pageextension 11147687 "IDYS Cust. Invoice Discounts" extends "Cust. Invoice Discounts"
{
    layout
    {
        addlast(Control1)
        {
            field("IDYS Add Calc. Freight Costs"; Rec."IDYS Add Calc. Freight Costs")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if freight costs should be added automatically after selecting a carrier.';
            }
            field("IDYS Surcharge %"; Rec."IDYS Surcharge %")
            {
                ApplicationArea = All;
#if BC17
#pragma warning disable AL0604
                Editable = "IDYS Add Calc. Freight Costs";
#pragma warning restore AL0604
#else
                Editable = Rec."IDYS Add Calc. Freight Costs";
#endif
                ToolTip = 'Specifies the value of the Surcharge Percentage.';
            }
        }
    }
}