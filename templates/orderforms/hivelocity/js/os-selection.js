/**
 * OS Selection and Configuration JavaScript for WHMCS Order Forms
 * For Hivelocity VPS and Dedicated Servers
 */

const $ = window.jQuery // Declare the $ variable

$(document).ready(() => {
  // OS Selection
  initOsSelection()

  // RAID Selection
  initRaidSelection()

  // Datacenter Selection
  initDatacenterSelection()

  // Resource Sliders
  initResourceSliders()

  // Form Validation
  initFormValidation()
})

/**
 * Initialize OS Selection functionality
 */
function initOsSelection() {
  // Click handler for OS options
  $(".os-option").click(function () {
    // Remove selected class from all options
    $(".os-option").removeClass("selected")

    // Add selected class to clicked option
    $(this).addClass("selected")

    // Check the radio button
    $(this).find('input[type="radio"]').prop("checked", true)

    // Trigger change event for any dependent fields
    $(this).find('input[type="radio"]').trigger("change")

    // Add animation effect
    $(this).addClass("pulse-animation")
    setTimeout(() => {
      $(".os-option").removeClass("pulse-animation")
    }, 500)
  })

  // Handle OS change events
  $('input[name^="configoption"][type="radio"]').change(function () {
    var selectedOS = $(this).closest(".os-option").data("os")

    // Show/hide OS-specific options
    toggleOsSpecificOptions(selectedOS)
  })

  // Initialize with currently selected OS
  var initialSelectedOS = $(".os-option.selected").data("os")
  if (initialSelectedOS) {
    toggleOsSpecificOptions(initialSelectedOS)
  }
}

/**
 * Toggle visibility of OS-specific configuration options
 */
function toggleOsSpecificOptions(osType) {
  // Hide all OS-specific option containers
  $(".os-specific-options").hide()

  // Show the container for the selected OS
  $("#" + osType + "-options").show()

  // Special handling for different OS types
  if (osType === "windows") {
    // Windows might need additional license options
    $(".windows-license-options").show()
  } else {
    $(".windows-license-options").hide()
  }

  if (osType === "esxi" || osType === "proxmox") {
    // Virtualization platforms might need special network config
    $(".virtualization-options").show()
  } else {
    $(".virtualization-options").hide()
  }
}

/**
 * Initialize RAID Selection functionality
 */
function initRaidSelection() {
  $(".raid-option").click(function () {
    // Remove selected class from all options
    $(".raid-option").removeClass("selected")

    // Add selected class to clicked option
    $(this).addClass("selected")

    // Check the radio button
    $(this).find('input[type="radio"]').prop("checked", true)

    // Add animation effect
    $(this).addClass("pulse-animation")
    setTimeout(() => {
      $(".raid-option").removeClass("pulse-animation")
    }, 500)
  })
}

/**
 * Initialize Datacenter Selection functionality
 */
function initDatacenterSelection() {
  $(".datacenter-option").click(function () {
    // Remove selected class from all options
    $(".datacenter-option").removeClass("selected")

    // Add selected class to clicked option
    $(this).addClass("selected")

    // Check the radio button
    $(this).find('input[type="radio"]').prop("checked", true)

    // Add animation effect
    $(this).addClass("pulse-animation")
    setTimeout(() => {
      $(".datacenter-option").removeClass("pulse-animation")
    }, 500)
  })
}

/**
 * Initialize Resource Sliders for VPS configuration
 */
function initResourceSliders() {
  $(".resource-slider").on("input", function () {
    var sliderId = $(this).attr("id")
    var valueId = sliderId.replace("slider", "value")
    var resourceType = $(this).data("resource")
    var value = $(this).val()

    // Update the displayed value
    if (resourceType === "cpu-cores") {
      $("#" + valueId).text(value + (value == 1 ? " Core" : " Cores"))
    } else if (resourceType === "ram" || resourceType === "ssd-storage") {
      $("#" + valueId).text(value + " GB")
    } else {
      $("#" + valueId).text(value)
    }

    // Update price calculation
    updatePriceCalculation()
  })

  // Initialize sliders with default values
  $(".resource-slider").each(function () {
    $(this).trigger("input")
  })
}

/**
 * Update price calculation based on selected options
 */
function updatePriceCalculation() {
  // This function would typically make an AJAX call to the server
  // to get updated pricing based on the selected configuration

  // For demonstration, we'll use a simple calculation
  var cpuValue = $("#slider-cpu").val() || 0
  var ramValue = $("#slider-ram").val() || 0
  var diskValue = $("#slider-storage").val() || 0

  // Base price calculation
  var basePrice = cpuValue * 5 + ramValue * 3 + diskValue * 0.1

  // Get selected billing cycle
  var billingCycle = $('input[name="billingcycle"]:checked').val() || "monthly"
  var discount = 0

  // Apply discount based on billing cycle
  if (billingCycle === "quarterly") {
    discount = 0.05 // 5% discount
  } else if (billingCycle === "semiannually") {
    discount = 0.1 // 10% discount
  } else if (billingCycle === "annually") {
    discount = 0.15 // 15% discount
  }

  // Calculate final price
  var finalPrice = basePrice * (1 - discount)

  // Update price display
  $(".config-price").text("$" + finalPrice.toFixed(2))
}

/**
 * Initialize form validation
 */
function initFormValidation() {
  $("#frmConfigureProduct").submit((e) => {
    var isValid = true
    var errorList = $("#containerProductValidationErrorsList")

    // Clear previous errors
    errorList.empty()
    $("#containerProductValidationErrors").addClass("hidden")

    // Check if OS is selected
    if (!$('input[name^="configoption"][type="radio"]:checked').length) {
      isValid = false
      errorList.append("<li>Please select an operating system</li>")
    }

    // Check if datacenter is selected (if applicable)
    if ($(".datacenter-option").length && !$(".datacenter-option.selected").length) {
      isValid = false
      errorList.append("<li>Please select a datacenter location</li>")
    }

    // Check if RAID is selected (if applicable)
    if ($(".raid-option").length && !$(".raid-option.selected").length) {
      isValid = false
      errorList.append("<li>Please select a RAID configuration</li>")
    }

    // If validation fails, show errors and prevent form submission
    if (!isValid) {
      $("#containerProductValidationErrors").removeClass("hidden")
      e.preventDefault()

      // Scroll to errors
      $("html, body").animate(
        {
          scrollTop: $("#containerProductValidationErrors").offset().top - 15,
        },
        500,
      )
    }
  })
}

/**
 * Add pulse animation effect
 */
$("<style>")
  .prop("type", "text/css")
  .html(`
        .pulse-animation {
            animation: pulse 0.5s;
        }
        
        @keyframes pulse {
            0% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
            100% {
                transform: scale(1);
            }
        }
    `)
  .appendTo("head")
