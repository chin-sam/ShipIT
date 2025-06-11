controladdin "IDYS Setup Wizard 01 Addin"
{
    RequestedHeight = 60;
    RequestedWidth = 480;
    //VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = false;
    Scripts = 'https://code.jquery.com/jquery-1.9.1.min.js',
              'Addins/SetupWizard/js/SetupWizard01Addin.js';
    StyleSheets = 'Addins/SetupWizard/css/style.css';

    event AddinLoaded();

    procedure Initialize();

    procedure addButton(ButtonName: Text);

    event ButtonPressed();
}