page 11147663 "IDYS ShipIT Setup Card Part"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "IDYS Setup";
    Caption = 'Activities';

    layout
    {
        area(Content)
        {
            cuegroup(Setup)
            {
                Caption = 'Setup';

                actions
                {
                    action("Run Wizard")
                    {
                        ApplicationArea = All;
                        Image = TileSettings;
                        RunObject = page "IDYS ShipIT Setup Wizard";
                        Caption = 'Run Wizard';
                        ToolTip = 'Starts the ShipIT wizard.';
                    }
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        IDYMApphub: Codeunit "IDYM Apphub";
        NotificationManagement: Codeunit "IDYS Notification Management";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        IDYMAppHub.NewAppVersionNotification(AppInfo.Id, false);
        NotificationManagement.SendInstructionNotification();
    end;
}