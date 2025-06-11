controladdin "IDYS Map Addin"
{
    Scripts = 'https://code.jquery.com/jquery-1.9.1.min.js',
              'https://www.bing.com/api/maps/mapcontrol',
              'Addins/Map/js/MapAddin.js';

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

    //NOTE - Obsolete
    //[Obsolete('Added parameter', '19.7')]
    procedure Initialize(Origin: Text; Destination: Text);
    procedure InitializeMap(Origin: Text; Destination: Text; Credentials: Text);
}