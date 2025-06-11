tableextension 11147654 "IDYS Return Rcpt. Header Ext." extends "Return Receipt Header"
{
    //NOTE - Obsolete - Removed due to wrongfully implemented flow

    fields
    {
        field(11147639; "IDYS E-Mail Type"; Code[127])
        {
            Caption = 'E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            Editable = false;
            DataClassification = SystemMetadata;
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(11147640; "IDYS Cost Center"; Code[127])
        {
            Caption = 'Cost Center';
            TableRelation = "IDYS Cost Center";
            Editable = false;
            DataClassification = SystemMetadata;
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(11147641; "IDYS Account No."; Code[32])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(11147642; "IDYS Shipping Agent Serv. Code"; Code[50])
        {
            Caption = 'Incorrect field ID';
            ObsoleteReason = 'Unused';
            ObsoleteState = Removed;
            TableRelation = "Shipping Agent Services"."Code" where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = SystemMetadata;
        }
        field(11147643; "IDYS Tracking URL"; Text[250])
        {
            Caption = 'ShipIT Tracking URL';
            Editable = false;
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(11147646; "IDYS Tracking No."; Code[50])
        {
            Caption = 'ShipIT Tracking No.';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(11147700; "IDYS Shipping Agent Serv Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services"."Code" where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = SystemMetadata;
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(11147702; "IDYS Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            Editable = false;
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(11147703; "IDYS Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            Editable = false;
            TableRelation = "IDYS Provider Booking Profile"."Entry No." where("Carrier Entry No." = field("IDYS Carrier Entry No."));
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(11147704; "IDYS No. of Selected Services"; Integer)
        {
            Caption = 'No. of Selected Services (Other)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("IDYS Source Document Service" where("Table No." = const(6660), "Document No." = field("No.")));
            ObsoleteState = Removed;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(11147705; "IDYS Provider"; Enum "IDYS Provider")
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Provider where("Entry No." = field("IDYS Carrier Entry No.")));
            Caption = 'Provider';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
    }
}