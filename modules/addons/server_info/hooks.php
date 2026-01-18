<?php
/**
 * Hook Name: ClientAreaSecondarySidebar
 * Description: Añade credenciales y información del servidor al sidebar del área de cliente.
 * Author: Edinson Tique
 * Company: Qué Código
 * License: GPL
 * Created: 29/07/2024
 * Last Modified: 29/07/2024
 */
use WHMCS\ClientArea;
use WHMCS\View\Menu\Item as MenuItem;
use Illuminate\Database\Capsule\Manager as Capsule;

require_once 'functions.php';

// add_hook('ClientAreaPageProductDetails', 1, function($vars) {
// 	// Verificar si se solicita la vista de Snapshots
// 	if ($vars['filename'] === 'clientarea' && $_GET['action'] === 'productdetails' && $_GET['customaction'] === 'snapshots') {
// 		// Obtener los servidores ocultos
// 		$service = Menu::context('service');
// 		$serverid = "{$service->server}";
// 		$hiddenServers = Capsule::table('mod_hidden_servers')->pluck('server_id')->toArray();

// 		// Verificar si el servidor está en la lista de ocultos
// 		if (in_array($serverid, $hiddenServers)) {
// 			return;
// 		}

// 		$serviceId = (int) $_GET['id'];

// 		if (!$serviceId) {
// 			return;
// 		}

// 		$frequencyLabels = [
// 			'HOURLY'  => 'Cada Hora',
// 			'DAILY'   => 'Diariamente',
// 			'WEEKLY'  => 'Semanalmente',
// 			'MONTHLY' => 'Mensualmente'
// 		];

// 		$apiKey = getServerApiKey($serviceId);
// 		$deviceId = getAssignedDeviceId($serviceId);
// 		$snapshots = getSnapshots($deviceId, $apiKey);
// 		$schedules = getSchedules($deviceId, $apiKey);
// 		foreach ($schedules as &$schedule){
// 			$intervalType = $schedule['intervalType'];
// 			$schedule['frecuency'] = $frequencyLabels[$intervalType] ?? $intervalType;
// 		}

// 		$ca = new ClientArea();
// 		$ca->setPageTitle('Snapshots');
// 		$ca->addToBreadCrumb('index.php', 'Inicio');
// 		$ca->addToBreadCrumb('clientarea.php', 'Área de Cliente');
// 		$ca->addToBreadCrumb('clientarea.php?action=productdetails&id=' . $serviceId, 'Detalles del Servicio');
// 		$ca->initPage();

// 		// Ruta de la plantilla dentro del addon
// 		$templatePath = __DIR__ . '/templates/snapshots.tpl';

// 		// Verificar que la plantilla exista
// 		if (file_exists($templatePath)) {
// 			// Asignar variables a la plantilla
// 			$ca->assign('serviceId', $serviceId);
// 			$ca->assign('snapshots', $snapshots);
// 			$ca->assign('schedules', $schedules);

// 			// Mostrar la plantilla
// 			$ca->setTemplate('/modules/addons/server_info/templates/snapshots.tpl');
// 			$ca->output();
// 			exit;
// 		}
// 	}
// });

add_hook('ClientAreaPageProductDetails', 1, function($vars) {
	if(!isset($_GET['id'])) {
		return;
	}

	$serviceId = (int) $_GET['id'];
	if(!$serviceId) {
		return;
	}

	$apiKey = getServerApiKey($serviceId);
	$deviceId = getAssignedDeviceId($serviceId);

	// --- 1. MANEJO DE ACCIONES AJAX (PRIORIDAD ALTA - ANTES DE API PESADA) ---
	if ($_SERVER['REQUEST_METHOD'] === 'POST') {
		$ajaxAction = $_POST['ajax_action'] ?? $_GET['ajax_action'] ?? '';
		
		if ($ajaxAction) {
			logActivity("Snapshots Debug: Receving AJAX Action: " . $ajaxAction . " for Service ID: " . $serviceId);
			$result = ['success' => false, 'response' => 'Acción no permitida: ' . $ajaxAction];

			// Metadatos enviados desde el frontend para optimización
			$postVolumeId = $_POST['volume_id'] ?? $_POST['disk'] ?? '';
			$postFacilityCode = $_POST['facility_code'] ?? '';
			$postClientId = $_POST['client_id'] ?? '';

			if ($ajaxAction === 'create_snapshot') {
				$snapshotName = $_POST['snapshot_name'] ?? 'Snapshot-' . time();
				$resultData = createSnapshot($postVolumeId, $snapshotName, $apiKey, $postFacilityCode, $postClientId);
				$result = ['success' => (isset($resultData['taskId']) || isset($resultData['id'])), 'response' => $resultData];
			} elseif ($ajaxAction === 'create_schedule') {
				$frequency = $_POST['schedule'] ?? 'daily';
				$time = $_POST['time'] ?? '00:00';
				$hour = 0; $minute = 0;
				if (strpos($time, ':') !== false) {
					list($h, $m) = explode(':', $time);
					$hour = (int)$h;
					$minute = (int)$m;
				}
				
				$scheduleData = [
					'intervalType' => $frequency,
					'hour' => $hour,
					'minute' => $minute,
					'timezone' => 'UTC',
					'maxSnapshots' => 1
				];

				if ($frequency == 'weekly') {
					$tplDay = (int)$_POST['weekDay'];
					$scheduleData['weekday'] = ($tplDay === 0) ? 7 : $tplDay;
				}
				if ($frequency == 'monthly') $scheduleData['day'] = 1;

				$resultData = createSnapshotSchedule($postVolumeId, $scheduleData, $apiKey, $postFacilityCode, $postClientId);
				$result = ['success' => isset($resultData['snapshotScheduleId']), 'response' => $resultData];
			} elseif ($ajaxAction === 'delete_snapshot') {
				$snapshotId = $_POST['snapshot_id'] ?? '';
				$resultData = deleteSnapshot($snapshotId, $apiKey, $postFacilityCode);
				$result = ['success' => true, 'response' => $resultData];
			} elseif ($ajaxAction === 'restore_snapshot') {
				$snapshotId = $_POST['snapshot_id'] ?? '';
				$resultData = restoreSnapshot($snapshotId, $apiKey, $postFacilityCode, $postClientId);
				$result = ['success' => true, 'response' => $resultData];
			} elseif ($ajaxAction === 'delete_schedule') {
				$scheduleId = $_POST['schedule_id'] ?? '';
				$resultData = deleteSnapshotSchedule($scheduleId, $apiKey, $postFacilityCode);
				$result = ['success' => true, 'response' => $resultData];
			}

			// Si la acción fue exitosa, obtenemos las listas actualizadas para devolverlas
			if ($result['success']) {
				$updatedSnapshots = getSnapshots($deviceId, $apiKey, $postFacilityCode, $postClientId);
				$updatedSchedules = getSchedules($deviceId, $apiKey, $postFacilityCode);
				
				$frequencyLabels = [
					'HOURLY'  => 'Cada Hora',
					'DAILY'   => 'Diariamente',
					'WEEKLY'  => 'Semanalmente',
					'MONTHLY' => 'Mensualmente'
				];

				foreach ($updatedSchedules as &$schedule){
					$intervalType = $schedule['intervalType'];
					$schedule['frecuency'] = $frequencyLabels[$intervalType] ?? $intervalType;
				}

				$result['updated_data'] = [
					'snapshots' => $updatedSnapshots,
					'schedules' => $updatedSchedules
				];
			}

			if (ob_get_length()) ob_clean();
			header('Content-Type: application/json');
			echo json_encode($result);
			exit;
		}
	}

	// --- 2. CARGA NORMAL DE LA PÁGINA (CON API PESADA) ---
	if($_GET['customaction'] === 'snapshots') {
		$service = Menu::context('service');
		if(!$service) {
			return;
		}

		// Obtener detalles del VPS para volumeId y otros parámetros
		$vpsDetails = getVPSDetails($deviceId, $apiKey);
		$volumeId = $vpsDetails['volumeId'];
		$facilityCode = $vpsDetails['facilityCode'];
		$clientId = $vpsDetails['clientId'];

		$snapshots = getSnapshots($deviceId, $apiKey, $facilityCode, $clientId);
		$schedules = getSchedules($deviceId, $apiKey, $facilityCode);

		$frequencyLabels = [
			'HOURLY'  => 'Cada Hora',
			'DAILY'   => 'Diariamente',
			'WEEKLY'  => 'Semanalmente',
			'MONTHLY' => 'Mensualmente'
		];

		foreach ($schedules as &$schedule){
			$intervalType = $schedule['intervalType'];
			$schedule['frecuency'] = $frequencyLabels[$intervalType] ?? $intervalType;
		}

		$ca = new ClientArea();
		$ca->setPageTitle('Snapshots');
		$ca->addToBreadCrumb('index.php', 'Inicio');
		$ca->addToBreadCrumb('clientarea.php', 'Área de Cliente');
		$ca->addToBreadCrumb('clientarea.php?action=productdetails&id=' . $serviceId, 'Detalles del Servicio');
		$ca->initPage();

		// Ruta de la plantilla dentro del addon
		$templatePath = __DIR__ . '/templates/snapshots.tpl';

		// Verificar que la plantilla exista
		if (file_exists($templatePath)) {
			// Asignar variables a la plantilla
			$ca->assign('serviceId', $serviceId);
			$ca->assign('snapshots', $snapshots);
			$ca->assign('schedules', $schedules);
			$ca->assign('volumeId', $volumeId);
			$ca->assign('facilityCode', $facilityCode);
			$ca->assign('clientId', $clientId);

			// Mostrar la plantilla
			$ca->setTemplate('/modules/addons/server_info/templates/snapshots.tpl');
			$ca->output();
			exit;
		}
	}
});

add_hook('ClientAreaPageProductDetails', 1, function ($vars) {
    if (!isset($_GET['id'])) {
        return;
    }

    $serviceId = (int) $_GET['id'];
    if (!$serviceId) {
        return;
    }

    $secondarySidebar = Menu::context('secondarySidebar');
    if ($secondarySidebar) {
        $secondarySidebar->addChild('customTab', [
            'label' => 'Información General',
            'uri' => 'clientarea.php?action=productdetails&id=' . $serviceId,
            'icon' => 'fa-info-circle',
            'order' => 1,
            'attributes' => [
                'id' => 'customTabLink',
                'class' => 'custom-tab-link',
                'data-serviceid' => $serviceId,
            ],
        ]);
    }
});

/**
 * Función para obtener la contraseña desde la API usando cURL
 */
function fetch_server_hivelocity($apiUrl, $apiKey, $clientIp) {
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $apiUrl);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_HTTPHEADER, [
		'X-API-KEY: ' . $apiKey,
		'Accept: application/json',
		'X-Client-IP: ' . $clientIp,
	]);

	try {
		$response = curl_exec($ch);
		if (curl_errno($ch)) {
			throw new Exception('cURL error: ' . curl_error($ch));
		}

		$data = json_decode($response, true);
		curl_close($ch);

		logActivity('QCServerInfo: Response de la API: ' . $apiUrl . ' Apikey ' . $apiKey . ' Response ' . $response);

		return $data;
	} catch (Exception $e) {
		logActivity('QCServerInfo: Error fetching server password: ' . $e->getMessage());
		curl_close($ch);
		return null;
	}
}

add_hook('ClientAreaSecondarySidebar', 1, function (MenuItem $secondarySidebar) {
	if ($_GET['action'] === 'productdetails' && isset($_GET['id'])) {
		$serviceId = (int) $_GET['id'];
		$service = Menu::context('service');
		$username = "{$service->username}";
		$serverid = "{$service->server}";
		$domain = "{$service->domain}";
		$password = "{$service->password}";
		$password = decrypt($password);

		try {
			$hivelocity = true;
			// Obtener los servidores ocultos
			$hiddenServers = Capsule::table('mod_hidden_servers')->pluck('server_id')->toArray();

			// Verificar si el servidor está en la lista de ocultos
			if (in_array($serverid, $hiddenServers)) {
				logActivity("ServerInfo estoy en el array");
				$hivelocity = false;
			}

			// Obtener detalles del servidor
			$server = Capsule::table('tblservers')->where('id', '=', $serverid)->value('hostname');
			$ipaddress = Capsule::table('tblhosting')->where('id', '=', $serviceId)->value('dedicatedip');
			$ip6address = Capsule::table('tblhosting')->where('id', '=', $serviceId)->value('assignedips');
			//$name1 = Capsule::table('tblservers')->where('id', '=', $serverid)->value('nameserver1');
			//$name2 = Capsule::table('tblservers')->where('id', '=', $serverid)->value('nameserver2');
			$server_host = Capsule::table('tblservers')->where('id', '=', $serverid)->first();

			if ($server) {
				$useApiPassword = Capsule::table('mod_api_servers')->where('server_id', $serverid)->value('use_api');
				logActivity("ServerInfo en Antes respuesta: ".print_r($hivelocity, true));
				logActivity("ServerInfo Datos a comprobar: ".print_r($useApiPassword, true));
				if ($useApiPassword) {
					logActivity("ServerInfo en API desde: ".$username);
					$apiUrl = $server_host->hostname; // Suponiendo que el hostname es la URL de la API
					$apiKey = $server_host->accesshash; // Suponiendo que el accesshash es la clave de la API

					$deviceId = getAssignedDeviceId($serviceId);

					// Obtener la contraseña desde la API
					$serverDetails = fetch_server_hivelocity('https://' . $apiUrl . '/api/v2/vps/' . $deviceId, $apiKey, '205.209.118.18');
					logActivity("ServerInfo antes actualización de datos: ".print_r($serverDetails, true));
					//$serverDetails = null;

					if ($serverDetails) {
						
						logActivity("ServerInfo en actualización de datos: ".$serverDetails);
						$apiUsername = "root";
						$apiPassword = $serverDetails['password'] ?? null;
						$ipv4Address = $serverDetails['nics'][0]['ipAddress'] ?? null;
						$ipv6Address = $serverDetails['nics'][0]['ipv6Address'] ?? null;
						
						logActivity("ServerInfo Variables de actualización: ".print_r($apiPassword, true));
						logActivity("ServerInfo Variables de actualización: ".print_r($ipv4Address, true));
						logActivity("ServerInfo Variables de actualización: ".print_r($password, true));
						
						// Actualizar el usuario
						if ($apiUsername !== $username) {
							Capsule::table('tblhosting')
								->where('id', $serviceId)
								->update(['username' => $apiUsername]);
						}

						// Actualizar la contraseña en WHMCS si es diferente
						if ($apiPassword !== $password) {
							Capsule::table('tblhosting')
								->where('id', $serviceId)
								->update(['password' => encrypt($apiPassword)]);
						}

						// Actualizar direcciones IPv4 e IPv6 en WHMCS
						if ($ipv4Address || $ipv6Address) {
							Capsule::table('tblhosting')
								->where('id', $serviceId)
								->update([
									'dedicatedip' => trim($ipv4Address),
									'assignedips' => trim($ipv6Address)
								]);
						}

						// Actualizar la variable de contraseña para mostrarla
						$username = $apiUsername;
						$password = $apiPassword;
						$ipaddress = $ipv4Address;
						$ip6address = $ipv6Address;
					}

					// Agregar servicios al panel
					$secondarySidebar->addChild('serviceControl', array(
						'label' => 'Opciones del Servicio',
						'uri'   => '#',
						'icon'  => 'fa-cloud',
						'order' => 5,
					));

					$servicePanel = $secondarySidebar->getChild('serviceControl');

					$servicePanel->addChild('Snapshots', array(
						'label' => 'Gestionar Snapshots',
						'uri'   => 'clientarea.php?action=productdetails&id=' . $serviceId . '&customaction=snapshots',
						'icon'  => 'fa-camera',
						'order' => 10,
					));

					// Añadir botón para abrir el popup de la consola noVNC
					$secondarySidebar->addChild('noVNCConsole', array(
						'label' => 'Conexión noVNC',
						'uri' => '#',
						'icon' => 'fa-desktop',
						'order' => 6,
						'attributes' => array(
							'data-serviceid' => $serviceId
						),
					));

					$noVNCConsolePanel = $secondarySidebar->getChild('noVNCConsole');
					$consoleUrl = "{$vars['WEB_ROOT']}/modules/addons/server_info/noVNC.php?serviceid=" . urlencode($serviceId);

					$noVNCConsolePanel->addChild('popup_script', array(
						'label' => 'Abrir Consola',
						'uri' => $consoleUrl,
						'icon' => 'fa-desktop',
						'order' => 1,
						'attributes' => array(
							'id' => 'noVNCConsoleBtn',
							'class' => 'noVNCConsoleScript',
							'data-serviceid' => $serviceId
						),
					));

					$noVNCConsolePanel->moveToBack();
				}
			}

			if ($username != '') {
				$secondarySidebar->addChild('credentials', array(
					'label' => 'Credenciales',
					'uri' => '#',
					'icon' => 'fa-key',
				));
				$credentialPanel = $secondarySidebar->getChild('credentials');
				$credentialPanel->moveToBack();

				if (!empty($username)) {
					$credentialPanel->addChild('username', array(
						'label' => $username,
						'order' => 1,
						'icon' => 'fa-user',
					));
				}

				if (!empty($password)) {
					$credentialPanel->addChild('password', array(
						'label' => '<span id="password" onclick="togglePassword()" title="Haga clic para mostrar la contraseña">********</span><span id="realPassword" style="display: none;">' . $password . '</span>',
						'order' => 2,
						'icon' => 'fa-lock',
					));
				}

				if (!empty($domain)) {
					$credentialPanel->addChild('domain', array(
						'label' => $domain,
						'order' => 3,
						'icon' => 'fa-globe',
					));
				}

				$secondarySidebar->addChild('serverInfo', array(
					'label' => 'Server',
					'uri' => '#',
					'icon' => 'fa-server',
					'order' => 5,
				));

				$serverInfoPanel = $secondarySidebar->getChild('serverInfo');

				if (!empty($ipaddress)) {
					$serverInfoPanel->addChild('ipv4', array(
						'label' => '<span>'.trim($ipaddress).'</span>',
						'order' => 4,
						'icon' => 'fa-network-wired',
					));
				}

				if (!empty($ip6address)) {
					$serverInfoPanel->addChild('ipv6', array(
						'label' => '<span>'.trim($ip6address).'</span>',
						'order' => 5,
						'icon' => 'fa-network-wired',
					));
				}
			}
		} catch (\Illuminate\Database\QueryException $e) {
			logActivity('QCServerInfo: Error en el hook: ' . $e->getMessage());

			$secondarySidebar->addChild('error', array(
				'label' => 'Error: Problema de base de datos. Por favor, verifica los permisos.',
				'uri' => '#',
				'icon' => 'fa-exclamation-circle',
			));
		} catch (Exception $e) {
			logActivity('QCServerInfo: Error en el hook: ' . $e->getMessage());

			$secondarySidebar->addChild('error', array(
				'label' => 'Error: ' . $e->getMessage(),
				'uri' => '#',
				'icon' => 'fa-exclamation-circle',
			));
		}
	}
});

add_hook('ClientAreaPrimaryNavbar', 1, function ($primaryNavbar) {
    if ($_GET['action'] === 'productdetails' && isset($_GET['id'])) {
        $serviceId = (int)$_GET['id'];
        $service = Menu::context('service');
        if (!$service) return;

        $productDetails = $primaryNavbar->getChild('Service Details Tabs');
        if (is_null($productDetails)) {
            $productDetails = $primaryNavbar;
        }

        $productDetails->addChild('Snapshots', [
            'label' => 'Snapshots',
            'uri' => 'clientarea.php?action=productdetails&id=' . $serviceId . '&customaction=snapshots',
            'order' => 50,
        ]);

        if ($_GET['customaction'] === 'snapshots') {
            $productDetails->getChild('Snapshots')->setCurrent(true);
        }
    }
});

add_hook('ClientAreaHeaderOutput', 1, function (array $vars) {
	if ($vars['filename'] == 'clientarea' AND $_GET['action'] == 'productdetails' AND isset($_GET['id'])) {
		$output = '';
		$output .= "<style>
			#loadingOverlay {
				position: fixed;
				top: 0;
				left: 0;
				width: 100%;
				height: 100%;
				background: rgba(0, 0, 0, 0.5);
				color: white;
				display: none;
				align-items: center;
				justify-content: center;
				z-index: 1000;
			}
			#loadingOverlay span {
				font-size: 20px;
			}

			#password {
				cursor: pointer;
				border-bottom: 1px dotted;
				position: relative;
			}
			#password::after {
				content: attr(title);
				position: absolute;
				top: 125%;
				left: 50%;
				transform: translateX(-50%);
				background: #333;
				color: #fff;
				padding: 5px 10px;
				border-radius: 5px;
				font-size: 12px;
				white-space: nowrap;
				display: none;
				z-index: 1001;
			}
			#password:hover::after {
				display: block;
			}
		</style>";

		$output .= "<div id='loadingOverlay'><span>Cargando...</span></div>";
		return $output;
	}
});
add_hook('ClientAreaHeaderOutput', 1, function (array $vars) {
	if ($vars['filename'] == 'clientarea' AND $_GET['action'] == 'productdetails' AND isset($_GET['id'])) {
		$output = "<script>
			function togglePassword() {
				var passwordField = document.getElementById('password');
				var realPasswordField = document.getElementById('realPassword');
				if (passwordField.innerHTML === '********') {
					passwordField.innerHTML = realPasswordField.innerHTML;
					passwordField.title = 'Haga clic para copiar la contraseña';
				} else {
					copyPassword(realPasswordField.innerHTML);
				}
			}

			function copyPassword(password) {
				var textarea = document.createElement('textarea');
				textarea.value = password;
				document.body.appendChild(textarea);
				textarea.select();
				document.execCommand('copy');
				document.body.removeChild(textarea);
				alert('¡Contraseña Copiada al Portapapeles!\\n\\nRecuerda que esta es una contraseña temporal.\\nSi no funciona, es probable que haya sido actualizada.\\n\\nSi deseas recuperarla, por favor contacta al equipo de soporte.');
			}

			document.addEventListener('DOMContentLoaded', function() {
				document.querySelectorAll('.noVNCConsoleScript').forEach(function(link) {
					link.addEventListener('click', function(event) {
						event.preventDefault(); // Evitar el comportamiento predeterminado del enlace

						var href = this.getAttribute('href');
						if (!href) {
							console.error('Href not found');
							return;
						}

						var loadingOverlay = document.getElementById('loadingOverlay');
						loadingOverlay.style.display = 'flex'; // Mostrar overlay de carga

						fetch(href)
							.then(response => response.json())
							.then(data => {
								loadingOverlay.style.display = 'none'; // Ocultar overlay de carga
								if (data.success) {
									var popup = window.open('', 'noVNCConsole', 'width=800,height=600');
									popup.document.write('<html><head><title>Consola noVNC</title></head><body>');
									popup.document.write('<iframe src=\"' + data.url + '\" width=\"100%\" height=\"100%\" style=\"border: none;\"></iframe>');
									popup.document.write('</body></html>');
									popup.document.close();
								} else {
									loadingOverlay.style.display = 'none'; // Ocultar overlay de carga
									alert('Error obteniendo la URL de la consola: ' + data.error);
								}
							})
							.catch(error => console.error('Error:', error));
					});
				});
			});
		</script>";
		return $output;
	}
});