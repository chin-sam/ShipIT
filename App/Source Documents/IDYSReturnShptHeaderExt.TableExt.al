tableextension 11147649 "IDYS Return Shpt. Header Ext." extends "Return Shipment Header"
{
    fields
    {
        field(11147639; "IDYS E-Mail Type"; Code[127])
        {
            Caption = 'E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            Editable = false;
            DataClassification = SystemMetadata;
        }

        field(11147640; "IDYS Cost Center"; Code[127])
        {
            Caption = 'Cost Center';
            TableRelation = "IDYS Cost Center";
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(11147641; "IDYS Account No."; Code[32])
        {
            Caption = 'Account No. (Ship-to)';
            DataClassification = SystemMetadata;
        }
        field(11147642; "IDYS Preferred Pickup Date"; Date)
        {
            Caption = 'Preferred pickup date';
            DataClassification = CustomerContent;
        }

        field(11147643; "IDYS Preferred Delivery Date"; Date)
        {
            Caption = 'Preferred delivery date';
            DataClassification = CustomerContent;
        }
        field(11147644; "IDYS Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
        }

        field(11147645; "IDYS Shipping Agent Srv Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services" where("Shipping Agent Code" = field("IDYS Shipping Agent Code"));
        }

        field(11147646; "IDYS Tracking No."; Code[50])
        {
            Caption = 'ShipIT Tracking No.';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(11147647; "IDYS Tracking URL"; Text[250])
        {
            Caption = 'ShipIT Tracking URL';
            Editable = false;
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(11147648; "IDYS Account No. (Bill-to)"; Code[32])
        {
            Caption = 'Account No. (Bill-to)';
            DataClassification = SystemMetadata;
        }
        field(11147649; "IDYS Do Not Insure"; Boolean)
        {
            Caption = 'Do Not Insure';
            DataClassification = CustomerContent;
        }
        field(11147702; "IDYS Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            Editable = false;
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;
        }
        field(11147703; "IDYS Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            Editable = false;
            TableRelation = "IDYS Provider Booking Profile"."Entry No." where("Carrier Entry No." = field("IDYS Carrier Entry No."));
            DataClassification = CustomerContent;
        }
        field(11147704; "IDYS No. of Selected Services"; Integer)
        {
            Caption = 'No. of Selected Services (Other)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("IDYS Source Document Service" where("Table No." = const(6650), "Document No." = field("No.")));
        }
        field(11147705; "IDYS Provider"; Enum "IDYS Provider")
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Provider where("Entry No." = field("IDYS Carrier Entry No.")));
            Caption = 'Provider';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}