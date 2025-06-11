tableextension 11147673 "IDYS Cust. Invoice Disc." extends "Cust. Invoice Disc."
{
    fields
    {
        field(11147639; "IDYS Add Calc. Freight Costs"; Boolean)
        {
            Caption = 'Add Calculated Freight Costs';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IDYSSetup.Get();
                if "IDYS Add Calc. Freight Costs" then
                    "IDYS Surcharge %" := IDYSSetup."Shipping Cost Surcharge (%)"
                else
                    "IDYS Surcharge %" := 0;

            end;
        }
        field(11147640; "IDYS Surcharge %"; Decimal)
        {
            Caption = 'Surcharge %';
            DataClassification = CustomerContent;
        }
    }

    var
        IDYSSetup: Record "IDYS Setup";
}