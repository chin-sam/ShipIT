table 11147658 "IDYS Carrier Select"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Carrier Select';
    LookupPageId = "IDYS Carrier Select";

    fields
    {
        field(1; "Transport Order No."; Code[20])
        {
            Caption = 'Transport Order No.';
            TableRelation = "IDYS Transport Order Header";
            DataClassification = CustomerContent;
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        field(3; "Carrier Code"; Code[50])
        {
            Caption = 'Carrier Code';
            TableRelation = "IDYS Carrier";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(4; "Carrier Name"; Text[50])
        {
            Caption = 'Carrier Name';
            DataClassification = CustomerContent;
        }

        field(5; "Pickup Date"; Date)
        {
            Caption = 'Pickup Date';
            DataClassification = CustomerContent;
        }

        field(6; "Delivery Date"; Date)
        {
            Caption = 'Delivery Date';
            DataClassification = CustomerContent;
        }

        field(7; "Delivery Time"; Time)
        {
            Caption = 'Delivery Time';
            DataClassification = CustomerContent;
        }

        field(8; Price; Text[20])
        {
            Caption = 'Price';
            ObsoleteState = Removed;
            ObsoleteReason = 'Wrong data type.';
            DataClassification = CustomerContent;
        }

        field(9; "Service Level Time"; Text[50])
        {
            Caption = 'Service Level Time';
            DataClassification = CustomerContent;
        }

        field(10; "Service Level Other"; Text[50])
        {
            Caption = 'Service Level Other';
            DataClassification = CustomerContent;
        }

        field(11; "Service Level Code (Time)"; Code[50])
        {
            Caption = 'Service Level Code (Time)';
            TableRelation = "IDYS Service Level (Time)".Code;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(12; "Price as Decimal"; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
        }

        field(13; "Booking Profile Code (Ext.)"; Code[50])
        {
            Caption = 'Booking Profile Code (Ext.)';
            TableRelation = "IDYS Booking Profile"."Code" where("Carrier Code (External)" = field("Carrier Code"));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(14; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(15; "Service Level Code (Other)"; Code[50])
        {
            Caption = 'Service Level Code (Other)';
            TableRelation = "IDYS Service Level (Other)".Code;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(16; "Transit Time (Hours)"; Text[20])
        {
            Caption = 'Transit Time (Hours)';
            DataClassification = CustomerContent;
        }

        field(17; "Transit Time Description"; Text[100])
        {
            Caption = 'Transit Time Description';
            DataClassification = CustomerContent;
        }

        field(18; "Calculated Weight"; Text[20])
        {
            Caption = 'Calculated Weight';
            DataClassification = CustomerContent;
        }

        field(19; "Calculated Weight UOM"; Code[20])
        {
            Caption = 'Calculated Weight UOM';
            DataClassification = CustomerContent;
        }

        field(20; Mapped; Boolean)
        {
            CalcFormula = Exist("IDYS Shipp. Agent Svc. Mapping" where("Carrier Code (External)" = field("Carrier Code"), "Booking Profile Code (Ext.)" = field("Booking Profile Code (Ext.)")));
            Caption = 'Mapped';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Not Available"; Boolean)
        {
            Editable = false;
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Transport Order No.", "Line No.")
        {
        }
    }
}