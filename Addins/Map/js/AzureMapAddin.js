// https://learn.microsoft.com/en-us/azure/azure-maps/tutorial-route-location

var map;
var datasource;

$(document).ready(function () {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AddinLoaded', null);
});

function GetDataPointFromAddress(query, subscriptionKey) {
    var url = `https://atlas.microsoft.com/search/address/json?api-version=1.0&query=${query}`;
    return fetch(url, {
        headers: {
            "Subscription-Key": subscriptionKey
        }
    })
    .then((response) => response.json())
    .then((response) => {
        if (response.results && response.results.length > 0) {
            return new atlas.data.Point([response.results[0].position.lon, response.results[0].position.lat]);
        }
    });
}

function InitializeMap(origin, destination, subscriptionKey) {
    try {
        // Initialize the map
        map = new atlas.Map('controlAddIn', {
            zoom: 10,
            style: 'road',
            language: 'en',
            view: 'Auto',
            authOptions: {
                authType: 'subscriptionKey',
                subscriptionKey: subscriptionKey
            }
        });

        map.controls.add(new atlas.control.StyleControl({
            mapStyles: ['road', 'grayscale_dark', 'night', 'road_shaded_relief', 'satellite', 'satellite_road_labels'],
            layout: 'list'
          }), {
            position: 'top-right'
          });  

        // Wait until the map resources are ready
        map.events.add('ready', function() {

            // Create a data source and add it to the map.
            datasource = new atlas.source.DataSource();
            map.sources.add(datasource);

            // Add a layer for rendering the route lines and have it render under the map labels.
            map.layers.add(new atlas.layer.LineLayer(datasource, null, {
                strokeColor: '#2272B9',
                strokeWidth: 5,
                lineJoin: 'round',
                lineCap: 'round'
            }), 'labels');

            // Add a layer for rendering point data.
            map.layers.add(new atlas.layer.SymbolLayer(datasource, null, {
                iconOptions: {
                    image: ['get', 'iconImage'],
                    allowOverlap: true
                },
                textOptions: {
                    textField: ['get', 'title'],
                    offset: [0, 1.2]
                },
                filter: ['any', ['==', ['geometry-type'], 'Point'], ['==', ['geometry-type'], 'MultiPoint']] // Only render Point or MultiPoints in this layer
            }));

            // Fetch coordinates for origin and destination
            Promise.all([
                GetDataPointFromAddress(origin, subscriptionKey),
                GetDataPointFromAddress(destination, subscriptionKey)
            ])
            .then(([originCoordinates, destinationCoordinates]) => {
                // Create start and end points
                var startPoint = new atlas.data.Feature(originCoordinates, {
                    iconImage: 'pin-round-blue'
                });

                var endPoint = new atlas.data.Feature(destinationCoordinates, {
                    iconImage: "pin-round-red"
                });

                //Add the data to the data source.
                datasource.add([startPoint, endPoint]);

                map.setCamera({
                    bounds: atlas.data.BoundingBox.fromData([startPoint, endPoint]),
                    padding: 80
                });

                var query = startPoint.geometry.coordinates[1] + "," +
                            startPoint.geometry.coordinates[0] + ":" +
                            endPoint.geometry.coordinates[1] + "," +
                            endPoint.geometry.coordinates[0];

                var url = `https://atlas.microsoft.com/route/directions/json?api-version=1.0&query=${query}`;

                // Make a search route request
                fetch(url, {
                    headers: {
                        "Subscription-Key": subscriptionKey
                    }
                })
                .then((response) => response.json())
                .then((response) => {
                    var route = response.routes[0];
                    // Create an array to store the coordinates of each turn
                    var routeCoordinates = [];
                    route.legs.forEach((leg) => {
                        var legCoordinates = leg.points.map((point) => {
                            return [point.longitude, point.latitude];
                        });
                        // Add each turn to the array
                        routeCoordinates = routeCoordinates.concat(legCoordinates);
                    });
                    // Add route line to the datasource
                    datasource.add(new atlas.data.Feature(new atlas.data.LineString(routeCoordinates)));
                });
            })
        });
    } catch (err) {
        document.getElementById("controlAddIn").innerHTML = 'Error: could not load the map.';
    }
}