controladdin "IDYS Setup Finished Addin"
{
    RequestedHeight = 300;
    RequestedWidth = 525;
    VerticalStretch = true;
    HorizontalStretch = true;
    Scripts = 'https://code.jquery.com/jquery-1.9.1.min.js',
              'Addins/SetupFinished/js/SetupFinishedAddin.js';
    StyleSheets = 'Addins/SetupFinished/css/SetupFinishedAddin.css';

    event AddinLoaded();

    //NOTE - Obsolete
    //[Obsolete('Replaced with InitializeAddin()', '19.7')]
    procedure Initialize(LanguageID: Integer);
    procedure InitializeAddin(TextToDisplay: Text);
}