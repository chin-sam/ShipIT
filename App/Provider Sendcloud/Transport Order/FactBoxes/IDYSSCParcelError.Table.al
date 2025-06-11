table 11147686 "IDYS SC Parcel Error"
{
    DataClassification = SystemMetadata;
    Caption = 'Parcel Error';

    fields
    {
        field(1; "Transport Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Transport Order No.';
        }
        field(2; "Parcel Identifier"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Parcel Identifier';
        }
        field(3; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(4; "Error Message"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Error Message';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}