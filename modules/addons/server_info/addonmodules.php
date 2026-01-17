<?php
function server_info_config() {
    return [
        'name' => 'Gestor de Snapshots',
        'description' => 'Permite gestionar snapshots de servidores VPS.',
        'version' => '1.0',
        'author' => 'Qué Código',
    ];
}

require_once __DIR__ . '/functions.php';

function server_info_clientarea($vars) {
    // Verificar archivo de funciones
    if (!function_exists('getAssignedDeviceId')) {
        require_once __DIR__ . '/functions.php';
    }

    $action = $_GET['action'] ?? '';
    $serviceId = $_GET['serviceid'] ?? 0;

    if (!$serviceId) {
         return ['vars' => ['error' => 'No Service ID provided']];
    }

    $apiKey = getServerApiKey($serviceId);
    $deviceId = getAssignedDeviceId($serviceId);

    if (!$deviceId) {
         return ['vars' => ['error' => 'Device ID not found for this service. Please contact support.']];
    }

    // Obtener detalles del VPS una sola vez
    $vpsDetails = getVPSDetails($deviceId, $apiKey);
    $volumeId = $vpsDetails['volumeId'];
    $facilityCode = $vpsDetails['facilityCode'];
    $clientId = $vpsDetails['clientId'];

    // --- ACCIONES SNAPSHOTS ---

    // Crear Snapshot Manual
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $action == 'create_snapshot') {
        $snapshotName = $_POST['snapshot_name'] ?? 'Snapshot-' . time();
        $postVolumeId = $_POST['volume_id'] ?? $volumeId;

        $result = createSnapshot($postVolumeId, $snapshotName, $apiKey, $facilityCode, $clientId);
        
        if (ob_get_length()) ob_clean();
        header('Content-Type: application/json');
        echo json_encode(['success' => isset($result['taskId']) || isset($result['id']) ? true : false, 'response' => $result]);
        exit;
    }

    // Eliminar Snapshot
    if ($action == 'delete_snapshot' && isset($_GET['snapshot_id'])) {
        $snapshotId = $_GET['snapshot_id'];
        $result = deleteSnapshot($snapshotId, $apiKey, $facilityCode);
        
        header("Location: index.php?m=server_info&action=productdetails&id=$serviceId&customaction=snapshots");
        exit;
    }

    // Restaurar Snapshot
    if ($action == 'restore_snapshot' && isset($_GET['snapshot_id'])) {
        $snapshotId = $_GET['snapshot_id'];
        $result = restoreSnapshot($snapshotId, $apiKey, $facilityCode, $clientId);
        
        header("Location: index.php?m=server_info&action=productdetails&id=$serviceId&customaction=snapshots&msg=restored");
        exit;
    }

    // --- ACCIONES SCHEDULES ---
    
    // Crear Schedule
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $action == 'create_schedule') {
        
        $frequency = $_POST['schedule'] ?? 'daily';
        $time = $_POST['time'] ?? '00:00';
        $hour = 0; 
        $minute = 0;
        if (strpos($time, ':') !== false) {
             list($h, $m) = explode(':', $time);
             $hour = (int)$h;
             $minute = (int)$m;
        }

        $scheduleData = [
            'intervalType' => $frequency,
            'hour' => $hour,
            'minute' => $minute,
            'timezone' => 'UTC', // Podría ser dinámico si se requiere
            'maxSnapshots' => 1
        ];

        if ($frequency == 'weekly') {
            $tplDay = (int)$_POST['weekDay'];
            $weekday = ($tplDay === 0) ? 7 : $tplDay;
            $scheduleData['weekday'] = $weekday;
        }
        
        if ($frequency == 'monthly') {
             $scheduleData['day'] = 1;
        }
        
        $postVolumeId = $_POST['volume_id'] ?? $_POST['disk'] ?? $volumeId;
        $result = createSnapshotSchedule($postVolumeId, $scheduleData, $apiKey, $facilityCode, $clientId);
        
        if (ob_get_length()) ob_clean();
        header('Content-Type: application/json');
        echo json_encode(['success' => isset($result['snapshotScheduleId']) ? true : false, 'response' => $result]);
        exit;
    }
    
    // Eliminar Schedule
    if ($action == 'delete_schedule' && isset($_GET['schedule_id'])) {
        $scheduleId = $_GET['schedule_id'];
        $result = deleteSnapshotSchedule($scheduleId, $apiKey, $facilityCode);
        header("Location: index.php?m=server_info&action=productdetails&id=$serviceId&customaction=snapshots");
        exit;
    }

    // Default: Render Template
    $snapshots = getSnapshots($deviceId, $apiKey, $facilityCode, $clientId);
    $schedules = getSchedules($deviceId, $apiKey, $facilityCode);
    
    return [
        'templatefile' => 'snapshots',
        'vars' => [
            'snapshots' => $snapshots,
            'schedules' => $schedules,
            'serviceId' => $serviceId,
            'volumeId'  => $volumeId,
            'msg'       => $_GET['msg'] ?? ''
        ]
    ];
}