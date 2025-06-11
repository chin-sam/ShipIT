tableextension 11147641 "IDYS Purch. Header Extension" extends "Purchase Header"
{
    fields
    {
        // modify("Buy-from Vendor No.")        
        // {
        //     trigger OnAfterValidate()
        //     begin
        //         //Account No., Cost Center and E-Mail Type is managed by events ("IDYS Purchase Header Events")
        //     end;
        // }
        // modify("Pay-to Vendor No.")
        // {
        //     trigger OnAfterValidate()
        //     begin
        //         //Account No., Cost Center and E-Mail Type is managed by events ("IDYS Purchase Header Events")
        //     end;
        // }
        // modify("Order Address Code")
        // {
        //     trigger OnAfterValidate()
        //     begin
        //         //Account No., Cost Center and E-Mail Type is managed by events ("IDYS Purchase Header Events")
        //     end;
        // }        
        modify("Location Code")
        {
            trigger OnAfterValidate()
            var
                IDYSShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
            begin
                if CurrFieldNo = FieldNo("Location Code") then
                    if "IDYS Provider" = "IDYS Provider"::"Delivery Hub" then
                        if "Location Code" <> xRec."Location Code" then begin
                            if GuiAllowed() then
                                if not Confirm(StrSubstNo(ChangingShipFromShipToCountryQst, FieldCaption("Location Code")), true) then
                                    Error('');

                            if not IDYSShippAgentSvcMapping.Get("IDYS Shipping Agent Code", "IDYS Shipping Agent Srv Code") then
                                IDYSShippAgentSvcMapping.Init();
                            IDYSSourceDocumentService.SetDefaultServices(Database::"Purchase Header", "Document Type", "No.", IDYSShippAgentSvcMapping, IDYSGetShipFromCountryCode(), "Ship-to Country/Region Code", SystemId);
                        end;
            end;
        }
        modify("Ship-to Country/Region Code")
        {
            trigger OnAfterValidate()
            var
                IDYSShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
            begin
                if CurrFieldNo = FieldNo("Ship-to Country/Region Code") then
                    if "IDYS Provider" = "IDYS Provider"::"Delivery Hub" then
                        if "Ship-to Country/Region Code" <> xRec."Ship-to Country/Region Code" then begin
                            if GuiAllowed() then
                                if not Confirm(StrSubstNo(ChangingShipFromShipToCountryQst, FieldCaption("Ship-to Country/Region Code")), true) then
                                    Error('');

                            if not IDYSShippAgentSvcMapping.Get("IDYS Shipping Agent Code", "IDYS Shipping Agent Srv Code") then
                                IDYSShippAgentSvcMapping.Init();
                            IDYSSourceDocumentService.SetDefaultServices(Database::"Purchase Header", "Document Type", "No.", IDYSShippAgentSvcMapping, IDYSGetShipFromCountryCode(), "Ship-to Country/Region Code", SystemId);
                        end;
            end;
        }
        field(11147639; "IDYS E-Mail Type"; Code[127])
        {
            Caption = 'E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            DataClassification = SystemMetadata;
        }
        field(11147640; "IDYS Cost Center"; Code[127])
        {
            Caption = 'Cost Center';
            TableRelation = "IDYS Cost Center";
            DataClassification = SystemMetadata;
        }
        field(11147641; "IDYS Account No."; Code[32])
        {
            Caption = 'Account No. (Ship-to)';
            DataClassification = SystemMetadata;
        }
        field(11147642; "IDYS Account No. (Bill-to)"; Code[32])
        {
            Caption = 'Account No. (Bill-to)';
            DataClassification = SystemMetadata;
            ObsoleteState = Removed;
            ObsoleteReason = 'Incorrect field ID';
            ObsoleteTag = '24.0';
        }
        field(11147644; "IDYS Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            var
                ShippingAgentMapping: Record "IDYS Ship. Agent Mapping";
            begin
                if not ShippingAgentMapping.Get("IDYS Shipping Agent Code") then
                    ShippingAgentMapping.Init();

                Validate("IDYS Carrier Entry No.", ShippingAgentMapping."Carrier Entry No.");
            end;
        }
        field(11147645; "IDYS Shipping Agent Srv Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services"."Code" where("Shipping Agent Code" = field("IDYS Shipping Agent Code"));

            trigger OnValidate()
            var
                ShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
            begin
                if not ShippAgentSvcMapping.Get("IDYS Shipping Agent Code", "IDYS Shipping Agent Srv Code") then
                    ShippAgentSvcMapping.Init();
                Validate("IDYS Booking Profile Entry No.", ShippAgentSvcMapping."Booking Profile Entry No.");

                if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                    IDYSSourceDocumentService.SetDefaultServices(Database::"Purchase Header", "Document Type", "No.", ShippAgentSvcMapping, IDYSGetShipFromCountryCode(), "Ship-to Country/Region Code", SystemId);
            end;
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
        field(11147648; "IDYS Acc. No. (Bill-to)"; Code[32])
        {
            Caption = 'Account No. (Bill-to)';
            DataClassification = SystemMetadata;
        }
        field(11147649; "IDYS Do Not Insure"; Boolean)
        {
            Caption = 'Do Not Insure';
            DataClassification = CustomerContent;
        }
        field(11147701; "IDYS Whse Post Batch ID"; Guid)
        {
            Caption = 'Warehouse Post Batch ID';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(11147702; "IDYS Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            Editable = false;
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IDYSProviderCarrier: Record "IDYS Provider Carrier";
            begin
                Validate("IDYS Booking Profile Entry No.", 0);

                if "IDYS Carrier Entry No." <> 0 then begin
                    IDYSProviderCarrier.Get("IDYS Carrier Entry No.");
                    if "IDYS Provider" <> IDYSProviderCarrier.Provider then
                        Validate("IDYS Provider", IDYSProviderCarrier.Provider);
                end;
            end;
        }
        field(11147703; "IDYS Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            Editable = false;
            TableRelation = "IDYS Provider Booking Profile"."Entry No." where("Carrier Entry No." = field("IDYS Carrier Entry No."));
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ProviderBookingProfile: Record "IDYS Provider Booking Profile";
            begin
                if not ProviderBookingProfile.Get("IDYS Booking Profile Entry No.", "IDYS Carrier Entry No.") then
                    ProviderBookingProfile.Init();

                //"Service Level Code (Time)" := ProviderBookingProfile."Service Level Code (Time)";
                //"Service Level Code (Other)" := ProviderBookingProfile."Service Level Code (Other)";
            end;
        }
        field(11147704; "IDYS No. of Selected Services"; Integer)
        {
            Caption = 'No. of Selected Services (Other)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("IDYS Source Document Service" where("Table No." = const(38), "Document Type" = field("Document Type"), "Document No." = field("No.")));
        }
        field(11147705; "IDYS Provider"; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ProviderSetup: Record "IDYS Setup";
            begin
                if "IDYS Provider" <> xRec."IDYS Provider" then
                    // Clear Shiping Agent information whenever the provider is changed
                    if CurrFieldNo = FieldNo("IDYS Provider") then
                        Validate("IDYS Shipping Agent Code", '');

                ProviderSetup.GetProviderSetup("IDYS Provider");
                if ("IDYS Cost Center" = '') and (ProviderSetup."Default Cost Center" <> '') then
                    "IDYS Cost Center" := ProviderSetup."Default Cost Center";
                if ("IDYS E-Mail Type" = '') and (ProviderSetup."Default E-Mail Type" <> '') then
                    "IDYS E-Mail Type" := ProviderSetup."Default E-Mail Type";
            end;
        }
    }

    trigger OnAfterInsert()
    var
        DefaultProvider: Enum "IDYS Provider";
        IsHandled: Boolean;
    begin
        // Set default provider
        if IDYSDocumentMgt.GetDefaultProvider("IDYS Provider", DefaultProvider) then
            Validate("IDYS Provider", DefaultProvider);

        IsHandled := false;
        IDYSOnBeforeModifyOnAfterInsert(Rec, IsHandled);
        if not IsHandled then
            Modify();
    end;

    procedure IDYSGetShipFromCountryCode(): Code[10]
    var
        Location: Record Location;
    begin
        if not Location.Get("Location Code") then
            Location.Init();

        exit(Location."Country/Region Code");
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeModifyOnAfterInsert(var PurchaseHeader: Record "Purchase Header"; var DontModify: Boolean)
    begin
    end;

    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        ChangingShipFromShipToCountryQst: Label 'Changing the %1 will reset the selected services. \Do you want to continue? ', Comment = '%1 = Ship-to/Ship-from Country';
}