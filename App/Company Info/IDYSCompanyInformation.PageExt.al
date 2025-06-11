pageextension 11147672 "IDYS Company Information" extends "Company Information"
{
    layout
    {
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
                        ToolTip = 'Specifies the Account No.';
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
                #endregion [Sendcloud]
            }
        }

#if not BC17EORI
        modify("EORI Number")
        {
            Visible = true;
            Importance = Additional;
        }
#endif
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