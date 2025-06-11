table 11147647 "IDYS E-Mail Type"
{
    Caption = 'E-Mail Type';
    DataCaptionFields = "Code", Description, "Is Default";
    LookupPageId = "IDYS E-Mail Types";

    fields
    {
        field(1; "Code"; Code[127])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; Description; Text[128])
        {
            Caption = 'Description';
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