codeunit 11147830 "IDYS SC Subscribers"
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
        OfferTitle := 'Sendcloud - The all-in-one shipping platform - with ShipIT 365';
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