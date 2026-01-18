<style>
	.snapshot-container {
		max-width: 1200px;
		margin: 0 auto;
		background-color: #ffffff;
		padding: 30px;
		border-radius: 8px;
		box-shadow: 0 2px 10px rgba(0,0,0,0.1);
	}
	.snapshot-container h2,
	.snapshot-container h3 {
		color: #2c3e50;
		border-bottom: 2px solid #ecf0f1;
		padding-bottom: 10px;
		margin-bottom: 20px;
	}
	.schedule-table {
		width: 100%;
		border-collapse: separate;
		border-spacing: 0;
		margin-bottom: 25px;
	}
	.schedule-table th, .schedule-table td {
		padding: 12px 15px;
		text-align: left;
		border-bottom: 1px solid #e0e0e0;
	}
	.schedule-table th {
		background-color: #f8f9fa;
		font-weight: 600;
		color: #2c3e50;
		text-transform: uppercase;
		font-size: 12px;
		letter-spacing: 0.5px;
	}
	.snapshot-container .btn {
		display: inline-block;
		padding: 8px 12px;
		margin-right: 5px;
		font-size: 14px;
		font-weight: 500;
		line-height: 1.5;
		text-align: center;
		white-space: nowrap;
		vertical-align: middle;
		cursor: pointer;
		border: 1px solid transparent;
		border-radius: 4px;
		transition: all 0.2s ease-in-out;
		text-decoration: none;
	}
	.snapshot-container .btn-primary { background-color: #3498db; color: #fff; }
	.snapshot-container .btn-danger { background-color: #e74c3c; color: #fff; }
	.snapshot-container .btn-success { background-color: #2ecc71; color: #fff; }
	/* Modal Styles */
	.custom-modal {
		display: none;
		position: fixed;
		z-index: 1000;
		left: 0;
		top: 0;
		width: 100%;
		height: 100%;
		overflow: auto;
		background-color: rgba(0,0,0,0.5);
		backdrop-filter: blur(5px);
		animation: fadeIn 0.3s;
	}
	.custom-modal .modal-content {
		background-color: #ffffff;
		margin: 5% auto;
		padding: 0;
		border: 1px solid #e0e0e0;
		width: 90%;
		max-width: 500px;
		border-radius: 12px;
		box-shadow: 0 15px 35px rgba(0,0,0,0.2);
		animation: slideIn 0.3s;
		position: relative;
	}
	.custom-modal .modal-header {
		padding: 20px 25px;
		border-bottom: 1px solid #ecf0f1;
		display: flex;
		justify-content: space-between;
		align-items: center;
		background-color: #f8f9fa;
		border-radius: 12px 12px 0 0;
	}
	.custom-modal .modal-header h3 {
		margin: 0;
		font-size: 18px;
		color: #2c3e50;
		border-bottom: none;
		padding-bottom: 0;
	}
	.custom-modal .modal-body {
		padding: 25px;
	}
	.custom-modal .close {
		color: #95a5a6;
		font-size: 24px;
		font-weight: bold;
		cursor: pointer;
		transition: color 0.2s;
		line-height: 1;
	}
	.custom-modal .close:hover {
		color: #e74c3c;
	}
	.custom-modal .form-group {
		margin-bottom: 20px;
	}
	.custom-modal label {
		display: block;
		margin-bottom: 8px;
		font-weight: 600;
		color: #34495e;
		font-size: 14px;
	}
	.custom-modal .form-control {
		width: 100%;
		padding: 10px 12px;
		font-size: 14px;
		border: 1px solid #dfe6e9;
		border-radius: 6px;
		transition: border-color 0.2s;
		box-sizing: border-box;
	}
	.custom-modal .form-control:focus {
		border-color: #3498db;
		outline: none;
	}
	.custom-modal .schedule-info {
		background-color: #f0f8ff;
		border: 1px solid #bcdff1;
		border-radius: 6px;
		padding: 12px;
		margin-top: 20px;
		font-size: 13px;
		color: #2c3e50;
	}
	.custom-modal button[type="submit"] {
		width: 100%;
		padding: 12px;
		font-size: 16px;
		margin-top: 10px;
	}
	@keyframes fadeIn {
		from { opacity: 0; }
		to { opacity: 1; }
	}
	@keyframes slideIn {
		from { transform: translateY(-30px); opacity: 0; }
		to { transform: translateY(0); opacity: 1; }
	}
	/* Estilos para el Loader */
	.loader-container {
		display: none;
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: rgba(255, 255, 255, 0.8);
		z-index: 10;
		justify-content: center;
		align-items: center;
		flex-direction: column;
		border-radius: 8px;
	}
	.spinner {
		border: 4px solid #f3f3f3;
		border-top: 4px solid #28a745;
		border-radius: 50%;
		width: 40px;
		height: 40px;
		animation: spin 1s linear infinite;
		margin-bottom: 10px;
	}
	@keyframes spin {
		0% { transform: rotate(0deg); }
		100% { transform: rotate(360deg); }
	}
	.loading-text {
		color: #333;
		font-weight: 600;
	}

	/* Toast Notifications */
	#toast-container {
		position: fixed;
		bottom: 20px;
		right: 20px;
		z-index: 9999;
	}
	.toast-msg {
		min-width: 250px;
		padding: 15px 20px;
		margin-top: 10px;
		border-radius: 4px;
		color: #fff;
		font-weight: 500;
		box-shadow: 0 4px 12px rgba(0,0,0,0.15);
		display: flex;
		align-items: center;
		animation: slideInRight 0.3s ease-out;
	}
	.toast-success { background-color: #28a745; }
	.toast-error { background-color: #dc3545; }
	.toast-info { background-color: #17a2b8; }

	@keyframes slideInRight {
		from { transform: translateX(100%); opacity: 0; }
		to { transform: translateX(0); opacity: 1; }
	}
	/* Confirm Modal Styles */
	.confirm-modal-footer {
		padding: 15px 25px;
		border-top: 1px solid #ecf0f1;
		display: flex;
		justify-content: flex-end;
		gap: 10px;
		background-color: #f8f9fa;
		border-radius: 0 0 12px 12px;
	}
	.confirm-modal-footer .btn {
		margin-right: 0;
		min-width: 100px;
	}
</style>

<div id="toast-container"></div>
<div class="snapshot-container">

	<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
		<h3 style="margin: 0;">Snapshots Programados</h3>
		<button id="createScheduleBtn" class="btn btn-success" onclick="openScheduleCreateModal()">Programar Snapshot</button>
	</div>

	<div id="schedules-list-container">
	{if $schedules}
	<table class="schedule-table">
		<thead>
			<tr>
				<th>ID</th>
				<th>Frecuencia</th>
				<th>Día/Hora</th>
				<th>Disco ID</th>
				<th>Acciones</th>
			</tr>
		</thead>
		<tbody>
			{foreach from=$schedules item=schedule}
			<tr>
				<td>{$schedule.snapshotScheduleId}</td>
				<td>{$schedule.frequency|default:$schedule.intervalType}</td>
				<td>
					{if $schedule.weekday}Día {$schedule.weekday} @ {elseif $schedule.day}Día {$schedule.day} @ {/if}
					{$schedule.hour|string_format:"%02d"}:00 UTC
				</td>
				<td>{$schedule.volumeId}</td>
				<td>
					<a href="#" class="btn btn-danger" onclick="showConfirmModal('ID: {$schedule.snapshotScheduleId}', '¿Eliminar esta programación de snapshot?', 'delete_schedule', '{$schedule.snapshotScheduleId}'); return false;">Eliminar</a>
				</td>
			</tr>
			{/foreach}
		</tbody>
	</table>
	{else}
		<p>No hay schedules disponibles.</p>
	{/if}
	</div>
</div>

<!-- Modal Schedule -->
<div id="scheduleSnapshotModal" class="custom-modal">
	<div class="modal-content">
		<div class="modal-header">
			<h3 id="scheduleModalTitle">Programar Nuevo Snapshot</h3>
			<span class="close" data-modal="scheduleSnapshotModal">&times;</span>
		</div>
		<div class="modal-body">
			<div id="scheduleLoader" class="loader-container">
				<div class="spinner"></div>
				<div class="loading-text">Guardando Programación...</div>
			</div>
			<form id="scheduleSnapshotForm">
				{if $token}<input type="hidden" name="token" value="{$token}" />{/if}
				<input type="hidden" name="serviceid" value="{$serviceId}">
				<input type="hidden" name="schedule_id" id="schedule_id" value="">
				<input type="hidden" name="action_type" id="schedule_action_type" value="create_schedule">
				<input type="hidden" name="facility_code" value="{$facilityCode}">
				<input type="hidden" name="client_id" value="{$clientId}">
				
				<div class="form-group">
					<label for="disk">Disco ID:</label>
					<input type="text" id="disk" name="disk" class="form-control" value="{$volumeId}" readonly>
					<small class="text-muted">ID del volumen principal detectado</small>
				</div>

			<div class="form-group">
				<label for="schedule">Frecuencia:</label>
				<select id="schedule" name="schedule" class="form-control" required>
					<option value="daily">Diaria</option>
					<option value="weekly">Semanal</option>
					<option value="monthly">Mensual</option>
				</select>
			</div>

			<div class="form-group">
				<label for="time">Hora (UTC):</label>
				<input type="time" id="time" name="time" value="00:00" class="form-control" required>
			</div>

			<div class="form-group" id="weekDayGroup" style="display:none;">
				<label for="weekDay">Día de la semana:</label>
				<select id="weekDay" name="weekDay" class="form-control">
					<option value="1">Lunes</option>
					<option value="2">Martes</option>
					<option value="3">Miércoles</option>
					<option value="4">Jueves</option>
					<option value="5">Viernes</option>
					<option value="6">Sábado</option>
					<option value="0">Domingo</option>
				</select>
			</div>

			<div class="schedule-info">
				<p>Snapshot será programado para (UTC): <span id="utcTime">--</span></p>
			</div>

			<button type="submit" class="btn btn-success" id="scheduleSubmitBtn">Guardar Programación</button>
			</form>
		</div>
	</div>
</div>

<!-- Modal Confirmation -->
<div id="confirmModal" class="custom-modal">
	<div class="modal-content">
		<div class="modal-header">
			<h3 id="confirmTitle">Confirmar Acción</h3>
			<span class="close" data-modal="confirmModal">&times;</span>
		</div>
		<div class="modal-body">
			<div id="confirmLoader" class="loader-container">
				<div class="spinner"></div>
				<div class="loading-text">Procesando acción...</div>
			</div>
			<p id="confirmMessage" style="font-size: 15px; color: #444; line-height: 1.5;"></p>
		</div>
		<div class="confirm-modal-footer">
			<button type="button" class="btn" style="background-color: #95a5a6; color: #fff;" onclick="closeConfirmModal()">Cancelar</button>
			<button id="confirmBtn" class="btn btn-danger" onclick="executeConfirmAction()">Confirmar</button>
		</div>
	</div>
</div>

<script>
	var scheduleModal = document.getElementById("scheduleSnapshotModal");
	
	function openScheduleCreateModal() {
		document.getElementById('scheduleModalTitle').innerText = "Programar Nuevo Snapshot";
		document.getElementById('scheduleSubmitBtn').innerText = "Guardar Programación";
		document.getElementById('schedule_action_type').value = "create_schedule";
		document.getElementById('schedule_id').value = "";
		document.getElementById('schedule').value = "daily";
		document.getElementById('time').value = "00:00";
		
		document.getElementById('weekDayGroup').style.display = 'none';
		updateTimes();
		scheduleModal.style.display = "block";
	}

	document.querySelectorAll('.close').forEach(function(span) {
		span.onclick = function() {
			var modalId = this.getAttribute('data-modal');
			document.getElementById(modalId).style.display = "none";
		}
	});

	var currentConfirmAction = null;
	var currentConfirmId = null;

	function closeConfirmModal() {
		document.getElementById('confirmModal').style.display = "none";
	}

	function closeAllModals() {
		if (scheduleModal) scheduleModal.style.display = "none";
		closeConfirmModal();
		var container = document.getElementById('toast-container');
		if (container) container.innerHTML = '';
	}

	function showConfirmModal(title, message, action, id) {
		document.getElementById('confirmTitle').innerText = 'Confirmar: ' + title;
		document.getElementById('confirmMessage').innerText = message;
		currentConfirmAction = action;
		currentConfirmId = id;
		var confirmBtn = document.getElementById('confirmBtn');
		confirmBtn.className = 'btn btn-danger';
		document.getElementById('confirmModal').style.display = "block";
	}

	function executeConfirmAction() {
		if (!currentConfirmAction || !currentConfirmId) return;
		var loader = document.getElementById('confirmLoader');
		loader.style.display = 'flex';
		var formData = new FormData();
		formData.append('ajax_action', currentConfirmAction);
		formData.append('facility_code', '{$facilityCode}');
		formData.append('client_id', '{$clientId}');
		formData.append('schedule_id', currentConfirmId);
		var cleanUrl = window.location.href.split('&ajax_action=')[0].split('?ajax_action=')[0];
		var token = document.querySelector('input[name="token"]');
		if (token) formData.append('token', token.value);

		fetch(cleanUrl, {
			method: 'POST',
			body: formData
		})
		.then(response => response.json())
		.then(data => {
			loader.style.display = 'none';
			if (data.success) {
				closeAllModals();
				if (data.updated_data) updateDynamicLists(data.updated_data);
				showNotification('success', '¡Éxito!', 'La operación se completó correctamente.');
			} else {
				showNotification('error', 'Error', getErrorMessage(data));
			}
		})
		.catch(error => {
			loader.style.display = 'none';
			showNotification('error', 'Error de Conexión', 'No se pudo comunicar con el servidor.');
		});
	}

	window.onclick = function(event) {
		if (event.target == scheduleModal) scheduleModal.style.display = "none";
		if (event.target == document.getElementById('confirmModal')) closeConfirmModal();
	}

	document.getElementById('schedule').addEventListener('change', function() {
		var val = this.value;
		document.getElementById('weekDayGroup').style.display = (val === 'weekly') ? 'block' : 'none';
	});

	function submitForm(formId) {
		var form = document.getElementById(formId);
		var formData = new FormData(form);
		var actionType = form.querySelector('input[name="action_type"]').value;
		document.getElementById('scheduleLoader').style.display = 'flex';
		var cleanUrl = window.location.href.split('&ajax_action=')[0].split('?ajax_action=')[0];
		formData.append('ajax_action', actionType);
		
		fetch(cleanUrl, {
			method: 'POST',
			body: formData
		})
		.then(response => response.json())
		.then(data => {
			document.getElementById('scheduleLoader').style.display = 'none';
			if (data.success) {
				closeAllModals();
				if (data.updated_data) updateDynamicLists(data.updated_data);
				showNotification('success', '¡Éxito!', 'La operación se completó correctamente.');
			} else {
				showNotification('error', 'Error', getErrorMessage(data));
			}
		})
		.catch(error => {
			document.getElementById('scheduleLoader').style.display = 'none';
			showNotification('error', 'Error de Conexión', 'No se pudo comunicar con el servidor.');
		});
	}

	function updateDynamicLists(data) {
		var schedulesContainer = document.getElementById('schedules-list-container');
		if (data.schedules && data.schedules.length > 0) {
			var html = '<table class="schedule-table"><thead><tr><th>ID</th><th>Frecuencia</th><th>Día/Hora</th><th>Disco ID</th><th>Acciones</th></tr></thead><tbody>';
			data.schedules.forEach(function(schedule) {
				var dateTime = (schedule.weekday ? 'Día ' + schedule.weekday + ' @ ' : (schedule.day ? 'Día ' + schedule.day + ' @ ' : '')) + 
							   (schedule.hour < 10 ? '0' + schedule.hour : schedule.hour) + ':00 UTC';
				html += '<tr>' +
					'<td>' + schedule.snapshotScheduleId + '</td>' +
					'<td>' + (schedule.frequency || schedule.intervalType) + '</td>' +
					'<td>' + dateTime + '</td>' +
					'<td>' + schedule.volumeId + '</td>' +
					'<td>' +
						'<a href="#" class="btn btn-danger" onclick="showConfirmModal(\'ID: ' + schedule.snapshotScheduleId + '\', \'¿Eliminar esta programación de snapshot?\', \'delete_schedule\', \'' + schedule.snapshotScheduleId + '\'); return false;">Eliminar</a>' +
					'</td>' +
				'</tr>';
			});
			html += '</tbody></table>';
			schedulesContainer.innerHTML = html;
		} else {
			schedulesContainer.innerHTML = '<p>No hay schedules disponibles.</p>';
		}
	}

	function getErrorMessage(data) {
		var errorMsg = 'Ocurrió un error inesperado.';
		const translations = {
			'Maximum number of volume snapshots reached: 1': 'Se ha alcanzado el número máximo de snapshots permitidos (1).',
			'Snapshot name already exists': 'Ya existe un snapshot con este nombre.',
			'Volume not found': 'Volumen no encontrado.',
			'Device not found': 'Dispositivo no encontrado.'
		};
		if (data && data.response) {
			let rawError = '';
			if (data.response.errors && Array.isArray(data.response.errors)) {
				rawError = data.response.errors.join('. ');
			} else if (data.response.message) {
				rawError = data.response.message;
			} else if (typeof data.response === 'string') {
				rawError = data.response;
			}
			if (rawError) {
				errorMsg = translations[rawError] || rawError;
				if (rawError.includes('Maximum number of volume snapshots reached')) {
					errorMsg = rawError.replace('Maximum number of volume snapshots reached', 'Se ha alcanzado el número máximo de snapshots permitidos');
				}
			}
		}
		return errorMsg;
	}

	function showNotification(type, title, message) {
		var container = document.getElementById('toast-container');
		var toast = document.createElement('div');
		toast.className = 'toast-msg toast-' + type;
		toast.innerHTML = '<strong>' + title + '</strong>: ' + message;
		container.appendChild(toast);
		setTimeout(function() {
			toast.style.opacity = '0';
			toast.style.transition = 'opacity 0.5s ease-out';
			setTimeout(function() { container.removeChild(toast); }, 500);
		}, 4000);
	}

	document.getElementById('scheduleSnapshotForm').addEventListener('submit', function(e) {
		e.preventDefault();
		submitForm('scheduleSnapshotForm');
	});
	
	function updateTimes() {
		const time = document.getElementById('time').value;
		document.getElementById('utcTime').textContent = time + ' UTC';
	}
	document.getElementById('time').addEventListener('change', updateTimes);
	updateTimes();

	// Force clean navigation for return links
	document.querySelectorAll('a[href*="action=productdetails"]').forEach(function(link) {
		if (!link.href.includes('customaction=')) {
			var newHref = link.href.split('#')[0].replace(/&?customaction=[^&]+/, '').replace(/\?&/, '?').replace(/\?$/, '').replace(/&$/, '');
			link.href = newHref;
			link.addEventListener('click', function(e) {
				e.preventDefault();
				e.stopPropagation();
				window.location.href = this.href;
			});
		}
	});
</script>
