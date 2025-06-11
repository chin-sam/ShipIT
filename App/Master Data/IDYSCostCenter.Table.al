table 11147646 "IDYS Cost Center"
{
    Caption = 'Cost Center';
    DataCaptionFields = "Code", Name;
    LookupPageId = "IDYS Cost Centers";

    fields
    {
        field(1; "Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; Name; Text[128])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }

        field(3; "Is Default"; Boolean)
        {
            Caption = 'Is Default';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
        }
    }
}