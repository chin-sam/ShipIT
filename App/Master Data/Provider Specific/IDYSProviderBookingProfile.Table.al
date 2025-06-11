table 11147676 "IDYS Provider Booking Profile"
{
    Caption = 'Booking Profile';
    DataCaptionFields = Provider, Description;
    DrillDownPageID = "IDYS Provider Booking Profiles";
    LookupPageID = "IDYS Provider Booking Profiles";

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
            NotBlank = true;
        }

        field(3; Provider; Enum "IDYS Provider")
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Provider where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Provider';
            Editable = false;
            FieldClass = FlowField;
        }

        field(4; "Carrier Name"; Text[100])
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Name where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Carrier Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(5; "Service Level Code (Time)"; Code[50])
        {
            Caption = 'Service Level Code (Time)';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(6; "Service Level Code (Other)"; Code[50])
        {
            Caption = 'Service Level Code (Other)';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(7; Mapped; Boolean)
        {
            CalcFormula = Exist("IDYS Ship. Agent Svc. Mapping" where("Carrier Entry No." = field("Carrier Entry No."),
                                                                        "Booking Profile Entry No." = field("Entry No.")));
            Caption = 'Mapped';
            Editable = false;
            FieldClass = FlowField;
        }

        field(8; Description; Text[150])
        {
            Caption = 'Description';
            Editable = false;
            DataClassification = CustomerContent;
        }
        #region [Transsmart specific]
        field(25; "Transsmart Booking Prof. Code"; Code[50])
        {
            Caption = 'Booking Profile Code';
            DataClassification = CustomerContent;
        }
        #endregion
        #region [nShift Ship]
        field(50; ProdConceptID; Integer)
        {
            Caption = 'Product Concept Id';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(51; AllowDG; Boolean)
        {
            Caption = 'AllowDG';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(52; AllowCOD; Boolean)
        {
            Caption = 'AllowCOD';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(53; "Subcarrier Name"; Text[100])
        {
            Caption = 'Carrier Name';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(54; "Actor Id"; Text[30])
        {
            CalcFormula = Lookup("IDYS Provider Carrier"."Actor Id" where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Actor Id';
            Editable = false;
            FieldClass = FlowField;
        }
        field(55; ProdCSID; Integer)
        {
            Caption = 'ProdCSID';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        #endregion
        #region [Sendcloud]
        field(100; Id; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Id';
        }
        field(101; "Min. Weight"; Decimal)
        {
            DataClassification = SystemMetadata;
            Caption = 'Minimal Weight (kg)';
            DecimalPlaces = 0 : 5;
        }
        field(102; "Max. Weight"; Decimal)
        {
            DataClassification = SystemMetadata;
            Caption = 'Maximum Weight (kg)';
            DecimalPlaces = 0 : 5;
        }
        field(103; "Is Return"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Is Return';
        }
        #endregion
        #region [Cargoson]
        field(150; ServiceId; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Service Id';
        }
        field(151; ServiceType; Enum "IDYS Cargoson Service Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Service Type';
        }
        #endregion
        field(500; Selected; Boolean)
        {
            Caption = 'Selected';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.", "Carrier Entry No.") { }
        key(Key1; ProdCSID) { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Provider, "Carrier Name", Description, "Service Level Code (Time)", "Service Level Code (Time)", "Service Level Code (Other)", "Service Level Code (Other)") { }
    }

    trigger OnInsert()
    var
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
    begin
        if "Entry No." = 0 then begin
            IDYSProviderBookingProfile.SetRange("Carrier Entry No.", "Carrier Entry No.");
            if IDYSProviderBookingProfile.FindLast() then
                "Entry No." := IDYSProviderBookingProfile."Entry No." + 1
            else
                "Entry No." := 1;
        end;
    end;

    trigger OnDelete()
    var
        RefIntegrityMgt: Codeunit "IDYS Ref. Integrity Mgt.";
    begin
        RefIntegrityMgt.DeleteShippingAgentSvcMappings("Carrier Entry No.", "Entry No.");
    end;
}