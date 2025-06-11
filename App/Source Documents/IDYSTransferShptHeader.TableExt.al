tableextension 11147656 "IDYS Transfer Shpt. Header" extends "Transfer Shipment Header"
{
    fields
    {
        field(11147639; "IDYS E-Mail Type"; Code[127])
        {
            Caption = 'E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            DataClassification = SystemMetadata;
        }
        field(11147640; "IDYS Cost Center"; Code[50])
        {
            Caption = 'Cost Center';
            TableRelation = "IDYS Cost Center";
            DataClassification = SystemMetadata;
        }
        field(11147741; "IDYS Account No."; Code[32])
        {
            Caption = 'Account No. (Pick-up)';
            DataClassification = CustomerContent;
        }
        field(11147642; "IDYS Tracking No."; Code[50])
        {
            Caption = 'ShipIT Tracking No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11147643; "IDYS Tracking URL"; Text[250])
        {
            Caption = 'ShipIT Tracking URL';
            Editable = false;
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(11147744; "IDYS Account No. (Ship-to)"; Code[32])
        {
            Caption = 'Account No. (Ship-to)';
            DataClassification = CustomerContent;
        }
        field(11147745; "IDYS Do Not Insure"; Boolean)
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
            CalcFormula = count("IDYS Source Document Service" where("Table No." = const(5744), "Document No." = field("No.")));
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