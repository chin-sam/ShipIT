table 11147656 "IDYS Shipping Agent Mapping"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Shipping Agent Mapping';
    DataCaptionFields = "Shipping Agent Code", "Shipping Agent Name";
    DrillDownPageID = "IDYS Shipping Agent Mappings";
    LookupPageID = "IDYS Shipping Agent Mappings";

    fields
    {
        field(1; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            NotBlank = true;
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
        }

        field(2; "Carrier Code (External)"; Code[50])
        {
            Caption = 'Carrier Code (External)';
            TableRelation = "IDYS Carrier";
            DataClassification = CustomerContent;
        }

        field(3; "Shipping Agent Name"; Text[50])
        {
            CalcFormula = Lookup("Shipping Agent".Name where(Code = field("Shipping Agent Code")));
            Caption = 'Shipping Agent Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Shipping Agent Code")
        {
        }
        key(Key2; "Carrier Code (External)")
        {
        }
    }
}