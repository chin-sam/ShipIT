controladdin "IDYS Setup Wizard 02 Addin"
{
    RequestedHeight = 120;
    RequestedWidth = 450;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalShrink = true;
    HorizontalStretch = true;
    Scripts = 'https://code.jquery.com/jquery-1.9.1.min.js',
              'Addins/SetupWizard/js/SetupWizard02Addin.js';
    StyleSheets = 'Addins/SetupWizard/css/style2.css';
    Images = 'Addins/SetupWizard/LogoBanner.png';

    event AddinLoaded();

    procedure Initialize();
}