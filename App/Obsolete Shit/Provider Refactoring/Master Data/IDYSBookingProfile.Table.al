table 11147641 "IDYS Booking Profile"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Booking Profile';
    DataCaptionFields = "Code";
    DrillDownPageID = "IDYS Booking Profiles";
    LookupPageID = "IDYS Booking Profiles";

    fields
    {
        field(1; "Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; "Carrier Code (External)"; Code[50])
        {
            Caption = 'Carrier Code (External)';
            TableRelation = "IDYS Carrier";
            DataClassification = CustomerContent;
        }

        field(3; "Carrier Name"; Text[50])
        {
            CalcFormula = Lookup("IDYS Carrier".Name where("Code" = field("Carrier Code (External)")));
            Caption = 'Carrier Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(4; "Service Level Code (Time)"; Code[50])
        {
            Caption = 'Service Level Code (Time)';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(5; "Service Level Code (Other)"; Code[50])
        {
            Caption = 'Service Level Code (Other)';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(6; Mapped; Boolean)
        {
            CalcFormula = Exist("IDYS Shipp. Agent Svc. Mapping" where("Carrier Code (External)" = field("Carrier Code (External)"),
                                                                        "Booking Profile Code (Ext.)" = field("Code")));
            Caption = 'Mapped';
            Editable = false;
            FieldClass = FlowField;
        }

        field(7; Description; Text[128])
        {
            Caption = 'Description';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code", "Carrier Code (External)")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", "Service Level Code (Time)", "Service Level Code (Time)", "Service Level Code (Other)", "Service Level Code (Other)")
        {
        }
    }
}