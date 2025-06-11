table 11147684 "IDYS Provider Package Entry"
{
    TableType = Temporary;
    DataClassification = CustomerContent;
    Caption = 'Provider Package Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; Provider; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            Editable = false;
        }
        field(3; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;
        }
        field(4; "Carrier Name"; Text[100])
        {
            Caption = 'Carrier Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            TableRelation = "IDYS Provider Booking Profile";
            DataClassification = CustomerContent;
        }
        field(6; "Booking Profile Description"; Text[150])
        {
            Caption = 'Booking Profile Description';
            DataClassification = CustomerContent;
        }
        field(7; "Package Type Code"; Code[50])
        {
            Caption = 'Package Type Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}