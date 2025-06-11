pageextension 11147675 "IDYS Ship-to Address" extends "Ship-to Address"
{
    layout
    {
        addlast(General)
        {
            group("IDYS ShipIT 365")
            {
                Caption = 'ShipIT 365';
                Visible = IDYSIsTranssmartEnabled;

                field("IDYS Account No."; Rec."IDYS Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account No.';
                }
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
        IDYSProviderSetup.Get("IDYS Provider"::Transsmart);
        IDYSIsTranssmartEnabled := IDYSProviderSetup.Enabled;
    end;

    var
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IDYSIsTranssmartEnabled: Boolean;
}