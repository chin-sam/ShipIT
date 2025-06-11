table 11147683 "IDYS SC Shipping Price"
{
    Caption = 'Shipping Price';
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
            Caption = 'Provider Booking Profile';
            TableRelation = "IDYS Provider Booking Profile";
        }
        field(3; "Country (from)"; Code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Country (from)';
        }

        field(4; "Country (to)"; Code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Country (to)';
        }

        field(5; "ISO 2"; Code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'ISO 2';
        }
        field(6; "ISO 3"; Code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'ISO 3';
        }
        field(7; Price; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Price';
        }
        field(8; "Country Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Country Name';
        }
        field(9; "Is Return"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Is Return';
        }

        field(100; "Last Update"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Update';
        }

        field(102; "Country/Region Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Send-to Country/Region Code';
            TableRelation = "Country/Region"."Code";
            ObsoleteState = Removed;
            ObsoleteReason = 'Restructured';
            ObsoleteTag = '21.0';
        }
    }

    keys
    {
        key(PK; "Carrier Entry No.", "Booking Profile Entry No.", "Country (from)", "Country (to)")
        {
            Clustered = true;
        }
        key(Sort; "ISO 2")
        {
        }
    }
}