$(document).ready(function () {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AddinLoaded', null);
});


function Initialize(LanguageID) {
    var Text = '';
    switch (LanguageID) {
        case 1043: //NL-Nederland
            Text = '<div id="container">\
            <p><b>U heeft de initiele ShipIT setup afgerond!</b></p>\
            <p>Vergeet niet om:</p>\
            <p> + Indien van toepassing extra velden in de setup kaart te wijzigen en/of vullen.</p>\
            <p> + Vervoerders te koppelen, en per vervoerder ook de services.</p>\
            <p> + Verzendwijzen te koppelen.</p>\
            <p><b>Happy shipping!</b></p>\
            </div>'; 
            break;
        case 2067: //NL-België
            Text = '<div id="container">\
            <p><b>U heeft de initiele ShipIT setup afgerond!</b></p>\
            <p>Vergeet niet om:</p>\
            <p> + Indien van toepassing extra velden in de setup kaart te wijzigen en/of vullen.</p>\
            <p> + Vervoerders te koppelen, en per vervoerder ook de services.</p>\
            <p> + Verzendwijzen te koppelen.</p>\
            <p><b>Happy shipping!</b></p>\
            </div>'; 
            break;
        case 2060: //FR-België
            break;
        case 3084: //FR-Cananda
            break;
        case 1036: //FR-Frankrijk
            break;
        case 4108: //FR-Zwitserland
            break;
        case 3079: //DE-Oostenrijk
            break;
        case 1031: //DE-Duitsland
            break;
        case 4103: //DE-Luxemburg
            break;
        case 2055: //DE-Zwitserland
            break;
        default:
            Text = '<div id="container">\
            <p><b>You have completed the initial ShipIT Setup.</b></p>\
            <p>Please do not forget to:</p>\
            <p> + Update/populate additional fields in the ShipIT Setup and add additional users in the ShipIT User Setup, if applicable.</p>\
            <p> + Map shipping agents, and the services per shipping agent.</p>\
            <p> + Map shipping methods.</p>\
            <p><b>Happy shipping!</b></p>\
            </div>';            
    }

    $("#controlAddIn").append(Text);
}

function InitializeAddin(TextToDisplay) {
    $("#controlAddIn").append(TextToDisplay);
}