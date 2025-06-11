pageextension 11147673 "IDYS Customer Card" extends "Customer Card"
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

                group(IDYSIsTranssmart)
                {
                    ShowCaption = false;
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
                field("IDYS Surcharge Fixed Amount"; Rec."IDYS Surcharge Fixed Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Amount Surcharge.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved to Cust. Inv. Discount';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }
                field("IDYS Surcharge %"; Rec."IDYS Surcharge %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Surcharge Percentage.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved to Cust. Inv. Discount';
                    ObsoleteTag = '21.0';
                    Visible = false;
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
