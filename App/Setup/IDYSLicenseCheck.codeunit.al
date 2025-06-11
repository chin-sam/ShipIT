codeunit 11147720 "IDYS License Check"
{
    trigger OnRun()
    begin
    end;

    procedure CheckLicense(LicenseEntryNo: Integer; var ErrorMessage: Text; var HttpStatusCode: Integer) IsValid: Boolean
    begin
        exit(CheckLicense(LicenseEntryNo, ErrorMessage, HttpStatusCode, false));
    end;

    procedure CheckLicense(LicenseEntryNo: Integer; var ErrorMessage: Text; var HttpStatusCode: Integer; ThrowNotification: Boolean) IsValid: Boolean
    var
        AppId: Guid;
        AppIds: List of [Guid];
        ErrorCodes: List of [Integer];
        ErrorMessages: List of [Text];
        CheckErrors: List of [Integer];
        CheckError: Integer;
        LicenseUnitsLbl: Label 'carriers';
        LicenseErrorTok: Label '92ce05ca-a27d-41ad-bb8e-f07f6c8e1e86', Locked = true;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        OnIncludeDependedAppId(AppIds);
        AppIds.Add(AppInfo.Id());

        if PostPoneWriteTransactions then
            IDYMAppHub.SetPostponeWriteTransactions();

        //prefered feedback sequence for errors 
        CheckErrors.Add(4);
        CheckErrors.Add(6);
        CheckErrors.Add(7);
        CheckErrors.Add(13);
        CheckErrors.Add(5);
        CheckErrors.Add(10);
        CheckErrors.Add(14);
        CheckErrors.Add(16);

        foreach AppId in AppIds do begin
            IDYMAppHub.SetErrorUnitName(LicenseUnitsLbl);
            if IDYMAppHub.CheckLicense(LicenseEntryNo, AppId, 0, ErrorMessage, HttpStatusCode, false) then
                exit(true);

            ErrorCodes.Add(HttpStatusCode);
            ErrorMessages.Add(ErrorMessage);
        end;

        foreach CheckError in CheckErrors do
            if ErrorCodes.Contains(CheckError) then
                if HttpStatusCode = 0 then
                    HttpStatusCode := CheckError;

        if HttpStatusCode = 0 then
            HttpStatusCode := ErrorCodes.Get(1);

        ErrorMessage := ErrorMessages.Get(ErrorCodes.IndexOf(HttpStatusCode));

        if GuiAllowed() and not HideErrors then
            Error(ErrorMessage);
        if GuiAllowed() and ThrowNotification then
            IDYSNotificationManagement.SendNotification(LicenseErrorTok, ErrorMessage);
        exit(false);
    end;

    procedure CheckLicenseProperty(LicenseEntryNo: Integer; PropertyKey: Text; PropertyValue: Text; ThrowError: Boolean; var ErrorMessage: Text; var HttpStatusCode: Integer) IsValid: Boolean
    var
        IDYMAppLicenseKey: Record "IDYM App License Key";
        AppId: Guid;
        AppIds: List of [Guid];
        ErrorCodes: List of [Integer];
        ErrorMessages: List of [Text];
        CheckErrors: List of [Integer];
        CheckError: Integer;
        LicenseUnitsLbl: Label 'carriers';
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        OnIncludeDependedAppId(AppIds);
        AppIds.Add(AppInfo.Id());

        IDYMAppLicenseKey.Get(LicenseEntryNo);
        //prefered feedback sequence for errors 
        CheckErrors.Add(4);
        CheckErrors.Add(6);
        CheckErrors.Add(7);
        CheckErrors.Add(13);
        CheckErrors.Add(5);
        CheckErrors.Add(10);
        CheckErrors.Add(14);
        CheckErrors.Add(16);

        foreach AppId in AppIds do begin
            IDYMAppHub.SetErrorUnitName(LicenseUnitsLbl);
            if IDYMApphub.CheckLicenseProperty(AppId, IDYMAppLicenseKey."License Key", PropertyKey, PropertyValue, false, HttpStatusCode, ErrorMessage) then
                exit(true);

            ErrorCodes.Add(HttpStatusCode);
            ErrorMessages.Add(ErrorMessage);
        end;

        foreach CheckError in CheckErrors do
            if ErrorCodes.Contains(CheckError) then
                if HttpStatusCode = 0 then
                    HttpStatusCode := CheckError;

        if HttpStatusCode = 0 then
            HttpStatusCode := ErrorCodes.Get(1);

        ErrorMessage := ErrorMessages.Get(ErrorCodes.IndexOf(HttpStatusCode));

        if ThrowError then
            Error(ErrorMessage);

        exit(false);
    end;

    procedure GetLicenseStatus(LicenseEntryNo: Integer; var LicenseKeyStatus: Text; var LicenseKeyStatusStyle: Text)
    var
        ErrorMessage: Text;
        ErrCode: Integer;
    begin
        if CheckLicense(LicenseEntryNo, ErrorMessage, ErrCode, false) then
            LicenseKeyStatus := IDYMAppHub.GetSuccessStatusAndStyle(LicenseKeyStatusStyle)
        else
            LicenseKeyStatus := IDYMAppHub.GetStatusAndStyleForErrCode(ErrCode, LicenseKeyStatusStyle);
    end;

    procedure OnValidateLicenseKey(var IDYSSetup: Record "IDYS Setup"; var LicenseKeyStatus: Text; var LicenseKeyStatusStyle: Text; LicenseKey: Text[50])
    var
        IDYMAppLicenseKey: Record "IDYM App License Key";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        ErrorCode: Integer;
        ErrorMessage: Text;
    begin
        if LicenseKey <> '' then begin
            if IDYSSetup."License Entry No." <> 0 then begin
                IDYMAppLicenseKey.Get(IDYSSetup."License Entry No.");
                IDYMAppLicenseKey.Delete(true);
            end;

            IDYSSetup."License Entry No." := IDYMAppHub.GetLicenseAppEntryNo(AppInfo.Id(), LicenseKey);
            GetLicenseStatus(IDYSSetup."License Entry No.", LicenseKeyStatus, LicenseKeyStatusStyle);

            IDYSSetup.Validate("Allow Link Del. Lines with Pck", CheckLicenseProperty(IDYSSetup."License Entry No.", 'applicationarea', 'IDYS_PackageContent', false, ErrorMessage, ErrorCode));
        end else begin
            Clear(IDYSSetup."License Entry No.");
            Clear(LicenseKeyStatus);
            Clear(LicenseKeyStatusStyle);
            IDYSSetup.Validate("Allow Link Del. Lines with Pck", false);
        end;
        IDYSSetup.Modify();
        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany(); //activate PackageContent if license permits
    end;

    procedure SetHideErrors(NewHideErrors: Boolean)
    begin
        HideErrors := NewHideErrors;
    end;

    procedure SetPostponeWriteTransactions()
    begin
        PostPoneWriteTransactions := true;
    end;

    local procedure GetLicenseUnitCount() Units: Integer;
    var
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        IDYSShipAgentMapping.SetFilter("Carrier Entry No.", '<>%1', 0);
        Units := IDYSShipAgentMapping.Count();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYM Apphub", 'OnSetOfferTitle', '', true, true)]
    local procedure Apphub_OnSetOfferTitle(MainAppid: Guid; var OfferTitle: Text)
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if MainAppid <> AppInfo.Id() then
            exit;
        SetOfferTitle(OfferTitle); //forward event from ShipIT to ShipIT-shell apps
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYM Apphub", 'OnCheckLicense', '', false, false)]
    local procedure IDYMAppHub_OnCheckLicense(AppId: Guid; var Units: Integer)
    var
        PerformCheck: Boolean;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        PerformCheck := AppId = AppInfo.Id();
        if not PerformCheck then
            CheckShipITMember(AppId, PerformCheck);
        if not PerformCheck then
            exit;

        Units := GetLicenseUnitCount();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIncludeDependedAppId(var AppIds: List of [Guid])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetOfferTitle(var OfferTitle: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CheckShipITMember(AppId: Guid; var Member: Boolean)
    begin
    end;

    var
        IDYMAppHub: Codeunit "IDYM Apphub";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        AppInfo: ModuleInfo;
        PostPoneWriteTransactions: Boolean;
        HideErrors: Boolean;
}