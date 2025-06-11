pageextension 11147676 "IDYS Order Address" extends "Order Address"
{
    layout
    {
        addlast(General)
        {
            group("IDYS ShipIT 365")
            {
                Caption = 'ShipIT 365';
                Visible = IDYSIsTranssmartEnabled;

                field("IDYS Cost Center"; Rec."IDYS Cost Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cost Center.';
                }
                field("IDYS E-Mail Type"; Rec."IDYS E-Mail Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Type.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if IDYSProviderSetup.Get("IDYS Provider"::Transsmart) then
            IDYSIsTranssmartEnabled := IDYSProviderSetup.Enabled;
    end;

    var
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IDYSIsTranssmartEnabled: Boolean;
}
