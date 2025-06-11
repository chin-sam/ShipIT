$(document).ready(function () {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AddinLoaded', null);
});

function Initialize() {
    var text = '<div id="container"></div>';
    $("#controlAddIn").append(text);
}

function addButton(buttonName) {    
    var placeholder = document.getElementById('container');        
    var button = document.createElement('button');  

    button.textContent = buttonName;        
    button.onclick = function() {        
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ButtonPressed', null);
    }
    
    placeholder.appendChild(button); 
}   