{literal}
<style>
	.stat{
		font-size: 22px !important;
	}
</style>
{/literal}
<div>
	<div class="alert alert-danger text-center" id="hivelocityMainErrorBox" style="display:none"></div>
	<div class="tiles mb-4" style="text-align: left;">
        <div class="row no-gutters">
            <div class="col-6 col-xl-3">
                <div class="tile">
                    <div class="stat">{$dashboarddetails.location}</div>
                    <div class="title">Device Location</div>
                    <div class="highlight bg-color-blue"></div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="tile">
                    <div class="stat">{$dashboarddetails.renewdate}</div>
                    <div class="title">Next Renew</div>
                    <div class="highlight bg-color-green"></div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="tile">
                    <div class="stat">{$dashboarddetails.monitorsUp} UP</div>
                    <div class="title">Monitoring</div>
                    <div class="highlight bg-color-red"></div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="tile">
                    <div class="stat">0/0 OK</div>
                    <div class="title">Backups</div>
                    <div class="highlight bg-color-gold"></div>
                </div>
            </div>
        </div>
    </div>
	<div class="row">
		<div class="col-6 col-xl-6">
			<div class=""><h4>{$_LANG.service_details}</h4>{$servicedetails}</div>
		</div>
		<div class="col-6 col-xl-6">
			<div class=""><h4>{$_LANG.hardware_details}</h4>{$hardwaredetails}</div>
		</div>
	</div>
	<hr>
	<ul class="nav nav-tabs responsive-tabs-sm">
		<li class="active nav-item"><a data-toggle="tab" class="nav-link active" href="#tabDetails">{$_LANG.details}</a></li>
		{if !$orderStatus}
			<li class="nav-item"><a data-toggle="tab" class="nav-link" href="#tabIpAssignments">{$_LANG.ip_assignments}</a></li>
			<li class="nav-item"><a data-toggle="tab" class="nav-link" href="#tabBandwidth">{$_LANG.bandwidth}</a></li>
			{if $ipmisensors}<li class="nav-item"><a data-toggle="tab" class="nav-link" href="#tabIpmi">IPMI</a></li>{/if}
		{/if}
	</ul>
	<div class="tab-content" style="border-style: solid; border-color: #ddd; padding:15px; padding-top: 20px; padding-bottom: 20px; border-width: 1px; border-top-style: none;" >
		<div id="tabDetails" class="tab-pane fade in active">
			{if !$orderStatus && $initialPassword}
				<div class="alert alert-info" role="alert" style="margin-bottom:20px;">
					{$_LANG.temporary_password_message} {$passwordExpiresInString}.
				</div>
			{/if}
			<div class="container" style="width:auto">
				{if $orderStatus}
					<div class="row">
						<div class="col-sm-5 text-right">
							<strong>{$_LANG.order_status}</strong>
						</div>
						<div class="col-sm-7 text-left">
							{$orderStatus}
						</div>
					</div>
				{else}
					<div class="row">
						<div class="col-sm-5 text-right">
							<strong>{$_LANG.device_status}</strong>
						</div>
						<div class="col-sm-7 text-left">
							{$deviceStatus}
						</div>
					</div>
					<div class="row">
						<div class="col-sm-5 text-right">
							<strong>{$_LANG.power_status}</strong>
						</div>
						<div class="col-sm-7 text-left">
							{$devicePowerStatus}
						</div>
					</div>
					<div class="row">
						<div class="col-sm-5 text-right">
							<strong>{$_LANG.default_ssh_user}</strong>
						</div>
						<div class="col-sm-7 text-left">
							{$username}
						</div>
					</div>
					{if $initialPassword}
						<div class="row">
							<div class="col-sm-5 text-right">
								<strong>{$_LANG.default_password} (expires {$passwordExpiresInString}) </strong>
							</div>
							<div class="col-sm-7 text-left">
								{$initialPassword}
							</div>
						</div>
					{/if}
					<div class="row">
						<div class="col-sm-5 text-right">
							<strong>{$_LANG.primary_ip_address}</strong>
						</div>
						<div class="col-sm-7 text-left">
							{$primaryIp}
						</div>
					</div>
				{/if}
			</div>
		</div>

		{if !$orderStatus}
			<div id="tabIpAssignments" class="tab-pane fade">
				<div class="container" style="width:auto">
					{if is_array($ips)}
					{foreach from=$ips key=key item=ipAssignment}
						<div {if $key neq (count($ips) - 1)} style="margin-bottom:20px" {/if}>
							<div class="row">
								<div class="col-sm-5 text-right">
									<strong>{$_LANG.ip_address}</strong>
								</div>
								<div class="col-sm-7 text-left">
									{$ipAssignment.description}
								</div>
							</div>
							<div class="row">
								<div class="col-sm-5 text-right">
									<strong>IP Range (CIDR)</strong>
								</div>
								<div class="col-sm-7 text-left">
									{$ipAssignment.subnet}
								</div>
							</div>
							<div class="row">
								<div class="col-sm-5 text-right">
									<strong>Netmask</strong>
								</div>
								<div class="col-sm-7 text-left">
									{$ipAssignment.netmask}
								</div>
							</div>

							{if empty($ipAssignment.usableIps)}
								</div>
								{continue}
							{/if}

							<div class="row">
								<div class="col-sm-5 text-right">
									<strong>Gateway IP</strong>
								</div>
								<div class="col-sm-7 text-left">
									{$ipAssignment.usableIps[0]}
								</div>
							</div>

							{foreach from=$ipAssignment.usableIps key=key item=usableIp}
								{if $key eq 0} {continue} {/if}

								<div class="row">
									<div class="col-sm-5 text-right">
										<strong>Usable IP</strong>
									</div>
									<div class="col-sm-7 text-left">
										{$usableIp}
									</div>
								</div>
							{/foreach}
						</div>
					{/foreach}
					{/if}
				</div>
			</div>

			<div id="tabBandwidth" class="tab-pane fade">
				<div class="container" style="width:auto">
					<div class="row" style="margin-bottom:5px">
						<div class="col">
							<table class="hivelocityFormTable" style="margin: auto;width: 100%;">
								<tr>
									<td style="width: 120px; text-align: right; padding-right: 5px; display:none;">
										<strong>{$_LANG.update}</strong>
									</td>
									<td style="width: 100%; text-align: right;">
										<button id="updateGraph" class="btn btn-primary" style="color: white"><i class="fas fa-sync"></i> {$_LANG.update}</button>
									</td>
									<td style="width: 200px; text-align: left; display: none;">
										<select id="periodSelect" class="form-control select-inline">
											<option value="day">Day</option>
											<option value="week">Week</option>
											<option value="month">Month</option>
											<option value="custom">Custom</option>
										</select>
									</td>
								</tr>
							</table>
						</div>
					</div>
					<div id="customPeriodDiv" class="row" style="margin-bottom:5px; display:none;">
						<div class="col">
							<table  class="hivelocityFormTable" style="margin: auto;">
								<tr>
									<td style="width: 120px; text-align: right; padding-right: 5px;">
										<strong>Custom Period</strong>
									</td>
									<td style="width: 200px; text-align: left">
										<input id="customPeriodInput" type="text" class="form-control input-inline">
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<img src="https://my.quecodigo.com/templates/hustbee/images/loading.gif" id="graphLoader" class="" style="display: none;">
				<div id="tabBandwidthGraphs">
					<h5 style="text-align: left;">
						<svg xmlns="http://www.w3.org/2000/svg" focusable="false" class="hv-tn" width="18" height="18" preserveAspectRatio="xMidYMid meet" viewBox="0 0 24 24" style="transform: rotate(360deg); vertical-align: -0.125em;"><path fill="currentColor" d="M15 9H9v6h6V9zm-2 4h-2v-2h2v2zm8-2V9h-2V7c0-1.1-.9-2-2-2h-2V3h-2v2h-2V3H9v2H7c-1.1 0-2 .9-2 2v2H3v2h2v2H3v2h2v2c0 1.1.9 2 2 2h2v2h2v-2h2v2h2v-2h2c1.1 0 2-.9 2-2v-2h2v-2h-2v-2h2zm-4 6H7V7h10v10z"></path></svg>
						<strong>{$_LANG.cpu_usage}</strong>
					</h5>
					<hr>
					<div id="cpu-graph"></div>
					<br>

					<h5 style="text-align: left;">
						<svg xmlns="http://www.w3.org/2000/svg" focusable="false" class="hv-tn" width="18" height="18" preserveAspectRatio="xMidYMid meet" viewBox="0 0 640 512" style="transform: rotate(360deg); vertical-align: -0.125em;"><path fill="currentColor" d="M640 130.94V96c0-17.67-14.33-32-32-32H32C14.33 64 0 78.33 0 96v34.94c18.6 6.61 32 24.19 32 45.06s-13.4 38.45-32 45.06V320h640v-98.94c-18.6-6.61-32-24.19-32-45.06s13.4-38.45 32-45.06zM224 256h-64V128h64v128zm128 0h-64V128h64v128zm128 0h-64V128h64v128zM0 448h64v-26.67c0-8.84 7.16-16 16-16s16 7.16 16 16V448h128v-26.67c0-8.84 7.16-16 16-16s16 7.16 16 16V448h128v-26.67c0-8.84 7.16-16 16-16s16 7.16 16 16V448h128v-26.67c0-8.84 7.16-16 16-16s16 7.16 16 16V448h64v-96H0v96z"></path></svg>
						<strong>{$_LANG.ram_usage}</strong>
					</h5>
					<hr>
					<div id="memory-graph"></div>
					<br>

					<h5 style="text-align: left;">
						<svg xmlns="http://www.w3.org/2000/svg" focusable="false" class="hv-tn" width="18" height="18" preserveAspectRatio="xMidYMid meet" viewBox="0 0 24 24" style="transform: rotate(360deg); vertical-align: -0.125em;"><path fill="currentColor" d="M6 2h12a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2m6 2a6 6 0 0 0-6 6c0 3.31 2.69 6 6.1 6l-.88-2.23a1.01 1.01 0 0 1 .37-1.37l.86-.5a1.01 1.01 0 0 1 1.37.37l1.92 2.42A5.977 5.977 0 0 0 18 10a6 6 0 0 0-6-6m0 5a1 1 0 0 1 1 1a1 1 0 0 1-1 1a1 1 0 0 1-1-1a1 1 0 0 1 1-1m-5 9a1 1 0 0 0-1 1a1 1 0 0 0 1 1a1 1 0 0 0 1-1a1 1 0 0 0-1-1m5.09-4.73l2.49 6.31l2.59-1.5l-4.22-5.31l-.86.5Z"></path></svg>
						<strong>{$_LANG.disk_usage}</strong>
					</h5>
					<hr>
					<div id="disk-graph"></div>
					<br>

					<h5 style="text-align: left;">
						<svg xmlns="http://www.w3.org/2000/svg" focusable="false" class="hv-tn" width="18" height="18" preserveAspectRatio="xMidYMid meet" viewBox="0 0 24 24" style="transform: rotate(360deg); vertical-align: -0.125em;"><path fill="currentColor" d="M15 20a1 1 0 0 0-1-1h-1v-2h4a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h4v2h-1a1 1 0 0 0-1 1H2v2h7a1 1 0 0 0 1 1h4a1 1 0 0 0 1-1h7v-2h-7m-8-5V5h10v10H7Z"></path></svg>
						<strong>{$_LANG.network_usage}</strong>
					</h5>
					<hr>
					<div id="network-graph"></div>
				</div>
			</div>
			{if $ipmisensors}
				<div id="tabIpmi" class="tab-pane fade">
					<div class="container" style="width:auto">
						<div class="row" style="margin-bottom:5px">
							<div class="col">
								<h6>IPMI Sensors</h6>
							</div>
						</div>
						<div class="row" style="margin-bottom:5px">
							<div class="col">
								<table id="" style="width:100%" border="1">
									{foreach from = $ipmisensors item = sensor}
										<tr>
											<td style="width:50%; text-align: center;">{$sensor.name}</td>
											<td style="width:50%; text-align: center;">{$sensor.unit}</td>
										</tr>
									{/foreach}
								</table>
							</div>
						</div>
					</div>
				</div>
			{/if}
		{/if}
	</div>

</div>

<style>
	#manage td {
	  padding:1px;
	}
</style>
<script>
	var hivelocityServiceId = {$serviceId};
</script>
<script type="text/javascript" src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
<script src="modules/servers/Hivelocity/templates/js/clientArea.js" type="text/javascript"></script>
