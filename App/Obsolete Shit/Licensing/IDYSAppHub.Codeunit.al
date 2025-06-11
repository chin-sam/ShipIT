codeunit 11147689 "IDYS App Hub"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by App Management app';
    //ObsoleteTag = '19.7';

    Permissions = TableData Company = r,
                Tabledata "IDYS Setup" = r,
                Tabledata "IDYS REST Parameters" = rimd;

    procedure ExecuteHubCall(var Parameters: Record "IDYS REST Parameters" temporary): Integer
    var
        IDYSHttpClient: HttpClient;
        IDYSHttpHeaders: HttpHeaders;
        IDYSHttpRequestMessage: HttpRequestMessage;
        IDYSHttpResponseMessage: HttpResponseMessage;
        IDYSHttpContent: HttpContent;
        ContentHttpHeaders: HttpHeaders;
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
        IDYSHttpRequestMessage.SetRequestUri(CreateUri(Parameters.Path));
        IDYSHttpRequestMessage.GetHeaders(IDYSHttpHeaders);

        if Parameters.Accept <> '' then
            IDYSHttpHeaders.Add('Accept', Parameters.Accept);

        IDYSHttpHeaders.Add('appId', 'idyn');
        IDYSHttpHeaders.Add('appSecret', 'secret');

        if Parameters.HasRequestContent() then begin
            Parameters.GetRequestContent(IDYSHttpContent);

            IDYSHttpContent.GetHeaders(ContentHttpHeaders);
            if ContentHttpHeaders.Contains('Content-Type') then
                ContentHttpHeaders.Remove('Content-Type');

            if Parameters."Content-Type" <> '' then
                ContentHttpHeaders.Add('Content-Type', Parameters."Content-Type")
            else
                ContentHttpHeaders.Add('Content-Type', 'application/json');

            IDYSHttpRequestMessage.Content := IDYSHttpContent;
        end;

        IDYSHttpClient.Send(IDYSHttpRequestMessage, IDYSHttpResponseMessage);

        IDYSHttpHeaders := IDYSHttpResponseMessage.Headers();
        Parameters.SetResponseHeaders(IDYSHttpHeaders);

        IDYSHttpContent := IDYSHttpResponseMessage.Content();
        Parameters.SetResponseContent(IDYSHttpContent);

        exit(IDYSHttpResponseMessage.HttpStatusCode());
    end;

    local procedure CreateUri(Path: Text): Text
    begin
        if not Path.StartsWith('/') then
            Path := '/' + Path;

        exit('https://apphub.azurewebsites.net/api' + Path);
    end;

    procedure ParseError(Parameters: Record "IDYS REST Parameters"; var ErrorCode: Integer; var ErrorMessage: Text; VoucherCode: Text[30]; LicenseKey: Text[50]; AppId: Guid; ThrowError: Boolean)
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        ErrorObject: JsonToken;
        Msg001Err: Label 'Tenant with ID %1 could not be found.', Comment = '%1=The tenant.'; //{usage.TenantId}
        Msg002Err: Label 'Voucher %1 could not be found.', Comment = '%1=The voucher.'; //{voucherCode} 
        Msg003Err: Label 'Voucher %1 is not valid.', Comment = '%1=The voucher.'; //{voucherCode}
        Msg004Err: Label 'LicenseKey %1 could not be found.', Comment = '%1=The license key.'; //{usage.LicenseKey}
        Msg005Err: Label 'LicenseKey %1 is invalid', Comment = '%1=The license key.'; //{usage.LicenseKey}
        Msg006Err: Label 'LicenseKey %1 is disabled.', Comment = '%1=The license key.'; //{usage.LicenseKey}
        Msg007Err: Label 'LicenseKey %1 has expired.', Comment = '%1=The license key.'; //{usage.LicenseKey}
        Msg008Err: Label 'App with ID %1 could not be found.', Comment = '%1=The app id.'; //{usage.AppId}
        Msg009Err: Label 'Tenant ID and License ID cannot be empty both, please provide one of them.';
        Msg010Err: Label 'AppAction could not be found.'; //{usage.AppActionId}
        Msg011Err: Label 'Extension Setting could not be found.'; //{name} 
        Msg012Err: Label 'This license key has already been claimed.';
        Msg013Err: Label 'You have exceeded the number of allowed carriers for your license.';
    begin
        if not TryGetResponseObject(Parameters, ErrorObject) or not ErrorObject.IsObject() then
            ErrorMessage := Parameters.GetResponseBodyAsString();
        if (ErrorMessage = '') then
            if not ErrorObject.AsObject().Contains('errorCode') then
                ErrorMessage := Parameters.GetResponseBodyAsString();

        if ErrorMessage = '' then begin
            ErrorCode := IDYMJSONHelper.GetIntegerValue(ErrorObject.AsObject(), 'errorCode');

            case ErrorCode of
                1:
                    ErrorMessage := StrSubstNo(Msg001Err, AzureADTenant.GetAadTenantId());
                2:
                    ErrorMessage := StrSubstNo(Msg002Err, VoucherCode);
                3:
                    ErrorMessage := StrSubstNo(Msg003Err, VoucherCode);
                4:
                    ErrorMessage := StrSubstNo(Msg004Err, LicenseKey);
                5:
                    ErrorMessage := StrSubstNo(Msg005Err, LicenseKey);
                6:
                    ErrorMessage := StrSubstNo(Msg006Err, LicenseKey);
                7:
                    ErrorMessage := StrSubstNo(Msg007Err, LicenseKey);
                8:
                    ErrorMessage := StrSubstNo(Msg008Err, AppId);
                9:
                    ErrorMessage := Msg009Err;
                10:
                    ErrorMessage := Msg010Err;
                11:
                    ErrorMessage := Msg011Err;
                12:
                    ErrorMessage := Msg012Err;
                13:
                    ErrorMessage := Msg013Err;
            end;
        end;

        if ThrowError then
            Error(ErrorMessage);
    end;

    procedure RegisterTenant(var ErrorMessage: Text; var ErrorCode: Integer): Boolean
    var
        TempRESTParameters: Record "IDYS REST Parameters" temporary;
        AppInfo: ModuleInfo;
        TenantLbl: Label '/tenant', Locked = true;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);

        TempRESTParameters.Init();
        TempRESTParameters.RestMethod := TempRESTParameters.RestMethod::POST;
        TempRESTParameters.Path := CopyStr(StrSubstNo(TenantLbl),
                                       1, MaxStrLen(TempRESTParameters.Path));

        TempRESTParameters.SetRequestContent(MakeJSONRequestBody());

        ErrorCode := ExecuteHubCall(TempRESTParameters);
        case ErrorCode of
            200:
                begin
                    ErrorCode := 0;
                    exit(true);
                end;
            403, 500 .. 511: //license check unavailable
                begin
                    ParseError(TempRESTParameters, ErrorCode, ErrorMessage, '', '', AppInfo.Id, false);
                    exit(false);
                end;
            else begin
                //especially meant for 400 errors
                ParseError(TempRESTParameters, ErrorCode, ErrorMessage, '', '', AppInfo.Id, true);
                exit(false);
            end;
        end;
    end;

    procedure MakeJSONRequestBody(): JsonObject
    var
        CompanyInformation: Record "Company Information";
        TenantInformation: Codeunit "Tenant Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        Tenant: JsonObject;
        Company: JsonObject;
    begin
        IDYMJSONHelper.AddValue(Tenant, 'tenantId', TenantInformation.GetTenantId());
        IDYMJSONHelper.AddValue(Tenant, 'aadTenantId', AzureADTenant.GetAadTenantId());
        IDYMJSONHelper.AddValue(Tenant, 'aadTenantDomainName', AzureADTenant.GetAadTenantDomainName());
        IDYMJSONHelper.AddValue(Tenant, 'tenantDisplayName', TenantInformation.GetTenantDisplayName());
        IDYMJSONHelper.AddValue(Tenant, 'applicationFamily', EnvironmentInformation.GetApplicationFamily());
        IDYMJSONHelper.AddValue(Tenant, 'environmentName', EnvironmentInformation.GetEnvironmentName());
        IDYMJSONHelper.AddValue(Tenant, 'isProduction', EnvironmentInformation.IsProduction());
        IDYMJSONHelper.AddValue(Tenant, 'isSandbox', EnvironmentInformation.IsSandbox());
        IDYMJSONHelper.AddValue(Tenant, 'isOnPrem', EnvironmentInformation.IsOnPrem());
        IDYMJSONHelper.AddValue(Tenant, 'isSaaS', EnvironmentInformation.IsSaaS());
        IDYMJSONHelper.AddValue(Tenant, 'isFinancials', EnvironmentInformation.IsFinancials());

        if CompanyInformation.Get() then begin
            IDYMJSONHelper.AddValue(Company, 'tenantId', TenantInformation.GetTenantId());
            IDYMJSONHelper.AddValue(Company, 'Name', CompanyInformation.Name);
            IDYMJSONHelper.AddValue(Company, 'Name2', CompanyInformation."Name 2");
            IDYMJSONHelper.AddValue(Company, 'Address', CompanyInformation.Address);
            IDYMJSONHelper.AddValue(Company, 'Address2', CompanyInformation."Address 2");
            IDYMJSONHelper.AddValue(Company, 'City', CompanyInformation.City);
            IDYMJSONHelper.AddValue(Company, 'PostCode', CompanyInformation."Post Code");
            IDYMJSONHelper.AddValue(Company, 'Country', CompanyInformation."Country/Region Code");
            IDYMJSONHelper.AddValue(Company, 'PhoneNo', CompanyInformation."Phone No.");
            IDYMJSONHelper.AddValue(Company, 'Email', CompanyInformation."E-Mail");
            IDYMJSONHelper.AddValue(Company, 'Website', CompanyInformation."Home Page");
        end;
        IDYMJSONHelper.Add(Tenant, 'Company', Company);

        exit(Tenant);
    end;

    procedure ClaimVoucher(VoucherCode: Text[30]; LicenseKey: Text[50]; AppId: Guid): Boolean
    var
        TempRESTParameters: Record "IDYS REST Parameters" temporary;
        AzureADTenant: Codeunit "Azure AD Tenant";
        StatusCode: Integer;
        ErrorCode: Integer;
        ErrorMessage: Text;
        VoucherLbl: Label '/Voucher/Claim?tenantId=%1&appId=%2&voucherCode=%3', Locked = true;
    begin
        TempRESTParameters.Init();
        TempRESTParameters.RestMethod := TempRESTParameters.RestMethod::GET;
        TempRESTParameters.Path := CopyStr(StrSubstNo(VoucherLbl, AzureADTenant.GetAadTenantId(), AppId, VoucherCode),
                                       1, MaxStrLen(TempRESTParameters.Path));

        StatusCode := ExecuteHubCall(TempRESTParameters);
        if StatusCode <> 200 then begin
            ParseError(TempRESTParameters, ErrorCode, ErrorMessage, VoucherCode, LicenseKey, AppId, true);
            exit(false);
        end else
            exit(true);
    end;

    local procedure CheckLicense(LicenseKey: Text[50]; var ErrorMessage: Text; var ErrorCode: Integer; VoucherCode: Text[30]; AppId: Guid; Units: Integer; ThrowError: Boolean): Boolean
    var
        TempRESTParameters: Record "IDYS REST Parameters" temporary;
        LicenseCheckUnavailable: Notification;
        LicenseCheckLbl: Label '/LicenseKey/Check?licenseKeyCode=%1&units=%2', Locked = true;
        LicenseCheckUnavailableMsg: Label 'The service that checks the ShipIT license is currently unavailable (returned error code %1). For the coming hours the license check is suspended and shipments can be booked, but please inform Idyn to prevent that shipments cannot be booked.', Comment = '%1 = HTTP Status code';
    begin
        TempRESTParameters.Init();
        TempRESTParameters.RestMethod := TempRESTParameters.RestMethod::GET;
        TempRESTParameters.Path := CopyStr(StrSubstNo(LicenseCheckLbl, LicenseKey, Units),
                                       1, MaxStrLen(TempRESTParameters.Path));

        ErrorCode := ExecuteHubCall(TempRESTParameters);
        case ErrorCode of
            200:
                begin
                    ErrorCode := 0;
                    exit(true);
                end;
            403, 500 .. 511: //license check unavailable
                begin
                    LoadSetup();
                    ThrowError := Setup."License Grace Period Start" <> 0DT;
                    if ThrowError then
                        ThrowError := CurrentDateTime - Setup."License Grace Period Start" > 28800000; //throw error when license cannot be checked for 8 hours
                    ParseError(TempRESTParameters, ErrorCode, ErrorMessage, VoucherCode, LicenseKey, AppId, ThrowError);
                    LicenseCheckUnavailable.Scope(NotificationScope::LocalScope);
                    LicenseCheckUnavailable.Message(StrSubStNo(LicenseCheckUnavailableMsg, ErrorCode));
                    LicenseCheckUnavailable.Send();
                    exit(false);
                end;
            else begin
                //especially meant for 400 errors
                ParseError(TempRESTParameters, ErrorCode, ErrorMessage, VoucherCode, LicenseKey, AppId, ThrowError);
                exit(false);
            end;
        end;
    end;

    procedure ClaimLicense(LicenseKey: Text[50]; var ErrorMessage: Text; var ErrorCode: Integer; VoucherCode: Text[30]; AppId: Guid): Boolean
    var
        TempRESTParameters: Record "IDYS REST Parameters" temporary;
        StatusCode: Integer;
        LicenseKeyLbl: Label '/LicenseKey/Claim', Locked = true;
    begin
        TempRESTParameters.Init();
        TempRESTParameters.RestMethod := TempRESTParameters.RestMethod::POST;
        TempRESTParameters.Path := CopyStr(StrSubstNo(LicenseKeyLbl), 1, MaxStrLen(TempRESTParameters.Path));

        TempRESTParameters.SetRequestContent(CreateClaim(LicenseKey));

        StatusCode := ExecuteHubCall(TempRESTParameters);
        if StatusCode <> 200 then begin
            ParseError(TempRESTParameters, ErrorCode, ErrorMessage, VoucherCode, LicenseKey, AppId, true);
            exit(false);
        end else
            exit(true);
    end;

    procedure CreateClaim(LicenseKey: Text): JsonObject
    var
        CompanyInformation: Record "Company Information";
        LicenseClaim: JsonObject;
    begin
        if CompanyInformation.Get() then begin
            IDYMJSONHelper.AddValue(LicenseClaim, 'licenseKeyCode', LicenseKey);
            IDYMJSONHelper.AddValue(LicenseClaim, 'companyName', CompanyName());
            IDYMJSONHelper.AddValue(LicenseClaim, 'name', CompanyInformation.Name);
            IDYMJSONHelper.AddValue(LicenseClaim, 'name2', CompanyInformation."Name 2");
            IDYMJSONHelper.AddValue(LicenseClaim, 'address', CompanyInformation.Address);
            IDYMJSONHelper.AddValue(LicenseClaim, 'address2', CompanyInformation."Address 2");
            IDYMJSONHelper.AddValue(LicenseClaim, 'city', CompanyInformation.City);
            IDYMJSONHelper.AddValue(LicenseClaim, 'postCode', CompanyInformation."Post Code");
            IDYMJSONHelper.AddValue(LicenseClaim, 'country', CompanyInformation."Country/Region Code");
            IDYMJSONHelper.AddValue(LicenseClaim, 'phoneNo', CompanyInformation."Phone No.");
            IDYMJSONHelper.AddValue(LicenseClaim, 'email', CompanyInformation."E-Mail");
            IDYMJSONHelper.AddValue(LicenseClaim, 'user', UserId());
        end;

        exit(LicenseClaim);
    end;

    [Obsolete('No longer used', '22.10')]

    procedure LogUsage(Qty: Integer; var ErrorMessage: Text; var ErrorCode: Integer; ActionId: Integer): Boolean
    begin
    end;

    procedure MakeJSONRequestBody(Qty: Integer; ActionId: Integer; LicenseKey: Text[50]; AppId: Guid): JsonObject
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        Usage: JsonObject;
    begin
        if EnvironmentInformation.IsSaaS() and (AzureADTenant.GetAadTenantId() <> 'common') then
            IDYMJSONHelper.AddValue(Usage, 'tenantId', AzureADTenant.GetAadTenantId());
        if LicenseKey <> '' then
            IDYMJSONHelper.AddValue(Usage, 'licenseKey', LicenseKey);
        IDYMJSONHelper.AddValue(Usage, 'appId', AppId);
        IDYMJSONHelper.AddValue(Usage, 'appActionId', ActionId);
        IDYMJSONHelper.AddValue(Usage, 'qty', Qty);
        exit(Usage);
    end;


    [Obsolete('Added new parameter to GetLicenseStatus', '19.7')]
    procedure GetLicenseStatus(LicenseKey: Text[50]; var Status: Text; var Style: Text): Boolean
    begin
    end;

    procedure GetLicenseStatus(LicenseKey: Text[50]; var IDYSSetup: Record "IDYS Setup"; var Status: Text; var Style: Text): Boolean
    var
        AppInfo: ModuleInfo;
        ErrorMessage: Text;
        ErrCode: Integer;
        LicenseKeyInvalidMsg: Label 'Invalid';
        LicenseKeyDisabledMsg: Label 'Inactive';
        LicenseKeyExpiredMsg: Label 'Expired';
    begin
        Style := 'Favorable';
        Status := 'Valid';

        NavApp.GetCurrentModuleInfo(AppInfo);
        if not CheckLicense(LicenseKey, ErrorMessage, ErrCode, '', AppInfo.Id(), 0, false) then begin
            case ErrCode of
                4:
                    begin
                        Status := LicenseKeyInvalidMsg;
                        Style := 'Unfavorable';
                    end;
                5:
                    begin
                        Status := LicenseKeyInvalidMsg;
                        Style := 'Unfavorable';
                    end;
                6:
                    begin
                        Status := LicenseKeyDisabledMsg;
                        Style := 'Unfavorable';
                    end;
                7:
                    begin
                        Status := LicenseKeyExpiredMsg;
                        Style := 'Unfavorable';
                    end;
                403, 500 .. 511:
                    if IDYSSetup."License Grace Period Start" = 0DT then begin
                        IDYSSetup.Validate("License Grace Period Start", CurrentDateTime);
                        Status := LicenseKeyInvalidMsg;
                        Style := 'Unfavorable';
                    end;
                else begin
                    Status := LicenseKeyInvalidMsg;
                    Style := 'Unfavorable';
                    if IDYSSetup."License Grace Period Start" <> 0DT then
                        Clear(IDYSSetup."License Grace Period Start");
                end;
            end;

            exit(false);
        end;
        if IDYSSetup."License Grace Period Start" <> 0DT then
            Clear(IDYSSetup."License Grace Period Start");
        exit(true);
    end;

    [Obsolete('Replaced with CheckLicenseWithErrCode', '19.7')]
    procedure CheckLicense()
    begin
    end;

    procedure CheckLicenseWithErrCode() ErrCode: Integer;
    var
        IDYSShippingAgentMapping: Record "IDYS Shipping Agent Mapping";
    begin
        LoadSetup();
        Setup.TestField("License Key");
        IDYSShippingAgentMapping.SetFilter("Carrier Code (External)", '<>%1', '');
        ErrCode := CheckLicenseWithErrCode(IDYSShippingAgentMapping.Count());
    end;

    [Obsolete('Replaced with CheckLicenseWithErrCode', '19.7')]
    procedure CheckLicense(Units: Integer)
    begin
    end;

    procedure CheckLicenseWithErrCode(Units: Integer) ErrCode: Integer;
    var
        AppInfo: ModuleInfo;
        ErrorMessage: Text;
    begin
        //First definition is always free.
        if Units > 0 then
            Units := Units - 1;

        LoadSetup();
        Setup.TestField("License Key");

        NavApp.GetCurrentModuleInfo(AppInfo);
        CheckLicense(Setup."License Key", ErrorMessage, ErrCode, '', AppInfo.Id(), Units, true);
    end;

    local procedure LoadSetup()
    begin
        if not SetupLoaded then begin
            SetupLoaded := true;
            Setup.Get();
        end;
    end;

    [TryFunction]
    local procedure TryGetResponseObject(RestParameters: Record "IDYS REST Parameters"; var ErrorObject: JsonToken)
    begin
        ErrorObject := RestParameters.GetResponseBodyAsJSON();
    end;

    var
        Setup: Record "IDYS Setup";
        IDYMJSONHelper: Codeunit "IDYM Json Helper";
        SetupLoaded: Boolean;
}