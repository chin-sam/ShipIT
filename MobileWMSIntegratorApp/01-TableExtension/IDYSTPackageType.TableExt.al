tableextension 11147822 "IDYST Package Type" extends "MOB Package Type"
{
    fields
    {
        field(11147820; "IDYST IDYS Provider"; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;
        }
        field(11147821; "IDYST Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            DataClassification = CustomerContent;
        }
        field(11147822; "IDYST Carrier Name"; Text[150])
        {
            Caption = 'Carrier Name';
            DataClassification = CustomerContent;
        }
        field(11147823; "IDYST Book Prof Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            DataClassification = CustomerContent;
        }
        field(11147824; "IDYST Book Prof Descr"; Text[150])
        {
            Caption = 'Booking Profile Description';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "IDYST Carrier Entry No.", "IDYST Book Prof Entry No.")
        {
        }
    }
}
