tableextension 11147674 "IDYS Shipment Method" extends "Shipment Method"
{
    fields
    {
        field(11147639; "IDYS Skip Transport Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Don''t create Transport Orders';
        }
    }
}