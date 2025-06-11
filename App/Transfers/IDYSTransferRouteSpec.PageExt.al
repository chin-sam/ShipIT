pageextension 11147680 "IDYS Transfer Route Spec." extends "Transfer Route Specification"
{
    layout
    {
        addlast(General)
        {
            group("IDYS ShipIT 365")
            {
                Caption = 'ShipIT 365';

                field("IDYS Shipment Method Code"; Rec."IDYS Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Method Code.';
                }
            }
        }
    }
}