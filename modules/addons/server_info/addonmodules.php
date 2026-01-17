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

    // --- ACCIONES SNAPSHOTS ---

    // Crear Snapshot Manual
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $action == 'create_snapshot') {
        $snapshotName = $_POST['snapshot_name'] ?? 'Snapshot-' . time();
        
        // Obtener Volume ID (Requerido para V2)
        $volumeId = $_POST['volume_id'] ?? '';
        if (empty($volumeId)) {
             $volumeId = getVolumeId($deviceId, $apiKey);
        } 

        $result = createSnapshot($volumeId, $snapshotName, $apiKey);
        
        // Clean buffer to avoid HTML pollution
        if (ob_get_length()) ob_clean();
        header('Content-Type: application/json');
        echo json_encode(['success' => isset($result['id']) || isset($result['name']) ? true : false, 'response' => $result]);
        exit;
    }
    


    // Eliminar Snapshot
    if ($action == 'delete_snapshot' && isset($_GET['snapshot_id'])) {
        $snapshotId = $_GET['snapshot_id'];
        $result = deleteSnapshot($snapshotId, $apiKey);
        
        // Redirigir para refrescar
        header("Location: index.php?m=server_info&action=productdetails&id=$serviceId&customaction=snapshots");
        exit;
    }

    // Restaurar Snapshot
    if ($action == 'restore_snapshot' && isset($_GET['snapshot_id'])) {
        $snapshotId = $_GET['snapshot_id'];
        $result = restoreSnapshot($snapshotId, $apiKey);
        
        // Redirigir con mensaje? Por ahora reload
        header("Location: index.php?m=server_info&action=productdetails&id=$serviceId&customaction=snapshots&msg=restored");
        exit;
    }

    // --- ACCIONES SCHEDULES ---
    
    // Crear/Actualizar Schedule
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $action == 'create_schedule') {
        
        $frequency = $_POST['schedule'] ?? 'daily';
        
        // Parsear hora (HH:MM)
        $time = $_POST['time'] ?? '00:00';
        $hour = 0; 
        $minute = 0;
        if (strpos($time, ':') !== false) {
             list($h, $m) = explode(':', $time);
             $hour = (int)$h;
             $minute = (int)$m;
        }

        $scheduleData = [
            'intervalType' => $frequency, // functions.php lo convertirá a strtoupper
            'hour' => $hour,
            'minute' => $minute
        ];

        // Dia de la semana (Weekly)
        if ($frequency == 'weekly') {
            // TPL envía 0-6 (0=Domingo). API V2 espera 1-7 (1=Lunes).
            $tplDay = (int)$_POST['weekDay'];
            // Mapa: 1(Lun)->1, ..., 6(Sab)->6, 0(Dom)->7
            $weekday = ($tplDay === 0) ? 7 : $tplDay;
            $scheduleData['weekday'] = $weekday;
        }
        
        // Dia del mes (Monthly)
        if ($frequency == 'monthly') {
             // TPL actual no tiene input de día del mes, por defecto 1
             $scheduleData['day'] = 1;
        }
        
        if ($action == 'create_schedule') {
            // Obtener Volume ID para Create
            $volumeId = $_POST['volume_id'] ?? '';
            if (empty($volumeId)) {
                 $volumeId = $_POST['disk'] ?? '';
            }
            if (empty($volumeId) || !is_numeric($volumeId)) {
                 $realVolumeId = getVolumeId($deviceId, $apiKey); 
                 if ($realVolumeId) {
                     $volumeId = $realVolumeId;
                 }
            }
            $result = createSnapshotSchedule($volumeId, $scheduleData, $apiKey);
        }
        
        // Clean buffer to avoid HTML pollution
        if (ob_get_length()) ob_clean();
        header('Content-Type: application/json');
        echo json_encode(['success' => isset($result['id']) || isset($result['snapshotScheduleId']) ? true : false, 'response' => $result]);
        exit;
    }
    
    // Eliminar Schedule
    if ($action == 'delete_schedule' && isset($_GET['schedule_id'])) {
        $scheduleId = $_GET['schedule_id'];
        $result = deleteSnapshotSchedule($scheduleId, $apiKey);
        header("Location: index.php?m=server_info&action=productdetails&id=$serviceId&customaction=snapshots");
        exit;
    }

    // Default: Render Template
    $snapshots = getSnapshots($deviceId, $apiKey);
    $schedules = getSchedules($deviceId, $apiKey);
    
    // Obtener volume ID para el formulario si se necesita
    $volumeId = getVolumeId($deviceId, $apiKey);

    return [
        'templatefile' => 'snapshots',
        'vars' => [
            'snapshots' => $snapshots,
            'schedules' => $schedules,
            'serviceId' => $serviceId,
            'volumeId'  => $volumeId, // Para prellenar el formulario
            'msg'       => $_GET['msg'] ?? ''
        ]
    ];
}