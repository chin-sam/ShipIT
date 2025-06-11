tableextension 11147655 "IDYS Transfer Header Extension" extends "Transfer Header"
{
    fields
    {
        modify("Transfer-from Code")
        {
            trigger OnAfterValidate()
            var
                Location: Record Location;
                IDYSProviderSetup: Record "IDYS Provider Setup";
            begin
                if ("Transfer-from Code" <> '') and IDYSProviderSetup.Get("IDYS Provider"::Transsmart) and IDYSProviderSetup.Enabled then begin
                    Location.Get("Transfer-From Code");
                    Validate("IDYS Cost Center", Location."IDYS Cost Center");
                    Validate("IDYS E-Mail Type", Location."IDYS E-Mail Type");
                    Validate("IDYS Account No.", Location."IDYS Account No.");  // Pick-up
                end else begin
                    Clear("IDYS Cost Center");
                    Clear("IDYS E-Mail Type");
                    Clear("IDYS Account No.");
                end;
            end;
        }
        modify("Transfer-to Code")
        {
            trigger OnAfterValidate()
            var
                Location: Record Location;
                IDYSProviderSetup: Record "IDYS Provider Setup";
            begin
                if ("Transfer-to Code" <> '') and IDYSProviderSetup.Get("IDYS Provider"::Transsmart) and IDYSProviderSetup.Enabled then begin
                    Location.Get("Transfer-From Code");
                    Validate("IDYS Cost Center", Location."IDYS Cost Center");
                    Validate("IDYS E-Mail Type", Location."IDYS E-Mail Type");
                    Validate("IDYS Account No. (Ship-to)", Location."IDYS Account No.");  // Ship-to
                end else begin
                    Clear("IDYS Cost Center");
                    Clear("IDYS E-Mail Type");
                    Clear("IDYS Account No. (Ship-to)");
                end;
            end;
        }
        modify("Shipping Agent Code")
        {
            trigger OnAfterValidate()
            var
                ShippingAgentMapping: Record "IDYS Ship. Agent Mapping";
            begin
                if not ShippingAgentMapping.Get("Shipping Agent Code") then
                    ShippingAgentMapping.Init();

                Validate("IDYS Carrier Entry No.", ShippingAgentMapping."Carrier Entry No.");
            end;
        }
        modify("Shipping Agent Service Code")
        {
            trigger OnAfterValidate()
            var
                ShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
            begin
                if not ShippAgentSvcMapping.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                    ShippAgentSvcMapping.Init();
                Validate("IDYS Booking Profile Entry No.", ShippAgentSvcMapping."Booking Profile Entry No.");

                IDYSSourceDocumentService.SetDefaultServices(Database::"Transfer Header", "IDYS Source Document Type"::"0", "No.", ShippAgentSvcMapping, "Trsf.-from Country/Region Code", "Trsf.-to Country/Region Code", SystemId);
            end;
        }
        modify("Trsf.-from Country/Region Code")
        {
            trigger OnAfterValidate()
            var
                IDYSShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
            begin
                if CurrFieldNo = FieldNo("Trsf.-from Country/Region Code") then
                    if "IDYS Provider" = "IDYS Provider"::"Delivery Hub" then
                        if "Trsf.-from Country/Region Code" <> xRec."Trsf.-from Country/Region Code" then begin
                            if GuiAllowed() then
                                if not Confirm(StrSubstNo(ChangingShipFromShipToCountryQst, FieldCaption("Trsf.-from Country/Region Code")), true) then
                                    Error('');

                            if not IDYSShippAgentSvcMapping.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                                IDYSShippAgentSvcMapping.Init();
                            IDYSSourceDocumentService.SetDefaultServices(Database::"Purchase Header", "IDYS Source Document Type"::"5", "No.", IDYSShippAgentSvcMapping, "Trsf.-from Country/Region Code", "Trsf.-to Country/Region Code", SystemId);
                        end;
            end;
        }
        modify("Trsf.-to Country/Region Code")
        {
            trigger OnAfterValidate()
            var
                IDYSShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
            begin
                if CurrFieldNo = FieldNo("Trsf.-to Country/Region Code") then
                    if "IDYS Provider" = "IDYS Provider"::"Delivery Hub" then
                        if "Trsf.-to Country/Region Code" <> xRec."Trsf.-to Country/Region Code" then begin
                            if GuiAllowed() then
                                if not Confirm(StrSubstNo(ChangingShipFromShipToCountryQst, FieldCaption("Trsf.-to Country/Region Code")), true) then
                                    Error('');

                            if not IDYSShippAgentSvcMapping.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                                IDYSShippAgentSvcMapping.Init();
                            IDYSSourceDocumentService.SetDefaultServices(Database::"Purchase Header", "IDYS Source Document Type"::"5", "No.", IDYSShippAgentSvcMapping, "Trsf.-from Country/Region Code", "Trsf.-to Country/Region Code", SystemId);
                        end;
            end;
        }
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
            CalcFormula = count("IDYS Source Document Service" where("Table No." = const(5740), "Document No." = field("No.")));
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
                        Validate("Shipping Agent Code", '');

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


    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeModifyOnAfterInsert(var TransferHeader: Record "Transfer Header"; var DontModify: Boolean)
    begin
    end;

    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        ChangingShipFromShipToCountryQst: Label 'Changing the %1 will reset the selected services. \Do you want to continue? ', Comment = '%1 = Ship-to/Ship-from Country';
}