pageextension 11147688 "IDYS Shipment Methods" extends "Shipment Methods"
{
    layout
    {
        addafter(Description)
        {
            field("IDYS Skip Transport Order"; Rec."IDYS Skip Transport Order")
            {
                ApplicationArea = All;
                ToolTip = 'Indicates whether or not Transport Orders are required for this shipping method.';
            }
        }
    }
}