<?php
use Illuminate\Database\Capsule\Manager as Capsule;

// Obtener la API Key del servidor
function getServerApiKey($serviceId) {
    $service = Capsule::table('tblhosting')->where('id', $serviceId)->first();
    return Capsule::table('tblservers')->where('id', $service->server)->value('accesshash');
}

// Obtener Snapshots desde la API
function getSnapshots($vpsId, $apiKey, $facilityCode = '', $clientId = '') {
    $url = "https://core.hivelocity.net/api/v2/vps/snapshot?deviceId=$vpsId";
    if ($facilityCode) $url .= "&facilityCode=$facilityCode";
    if ($clientId) $url .= "&clientId=$clientId";

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

// Obtener Snapshot por ID
function getSnapshot($snapshotId, $apiKey, $facilityCode = 'TPA1') {
    // Official Endpoint based on User provided OpenAPI: 
    // GET https://core.hivelocity.net/api/v2/vps/snapshot/{snapshotId}?facilityCode={facilityCode}
    
    $url = "https://core.hivelocity.net/api/v2/vps/snapshot/$snapshotId?facilityCode=$facilityCode";
    
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

function getSchedules($vpsId, $apiKey, $facilityCode = '') {
	$url = "https://core.hivelocity.net/api/v2/vps/snapshotSchedule?deviceId=$vpsId";
    if ($facilityCode) $url .= "&facilityCode=$facilityCode";

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
function createSnapshot($volumeId, $snapshotName, $apiKey, $facilityCode = 'TPA1') {
    // Official Endpoint based on User provided OpenAPI: 
    // POST https://core.hivelocity.net/api/v2/vps/snapshot
    // Body keys: volumeId, name, facilityCode
    
    $url = "https://core.hivelocity.net/api/v2/vps/snapshot";
    
    $payload = [
        'volumeId' => (string)$volumeId,
        'name' => $snapshotName,
        'facilityCode' => $facilityCode
    ];
    if ($clientId) $payload['clientId'] = (int)$clientId;

    $data = json_encode($payload);

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
function deleteSnapshot($snapshotId, $apiKey, $facilityCode = 'TPA1') {
    // Official Action based on User provided OpenAPI: 
    // DELETE https://core.hivelocity.net/api/v2/vps/snapshot/{snapshotId}?facilityCode={facilityCode}
    
    $url = "https://core.hivelocity.net/api/v2/vps/snapshot/$snapshotId?facilityCode=$facilityCode";
    
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



// Restaurar Snapshot
function restoreSnapshot($snapshotId, $apiKey, $facilityCode = 'TPA1') {
    // Official Endpoint based on User provided OpenAPI: 
    // POST https://core.hivelocity.net/api/v2/vps/snapshot/{snapshotId}
    // Body required: { "facilityCode": "TPA1" }
    
    $url = "https://core.hivelocity.net/api/v2/vps/snapshot/$snapshotId";
    
    $payload = [
        'facilityCode' => $facilityCode
    ];
    if ($clientId) $payload['clientId'] = (int)$clientId;
    
    $data = json_encode($payload);
    
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

// --- SCHEDULES ---

// Crear Schedule
function createSnapshotSchedule($volumeId, $scheduleData, $apiKey, $facilityCode = 'TPA1') {
    // Official Endpoint based on User provided OpenAPI: 
    // POST https://core.hivelocity.net/api/v2/vps/snapshotSchedule
    // Required: facilityCode, hour, intervalType, maxSnapshots, minute, timezone, volumeId
    
    $url = "https://core.hivelocity.net/api/v2/vps/snapshotSchedule";
    
    $payload = [
        'volumeId' => (string)$volumeId,
        'facilityCode' => $facilityCode,
        'intervalType' => strtoupper($scheduleData['intervalType']), // DAILY, WEEKLY, MONTHLY
        'hour' => (int)$scheduleData['hour'],
        'minute' => isset($scheduleData['minute']) ? (int)$scheduleData['minute'] : 0,
        'maxSnapshots' => isset($scheduleData['maxSnapshots']) ? (int)$scheduleData['maxSnapshots'] : 1, // Default 1
        'timezone' => isset($scheduleData['timezone']) ? $scheduleData['timezone'] : 'UTC', // Default UTC
    ];
    if ($clientId) $payload['clientId'] = (int)$clientId;

    if (isset($scheduleData['day'])) {
        $payload['day'] = (int)$scheduleData['day'];
    }
    
    // Validar weekday: API 1-7 (1=Monday).
    if (isset($scheduleData['weekday'])) {
        $payload['weekday'] = (int)$scheduleData['weekday'];
    }

    $data = json_encode($payload);

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

// Obtener Schedule por ID
function getSnapshotSchedule($scheduleId, $apiKey, $facilityCode = 'TPA1') {
    // Official Endpoint based on User provided OpenAPI: 
    // GET https://core.hivelocity.net/api/v2/vps/snapshotSchedule/{snapshotScheduleId}?facilityCode={facilityCode}
    
    $url = "https://core.hivelocity.net/api/v2/vps/snapshotSchedule/$scheduleId?facilityCode=$facilityCode";
    
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



// Eliminar Schedule
function deleteSnapshotSchedule($scheduleId, $apiKey, $facilityCode = 'TPA1') {
    // Official Endpoint based on User provided OpenAPI: 
    // DELETE https://core.hivelocity.net/api/v2/vps/snapshotSchedule/{snapshotScheduleId}?facilityCode={facilityCode}
    
    $url = "https://core.hivelocity.net/api/v2/vps/snapshotSchedule/$scheduleId?facilityCode=$facilityCode";
    
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

function getVPSDetails($vpsId, $apiKey) {
    $url = "https://core.hivelocity.net/api/v2/vps/$vpsId";
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer $apiKey",
        "Content-Type: application/json"
    ]);
    
    $response = curl_exec($ch);
    curl_close($ch);
    $data = json_decode($response, true);

    $details = [
        'volumeId' => '',
        'facilityCode' => $data['facilityCode'] ?? 'TPA1',
        'clientId' => $data['clientId'] ?? ''
    ];

    if (isset($data['primaryDisk']) && isset($data['primaryDisk']['id'])) {
        $details['volumeId'] = $data['primaryDisk']['id'];
    } elseif (isset($data['primary_volume_id'])) {
        $details['volumeId'] = $data['primary_volume_id'];
    } elseif (isset($data['volumes']) && !empty($data['volumes'])) {
        $details['volumeId'] = $data['volumes'][0]['id'];
    }
    
    return $details;
}

function getAssignedDeviceId($serviceId) {
	$serviceId = intval($serviceId);
	$pdo = Capsule::connection()->getPdo();
	$pdo->beginTransaction();
	$query = "SELECT tblcustomfieldsvalues.value 
			  FROM tblcustomfieldsvalues 
			  INNER JOIN tblcustomfields ON tblcustomfieldsvalues.fieldid = tblcustomfields.id 
			  WHERE tblcustomfields.fieldname LIKE 'hivelocityDeviceId%' AND tblcustomfieldsvalues.relid = ?";
	$statement = $pdo->prepare($query);
	$statement->execute([$serviceId]);
	$row = $statement->fetch();
	$pdo->commit();
	if (isset($row["value"]) && !empty($row["value"])) {
		return $row["value"];
	} else {
		return false;
	}
}