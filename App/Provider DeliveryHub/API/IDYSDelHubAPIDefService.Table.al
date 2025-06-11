table 11147710 "IDYS DelHub API Def. Service"
{
    Caption = 'nShift Ship API Def. Service';
    fields
    {
        field(1; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
        }
        field(2; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = CustomerContent;
        }
        field(3; "DelHub API Service Entry No."; Integer)
        {
            Caption = 'nShift Ship API Service Entry No.';
            TableRelation = "IDYS DelHub API Services";
            DataClassification = CustomerContent;
        }
        field(13; "Service Level Code (Other)"; Code[50])
        {
            Caption = 'Service Level Code (Other)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("IDYS DelHub API Services"."Service Level Code (Other)" where("Entry No." = field("DelHub API Service Entry No.")));
        }
        field(14; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("IDYS DelHub API Services"."Country Code" where("Entry No." = field("DelHub API Service Entry No.")));
        }
        field(15; "Ship-to Countries"; Text[250])
        {
            Caption = 'Ship-to Countries';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("IDYS DelHub API Services"."Ship-to Countries" where("Entry No." = field("DelHub API Service Entry No.")));
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with the supplemental table';
            ObsoleteTag = '22.0';
        }
        field(16; "Ship-to Countries (Denied)"; Text[250])
        {
            Caption = 'Ship-to Countries (Denied)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("IDYS DelHub API Services"."Ship-to Countries (Denied)" where("Entry No." = field("DelHub API Service Entry No.")));
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with the supplemental table';
            ObsoleteTag = '22.0';
        }
        field(100; "User Default"; Boolean)
        {
            Caption = 'User Default';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Shipping Agent Code", "Shipping Agent Service Code", "DelHub API Service Entry No.")
        {
        }
    }
}
