<?php
namespace Hivelocity\classes;

use DateTime;
use Illuminate\Database\Capsule\Manager as Capsule;

class Addon {
	static public function getConfig($params) {
		Helpers::maintenanceDatabase();
		$_LANG = Helpers::lang('hivelocity');

		$productId          = $_POST["id"];
		$serverGroupId      = $_POST["servergroup"];

		if(empty($serverGroupId)) {

			$script = <<<SCRIPT
			<script>
				$("#noModuleSelectedRow").next().html('<td><div class="no-module-selected">Choose a server group to load configuration settings</div></td>');
			</script>
SCRIPT;

			return array(
				"noServer" => array (
					"FriendlyName"  => "No Server",
					"Type"          => "text",
					"Size"          => "25",
					"Description"   => $script,
				)
			);
		}

		$serverConfig       = Helpers::getServerConfigByServerGroupId($serverGroupId);

		$apiUrl             = $serverConfig["hostname"];
		$apiKey             = $serverConfig["accesshash"];

		Api::setApiDetails($apiUrl, $apiKey);

		try {
			$remoteProductList  = Api::getProductList();
			$productOptions     = array();

			foreach($remoteProductList as $location => $list) {

				foreach($list as $remoteProduct) {

					$remoteProductId            = $remoteProduct["product_id"];
					$displayString              = $remoteProduct["product_id"]." - ".$remoteProduct["product_cpu"]." - ".$remoteProduct["product_memory"]." - ".$remoteProduct["product_drive"]." (".$remoteProduct["product_monthly_price"]." USD)";

					$productOptions[$remoteProductId]  = $displayString;
				}
			}

			$billingInfoList    = Api::getBillingInfoList();

			$billingOptions     = array();

			foreach($billingInfoList as $billingInfo) {

				$billingOptions[$billingInfo["id"]] = $billingInfo["ccType"]." **** **** **** ".$billingInfo["ccNum"];
			}

		} catch(\Exception $e) {

			$script = <<<SCRIPT
			<script>
				$("#noModuleSelectedRow").next().html('<td><div class="no-module-selected">Server connection error</div></td>');
			</script>
SCRIPT;
			return array(
				"noServer" => array (
					"FriendlyName"  => "No Server",
					"Type"          => "text",
					"Size"          => "25",
					"Description"   => $script,
				)
			);
		}

		$script = <<<SCRIPT
			<script>
				var hivelocityProductId = $productId;
			</script>
			<script src="../modules/servers/Hivelocity/templates/js/modifyProductConfig.js" type="text/javascript"></script>
SCRIPT;

		$configArray = array(
			"product" => array (
				"FriendlyName"  => "Product",
				"Type"          => "dropdown",
				"Size"          => "25",
				"Options"       => $productOptions,
				"Description"   => $script,
			),
			"" => array(),
			"billingInfo" => array (
				"FriendlyName"  => "Billing Info",
				"Type"          => "dropdown",
				"Size"          => "25",
				"Options"       => $billingOptions,
			),
		);

		$remoteProductId        = Helpers::getRemoteProductIdByProductId($productId);

		if($remoteProductId === false) {
			return $configArray;
		}
		try {
			$remoteProductDetails       = Api::getProductDetails($remoteProductId);
			$remoteProductOS            = Api::getProductOS($remoteProductId);
			$remoteProductOptions       = Api::getProductOptions($remoteProductId);
		} catch (\Exception $e) {
			return $configArray;
		}

//------------------------------------------------------------------------------

		$locationOptions                    = array();

		foreach($remoteProductDetails as $location => $details) {

			$price                          = floatval($details[0]["monthly_location_premium"]);
			$displayString                  = Helpers::getLocationName($location);

			if(!empty($price)) {
				$price          = number_format($price, 2);
				$displayString .= " ($price USD)";
			}

			$locationOptions[$location]     = $displayString;
		}

		$configArray["location"]            = array(
			"FriendlyName"  => "Location",
			"Type"          => "dropdown",
			"Size"          => "25",
			"Options"       => $locationOptions,
		);

		//------------------------------------------------------------------------------

		$osOptions          = array();

		foreach($remoteProductOS as $os) {

			$price                          = floatval($os["monthlyPrice"]);
			$name                           = $os["name"];
			$displayString                  = $name;

			if(!empty($price)) {
				$price          = number_format($price, 2);
				$displayString .= " ($price USD)";
			}

			$osOptions[$name]               = $displayString;
		}

		$configArray["os"]  = array(
			"FriendlyName"      => "Operating System",
			"Type"              => "dropdown",
			"Size"              => "25",
			"Options"           => $osOptions,
		);

		//------------------------------------------------------------------------------
		$remoteProductOptions = Helpers::filterProductOptions($remoteProductOptions);

		foreach($remoteProductOptions as $optionName => $subOptions) {
			$options = array();

			foreach($subOptions as $subOption) {
				$price                          = floatval($subOption["monthlyPrice"]);
				$name                           = $subOption["name"];
				$displayString                  = $name;

				if(!empty($price)) {
					$price          = number_format($price, 2);
					$displayString .= " ($price USD)";
				}
				$options[$subOption["id"]] = $displayString;
			}

			$configArray[$optionName]  = array(
				"FriendlyName"      => $optionName,
				"Type"              => "dropdown",
				"Size"              => "25",
				"Options"           => $options,
			);
		}

		return $configArray;
	}
	static public function create($params) {
		$apiUrl             = $params["serverhostname"];
		$apiKey             = $params["serveraccesshash"];

		Api::setApiDetails($apiUrl, $apiKey);

		// Check if billing info is valid BEGIN
		$billingInfoId      = $params["configoption3"];
		$billingOptionValid = false;
		$billingInfoList    = Api::getBillingInfoList();

		foreach($billingInfoList as $billingInfo) {
			if ($billingInfo["id"] == $billingInfoId) {
				$billingOptionValid = true;
				break;
			}
		}

		if ($billingOptionValid == false) {
			return 'Billing info is not valid. Please go to System Settings -> Products/Services, edit product, go to Module Settings and resave configuration.';
		}
		// Check if billing info is valid END
		$serviceId          = $params["serviceid"];

		//check if deployment exist---------------------------------------------

		$deploymentId       = Helpers::getHivelocityDeploymentCorrelation($serviceId);
		$assignedDeviceId   = Helpers::getAssignedDeviceId($serviceId);

		if($assignedDeviceId) {
			throw new \Exception("Device already exist.");
		}

		if ($deploymentId) return;
		//----------------------------------------------------------------------

		$deploymentName     = "S".$serviceId."T".time();
		$response           = Api::createDeployment($deploymentName);
		$deploymentId       = $response["deploymentId"];

		// First, save correlation between serviceId and deploymentId
		Helpers::saveHivelocityDeploymentCorrelation($serviceId, $deploymentId);

		try {
			$remoteProductId    = $params["configoption1"];

			if(isset($params["configoptions"]["Location"])) {
				$locationId     = $params["configoptions"]["Location"];
			} else {
				$locationId     = $params["configoption4"];
			}

			if(isset($params["configoptions"]["Operating System"])) {
				$osId           = $params["configoptions"]["Operating System"];
			} else {
				$osId           = $params["configoption5"];
			}

			$expectedOptions = array(
				"Control Panel",
				"Managed Services",
				"LiteSpeed",
				"WHMCS",
				"Bandwidth",
				"Load Balancing",
				"DDOS",
				"Daily Backup & Rapid Restore",
				"Cloud Storage",
				"Data Migration"
			);

			$options = array();

			if(isset($params["configoptions"]["Operating System"])) {               //config options exist, use config options

				foreach($expectedOptions as $optionName) {

					if(isset($params["configoptions"][$optionName]) && !empty($params["configoptions"][$optionName])) {

						$options[]  = $params["configoptions"][$optionName];
					}
				}

			} else {                                                                //use admin area options
				for($i=6; $i<20; $i++) {

					if(isset($params["configoption".$i]) && !empty($params["configoption".$i])) {
						$options[]  = $params["configoption".$i];
					}
				}
			}
			$hostName           = $params["domain"];

			$serviceModel       = $params["model"];
			$serviceAttributes  = $serviceModel->getAttributes();
			$billingPeriod      = strtolower($serviceAttributes["billingcycle"]);

			$response           = Api::configureDeployment($deploymentId, $remoteProductId, $locationId, $osId, $options, $hostName, $billingPeriod);

			// Final check and execute deployment
			$savedDeploymentId = Helpers::getHivelocityDeploymentCorrelation($serviceId);

			if($savedDeploymentId == $deploymentId) {
				$response           = Api::executeDeployment($deploymentId, $billingInfoId);

				$deploymentDetails  = Api::getDeploymentDetails($deploymentId);
				$hivelocityOrderId  = $deploymentDetails["orderNumber"];

				Helpers::saveHivelocityOrderCorrelation($serviceId, $hivelocityOrderId);

				return 'success';
			}
		} catch(\Exception $e) {
			if($deploymentId) {
				Helpers::deleteHivelocityDeploymentCorrelationByDeploymentId($deploymentId);
			}

			throw $e;
		}
	}

	static public function terminate($params) {
		$apiUrl             = $params["serverhostname"];
		$apiKey             = $params["serveraccesshash"];

		Api::setApiDetails($apiUrl, $apiKey);

		$serviceId          = $params["serviceid"];
		$assignedDeviceId   = Helpers::getAssignedDeviceId($serviceId);

		if($assignedDeviceId === false) {
			throw new \Exception("Device is not assigned");
		}

		$deviceDetails      = Api::getDeviceDetails($assignedDeviceId);
		$remoteServiceId    = $deviceDetails["servicePlan"];

		//$correlatedServiceId    = Helpers::getHivelocityServiceCorrelation($serviceId);

		$response           = Api::cancelDevice($assignedDeviceId, $remoteServiceId);
	}

	static public function clientArea($params) {
		if(isset($_POST["hivelocityAction"])) {
			return;
		}

		Helpers::maintenanceDatabase();

		$apiUrl             = $params["serverhostname"];
		$apiKey             = $params["serveraccesshash"];

		Api::setApiDetails($apiUrl, $apiKey);

		$serviceId          = $params["serviceid"];

		$assignedDeviceId   = Helpers::getAssignedDeviceId($serviceId);
		$hivelocityOrderId  = Helpers::getHivelocityOrderCorrelation($serviceId);

		if($assignedDeviceId !== false && $hivelocityOrderId !== false) {
			try {
				$orderDetails       = Api::getOrderDetails($hivelocityOrderId);
				$orderStatus        = $orderDetails["status"];
			} catch (\Exception $e) {
				$orderStatus        = "unknown";
			}

			if($orderStatus == "complete") {
				$remoteServiceList = Api::getServiceList($hivelocityOrderId);

				foreach($remoteServiceList as $remoteService) {
					if($remoteService["orderId"] == $hivelocityOrderId) {
						$remoteServiceId    = $remoteService["serviceId"];

						Helpers::saveHivelocityServiceCorrelation($serviceId, $remoteServiceId);

						$deviceId           = $remoteService["serviceDevices"][0]["id"];
						Helpers::assignDevice($serviceId, $deviceId);
						$deviceDetails      = Api::getDeviceDetails($deviceId);
						$initialCreds       = Api::getInitialPassword($deviceId);
						$orderStatus        = false;
						$ips                = Api::getIpAssigments($deviceId);

						break;
					}
				}
			}
		} else {
			$deviceDetails      = Api::getDeviceDetails($assignedDeviceId);
			$initialCreds    = Api::getInitialPassword($assignedDeviceId);
			$ips                = Api::getIpAssigments($assignedDeviceId);
		}

		//$domainList= Api::getDomainList();
		$domainList=array();
		//$ipmis= Api::getIpmiData($assignedDeviceId);

		//$domainListString = print_r($ipmis, true);
		$ipmisensors=array();
		//foreach ($ipmis['sensors'] as $key => $value) {
		//    if($value['status']==1)
		//    {
		//        $ipmisensors[$value['sensorId']]['name']=$value['name'];
		//        $ipmisensors[$value['sensorId']]['unit']=$value['reading'].$value['units'];
		//    }
		//}
		$dashboarddetails=array();
		$dashboarddetails["location"]=$deviceDetails["location"]["facility"];
		$dashboarddetails["monitorsUp"]=$deviceDetails["monitorsUp"];
		$service      = Api::getServiceDetails($deviceDetails["servicePlan"]);
		$servicedetails='';
		$hardwaredetails='';

		$_LANG = Helpers::lang('hivelocity');

		foreach ($service['serviceOptions'] as $key => $value) {
			if($value['name']=='Self Managed')
			{
				$servicedetails .= $_LANG['service_details'].'<br><h6>'.$value['name'].'</h6>';
			}

			if($value['upgradeName']=='Bandwidth')
			{
				$servicedetails .= $_LANG['bandwidth'].'<br><h6>'.$value['name'].'</h6>';
			}

			if($value['upgradeName']=='DDOS')
			{
				$servicedetails .= 'DDOS<br><h6>'.$value['name'].'</h6>';
			}

			if($value['upgradeName']=='Processor')
			{
				$hardwaredetails .= $_LANG['processor'].'<br><h6>'.$value['name'].'</h6>';
			}

			if($value['upgradeName']=='Memory')
			{
				$hardwaredetails .= $_LANG['ram'].'<br><h6>'.$value['name'].'</h6>';
			}

			if($value['upgradeName']=='Primary Hard Drive')
			{
				$hardwaredetails .= $_LANG['disk'].'<br><h6>'.$value['name'].'</h6>';
			}

			if($value['upgradeName']=='Operating System')
			{
				$hardwaredetails .= $_LANG['operating_system'].'<br><h6>'.$value['name'].'</h6>';
			}
		}
		/*foreach ($service['serviceDevices']['0'] as $key => $value) {
			$servicedetails .= 'IP Addresses<br><h6>'.$value.'</h6>';
		}*/
		$dashboarddetails["renewdate"]=date('M d, y',$service["renewDate"]);

		//$remoteProductOptions       = Api::getProductOptions('504');
		//$backup=Api::getBackup('504','143018');
		//print_r($backup); exit;

		$userIp = $_SERVER['REMOTE_ADDR'];

		// Show correct device power status when device is reloading
		$devicePowerStatus = $deviceDetails["isReload"] ? 'RELOADING' : $deviceDetails["powerStatus"];

		// Handle password expiration
		if (isset($initialCreds["passwordReturnsUntil"])) {
			$passwordReturnsUntil = DateTime::createFromFormat( 'U', $initialCreds["passwordReturnsUntil"] );
			$now = new DateTime();

			$diff = $passwordReturnsUntil->diff($now);

			$daysRemaining =  $diff->format('%d') + 1;

			$passwordExpiresInString = ($daysRemaining > 0)
									? ('in ' . $daysRemaining . ' day' . (($daysRemaining > 1) ? 's' : ''))
									: 'within 24 hours';
		} else {
			$passwordExpiresInString = '';
		}

		if(Helpers::isTwentyOne()) {
			$templateFile = 'templates/tpl/clientareatwentyone.tpl';
		} else {
		    $templateFile = 'templates/tpl/clientareasix.tpl';
		}

		return array(
			'templatefile' => $templateFile,
			'vars' => array(
				'_LANG' 			=> Helpers::lang('hivelocity'),
				'serviceId'         => $serviceId,
				'primaryIp'         => $deviceDetails["primaryIp"],
				'username'          => $initialCreds['user'],
				'initialPassword'   => $initialCreds["password"],
				'orderStatus'       => ucwords($orderStatus),
				'userIp'            => $userIp,
				'deviceStatus'      => $deviceDetails['status'],
				'devicePowerStatus' => $devicePowerStatus,
				'ips'               => $ips,
				'domainList'        => $domainList,
				'ipmisensors'        => $ipmisensors,
				'dashboarddetails'        => $dashboarddetails,
				'passwordExpiresInString' => $passwordExpiresInString,
				'servicedetails' => $servicedetails,
				'hardwaredetails' => $hardwaredetails
			),
		);
	}

	static public function boot($params) {
		$_LANG = Helpers::lang('hivelocity');

		$apiUrl             = $params["serverhostname"];
		$apiKey             = $params["serveraccesshash"];

		Api::setApiDetails($apiUrl, $apiKey);

		$serviceId          = $params["serviceid"];
		$assignedDeviceId   = Helpers::getAssignedDeviceId($serviceId);

		if($assignedDeviceId === false) {
			return $_LANG['no_provisioning'];
		}

		try {
			Api::bootDevice($assignedDeviceId);
		} catch (\Exception $e) {
			return $e;
		}

		return 'success';
	}

	static public function reboot($params) {
		$_LANG = Helpers::lang('hivelocity');

		$apiUrl             = $params["serverhostname"];
		$apiKey             = $params["serveraccesshash"];

		Api::setApiDetails($apiUrl, $apiKey);

		$serviceId          = $params["serviceid"];
		$assignedDeviceId   = Helpers::getAssignedDeviceId($serviceId);

		if($assignedDeviceId === false) {
			return $_LANG['no_provisioning'];
		}

		try {
			Api::rebootDevice($assignedDeviceId);
		} catch (\Exception $e) {
			return $e;
		}

		return 'success';
	}

	static public function shutdown($params) {
		$_LANG = Helpers::lang('hivelocity');

		$apiUrl             = $params["serverhostname"];
		$apiKey             = $params["serveraccesshash"];

		Api::setApiDetails($apiUrl, $apiKey);

		$serviceId          = $params["serviceid"];
		$assignedDeviceId   = Helpers::getAssignedDeviceId($serviceId);

		if($assignedDeviceId === false) {
			return $_LANG['no_provisioning'];
		}

		try {
			Api::shutdownDevice($assignedDeviceId);
		} catch (\Exception $e) {
			return $e;
		}

		return 'success';
	}

	static public function reload($params) {
		$_LANG = Helpers::lang('hivelocity');

		$apiUrl             = $params["serverhostname"];
		$apiKey             = $params["serveraccesshash"];

		Api::setApiDetails($apiUrl, $apiKey);

		$serviceId          = $params["serviceid"];
		$assignedDeviceId   = Helpers::getAssignedDeviceId($serviceId);

		if($assignedDeviceId === false) {
			return $_LANG['no_provisioning'];
		}

		if(isset($params["configoptions"]["Operating System"])) {
			$osName           = $params["configoptions"]["Operating System"];
		} else {
			$osName           = $params["configoption5"];
		}

		$productId          = Helpers::getProductIdByServiceId($serviceId);
		$remoteProductId    = Helpers::getRemoteProductIdByProductId($productId);

		$remoteProductOS    = Api::getProductOS($remoteProductId);
		$osId               = false;

		foreach($remoteProductOS as $os) {
			if($os["name"] == $osName) {
				$osId = $os["id"];
				break;
			}
		}

		try {
			Api::reloadDevice($assignedDeviceId, $osId);
		} catch (\Exception $e) {
			return $e;
		}

		return 'success';
	}
}
