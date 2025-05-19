<?php
/**
 * Module Name: Server Configuration Module
 * Description: Permite la configuración para ocultar la información de servidores específicos en el área de cliente.
 * Author: Edinson Tique
 * Company: Qué Código
 * License: GPL
 * Created: 29/07/2024
 * Last Modified: 29/07/2024
 */

if (!defined("WHMCS")) {
    die("This file cannot be accessed directly");
}

use Illuminate\Database\Capsule\Manager as Capsule;

/**
 * Configuración del módulo
 */
function server_info_config() {
    return [
        'name' => 'Server Display Configuration',
        'description' => 'Enable or disable server display for specific servers in the client area',
        'version' => '1.0',
        'author' => 'Qué Código',
        'fields' => []
    ];
}

/**
 * Función de activación del módulo
 */
function server_info_activate() {
    try {
        if (!Capsule::schema()->hasTable('mod_hidden_servers')) {
            Capsule::schema()->create('mod_hidden_servers', function ($table) {
                $table->increments('id');
                $table->integer('server_id')->unique();
                $table->boolean('hidden')->default(false);
            });
        }
		
		if (!Capsule::schema()->hasTable('mod_api_servers')) {
            Capsule::schema()->create('mod_api_servers', function ($table) {
                $table->increments('id');
                $table->integer('server_id')->unique();
                $table->boolean('use_api')->default(false);
            });
        }

        return [
            'status' => 'success',
            'description' => 'Table mod_hidden_servers is ready.',
        ];
    } catch (Exception $e) {
        return [
            'status' => 'error',
            'description' => 'Unable to create table mod_hidden_servers: ' . $e->getMessage(),
        ];
    }
}

/**
 * Función de desactivación del módulo
 */
function server_info_deactivate() {
    try {
        if (Capsule::schema()->hasTable('mod_hidden_servers')) {
            Capsule::schema()->dropIfExists('mod_hidden_servers');
        }
		
		if (Capsule::schema()->hasTable('mod_api_servers')) {
            Capsule::schema()->dropIfExists('mod_api_servers');
        }

        return [
            'status' => 'success',
            'description' => 'Table mod_hidden_servers dropped successfully',
        ];
    } catch (Exception $e) {
		curl_close($ch);
        return [
            'status' => 'error',
            'description' => 'Unable to drop table mod_hidden_servers: ' . $e->getMessage(),
        ];
    }
}

/**
 * Función de administración del módulo
 */
function server_info_output($vars) {
	if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['submit'])) {
		try{
			// Limpiar la tabla de servidores ocultos
			Capsule::table('mod_hidden_servers')->delete();

			// Actualizar la tabla con los servidores ocultos seleccionados
			$hiddenServers = isset($_POST['hidden_servers']) ? $_POST['hidden_servers'] : [];
			foreach ($hiddenServers as $serverId) {
				Capsule::table('mod_hidden_servers')->updateOrInsert(
					['server_id' => $serverId],
					['hidden' => true]
				);
			}
			
			// Manejo de actualización de contraseñas
            Capsule::table('mod_api_servers')->delete();
            $apiServers = isset($_POST['api_servers']) ? $_POST['api_servers'] : [];
            foreach ($apiServers as $serverId) {
                Capsule::table('mod_api_servers')->updateOrInsert(
                    ['server_id' => $serverId],
                    ['use_api' => true]
                );
            }
			
			// Actualizar contraseñas usando la API
            $servers = Capsule::table('tblservers')->get();
            foreach ($servers as $server) {
                $useApiPassword = Capsule::table('mod_api_servers')
                    ->where('server_id', $server->id)
                    ->value('use_api');
            }

			//echo '<p>Settings saved!</p>';

			// Recargar los datos después de guardar
			//$hiddenServers = Capsule::table('mod_hidden_servers')
			//	->pluck('server_id')
            //	->toArray();
			
			// Redirigir con una notificación de éxito
            header('Location: addonmodules.php?module=server_info&success=true');
			exit;
        } catch (Exception $e) {
            // Redirigir con una notificación de error
            header('Location: addonmodules.php?module=server_info&error=true: ' . urlencode($e->getMessage()));
			exit;
        }
    }
    $servers = Capsule::table('tblservers')->get();
    
    // Obtener los servidores ocultos
    $hiddenServers = Capsule::table('mod_hidden_servers')
        ->pluck('server_id')
        ->toArray();
	
	// Obtener los servidores que usan la API
    $apiServers = Capsule::table('mod_api_servers')
        ->pluck('server_id')
        ->toArray();

    echo '<form method="post" action="">';
    echo '<h3>Configure Hidden Servers</h3>';
    echo '<table>';
    echo '<tr><th>Server Name</th><th>Hide</th><th>Use API Password</th></tr>';

    foreach ($servers as $server) {
        $isChecked = in_array($server->id, $hiddenServers) ? 'checked' : '';
        $apiPasswordChecked = in_array($server->id, $apiServers) ? 'checked' : '';

        echo '<tr>';
        echo '<td>' . htmlspecialchars($server->name) . '</td>';
        echo '<td><input type="checkbox" name="hidden_servers[]" value="' . $server->id . '" ' . $isChecked . '></td>';
        echo '<td><input type="checkbox" name="api_servers[]" value="' . $server->id . '" ' . $apiPasswordChecked . '></td>';
        echo '</tr>';
    }
    
    echo '</table>';
    echo '<input type="submit" name="submit" value="Save">';
    echo '</form>';
    
}