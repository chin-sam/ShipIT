var map;
var directionsManager;

$(document).ready(function () {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AddinLoaded', null);
});

function InitializeMap(origin, destination, Credentials) {
    try {
        map = new Microsoft.Maps.Map('#controlAddIn', { credentials: Credentials, showZoomButtons: false });
        Microsoft.Maps.loadModule('Microsoft.Maps.Directions', function () {
            directionsManager = new Microsoft.Maps.Directions.DirectionsManager(map);

            var originWaypoint = new Microsoft.Maps.Directions.Waypoint({ address: origin });
            directionsManager.addWaypoint(originWaypoint);

            var destinationWaypoint = new Microsoft.Maps.Directions.Waypoint({ address: destination });
            directionsManager.addWaypoint(destinationWaypoint);

            directionsManager.calculateDirections();
        });
    }
    catch (err) {
        document.getElementById("controlAddIn").innerHTML = 'Error: could not load the map.';
    }
}