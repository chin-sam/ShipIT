table 11147664 "IDYS Language Mapping"
{
    Caption = 'Language Mapping';
    LookupPageId = "IDYS Language Mappings";

    fields
    {
        field(1; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = "Language";
            DataClassification = CustomerContent;
        }

        field(2; "Language Code (External)"; Code[2])
        {
            Caption = 'Language Code (External)';
            DataClassification = CustomerContent;
        }
        field(3; "Language Name"; Text[50])
        {
            CalcFormula = Lookup(Language.Name where("Code" = field("Language Code")));
            Caption = 'Language Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Language Code")
        {
        }

        key(Key2; "Language Code (External)")
        {
        }
    }
}