tableextension 11147664 "IDYS Whse. Receipt Header" extends "Warehouse Receipt Header"
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