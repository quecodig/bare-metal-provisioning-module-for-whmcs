{include file="orderforms/standard_cart/common.tpl"}

<script>
var _localLang = {
    'addToCart': '{$LANG.orderForm.addToCart|escape}',
    'addedToCartRemove': '{$LANG.orderForm.addedToCartRemove|escape}',
    'continue': '{$LANG.continue|escape}',
    'loading': 'Loading...'
}
</script>

<div class="order-container">
    <div class="container">
        <div class="row">
            <div class="col-md-8">
                <div class="order-content">
                    
                    {* Header mejorado *}
                    <div class="product-configure-header">
                        <div class="breadcrumb-nav">
                            <a href="{$smarty.server.PHP_SELF}" class="breadcrumb-link">
                                <i class="fas fa-arrow-left"></i> {$LANG.orderForm.backToProducts}
                            </a>
                        </div>
                        <h1 class="product-title">{$productinfo.name}</h1>
                        <p class="product-description">{$productinfo.description}</p>
                    </div>

                    {* Alertas de error mejoradas *}
                    <div class="alert alert-danger w-hidden modern-alert" role="alert" id="containerProductValidationErrors">
                        <div class="alert-icon">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <div class="alert-content">
                            <h4>{$LANG.orderForm.correctErrors}:</h4>
                            <ul id="containerProductValidationErrorsList"></ul>
                        </div>
                    </div>

                    <form id="frmConfigureProduct" class="modern-form">
                        <input type="hidden" name="configure" value="true" />
                        <input type="hidden" name="i" value="{$i}" />

                        {* Ciclos de facturación mejorados *}
                        {if $pricing.type eq "recurring"}
                            <div class="config-section">
                                <div class="section-header">
                                    <h3 class="section-title">
                                        <i class="fas fa-calendar-alt"></i>
                                        {$LANG.cartchoosecycle}
                                    </h3>
                                    <p class="section-description">Choose your preferred billing cycle</p>
                                </div>
                                
                                <div class="billing-cycles-grid">
                                    {if $pricing.monthly}
                                        <div class="billing-cycle-card">
                                            <input type="radio" name="billingcycle" value="monthly" id="cycle-monthly" 
                                                   {if $billingcycle eq "monthly"}checked{/if}
                                                   onchange="updateConfigurableOptions({$i}, this.value); return false">
                                            <label for="cycle-monthly" class="cycle-label">
                                                <div class="cycle-header">
                                                    <span class="cycle-name">Monthly</span>
                                                    <span class="cycle-badge">Most Flexible</span>
                                                </div>
                                                <div class="cycle-price">{$pricing.monthly}</div>
                                                <div class="cycle-features">
                                                    <span>✓ Pay as you go</span>
                                                    <span>✓ Cancel anytime</span>
                                                </div>
                                            </label>
                                        </div>
                                    {/if}
                                    
                                    {if $pricing.annually}
                                        <div class="billing-cycle-card">
                                            <input type="radio" name="billingcycle" value="annually" id="cycle-annually"
                                                   {if $billingcycle eq "annually"}checked{/if}
                                                   onchange="updateConfigurableOptions({$i}, this.value); return false">
                                            <label for="cycle-annually" class="cycle-label">
                                                <div class="cycle-header">
                                                    <span class="cycle-name">Annually</span>
                                                    <span class="cycle-badge popular">Most Popular</span>
                                                </div>
                                                <div class="cycle-price">{$pricing.annually}</div>
                                                <div class="cycle-features">
                                                    <span>✓ 2 months free</span>
                                                    <span>✓ Best value</span>
                                                </div>
                                            </label>
                                        </div>
                                    {/if}
                                    
                                    {if $pricing.biennially}
                                        <div class="billing-cycle-card">
                                            <input type="radio" name="billingcycle" value="biennially" id="cycle-biennially"
                                                   {if $billingcycle eq "biennially"}checked{/if}
                                                   onchange="updateConfigurableOptions({$i}, this.value); return false">
                                            <label for="cycle-biennially" class="cycle-label">
                                                <div class="cycle-header">
                                                    <span class="cycle-name">2 Years</span>
                                                    <span class="cycle-badge premium">Maximum Savings</span>
                                                </div>
                                                <div class="cycle-price">{$pricing.biennially}</div>
                                                <div class="cycle-features">
                                                    <span>✓ 4 months free</span>
                                                    <span>✓ Lowest price</span>
                                                </div>
                                            </label>
                                        </div>
                                    {/if}
                                </div>
                            </div>
                        {/if}

                        {* Configuración de servidor mejorada *}
                        {if $productinfo.type eq "server"}
                            <div class="config-section">
                                <div class="section-header">
                                    <h3 class="section-title">
                                        <i class="fas fa-server"></i>
                                        {$LANG.cartconfigserver}
                                    </h3>
                                    <p class="section-description">Configure your server settings</p>
                                </div>
                                
                                <div class="server-config-grid">
                                    <div class="form-group">
                                        <label for="inputHostname" class="modern-label">
                                            <i class="fas fa-globe"></i>
                                            {$LANG.serverhostname}
                                        </label>
                                        <input type="text" name="hostname" class="form-control modern-input" 
                                               id="inputHostname" value="{$server.hostname}" 
                                               placeholder="servername.example.com">
                                        <div class="input-help">Enter your desired hostname</div>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label for="inputRootpw" class="modern-label">
                                            <i class="fas fa-lock"></i>
                                            {$LANG.serverrootpw}
                                        </label>
                                        <div class="password-input-wrapper">
                                            <input type="password" name="rootpw" class="form-control modern-input" 
                                                   id="inputRootpw" value="{$server.rootpw}">
                                            <button type="button" class="password-toggle" onclick="togglePassword('inputRootpw')">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </div>
                                        <div class="input-help">Choose a strong root password</div>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label for="inputNs1prefix" class="modern-label">
                                            <i class="fas fa-dns"></i>
                                            {$LANG.serverns1prefix}
                                        </label>
                                        <input type="text" name="ns1prefix" class="form-control modern-input" 
                                               id="inputNs1prefix" value="{$server.ns1prefix}" placeholder="ns1">
                                    </div>
                                    
                                    <div class="form-group">
                                        <label for="inputNs2prefix" class="modern-label">
                                            <i class="fas fa-dns"></i>
                                            {$LANG.serverns2prefix}
                                        </label>
                                        <input type="text" name="ns2prefix" class="form-control modern-input" 
                                               id="inputNs2prefix" value="{$server.ns2prefix}" placeholder="ns2">
                                    </div>
                                </div>
                            </div>
                        {/if}

                        {* Opciones configurables mejoradas *}
                        {if $configurableoptions}
                            <div class="config-section">
                                <div class="section-header">
                                    <h3 class="section-title">
                                        <i class="fas fa-cogs"></i>
                                        {$LANG.orderconfigpackage}
                                    </h3>
                                    <p class="section-description">Customize your package options</p>
                                </div>
                                
                                <div class="configurable-options-grid" id="productConfigurableOptions">
                                    {foreach $configurableoptions as $configoption}
                                        <div class="config-option-card">
                                            <div class="option-header">
                                                <h4 class="option-name">{$configoption.optionname}</h4>
                                                {if $configoption.description}
                                                    <p class="option-description">{$configoption.description}</p>
                                                {/if}
                                            </div>
                                            
                                            <div class="option-control">
                                                {if $configoption.optiontype eq 1}
                                                    {* Dropdown *}
                                                    <select name="configoption[{$configoption.id}]" 
                                                            id="inputConfigOption{$configoption.id}" 
                                                            class="form-control modern-select"
                                                            onchange="triggerRecalculation()">
                                                        {foreach $configoption.options as $option}
                                                            <option value="{$option.id}" 
                                                                    {if $configoption.selectedvalue eq $option.id}selected{/if}>
                                                                {$option.name}
                                                            </option>
                                                        {/foreach}
                                                    </select>
                                                    
                                                {elseif $configoption.optiontype eq 2}
                                                    {* Radio buttons *}
                                                    <div class="radio-options">
                                                        {foreach $configoption.options as $option}
                                                            <div class="radio-option">
                                                                <input type="radio" 
                                                                       name="configoption[{$configoption.id}]" 
                                                                       value="{$option.id}" 
                                                                       id="config{$configoption.id}_{$option.id}"
                                                                       {if $configoption.selectedvalue eq $option.id}checked{/if}
                                                                       onchange="triggerRecalculation()">
                                                                <label for="config{$configoption.id}_{$option.id}" class="radio-label">
                                                                    <span class="radio-custom"></span>
                                                                    <span class="radio-text">
                                                                        {if $option.name}{$option.name}{else}{$LANG.enable}{/if}
                                                                    </span>
                                                                </label>
                                                            </div>
                                                        {/foreach}
                                                    </div>
                                                    
                                                {elseif $configoption.optiontype eq 3}
                                                    {* Checkbox *}
                                                    <div class="checkbox-option">
                                                        <input type="checkbox" 
                                                               name="configoption[{$configoption.id}]" 
                                                               id="inputConfigOption{$configoption.id}" 
                                                               value="1" 
                                                               {if $configoption.selectedqty}checked{/if}
                                                               onchange="triggerRecalculation()">
                                                        <label for="inputConfigOption{$configoption.id}" class="checkbox-label">
                                                            <span class="checkbox-custom"></span>
                                                            <span class="checkbox-text">
                                                                {if $configoption.options.0.name}
                                                                    {$configoption.options.0.name}
                                                                {else}
                                                                    {$LANG.enable}
                                                                {/if}
                                                            </span>
                                                        </label>
                                                    </div>
                                                    
                                                {elseif $configoption.optiontype eq 4}
                                                    {* Quantity *}
                                                    <div class="quantity-option">
                                                        <div class="quantity-controls">
                                                            <button type="button" class="qty-btn qty-minus" onclick="adjustQuantity('{$configoption.id}', -1)">
                                                                <i class="fas fa-minus"></i>
                                                            </button>
                                                            <input type="number" 
                                                                   name="configoption[{$configoption.id}]" 
                                                                   value="{if $configoption.selectedqty}{$configoption.selectedqty}{else}{$configoption.qtyminimum}{/if}" 
                                                                   id="inputConfigOption{$configoption.id}" 
                                                                   min="{$configoption.qtyminimum}"
                                                                   {if $configoption.qtymaximum}max="{$configoption.qtymaximum}"{/if}
                                                                   class="form-control qty-input"
                                                                   onchange="triggerRecalculation()" 
                                                                   onkeyup="triggerRecalculation()">
                                                            <button type="button" class="qty-btn qty-plus" onclick="adjustQuantity('{$configoption.id}', 1)">
                                                                <i class="fas fa-plus"></i>
                                                            </button>
                                                        </div>
                                                        <span class="quantity-label">x {$configoption.options.0.name}</span>
                                                    </div>
                                                {/if}
                                            </div>
                                        </div>
                                    {/foreach}
                                </div>
                            </div>
                        {/if}

                        {* Campos personalizados mejorados *}
                        {if $customfields}
                            <div class="config-section">
                                <div class="section-header">
                                    <h3 class="section-title">
                                        <i class="fas fa-info-circle"></i>
                                        {$LANG.orderadditionalrequiredinfo}
                                    </h3>
                                    <p class="section-description">
                                        <i class="fas fa-asterisk required-icon"></i>
                                        {lang key='orderForm.requiredField'}
                                    </p>
                                </div>
                                
                                <div class="custom-fields-grid">
                                    {foreach $customfields as $customfield}
                                        <div class="form-group">
                                            <label for="customfield{$customfield.id}" class="modern-label">
                                                {$customfield.name} {$customfield.required}
                                            </label>
                                            {$customfield.input}
                                            {if $customfield.description}
                                                <div class="input-help">
                                                    <i class="fas fa-question-circle"></i>
                                                    {$customfield.description}
                                                </div>
                                            {/if}
                                        </div>
                                    {/foreach}
                                </div>
                            </div>
                        {/if}

                        {* Addons mejorados *}
                        {if $addons}
                            <div class="config-section">
                                <div class="section-header">
                                    <h3 class="section-title">
                                        <i class="fas fa-puzzle-piece"></i>
                                        {$LANG.cartavailableaddons}
                                    </h3>
                                    <p class="section-description">Enhance your package with these optional add-ons</p>
                                </div>
                                
                                <div class="addons-grid">
                                    {foreach $addons as $addon}
                                        <div class="addon-card {if $addon.status}addon-selected{/if}" data-addon-id="{$addon.id}">
                                            <div class="addon-header">
                                                <div class="addon-checkbox">
                                                    <input type="checkbox" 
                                                           name="addons[{$addon.id}]" 
                                                           id="addon{$addon.id}"
                                                           {if $addon.status}checked{/if}
                                                           onchange="triggerRecalculation()">
                                                    <label for="addon{$addon.id}" class="checkbox-label">
                                                        <span class="checkbox-custom"></span>
                                                    </label>
                                                </div>
                                                <div class="addon-info">
                                                    <h4 class="addon-name">{$addon.name}</h4>
                                                    <p class="addon-description">{$addon.description}</p>
                                                </div>
                                            </div>
                                            <div class="addon-footer">
                                                <div class="addon-price">{$addon.pricing}</div>
                                                <div class="addon-action">
                                                    <i class="fas fa-plus"></i>
                                                </div>
                                            </div>
                                        </div>
                                    {/foreach}
                                </div>
                            </div>
                        {/if}

                        {* Información de contacto mejorada *}
                        <div class="help-section">
                            <div class="help-card">
                                <div class="help-icon">
                                    <i class="fas fa-headset"></i>
                                </div>
                                <div class="help-content">
                                    <h4>Need Help?</h4>
                                    <p>{$LANG.orderForm.haveQuestionsContact}</p>
                                    <a href="{$WEB_ROOT}/contact.php" target="_blank" class="help-link">
                                        {$LANG.orderForm.haveQuestionsClickHere}
                                        <i class="fas fa-external-link-alt"></i>
                                    </a>
                                </div>
                            </div>
                        </div>

                    </form>
                </div>
            </div>

            {* Sidebar mejorado *}
            <div class="col-md-4">
                <div class="order-sidebar sticky-sidebar">
                    <div class="order-summary-card">
                        <div class="summary-header">
                            <h3 class="summary-title">
                                <i class="fas fa-shopping-cart"></i>
                                {$LANG.ordersummary}
                            </h3>
                            <div class="loader" id="orderSummaryLoader">
                                <i class="fas fa-sync fa-spin"></i>
                            </div>
                        </div>
                        
                        <div class="summary-content" id="producttotal">
                            {* El contenido se carga dinámicamente *}
                        </div>
                        
                        <div class="summary-actions">
                            <button type="submit" form="frmConfigureProduct" 
                                    id="btnCompleteProductConfig" 
                                    class="btn btn-primary btn-lg btn-block">
                                <span class="btn-text">{$LANG.continue}</span>
                                <i class="fas fa-arrow-right btn-icon"></i>
                            </button>
                        </div>
                    </div>
                    
                    {* Características del producto *}
                    <div class="features-card">
                        <h4 class="features-title">What's Included</h4>
                        <ul class="features-list">
                            <li><i class="fas fa-check"></i> 24/7 Support</li>
                            <li><i class="fas fa-check"></i> 99.9% Uptime</li>
                            <li><i class="fas fa-check"></i> Free SSL Certificate</li>
                            <li><i class="fas fa-check"></i> Daily Backups</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

{* CSS igual que antes - mantengo el mismo estilo *}
<style>
/* Todos los estilos CSS anteriores se mantienen igual */
.order-container {
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
    min-height: 100vh;
    padding: 2rem 0;
}

.order-content {
    background: white;
    border-radius: 16px;
    padding: 2rem;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    margin-bottom: 2rem;
}

.product-configure-header {
    text-align: center;
    margin-bottom: 3rem;
    padding-bottom: 2rem;
    border-bottom: 1px solid #e2e8f0;
}

.breadcrumb-nav {
    margin-bottom: 1rem;
}

.breadcrumb-link {
    color: #667eea;
    text-decoration: none;
    font-weight: 500;
    transition: color 0.3s ease;
}

.breadcrumb-link:hover {
    color: #5a67d8;
}

.product-title {
    font-size: 2.5rem;
    font-weight: 700;
    color: #2d3748;
    margin-bottom: 1rem;
}

.product-description {
    font-size: 1.1rem;
    color: #718096;
    max-width: 600px;
    margin: 0 auto;
}

.config-section {
    margin-bottom: 3rem;
    background: #f8f9fa;
    border-radius: 12px;
    padding: 2rem;
    border: 1px solid #e2e8f0;
}

.section-header {
    text-align: center;
    margin-bottom: 2rem;
}

.section-title {
    font-size: 1.5rem;
    font-weight: 600;
    color: #2d3748;
    margin-bottom: 0.5rem;
}

.section-title i {
    color: #667eea;
    margin-right: 0.5rem;
}

.section-description {
    color: #718096;
    font-size: 1rem;
}

/* Billing Cycles */
.billing-cycles-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 1.5rem;
}

.billing-cycle-card {
    position: relative;
}

.billing-cycle-card input[type="radio"] {
    position: absolute;
    opacity: 0;
    pointer-events: none;
}

.cycle-label {
    display: block;
    background: white;
    border: 2px solid #e2e8f0;
    border-radius: 12px;
    padding: 1.5rem;
    cursor: pointer;
    transition: all 0.3s ease;
    height: 100%;
}

.billing-cycle-card input[type="radio"]:checked + .cycle-label {
    border-color: #667eea;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.cycle-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
}

.cycle-name {
    font-size: 1.25rem;
    font-weight: 600;
}

.cycle-badge {
    background: #e2e8f0;
    color: #4a5568;
    padding: 0.25rem 0.75rem;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 500;
}

.cycle-badge.popular {
    background: #ffd700;
    color: #744210;
}

.cycle-badge.premium {
    background: #9f7aea;
    color: white;
}

.billing-cycle-card input[type="radio"]:checked + .cycle-label .cycle-badge {
    background: rgba(255, 255, 255, 0.2);
    color: white;
}

.cycle-price {
    font-size: 1.5rem;
    font-weight: 700;
    margin-bottom: 1rem;
}

.cycle-features {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    font-size: 0.9rem;
}

/* Form Controls */
.modern-label {
    display: block;
    font-weight: 600;
    color: #2d3748;
    margin-bottom: 0.5rem;
}

.modern-label i {
    color: #667eea;
    margin-right: 0.5rem;
}

.modern-input,
.modern-select {
    width: 100%;
    padding: 0.875rem 1rem;
    border: 2px solid #e2e8f0;
    border-radius: 8px;
    font-size: 1rem;
    transition: all 0.3s ease;
    background: white;
}

.modern-input:focus,
.modern-select:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.input-help {
    font-size: 0.875rem;
    color: #718096;
    margin-top: 0.5rem;
}

.password-input-wrapper {
    position: relative;
}

.password-toggle {
    position: absolute;
    right: 1rem;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    color: #718096;
    cursor: pointer;
}

/* Server Config */
.server-config-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
}

/* Configurable Options */
.configurable-options-grid {
    display: grid;
    gap: 1.5rem;
}

.config-option-card {
    background: white;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 1.5rem;
}

.option-header {
    margin-bottom: 1rem;
}

.option-name {
    font-size: 1.1rem;
    font-weight: 600;
    color: #2d3748;
    margin-bottom: 0.5rem;
}

.option-description {
    color: #718096;
    font-size: 0.9rem;
}

/* Radio Options */
.radio-options {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
}

.radio-option {
    display: flex;
    align-items: center;
}

.radio-option input[type="radio"] {
    position: absolute;
    opacity: 0;
    pointer-events: none;
}

.radio-label {
    display: flex;
    align-items: center;
    cursor: pointer;
    width: 100%;
}

.radio-custom {
    width: 20px;
    height: 20px;
    border: 2px solid #e2e8f0;
    border-radius: 50%;
    margin-right: 0.75rem;
    position: relative;
    transition: all 0.3s ease;
}

.radio-option input[type="radio"]:checked + .radio-label .radio-custom {
    border-color: #667eea;
    background: #667eea;
}

.radio-option input[type="radio"]:checked + .radio-label .radio-custom::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 8px;
    height: 8px;
    background: white;
    border-radius: 50%;
}

/* Checkbox Options */
.checkbox-option {
    display: flex;
    align-items: center;
}

.checkbox-option input[type="checkbox"] {
    position: absolute;
    opacity: 0;
    pointer-events: none;
}

.checkbox-label {
    display: flex;
    align-items: center;
    cursor: pointer;
}

.checkbox-custom {
    width: 20px;
    height: 20px;
    border: 2px solid #e2e8f0;
    border-radius: 4px;
    margin-right: 0.75rem;
    position: relative;
    transition: all 0.3s ease;
}

.checkbox-option input[type="checkbox"]:checked + .checkbox-label .checkbox-custom {
    border-color: #667eea;
    background: #667eea;
}

.checkbox-option input[type="checkbox"]:checked + .checkbox-label .checkbox-custom::after {
    content: '✓';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    color: white;
    font-size: 12px;
    font-weight: bold;
}

/* Quantity Controls */
.quantity-option {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.quantity-controls {
    display: flex;
    align-items: center;
    background: white;
    border: 2px solid #e2e8f0;
    border-radius: 8px;
    overflow: hidden;
}

.qty-btn {
    background: #f7fafc;
    border: none;
    padding: 0.75rem;
    cursor: pointer;
    transition: background 0.3s ease;
    color: #4a5568;
}

.qty-btn:hover {
    background: #edf2f7;
}

.qty-input {
    border: none;
    text-align: center;
    font-weight: 600;
    flex: 1;
    padding: 0.75rem 0.5rem;
}

.qty-input:focus {
    outline: none;
}

.quantity-label {
    color: #718096;
    font-size: 0.9rem;
}

/* Addons */
.addons-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 1.5rem;
}

.addon-card {
    background: white;
    border: 2px solid #e2e8f0;
    border-radius: 12px;
    padding: 1.5rem;
    transition: all 0.3s ease;
    cursor: pointer;
}

.addon-card:hover {
    border-color: #667eea;
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.addon-card.addon-selected {
    border-color: #667eea;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.addon-header {
    display: flex;
    align-items: flex-start;
    gap: 1rem;
    margin-bottom: 1rem;
}

.addon-checkbox input[type="checkbox"] {
    position: absolute;
    opacity: 0;
    pointer-events: none;
}

.addon-name {
    font-size: 1.1rem;
    font-weight: 600;
    margin-bottom: 0.5rem;
}

.addon-description {
    font-size: 0.9rem;
    opacity: 0.8;
}

.addon-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.addon-price {
    font-weight: 700;
    font-size: 1.1rem;
}

.addon-action {
    width: 32px;
    height: 32px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}

/* Help Section */
.help-section {
    margin-top: 2rem;
}

.help-card {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 12px;
    padding: 1.5rem;
    display: flex;
    align-items: center;
    gap: 1rem;
}

.help-icon {
    font-size: 2rem;
    opacity: 0.8;
}

.help-content h4 {
    margin-bottom: 0.5rem;
}

.help-link {
    color: white;
    text-decoration: none;
    font-weight: 500;
}

.help-link:hover {
    color: #f7fafc;
}

/* Sidebar */
.sticky-sidebar {
    position: sticky;
    top: 2rem;
}

.order-summary-card {
    background: white;
    border-radius: 16px;
    padding: 2rem;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    margin-bottom: 2rem;
}

.summary-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #e2e8f0;
}

.summary-title {
    font-size: 1.25rem;
    font-weight: 600;
    color: #2d3748;
}

.summary-title i {
    color: #667eea;
    margin-right: 0.5rem;
}

.summary-actions {
    margin-top: 1.5rem;
    padding-top: 1.5rem;
    border-top: 1px solid #e2e8f0;
}

.btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    color: white;
    padding: 1rem 2rem;
    border-radius: 8px;
    font-weight: 600;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.features-card {
    background: white;
    border-radius: 16px;
    padding: 1.5rem;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.features-title {
    font-size: 1.1rem;
    font-weight: 600;
    color: #2d3748;
    margin-bottom: 1rem;
}

.features-list {
    list-style: none;
    padding: 0;
    margin: 0;
}

.features-list li {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.5rem 0;
    color: #4a5568;
}

.features-list i {
    color: #38a169;
    font-size: 0.9rem;
}

/* Alerts */
.modern-alert {
    display: flex;
    align-items: flex-start;
    gap: 1rem;
    padding: 1rem;
    border-radius: 8px;
    margin-bottom: 2rem;
}

.alert-icon {
    font-size: 1.25rem;
}

.alert-content h4 {
    margin-bottom: 0.5rem;
}

/* Responsive */
@media (max-width: 768px) {
    .order-content {
        padding: 1rem;
    }
    
    .product-title {
        font-size: 2rem;
    }
    
    .billing-cycles-grid {
        grid-template-columns: 1fr;
    }
    
    .server-config-grid {
        grid-template-columns: 1fr;
    }
    
    .addons-grid {
        grid-template-columns: 1fr;
    }
    
    .help-card {
        flex-direction: column;
        text-align: center;
    }
    
    .sticky-sidebar {
        position: static;
        margin-top: 2rem;
    }
}

/* Utilities */
.w-hidden {
    display: none !important;
}

.required-icon {
    color: #e53e3e;
    font-size: 0.7rem;
}
</style>

<script>
// JavaScript corregido sin bucle infinito
let recalcTimeout = null;

// Función segura para recalcular totales
function triggerRecalculation() {
    // Limpiar timeout anterior si existe
    if (recalcTimeout) {
        clearTimeout(recalcTimeout);
    }
    
    // Establecer un pequeño delay para evitar múltiples llamadas
    recalcTimeout = setTimeout(function() {
        // Verificar si la función global de WHMCS existe
        if (typeof window.recalctotals === 'function') {
            try {
                window.recalctotals();
            } catch (error) {
                console.log('Error al recalcular totales:', error);
            }
        } else {
            console.log('Función recalctotals no disponible');
        }
        recalcTimeout = null;
    }, 300);
}

function togglePassword(inputId) {
    const input = document.getElementById(inputId);
    const button = input.nextElementSibling;
    const icon = button.querySelector('i');
    
    if (input.type === 'password') {
        input.type = 'text';
        icon.className = 'fas fa-eye-slash';
    } else {
        input.type = 'password';
        icon.className = 'fas fa-eye';
    }
}

function adjustQuantity(optionId, change) {
    const input = document.getElementById('inputConfigOption' + optionId);
    const currentValue = parseInt(input.value) || 0;
    const newValue = Math.max(parseInt(input.min) || 0, currentValue + change);
    
    if (input.max && newValue > parseInt(input.max)) {
        return;
    }
    
    input.value = newValue;
    triggerRecalculation();
}

// Mejorar la experiencia de los addons
document.addEventListener('DOMContentLoaded', function() {
    const addonCards = document.querySelectorAll('.addon-card');
    
    addonCards.forEach(card => {
        card.addEventListener('click', function(e) {
            // Evitar que el click en el checkbox dispare el evento dos veces
            if (e.target.type === 'checkbox') {
                return;
            }
            
            const checkbox = this.querySelector('input[type="checkbox"]');
            checkbox.checked = !checkbox.checked;
            
            if (checkbox.checked) {
                this.classList.add('addon-selected');
            } else {
                this.classList.remove('addon-selected');
            }
            
            triggerRecalculation();
        });
    });
    
    // Llamar a recalcular totales al cargar la página
    triggerRecalculation();
});
</script>