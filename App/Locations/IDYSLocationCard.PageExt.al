pageextension 11147679 "IDYS Location Card" extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            group("IDYS ShipIT 365")
            {
                Caption = 'ShipIT 365';

                field("IDYS Cost Center"; Rec."IDYS EORI Number")
                {
                    Importance = Additional;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EORI Number.';
                }

                group(IDYSIsTranssmart)
                {
                    ShowCaption = false;
                    Visible = IDYSIsTranssmartEnabled;

                    field("IDYS Account No."; Rec."IDYS Account No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Account No.';
                        Importance = Additional;
                    }
                    field(IDYSCostCenterFld; Rec."IDYS Cost Center")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cost Center.';
                        Importance = Additional;
                    }
                    field("IDYS E-Mail Type"; Rec."IDYS E-Mail Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the E-Mail Type.';
                        Importance = Additional;
                    }
                }

                #region [Sendcloud]
                field("IDYS Address Id."; Rec."IDYS Address Id.")
                {
                    Importance = Additional;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sender Address Id.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Sender Address removed';
                    ObsoleteTag = '21.0';
                }
                #endregion
                #region [nShift Ship]
                group(IDYSIsDelHub)
                {
                    ShowCaption = false;
                    Visible = IsDelHubEnabled;

                    field("IDYS Actor Id"; Rec."IDYS Actor Id")
                    {
                        Caption = 'Actor Id';
                        Importance = Additional;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the actor id that will be used in the Transport Order creation.';
                    }
                }
                #endregion
            }
        }
    }
    trigger OnOpenPage()
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        IDYSIsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Transsmart, false);
        IsDelHubEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::"Delivery Hub", false);
    end;

    var
        IDYSIsTranssmartEnabled: Boolean;
        IsDelHubEnabled: Boolean;
}