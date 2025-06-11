controladdin "IDYS Contact Addin"
{
    RequestedHeight = 210;
    RequestedWidth = 480;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    Scripts = 'https://code.jquery.com/jquery-1.9.1.min.js',
              'Addins/SetupWizard/js/ContactAddin.js';
    StyleSheets = 'Addins/SetupWizard/css/style3.css';

    event AddinLoaded();

    procedure Initialize();

    procedure addButton(ButtonName: Text);

    event ButtonPressed();

    procedure addButton2(ButtonName: Text);

    event ButtonPressed2();
}