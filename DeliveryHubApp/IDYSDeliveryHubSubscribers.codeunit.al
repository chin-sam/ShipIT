codeunit 11147833 "IDYS Delivery Hub Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYS License Check", 'OnIncludeDependedAppId', '', true, false)]
    local procedure IDYSLicenseCheck_IncludeDependedAppId(var AppIds: List of [Guid])
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        AppIds.Add(AppInfo.Id());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYS License Check", 'SetOfferTitle', '', true, false)]
    local procedure IDYSLicenseCheck_SetOfferTitle(var OfferTitle: Text)
    var
    begin
        OfferTitle := 'nShift-Delivery Hub';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYS License Check", 'CheckShipITMember', '', true, false)]
    local procedure IDYSLicenseCheck_CheckShipITMember(AppId: Guid; var Member: Boolean)
    var
        AppInfo: ModuleInfo;
    begin
        if Member then
            exit;
        NavApp.GetCurrentModuleInfo(AppInfo);
        Member := AppInfo.Id = AppId;
    end;
}