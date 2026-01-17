<?php
namespace HivelocityPricingTool\classes;
use Illuminate\Database\Capsule\Manager as Capsule;

class Cron {
    static public function priceChangeNotify() {
        
        $productList           = Helpers::getProductList();

        $addonConfig        = Helpers::getAdonConfig();
        $serverGroupId      = $addonConfig["serverGroup"];
        $productGroupId     = $addonConfig["productGroup"];
        $debugMode          = $addonConfig["debugMode"];

        $serverConfig       = Helpers::getServerConfigByServerGroupId($serverGroupId);
        
        $apiUrl             = $serverConfig["hostname"];
        $apiKey             = $serverConfig["accesshash"];
        
        Api::setApiDetails($apiUrl, $apiKey);

        $remoteProductListRaw  = Api::getProductList();
        $remoteProductList     = array();

        foreach($remoteProductListRaw as $location => $list) {

            foreach($list as $remoteProductData) {
                $remoteProductId    = $remoteProductData["product_id"];
                if(isset($remoteProductList[$remoteProductId])) {
                    if($remoteProductData["stock"] != "unavailable") {
                        $remoteProductList[$remoteProductId] = $remoteProductData;
                    }
                } else {
                    $remoteProductList[$remoteProductId] = $remoteProductData;
                }
            }
        }
        logActivity("Hivelocity Pricing Tool - Price Change Notify Cron job started to check for price changes in Hivelocity products.");
        logActivity("Hivelocity Pricing Tool - Price Change Notify Remote product list fetched successfully. Total products: ".count($remoteProductList));

        
        if ($debugMode === "on") {
            logModuleCall('Hivelocity','priceChangeNotify','remoteProductList',$remoteProductList);
        }

        foreach($productList as $productData) {
            set_time_limit(60);
            $productId                  = $productData["id"];
            $remoteProductPrice         = 0;
            
            if (array_key_exists($remoteProductId, $remoteProductList)) {
                $remoteProductId     = $productData["configoption1"];
                $remoteProductPrice  = $remoteProductList[$remoteProductId]["product_monthly_price"];
                logActivity("Hivelocity Pricing Tool - Price Change Notify Cron job started to check for price changes in product ID: ".$productId." with remote product ID: ".$remoteProductId." and price: ".$remoteProductPrice);
                // Normaliza los ciclos deshabilitados antes de guardar
                $disabledPeriodsRaw  = $remoteProductList[$remoteProductId]['product_disabled_billing_periods'];
                logActivity("Hivelocity Pricing Tool - Price Change Notify Cron job disabled billing periods: ".print_r($disabledPeriodsRaw, true));
                $disabledPeriods     = Helpers::normalizeBillingPeriods($disabledPeriodsRaw);
            } else {
                continue;
            }

            $savedRemoteProductPrice    = Helpers::getHivelocityProductPrice($remoteProductId);
            if($savedRemoteProductPrice['hivelocityProductPrice'] === false) {
                Helpers::saveHivelocityProductPrice($remoteProductId, $remoteProductPrice, $disabledPeriods);
            } elseif($savedRemoteProductPrice['hivelocityProductPrice'] != $remoteProductPrice && $remoteProductPrice != 0) {
                Helpers::saveHivelocityProductPrice($remoteProductId, $remoteProductPrice, $disabledPeriods);
                if (Helpers::isNotificationEnabled()) {
                    $command = 'SendAdminEmail';

                    $postData = array(
                        'messagename' => 'Hivelocity Product Price Change',
                        'mergefields' => array('hivelocityProductId' => $remoteProductId, 'oldPrice' => number_format($savedRemoteProductPrice['hivelocityProductPrice'], 2)." USD", 'newPrice' => number_format($remoteProductPrice, 2)." USD"),
                    );
                    
                    logActivity("Intentando enviar correo de cambio de precio para el producto: ".$remoteProductId);
                    $results = localAPI($command, $postData);
                    logActivity("Resultado del envío de correo: ".print_r($results, true));
                }
            }
        }
    }
    
    static public function synchronizeProducts() {
        
        $addonConfig        = Helpers::getAdonConfig();
        $serverGroupId      = $addonConfig["serverGroup"];
        $productGroupId     = $addonConfig["productGroup"];
        $debugMode          = $addonConfig["debugMode"];
        
        Helpers::updateProductGroupConfig($productGroupId);
        Helpers::updateServerGroupConfig($serverGroupId);

        $serverConfig       = Helpers::getServerConfigByServerGroupId($serverGroupId);
        
        $apiUrl             = $serverConfig["hostname"];
        $apiKey             = $serverConfig["accesshash"];
        
        Api::setApiDetails($apiUrl, $apiKey);
        
        $remoteProductListRaw  = Api::getProductList();
        $remoteProductList     = array();

        foreach($remoteProductListRaw as $location => $list) {
            foreach($list as $remoteProductData) {
                $remoteProductId    = $remoteProductData["product_id"];
                if(isset($remoteProductList[$remoteProductId])) {
                    if($remoteProductData["stock"] != "unavailable") {
                        $remoteProductList[$remoteProductId] = $remoteProductData;
                    }
                } else {
                    $remoteProductList[$remoteProductId] = $remoteProductData;
                }
            }
        }

        if ($debugMode === "on") {
            logModuleCall('Hivelocity','synchronizeProducts','remoteProductList',$remoteProductList);
        }
        
        $currencyList       = Helpers::getCurrencyList();
        foreach($currencyList as $currency) {
            $currencyId     = $currency["id"];
        }
        
        $processedProducts  = array(); 
        
        $billingInfoList    = Api::getBillingInfoList();
        $billingId          = $billingInfoList[0]["id"];

        if ($debugMode === "on") {
            logModuleCall('Hivelocity','synchronizeProducts','billingId',$billingId);
        }

        foreach ($remoteProductList as $remoteProductId => $remoteProductData) {
            set_time_limit(120);
            $localProductId     = Helpers::getProductIdByRemoteProductId($remoteProductId);

            $profitPercent = isset($addonConfig['profitPercent']) ? floatval($addonConfig['profitPercent']) : 0;
            $disabledPeriods = Helpers::normalizeBillingPeriods($remoteProductData["product_disabled_billing_periods"]);
            $price = floatval($remoteProductData["product_monthly_price"]);
            $pricing = Helpers::getPricingArray($price, $disabledPeriods, $profitPercent);

            if ($localProductId == false && $remoteProductData["stock"] != "unavailable") {
                // Crear producto
                $desc = '';
                if ($remoteProductData["product_bandwidth"]) {
                    $desc .= "Bandwidth : " . $remoteProductData["product_bandwidth"];
                }
                if ($remoteProductData["product_cpu"]) {
                    $desc .= "<br>CPU : " . $remoteProductData["product_cpu"] . " " . $remoteProductData['product_cpu_cores'];
                }
                if ($remoteProductData["product_memory"]) {
                    $desc .= "<br>Memory : " . $remoteProductData["product_memory"];
                }
                if ($remoteProductData["product_drive"]) {
                    $desc .= "<br>Drive : " . $remoteProductData["product_drive"];
                }

                $result = WhmcsApi::AddProduct([
                    "name"          => $remoteProductData["product_id"] . " - " . $remoteProductData["product_cpu"] . " - " . $remoteProductData["product_cpu_cores"] . " - " . $remoteProductData["product_memory"] . " - " . $remoteProductData["product_drive"],
                    "gid"           => $productGroupId,
                    "type"          => "server",
                    "paytype"       => "recurring",
                    "autosetup"     => "payment",
                    "pricing"       => $pricing,
                    "servergroupid" => $serverGroupId,
                    "module"        => "Hivelocity",
                    "configoption1" => $remoteProductId,
                    "configoption2" => $billingId,
                    "description"   => $desc,
                ]);

                $localProductId = $result["pid"];
                logModuleCall('Hivelocity', 'synchronizeProducts', 'localProductId', $localProductId);
                Helpers::addProductCustomField($localProductId);
                Helpers::createConfigOptions($localProductId, $remoteProductId);
                Helpers::saveHivelocityProductPrice($remoteProductId, $price, $disabledPeriods);
                $processedProducts[] = $localProductId;
            } elseif ($localProductId != false && $remoteProductData["stock"] != "unavailable") {
                // Actualizar producto
                logModuleCall('Hivelocity', 'synchronizeProducts', 'localProductId', $localProductId);
                Helpers::createConfigOptions($localProductId, $remoteProductId);
                $processedProducts[] = $localProductId;
            }
        }

        if ($debugMode === "on") {
            logModuleCall('Hivelocity','synchronizeProducts','processedProducts',$processedProducts);
        }
        

        $localProductList = Helpers::getProductList();
        foreach ($localProductList as $localProductData) {
            $localProductId = $localProductData["id"];
            $remoteProductId = $localProductData["configoption1"];

            if (isset($remoteProductList[$remoteProductId])) {
                $remoteProductData = $remoteProductList[$remoteProductId];
                $remoteProductPrice = floatval($remoteProductData["product_monthly_price"]);
                $disabledPeriods = Helpers::normalizeBillingPeriods($remoteProductData["product_disabled_billing_periods"]);
                $profitPercent = isset($addonConfig['profitPercent']) ? floatval($addonConfig['profitPercent']) : 0;
                
                // Pasar el objeto completo de datos del producto para obtener precios específicos
                $pricing = Helpers::getPricingArray($remoteProductData, $disabledPeriods, $profitPercent);

                // Verificar si tenemos al menos un precio válido en cualquier ciclo/moneda
                $hasValidPrice = false;
                foreach ($pricing as $currencyId => $cycles) {
                    foreach ($cycles as $cycle => $price) {
                        if ($price > 0) {
                            $hasValidPrice = true;
                            break 2;
                        }
                    }
                }

                if ($hasValidPrice) {
                    Helpers::saveHivelocityProductPrice($remoteProductId, $remoteProductPrice, $disabledPeriods);

                    foreach ($pricing as $currencyId => $cycles) {
                        // Pasamos el array de precios calculados ($cycles) directamente
                        Helpers::updateAllProductPricing($localProductId, $cycles, $currencyId, $disabledPeriods);
                    }
                } else {
                    Helpers::hideProduct($localProductId);
                    logActivity("Producto $localProductId ocultado porque no tiene precios válidos en ningún ciclo.");
                }
            } else {
                Helpers::hideProduct($localProductId);
                logActivity("Producto $localProductId ocultado porque no existe en la API.");
            }
        }
    }
}
