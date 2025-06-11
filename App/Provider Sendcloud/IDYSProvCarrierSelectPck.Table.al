table 11147703 "IDYS Prov. Carrier Select Pck."
{
    Caption = 'Package Details';
    LookupPageId = "IDYS Prov. Carrier Select Pck.";

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

        field(3; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }

        field(4; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            TableRelation = "IDYS Provider Carrier";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(5; "Carrier Name"; Text[50])
        {
            Caption = 'Carrier Name';
            DataClassification = CustomerContent;
        }
        field(6; "Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            TableRelation = "IDYS Provider Booking Profile"."Entry No." where("Carrier Entry No." = field("Carrier Entry No."));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(7; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(8; Include; Boolean)
        {
            Caption = 'Include';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
            begin
                if Include then begin
                    IDYSProvCarrierSelectPck.SetRange("Transport Order No.", "Transport Order No.");
                    IDYSProvCarrierSelectPck.SetRange("Line No.", "Line No.");
                    IDYSProvCarrierSelectPck.SetRange("Parcel Identifier", "Parcel Identifier");
                    IDYSProvCarrierSelectPck.SetFilter("Entry No.", '<>%1', "Entry No.");
                    if not IDYSProvCarrierSelectPck.IsEmpty() then
                        IDYSProvCarrierSelectPck.ModifyAll(Include, false, true);
                end;
            end;
        }

        field(10; "Price as Decimal"; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
        }

        field(11; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }

        field(12; Provider; Enum "IDYS Provider")
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Provider where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Provider';
            Editable = false;
            FieldClass = FlowField;
        }

        field(49; "Min. Weight"; Decimal)
        {
            DataClassification = SystemMetadata;
            Caption = 'Minimal Weight';
            DecimalPlaces = 0 : 5;
        }
        field(50; "Max Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Max Weight';
            DecimalPlaces = 0 : 5;
        }

        field(54; "Parcel Identifier"; Code[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Parcel Identifier';
        }
        field(55; "Shipping Method Id"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Shipping Method Id';
        }
        #region [Transsmart Insurance]
        field(100; "Transsmart Insurance"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Transsmart Insurance';
        }
        field(101; "Charge Name"; Text[128])
        {
            DataClassification = CustomerContent;
            Caption = 'Charge Name';
        }
        field(102; "Charge Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Charge Amount';
        }
        #endregion
        #region [EasyPost]
        field(300; "Shipment Id"; Text[100])
        {
            Caption = 'Shipment Id';
            DataClassification = SystemMetadata;
        }

        field(301; "Package Id"; Text[100])
        {
            Caption = 'Package Id';
            DataClassification = SystemMetadata;
        }

        field(302; "Rate Id"; Text[100])
        {
            Caption = 'Rate Id';
            DataClassification = SystemMetadata;
        }
        #endregion

        #region [nShift]
        field(400; "Service Level Code (Other)"; Code[50])
        {
            Caption = 'Service Level Code (Other)';
            DataClassification = CustomerContent;
        }
        field(401; "Service Level Code"; Text[50])
        {
            CalcFormula = Lookup("IDYS Service Level (Other)"."Service Code" where(Code = field("Service Level Code (Other)")));
            Caption = 'Service Level Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(402; "Service Level Code Description"; Text[128])
        {
            CalcFormula = Lookup("IDYS Service Level (Other)".Description where(Code = field("Service Level Code (Other)")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        #endregion
        field(500; Surcharges; Boolean)
        {
            Caption = 'Surcharges';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Transport Order No.", "Line No.", "Entry No.")
        {
        }
    }

    trigger OnInsert()
    var
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
    begin
        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", "Transport Order No.");
        IDYSProvCarrierSelectPck.SetRange("Line No.", "Line No.");
        if IDYSProvCarrierSelectPck.FindLast() then
            "Entry No." := IDYSProvCarrierSelectPck."Entry No." + 1
        else
            "Entry No." := 1;
    end;
}