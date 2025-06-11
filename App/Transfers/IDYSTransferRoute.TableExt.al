tableextension 11147666 "IDYS Transfer Route" extends "Transfer Route"
{
    fields
    {
        field(11147740; "IDYS Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipment Method".Code;
        }
    }
}