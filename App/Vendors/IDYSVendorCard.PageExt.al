pageextension 11147674 "IDYS Vendor Card" extends "Vendor Card"
{
    layout
    {
#if not BC17EORI
        modify("EORI Number")
        {
            Visible = true;
            Importance = Additional;
        }
#endif
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
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        IDYSIsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled(Enum::"IDYS Provider"::Transsmart, false);
    end;

    var
        IDYSIsTranssmartEnabled: Boolean;
}