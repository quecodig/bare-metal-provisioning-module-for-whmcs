<?php
use Illuminate\Database\Capsule\Manager as Capsule;

// Obtener la API Key del servidor
function getServerApiKey($serviceId) {
    $service = Capsule::table('tblhosting')->where('id', $serviceId)->first();
    return Capsule::table('tblservers')->where('id', $service->server)->value('accesshash');
}

// Obtener Snapshots desde la API
function getSnapshots($vpsId, $apiKey) {
    $url = "https://core.hivelocity.net/api/v2/vps/snapshot?deviceId=$vpsId";
    logActivity('URL DE LOS SNAPS '.print_r($url, true));
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer $apiKey",
        "Content-Type: application/json"
    ]);

    $response = curl_exec($ch);
    curl_close($ch);

    return json_decode($response, true);
}

function getSchedules($vpsId, $apiKey) {
	$url = "https://core.hivelocity.net/api/v2/vps/snapshotSchedule?deviceId=$vpsId";
    logActivity('URL DE LOS SNAPS '.print_r($url, true));
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer $apiKey",
        "Content-Type: application/json"
    ]);

    $response = curl_exec($ch);
    curl_close($ch);

    return json_decode($response, true);
}

// Crear Snapshot
function createSnapshot($vpsId, $snapshotName, $apiKey) {
    $url = "https://core.hivelocity.net/api/v2/vps/$vpsId/snapshots";
    
    $data = json_encode(['name' => $snapshotName]);

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer $apiKey",
        "Content-Type: application/json"
    ]);

    $response = curl_exec($ch);
    curl_close($ch);

    return json_decode($response, true);
}

// Eliminar Snapshot
function deleteSnapshot($vpsId, $snapshotId, $apiKey) {
    $url = "https://core.hivelocity.net/api/v2/vps/$vpsId/snapshots/$snapshotId";
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer $apiKey",
        "Content-Type: application/json"
    ]);

    $response = curl_exec($ch);
    curl_close($ch);

    return json_decode($response, true);
}