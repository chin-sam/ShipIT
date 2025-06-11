tableextension 11147639 "IDYS Sales Header Extension" extends "Sales Header"
{
    fields
    {
        // modify("Sell-to Customer No.")
        // {
        //     trigger OnAfterValidate()
        //     begin
        //         //Account No., Cost Center and E-Mail Type is managed by events ("IDYS Sales Header Events")
        //     end;
        // }
        // modify("Bill-to Customer No.")
        // {
        //     trigger OnAfterValidate()
        //     begin
        //         //Account No., Cost Center and E-Mail Type is managed by events ("IDYS Sales Header Events")
        //     end;
        // }
        // modify("Ship-to Code")
        // {
        //     trigger OnAfterValidate()
        //     begin
        //         //Account No., Cost Center and E-Mail Type is managed by events ("IDYS Sales Header Events")
        //     end;
        // }
        modify("Shipping Agent Code")
        {
            trigger OnAfterValidate()
            var
                ShippingAgentMapping: Record "IDYS Ship. Agent Mapping";
                IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
            begin
                if not ShippingAgentMapping.Get("Shipping Agent Code") then
                    ShippingAgentMapping.Init();

                Validate("IDYS Carrier Entry No.", ShippingAgentMapping."Carrier Entry No.");
                "IDYS Freight Amount" := 0;

                if IsTemporary() then
                    exit;

                if IsInsertMode() then
                    exit;

                if SkipPackageValidation then
                    exit;

                if "IDYS Provider" <> "IDYS Provider"::EasyPost then
                    exit;

                // Clear packages (Shipping Agent level)
                IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
                IDYSSourceDocumentPackage.SetRange("Document Type", "Document Type");
                IDYSSourceDocumentPackage.SetRange("Document No.", "No.");
                IDYSSourceDocumentPackage.SetFilter("Book. Prof. Package Type Code", '<>%1', ''); // only agent/carrier related
                if not IDYSSourceDocumentPackage.IsEmpty() then
                    IDYSSourceDocumentPackage.DeleteAll();

                InsertDefaultSourceDocumentPackage();
            end;
        }
        modify("Shipping Agent Service Code")
        {
            trigger OnAfterValidate()
            var
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
                ShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
                IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
            begin
                if not ShippAgentSvcMapping.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                    ShippAgentSvcMapping.Init();
                Validate("IDYS Booking Profile Entry No.", ShippAgentSvcMapping."Booking Profile Entry No.");

                if IsTemporary() then
                    exit;

                if IsInsertMode() then
                    exit;

                if "IDYS Provider" <> "IDYS Provider"::"Delivery Hub" then
                    exit;

                if "Document Type" in ["Document Type"::Quote, "Document Type"::Order, "Document Type"::"Return Order"] then
                    IDYSSourceDocumentService.SetDefaultServices(Database::"Sales Header", "Document Type", "No.", ShippAgentSvcMapping, IDYSGetShipFromCountryCode(), "Ship-to Country/Region Code", SystemId);

                if SkipPackageValidation then
                    exit;

                // Clear packages (Shipping Agent Service level)
                IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
                IDYSSourceDocumentPackage.SetRange("Document Type", "Document Type");
                IDYSSourceDocumentPackage.SetRange("Document No.", "No.");
                if not IDYSSourceDocumentPackage.IsEmpty() then
                    IDYSSourceDocumentPackage.DeleteAll();

                InsertDefaultSourceDocumentPackage();
            end;
        }
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

                            if not IDYSShippAgentSvcMapping.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                                IDYSShippAgentSvcMapping.Init();
                            IDYSSourceDocumentService.SetDefaultServices(Database::"Sales Header", "Document Type", "No.", IDYSShippAgentSvcMapping, IDYSGetShipFromCountryCode(), "Ship-to Country/Region Code", SystemId);
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

                            if not IDYSShippAgentSvcMapping.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                                IDYSShippAgentSvcMapping.Init();
                            IDYSSourceDocumentService.SetDefaultServices(Database::"Sales Header", "Document Type", "No.", IDYSShippAgentSvcMapping, IDYSGetShipFromCountryCode(), "Ship-to Country/Region Code", SystemId);
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
        field(11147644; "IDYS Freight Amount"; Decimal)
        {
            Caption = 'Freight Amount';
            DataClassification = CustomerContent;
        }
        field(11147645; "IDYS Copy Source Doc. Packages"; Boolean)
        {
            Caption = 'Copy Source Doc. Packages';
            DataClassification = SystemMetadata;
        }
        field(11147646; "IDYS Tracking No"; Code[50])
        {
            Caption = 'ShipIT Tracking No.';
            Editable = false;
            ObsoleteReason = 'Placeholder for field on Return Rcpt Header';
            ObsoleteState = Removed;
            DataClassification = CustomerContent;
        }
        field(11147647; "IDYS Account No. (Bill-to)"; Code[32])
        {
            Caption = 'Account No. (Bill-to)';
            DataClassification = SystemMetadata;
        }
        field(11147648; "IDYS Do Not Insure"; Boolean)
        {
            Caption = 'Do Not Insure';
            DataClassification = CustomerContent;
        }
        field(11147700; "IDYS Shipping Agent Serv Code"; Code[10])
        {
            Caption = 'Reserved field';
            ObsoleteReason = 'Placeholder for field on Return Rcpt Header';
            ObsoleteState = Removed;
            TableRelation = "Shipping Agent Services"."Code" where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = SystemMetadata;
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
        }
        field(11147704; "IDYS No. of Selected Services"; Integer)
        {
            Caption = 'No. of Selected Services (Other)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("IDYS Source Document Service" where("Table No." = const(36), "Document Type" = field("Document Type"), "Document No." = field("No.")));
        }
        field(11147705; "IDYS Provider"; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ProviderSetup: Record "IDYS Setup";
                IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
            begin
                if "IDYS Provider" <> xRec."IDYS Provider" then
                    // Clear Shiping Agent information whenever the provider is changed
                    if CurrFieldNo = FieldNo("IDYS Provider") then
                        Validate("Shipping Agent Code", '');

                ProviderSetup.GetProviderSetup("IDYS Provider");
                if ("IDYS Cost Center" = '') and (ProviderSetup."Default Cost Center" <> '') then //Apply defaults when not set on Ship-to / Bill-to level
                    "IDYS Cost Center" := ProviderSetup."Default Cost Center";
                if ("IDYS E-Mail Type" = '') and (ProviderSetup."Default E-Mail Type" <> '') then //Apply defaults when not set on Ship-to / Sell-to level
                    "IDYS E-Mail Type" := ProviderSetup."Default E-Mail Type";

                if IsTemporary() then
                    exit;

                if IsInsertMode() then
                    exit;

                if not ("Document Type" in ["Document Type"::Quote, "Document Type"::Order, "Document Type"::"Return Order"]) then
                    exit;

                IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
                IDYSSourceDocumentPackage.SetRange("Document Type", "Document Type");
                IDYSSourceDocumentPackage.SetRange("Document No.", "No.");
                if "IDYS Provider" <> xRec."IDYS Provider" then begin

                    // Clear packages (Provider level)
                    if not IDYSSourceDocumentPackage.IsEmpty() then
                        IDYSSourceDocumentPackage.DeleteAll();

                    if xRec."IDYS Provider" = xRec."IDYS Provider"::"Delivery Hub" then begin
                        IDYSSourceDocumentService.SetRange("Table No.", Database::"Sales Header");
                        IDYSSourceDocumentService.SetRange("Document No.", "No.");
                        if not IDYSSourceDocumentService.IsEmpty() then
                            IDYSSourceDocumentService.DeleteAll();
                    end;
                end else
                    if not IDYSSourceDocumentPackage.IsEmpty then
                        exit;

                // Insert default package (Provider & Shipping Agent level)
                InsertDefaultSourceDocumentPackage();
            end;
        }
    }

    trigger OnAfterInsert()
    var
        SalesHeader: Record "Sales Header";
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
        DefaultProvider: Enum "IDYS Provider";
        IsHandled: Boolean;
        Suspended: Boolean;
        WasSuspended: Boolean;
    begin
        // Most common scenario is that before the insert of the sales header, the Sell-to Customer No. is validated
        // That means we cannot insert default packages before the sales header is inserted
        // This code block is dedicated only to revalidating the shipping agent information
        // std BC Sets Shipping Agent Code & - Service without validating the fields

        if not IsTemporary() then begin
            IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
            IDYSSourceDocumentPackage.SetRange("Document Type", Rec."Document Type");
            IDYSSourceDocumentPackage.SetRange("Document No.", Rec."No.");
            if not IDYSSourceDocumentPackage.IsEmpty then
                exit;
        end;

        IDYSOnBeforeShippingAgentValidationOnAfterInsert(Rec, IsHandled);
        if not IsHandled then begin
            SalesHeader := Rec;
            if Status <> Status::Open then begin //this is required when a temp sales header is inserted in a released state
                Suspended := true;
#if BC17EORI
                WasSuspended := StatusCheckSuspended; //17.1 - 17.3 dont have a GetStatusCheckSuspended
#else 
                WasSuspended := GetStatusCheckSuspended();
#endif
                SuspendStatusCheck(Suspended);
            end;
            Validate("Shipping Agent Code", SalesHeader."Shipping Agent Code");
            Validate("Shipping Agent Service Code", SalesHeader."Shipping Agent Service Code");
            if Suspended and not WasSuspended then //restore Suspended state to what it was before
                SuspendStatusCheck(false);
        end;
        IDYSOnAfterShippingAgentValidationOnAfterInsert(Rec);

        // Set default provider
        if IDYSDocumentMgt.GetDefaultProvider("IDYS Provider", DefaultProvider) then
            Validate("IDYS Provider", DefaultProvider);

        // Insert default package (Provider & Shipping Agent level)
        IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        IDYSSourceDocumentPackage.SetRange("Document Type", Rec."Document Type");
        IDYSSourceDocumentPackage.SetRange("Document No.", Rec."No.");
        if IDYSSourceDocumentPackage.IsEmpty then
            InsertDefaultSourceDocumentPackage();

        IsHandled := false;
        IDYSOnBeforeModifyOnAfterInsert(Rec, IsHandled);
        if not IsHandled then
            Modify();
    end;

    local procedure InsertDefaultSourceDocumentPackage()
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
        DefaultPackageTypeCode: Code[50];
        IProvider: Interface "IDYS IProvider";
        IsHandled: Boolean;
    begin
        IDYSOnBeforeInsertDefaultSourceDocumentPackage(Rec, IsHandled);
        if IsHandled then
            exit;

        if IsTemporary() then
            exit;

        if not ("Document Type" in ["Document Type"::Order, "Document Type"::Quote, "Document Type"::"Return Order"]) then
            exit;

        IProvider := "IDYS Provider";
        if not IProvider.IsEnabled(false) then
            exit;

        if not IDYSSetup.Get() then
            exit;

        if not IDYSSetup."Auto. Add One Default Package" then
            exit;

        case "IDYS Provider" of
            "IDYS Provider"::"Delivery Hub",
            "IDYS Provider"::EasyPost:
                begin
                    DefaultPackageTypeCode := IProvider.GetDefaultPackage("IDYS Carrier Entry No.", "IDYS Booking Profile Entry No.");
                    if DefaultPackageTypeCode = '' then
                        exit;

                    Clear(IDYSSourceDocumentPackage);
                    IDYSSourceDocumentPackage.SetRange("Carrier Entry No. Filter", Rec."IDYS Carrier Entry No.");
                    IDYSSourceDocumentPackage.SetRange("Booking P. Entry No. Filter", IDYSProviderMgt.GetBookingProfileEntryNo("IDYS Carrier Entry No.", "IDYS Booking Profile Entry No."));
                    IDYSSourceDocumentPackage.Init();
                    IDYSSourceDocumentPackage.Validate("Table No.", Database::"Sales Header");
                    IDYSSourceDocumentPackage.Validate("Document Type", "Document Type");
                    IDYSSourceDocumentPackage.Validate("Document No.", "No.");
                    IDYSSourceDocumentPackage.Validate("Book. Prof. Package Type Code", DefaultPackageTypeCode);
                    IDYSSourceDocumentPackage.Validate("System Created Entry", true);
                    IDYSSourceDocumentPackage.Insert(true);
                end;
            else begin
                DefaultPackageTypeCode := IProvider.GetDefaultPackage("IDYS Carrier Entry No.", "IDYS Booking Profile Entry No.");
                if DefaultPackageTypeCode = '' then
                    exit;

                Clear(IDYSSourceDocumentPackage);
                IDYSSourceDocumentPackage.SetRange("Provider Filter", "IDYS Provider");
                IDYSSourceDocumentPackage.Init();
                IDYSSourceDocumentPackage.Validate("Table No.", Database::"Sales Header");
                IDYSSourceDocumentPackage.Validate("Document Type", "Document Type");
                IDYSSourceDocumentPackage.Validate("Document No.", "No.");
                IDYSSourceDocumentPackage.Validate("Provider Package Type Code", DefaultPackageTypeCode);
                IDYSSourceDocumentPackage.Validate("System Created Entry", true);
                IDYSSourceDocumentPackage.Insert(true);
            end;
        end;
    end;

    local procedure IsInsertMode(): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader := Rec;
        SalesHeader.SetRecFilter();
        exit(SalesHeader.IsEmpty());
    end;

    procedure IDYSSetSkipPackageValidation(Skip: Boolean)
    begin
        SkipPackageValidation := Skip;
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
    local procedure IDYSOnBeforeShippingAgentValidationOnAfterInsert(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSOnAfterShippingAgentValidationOnAfterInsert(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeModifyOnAfterInsert(var SalesHeader: Record "Sales Header"; var DontModify: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeInsertDefaultSourceDocumentPackage(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        SkipPackageValidation: Boolean;
        ChangingShipFromShipToCountryQst: Label 'Changing the %1 will reset the selected services. \Do you want to continue? ', Comment = '%1 = Ship-to/Ship-from Country';

}