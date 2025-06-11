codeunit 11147680 "IDYS Http Helper"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by App Management app';
    //ObsoleteTag = '19.7';

    procedure Execute(var Parameters: Record "IDYS REST Parameters" temporary; IDYSSetup: Record "IDYS Setup"; API: Enum "IDYS API"): Integer
    var
        Base64Convert: Codeunit "Base64 Convert";
        IDYSHttpClient: HttpClient;
        IDYSHttpHeaders: HttpHeaders;
        IDYSHttpRequestMessage: HttpRequestMessage;
        IDYSHttpResponseMessage: HttpResponseMessage;
        IDYSHttpContent: HttpContent;
        ContentHttpHeaders: HttpHeaders;
        BasicTxt: Label 'Basic %1', Locked = true;
        BearerTxt: Label 'Bearer %1', Locked = true;
        UserPasswordTxt: Label '%1:%2', Locked = true;
    begin

        case Parameters.RestMethod of
            Parameters.RestMethod::GET:
                IDYSHttpRequestMessage.Method := 'GET'; //translation indepedent
            Parameters.RestMethod::PATCH:
                IDYSHttpRequestMessage.Method := 'PATCH';
            Parameters.RestMethod::DELETE:
                IDYSHttpRequestMessage.Method := 'DELETE';
            Parameters.RestMethod::POST:
                IDYSHttpRequestMessage.Method := 'POST';
            Parameters.RestMethod::PUT:
                IDYSHttpRequestMessage.Method := 'PUT';
        end;

        IDYSHttpRequestMessage.SetRequestUri(CreateUri(Parameters.Path, IDYSSetup, API));
        IDYSHttpRequestMessage.GetHeaders(IDYSHttpHeaders);

        if Parameters.Accept <> '' then
            IDYSHttpHeaders.Add('Accept', Parameters.Accept);

        if Parameters.Username <> '' then
            IDYSHttpHeaders.Add('Authorization', StrSubstNo(BasicTxt, Base64Convert.ToBase64(StrSubstNo(UserPasswordTxt, Parameters.Username, Parameters.Password))));

        if Parameters.GetJWTToken() <> '' then
            IDYSHttpHeaders.Add('Authorization', StrSubstNo(BearerTxt, Parameters.GetJWTToken()));

        if Parameters.HasRequestContent() then begin
            Parameters.GetRequestContent(IDYSHttpContent);

            IDYSHttpContent.GetHeaders(ContentHttpHeaders);
            if ContentHttpHeaders.Contains('Content-Type') then
                ContentHttpHeaders.Remove('Content-Type');
            ContentHttpHeaders.Add('Content-Type', 'application/json');

            IDYSHttpRequestMessage.Content := IDYSHttpContent;
        end;

        IDYSHttpClient.Send(IDYSHttpRequestMessage, IDYSHttpResponseMessage);

        IDYSHttpHeaders := IDYSHttpResponseMessage.Headers();
        Parameters.SetResponseHeaders(IDYSHttpHeaders);

        IDYSHttpContent := IDYSHttpResponseMessage.Content();
        Parameters.SetResponseContent(IDYSHttpContent);

        Parameters."Status Code" := IDYSHttpResponseMessage.HttpStatusCode();
    end;

    procedure ExecuteGet(Path: Text; ExpectArray: Boolean; IDYSSetup: Record "IDYS Setup"; var TempIDYSRESTParameters: Record "IDYS REST Parameters"; var ErrorCode: Enum "IDYS Error Codes"; API: Enum "IDYS API"): Boolean
    var
        IDYSTokenStore: Codeunit "IDYS Token Store";
    begin
        if IDYSSetup."Unit Test Mode" then
            exit(true);

        TempIDYSRESTParameters.Init();
        TempIDYSRESTParameters.Path := CopyStr(Path, 1, 250);
        TempIDYSRESTParameters.RestMethod := TempIDYSRESTParameters.RestMethod::GET;
        TempIDYSRESTParameters.SetJWTToken(IDYSTokenStore.GetToken());

        Execute(TempIDYSRESTParameters, IDYSSetup, API);
        if TempIDYSRESTParameters."Status Code" <> 200 then begin
            if TempIDYSRESTParameters."Status Code" = 403 then
                ErrorCode := ErrorCode::TranssmartCode;
            if TempIDYSRESTParameters."Status Code" = 401 then
                ErrorCode := ErrorCode::Credentials;

            exit(false);
        end;

        exit(true);
    end;

    procedure ExecutePost(Path: Text; ExpectArray: Boolean; IDYSSetup: Record "IDYS Setup"; var TempIDYSRESTParameters: Record "IDYS REST Parameters"; API: Enum "IDYS API")
    var
        IDYSTokenStore: Codeunit "IDYS Token Store";
        Response: JsonToken;
        NonArrayErr: Label 'Unexpected response from the nShift Transsmart API V2. The response was not an array.';
    begin
        TempIDYSRESTParameters.Init();
        TempIDYSRESTParameters.Path := CopyStr(Path, 1, 250);
        TempIDYSRESTParameters.RestMethod := TempIDYSRESTParameters.RestMethod::POST;
        if API = API::Transsmart then
            TempIDYSRESTParameters.SetJWTToken(IDYSTokenStore.GetToken());

        Execute(TempIDYSRESTParameters, IDYSSetup, API);

        if ExpectArray and (TempIDYSRESTParameters."Status Code" = 200) then begin
            Response := TempIDYSRESTParameters.GetResponseBodyAsJSON();
            if not Response.IsArray() then
                Error(NonArrayErr);
        end;
    end;

    procedure ExecuteDelete(Path: Text; IDYSSetup: Record "IDYS Setup"; var TempIDYSRESTParameters: Record "IDYS REST Parameters"; API: Enum "IDYS API")
    var
        IDYSTokenStore: Codeunit "IDYS Token Store";
    begin
        TempIDYSRESTParameters.Init();
        TempIDYSRESTParameters.Path := CopyStr(Path, 1, 250);
        TempIDYSRESTParameters.RestMethod := TempIDYSRESTParameters.RestMethod::DELETE;
        TempIDYSRESTParameters.SetJWTToken(IDYSTokenStore.GetToken());

        Execute(TempIDYSRESTParameters, IDYSSetup, API);
    end;

    local procedure CreateUri(Path: Text; IDYSSetup: Record "IDYS Setup"; API: Enum "IDYS API"): Text
    begin
        if StrPos(Path, '/') < 1 then
            Path := '/' + Path;

        if API = API::Transsmart then
            if IDYSSetup."Transsmart Environment" = IDYSSetup."Transsmart Environment"::Production then
                exit('https://api.transsmart.com' + Path)
            else
                exit('https://accept-api.transsmart.com' + Path);

        if API = API::idynFunctions then
            exit('http://idynfunctions.azurewebsites.net/api' + Path);
    end;
}