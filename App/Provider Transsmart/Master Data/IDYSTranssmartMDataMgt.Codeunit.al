codeunit 11147696 "IDYS Transsmart M. Data Mgt."
{
    procedure UpdateMasterData(ShowNotifications: Boolean): Boolean
    var
        IDYSTranssmartAPIDataSetup: Codeunit "IDYS Transsmart API Data Setup";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        MasterDataUpdatedMsg: Label 'The ShipIT master data has been successfully updated.';
        MasterDataUpdateTok: Label '343d136d-a7a0-4545-a38c-57c2f0847ac0', Locked = true;
        GetCarriersTok: Label 'bfefaef4-a06c-4a86-b468-2b9232ddb1e9', Locked = true;
        GetServiceLevelsTimeTok: Label '8d348a13-12b7-44eb-8836-2bd11f4f2993', Locked = true;
        GetServiceLevelsOtherTok: Label '89b34d5b-c975-4531-92a2-a95a03c4de9f', Locked = true;
        GetBookingProfilesTok: Label '6421507c-1bce-40b1-9b33-10ceac39484f', Locked = true;
        GetPackageTypesTok: Label '28d67628-bb39-494f-8247-b3859dbb86a2', Locked = true;
        GetCostCentersTok: Label '13967da1-328a-47db-b296-8b4ffe605190', Locked = true;
        GetIncoTermsTok: Label '5874737a-6ff3-4fda-b959-00c0af8172c2', Locked = true;
        GetEmailTypesTok: Label 'db4c3ca0-bc59-4dc8-ac83-6750291b09e0', Locked = true;
    begin
        if not IDYSTranssmartAPIDataSetup.GetCarriers() then begin
            if (GuiAllowed()) and ShowNotifications then
                IDYSNotificationManagement.SendNotification(GetCarriersTok, IDYSTranssmartAPIDataSetup.GetErrorMessage());
            exit(false);
        end else
            IDYSNotificationManagement.RecallNotification(GetCarriersTok);

        if not IDYSTranssmartAPIDataSetup.GetServiceLevelsTime() then begin
            if (GuiAllowed()) and ShowNotifications then
                IDYSNotificationManagement.SendNotification(GetServiceLevelsTimeTok, IDYSTranssmartAPIDataSetup.GetErrorMessage());
            exit(false);
        end else
            IDYSNotificationManagement.RecallNotification(GetServiceLevelsTimeTok);

        if not IDYSTranssmartAPIDataSetup.GetServiceLevelsOther() then begin
            if (GuiAllowed()) and ShowNotifications then
                IDYSNotificationManagement.SendNotification(GetServiceLevelsOtherTok, IDYSTranssmartAPIDataSetup.GetErrorMessage());
            exit(false);
        end else
            IDYSNotificationManagement.RecallNotification(GetServiceLevelsOtherTok);

        if not IDYSTranssmartAPIDataSetup.GetBookingProfiles() then begin
            if (GuiAllowed()) and ShowNotifications then
                IDYSNotificationManagement.SendNotification(GetBookingProfilesTok, IDYSTranssmartAPIDataSetup.GetErrorMessage());
            exit(false);
        end else
            IDYSNotificationManagement.RecallNotification(GetBookingProfilesTok);

        if not IDYSTranssmartAPIDataSetup.GetPackageTypes() then begin
            if (GuiAllowed()) and ShowNotifications then
                IDYSNotificationManagement.SendNotification(GetPackageTypesTok, IDYSTranssmartAPIDataSetup.GetErrorMessage());
            exit(false);
        end else
            IDYSNotificationManagement.RecallNotification(GetPackageTypesTok);

        if not IDYSTranssmartAPIDataSetup.GetIncoTerms() then begin
            if (GuiAllowed()) and ShowNotifications then
                IDYSNotificationManagement.SendNotification(GetCostCentersTok, IDYSTranssmartAPIDataSetup.GetErrorMessage());
            exit(false);
        end else
            IDYSNotificationManagement.RecallNotification(GetCostCentersTok);

        if not IDYSTranssmartAPIDataSetup.GetCostCenters() then begin
            if (GuiAllowed()) and ShowNotifications then
                IDYSNotificationManagement.SendNotification(GetIncoTermsTok, IDYSTranssmartAPIDataSetup.GetErrorMessage());
            exit(false);
        end else
            IDYSNotificationManagement.RecallNotification(GetIncoTermsTok);

        if not IDYSTranssmartAPIDataSetup.GetEMailTypes() then begin
            if (GuiAllowed()) and ShowNotifications then
                IDYSNotificationManagement.SendNotification(GetEmailTypesTok, IDYSTranssmartAPIDataSetup.GetErrorMessage());
            exit(false);
        end else
            IDYSNotificationManagement.RecallNotification(GetEmailTypesTok);

        if (GuiAllowed()) and ShowNotifications then
            IDYSNotificationManagement.SendNotification(MasterDataUpdateTok, MasterDataUpdatedMsg);

        exit(true);
    end;
}