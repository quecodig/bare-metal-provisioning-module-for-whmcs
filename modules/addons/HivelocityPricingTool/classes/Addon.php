<?php
namespace HivelocityPricingTool\classes;
use Illuminate\Database\Capsule\Manager as Capsule;

class Addon {
    static public function config() {
        
        $serverGropupList   = Helpers::getServerGroupList();
        $serverGroupOptions = array();
        
        foreach($serverGropupList as $serverGroupData) {
            
            $serverGroupId      = $serverGroupData["id"];
            $serverGroupName    = $serverGroupData["name"];
            
            $serverGroupOptions[$serverGroupId] = $serverGroupName;
        }
        
        $productGropupList      = Helpers::getProductGroupList();
        $productGropupOptions   = array();
        
        foreach($productGropupList as $productGroupData) {
            
            $productGroupId     = $productGroupData["id"];
            $productGroupName   = $productGroupData["name"];
            
            $productGropupOptions[$productGroupId] = $productGroupName;
        }
        
        $configArray = array(
            
            "name"          => "Hivelocity Pricing Tool",
            "description"   => "A simple interface allowing you to quickly change pricing for all the products using Hivelocity as the provisioning module.",
            "version"       => "1.1",
            "author"        => "<a target='_blank' rel='noopener noreferrer' href=''>Hivelocity</a>",
            "language"      => "english",
            "fields"        => array(
                "priceNotification" => array (
                    "FriendlyName"      => "Price Change Notification", 
                    "Type"              => "yesno", 
                    "Size"              => "25",
                    "Description"       => "Check if you want to receive an email notification about the price change of Hivelocity products."
                ),
                "debugMode" => array (
                    "FriendlyName"      => "Debug Mode",
                    "Type"              => "yesno",
                    "Size"              => "25",
                    "Description"       => "Check if you want to enable debug mode"
                ),
                "productGroup" => array (
                    "FriendlyName"      => "Product Group", 
                    "Type"              => "dropdown", 
                    "Options"           => $productGropupOptions,
                    "Size"              => "25",
                    "Description"       => "Product Group for auto created products."
                ),
                "serverGroup" => array (
                    "FriendlyName"      => "Server Group", 
                    "Type"              => "dropdown", 
                    "Options"           => $serverGroupOptions,
                    "Size"              => "25",
                    "Description"       => "Server Group for auto created products."
                ),
                "usdExchangeRate" => array (
                    "FriendlyName"      => "Tasa de Cambio USD (Manual)", 
                    "Type"              => "text", 
                    "Size"              => "25",
                    "Default"           => "1.00",
                    "Description"       => "Ingrese el valor de 1 USD en su moneda base (ej. 4000 para COP) si no tiene USD configurado. Si tiene USD configurado en el sistema, este valor será ignorado."
                ),
                "profitPercent" => array (
                    "FriendlyName"      => "Porcentaje de Ganancia Global (%)", 
                    "Type"              => "text", 
                    "Size"              => "10",
                    "Default"           => "0",
                    "Description"       => "Este porcentaje se aplicará automáticamente a todos los productos cuando se ejecute la sincronización automática (Cron). Para actualizaciones manuales, use la herramienta en la página del módulo."
                ),
            )
        );
        
        return $configArray;
    }
    
    static public function output($params) {

        $crondisable='';

        $output = shell_exec('crontab -l');
        if($output)
        {
            if(!str_contains($output, '/HivelocityPricingTool/cron.php') && !substr_count($output, "HivelocityPricingTool") > 1)
            {
                $crondisable='It seems cron is not setup yet.Please set the cron first.';
            }
        }

        $disabled='';
        $disabledmsg='';

        $q=mysql_query("SELECT value FROM mod_hivelocity_cron WHERE value='RunFiveMinCron'");
        if(mysql_num_rows($q))
        {
            $disabled='disabled';
            $disabledmsg='Product sync is in progress it may take 5-10 min.Please be patient.';
        }

        if($_GET['action']=='generateproducts')
        {
            mysql_query("DELETE FROM mod_hivelocity_cron WHERE value='RunFiveMinCron'");
            insert_query("mod_hivelocity_cron",array("value"=>'RunFiveMinCron',"created_at"=>date('Y-m-d h:i:s')));
            $disabled='disabled';
            $disabledmsg='Product sync is in progress it may take 5-10 min.Please be patient.';
        }
        
        if(isset($_POST["hivelocityPricingToolAction"]) && !empty($_POST["hivelocityPricingToolAction"])) {
            $action = $_POST["hivelocityPricingToolAction"];
        } else {
            $action="";
        }
        
        $success    = false;
        $error      = false;
        $productList            = Helpers::getProductList();
        $totalActiveProducts    = Helpers::countActiveProducts();
        $totalHiddenProducts    = Helpers::countHiddenProducts();
        try {
            if($action == "updatePricing") { 
            
                // Obtener tasa USD de manera robusta
                $usdRate = Helpers::getCurrencyRate("USD");
                if ($usdRate === false) {
                    $addonConfig = Helpers::getAdonConfig();
                    $manualRate = isset($addonConfig['usdExchangeRate']) ? floatval($addonConfig['usdExchangeRate']) : 0;
                    if ($manualRate > 0) {
                        $usdRate = 1 / $manualRate;
                    } else {
                        $usdRate = 1;
                    }
                }

                if($_POST["globalchange"]=='true'){

                    unset($_POST['DataTables_Table_0_length']);
                    $globalprofit=(float)$_POST["globalprofit"];
                    foreach($productList as $productData) {
                        $remoteProductPrice    = Helpers::getHivelocityProductPrice($productData["configoption1"]);
                        $remotePrice           = $remoteProductPrice['hivelocityProductPrice'];
                        $disabledBillingPeriods    = $remoteProductPrice['disabled_billing_periods'] ?? [];
                        
                        // Convertir precio remoto (USD) a moneda base usando la tasa
                        $basePrice = $remotePrice / $usdRate;
                        
                        $profit         = ($basePrice * $globalprofit) / 100;
                        $price          = $basePrice + $profit;
                        $currencyId = $_POST["currencyId"];
                        
                        Helpers::updateAllProductPricing($productData["id"], $price, $currencyId, $disabledBillingPeriods);
                    }

                }
                else
                {
                    foreach($_POST["productId"] as $index => $productId) {
                        $remoteProductPrice    = Helpers::getHivelocityProductPrice($productId);
                        $price      = $_POST["localPrice"][$index];
                        $currencyId = $_POST["currencyId"];
                        $disabledBillingPeriods = $remoteProductPrice["disabled_billing_periods"] ?? [];
                        
                        // NOTA: 'localPrice' enviado por POST ya debería ser el valor final editado por el usuario en la UI.
                        // Si el usuario lo ve en COP en la tabla (porque el display logic ya fue arreglado), 
                        // entonces 'localPrice' ya es COP. No necesitamos convertir 'localPrice'.
                        // Solo necesitamos asegurarnos de que se guarde tal cual.
                        
                        //Helpers::setProductPrice($productId, $price, $currencyId);
                        Helpers::updateAllProductPricing($productId, $price, $currencyId, $disabledBillingPeriods);
                    }
                }
                
                $success = true;
            }
        } catch(\Exception $e) {
            $error = $e->getMessage;
        }    
        
        $currencyList           = Helpers::getCurrencyList(); 
        
        $smartyVarsCurrencyList = array();
        
        foreach($currencyList as $currencyData) {
            $currencyId=$currencyData["id"];
            $smartyVarsCurrencyList[$currencyData["id"]] = array(
                "code"      => $currencyData["code"],
                "suffix"    => $currencyData["suffix"]
            );
        }
        
        
        
        $smartyVarsProductList = array();
            
        foreach($productList as $productData) {
            
            $productId          = $productData["id"];
            $serverConfig       = Helpers::getServerConfigByProductId($productId);
        
            $apiUrl             = $serverConfig["hostname"];
            $apiKey             = $serverConfig["accesshash"];
            
            Api::setApiDetails($apiUrl, $apiKey);
            
            $remoteProductId    = $productData["configoption1"];
            //$remoteProductPrice = 0;
            /*try {
                $remoteProductData  = Api::getProductDetails($remoteProductId);
            } catch ( \Exception $e) {
                continue;
            }
            
            $remoteProductPrice = 0;
            foreach($remoteProductData as $location => $data) {
                $remoteProductPrice = $data[0]["product_monthly_price"];
                break;
            } */
            $remoteProductPrice    = Helpers::getHivelocityProductPrice($remoteProductId);
            $remotePrice    = $remoteProductPrice['hivelocityProductPrice'];
            logActivity("HivelocityPricingTool2: Remote Product Price for Product ID $remoteProductId: " . $remotePrice);
            $disabledBillingPeriods = $remoteProductPrice["disabled_billing_periods"] ?? [];
            $convertedDisabledBillingPeriods = !empty($disabledBillingPeriods) ? implode(", ", $disabledBillingPeriods) : "No hay ciclos deshabilitados";
            
            $usdRate            = Helpers::getCurrencyRate("USD");
            
            if($usdRate === false) {
                 $addonConfig = Helpers::getAdonConfig();
                 $manualRate = isset($addonConfig['usdExchangeRate']) ? floatval($addonConfig['usdExchangeRate']) : 0;
                 if ($manualRate > 0) {
                     $usdRate = 1 / $manualRate;
                 } else {
                     $usdRate = 1;
                 }
            }
            
            $remotePrice = $remotePrice / $usdRate;
            
            $smartyVarsProductList[$productId] = array(
                "name" => $productData["name"],
                "hidden" => $productData["hidden"],
                "disabledPeriods" => $convertedDisabledBillingPeriods
            );

            foreach($currencyList as $currencyData) {
                
                $currencyId                     = $currencyData["id"];
                $productPrice                   = Helpers::getProductPrice($productId, $currencyId);
                
                $currencyRate                   = $currencyData["rate"];
                
                $remoteProductPriceConverted    = $remotePrice * $currencyRate;
                
                $profit                         = $productPrice - $remoteProductPriceConverted;
                if($remotePrice!=0)
                {
                    $profitPercentage           = ($profit / $remotePrice) * 100;
                }
                
                $smartyVarsProductList[$productId]["remotePrice"][$currencyId]  = number_format($remoteProductPriceConverted, 2);
                $smartyVarsProductList[$productId]["localPrice"][$currencyId]   = number_format($productPrice, 2);
                $smartyVarsProductList[$productId]["profit"][$currencyId]       = number_format($profitPercentage, 2);
            }
        }
        
        $smarty                 = new \Smarty();

        $smarty->assign('activeProducts',  $totalActiveProducts);
        $smarty->assign('hiddenProducts',  $totalHiddenProducts);
        $smarty->assign('productList',  $smartyVarsProductList);
        $smarty->assign('currencyList', $smartyVarsCurrencyList);
        $smarty->assign('success',      $success);
        $smarty->assign('error',        $error);
        $smarty->assign('disabled',        $disabled);
        $smarty->assign('disabledmsg',        $disabledmsg);
        $smarty->assign('crondisable',        $crondisable);
        
        $smarty->caching        = false;
        $smarty->compile_dir    = $GLOBALS['templates_compiledir'];
        
        $smarty->display(dirname(dirname(__FILE__)).'/templates/tpl/adminArea.tpl');
        
    }
}
