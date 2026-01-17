{include file="orderforms/standard_cart/common.tpl"}

<div id="order-standard_cart">
	<div class="row">
		<div class="col-md-12">
			<div class="header-lined">
				<h1>{$LANG.orderconfigure} - {$productinfo.name}</h1>
			</div>
		</div>

		{if $errormessage}
			<div class="col-md-12">
				<div class="alert alert-danger">
					{$errormessage}
				</div>
			</div>
		{/if}

		<div class="col-md-8">
			<form id="frmConfigureProduct">
				<input type="hidden" name="configure" value="true" />
				<input type="hidden" name="i" value="{$i}" />

				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title">{$LANG.orderconfigpackage}</h3>
					</div>
					<div class="panel-body">
						<h2>{$productinfo.name}</h2>
						<div class="product-info">
							<p>{$productinfo.description}</p>
						</div>

						{if $pricing.type eq "recurring"}
							<div class="field-container">
								<div class="form-group">
									<label for="inputBillingcycle">{$LANG.cartchoosecycle}</label>
									<select name="billingcycle" id="inputBillingcycle" class="form-control select-billing-cycle" onchange="updateConfigurableOptions({$i}, this.value); return false">
										{if $pricing.monthly}
											<option value="monthly"{if $billingcycle eq "monthly"} selected{/if}>
												{$pricing.monthly}
											</option>
										{/if}
										{if $pricing.quarterly}
											<option value="quarterly"{if $billingcycle eq "quarterly"} selected{/if}>
												{$pricing.quarterly}
											</option>
										{/if}
										{if $pricing.semiannually}
											<option value="semiannually"{if $billingcycle eq "semiannually"} selected{/if}>
												{$pricing.semiannually}
											</option>
										{/if}
										{if $pricing.annually}
											<option value="annually"{if $billingcycle eq "annually"} selected{/if}>
												{$pricing.annually}
											</option>
										{/if}
										{if $pricing.biennially}
											<option value="biennially"{if $billingcycle eq "biennially"} selected{/if}>
												{$pricing.biennially}
											</option>
										{/if}
										{if $pricing.triennially}
											<option value="triennially"{if $billingcycle eq "triennially"} selected{/if}>
												{$pricing.triennially}
											</option>
										{/if}
									</select>
								</div>
							</div>
						{/if}

						{if $productinfo.type eq "server"}
							<div class="row">
								<div class="col-md-6">
									<div class="field-container">
										<div class="form-group">
											<label for="inputHostname">{$LANG.serverhostname}</label>
											<input type="text" name="hostname" class="form-control" id="inputHostname" value="{$server.hostname}" placeholder="servername.example.com">
										</div>
									</div>
								</div>
								<div class="col-md-6">
									<div class="field-container">
										<div class="form-group">
											<label for="inputRootpw">{$LANG.serverrootpw}</label>
											<input type="password" name="rootpw" class="form-control" id="inputRootpw" value="{$server.rootpw}">
										</div>
									</div>
								</div>
								<div class="col-md-6">
									<div class="field-container">
										<div class="form-group">
											<label for="inputNs1prefix">{$LANG.serverns1prefix}</label>
											<input type="text" name="ns1prefix" class="form-control" id="inputNs1prefix" value="{$server.ns1prefix}" placeholder="ns1">
										</div>
									</div>
								</div>
								<div class="col-md-6">
									<div class="field-container">
										<div class="form-group">
											<label for="inputNs2prefix">{$LANG.serverns2prefix}</label>
											<input type="text" name="ns2prefix" class="form-control" id="inputNs2prefix" value="{$server.ns2prefix}" placeholder="ns2">
										</div>
									</div>
								</div>
							</div>
						{/if}

						{* Configurable Options *}
						{if $configurableoptions}
							<div class="sub-heading">
								<span>{$LANG.orderconfigpackage}</span>
							</div>

							{* Other Configurable Options *}
							{foreach from=$configurableoptions item=configoption}
								<div class="form-group">
									<label for="inputConfigOption{$configoption.id}" class="control-label">
										{$configoption.optionname}
									</label>
									{if $configoption.optiontype eq 1}
										<select name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" class="form-control" onchange="recalctotals()">
											{foreach from=$configoption.options item=option}
												<option value="{$option.id}"{if $configoption.selectedvalue eq $option.name} selected="selected"{/if}>
													{$option.name}
												</option>
											{/foreach}
										</select>
									{elseif $configoption.optiontype eq 2}
										<div class="radio-inline">
											{foreach from=$configoption.options item=option}
												<label>
													<input type="radio" name="configoption[{$configoption.id}]" value="{$option.id}"{if $configoption.selectedvalue eq $option.name} checked="checked"{/if} onclick="recalctotals()">
													{$option.name}
												</label>
											{/foreach}
										</div>
									{elseif $configoption.optiontype eq 3}
										<label>
											<input type="checkbox" name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" value="1"{if $configoption.selectedqty} checked{/if} onclick="recalctotals()">
											{$LANG.orderavailable}
										</label>
									{elseif $configoption.optiontype eq 4}
										<div class="row">
											<div class="col-sm-4">
												<input type="number" name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" value="{$configoption.selectedqty}" class="form-control" min="{$configoption.qtyminimum}" max="{$configoption.qtymaximum}" onchange="recalctotals()" onkeyup="recalctotals()">
											</div>
											<div class="col-sm-8">
												<span class="help-block">{$LANG.orderForm.min}: {$configoption.qtyminimum} - {$LANG.orderForm.max}: {$configoption.qtymaximum}</span>
											</div>
										</div>
									{/if}
								</div>
							{/foreach}
						{/if}

						{if $customfields}
							<div class="sub-heading">
								<span>{$LANG.orderadditionalrequiredinfo}</span>
							</div>
							<div class="field-container">
								{foreach from=$customfields item=customfield}
									<div class="form-group">
										<label for="customfield{$customfield.id}">{$customfield.name}{if $customfield.required} *{/if}</label>
										{$customfield.input}
										{if $customfield.description}
											<span class="help-block">{$customfield.description}</span>
										{/if}
									</div>
								{/foreach}
							</div>
						{/if}

						{if $addons || count($addonsPromoOutput) > 0}

							<div id="productAddonsContainer">
								<div class="sub-heading">
									<span class="primary-bg-color">{$LANG.cartavailableaddons}</span>
								</div>

								{foreach $addonsPromoOutput as $output}
									<div>
										{$output}
									</div>
								{/foreach}

								<div class="row addon-products">
									{foreach $addons as $addon}
										<div class="col-sm-{if count($addons) > 1}6{else}12{/if}">
											<div class="panel card panel-default panel-addon{if $addon.status} panel-addon-selected{/if}">
												<div class="panel-body card-body">
													<label>
														<input type="checkbox" name="addons[{$addon.id}]"{if $addon.status} checked{/if} />
														{$addon.name}
													</label><br />
													{$addon.description}
												</div>
												<div class="panel-price">
													{$addon.pricing}
												</div>
												<div class="panel-add">
													<i class="fas fa-plus"></i>
													{$LANG.addtocart}
												</div>
											</div>
										</div>
									{/foreach}
								</div>
							</div>
						{/if}

						{if $addons}
							<div class="sub-heading">
								<span>{$LANG.cartavailableaddons}</span>
							</div>
							<div class="field-container">
								{foreach from=$addons item=addon}
									<div class="form-group">
										<label class="checkbox-inline">
											<input type="checkbox" name="addons[{$addon.id}]" id="addon{$addon.id}"{if $addon.selected} checked{/if} onclick="recalctotals()">
											{$addon.name} ({$addon.pricing})
										</label>
										{if $addon.description}
											<span class="help-block">{$addon.description}</span>
										{/if}
									</div>
								{/foreach}
							</div>
						{/if}
					</div>
				</div>

				<div class="alert alert-warning info-text-sm">
					<i class="fas fa-info-circle"></i>
					{$LANG.orderForm.hivelocityInfo|default:"Configure your server options above"}
				</div>

				<div class="text-center">
					<button type="submit" class="btn btn-primary btn-lg">
						{$LANG.continue}
						<i class="fas fa-arrow-circle-right"></i>
					</button>
				</div>
			</form>
		</div>
		<div class="col-md-4" id="scrollingPanelContainer">
			<div class="panel panel-default" id="orderSummary">
				<div class="panel-heading">
					<h3 class="panel-title">{$LANG.ordersummary}</h3>
				</div>
				<div class="panel-body">
					<div class="summary-container">
						<div class="product-name">
							<span>{$productinfo.name}</span>
						</div>

						<div class="product-pricing">
							{if $productinfo.pricing.type eq "recurring"}
								<span class="price">{$productinfo.pricing[$billingcycle].price}</span>
								<span class="cycle">{$LANG.orderpaymentterm[$billingcycle]}</span>
							{else}
								<span class="price">{$productinfo.pricing.onetime.price}</span>
								<span class="cycle">{$LANG.orderpaymenttermonetime}</span>
							{/if}
						</div>

						<div class="summary-details">
							<div class="detail-item">
								<span class="detail-name">{$LANG.ordersetupfee}:</span>
								<span class="detail-value">
									{if $productinfo.pricing.type eq "recurring"}
										{$productinfo.pricing[$billingcycle].setupfee}
									{else}
										{$productinfo.pricing.onetime.setupfee}
									{/if}
								</span>
							</div>

							<div class="detail-item">
								<span class="detail-name">{$LANG.orderbillingcycle}:</span>
								<span class="detail-value">
									{if $productinfo.pricing.type eq "recurring"}
										{$productinfo.pricing[$billingcycle].billingcycle}
									{else}
										{$productinfo.pricing.onetime.billingcycle}
									{/if}
								</span>
							</div>
							<div id="summaryConfigurableOptions">
								{* This will be populated via JavaScript *}
							</div>

							<div id="summaryAddons">
								{* This will be populated via JavaScript *}
							</div>
						</div>

						<div class="total-due-today">
							<span class="total-name">{$LANG.ordertotalduetoday}:</span>
							<span class="total-price" id="totalDueToday">
								{if $productinfo.pricing.type eq "recurring"}
									{$productinfo.pricing[$billingcycle].totalprice}
								{else}
									{$productinfo.pricing.onetime.totalprice}
								{/if}
							</span>
						</div>
					</div>
				</div>

				{if $productinfo.stockcontrol && $productinfo.qty eq "0"}
					<div class="panel-footer">
						<div class="alert alert-danger">
							{$LANG.outofstock}
						</div>
					</div>
				{/if}
			</div>

			<div class="panel-footer">
				<div class="text-center">
					<button type="submit" id="btnCompleteProductConfig" class="btn btn-primary btn-lg">
						{$LANG.continue}
						<i class="fas fa-arrow-circle-right"></i>
					</button>
				</div>
			</div>

			{if $crosssells}
				<div class="panel panel-default" id="crossSellProducts">
					<div class="panel-heading">
						<h3 class="panel-title">{$LANG.orderForm.mayAlsoLike}</h3>
					</div>
					<div class="panel-body">
						<div class="crosssell-container">
							{foreach from=$crosssells item=crosssell}
								<div class="crosssell-item">
									<div class="crosssell-name">
										<a href="{$crosssell.link}">{$crosssell.name}</a>
									</div>
									<div class="crosssell-description">
										{$crosssell.description|truncate:50:"..."}
									</div>
									<div class="crosssell-price">
										{$crosssell.pricing}
									</div>
									<div class="crosssell-actions">
										<a href="{$crosssell.link}" class="btn btn-default btn-sm">
											{$LANG.orderForm.viewDetails}
										</a>
										<a href="{$crosssell.addtocarturl}" class="btn btn-primary btn-sm">
											{$LANG.orderForm.addToCart}
										</a>
									</div>
								</div>
							{/foreach}
						</div>
					</div>
				</div>
			{/if}
		</div>
	</div>
</div>
<style>
	/* Order Summary Styling */
	#scrollingPanelContainer {
		position: relative;
	}

	.sticky-summary {
		position: fixed;
		top: 20px;
		width: inherit;
		max-width: inherit;
		z-index: 100;
	}

	.summary-container {
		margin-bottom: 15px;
	}

	.product-name {
		font-size: 16px;
		font-weight: 600;
		margin-bottom: 10px;
	}

	.product-pricing {
		margin-bottom: 15px;
		text-align: right;
	}

	.product-pricing .price {
		font-size: 20px;
		font-weight: 700;
		color: #2196F3;
	}

	.product-pricing .cycle {
		display: block;
		font-size: 12px;
		color: #777;
	}

	.summary-details {
		border-top: 1px solid #ddd;
		border-bottom: 1px solid #ddd;
		padding: 10px 0;
		margin-bottom: 15px;
	}

	.detail-item {
		display: flex;
		justify-content: space-between;
		margin-bottom: 5px;
	}
	
	.detail-name {
		color: #777;
	}
	
	.detail-value {
		font-weight: 600;
	}
	
	.total-due-today {
		display: flex;
		justify-content: space-between;
		font-size: 16px;
		font-weight: 600;
	}
	
	.total-price {
		color: #2196F3;
	}
	
	/* Cross-sell Products */
	.crosssell-container {
		margin-bottom: 15px;
	}
	
	.crosssell-item {
		border-bottom: 1px solid #eee;
		padding-bottom: 10px;
		margin-bottom: 10px;
	}
	
	.crosssell-item:last-child {
		border-bottom: none;
		margin-bottom: 0;
	}
	
	.crosssell-name {
		font-weight: 600;
		margin-bottom: 5px;
	}
	
	.crosssell-description {
		font-size: 12px;
		color: #777;
		margin-bottom: 5px;
	}
	
	.crosssell-price {
		font-weight: 600;
		color: #2196F3;
		margin-bottom: 5px;
	}
	
	.crosssell-actions {
		display: flex;
		justify-content: space-between;
	}
	
	/* Info Text */
	.info-text-sm {
		font-size: 12px;
	}
	/* Server Specifications */
	.server-specs {
		margin-bottom: 30px;
	}
	
	.spec-box {
		border: 1px solid #ddd;
		border-radius: 4px;
		padding: 15px;
		margin-bottom: 15px;
		text-align: center;
		height: 100%;
	}
	
	.spec-icon {
		font-size: 24px;
		margin-bottom: 10px;
		color: #2196F3;
	}
	
	.spec-title {
		font-weight: 600;
		margin-bottom: 5px;
	}
	
	.spec-value {
		color: #666;
	}
	
	/* Responsive Adjustments */
	@media (max-width: 767px) {
		.os-icon {
			font-size: 24px;
		}
		
		.os-name {
			font-size: 14px;
		}
		
		.raid-icon {
			font-size: 20px;
		}
		
		.raid-name {
			font-size: 14px;
		}
		
		.raid-description {
			font-size: 10px;
		}
		
		.datacenter-icon {
			font-size: 20px;
		}
		
		.datacenter-name {
			font-size: 14px;
		}
	}

	/* Estilos para opciones no disponibles */
	.datacenter-option.unavailable {
		opacity: 0.6;
		cursor: not-allowed;
		position: relative;
	}
	
	.datacenter-option.unavailable:hover {
		transform: none;
		box-shadow: none;
	}
	
	.datacenter-option.unavailable .datacenter-label {
		cursor: not-allowed;
	}
	
	.datacenter-status {
		font-size: 12px;
		color: #dc3545;
		margin-top: 5px;
		font-weight: 500;
	}
	
	.datacenter-option.unavailable:after {
		content: "";
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: rgba(255, 255, 255, 0.5);
		z-index: 1;
	}
	
	.datacenter-option.unavailable .datacenter-icon,
	.datacenter-option.unavailable .datacenter-name {
		position: relative;
		z-index: 2;
	}

	.os-option.unavailable {
		opacity: 0.6;
		cursor: not-allowed;
		pointer-events: none;
		position: relative;
	}
	.os-option.unavailable:hover {
		background: inherit;
		border-color: #ddd;
		box-shadow: none;
		transform: none;
	}

	.os-option.unavailable.selected {
	border-color: #aaa;
	background: #f5f5f5;
}
</style>