$(document).ready(function () {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AddinLoaded', null);
});

function Initialize() {
    var text = '<div id="container">\
            <div id="button1">\
            </div>\
            <div id="button2">\
            </div>\
            <div>\
            <p><b>idyn BV</b><br>\
            Binnen 1<br>\
            4271 BV<br>\
            Dussen</p>\
            </div>\
            </div>';
    $("#controlAddIn").append(text);
}

function addButton(buttonName) {
    var placeholder = document.getElementById('button1');
    var button = document.createElement('button');

    button.textContent = buttonName;
    button.onclick = function () {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ButtonPressed', null);
    }

    placeholder.appendChild(button);
}

function addButton2(buttonName) {
    var placeholder = document.getElementById('button2');
    var button = document.createElement('button');

    button.textContent = buttonName;
    button.onclick = function () {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ButtonPressed2', null);
    }

    placeholder.appendChild(button);
} 