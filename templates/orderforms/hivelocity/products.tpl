{include file="orderforms/standard_cart/common.tpl"}

<div id="order-standard_cart">
    <div class="row">
        <div class="col-md-12">
            <div class="header-lined text-center mb-5">
                <h2 class="font-size-28 mb-3">
                    {if $productGroup.headline}
                        {$productGroup.headline}
                    {else}
                        {$productGroup.name}
                    {/if}
                </h2>
                {if $productGroup.tagline}
                    <p class="lead text-muted">{$productGroup.tagline}</p>
                {/if}
            </div>
            {if $errormessage}
                <div class="alert alert-danger">
                    {$errormessage}
                </div>
            {elseif !$productGroup}
                <div class="alert alert-info">
                    {lang key='orderForm.selectCategory'}
                </div>
            {/if}
        </div>

        <!-- Buscador de productos -->
        <div class="col-md-12 mb-4">
            <div class="search-box">
                <div class="form-group">
                    <input type="text" id="product-search" class="form-control form-control-lg" placeholder="{$LANG.orderForm.search}">
                </div>
            </div>
        </div>

        <div class="col-md-3">
            {include file="orderforms/standard_cart/sidebar-categories.tpl"}
        </div>

        <!-- Productos -->
        <div class="col-md-9">
            <div class="products-container">
                {foreach $products as $product}
                    <div class="product-box" data-category="{$product.gid}">
                        <div class="product-content">
                            <div class="product-header">
                                <h3>{$product.name}</h3>
                                {if $product.tagline}
                                    <p class="product-tagline">{$product.tagline}</p>
                                {/if}
                            </div>
                            <div class="product-body">
                                <div class="product-features">
                                    {if $product.featuresdesc}
                                        <div class="product-description">
                                            {$product.featuresdesc}
                                        </div>
                                    {/if}
                                    <ul class="product-feature-list">
                                        {foreach $product.features as $feature}
                                            <li><i class="fas fa-check-circle"></i> {$feature}</li>
                                        {/foreach}
                                    </ul>
                                </div>
                                <div class="product-pricing">
                                    {if $product.bid}
                                        <span class="badge badge-info">{$LANG.bundledeal}</span>
                                        {if $product.displayprice}
                                            <div class="product-price">
                                                {$product.displayprice}
                                            </div>
                                        {/if}
                                    {elseif $product.paytype eq "free"}
                                        <div class="product-price">
                                            {$LANG.orderfree}
                                        </div>
                                    {elseif $product.paytype eq "onetime"}
                                        <div class="product-price">
                                            {$product.pricing.onetime}
                                        </div>
                                        <div class="product-billing-cycle">
                                            {$LANG.orderpaymenttermonetime}
                                        </div>
                                    {elseif $product.paytype eq "recurring"}
                                        {if $product.pricing.hasconfigoptions}
                                            <div class="product-price-label">
                                                {$LANG.startingfrom}
                                            </div>
                                            <div class="product-price-amount">
                                                {$product.pricing.minprice.price}
                                            </div>
                                            <div class="product-billing-cycle">
                                                {if $product.pricing.minprice.cycle eq "monthly"}
                                                    {$LANG.orderpaymenttermmonthly}
                                                {elseif $product.pricing.minprice.cycle eq "quarterly"}
                                                    {$LANG.orderpaymenttermquarterly}
                                                {elseif $product.pricing.minprice.cycle eq "semiannually"}
                                                    {$LANG.orderpaymenttermsemiannually}
                                                {elseif $product.pricing.minprice.cycle eq "annually"}
                                                    {$LANG.orderpaymenttermannually}
                                                {elseif $product.pricing.minprice.cycle eq "biennially"}
                                                    {$LANG.orderpaymenttermbiennially}
                                                {elseif $product.pricing.minprice.cycle eq "triennially"}
                                                    {$LANG.orderpaymenttermtriennially}
                                                {/if}
                                            </div>
                                        {else}
                                            <div class="pricing-tiers">
                                                <select class="form-control billing-cycle-selector">
                                                    {if $product.pricing.monthly}
                                                        <option value="monthly">
                                                            {$product.pricing.monthly}
                                                            {$LANG.orderpaymenttermmonthly}
                                                        </option>
                                                    {/if}
                                                    {if $product.pricing.quarterly}
                                                        <option value="quarterly">
                                                            {$product.pricing.quarterly}
                                                            {$LANG.orderpaymenttermquarterly}
                                                        </option>
                                                    {/if}
                                                    {if $product.pricing.semiannually}
                                                        <option value="semiannually">
                                                            {$product.pricing.semiannually}
                                                            {$LANG.orderpaymenttermsemiannually}
                                                        </option>
                                                    {/if}
                                                    {if $product.pricing.annually}
                                                        <option value="annually">
                                                            {$product.pricing.annually}
                                                            {$LANG.orderpaymenttermannually}
                                                        </option>
                                                    {/if}
                                                    {if $product.pricing.biennially}
                                                        <option value="biennially">
                                                            {$product.pricing.biennially}
                                                            {$LANG.orderpaymenttermbiennially}
                                                        </option>
                                                    {/if}
                                                    {if $product.pricing.triennially}
                                                        <option value="triennially">
                                                            {$product.pricing.triennially}
                                                            {$LANG.orderpaymenttermtriennially}
                                                        </option>
                                                    {/if}
                                                </select>
                                            </div>
                                        {/if}
                                    {/if}
                                </div>
                            </div>
                            <div class="product-footer">
                                <div class="product-actions">
                                    <a href="{$WEB_ROOT}/cart.php?a=add&{if $product.bid}bid={$product.bid}{else}pid={$product.pid}{/if}" class="btn btn-primary btn-lg btn-block btn-order">
                                        {$LANG.ordernowbutton}
                                    </a>
                                </div>
                                {if $product.stockcontrol && $product.qty eq "0"}
                                    <div class="product-unavailable mt-3">
                                        <span class="badge badge-danger">
                                            {$LANG.outofstock}
                                        </span>
                                    </div>
                                {/if}
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>
        </div>

        <!-- Sin resultados -->
        <div class="col-md-12 no-results" style="display: none;">
            <div class="alert alert-info">
                <p class="m-0">{$LANG.orderForm.noProductsFound}</p>
            </div>
        </div>
    </div>
</div>

<style>
    /* Estilos generales */
    #order-standard_cart {
        margin-bottom: 60px;
        font-family: 'Roboto', 'Helvetica Neue', Arial, sans-serif;
    }

    .header-lined {
        margin-bottom: 40px;
        text-align: center;
    }

    .header-lined h2 {
        margin-bottom: 15px;
        font-weight: 700;
        color: #333;
        position: relative;
        display: inline-block;
    }

    .header-lined h2:after {
        content: '';
        display: block;
        width: 60px;
        height: 3px;
        background: #4a90e2;
        margin: 15px auto 0;
    }

    /* Buscador */
    .search-box {
        margin-bottom: 30px;
        box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);
    }

    .search-box .form-control {
        border-radius: 4px 0 0 4px;
        height: 50px;
        border: 1px solid #e0e0e0;
    }

    .search-box .btn {
        border-radius: 0 4px 4px 0;
        height: 50px;
        padding: 0 20px;
    }

    /* Productos */
    .products-container {
        display: flex;
        flex-wrap: wrap;
        margin: 0 -15px;
    }

    .product-box {
        width: 100%;
        padding: 0 15px;
        margin-bottom: 30px;
    }

    @media (min-width: 768px) {
        .product-box {
            width: 50%;
        }
    }

    @media (min-width: 992px) {
        .product-box {
            width: 50%;
        }
    }

    .product-content {
        border: none;
        border-radius: 8px;
        overflow: hidden;
        transition: all 0.3s ease;
        height: 100%;
        display: flex;
        flex-direction: column;
        background-color: #fff;
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
    }

    .product-content:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
    }

    .product-header {
        padding: 25px;
        background-color: #f8f9fa;
        border-bottom: 1px solid #e0e0e0;
        position: relative;
    }

    .product-header:before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 4px;
        background: linear-gradient(to right, #4a90e2, #67b8e3);
    }

    .product-header h3 {
        margin: 0 0 10px;
        font-size: 20px;
        font-weight: 700;
        color: #333;
    }

    .product-tagline {
        margin: 0;
        color: #777;
        font-size: 14px;
    }

    .product-body {
        padding: 25px;
        flex-grow: 1;
        display: flex;
        flex-direction: column;
    }

    .product-features {
        margin-bottom: 25px;
        flex-grow: 1;
    }

    .product-description {
        margin-bottom: 20px;
        color: #666;
        font-size: 14px;
        line-height: 1.6;
    }

    .product-feature-list {
        padding: 0;
        list-style: none;
        margin: 0;
    }

    .product-feature-list li {
        margin-bottom: 12px;
        font-size: 14px;
        color: #555;
        display: flex;
        align-items: flex-start;
    }

    .product-feature-list li i {
        color: #4a90e2;
        margin-right: 10px;
        font-size: 16px;
        margin-top: 2px;
    }

    .product-pricing {
        text-align: center;
        padding: 20px;
        margin: 0 -25px;
        background-color: #f8f9fa;
        border-top: 1px solid #e0e0e0;
        border-bottom: 1px solid #e0e0e0;
    }

    .product-price-label {
        font-size: 14px;
        color: #777;
        margin-bottom: 5px;
    }

    .product-price, .product-price-amount {
        font-size: 28px;
        font-weight: 700;
        color: #4a90e2;
        margin-bottom: 5px;
    }

    .product-billing-cycle {
        font-size: 14px;
        color: #777;
        margin-bottom: 10px;
    }

    .pricing-tiers {
        margin-bottom: 15px;
    }

    .billing-cycle-selector {
        max-width: 100%;
        border: 1px solid #ddd;
        border-radius: 4px;
        padding: 8px 12px;
        font-size: 14px;
    }

    .product-footer {
        padding: 25px;
        background-color: #fff;
    }

    .product-actions {
        display: flex;
        justify-content: space-between;
    }

    .btn-order {
        flex-grow: 1;
        font-weight: 600;
        letter-spacing: 0.5px;
        text-transform: uppercase;
        font-size: 14px;
        padding: 12px 20px;
        transition: all 0.3s ease;
        background-color: #4a90e2;
        border-color: #4a90e2;
    }

    .btn-order:hover {
        background-color: #3a7bc8;
        border-color: #3a7bc8;
        transform: translateY(-2px);
        box-shadow: 0 5px 10px rgba(74, 144, 226, 0.3);
    }

    .product-unavailable {
        margin-top: 15px;
        text-align: center;
    }

    .badge {
        padding: 6px 10px;
        font-weight: 500;
        font-size: 12px;
        border-radius: 4px;
    }

    .badge-info {
        background-color: #17a2b8;
    }

    .badge-danger {
        background-color: #dc3545;
    }

    /* Sin resultados */
    .no-results {
        text-align: center;
        padding: 40px 0;
    }

    /* Animaciones */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .product-box {
        animation: fadeIn 0.5s ease forwards;
        opacity: 0;
    }

    .product-box:nth-child(1) { animation-delay: 0.1s; }
    .product-box:nth-child(2) { animation-delay: 0.2s; }
    .product-box:nth-child(3) { animation-delay: 0.3s; }
    .product-box:nth-child(4) { animation-delay: 0.4s; }
    .product-box:nth-child(5) { animation-delay: 0.5s; }
    .product-box:nth-child(6) { animation-delay: 0.6s; }
</style>

<script type="text/javascript">
    $(document).ready(function() {
        // Búsqueda de productos
        $('#product-search').on('keyup', function() {
            var searchTerm = $(this).val().toLowerCase();

            if (searchTerm === '') {
                $('.product-box').show();
                $('.product-box').css('opacity', '1');
            } else {
                // Filtrar productos por término de búsqueda
                $('.product-box').hide();
                $('.product-box').each(function() {
                    var productText = $(this).text().toLowerCase();
                    if (productText.indexOf(searchTerm) !== -1) {
                        $(this).show();
                        $(this).css('opacity', '1');
                    }
                });
            }

            // Verificar si hay resultados
            checkResults();
        });

        // Cambio de ciclo de facturación
        $('.billing-cycle-selector').on('change', function() {
            var cycle = $(this).val();
            var productBox = $(this).closest('.product-box');
            
            // Efecto visual al cambiar
            var pricingSection = $(this).closest('.product-pricing');
            pricingSection.fadeOut(200).fadeIn(200);
            
            // Aquí podrías actualizar el precio mostrado si tienes los datos disponibles
            // o hacer una petición AJAX para obtener el precio actualizado
        });

        // Función para verificar si hay resultados
        function checkResults() {
            if ($('.product-box:visible').length === 0) {
                $('.no-results').fadeIn(300);
            } else {
                $('.no-results').fadeOut(300);
            }
        }

        // Inicializar
        checkResults();
        
        // Hover effect para botones
        $('.btn-order').hover(
            function() {
                $(this).addClass('pulse');
            },
            function() {
                $(this).removeClass('pulse');
            }
        );
    });
</script>