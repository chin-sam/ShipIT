controladdin "IDYS Azure Map Addin"
{
    StyleSheets = 'https://atlas.microsoft.com/sdk/javascript/mapcontrol/3/atlas.min.css';
    Scripts = 'https://atlas.microsoft.com/sdk/javascript/mapcontrol/3/atlas.min.js',
              'https://code.jquery.com/jquery-3.6.0.min.js',
              'Addins/Map/js/AzureMapAddin.js';

    RequestedHeight = 300;
    RequestedWidth = 300;
    MinimumHeight = 250;
    MinimumWidth = 250;
    MaximumHeight = 500;
    MaximumWidth = 500;
    VerticalShrink = true;
    HorizontalShrink = true;
    VerticalStretch = true;
    HorizontalStretch = true;

    event AddinLoaded();

    procedure InitializeMap(Origin: Text; Destination: Text; Credentials: Text);
}