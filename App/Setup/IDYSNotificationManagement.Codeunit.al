codeunit 11147701 "IDYS Notification Management"
{
    procedure SendInstructionNotification()
    var
        IDYSUpgradeTagDefinitions: Codeunit "IDYS Upgrade Tag Definitions";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::"Delivery Hub", false) then
            if not (UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.GetUpdatenShiftShipMasterDataTag())) then
                CreateAndSendNotification(UpdatenShiftShipMasterDataTok, UpdatenShiftShipMasterDataLbl, UpdatenShiftShipMasterDataMsg, false);
    end;

    procedure SendSkipTransportCreationNotification()
    begin
        CreateAndSendNotification(SkipOnShipmentMethodTok, SkipOnShipmentMethodNameMsg, SkipOnShipmentMethodMsg, true);
    end;

    procedure SendEnableMinShipmentPerItemCategoryNotification(NotificationMessage: Text; FirstActionCaption: Text; FirstActionCodeunit: Integer; FirstActionName: Text)
    begin
        CreateAndSendNotification(ConfigureItemCategoriesForInsuranceNameTok, ConfigureItemCategoriesForInsuranceNameLbl, NotificationMessage, FirstActionCaption, FirstActionCodeunit, FirstActionName);
    end;

    local procedure CreateAndSendNotification(NotificationId: Guid; NotificationName: Text[128]; NotificationMessage: Text; AddHideNotification: Boolean)
    var
        MyNotifications: Record "My Notifications";
        Notification: Notification;
    begin
        Notification.Id(NotificationId);
        if not IsEnabled(Notification) then
            exit;

        MyNotifications.InsertDefault(NotificationId, NotificationName, NotificationMessage, true);

        Notification.Message(NotificationMessage);
        Notification.Scope(NotificationScope::LocalScope);
        if AddHideNotification then
            Notification.AddAction(HideNotificationTxt, Codeunit::"IDYS Notification Management", 'HideNotification');
        Notification.Send();
    end;

    local procedure CreateAndSendNotification(NotificationId: Guid; NotificationName: Text[128]; NotificationMessage: Text; FirstActionCaption: Text; FirstActionCodeunit: Integer; FirstActionName: Text)
    var
        MyNotifications: Record "My Notifications";
        Notification: Notification;
    begin
        Notification.Id(NotificationId);
        if not IsEnabled(Notification) then
            exit;

        MyNotifications.InsertDefault(NotificationId, NotificationName, NotificationMessage, true);

        Notification.Message(NotificationMessage);
        Notification.Scope(NotificationScope::LocalScope);
        Notification.AddAction(FirstActionCaption, FirstActionCodeunit, FirstActionName);
        Notification.AddAction(HideNotificationTxt, Codeunit::"IDYS Notification Management", 'HideNotification');
        Notification.Send();
    end;

    procedure SendNotification(NotificationId: Guid; NotificationMessage: Text)
    var
        Notification: Notification;
    begin
        Notification.Id(NotificationId);
        Notification.Recall();
        Notification.Message(NotificationMessage);
        Notification.Scope(NotificationScope::LocalScope);
        Notification.Send();
    end;

    procedure SendNotification(NotificationMessage: Text)
    var
        Notification: Notification;
    begin
        Notification.Scope(NotificationScope::LocalScope);
        Notification.Message(NotificationMessage);
        Notification.Send();
    end;

    procedure RecallNotification(NotificationId: Guid)
    var
        Notification: Notification;
    begin
        Notification.Id(NotificationId);
        Notification.Recall();
    end;

    procedure HideNotification(EnabledNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.Disable(EnabledNotification.Id());
    end;

    local procedure IsEnabled(MyNotification: Notification) Enabled: Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        Enabled := MyNotifications.IsEnabled(MyNotification.Id());
    end;

    procedure OpenItemCategories(MyNotifation: Notification)
    var
        ItemCategory: Record "Item Category";
    begin
        Page.RunModal(0, ItemCategory);
    end;

    var
        HideNotificationTxt: Label 'Don''t show this notification again.';
        SkipOnShipmentMethodNameMsg: Label 'Skip Transport Order creation on shipment method.';
        SkipOnShipmentMethodMsg: Label 'There''s nothing to create at the moment. The creation process is being skipped due to the shipment method.';
        ConfigureItemCategoriesForInsuranceNameLbl: Label 'Configure Item Categories for Insurance.';
        UpdatenShiftShipMasterDataLbl: Label 'Update master data for nShift Ship.';
        UpdatenShiftShipMasterDataMsg: Label 'Please update master data for nShift Ship provider.';
        UpdatenShiftShipMasterDataTok: Label 'a524eff2-951e-4843-b50c-f7eba67e66fb', Locked = true;
        SkipOnShipmentMethodTok: Label '88785174-2f73-42b8-b18f-8734bfdb7053', Locked = true;
        ConfigureItemCategoriesForInsuranceNameTok: Label 'ca84ada0-bcf4-4219-94f5-b55317ec6641', Locked = true;
}