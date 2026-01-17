<?php
use WHMCS\Database\Capsule;
require_once '../../../../init.php';
require_once '../../../../includes/functions.php';
require_once '../../../../includes/adminfunctions.php';

header('Content-Type: application/json');

// IP permitida
$allowedIps = ['205.209.118.18'];
$clientIp = $_SERVER['REMOTE_ADDR'];

if (!in_array($clientIp, $allowedIps)) {
    http_response_code(403);
    echo json_encode(['error' => 'Access denied: IP not allowed']);
    exit;
}

// Admin user válido
$adminUser = 'quecodig';

// Método de la API
$method = $_REQUEST['action'] ?? null;
if (!$method) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing "method" parameter']);
    exit;
}

// Métodos permitidos
$allowedMethods = ['GetProducts', 'GetTLDPricing'];

if (!in_array($method, $allowedMethods)) {
    http_response_code(403);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

// Filtrar parámetros válidos por método
$methodParams = [];

switch ($method) {
    case 'GetProducts':
        foreach (['pid', 'gid', 'module'] as $param) {
            if (isset($_REQUEST[$param])) {
                $methodParams[$param] = $_REQUEST[$param];
            }
        }
        break;

    case 'GetTLDPricing':
        if (isset($_REQUEST['currencyid'])) {
            $methodParams['currencyid'] = (int) $_REQUEST['currencyid'];
        }
        break;
}

// Ejecutar llamada
$response = localAPI($method, $methodParams, $adminUser);

// Si es GetProducts, agregamos `hidden`
if ($method === 'GetProducts' && !empty($response['products']['product'])) {
    foreach ($response['products']['product'] as &$product) {
        $hidden = Capsule::table('tblproducts')
            ->where('id', $product['pid'])
            ->value('hidden');

        $product['hidden'] = (int) $hidden;
    }
}

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
exit;