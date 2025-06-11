$(document).ready(function () {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AddinLoaded', null);
});

function Initialize() {
    var ImageURL = Microsoft.Dynamics.NAV.GetImageResource('Addins/SetupWizard/LogoBanner.png');
    var Image = "<div><img src='" + ImageURL + "' /></div>";
    $("#controlAddIn").append(Image);
} 