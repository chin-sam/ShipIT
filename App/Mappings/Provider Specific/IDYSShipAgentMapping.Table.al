table 11147675 "IDYS Ship. Agent Mapping"
{
    Caption = 'Shipping Agent Mapping';
    DataCaptionFields = "Shipping Agent Code", "Shipping Agent Name";
    DrillDownPageID = "IDYS Ship. Agent Mappings";
    LookupPageID = "IDYS Ship. Agent Mappings";

    fields
    {
        field(1; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            NotBlank = true;
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
        }

        field(2; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;
        }

        field(3; "Shipping Agent Name"; Text[50])
        {
            CalcFormula = Lookup("Shipping Agent".Name where(Code = field("Shipping Agent Code")));
            Caption = 'Shipping Agent Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(4; Provider; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Carrier Name", '');
            end;
        }
        field(5; "Carrier Name"; Text[100])
        {
            Caption = 'Carrier Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                IDYSProviderCarrier: Record "IDYS Provider Carrier";
                IDYSProviderCarriers: Page "IDYS Provider Carriers";
            begin
                IDYSProviderCarrier.SetCurrentKey(Provider, CarrierConceptID);
                IDYSProviderCarrier.SetRange(Provider, Provider);
                IDYSProviderCarriers.SetTableView(IDYSProviderCarrier);
                IDYSProviderCarriers.LookupMode(true);
                if IDYSProviderCarriers.RunModal() = Action::LookupOK then begin
                    IDYSProviderCarriers.GetRecord(IDYSProviderCarrier);
                    "Carrier Entry No." := IDYSProviderCarrier."Entry No.";
                    "Carrier Name" := IDYSProviderCarrier.Name;
                end;
            end;

            trigger OnValidate()
            var
                IDYSProviderCarrier: Record "IDYS Provider Carrier";
            begin
                if "Carrier Name" <> '' then begin
                    IDYSProviderCarrier.SetRange(Provider, Provider);
                    IDYSProviderCarrier.SetRange(Name, "Carrier Name");
                    if IDYSProviderCarrier.Count > 1 then
                        Error(MultipleProvidersFoundErr);
                    IDYSProviderCarrier.FindLast();
                    "Carrier Entry No." := IDYSProviderCarrier."Entry No.";
                    "Carrier Name" := IDYSProviderCarrier.Name;
                end else
                    "Carrier Entry No." := 0
            end;
        }
        #region [nShift Ship]
        field(100; "Blank Invoice Address"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Blank Invoice Address';
        }
        #endregion
        #region [Transsmart]
        field(150; Insure; Boolean)
        {
            Caption = 'Insure';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
            begin
                IDYSShipAgentSvcMapping.SetRange("Shipping Agent Code", "Shipping Agent Code");
                IDYSShipAgentSvcMapping.ModifyAll(Insure, Insure);
            end;

        }
        #endregion
    }

    keys
    {
        key(PK; "Shipping Agent Code")
        {
        }
        key(Key2; "Carrier Entry No.")
        {
        }
    }

    trigger OnDelete()
    var
        RefIntegrityMgt: Codeunit "IDYS Ref. Integrity Mgt.";
    begin
        RefIntegrityMgt.DeleteShippingAgentSvcMappings("Shipping Agent Code", '');
    end;

    var
        MultipleProvidersFoundErr: Label 'Multiple providers found by the name field. Please use the assist edit button to select a provider.';
}