table 11147677 "IDYS Package Content Buffer"
{
    DataClassification = SystemMetadata;
    TableType = Temporary;
    Caption = 'Package Content Buffer';

    fields
    {
        field(1; "Transport Order No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Package Line No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Source RecordId"; RecordId)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Qty. (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Net Weight"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(7; "Gross Weight"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(8; "Transport Order Line No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Transport Order No.", "Line No.")
        {
            Clustered = true;
        }
    }
}