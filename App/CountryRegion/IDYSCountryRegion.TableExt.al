tableextension 11147672 "IDYS Country/Region" extends "Country/Region"
{
    fields
    {
        field(11147740; "IDYS Ship-from"; Boolean)
        {
            Caption = 'Ship-from (Sendcloud)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IDYSSCCountryRegionLine: Record "IDYS SC Country/Region Line";
                CountryRegion: Record "Country/Region";
            begin
                if "IDYS Ship-from" then begin
                    TestField("ISO Code");

                    if CountryRegion.FindSet() then
                        repeat
                            if not IDYSSCCountryRegionLine.Get(Code, CountryRegion.Code) then begin
                                IDYSSCCountryRegionLine.Init();
                                IDYSSCCountryRegionLine."Ship-from Country" := Code;
                                IDYSSCCountryRegionLine."Ship-to Country" := CountryRegion.Code;
                                IDYSSCCountryRegionLine.Insert();
                            end;
                        until CountryRegion.Next() = 0;
                end else begin
                    // Delete line record
                    "IDYS Used for Returns" := false;

                    IDYSSCCountryRegionLine.SetRange("Ship-from Country", Code);
                    IDYSSCCountryRegionLine.DeleteAll();
                end;
            end;
        }
        field(11147741; "IDYS Used for Returns"; Boolean)
        {
            Caption = 'Used for Returns (Sendcloud)';
            DataClassification = CustomerContent;
        }
        field(11147639; "IDYS Ship-to Lines"; Boolean)
        {
            Caption = 'Ship-to Lines (Sendcloud)';
            FieldClass = FlowField;
            CalcFormula = exist("IDYS SC Country/Region Line" where("Ship-from Country" = field("Code")));
            Editable = false;
        }
        field(11147640; "IDYS Insure"; Boolean)
        {
            Caption = 'Insure';
            DataClassification = CustomerContent;
        }
    }
}
