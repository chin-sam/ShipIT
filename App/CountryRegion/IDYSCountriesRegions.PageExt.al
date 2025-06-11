pageextension 11147684 "IDYS Countries/Regions" extends "Countries/Regions"
{
    layout
    {
        addlast(Control1)
        {
            field("IDYS Ship-from"; Rec."IDYS Ship-from")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Ship-from country/region code';
                Visible = IDYSIsSendcloudEnabled;

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
            field("IDYS Used for Returns"; Rec."IDYS Used for Returns")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the country can be used for returns.';
                Visible = IDYSIsSendcloudEnabled;
#if BC17
#pragma warning disable AL0604
                Enabled = "IDYS Ship-from";
#pragma warning restore AL0604
#else
                Enabled = Rec."IDYS Ship-from";
#endif
            }
            field("IDYS Ship-to Lines"; Rec."IDYS Ship-to Lines")
            {
                ApplicationArea = All;
                ToolTip = 'Opens list of the Ship-to Countries';
                Visible = IDYSIsSendcloudEnabled;

                trigger OnDrillDown()
                var
                    IDYSSCCountryRegionLine: Record "IDYS SC Country/Region Line";
                begin
                    IDYSSCCountryRegionLine.SetRange("Ship-from Country", Rec.Code);
                    Page.RunModal(Page::"IDYS SC Countries/Reg. Lines", IDYSSCCountryRegionLine);
                    CurrPage.Update();
                end;
            }
            field("IDYS Insure"; Rec."IDYS Insure")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if insurance is applied when shipping to this country code';
                Visible = IDYSIsTranssmartEnabled and IDYSInsuranceEnabled;
            }
        }
    }

    trigger OnOpenPage()
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        IDYSIsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Transsmart, false);
        IDYSIsSendcloudEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Sendcloud, false);
        IDYSInsuranceEnabled := IDYSProviderMgt.IsInsuranceEnabled("IDYS Provider"::Transsmart);
    end;

    var
        IDYSIsTranssmartEnabled: Boolean;
        IDYSIsSendcloudEnabled: Boolean;
        IDYSInsuranceEnabled: Boolean;
}
