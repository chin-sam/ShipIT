table 11147673 "IDYS Transport Order Register"
{
    DataClassification = SystemMetaData;
    Caption = 'Transport Order Register';

    fields
    {
        field(1; "Table No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table No.';
            NotBlank = true;
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(3; "Transport Order No."; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Transport Order No.';
            TableRelation = "IDYS Transport Order Header"."No.";
            NotBlank = true;
        }
        field(4; Created; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Created';
        }
        field(10; "Warehouse Shipment No."; Code[20])
        {
            TableRelation = "Warehouse Shipment Header";
            DataClassification = SystemMetadata;
            Caption = 'Warehouse Shipment No.';
        }
        field(11; "Batch Posting ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Batch Posting ID';
        }
        field(12; "Source Document Record Id"; RecordId)
        {
            DataClassification = SystemMetadata;
            Caption = 'Source Document Record Id';
        }
    }

    keys
    {
        key(Key1; "Table No.", "Document No.", "Transport Order No.")
        {
            Clustered = true;
        }
        key(Key2; "Batch Posting ID")
        {
        }
        key(Key3; "Source Document Record Id")
        {
        }
        key(Key4; "Warehouse Shipment No.")
        {
        }
    }
}