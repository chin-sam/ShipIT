table 11147705 "IDYS SC Country/Region Line"
{
    Caption = 'Country/Region Line';

    fields
    {
        field(1; "Ship-from Country"; Code[10])
        {
            Caption = 'Ship-from Country';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }

        field(2; "Ship-to Country"; Code[10])
        {
            Caption = 'Ship-to Country';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }

        field(10; "Ship-to Country Name"; Text[50])
        {
            CalcFormula = Lookup("Country/Region".Name where(Code = field("Ship-to Country")));
            Caption = 'Ship-to Country Name';
            FieldClass = FlowField;
            Editable = false;
        }

        field(11; "Ship-from ISO Code"; Code[2])
        {
            CalcFormula = Lookup("Country/Region"."ISO Code" where(Code = field("Ship-from Country")));
            Caption = 'Ship-from ISO Code';
            FieldClass = FlowField;
            Editable = false;
        }
        field(12; "Ship-to ISO Code"; Code[2])
        {
            CalcFormula = Lookup("Country/Region"."ISO Code" where(Code = field("Ship-to Country")));
            Caption = 'Ship-from ISO Code';
            FieldClass = FlowField;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Ship-from Country", "Ship-to Country")
        {
        }
    }
}