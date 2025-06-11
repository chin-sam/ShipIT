tableextension 11147671 "IDYS Item Category" extends "Item Category"
{
    fields
    {
        field(11147639; "IDYS Enable Insurance"; Boolean)
        {
            Caption = 'Enable Insurance';
            DataClassification = CustomerContent;
        }
        field(11147640; "IDYS Min. Shipmt. Amount (LCY)"; Decimal)
        {
            Caption = 'Min. Shipment Amount (LCY) for Insurance';
            DataClassification = CustomerContent;
        }
    }
}