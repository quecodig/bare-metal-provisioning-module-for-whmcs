<?php

define("CLIENTAREA", true);

// Autocargar WHMCS
// Asegúrate de que `init.php` solo se incluye una vez
require_once(__DIR__ . "/../../../init.php");

// Verificar autenticación
if (!isset($_SESSION['uid'])) {
    echo json_encode(['success' => false, 'error' => 'No autenticado']);
    exit;
}

use Illuminate\Database\Capsule\Manager as Capsule;

$serviceId = intval($_GET['serviceid']);

// Asegurarse de que el usuario tenga acceso a este servicio
$service = Capsule::table('tblhosting')
    ->where('id', $serviceId)
    ->where('userid', $_SESSION['uid'])
    ->first();

if ($service) {
    $deviceId = getAssignedDeviceId($serviceId);
    if ($deviceId) {
        try {
			$serverId = $service->server;
			$server = Capsule::table('tblservers')->where('id', $serverId)->first();
			$apiUrl = $server->hostname;
			$apiKey = $server->accesshash;
            // Realizar una solicitud HTTP a la API para obtener la URL
            $apiUrl = 'https://'.$apiUrl.'/api/v2/vps/' . $deviceId . '/console';

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $apiUrl);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'accept: application/json',
                'X-API-KEY: ' . $apiKey,
            ]);

            $response = curl_exec($ch);

            if (curl_errno($ch)) {
                throw new Exception('cURL error: ' . curl_error($ch));
            }
			
			logActivity('QCServerInfo: noVPC de la API: '.$response);

            $data = json_decode($response, true);
            curl_close($ch);

            if (isset($data['url'])) {
                echo json_encode(['success' => true, 'url' => $data['url']]);
            } else {
                echo json_encode(['success' => false, 'error' => 'URL de la consola no encontrada']);
            }
        } catch (Exception $e) {
			curl_close($ch);
            echo json_encode(['success' => false, 'error' => 'Error: ' . $e->getMessage()]);
        }
    } else {
        echo json_encode(['success' => false, 'error' => 'Device ID no encontrado']);
    }
} else {
    echo json_encode(['success' => false, 'error' => 'Servicio no encontrado o acceso denegado']);
}
exit;