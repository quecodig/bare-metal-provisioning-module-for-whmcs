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
function createSnapshot($volumeId, $snapshotName, $apiKey, $facilityCode = 'TPA1') {
    // Official Endpoint based on User provided OpenAPI: 
    // POST https://core.hivelocity.net/api/v2/vps/snapshot
    // Body keys: volumeId, name, facilityCode
    
    $url = "https://core.hivelocity.net/api/v2/vps/snapshot";
    
    $data = json_encode([
        'volumeId' => $volumeId,     // OpenAPI Spec: volumeId (camelCase)
        'name' => $snapshotName,
        'facilityCode' => $facilityCode
    ]);

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
    
    $data = json_encode([
        'facilityCode' => $facilityCode
    ]);
    
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
        'volumeId' => $volumeId,
        'facilityCode' => $facilityCode,
        'intervalType' => strtoupper($scheduleData['intervalType']), // DAILY, WEEKLY, MONTHLY
        'hour' => (int)$scheduleData['hour'],
        'minute' => isset($scheduleData['minute']) ? (int)$scheduleData['minute'] : 0,
        'maxSnapshots' => isset($scheduleData['maxSnapshots']) ? (int)$scheduleData['maxSnapshots'] : 1, // Default 1
        'timezone' => isset($scheduleData['timezone']) ? $scheduleData['timezone'] : 'UTC', // Default UTC
    ];

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

function getVolumeId($vpsId, $apiKey) {
    // Helper para obtener el ID real del volumen (disco) dado el ID del dispositivo VPS
    // El endpoint /vps/{vpsId} suele retornar detalles que incluyen volumes
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
    logActivity("QCServerInfo: getVolumeId Response for VPS $vpsId: " . print_r($data, true));
    
    // Asumimos que retornan un array de volúmenes o el primario.
    // Ajustar según respuesta real. Por ahora asumimos que el usuario selecciona o se toma el raiz.
    // Si la API retorna 'primary_volume_id' o similar, usarlo.
    // Estructura común HV: { "primary_volume_id": 12345 ... } o en "volumes": [...]
    
    
    // Check for "primaryDisk" object (V2 standard)
    if (isset($data['primaryDisk']) && isset($data['primaryDisk']['id'])) {
        return $data['primaryDisk']['id'];
    }

    // Check for "primary_volume_id" (Legacy/Alternative)
    if (isset($data['primary_volume_id'])) {
        return $data['primary_volume_id'];
    }

    // Fallback: Use first volume in "volumes" array
    if (isset($data['volumes']) && is_array($data['volumes']) && !empty($data['volumes'])) {
        return $data['volumes'][0]['id'];
    }
    
    return false;
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