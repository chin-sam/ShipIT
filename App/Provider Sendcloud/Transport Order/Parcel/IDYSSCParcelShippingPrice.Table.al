table 11147694 "IDYS SC Parcel Shipping Price"
{
    DataClassification = CustomerContent;
    Caption = 'Parcel Shipping Price';

    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(2; "Booking Profile Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Provider Booking Profile';
            TableRelation = "IDYS Provider Booking Profile";
        }
        field(3; Carrier; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Carrier';
        }
        field(4; Name; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Carrier Service';
        }
        field(5; "Max. Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Max. Weight';
            DecimalPlaces = 0 : 5;
        }
        field(6; "Country (from)"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Country (from)';
        }
        field(7; "Country (to)"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Country (to)';
        }
        field(8; "Price"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Price';
        }
        field(9; "Shipping Agent Code"; Code[10])
        {
            Editable = false;
            Caption = 'Shipping Agent';
        }
        field(10; "Shipping Agent Service Code"; Code[20])
        {
            Editable = false;
            Caption = 'Shipping Service';
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
        key(Sort; Price)
        {

        }
    }
}