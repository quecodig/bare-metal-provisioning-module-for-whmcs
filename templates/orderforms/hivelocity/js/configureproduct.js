$(document).ready(function() {
    // Función para actualizar el resumen
    function updateOrderSummary() {
        var formData = $('#frmConfigureProduct').serialize();
        $.post('cart.php?a=view', formData, function(data) {
            var summaryHtml = $(data).find('#summaryConfigurableOptions').html();
            $('#summaryConfigurableOptions').html(summaryHtml);
            
            var totalHtml = $(data).find('#totalDueToday').html();
            $('#totalDueToday').html(totalHtml);
        });
    }

    // Actualizar el resumen cuando cambie cualquier opción
    $('input[type="radio"], input[type="checkbox"], select, input[type="number"]').on('change', function() {
        updateOrderSummary();
    });

    // Actualizar el resumen cuando cambie el ciclo de facturación
    $('#inputBillingcycle').on('change', function() {
        updateOrderSummary();
    });

    // OS Selection
    $('.os-option').click(function() {
        $('.os-option').removeClass('selected');
        $(this).addClass('selected');
        $(this).find('input[type="radio"]').prop('checked', true);
        updateOrderSummary();
    });

    // RAID Selection
    $('.raid-option').click(function() {
        $('.raid-option').removeClass('selected');
        $(this).addClass('selected');
        $(this).find('input[type="radio"]').prop('checked', true);
        updateOrderSummary();
    });

    // Resource Sliders
    $('.resource-slider').on('input', function() {
        var sliderId = $(this).attr('id');
        var valueId = sliderId.replace('slider', 'value');
        var resourceType = $(this).data('resource');
        var value = $(this).val();
        
        if (resourceType === 'cpu-cores') {
            $('#' + valueId).text(value + (value == 1 ? ' Core' : ' Cores'));
        } else if (resourceType === 'ram' || resourceType === 'ssd-storage') {
            $('#' + valueId).text(value + ' GB');
        } else {
            $('#' + valueId).text(value);
        }
        
        updateOrderSummary();
    });

    // Addon Selection
    $('.panel-addon').click(function() {
        var checkbox = $(this).find('input[type="checkbox"]');
        checkbox.prop('checked', !checkbox.prop('checked'));
        $(this).toggleClass('panel-addon-selected');
        updateOrderSummary();
    });

    // Form Submission
    $('#frmConfigureProduct').on('submit', function(e) {
        e.preventDefault();
        
        // Validar campos requeridos
        var isValid = true;
        $(this).find('[required]').each(function() {
            if (!$(this).val()) {
                isValid = false;
                $(this).addClass('is-invalid');
            } else {
                $(this).removeClass('is-invalid');
            }
        });

        if (!isValid) {
            return false;
        }

        // Enviar formulario
        var formData = $(this).serialize();
        $.post('cart.php?a=add', formData, function(response) {
            if (response.success) {
                window.location.href = 'cart.php?a=view';
            } else {
                alert(response.error || 'Error al procesar la solicitud');
            }
        });
    });

    // Inicializar el resumen al cargar la página
    updateOrderSummary();
}); 