table 11147662 "IDYS Blob Helper"
{
    Caption = 'Blob Helper';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[1])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }

        field(2; "Blob"; Blob)
        {
            Caption = 'Blob';
            DataClassification = SystemMetadata;
        }

        field(3; "Media"; Media)
        {
            Caption = 'Media';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if not IsTemporary() then
            Error('Blob Helper can only be used in a temporary context.');
    end;

    [Obsolete('Unused')]
    procedure SetMediaFromBlob(FileName: Text)
    var
        IDYSInStream: InStream;
    begin
        CalcFields("Blob");
        "Blob".CreateInStream(IDYSInStream);
        Media.ImportStream(IDYSInStream, FileName);
    end;

    [Obsolete('Unused')]
    procedure FromBase64String(Input: Text; FileName: Text);
    var
        Base64Convert: Codeunit "Base64 Convert";
        IDYSOutStream: OutStream;
        IDYSInStream: InStream;
    begin
        "Blob".CreateOutStream(IDYSOutStream);
        Base64Convert.FromBase64(Input, IDYSOutStream);

        if FileName <> '' then begin
            "Blob".CreateInStream(IDYSInStream);
            Media.ImportStream(IDYSInStream, FileName);
        end;
    end;

    [Obsolete('Unused')]
    procedure BlobToBase64String(): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        IDYSInStream: InStream;
    begin
        if Insert(true) then;

        CalcFields("Blob");
        "Blob".CreateInStream(IDYSInStream);
        exit(Base64Convert.ToBase64(IDYSInStream));
    end;

    [Obsolete('Unused')]
    procedure ToBase64String(): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        IDYSOutStream: OutStream;
        IDYSInStream: InStream;
    begin
        if Insert(true) then;

        if Media.HasValue() then begin
            "Blob".CreateOutStream(IDYSOutStream);
            Media.ExportStream(IDYSOutStream);
            "Blob".CreateInStream(IDYSInStream);
            exit(Base64Convert.ToBase64(IDYSInStream));
        end;
    end;

    [Obsolete('Unused')]
    procedure TryDownloadFromUrl(Url: Text): Boolean
    var
        DownloadHttpClient: HttpClient;
        DownloadHttpResponseMessage: HttpResponseMessage;
        DownloadInStream: InStream;
        DownloadOutStream: OutStream;
    begin
        if Insert(true) then;

        if DownloadHttpClient.Get(Url, DownloadHttpResponseMessage) then
            if DownloadHttpResponseMessage.IsSuccessStatusCode() then begin
                DownloadHttpResponseMessage.Content().ReadAs(DownloadInStream);
                "Blob".CreateOutStream(DownloadOutStream);
                CopyStream(DownloadOutStream, DownloadInStream);

                Media.ImportStream(DownloadInStream, 'thumbnail.jpg');
                exit(true);
            end;

        exit(false);
    end;

    procedure ReadAsText(): Text
    var
        Output: Text;
        TextInStream: InStream;
    begin
        if Insert(true) then;

        CalcFields("Blob");
        "Blob".CreateInStream(TextInStream);
        TextInStream.ReadText(Output);
        exit(Output);
    end;

    procedure WriteAsText(Input: Text)
    var
        TextOutStream: OutStream;
    begin
        "Blob".CreateOutStream(TextOutStream);
        TextOutStream.WriteText(Input);
    end;
}