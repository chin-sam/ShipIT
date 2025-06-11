controladdin "IDYS Code Viewer"
{
    VerticalStretch = true;
    HorizontalStretch = true;
    MinimumHeight = 350;
    RequestedHeight = 350;

    Scripts = 'https://code.jquery.com/jquery-1.9.1.min.js',
              'Addins/CodeViewer/js/codemirror.js',
              'Addins/CodeViewer/js/script.js',
              'Addins/CodeViewer/js/vkbeautify.js';

    StyleSheets = 'Addins/CodeViewer/css/codemirror.css',
                  'Addins/CodeViewer/css/htmleditor.css',
                  'Addins/CodeViewer/css/style.css';

    internal procedure LoadData(Data: Text);

    event AddinLoaded();
}