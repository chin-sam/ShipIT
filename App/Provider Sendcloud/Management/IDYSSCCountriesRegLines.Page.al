page 11147733 "IDYS SC Countries/Reg. Lines"
{
    PageType = List;
    Caption = 'Ship-to Countries';
    UsageCategory = None;
    SourceTable = "IDYS SC Country/Region Line";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Ship-to Country"; Rec."Ship-to Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Ship-to Country';
                }
                field("Ship-to Country Name"; Rec."Ship-to Country Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Ship-to Country name';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("Select Countries")
                {
                    Caption = 'Select Ship-to Countries';
                    Image = SelectLineToApply;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    ApplicationArea = All;
                    ToolTip = 'Select one or more countries. Only unique entries will be included.';

                    trigger OnAction()
                    var
                        CountryRegion: Record "Country/Region";
                        IDYSSCCountryRegionLine: Record "IDYS SC Country/Region Line";
                        CountriesRegions: Page "Countries/Regions";
                    begin
                        CurrPage.SaveRecord();

                        CountriesRegions.LookupMode(true);
                        CountriesRegions.Editable(false);
                        if CountriesRegions.RunModal() = Action::LookupOK then begin
                            CountriesRegions.SetSelectionFilter(CountryRegion);

                            if CountryRegion.FindSet() then
                                repeat
                                    if not IDYSSCCountryRegionLine.Get(Rec."Ship-from Country", CountryRegion.Code) then begin
                                        IDYSSCCountryRegionLine.Init();
                                        IDYSSCCountryRegionLine."Ship-from Country" := Rec."Ship-from Country";
                                        IDYSSCCountryRegionLine."Ship-to Country" := CountryRegion.Code;
                                        IDYSSCCountryRegionLine.Insert();
                                    end;
                                until CountryRegion.Next() = 0;
                        end;
                        CurrPage.Update();
                    end;
                }
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Select Countries_Promoted"; "Select Countries")
                {
                }
            }
        }
#endif
    }
}