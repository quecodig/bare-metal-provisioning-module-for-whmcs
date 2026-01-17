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
	.snapshot-table, .schedule-table {
		width: 100%;
		border-collapse: separate;
		border-spacing: 0;
		margin-bottom: 25px;
	}
	.snapshot-table th, .snapshot-table td,
	.schedule-table th, .schedule-table td {
		padding: 12px 15px;
		text-align: left;
		border-bottom: 1px solid #e0e0e0;
	}
	.snapshot-table th, .schedule-table th {
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
</style>

<div class="snapshot-container">

	<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
		<h3 style="margin: 0;">Snapshots Existentes</h3>
		<button id="createManualSnapshotBtn" class="btn btn-primary">Crear Snapshot Manual</button>
	</div>
	
	{if $msg == 'restored'}
	<div class="alert alert-success">La restauración del snapshot se ha iniciado. El servidor puede reiniciarse.</div>
	{/if}

	{if $snapshots}
	<table class="snapshot-table">
		<thead>
			<tr>
				<th>Nombre</th>
				<th>Fecha de Creación</th>
				<th>Tipo</th>
				<th style="width: 30%">Acciones</th>
			</tr>
		</thead>
		<tbody>
		{foreach from=$snapshots item=snapshot}
			<tr>
				<td>{$snapshot.name}</td>
				<td>{$snapshot.createdAt|strtotime|date_format:"%d/%m/%Y %H:%M"}</td>
				<td>{$snapshot.snapshotType}</td>
				<td>

					<a href="index.php?m=server_info&action=restore_snapshot&snapshot_id={$snapshot.snapshotId}&serviceid={$serviceId}" class="btn btn-warning" onclick="return confirm('¿Está seguro de restaurar este snapshot? Esto sobrescribirá datos actuales.')">Restaurar</a>
					<a href="index.php?m=server_info&action=delete_snapshot&snapshot_id={$snapshot.snapshotId}&serviceid={$serviceId}" class="btn btn-danger" onclick="return confirm('¿Eliminar permanentemente este snapshot?')">Eliminar</a>
				</td>
			</tr>
			{/foreach}
		  </tbody>
	</table>
	{else}
		<p>No hay snapshots disponibles.</p>
	{/if}

	<div style="display: flex; justify-content: space-between; align-items: center; margin-top: 40px; margin-bottom: 20px;">
		<h3 style="margin: 0;">Snapshots Programados</h3>
		<button id="createScheduleBtn" class="btn btn-success" onclick="openScheduleCreateModal()">Programar Snapshot</button>
	</div>

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
					<a href="index.php?m=server_info&action=delete_schedule&schedule_id={$schedule.snapshotScheduleId}&serviceid={$serviceId}" class="btn btn-danger" onclick="return confirm('¿Eliminar esta programación?')">Eliminar</a>
				</td>
			</tr>
			{/foreach}
		</tbody>
	</table>
	{else}
		<p>No hay schedules disponibles.</p>
	{/if}
</div>

<!-- Modal Manual Snapshot -->
<div id="manualSnapshotModal" class="custom-modal">
	<div class="modal-content">
		<div class="modal-header">
			<h3 id="manualModalTitle">Crear Snapshot Manual</h3>
			<span class="close" data-modal="manualSnapshotModal">&times;</span>
		</div>
		<div class="modal-body">
			<p class="text-muted">Esto creará un snapshot del estado actual del servidor.</p>
			<form id="manualSnapshotForm">
				<input type="hidden" name="serviceid" value="{$serviceId}">
				<input type="hidden" name="snapshot_id" id="manual_snapshot_id" value="">
				<input type="hidden" name="action_type" id="manual_action_type" value="create_snapshot">
				<input type="hidden" name="volume_id" value="{$volumeId}">
				
				<div class="form-group">
				<label for="snapshot_name">Nombre (Opcional):</label>
				<input type="text" id="snapshot_name" name="snapshot_name" class="form-control" placeholder="Snapshot-Manual">
			</div>
			<button type="submit" class="btn btn-primary" id="manualSubmitBtn">Crear</button>
			</form>
		</div>
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
			<form id="scheduleSnapshotForm">
				<input type="hidden" name="serviceid" value="{$serviceId}">
				<input type="hidden" name="schedule_id" id="schedule_id" value="">
				<input type="hidden" name="action_type" id="schedule_action_type" value="create_schedule">
				
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

<script>
	// Modal Logic
	var manualModal = document.getElementById("manualSnapshotModal");
	var scheduleModal = document.getElementById("scheduleSnapshotModal");
	
	document.getElementById("createManualSnapshotBtn").onclick = function() { 
		// Reset for Create
		document.getElementById('manualModalTitle').innerText = "Crear Snapshot Manual";
		document.getElementById('manualSubmitBtn').innerText = "Crear";
		document.getElementById('manual_action_type').value = "create_snapshot";
		document.getElementById('manual_snapshot_id').value = "";
		document.getElementById('snapshot_name').value = "";
		manualModal.style.display = "block"; 
	}

	function openScheduleCreateModal() {
		// Reset for Create
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

	window.onclick = function(event) {
		if (event.target == manualModal) manualModal.style.display = "none";
		if (event.target == scheduleModal) scheduleModal.style.display = "none";
	}

	// Schedule Actions Logic
	document.getElementById('schedule').addEventListener('change', function() {
		var val = this.value;
		document.getElementById('weekDayGroup').style.display = (val === 'weekly') ? 'block' : 'none';
	});

	// AJAX Submission
	function submitForm(formId) {
		var form = document.getElementById(formId);
		var formData = new FormData(form);
		
		// Get action from hidden field
		var actionType = form.querySelector('input[name="action_type"]').value;
		
		var url = 'index.php?m=server_info&action=' + actionType + '&serviceid={$serviceId}';
		
		fetch(url, {
			method: 'POST',
			body: formData
		})
		.then(response => response.json())
		.then(data => {
			if(data.success) {
				alert('Operación exitosa');
				location.reload();
			} else {
				alert('Error: ' + JSON.stringify(data.response || 'Desconocido'));
			}
		})
		.catch(error => {
			console.error('Error:', error);
			alert('Error de conexión');
		});
	}

	document.getElementById('manualSnapshotForm').addEventListener('submit', function(e) {
		e.preventDefault();
		submitForm('manualSnapshotForm');
	});

	document.getElementById('scheduleSnapshotForm').addEventListener('submit', function(e) {
		e.preventDefault();
		submitForm('scheduleSnapshotForm');
	});
	
	function updateTimes() {
	    // Simple update logic for display
		const time = document.getElementById('time').value;
		document.getElementById('utcTime').textContent = time + ' UTC';
	}
	document.getElementById('time').addEventListener('change', updateTimes);
	updateTimes();
</script>