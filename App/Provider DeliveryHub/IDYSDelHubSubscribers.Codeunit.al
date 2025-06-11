codeunit 11147715 "IDYS DelHub Subscribers"
{
    #Region BearerToken
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYM HTTP Helper", 'OnGetBearerToken', '', true, false)]
    local procedure OnGetBearerToken(Endpoint: Record "IDYM Endpoint"; var BearerToken: Text; var ExpiryInMS: Integer)
    begin
        if not (Endpoint.Service In [Endpoint.Service::DeliveryHub, Endpoint.Service::DeliveryHubData]) then
            exit;
        if Endpoint."Authorization Type" <> Endpoint."Authorization Type"::Bearer then
            exit;

        GetBearerToken(BearerToken, ExpiryInMS, Endpoint);
    end;

    [NonDebuggable]
    local procedure GetBearerToken(var BearerToken: Text; var ExpiryInMS: Integer; var IDYMEndpoint: Record "IDYM Endpoint") StatusCode: Integer
    var
        TempIDYMRestParameters: Record "IDYM REST Parameters" temporary;
        IDYMHTTPHelper: Codeunit "IDYM HTTP Helper";
        TypeHelper: Codeunit "Type Helper";
        ContentTxt: Label 'grant_type=client_credentials&client_id=%1&client_secret=%2', Locked = true;
        ClientId: Text;
        ClientSecret: Text;
    begin
        LoadSetup();
        IDYMEndpoint.Get(IDYMEndpoint.Service, IDYMEndpoint.Usage::GetToken);

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
        TempIDYMRESTParameters."Acceptance Environment" := IDYSDeliveryHubSetup."Transsmart Environment" = IDYSDeliveryHubSetup."Transsmart Environment"::Acceptance;
        TempIDYMRESTParameters."Content-Type" := 'application/x-www-form-urlencoded';
        ClientId := IDYMEndpoint."API Key Name";
        ClientSecret := IDYMEndpoint.GetApiKeyValue();

        TempIDYMRESTParameters.SetRequestContent(StrSubstNo(ContentTxt, TypeHelper.UrlEncode(ClientId), TypeHelper.UrlEncode(ClientSecret)));
        StatusCode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, IDYMEndpoint.Service, "IDYM Endpoint Usage"::GetToken);

        ProcessBearerTokenResponse(TempIDYMRestParameters, BearerToken, ExpiryInMS);
    end;

    local procedure ProcessBearerTokenResponse(var TempIDYMRestParameters: Record "IDYM REST Parameters" temporary; var BearerToken: Text; var ExpiryInMS: Integer): Boolean
    var
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        Response: JsonToken;
        BearerTokenErr: Label 'Retrieving the Bearer token failed with HTTP Status %1', Comment = '%1 = HTTP Status Code';
    begin
        if TempIDYMRestParameters."Status Code" <> 200 then
            Error(BearerTokenErr, TempIDYMRestParameters."Status Code");
        if TempIDYMRESTParameters.HasResponseContent() then begin
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();
            BearerToken := IDYMJSONHelper.GetTextValue(Response.AsObject(), 'access_token');
            ExpiryInMS := IDYMJSONHelper.GetIntegerValue(Response.AsObject(), 'expires_in');
        end;
        exit(true);
    end;
    #EndRegion


    local procedure LoadSetup()
    begin
        IDYSDeliveryHubSetup.GetProviderSetup("IDYS Provider"::"Delivery Hub");
        IDYSSetup.Get();
    end;

    [Obsolete('Moved to "IDYS DelHub Provider"', '25.0')]
    procedure UpdateSourceDocumentServices(SourceTable: Integer; DocumentType: Enum "IDYS Source Document Type"; DocumentNo: Code[20]; ServiceLevelCodeOther: Text[50]; CarrierEntryNo: Integer; BookingProfileEntryNo: Integer)
    var
        IDYSDelhubProvider: Codeunit "IDYS DelHub Provider";
    begin
        IDYSDelhubProvider.UpdateSourceDocumentServices(SourceTable, DocumentType, DocumentNo, ServiceLevelCodeOther, CarrierEntryNo, BookingProfileEntryNo);
    end;

    [Obsolete('Moved to "IDYS DelHub Provider"', '25.0')]
    procedure ClearSourceDocumentServices(SourceTable: Integer; DocumentType: Enum "IDYS Source Document Type"; DocumentNo: Code[20])
    var
        IDYSDelhubProvider: Codeunit "IDYS DelHub Provider";
    begin
        IDYSDelhubProvider.ClearSourceDocumentServices(SourceTable, DocumentType, DocumentNo);
    end;

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSDeliveryHubSetup: Record "IDYS Setup";
}