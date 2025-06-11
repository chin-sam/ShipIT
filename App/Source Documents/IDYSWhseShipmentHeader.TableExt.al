tableextension 11147663 "IDYS Whse. Shipment Header" extends "Warehouse Shipment Header"
{
    fields
    {
        field(11147701; "IDYS Whse Post Batch ID"; Guid)
        {
            Caption = 'Warehouse Post Batch ID';
            Editable = false;
            DataClassification = SystemMetadata;
        }
    }
}