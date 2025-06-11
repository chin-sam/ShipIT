table 11147701 "IDYS Unit of Measure Mapping"
{
    Caption = 'Unit of Measure Mapping';
    DataCaptionFields = "Unit of Measure", Description;
    LookupPageId = "IDYS Unit of Measure Mappings";

    fields
    {
        field(1; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }

        field(2; Description; Text[50])
        {
            CalcFormula = Lookup("Unit of Measure".Description where("Code" = field("Unit of Measure")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }

        field(10; "Unit of Measure (External)"; Code[10])
        {
            Caption = 'Unit of Measure (External)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Unit of Measure")
        {
        }
    }
}