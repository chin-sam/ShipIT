table 11147681 "IDYS Provider Carrier Select"
{
    Caption = 'Carrier Select';
    LookupPageId = "IDYS Provider Carrier Select";

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

        field(3; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            TableRelation = "IDYS Provider Carrier";
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

        field(13; "Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Code (Ext.)';
            TableRelation = "IDYS Provider Booking Profile"."Entry No." where("Carrier Entry No." = field("Carrier Entry No."));
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
            CalcFormula = Exist("IDYS Ship. Agent Svc. Mapping" where("Carrier Entry No." = field("Carrier Entry No."),
                                                                        "Booking Profile Entry No." = field("Booking Profile Entry No.")));
            Caption = 'Mapped';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; Provider; Enum "IDYS Provider")
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Provider where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Provider';
            Editable = false;
            FieldClass = FlowField;
        }
        field(22; "Not Available"; Boolean)
        {
            Editable = false;
            DataClassification = SystemMetadata;
        }

        #region [Transsmart specific]
        field(25; "Transsmart Carrier Code"; Code[50])
        {
            Caption = 'nShift Transsmart Carrier Code';
            DataClassification = CustomerContent;
        }
        field(26; Insure; Boolean)
        {
            Caption = 'Insure';
            DataClassification = CustomerContent;
        }
        field(27; "Insurance Amount"; Decimal)
        {
            Caption = 'Insurance Amount';
            DataClassification = CustomerContent;
        }
        field(28; "Insurance Company"; Text[50])
        {
            Caption = 'Insurance Company';
            DataClassification = CustomerContent;
        }
        field(29; "Insurance Charges"; Boolean)
        {
            CalcFormula = exist("IDYS Prov. Carrier Select Pck." where("Transport Order No." = field("Transport Order No.")));
            Caption = 'Insurance Charges';
            Editable = false;
            FieldClass = FlowField;
        }
        #endregion

        #region [nShift Ship]
        field(30; "Package Type Code"; Code[50])
        {
            Caption = 'Package Type Code';
            DataClassification = CustomerContent;
            TableRelation = "IDYS BookingProf. Package Type"."Package Type Code" where("Carrier Entry No." = field("Carrier Entry No."), "Booking Profile Entry No." = field("Booking Profile Entry No."));
        }
        field(31; "Package Type Description"; Text[128])
        {
            Caption = 'Package Type';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("IDYS BookingProf. Package Type".Description where("Carrier Entry No." = field("Carrier Entry No."), "Booking Profile Entry No." = field("Booking Profile Entry No."), "Package Type Code" = field("Package Type Code")));
        }
        field(32; "Actor Id"; Text[30])
        {
            CalcFormula = Lookup("IDYS Provider Carrier"."Actor Id" where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Actor Id';
            Editable = false;
            FieldClass = FlowField;
        }
        #endregion

        #region [Sendcloud]
        field(50; "Max Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Max Weight';
            DecimalPlaces = 0 : 5;
        }
        field(51; Id; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Id';
        }

        field(52; Details; Boolean)
        {
            CalcFormula = exist("IDYS Prov. Carrier Select Pck." where("Transport Order No." = field("Transport Order No."),
                                                                        "Line No." = field("Line No.")));
            Caption = 'Details';
            Editable = false;
            FieldClass = FlowField;
        }

        field(53; "Calculated Price"; Decimal)
        {
            CalcFormula = sum("IDYS Prov. Carrier Select Pck."."Price as Decimal" where("Transport Order No." = field("Transport Order No."),
                                                                                        "Line No." = field("Line No."),
                                                                                        Include = const(true)));
            Caption = 'Price';
            Editable = false;
            FieldClass = FlowField;
        }

        field(54; "Calculated Carrier Name"; Text[100])
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Name where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Carrier Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(55; "Svc. Mapping RecordId"; RecordId)
        {
            DataClassification = SystemMetadata;
        }
        field(56; "Shipping Agent Service Desc."; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Shipping Agent Service Desc.';
            Editable = false;
        }
        #endregion
        #region [Cargoson]
        field(60; "Transit Time (Days)"; Text[20])
        {
            Caption = 'Transit Time (Days)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(61; Surcharges; Boolean)
        {
            CalcFormula = exist("IDYS Prov. Carrier Select Pck." where("Transport Order No." = field("Transport Order No.")));
            Caption = 'Surcharges';
            Editable = false;
            FieldClass = FlowField;
        }
        #endregion
    }

    keys
    {
        key(PK; "Transport Order No.", "Line No.")
        {
        }
        key(Key1; "Carrier Entry No.", "Booking Profile Entry No.")
        {
        }
        key(Key2; "Price as Decimal")
        {
        }
    }
}