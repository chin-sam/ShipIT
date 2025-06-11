table 11147674 "IDYS Provider Carrier"
{
    Caption = 'Carrier';
    DataCaptionFields = Provider, Name;
    DrillDownPageID = "IDYS Provider Carriers";
    LookupPageID = "IDYS Provider Carriers";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }

        field(2; Provider; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;
        }

        field(3; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }

        field(4; Mapped; Boolean)
        {
            CalcFormula = Exist("IDYS Ship. Agent Mapping" where("Carrier Entry No." = field("Entry No.")));
            Caption = 'Mapped';
            Editable = false;
            FieldClass = FlowField;
        }
        #region [Transsmart specific]
        field(25; "Transsmart Carrier Code"; Code[50])
        {
            Caption = 'Transsmart Carrier Code';
            DataClassification = CustomerContent;
        }

        field(26; "Location Select"; Boolean)
        {
            Caption = 'Location Select';
            DataClassification = CustomerContent;
        }

        field(27; "Needs Manifesting"; Boolean)
        {
            Caption = 'Needs Manifesting';
            DataClassification = SystemMetadata;
        }
        #endregion

        #region [nShift Ship]
        field(50; CarrierConceptID; Integer)
        {
            Editable = false;
            Caption = 'Carrier Concept ID';
            DataClassification = SystemMetadata;
        }
        field(51; "Actor Id"; Text[30])
        {
            Caption = 'Actor Id';
            DataClassification = CustomerContent;
            TableRelation = "IDYS Additional Actor";
        }
        #endregion
        #region [Sendcloud]
        field(100; "Shipping Methods"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Available Services';
            CalcFormula = count("IDYS Provider Booking Profile" where("Carrier Entry No." = field("Entry No."), Provider = field(Provider)));
            Editable = false;
        }

        field(101; "Use Volume Weight"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Use Volume Weight';
        }
        field(102; "Volume Weight Convers. Factor"; Integer)
        {
            Caption = 'Volume Weight Conversion Factor';
            MinValue = 0;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Conversion factors';
            ObsoleteTag = '21.0';
        }
        #endregion

        #region [EasyPost]
        field(125; "Carrier Id"; Text[100])
        {
            Editable = false;
            Caption = 'Carrier Id';
            DataClassification = SystemMetadata;
        }
        #endregion

        #region [Cargoson]
        field(135; CarrierId; Integer)
        {
            Editable = false;
            Caption = 'CarrierId';
            DataClassification = SystemMetadata;
        }
        #endregion


        #region [Conversion]
        field(150; "Conversion Factor (Mass)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Conversion Factor (Mass)';
            InitValue = 1;
            DecimalPlaces = 0 : 15;
        }

        field(151; "Rounding Precision (Mass)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision (Mass)';
            AutoFormatType = 1;
        }

        field(152; "Conversion Factor (Linear)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Conversion Factor (Linear)';
            InitValue = 1;
            DecimalPlaces = 0 : 15;
        }

        field(153; "Rounding Precision (Linear)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision (Linear)';
            AutoFormatType = 1;
        }

        field(154; "Conversion Factor (Volume)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Conversion Factor (Volume)';
            InitValue = 1;
            DecimalPlaces = 0 : 15;
        }

        field(155; "Rounding Precision (Volume)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision (Volume)';
            AutoFormatType = 1;
        }
        #endregion        
    }

    keys
    {
        key(PK; "Entry No.") { }
        key(Key1; Provider, CarrierConceptID) { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Provider, Name)
        {
        }
    }

    trigger OnInsert()
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
    begin
        if "Entry No." = 0 then
            if IDYSProviderCarrier.FindLast() then
                "Entry No." := IDYSProviderCarrier."Entry No." + 1
            else
                "Entry No." := 1;
    end;

    trigger OnDelete()
    var
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        RefIntegrityMgt: Codeunit "IDYS Ref. Integrity Mgt.";
    begin
        IDYSProviderBookingProfile.SetRange("Carrier Entry No.", "Entry No.");
        IDYSProviderBookingProfile.DeleteAll();

        RefIntegrityMgt.DeleteShippingAgentSvcMappings("Entry No.", 0);
    end;
}