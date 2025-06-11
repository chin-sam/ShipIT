table 11147640 "IDYS Carrier"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Carrier';
    DataCaptionFields = "Code", Name;
    DrillDownPageID = "IDYS Carriers";
    LookupPageID = "IDYS Carriers";

    fields
    {
        field(1; "Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }

        field(3; Mapped; Boolean)
        {
            CalcFormula = Exist("IDYS Shipping Agent Mapping" where("Carrier Code (External)" = field("Code")));
            Caption = 'Mapped';
            Editable = false;
            FieldClass = FlowField;
        }

        field(4; "Location Select"; Boolean)
        {
            Caption = 'Location Select';
            DataClassification = CustomerContent;
        }

        field(5; "Needs Manifesting"; Boolean)
        {
            Caption = 'Needs Manifesting';
            DataClassification = SystemMetadata;
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
        fieldgroup(DropDown; "Code", Name)
        {
        }
    }
}