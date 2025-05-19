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
    $action = $_GET['action'] ?? '';
    $serviceId = $_GET['serviceid'] ?? 0;
    $apiKey = getServerApiKey($serviceId);

    // Procesar acciones de creación y eliminación de snapshots
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $action == 'create_snapshot') {
        $snapshotName = $_POST['snapshot_name'] ?? 'Snapshot-' . time();
        $volumeId = $_POST['volume_id'] ?? '';  // Debes obtener el volumeId correspondiente
        $facilityCode = "TPA1"; // Puedes obtenerlo dinámicamente si es necesario

        $result = createSnapshot($snapshotName, $facilityCode, $volumeId, $apiKey);
        header('Content-Type: application/json');
        echo json_encode(['success' => $result ? true : false, 'response' => $result]);
        exit;
    }

    if ($action == 'delete_snapshot' && isset($_GET['snapshot_id'])) {
        $snapshotId = $_GET['snapshot_id'];
        $result = deleteSnapshot($snapshotId, $apiKey);
        header('Content-Type: application/json');
        echo json_encode(['success' => $result ? true : false]);
        exit;
    }

    return [
        'templatefile' => 'snapshots',
        'vars' => [
            'snapshots' => getSnapshots($serviceId, $apiKey)
        ]
    ];
}