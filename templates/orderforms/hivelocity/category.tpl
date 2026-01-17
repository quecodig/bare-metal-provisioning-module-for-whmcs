{include file="orderforms/standard_cart/common.tpl"}

<div id="order-standard_cart">
    <div class="row">
        <div class="col-md-12">
            <div class="header-lined">
                <h1>{$LANG.ordercategories}</h1>
            </div>
        </div>
        <div class="col-md-12">
            <div class="categories-list">
                <div class="row">
                    {foreach from=$productgroups item=productgroup}
                        <div class="col-md-6">
                            <div class="category-box">
                                <div class="category-content">
                                    <h3 class="category-title">
                                        {if $productgroup.name|strstr:"VPS" || $productgroup.name|strstr:"Virtual Server"}
                                            <i class="fas fa-server category-icon vps-icon"></i>
                                        {elseif $productgroup.name|strstr:"Dedicated" || $productgroup.name|strstr:"Dedicated Server"}
                                            <i class="fas fa-hdd category-icon dedicated-icon"></i>
                                        {elseif $productgroup.name|strstr:"Web Hosting" || $productgroup.name|strstr:"Shared Hosting"}
                                            <i class="fas fa-globe category-icon hosting-icon"></i>
                                        {elseif $productgroup.name|strstr:"Domain" || $productgroup.name|strstr:"Domains"}
                                            <i class="fas fa-globe-americas category-icon domain-icon"></i>
                                        {else}
                                            <i class="fas fa-cube category-icon"></i>
                                        {/if}
                                        {$productgroup.name}
                                    </h3>
                                    <div class="category-description">
                                        {if $productgroup.tagline}
                                            <p>{$productgroup.tagline}</p>
                                        {/if}
                                    </div>
                                    <div class="category-features">
                                        {if $productgroup.features}
                                            <ul class="features-list">
                                                {foreach from=$productgroup.features item=feature}
                                                    <li><i class="fas fa-check-circle"></i> {$feature}</li>
                                                {/foreach}
                                            </ul>
                                        {/if}
                                    </div>
                                </div>
                                <div class="category-footer">
                                    <a href="{$WEB_ROOT}/cart.php?gid={$productgroup.gid}" class="btn btn-primary">
                                        {$LANG.ordernowbutton} <i class="fas fa-arrow-circle-right"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    {/foreach}
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    /* Category List Styling */
    .categories-list {
        margin-bottom: 30px;
    }
    
    .category-box {
        border: 1px solid #ddd;
        border-radius: 4px;
        margin-bottom: 30px;
        transition: all 0.3s ease;
        height: 100%;
        display: flex;
        flex-direction: column;
    }
    
    .category-box:hover {
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        transform: translateY(-5px);
    }
    
    .category-content {
        padding: 20px;
        flex-grow: 1;
    }
    
    .category-title {
        margin-top: 0;
        margin-bottom: 15px;
        font-size: 20px;
        font-weight: 600;
        display: flex;
        align-items: center;
    }
    
    .category-icon {
        margin-right: 10px;
        font-size: 24px;
    }
    
    .vps-icon {
        color: #2196F3;
    }
    
    .dedicated-icon {
        color: #FF9800;
    }
    
    .hosting-icon {
        color: #4CAF50;
    }
    
    .domain-icon {
        color: #9C27B0;
    }
    
    .category-description {
        color: #666;
        margin-bottom: 15px;
    }
    
    .features-list {
        padding-left: 0;
        list-style: none;
    }
    
    .features-list li {
        margin-bottom: 5px;
    }
    
    .features-list i {
        color: #4CAF50;
        margin-right: 5px;
    }
    
    .category-footer {
        padding: 15px 20px;
        border-top: 1px solid #ddd;
        background-color: #f8f8f8;
        text-align: center;
    }
</style>
