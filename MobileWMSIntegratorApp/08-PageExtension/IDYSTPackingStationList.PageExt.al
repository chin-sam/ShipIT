pageextension 11147823 "IDYST Packing Station List" extends "MOB Packing Station List"
{
    layout
    {
        addlast(General)
        {
            field("IDYST User Name (External)"; Rec."IDYST User Name (External)")
            {
                ToolTip = 'Specifies the value of the User Name (External) field (ShipIT365 - TransSmart)';
                ApplicationArea = All;
                Visible = TransSmartEnabled;
                Enabled = TransSmartEnabled;
            }
            field("IDYST Password (External)"; Rec."IDYST Password (External)")
            {
                ToolTip = 'Specifies the value of the Password (External) field (ShipIT365 - TransSmart)';
                ApplicationArea = All;
                Visible = TransSmartEnabled;
                Enabled = TransSmartEnabled;
            }
            field("IDYST Ticket Username"; Rec."IDYST Ticket Username")
            {
                ToolTip = 'Specifies the value of the Ticket Username field (ShipIT365 - DeliveryHub)';
                ApplicationArea = All;
                Visible = DeliveryHubEnabled;
                Enabled = DeliveryHubEnabled;
            }
            field("IDYST Workstation ID"; Rec."IDYST Workstation ID")
            {
                ToolTip = 'Specifies the value of the Workstation ID field (ShipIT365 - DeliveryHub)';
                ApplicationArea = All;
                Visible = DeliveryHubEnabled;
                Enabled = DeliveryHubEnabled;
            }
            field("IDYST DZ Label Printer Key"; Rec."IDYST DZ Label Printer Key")
            {
                ToolTip = 'Specifies the value of the Drop Zone Label Printer Key field (ShipIT365 - DeliveryHub)';
                ApplicationArea = All;
                Visible = DeliveryHubEnabled;
                Enabled = DeliveryHubEnabled;
            }
        }
    }

    trigger OnOpenPage()
    var
        IDYSProviderSetup: Record "IDYS Provider Setup";
    begin
        IDYSProviderSetup.SetRange(Enabled, true);
        if IDYSProviderSetup.FindSet() then
            repeat
                case IDYSProviderSetup.Provider of
                    IDYSProviderSetup.Provider::Default, IDYSProviderSetup.Provider::Transsmart:
                        TransSmartEnabled := true;
                    IDYSProviderSetup.Provider::"Delivery Hub":
                        DeliveryHubEnabled := true;
                    // IDYSProviderSetup.Provider::Sendcloud:
                    //     SendCloudEnabled := true;  // TODO Currently not implemented
                    // IDYSProviderSetup.Provider::EasyPost:
                    //     EasyPostEnabled := true;   // TODO Currently not implemented
                end;
            until IDYSProviderSetup.Next() = 0;
    end;

    var
        TransSmartEnabled: Boolean; // Default, Transsmart
        DeliveryHubEnabled: Boolean; // DeliveryHub
        // SendCloudEnabled: Boolean;  // SendCloud
        // EasyPostEnabled: Boolean; // Easypost
}
