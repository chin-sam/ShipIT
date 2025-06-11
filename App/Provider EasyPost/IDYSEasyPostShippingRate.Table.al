table 11147709 "IDYS EasyPost Shipping Rate"
{
    Caption = 'Rates';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Carrier Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Carrier Entry No';
            TableRelation = "IDYS Provider Carrier";
        }
        field(2; "Booking Profile Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Provider Booking Profile Entry No.';
            TableRelation = "IDYS Provider Booking Profile";
        }
        field(3; "Parcel Identifier"; Code[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Parcel Identifier';
        }

        field(4; Price; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Price';
        }
        field(20; "Shipment Id"; Text[100])
        {
            Caption = 'Shipment Id';
            DataClassification = SystemMetadata;
        }
        field(21; "Package Id"; Text[100])
        {
            Caption = 'Package Id';
            DataClassification = SystemMetadata;
        }
        field(22; "Rate Id"; Text[100])
        {
            Caption = 'Rate Id';
            DataClassification = SystemMetadata;
        }

        field(100; "Last Update"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Update';
        }
    }

    keys
    {
        key(PK; "Carrier Entry No.", "Booking Profile Entry No.", "Parcel Identifier")
        {
        }
    }
}