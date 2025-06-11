table 11147663 "IDYS DelHub API Services"
{
    Caption = 'nShift Ship API Services';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }

        field(2; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;
        }

        field(3; "Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            TableRelation = "IDYS Provider Booking Profile";
            DataClassification = CustomerContent;
        }
        field(5; "Actor Id"; Text[30])
        {
            CalcFormula = Lookup("IDYS Provider Carrier"."Actor Id" where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Actor Id';
            Editable = false;
            FieldClass = FlowField;
        }

        field(11; "Booking Profile Description"; Text[150])
        {
            CalcFormula = Lookup("IDYS Provider Booking Profile".Description where("Entry No." = field("Booking Profile Entry No."),
                                                                                    "Carrier Entry No." = field("Carrier Entry No.")));
            Caption = 'Booking Profile Description';
            Editable = false;
            FieldClass = FlowField;
        }

        field(12; "Carrier Name"; Text[100])
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Name where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Carrier Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(13; "Service Level Code (Other)"; Code[50])
        {
            Caption = 'Service Level Code (Other)';
            TableRelation = "IDYS Service Level (Other)";
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(15; "Service Level Code"; Code[50])
        {
            Caption = 'Service Level Code';
            FieldClass = FlowField;
            CalcFormula = lookup("IDYS Service Level (Other)"."Service Code" where(Code = field("Service Level Code (Other)")));
            Editable = false;
        }
        field(20; "Is Default"; Boolean)
        {
            Caption = 'Is Default';
            FieldClass = FlowField;
            CalcFormula = lookup("IDYS Service Level (Other)"."Is Default" where(Code = field("Service Level Code (Other)")));
            Editable = false;
        }
        field(21; "Read Only"; Boolean)
        {
            Caption = 'Read Only';
            FieldClass = FlowField;
            CalcFormula = lookup("IDYS Service Level (Other)"."Read Only" where(Code = field("Service Level Code (Other)")));
            Editable = false;
        }
        field(22; GroupId; Integer)
        {
            Caption = 'Group Id';
            FieldClass = FlowField;
            CalcFormula = lookup("IDYS Service Level (Other)".GroupId where(Code = field("Service Level Code (Other)")));
            Editable = false;
        }
        field(23; "Ship-to Countries"; Text[250])
        {
            Caption = 'Ship-to Countries';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with the supplemental table';
            ObsoleteTag = '22.0';
        }
        field(24; "Ship-to Countries (Denied)"; Text[250])
        {
            Caption = 'Ship-to Countries (Denied)';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with the supplemental table';
            ObsoleteTag = '22.0';
        }
        #region [Transport Order Services]
        field(50; Selected; Boolean)
        {
            Caption = 'Selected';
            DataClassification = SystemMetadata;
        }
        field(51; "Selected GroupID"; Integer)
        {
            Caption = 'GroupId';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(52; "Selected Read Only"; Boolean)
        {
            Caption = 'Read Only';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(53; IsGroup; Boolean)
        {
            Caption = 'Select from Group';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        #endregion
    }

    keys
    {
        key(PK; "Entry No.")
        {
        }
        key(Key1; "Carrier Entry No.", "Booking Profile Entry No.", IsGroup)
        {
        }
    }

    trigger OnInsert()
    var
        IDYSDelHubAPIServices: Record "IDYS DelHub API Services";
    begin
        if IDYSDelHubAPIServices.FindLast() then
            "Entry No." := IDYSDelHubAPIServices."Entry No." + 1
        else
            "Entry No." := 1;
    end;
}