table 11147648 "IDYS Currency Mapping"
{
    Caption = 'Currency Mapping';
    DataCaptionFields = "Currency Code", "Currency Description";
    LookupPageId = "IDYS Currency Mappings";

    fields
    {
        field(1; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }

        field(2; "Currency Code (External)"; Code[10])
        {
            Caption = 'Currency Code (External)';
            DataClassification = CustomerContent;
        }

        field(3; "Currency Description"; Text[30])
        {
            CalcFormula = Lookup(Currency.Description where("Code" = field("Currency Code")));
            Caption = 'Currency Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Currency Value"; Integer)
        {
            Caption = 'Currency Value (External)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Currency Code")
        {
        }

        key(Key2; "Currency Code (External)")
        {
        }
    }
}