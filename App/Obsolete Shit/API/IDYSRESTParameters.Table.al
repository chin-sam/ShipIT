table 11147680 "IDYS REST Parameters"
{
    DataClassification = SystemMetadata;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by App Management app';
    //ObsoleteTag = '19.7';

    fields
    {
        field(1; PK; Integer)
        {
            DataClassification = SystemMetadata;
        }

        field(2; RestMethod; Option)
        {
            OptionMembers = GET,POST,DELETE,PATCH,PUT;
            DataClassification = SystemMetadata;
        }

        field(3; Path; Text[250])
        {
            DataClassification = SystemMetadata;
        }

        field(4; Accept; Text[30])
        {
            DataClassification = SystemMetadata;
        }

        field(5; "Content-Type"; Text[30])
        {
            DataClassification = SystemMetadata;
        }

        field(6; Username; text[80])
        {
            DataClassification = SystemMetadata;
        }

        field(7; Password; text[80])
        {
            DataClassification = SystemMetadata;
        }

        field(8; "Status Code"; Integer)
        {
            DataClassification = SystemMetadata;
        }

        field(100; "Response Content"; Blob)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }

    procedure SetRequestContent("Value": JsonObject)
    var
        SerializedRequest: Text;
    begin
        "Value".WriteTo(SerializedRequest);
        //Message(SerializedRequest);
        RequestContent.WriteFrom(SerializedRequest);
        RequestContentSet := true;
    end;

    procedure SetRequestContent("Value": JsonArray)
    var
        SerializedRequest: Text;
    begin
        "Value".WriteTo(SerializedRequest);
        //Message(SerializedRequest);
        RequestContent.WriteFrom(SerializedRequest);
        RequestContentSet := true;
    end;

    procedure SetRequestContent("Value": HttpContent)
    begin
        RequestContent := Value;
        RequestContentSet := true;
    end;

    procedure HasRequestContent(): Boolean
    begin
        exit(RequestContentSet);
    end;

    procedure GetRequestContent(var "Value": HttpContent)
    begin
        Value := RequestContent;
    end;

    procedure SetResponseContent("Value": HttpContent)
    var
        ContentInStream: InStream;
        ContentOutStream: OutStream;
    begin
        "Response Content".CreateInStream(ContentInStream);
        "Value".ReadAs(ContentInStream);

        "Response Content".CreateOutStream(ContentOutStream);
        CopyStream(ContentOutStream, ContentInStream);
    end;

    procedure HasResponseContent(): Boolean
    begin
        exit("Response Content".HasValue());
    end;

    procedure GetResponseContent(var "Value": HttpContent)
    var
        ContentInStream: InStream;
    begin
        "Response Content".CreateInStream(ContentInStream);
        "Value".Clear();
        "Value".WriteFrom(ContentInStream);
    end;

    procedure GetResponseBodyAsString() ReturnValue: text
    var
        ContentInStream: InStream;
        Line: Text;
    begin
        if not HasResponseContent() then
            exit;

        "Response Content".CreateInStream(ContentInStream);

        ContentInStream.ReadText(ReturnValue);

        while not ContentInStream.EOS() do begin
            ContentInStream.ReadText(Line);
            ReturnValue += Line;
        end;
    end;

    procedure GetResponseBodyAsJSON(): JsonToken
    var
        ResponseBody: Text;
        ResponseObject: JsonToken;
    begin
        if not HasResponseContent() then
            exit;

        ResponseBody := GetResponseBodyAsString();
        if not ResponseObject.ReadFrom(ResponseBody) then
            Error(ResponseBody);

        exit(ResponseObject);
    end;

    procedure GetResponseBodyAsJSONArray(): JsonArray
    var
        ResponseObject: JsonArray;
    begin
        if not HasResponseContent() then
            exit;

        ResponseObject.ReadFrom(GetResponseBodyAsString());
        exit(ResponseObject);
    end;

    procedure SetResponseHeaders(var "Value": HttpHeaders)
    begin
        ResponseHeaders := "Value";
    end;

    procedure GetResponseHeaders(var "Value": HttpHeaders)
    begin
        "Value" := ResponseHeaders;
    end;

    procedure SetJWTToken("Value": Text)
    begin
        JWTToken := "Value";
    end;

    procedure GetJWTToken(): Text
    begin
        exit(JWTToken);
    end;

    trigger OnInsert()
    begin
        if not IsTemporary() then
            Error('You cannot use this table with non-temporary records');
    end;

    var
        RequestContent: HttpContent;
        RequestContentSet: Boolean;
        ResponseHeaders: HttpHeaders;
        JWTToken: Text;
}