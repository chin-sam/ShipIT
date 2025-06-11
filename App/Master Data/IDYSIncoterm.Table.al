table 11147645 "IDYS Incoterm"
{
    Caption = 'Incoterm';
    DataCaptionFields = "Code", Description;
    LookupPageId = "IDYS Incoterms";

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

        field(3; Mapped; Boolean)
        {
            CalcFormula = Exist("IDYS Shipment Method Mapping" where("Incoterms Code" = field("Code")));
            Caption = 'Mapped';
            Editable = false;
            FieldClass = FlowField;
        }

        field(4; Default; Boolean)
        {
            Caption = 'Default';
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