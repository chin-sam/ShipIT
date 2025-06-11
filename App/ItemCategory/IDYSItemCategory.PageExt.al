pageextension 11147682 "IDYS Item Category" extends "Item Category Card"
{
    layout
    {
        addlast(General)
        {
            group("IDYS ShipIT 365")
            {
                Caption = 'ShipIT 365';
                Visible = IDYSIsTranssmartEnabled and IDYSInsuranceEnabled;

                group(IDYSIsTranssmart)
                {
                    ShowCaption = false;
                    Visible = IDYSInsuranceEnabled;

                    field("IDYS Enable Insurance"; Rec."IDYS Enable Insurance")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if the insurance is enabled per item category.';
                    }

                    group(IDYSMinimumShipmentAmount)
                    {
                        ShowCaption = false;
#if BC17
#pragma warning disable AL0604
                        Visible = "IDYS Enable Insurance";
#pragma warning restore AL0604
#else
                        Visible = Rec."IDYS Enable Insurance";
#endif
                        field("IDYS Min. Shipmt. Amount (LCY)"; Rec."IDYS Min. Shipmt. Amount (LCY)")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the minimum shipment amount for the insurance.';
                        }
                    }
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        IDYSIsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Transsmart, false);
        IDYSInsuranceEnabled := IDYSProviderMgt.IsInsuranceEnabled("IDYS Provider"::Transsmart);
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSIsTranssmartEnabled: Boolean;
        IDYSInsuranceEnabled: Boolean;
}