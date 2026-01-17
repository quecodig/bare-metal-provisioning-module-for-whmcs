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
	#createSnapshotModal.modal {
		display: none;
		position: fixed;
		z-index: 50;
		left: 0;
		top: 0;
		width: 100%;
		height: 100%;
		overflow: auto;
		background-color: rgba(0,0,0,0.4);
	}
	#createSnapshotModal .modal-content {
		background-color: #fefefe;
		margin: 10% auto;
		padding: 20px;
		border: 1px solid #888;
		width: 50%;
		max-width: 500px;
		border-radius: 8px;
	}
	#createSnapshotModal .close {
		color: #aaa;
		float: right;
		font-size: 28px;
		font-weight: bold;
		cursor: pointer;
	}
	#createSnapshotModal .close:hover,
	#createSnapshotModal .close:focus {
		color: #000;
		text-decoration: none;
		cursor: pointer;
	}
	#createSnapshotModal .form-group {
		margin-bottom: 15px;
	}
	#createSnapshotModal .form-group label {
		display: block;
		margin-bottom: 5px;
		font-weight: 500;
	}
	#createSnapshotModal .form-control {
		width: 100%;
		padding: 8px;
		font-size: 14px;
		border: 1px solid #ced4da;
		border-radius: 4px;
	}
	#createSnapshotModal .schedule-info {
		background-color: #f8f9fa;
		border: 1px solid #e9ecef;
		border-radius: 4px;
		padding: 10px;
		margin-top: 15px;
		font-size: 14px;
	}
</style>

<div class="snapshot-container">
	<h3>Snapshots Existentes</h3>
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
					<a href="index.php?m=server_info&action=restore_snapshot&snapshot_id={$snapshot.id}&serviceid={$serviceId}" class="btn btn-primary">Restaurar</a>
					<a href="index.php?m=server_info&action=delete_snapshot&snapshot_id={$snapshot.id}&serviceid={$serviceId}" class="btn btn-danger">Eliminar</a>
				</td>
			</tr>
			{/foreach}
		  </tbody>
	</table>
	{else}
		<p>No hay snapshots disponibles.</p>
	{/if}

	<h3>Snapshots Programados <button id="createSnapshotBtn" class="btn btn-success" style="float: right; display: none">Crear Snapshot</button></h3>
	{if $schedules}
	<table class="schedule-table">
		<thead>
			<tr>
				<th>Nombre</th>
				<th>Fecha Programada</th>
				<th>Disco ID</th>
				<th style="display: none">Acciones</th>
			</tr>
		</thead>
		<tbody>
			{foreach from=$schedules item=schedule}
			<tr>
				<td>{$schedule.snapshotScheduleId}</td>
				<td>{$schedule.frecuency}</td>
				<td>{$schedule.volumeId}</td>
				<td style="display: none">
					<a href="index.php?m=server_info&action=delete_schedule&schedule_id=1&serviceid=123" class="btn btn-danger">Eliminar</a>
				</td>
			</tr>
			{/foreach}
		</tbody>
	</table>
	{else}
		<p>No hay schedules disponibles.</p>
	{/if}
</div>

<div id="createSnapshotModal" class="modal">
	<div class="modal-content">
		<span class="close">&times;</span>
		<h3>Crear Nuevo Snapshot</h3>
		<form id="snapshotForm" action="process_snapshot.php" method="POST">
			<div class="form-group">
				<label for="disk">Disco:</label>
				<select id="disk" name="disk" class="form-control" required>
					<option value="ROOT-5a090a97-a4d1-46dc-9bae-ed1922e3b0e2">ROOT-5a090a97-a4d1-46dc-9bae-ed1922e3b0e2</option>
				</select>
			</div>

			<h4>Programación de Snapshots</h4>
			<div class="form-group">
				<label for="schedule">Frecuencia:</label>
				<select id="schedule" name="schedule" class="form-control" required>
					<option value="daily">Diaria</option>
					<option value="weekly">Semanal</option>
					<option value="monthly">Mensual</option>
				</select>
			</div>

			<div class="form-group">
				<label for="time">Hora:</label>
				<input type="time" id="time" name="time" value="00:00" class="form-control" required>
			</div>

			<div class="form-group">
				<label for="weekDay">Día de la semana:</label>
				<select id="weekDay" name="weekDay" class="form-control" required>
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
				<p>Snapshot será programado para (UTC): <span id="utcTime">13 January 2025 05:00 AM</span></p>
				<p>Próximo snapshot en su ubicación (UTC -05:00): <span id="localTime">13 January 2025 12:00 AM</span></p>
			</div>

			<button type="submit" class="btn btn-success">Crear Snapshot</button>
		</form>
	</div>
</div>
<script>
	var modal = document.getElementById("createSnapshotModal");
	var btn = document.getElementById("createSnapshotBtn");
	var span = document.getElementsByClassName("close")[0];

	btn.onclick = function() {
		modal.style.display = "block";
	}

	span.onclick = function() {
		modal.style.display = "none";
	}

	window.onclick = function(event) {
		if (event.target == modal) {
			modal.style.display = "none";
		}
	}

	function updateTimes() {
		const weekDay = document.getElementById('weekDay').value;
		const time = document.getElementById('time').value;

		const now = new Date();
		const daysUntilNext = (7 + (weekDay - now.getDay())) % 7;
		const nextDate = new Date(now.getFullYear(), now.getMonth(), now.getDate() + daysUntilNext);

		const [hours, minutes] = time.split(':');
		nextDate.setHours(hours, minutes, 0, 0);

		const utcDate = new Date(nextDate.getTime() + nextDate.getTimezoneOffset() * 60000);

		const utcString = utcDate.toUTCString();
		const localString = nextDate.toLocaleString();

		document.getElementById('utcTime').textContent = utcString;
		document.getElementById('localTime').textContent = localString;
	}

	document.getElementById('weekDay').addEventListener('change', updateTimes);
	document.getElementById('time').addEventListener('change', updateTimes);

	updateTimes();
</script>