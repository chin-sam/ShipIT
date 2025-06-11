table 11147642 "IDYS Service Level (Time)"
{
    Caption = 'Service Level (Time)';
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "IDYS Service Levels (Time)";
    LookupPageID = "IDYS Service Levels (Time)";

    fields
    {
        field(1; "Code"; Code[50])
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

    fieldgroups
    {
        fieldgroup(DropDown; "Code")
        {
        }
    }
}