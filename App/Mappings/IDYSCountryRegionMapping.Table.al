table 11147649 "IDYS Country/Region Mapping"
{
    Caption = 'Country/Region Mapping';
    LookupPageId = "IDYS Country/Region Mappings";

    fields
    {
        field(1; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }

        field(2; "Country/Region Code (External)"; Code[10])
        {
            Caption = 'Country/Region Code (External)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Country/Region Code")
        {
        }

        key(Key2; "Country/Region Code (External)")
        {
        }
    }
}