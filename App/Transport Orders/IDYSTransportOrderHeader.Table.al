table 11147669 "IDYS Transport Order Header"
{
    Caption = 'Transport Order Header';
    DataCaptionFields = "No.", Description;
    DrillDownPageID = "IDYS Transport Order List";
    LookupPageID = "IDYS Transport Order List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                IDYSSetup: Record "IDYS Setup";
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
                NoSeriesManagement: Codeunit NoSeriesManagement;
#else
                NoSeries: Codeunit "No. Series";
#endif
            begin
                if "No." <> xRec."No." then begin
                    IDYSSetup.Get();
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
                    NoSeriesManagement.TestManual(IDYSSetup."Transport Order Nos.");
#else
                    NoSeries.TestManual(IDYSSetup."Transport Order Nos.");
#endif
                    "No. Series" := '';
                end;
            end;
        }

        field(5; "Document Date"; Date)
        {
            DataClassification = SystemMetadata;
            Caption = 'Document Date';
        }

        field(10; "External ID"; Integer)
        {
            BlankZero = true;
            Caption = 'External ID';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(20; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(30; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            InitValue = New;
            // OptionCaption = ',,,New,,,Uploaded,,,Error,,,Booked,,,Label Printed,,,Recalled,,Done,,On Hold,,Archived';
            // OptionMembers = ,,,New,,,Uploaded,,,Error,,,Booked,,,"Label Printed",,,Recalled,,Done,,"On Hold",,Archived;
            OptionCaption = ',,,New,,,Uploaded,,,,,,Booked,,,Label Printed,,,Recalled,,,,,,Archived,Done,Error,On Hold';
            OptionMembers = ,,,New,,,Uploaded,,,,,,Booked,,,"Label Printed",,,Recalled,,,,,,Archived,Done,Error,"On Hold";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateOrderLineStatus();
                UpdateSequenceNo();
            end;
        }

        field(31; "Status (External)"; Code[10])
        {
            Caption = 'Status (External)';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(32; "Archived On"; Date)
        {
            Caption = 'Archived On';
            DataClassification = CustomerContent;
        }

        field(33; "Archived By"; Text[50])
        {
            Caption = 'Archived By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";

            trigger OnLookup()
            var
                LoginMgt: Codeunit "User Management";
            begin
                LoginMgt.DisplayUserInformation("Archived By");
            end;
        }

        field(34; "Last Status Update"; DateTime)
        {
            Caption = 'Last Status Update';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(35; "Sub Status (External)"; Text[256])
        {
            Caption = 'Sub Status (External)';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(40; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(41; Book; Boolean)
        {
            Caption = 'Book';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(42; Print; Boolean)
        {
            Caption = 'Print';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(50; "Shipment Error"; Text[2048])
        {
            Caption = 'Booking Error';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(60; "Preferred Pick-up Date"; Date)
        {
            Caption = 'Preferred Pick-up Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IDYSTransportOrderHdrMgt.UpdatePickupDate(Rec);
                IDYSTransportOrderHdrMgt.UpdateDeliveryDate(Rec);
            end;
        }

        field(70; "Preferred Delivery Date"; Date)
        {
            Caption = 'Preferred Delivery Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IDYSTransportOrderHdrMgt.UpdateDeliveryDate(Rec);
            end;
        }

        field(90; "Combinability ID"; Code[40])
        {
            Caption = 'Combinability ID';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(100; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ShippingAgentMapping: Record "IDYS Ship. Agent Mapping";
                IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
            begin
                if not ShippingAgentMapping.Get("Shipping Agent Code") then
                    ShippingAgentMapping.Init();

                // Clear packages (Shipping Agent level)
                if not SkipPackageValidation and (Provider = Provider::EasyPost) then begin
                    IDYSTransportOrderPackage.SetRange("Transport Order No.", Rec."No.");
                    IDYSTransportOrderPackage.SetFilter("Book. Prof. Package Type Code", '<>%1', ''); // only agent/carrier related
                    IDYSTransportOrderPackage.DeleteAll(true);
                end;

                Validate("Carrier Entry No.", ShippingAgentMapping."Carrier Entry No.");
                Validate("Shipping Agent Service Code", '');
            end;
        }

        field(101; "Carrier Code (External)"; Code[50])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Restructured with Provider level';
            Caption = 'Carrier Code (External)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(102; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            Editable = false;
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IDYSProviderCarrier: Record "IDYS Provider Carrier";
            begin
                Validate("Booking Profile Entry No.", 0);

                if "Carrier Entry No." <> 0 then begin
                    IDYSProviderCarrier.Get("Carrier Entry No.");
                    Validate(Provider, IDYSProviderCarrier.Provider);
                end;
                UpdateTotals();
            end;
        }

        field(103; Provider; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
            begin
                if IsTemporary() then
                    exit;
                IDYSTransportOrderPackage.SetRange("Transport Order No.", Rec."No.");
                if (xRec.Provider <> Rec.Provider) then begin
                    if not (Status in [Status::New]) then
                        Error(ProviderChangeNotAllowedErr, Status);

                    // Clear Shiping Agent information whenever the provider is changed
                    if CurrFieldNo = FieldNo(Provider) then
                        Validate("Shipping Agent Code", '');

                    // Clear packages (Provider level)
                    IDYSTransportOrderPackage.DeleteAll(true);
                    if (xRec.Provider = xRec.Provider::"Delivery Hub") then begin
                        IDYSSourceDocumentService.SetRange("Table No.", Database::"IDYS Transport Order Header");
                        IDYSSourceDocumentService.SetRange("Document No.", "No.");
                        IDYSSourceDocumentService.DeleteAll();
                    end;
                end else
                    if not IDYSTransportOrderPackage.IsEmpty then
                        exit;

                // Insert default package (Provider & Shipping Agent level)
                InsertDefaultTransportOrderPackage();
            end;
        }
        field(104; "Carrier Name"; Text[100])
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Name where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Carrier Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; "Allow Deletion"; Boolean)
        {
            Editable = false;
            DataClassification = SystemMetadata;
            Caption = 'Allow Deletion';
        }

        field(106; "Carrier Code (Ext.)"; Code[50])
        {
            CalcFormula = Lookup("IDYS Provider Carrier"."Transsmart Carrier Code" where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Carrier Code (Ext.)';
            Editable = false;
            FieldClass = FlowField;
        }

        field(107; "Booking Prof. Code (Ext.)"; Code[50])
        {
            CalcFormula = Lookup("IDYS Provider Booking Profile"."Transsmart Booking Prof. Code" where("Entry No." = field("Booking Profile Entry No."),
                                                                                                        "Carrier Entry No." = field("Carrier Entry No.")));
            Caption = 'Booking Prof. Code (Ext.)';
            Editable = false;
            FieldClass = FlowField;
        }

        field(110; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ShippingAgentServices: Record "Shipping Agent Services";
                IDYSShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
                IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
            begin
                if not IDYSShippAgentSvcMapping.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                    IDYSShippAgentSvcMapping.Init();
                Validate("Booking Profile Entry No.", IDYSShippAgentSvcMapping."Booking Profile Entry No.");
                if Rec."Preferred Pick-up Date" <> 0D then
                    IDYSTransportOrderHdrMgt.UpdatePickupDate(Rec);
                if (Rec."Preferred Pick-up Date" <> 0D) and (Rec."Shipping Agent Service Code" <> '') then begin
                    ShippingAgentServices.Get(Rec."Shipping Agent Code", Rec."Shipping Agent Service Code");
                    Validate("Preferred Delivery Date", CalcDate(ShippingAgentServices."Shipping Time", Rec."Preferred Pick-up Date"));
                end else
                    if Rec."Preferred Pick-up Date" <> 0D then
                        Validate("Preferred Delivery Date", CalcDate('<+1D>', Rec."Preferred Pick-up Date"));

                if IsTemporary() then
                    exit;

                if Provider <> Provider::"Delivery Hub" then
                    exit;

                if SkipPackageValidation then
                    exit;

                IDYSSourceDocumentService.SetDefaultServices(Database::"IDYS Transport Order Header", "IDYS Source Document Type"::"0", "No.", IDYSShippAgentSvcMapping, "Country/Region Code (Pick-up)", "Country/Region Code (Ship-to)", SystemId);

                // Clear packages (Shipping Agent Service level)
                IDYSTransportOrderPackage.SetRange("Transport Order No.", "No.");
                IDYSTransportOrderPackage.DeleteAll(true);

                InsertDefaultTransportOrderPackage();
            end;
        }

        field(111; "Booking Profile Code (Ext.)"; Code[50])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Restructured with Provider level';
            Caption = 'Booking Profile Code (Ext.)';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(112; "Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            Editable = false;
            TableRelation = "IDYS Provider Booking Profile"."Entry No." where("Carrier Entry No." = field("Carrier Entry No."));
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ProviderBookingProfile: Record "IDYS Provider Booking Profile";
            begin
                if not ProviderBookingProfile.Get("Booking Profile Entry No.", "Carrier Entry No.") then
                    ProviderBookingProfile.Init();

                "Service Level Code (Time)" := ProviderBookingProfile."Service Level Code (Time)";
                "Service Level Code (Other)" := ProviderBookingProfile."Service Level Code (Other)";
            end;
        }
        field(113; "Booking Profile Description"; Text[150])
        {
            CalcFormula = Lookup("IDYS Provider Booking Profile".Description where("Entry No." = field("Booking Profile Entry No."),
                                                                                    "Carrier Entry No." = field("Carrier Entry No.")));
            Caption = 'Booking Profile Description';
            Editable = false;
            FieldClass = FlowField;
        }

        field(114; "Service Level Code (Time)"; Code[50])
        {
            Caption = 'Service Level Code (Time)';
            Editable = false;
            TableRelation = "IDYS Service Level (Time)";
            DataClassification = CustomerContent;
        }

        field(117; "Service Level Code (Other)"; Code[50])
        {
            Caption = 'Service Level Code (Other)';
            TableRelation = "IDYS Service Level (Other)";
            DataClassification = CustomerContent;
        }

        field(120; "EORI Number (Pick-up)"; text[50])
        {
            Caption = 'EORI Number (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(121; "EORI Number (Ship-to)"; text[50])
        {
            Caption = 'EORI Number (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(122; "EORI Number (Invoice)"; text[50])
        {
            Caption = 'EORI Number (Invoice)';
            DataClassification = CustomerContent;
        }

        field(140; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ShipmentMethodMapping: Record "IDYS Shipment Method Mapping";
            begin
                if not ShipmentMethodMapping.Get("Shipment Method Code") then
                    ShipmentMethodMapping.Init();

                "Incoterms Code" := ShipmentMethodMapping."Incoterms Code";
            end;
        }

        field(141; "Incoterms Code"; Code[50])
        {
            Caption = 'Incoterms Code';
            Editable = false;
            TableRelation = "IDYS Incoterm";
            DataClassification = CustomerContent;
        }

        field(142; Insure; Boolean)
        {
            Caption = 'Insure';
            DataClassification = CustomerContent;
        }
        field(143; "Insurance Amount"; Decimal)
        {
            Caption = 'Insurance Amount';
            DataClassification = CustomerContent;
        }
        field(144; "Insurance Company"; Text[50])
        {
            Caption = 'Insurance Company';
            DataClassification = CustomerContent;
        }
        field(145; "Insured Value"; Decimal)
        {
            Caption = 'Insured Value';
            DataClassification = CustomerContent;
        }
        field(146; "Claim Url"; Text[150])
        {
            Caption = 'Claim Url';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(147; "Policy Url"; Text[150])
        {
            Caption = 'Policy Url';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(148; "Insurance Status Description"; Text[150])
        {
            Caption = 'Insurance Status Description';
            DataClassification = CustomerContent;
        }
        field(150; "Service Type"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Changed to enum IDYS Service Type to avoid translation issues';
            Caption = 'Service Type';
            OptionCaption = ' ,DOCS,NON-DOCS';
            OptionMembers = " ",DOCS,"NON-DOCS";
            DataClassification = CustomerContent;
        }

        field(151; "Service Type Enum"; Enum "IDYS Service Type")
        {
            Caption = 'Service Type';
            DataClassification = CustomerContent;
        }

        field(160; "E-Mail Type"; Code[127])
        {
            Caption = 'E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            DataClassification = CustomerContent;
        }

        field(170; "Cost Center"; Code[127])
        {
            Caption = 'Cost Center';
            TableRelation = "IDYS Cost Center";
            DataClassification = CustomerContent;
        }
        field(175; "Account No."; Code[32])
        {
            Caption = 'Account No. (Ship-to)';
            DataClassification = CustomerContent;
        }
        field(176; "Account No. (Invoice)"; Code[32])
        {
            Caption = 'Account No. (Invoice)';
            DataClassification = CustomerContent;
        }
        field(177; "Account No. (Pick-up)"; Code[32])
        {
            Caption = 'Account No. (Pick-up)';
            DataClassification = CustomerContent;
        }
        field(200; "Accepted By"; Text[80])
        {
            Caption = 'Accepted By';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(300; "Preferred Pick-up Date From"; DateTime)
        {
            Caption = 'Preferred Pick-up Date From';
            DataClassification = CustomerContent;
        }

        field(310; "Preferred Pick-up Date To"; DateTime)
        {
            Caption = 'Preferred Pick-up Date To';
            DataClassification = CustomerContent;
        }

        field(320; "Preferred Delivery Date From"; DateTime)
        {
            Caption = 'Preferred Delivery Date From';
            DataClassification = CustomerContent;
        }

        field(330; "Preferred Delivery Date To"; DateTime)
        {
            Caption = 'Preferred Delivery Date To';
            DataClassification = CustomerContent;
        }

        field(340; "Actual Delivery Date"; DateTime)
        {
            Caption = 'Actual Delivery Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(400; "Booking Method"; Option)
        {
            OptionMembers = Manual,Background;
            Caption = 'Booking Method';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(401; "Booking Scheduled On"; DateTime)
        {
            Editable = false;
            Caption = 'Booking Scheduled On';
            DataClassification = CustomerContent;
        }

        field(403; "Booking Scheduled By"; Text[50])
        {
            Editable = false;
            Caption = 'Booking Scheduled By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";

            trigger OnLookup()
            var
                LoginMgt: Codeunit "User Management";
            begin
                LoginMgt.DisplayUserInformation("Booking Scheduled By");
            end;
        }

        field(1000; "Type (Pick-up)"; Option)
        {
            Caption = 'Type (Pick-up)';
            InitValue = Location;
            OptionCaption = ',,,Location,,,Customer,,,Vendor,Our Company';
            OptionMembers = ,,,Location,,,Customer,,,Vendor,Company;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Source Type (Pick-up)';
            ObsoleteTag = '21.0';
        }
        field(1001; "Source Type (Pick-up)"; Enum "IDYS Address Source Type")
        {
            Caption = 'Type (Pick-up)';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                Validate("No. (Pick-up)", '');
            end;
        }

        field(1010; "No. (Pick-up)"; Code[20])
        {
            Caption = 'No. (Pick-up)';
            TableRelation = if ("Source Type (Pick-up)" = const(Location)) Location
            else
            if ("Source Type (Pick-up)" = const(Customer)) Customer
            else
            if ("Source Type (Pick-up)" = const(Vendor)) Vendor;
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                Validate("Code (Pick-up)", '');
                IDYSTransportOrderHdrMgt.UpdatePickupAddress(Rec);
            end;
        }

        field(1015; "Code (Pick-up)"; Code[10])
        {
            Caption = 'Code (Pick-up)';
            TableRelation = if ("Source Type (Pick-up)" = const(Customer)) "Ship-to Address".Code where("Customer No." = field("No. (Pick-up)"))
            else
            if ("Source Type (Pick-up)" = const(Vendor)) "Order Address".Code where("Vendor No." = field("No. (Pick-up)"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IDYSTransportOrderHdrMgt.UpdatePickupAddress(Rec);
            end;
        }

        field(1020; "Name (Pick-up)"; Text[100])
        {
            Caption = 'Name (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(1040; "Address (Pick-up)"; Text[100])
        {
            Caption = 'Address (Pick-up)';
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                Street: Text;
                HouseNo: Text;
            begin
                IDYSTransportOrderHdrMgt.SplitAddress("Address (Pick-up)", Street, HouseNo);
                "Street (Pick-up)" := CopyStr(Street, 1, MaxStrLen("Street (Pick-up)"));
                "House No. (Pick-up)" := CopyStr(HouseNo, 1, MaxStrLen("House No. (Pick-up)"));
            end;
        }

        field(1041; "Street (Pick-up)"; Text[100])
        {
            Caption = 'Street (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(1042; "House No. (Pick-up)"; Text[20])
        {
            Caption = 'House No. (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(1050; "Address 2 (Pick-up)"; Text[100])
        {
            Caption = 'Address 2 (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(1060; "Post Code (Pick-up)"; Code[20])
        {
            Caption = 'Post Code (Pick-up)';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code (Pick-up)" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code (Pick-up)" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code (Pick-up)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate();
            begin
                if CurrFieldNo = FieldNo("Post Code (Pick-up)") then begin
                    Postcode.ValidatePostCode("City (Pick-up)", "Post Code (Pick-up)", "County (Pick-up)", "Country/Region Code (Pick-up)", GuiAllowed());
                    if "Country/Region Code (Pick-up)" <> xRec."Country/Region Code (Pick-up)" then
                        "Cntry/Rgn. Code (Pick-up) (TS)" := IDYSTransportOrderHdrMgt.GetExternalCountryCode("Country/Region Code (Pick-up)");
                end;
            end;
        }

        field(1070; "City (Pick-up)"; Text[30])
        {
            Caption = 'City (Pick-up)';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code (Pick-up)" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code (Pick-up)" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code (Pick-up)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate();
            begin
                if CurrFieldNo = Rec.FieldNo("City (Pick-up)") then begin
                    Postcode.ValidateCity("City (Pick-up)", "Post Code (Pick-up)", "County (Pick-up)", "Country/Region Code (Pick-up)", GuiAllowed());
                    if "Country/Region Code (Pick-up)" <> xRec."Country/Region Code (Pick-up)" then
                        "Cntry/Rgn. Code (Pick-up) (TS)" := IDYSTransportOrderHdrMgt.GetExternalCountryCode("Country/Region Code (Pick-up)");
                end;
            end;
        }

        field(1080; "County (Pick-up)"; Text[30])
        {
            Caption = 'County (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(1090; "Country/Region Code (Pick-up)"; Code[10])
        {
            Caption = 'Country/Region Code (Pick-up)';
            TableRelation = "IDYS Country/Region Mapping";
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                IDYSShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
            begin
                "Cntry/Rgn. Code (Pick-up) (TS)" := IDYSTransportOrderHdrMgt.GetExternalCountryCode("Country/Region Code (Pick-up)");

                if CurrFieldNo = FieldNo("Country/Region Code (Pick-up)") then begin
                    Postcode.ValidateCountryCode(
                        "City (Pick-up)", "Post Code (Pick-up)", "County (Pick-up)", "Country/Region Code (Pick-up)");

                    if Provider = Provider::"Delivery Hub" then
                        if "Country/Region Code (Pick-up)" <> xRec."Country/Region Code (Pick-up)" then begin
                            if GuiAllowed() then
                                if not Confirm(StrSubstNo(ChangingShipFromShipToCountryQst, FieldCaption("Country/Region Code (Pick-up)")), true) then
                                    Error('');

                            if not IDYSShippAgentSvcMapping.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                                IDYSShippAgentSvcMapping.Init();
                            IDYSSourceDocumentService.SetDefaultServices(Database::"IDYS Transport Order Header", "IDYS Source Document Type"::"0", "No.", IDYSShippAgentSvcMapping, "Country/Region Code (Pick-up)", "Country/Region Code (Ship-to)", SystemId);
                        end;
                end;
            end;
        }

        field(1091; "Cntry/Rgn. Code (Pick-up) (TS)"; Code[10])
        {
            Caption = 'Cntry/Rgn. Code (Pick-up) (TS)';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "IDYS Country/Region Mapping"."Country/Region Code (External)";
        }

        field(1100; "Contact (Pick-up)"; Text[100])
        {
            Caption = 'Contact (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(1110; "Phone No. (Pick-up)"; Text[30])
        {
            Caption = 'Phone No. (Pick-up)';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(1111; "Mobile Phone No. (Pick-up)"; Text[30])
        {
            Caption = 'Mobile Phone No. (Pick-up)';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(1120; "Fax No. (Pick-up)"; Text[30])
        {
            Caption = 'Fax No. (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(1130; "E-Mail (Pick-up)"; Text[80])
        {
            Caption = 'E-Mail (Pick-up)';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }

        field(1190; "VAT Registration No. (Pick-up)"; Text[20])
        {
            Caption = 'VAT Registration No. (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(2000; "Type (Ship-to)"; Option)
        {
            Caption = 'Type (Ship-to)';
            InitValue = Customer;
            OptionCaption = ',,,Customer,,,Vendor,,,Location,Our Company';
            OptionMembers = ,,,Customer,,,Vendor,,,Location,Company;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Source Type (Pick-up)';
            ObsoleteTag = '21.0';
        }
        field(2001; "Source Type (Ship-to)"; Enum "IDYS Address Source Type")
        {
            Caption = 'Type (Ship-to)';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                Validate("No. (Ship-to)", '');
            end;
        }

        field(2010; "No. (Ship-to)"; Code[20])
        {
            Caption = 'No. (Ship-to)';
            TableRelation = if ("Source Type (Ship-to)" = const(Customer)) Customer
            else
            if ("Source Type (Ship-to)" = const(Vendor)) Vendor
            else
            if ("Source Type (Ship-to)" = const(Location)) Location where("Use As In-Transit" = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                Validate("Code (Ship-to)", '');
                IDYSTransportOrderHdrMgt.UpdateShipToAddress(Rec);
            end;
        }

        field(2020; "Code (Ship-to)"; Code[10])
        {
            Caption = 'Code (Ship-to)';
            TableRelation = if ("Source Type (Ship-to)" = const(Customer)) "Ship-to Address".Code where("Customer No." = field("No. (Ship-to)"))
            else
            if ("Source Type (Ship-to)" = const(Vendor)) "Order Address".Code where("Vendor No." = field("No. (Ship-to)"));
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                IDYSTransportOrderHdrMgt.UpdateShipToAddress(Rec);
            end;
        }

        field(2030; "Name (Ship-to)"; Text[100])
        {
            Caption = 'Name (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(2050; "Address (Ship-to)"; Text[100])
        {
            Caption = 'Address (Ship-to)';
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                Street: Text;
                HouseNo: Text;
            begin
                IDYSTransportOrderHdrMgt.SplitAddress("Address (Ship-to)", Street, HouseNo);
                "Street (Ship-to)" := CopyStr(Street, 1, MaxStrLen("Street (Ship-to)"));
                "House No. (Ship-to)" := CopyStr(HouseNo, 1, MaxStrLen("House No. (Ship-to)"));
            end;
        }

        field(2051; "Street (Ship-to)"; Text[100])
        {
            Caption = 'Street (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(2052; "House No. (Ship-to)"; Text[20])
        {
            Caption = 'House No. (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(2060; "Address 2 (Ship-to)"; Text[100])
        {
            Caption = 'Address 2 (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(2070; "Post Code (Ship-to)"; Code[20])
        {
            Caption = 'Post Code (Ship-to)';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code (Ship-to)" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code (Ship-to)" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code (Ship-to)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate();
            begin
                if CurrFieldNo = FieldNo("Post Code (Ship-to)") then begin
                    Postcode.ValidatePostCode("City (Ship-to)", "Post Code (Ship-to)", "County (Ship-to)", "Country/Region Code (Ship-to)", GuiAllowed());
                    if "Country/Region Code (Ship-to)" <> xRec."Country/Region Code (Ship-to)" then
                        "Cntry/Rgn. Code (Ship-to) (TS)" := IDYSTransportOrderHdrMgt.GetExternalCountryCode("Country/Region Code (Ship-to)");
                end;
            end;
        }

        field(2080; "City (Ship-to)"; Text[30])
        {
            Caption = 'City (Ship-to)';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code (Ship-to)" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code (Ship-to)" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code (Ship-to)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate();
            begin
                if CurrFieldNo = FieldNo("City (Ship-to)") then begin
                    Postcode.ValidateCity("City (Ship-to)", "Post Code (Ship-to)", "County (Ship-to)", "Country/Region Code (Ship-to)", GuiAllowed());
                    if "Country/Region Code (Ship-to)" <> xRec."Country/Region Code (Ship-to)" then
                        "Cntry/Rgn. Code (Ship-to) (TS)" := IDYSTransportOrderHdrMgt.GetExternalCountryCode("Country/Region Code (Ship-to)");
                end;
            end;
        }

        field(2090; "County (Ship-to)"; Text[30])
        {
            Caption = 'County (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(2100; "Country/Region Code (Ship-to)"; Code[10])
        {
            Caption = 'Country/Region Code (Ship-to)';
            TableRelation = "IDYS Country/Region Mapping";
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                IDYSShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
                IDYSSourceDocumentService: Record "IDYS Source Document Service";
            begin
                "Cntry/Rgn. Code (Ship-to) (TS)" := IDYSTransportOrderHdrMgt.GetExternalCountryCode("Country/Region Code (Ship-to)");

                if CurrFieldNo = FieldNo("Country/Region Code (Ship-to)") then begin
                    Postcode.ValidateCountryCode(
                        "City (Ship-to)", "Post Code (Ship-to)", "County (Ship-to)", "Country/Region Code (Ship-to)");

                    if Provider = Provider::"Delivery Hub" then
                        if "Country/Region Code (Ship-to)" <> xRec."Country/Region Code (Ship-to)" then begin
                            if GuiAllowed() then
                                if not Confirm(StrSubstNo(ChangingShipFromShipToCountryQst, FieldCaption("Country/Region Code (Ship-to)")), true) then
                                    Error('');

                            if not IDYSShippAgentSvcMapping.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                                IDYSShippAgentSvcMapping.Init();
                            IDYSSourceDocumentService.SetDefaultServices(Database::"IDYS Transport Order Header", "IDYS Source Document Type"::"0", "No.", IDYSShippAgentSvcMapping, "Country/Region Code (Pick-up)", "Country/Region Code (Ship-to)", SystemId);
                        end;
                end;
            end;
        }

        field(2101; "Cntry/Rgn. Code (Ship-to) (TS)"; Code[10])
        {
            Caption = 'Cntry/Rgn. Code (Ship-to) (TS)';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "IDYS Country/Region Mapping"."Country/Region Code (External)";
        }

        field(2110; "Contact (Ship-to)"; Text[100])
        {
            Caption = 'Contact (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(2120; "Phone No. (Ship-to)"; Text[30])
        {
            Caption = 'Phone No. (Ship-to)';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(2121; "Mobile Phone No. (Ship-to)"; Text[30])
        {
            Caption = 'Mobile Phone No. (Ship-to)';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(2130; "Fax No. (Ship-to)"; Text[30])
        {
            Caption = 'Fax No. (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(2140; "E-Mail (Ship-to)"; Text[80])
        {
            Caption = 'E-Mail (Ship-to)';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }

        field(2190; "VAT Registration No. (Ship-to)"; Text[20])
        {
            Caption = 'VAT Registration No. (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(4000; "Type (Invoice)"; Option)
        {
            Caption = 'Type (Invoice)';
            OptionCaption = ',,,Customer,Our Company';
            OptionMembers = ,,,Customer,Company;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Source Type (Pick-up)';
            ObsoleteTag = '21.0';
        }
        field(4001; "Source Type (Invoice)"; Enum "IDYS Address Source Type")
        {
            Caption = 'Type (Invoice)';
            DataClassification = CustomerContent;
            trigger OnValidate();
            begin
                Validate("No. (Invoice)", '');
            end;
        }
        field(4010; "No. (Invoice)"; Code[20])
        {
            Caption = 'No. (Invoice)';
            TableRelation = if ("Source Type (Invoice)" = const(Customer)) Customer;
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                IDYSTransportOrderHdrMgt.UpdateInvoiceAddress(Rec);
            end;
        }

        field(4030; "Name (Invoice)"; Text[100])
        {
            Caption = 'Name (Invoice)';
            DataClassification = CustomerContent;
        }

        field(4040; "Address (Invoice)"; Text[100])
        {
            Caption = 'Address (Invoice)';
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                Street: Text;
                HouseNo: Text;
            begin
                IDYSTransportOrderHdrMgt.SplitAddress("Address (Invoice)", Street, HouseNo);
                "Street (Invoice)" := CopyStr(Street, 1, MaxStrLen("Street (Invoice)"));
                "House No. (Invoice)" := CopyStr(HouseNo, 1, MaxStrLen("House No. (Invoice)"));
            end;
        }

        field(4041; "Street (Invoice)"; Text[100])
        {
            Caption = 'Street (Invoice)';
            DataClassification = CustomerContent;
        }

        field(4042; "House No. (Invoice)"; Text[20])
        {
            Caption = 'House No. (Invoice)';
            DataClassification = CustomerContent;
        }

        field(4050; "Address 2 (Invoice)"; Text[100])
        {
            Caption = 'Address 2 (Invoice)';
            DataClassification = CustomerContent;
        }

        field(4060; "Post Code (Invoice)"; Code[20])
        {
            Caption = 'Post Code (Invoice)';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code (Invoice)" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code (Invoice)" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code (Invoice)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate();
            begin
                if CurrFieldNo = FieldNo("Post COde (Invoice)") then begin
                    Postcode.ValidatePostCode("City (Invoice)", "Post Code (Invoice)", "County (Invoice)", "Country/Region Code (Invoice)", GuiAllowed());
                    if "Country/Region Code (Invoice)" <> xRec."Country/Region Code (Invoice)" then
                        "Cntry/Rgn. Code (Invoice) (TS)" := IDYSTransportOrderHdrMgt.GetExternalCountryCode("Country/Region Code (Invoice)");
                end;
            end;
        }

        field(4070; "City (Invoice)"; Text[30])
        {
            Caption = 'City (Invoice)';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code (Invoice)" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code (Invoice)" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code (Invoice)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate();
            begin
                if CurrFieldNo = Rec.FieldNo("City (Invoice)") then begin
                    Postcode.ValidateCity("City (Invoice)", "Post Code (Invoice)", "County (Invoice)", "Country/Region Code (Invoice)", GuiAllowed());
                    if "Country/Region Code (Invoice)" <> xRec."Country/Region Code (Invoice)" then
                        "Cntry/Rgn. Code (Invoice) (TS)" := IDYSTransportOrderHdrMgt.GetExternalCountryCode("Country/Region Code (Invoice)");
                end;
            end;
        }

        field(4080; "County (Invoice)"; Text[30])
        {
            Caption = 'County (Invoice)';
            DataClassification = CustomerContent;
        }

        field(4090; "Country/Region Code (Invoice)"; Code[10])
        {
            Caption = 'Country/Region Code (Invoice)';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                if CurrFieldNo = Rec.FieldNo("Country/Region Code (Invoice)") then
                    Postcode.ValidateCountryCode(
                        "City (Invoice)", "Post Code (Invoice)", "County (Invoice)", "Country/Region Code (Invoice)");
                "Cntry/Rgn. Code (Invoice) (TS)" := IDYSTransportOrderHdrMgt.GetExternalCountryCode("Country/Region Code (Invoice)");
            end;
        }

        field(4091; "Cntry/Rgn. Code (Invoice) (TS)"; Code[10])
        {
            Caption = 'Cntry/Rgn. Code (Invoice) (TS)';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "IDYS Country/Region Mapping"."Country/Region Code (External)";
        }

        field(4100; "Contact (Invoice)"; Text[100])
        {
            Caption = 'Contact (Invoice)';
            DataClassification = CustomerContent;
        }

        field(4110; "Phone No. (Invoice)"; Text[30])
        {
            Caption = 'Phone No. (Invoice)';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(4111; "Mobile Phone No. (Invoice)"; Text[30])
        {
            Caption = 'Mobile Phone No. (Invoice)';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(4120; "Fax No. (Invoice)"; Text[30])
        {
            Caption = 'Fax No. (Invoice)';
            DataClassification = CustomerContent;
        }

        field(4130; "E-Mail (Invoice)"; Text[80])
        {
            Caption = 'E-Mail (Invoice)';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }

        field(4140; "VAT Registration No. (Invoice)"; Text[20])
        {
            Caption = 'VAT Registration No. (Invoice)';
            DataClassification = CustomerContent;
        }
        field(4150; "Include Invoice Address"; Boolean)
        {
            Caption = 'Include Invoice Address';
            DataClassification = CustomerContent;
        }
        field(4180; "Do Not Insure"; Boolean)
        {
            Description = 'Only used in the carrier selection.';
            Caption = 'Do Not Insure';
            DataClassification = SystemMetadata;
        }
        field(5000; "Total No. of Packages"; Decimal)
        {
            CalcFormula = Sum("IDYS Transport Order Package".Quantity where("Transport Order No." = field("No.")));
            Caption = 'Total No. of Packages';
            DecimalPlaces = 0 : 0;
            Editable = false;
            FieldClass = FlowField;
            MinValue = 0;
            ObsoleteState = Pending;
            ObsoleteReason = 'Quantity replaced with multiplication action on a subpage';
            ObsoleteTag = '21.0';
        }

        field(5001; "Total Count of Packages"; Integer)
        {
            CalcFormula = Count("IDYS Transport Order Package" where("Transport Order No." = field("No.")));
            Caption = 'Total No. of Packages';
            Editable = false;
            FieldClass = FlowField;
            MinValue = 0;
        }

        field(5010; "Total Volume"; Decimal)
        {
            CalcFormula = Sum("IDYS Transport Order Package".Volume where("Transport Order No." = field("No.")));
            Caption = 'Total Volume';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            MinValue = 0;
        }

        field(5020; "Total Weight"; Decimal)
        {
            CalcFormula = Sum("IDYS Transport Order Package"."Total Weight" where("Transport Order No." = field("No.")));
            Caption = 'Total Weight';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            MinValue = 0;
        }
        field(5030; "Carrier Weight"; Decimal)
        {
            Caption = 'Carrier Weight';
            Editable = false;
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(6000; "Tracking No."; Code[50])
        {
            Caption = 'Tracking No.';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(6010; "Tracking Url"; Text[250])
        {
            Caption = 'Tracking Url';
            Editable = false;
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }

        field(6011; "Shipment Label Data"; Blob)
        {
            Caption = 'Shipment Label Data';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with the standard attachments';
            ObsoleteTag = '23.0';
        }

        field(7000; "Invoice (Ref)"; Text[64])
        {
            Caption = 'Invoice (Ref)';
            DataClassification = CustomerContent;
        }

        field(7001; "Customer Order (Ref)"; Text[64])
        {
            Caption = 'Customer Order (Ref)';
            DataClassification = CustomerContent;
        }

        field(7002; "Order No. (Ref)"; Text[64])
        {
            Caption = 'Order No. (Ref)';
            DataClassification = CustomerContent;
        }

        field(7003; "Delivery Note (Ref)"; Text[64])
        {
            Caption = 'Delivery Note (Ref)';
            DataClassification = CustomerContent;
        }

        field(7004; "Delivery Id (Ref)"; Text[64])
        {
            Caption = 'Delivery Id (Ref)';
            DataClassification = CustomerContent;
        }

        field(7005; "Other (Ref)"; Text[64])
        {
            Caption = 'Other (Ref)';
            DataClassification = CustomerContent;
        }

        field(7006; "Service Point (Ref)"; Text[64])
        {
            Caption = 'Service Point (Ref)';
            DataClassification = CustomerContent;
        }

        field(7007; "Project (Ref)"; Text[64])
        {
            Caption = 'Project (Ref)';
            DataClassification = CustomerContent;
        }

        field(7008; "Your Reference (Ref)"; Text[64])
        {
            Caption = 'Your Reference (Ref)';
            DataClassification = CustomerContent;
        }

        field(7009; "Engineer (Ref)"; Text[64])
        {
            Caption = 'Engineer (Ref)';
            DataClassification = CustomerContent;
        }

        field(7010; "Customer (Ref)"; Text[64])
        {
            Caption = 'Customer (Ref)';
            DataClassification = CustomerContent;
        }

        field(7011; "Agent (Ref)"; Text[64])
        {
            Caption = 'Agent (Ref)';
            DataClassification = CustomerContent;
        }

        field(7012; "Driver ID (Ref)"; Text[64])
        {
            Caption = 'Driver ID (Ref)';
            DataClassification = CustomerContent;
        }

        field(7013; "Route ID (Ref)"; Text[64])
        {
            Caption = 'Route ID (Ref)';
            DataClassification = CustomerContent;
        }

        field(8000; "Load Meter"; Decimal)
        {
            Caption = 'Load Meter';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }

        field(8001; Instruction; Text[250])
        {
            Caption = 'Instruction';
            DataClassification = CustomerContent;
        }

        field(8002; "Shipment Value Curr Code"; Code[10])
        {
            Caption = 'Shipment Value Currency Code';
            TableRelation = "IDYS Currency Mapping";
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                "Shipmt. Value Curr Code (TS)" := IDYSTransportOrderHdrMgt.GetExternalCurrencyCode("Shipment Value Curr Code");
                Validate("Shipment Cost Curr Code", "Shipment Value Curr Code");
                Validate("Spot Price Curr Code", "Shipment Value Curr Code");
            end;
        }

        field(8003; "Shipmt. Value Curr Code (TS)"; Code[10])
        {
            Caption = 'Shipmt. Value Curr. Code (TS)';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "IDYS Currency Mapping"."Currency Code (External)";
        }

        field(8004; "Shipmt. Value"; Decimal)
        {
            Caption = 'Actual Shipment Value';
            MinValue = 0;
            DataClassification = CustomerContent;
            AutoFormatExpression = "Shipment Value Curr Code";
            AutoFormatType = 1;
        }

        field(8005; "Shipment Cost Curr Code"; Code[10])
        {
            Caption = 'Shipment Cost Currency Code';
            TableRelation = "IDYS Currency Mapping";
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                "Shipmt. Cost Curr Code (TS)" := IDYSTransportOrderHdrMgt.GetExternalCurrencyCode("Shipment Cost Curr Code");
            end;
        }

        field(8006; "Shipmt. Cost Curr Code (TS)"; Code[10])
        {
            Caption = 'Shipmt. Cost Curr. Code (TS)';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "IDYS Currency Mapping"."Currency Code (External)";
        }

        field(8007; "Shipmt. Cost"; Decimal)
        {
            Caption = 'Shipment Cost';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Shipment Cost Curr Code";
            AutoFormatType = 1;
        }

        field(8008; "Spot Price Curr Code"; Code[10])
        {
            Caption = 'Spot Price Currency Code';
            TableRelation = "IDYS Currency Mapping";
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                "Spot Price Curr Code (TS)" := IDYSTransportOrderHdrMgt.GetExternalCurrencyCode("Spot Price Curr Code");
            end;
        }

        field(8009; "Spot Price Curr Code (TS)"; Code[10])
        {
            Caption = 'Spot Price Currency Code (TS)';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "IDYS Currency Mapping"."Currency Code (External)";
        }

        field(8010; "Spot Pr."; Decimal)
        {
            Caption = 'Spot Price';
            MinValue = 0;
            DataClassification = CustomerContent;
            AutoFormatExpression = "Spot Price Curr Code";
            AutoFormatType = 1;
        }

        field(8011; "Calculated Shipment Value"; Decimal)
        {
            Caption = 'Calculated Shipment Value';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("IDYS Transport Order Line".Amount where("Transport Order No." = field("No."), "Item Category Code" = field("Item Category Code Filter")));
            AutoFormatExpression = "Shipment Value Curr Code";
            AutoFormatType = 1;
        }
        field(8012; "Item Category Code Filter"; Code[20])
        {
            Caption = 'Item Category Code Filter';
            FieldClass = FlowFilter;
        }
        field(8013; "Reason of Export"; Text[64])
        {
            Caption = 'Reason of Export';
            DataClassification = CustomerContent;
        }
        #region [Sendcloud]

        field(9000; "Address Id. (Pick-up)"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Address Id. (Pick-up)';
            TableRelation = "IDYS SC Sender Address".Id;
            ObsoleteState = Pending;
            ObsoleteReason = 'Sender Address removed';
            ObsoleteTag = '21.0';
        }
        field(9001; "Customs Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customs Invoice No.';
        }
        field(9002; "Customs Shipment Type"; Enum "IDYS SC Customs Shipment Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Customs Shipment Type';
            InitValue = 2;
        }
        field(9003; "Ship Outside EU"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Ship Outside EU';
            Editable = false;
        }

        field(9004; "Recipient PO Box No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'PO Box No.';
        }
        field(9005; "Is Return"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Return';
            Editable = False;
        }
        field(9006; "Source Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source Document No.';

            trigger OnValidate()
            begin
                if (("Customs Invoice No." = '') and ("Source Document No." <> '')) or
                   ((xRec."Source Document No." <> '') and ("Customs Invoice No." = xRec."Source Document No."))
                then
                    Validate("Customs Invoice No.", "Source Document No.");
            end;
        }
        field(9007; "External Document No."; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        #endregion
        field(9008; "Booked with Error"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Booked with Error';
        }
        #region [Obsolete]
        field(50100; "Shipment Value Currency Code"; Code[10])
        {
            Caption = 'Shipment Value Currency Code';
            TableRelation = "IDYS Currency Mapping";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Illegal field ID.';
        }
        field(50101; "Shipmt. Value Curr. Code (TS)"; Code[10])
        {
            Caption = 'Shipmt. Value Curr. Code (TS)';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Illegal field ID.';
        }
        field(50110; "Shipment Value"; Decimal)
        {
            Caption = 'Shipment Value';
            MinValue = 0;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Illegal field ID.';
        }
        field(50120; "Shipment Cost Currency Code"; Code[10])
        {
            Caption = 'Shipment Cost Currency Code';
            TableRelation = "IDYS Currency Mapping";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Illegal field ID.';
        }

        field(50121; "Shipmt. Cost Curr. Code (TS)"; Code[10])
        {
            Caption = 'Shipmt. Cost Curr. Code (TS)';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Illegal field ID.';
        }

        field(50130; "Shipment Cost"; Decimal)
        {
            Caption = 'Shipment Cost';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Illegal field ID.';
        }

        field(50140; "Spot Price Currency Code"; Code[10])
        {
            Caption = 'Spot Price Currency Code';
            TableRelation = "IDYS Currency Mapping";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Illegal field ID.';
        }

        field(50141; "Spot Price Currency Code (TS)"; Code[10])
        {
            Caption = 'Spot Price Currency Code (TS)';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Illegal field ID.';
        }

        field(50150; "Spot Price"; Decimal)
        {
            Caption = 'Spot Price';
            MinValue = 0;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Illegal field ID.';
        }
        #endregion

        #region [nShift Ship]
        field(9100; "Shipment Tag"; Guid)
        {
            Caption = 'Shipment Tag';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9101; "Shipment CSID"; integer)
        {
            Caption = 'Shipment CSID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9102; "No. of Selected Services"; Integer)
        {
            Caption = 'No. of Selected Services (Other)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("IDYS Source Document Service" where("Table No." = const(11147669), "Document No." = field("No.")));
        }
        field(9103; "Actor Id"; Text[30])
        {
            CalcFormula = Lookup("IDYS Provider Carrier"."Actor Id" where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Actor Id';
            Editable = false;
            FieldClass = FlowField;
        }
        #endregion

        #region [EasyPost]
        field(9200; "Contents Type"; Enum "IDYS EasyPost Contents Type")
        {
            Caption = 'Contents Type';
            DataClassification = CustomerContent;
        }
        field(9201; "Contents Explanation"; Text[100])
        {
            Caption = 'Contents Explanation';
            DataClassification = CustomerContent;
        }
        field(9202; "Restriction Type"; Enum "IDYS EasyPost Restriction Type")
        {
            Caption = 'Restriction Type';
            DataClassification = CustomerContent;
        }
        field(9203; "Restriction Comments"; Text[100])
        {
            Caption = 'Restriction Comments';
            DataClassification = CustomerContent;
        }
        field(9204; "Customs Certify"; Boolean)
        {
            Caption = 'Customs Certify';
            DataClassification = CustomerContent;
        }
        field(9205; "Customs Signer"; Code[20])
        {
            Caption = 'Customs Signer';
            TableRelation = Employee;
            DataClassification = CustomerContent;
        }
        field(9206; "Non Delivery Options"; Option)
        {
            Caption = 'Non Delivery Options';
            OptionCaption = 'Return, Abandon';
            OptionMembers = Return,Abandon;
            DataClassification = CustomerContent;
        }
        field(9207; "EEL / PFC"; Text[50])
        {
            Caption = 'EEL / PFC';
            DataClassification = CustomerContent;
        }
        #endregion
        #region [Cargoson]
        field(9300; "Booking Reference"; Text[30])
        {
            Caption = 'Booking Reference';
            DataClassification = SystemMetadata;
        }
        field(9301; "Label Url"; Text[350])
        {
            Caption = 'Label Url';
            DataClassification = CustomerContent;
        }
        field(9302; "CMR Url"; Text[350])
        {
            Caption = 'CMR Url';
            DataClassification = CustomerContent;
        }
        field(9303; "Waybill Url"; Text[350])
        {
            Caption = 'Waybill Url';
            DataClassification = CustomerContent;
        }
        field(9304; "Label Format"; Enum "IDYS Cargoson Label Format")
        {
            Caption = 'Label Format';
            DataClassification = CustomerContent;
        }
        field(9305; "Booking Id"; Integer)
        {
            Caption = 'Booking Id';
            DataClassification = SystemMetadata;
        }
        #endregion
        field(9500; "Sequence No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Sequence No.';
        }
    }

    keys
    {
        key(PK; "No.") { }
        key(Key2; Status) { }
        key(Key3; "Last Status Update", Status) { }
        key(Key4; "Combinability ID") { }
        key(Key5; "Sequence No.") { }
    }

    trigger OnDelete();
    var
        TransportOrderLine: Record "IDYS Transport Order Line";
        TransportOrderLogEntry: Record "IDYS Transport Order Log Entry";
        TransportOrderPackage: Record "IDYS Transport Order Package";
        ProviderCarrierSelect: Record "IDYS Provider Carrier Select";
        SourceDocumentService: Record "IDYS Source Document Service";
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
    begin
        if not "Allow Deletion" then
            if not (Status in [Status::New, Status::Recalled, Status::Archived]) then
                Error(CouldNotDeleteErr, TableCaption(), "No.", FieldCaption(Status));

        TransportOrderLine.SetRange("Transport Order No.", "No.");
        if not TransportOrderLine.IsEmpty() then
            TransportOrderLine.DeleteAll(true);

        TransportOrderLogEntry.SetRange("Transport Order No.", "No.");
        if not TransportOrderLogEntry.IsEmpty() then
            TransportOrderLogEntry.DeleteAll();

        TransportOrderPackage.SetRange("Transport Order No.", "No.");
        if not TransportOrderPackage.IsEmpty() then
            TransportOrderPackage.DeleteAll(true);

        ProviderCarrierSelect.SetRange("Transport Order No.", "No.");
        ProviderCarrierSelect.DeleteAll();

        SourceDocumentService.SetRange("Table No.", Database::"IDYS Transport Order Header");
        SourceDocumentService.SetRange("Document Type", SourceDocumentService."Document Type"::"0");
        SourceDocumentService.SetRange("Document No.", "No.");
        if not SourceDocumentService.IsEmpty() then
            SourceDocumentService.DeleteAll();

        IDYSTransportOrderMgt.DeleteAttachments(Rec);
    end;

    trigger OnInsert();
    var
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
        NoSeriesManagement: Codeunit NoSeriesManagement;
#else
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        NoSeries: Codeunit "No. Series";
#endif    
        CombinabilityMgt: Codeunit "IDYS Combinability Mgt.";
    begin
        IDYSSetup.Get();
        if "No." = '' then begin
            IDYSSetup.TestField("Transport Order Nos.");
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
            NoSeriesManagement.InitSeries(IDYSSetup."Transport Order Nos.", xRec."No. Series", 0D, "No.", "No. Series");
#else
            if NoSeries.AreRelated(IDYSSetup."Transport Order Nos.", xRec."No. Series") then
                "No. Series" := xRec."No. Series"
            else
                "No. Series" := IDYSSetup."Transport Order Nos.";
            "No." := NoSeries.GetNextNo("No. Series");
            IDYSTransportOrderHeader.ReadIsolation(IsolationLevel::ReadUncommitted);
            IDYSTransportOrderHeader.SetLoadFields("No.");
            while IDYSTransportOrderHeader.Get("No.") do
                "No." := NoSeries.GetNextNo("No. Series");
#endif
        end;

        if "Document Date" = 0D then
            Validate("Document Date", WorkDate());

        if "Combinability ID" = '' then
            "Combinability ID" := CombinabilityMgt.GetHashForTransportOrderHeader(Rec);

        CreateLogEntry(CopyStr(CreatedMsg, 1, 80), EventLogEntryType::Information);
    end;

    trigger OnModify();
    var
        CombinabilityMgt: Codeunit "IDYS Combinability Mgt.";
    begin
        "Combinability ID" := CombinabilityMgt.GetHashForTransportOrderHeader(Rec);
    end;

    trigger OnRename();
    begin
        // No. is used as a reference when communicating with Transsmart,
        // therefore we shouldn't allow renames.
        Error(RenameErr, TableCaption());
    end;

    procedure AssistEdit(OldTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean;
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
        NoSeriesManagement: Codeunit NoSeriesManagement;
#else
        NoSeries: Codeunit "No. Series";
#endif        
    begin
        TransportOrderHeader := Rec;
        IDYSSetup.Get();
        IDYSSetup.TestField("Transport Order Nos.");

#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
        if NoSeriesManagement.SelectSeries(
          IDYSSetup."Transport Order Nos.",
          OldTransportOrderHeader."No. Series",
          TransportOrderHeader."No. Series")
        then begin
            NoSeriesManagement.SetSeries(TransportOrderHeader."No.");
            Rec := TransportOrderHeader;
            exit(true);
        end;
#else
        if NoSeries.LookupRelatedNoSeries(IDYSSetup."Transport Order Nos.", OldTransportOrderHeader."No. Series", TransportOrderHeader."No. Series") then begin
            TransportOrderHeader."No." := NoSeries.GetNextNo(TransportOrderHeader."No. Series");
            Rec := TransportOrderHeader;
            exit(true);
        end;
#endif
    end;

    [Obsolete('Replaced by CreateLogEntry', '22.10')]
#pragma warning disable AA0245
    procedure InsertLogEntry(Description: Text; LoggingLevel: Enum "IDYS Logging Level");
    var
        IDYSLoggingHelper: Codeunit "IDYS Logging Helper";
    begin
        IDYSLoggingHelper.WriteLogEntry("No.", Description, LoggingLevel);
    end;
#pragma warning restore

    procedure CreateLogEntry(LogDescription: Text; LoggingLevel: Enum "IDYS Logging Level");
    var
        IDYSLoggingHelper: Codeunit "IDYS Logging Helper";
    begin
        IDYSLoggingHelper.WriteLogEntry("No.", LogDescription, LoggingLevel);
    end;

    procedure UpdateOrderLineStatus();
    var
        TransportOrderLine: Record "IDYS Transport Order Line";
    begin
        TransportOrderLine.SetRange("Transport Order No.", "No.");
        if not TransportOrderLine.IsEmpty() then
            TransportOrderLine.ModifyAll("Order Header Status", Status);
        Validate("Last Status Update", CurrentDateTime());
    end;

    local procedure UpdateSequenceNo()
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        if not (Status in [Status::Recalled, Status::Archived, Status::Done, Status::Error]) then
            exit;

        TransportOrderHeader.SetCurrentKey("Sequence No.");
        if TransportOrderHeader.FindLast() then
            "Sequence No." := TransportOrderHeader."Sequence No." + 1;
    end;

    [Obsolete('Moved to IDYS Transport Order Hdr. Mgt. codeunit', '18.5')]
    procedure GetExternalCountryCode(CountryCode: Code[10]): Code[10];
    begin
        exit(IDYSTransportOrderHdrMgt.GetExternalCountryCode(CountryCode));
    end;

    procedure AllowEditing(): Boolean;
    begin
        exit(
          Status in [
            Status::New,
            Status::Uploaded,
            Status::Recalled]);
    end;

    [Obsolete('Became obsolete in shipit multiprovider', '18.8')]
    procedure UpdateStatus();
    begin
    end;

    [Obsolete('Moved to IDYS Transport Order Hdr. Mgt. codeunit', '18.5')]
    procedure UpdateCurrencies();
    begin
    end;

    [Obsolete('All header-level files are now stored in attachments', '23.0')]
    procedure OpenShippingLabel(ThrowError: Boolean)
    begin
    end;

    procedure GetCalculatedWeight() GrossWeight: Decimal;
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        // Packages with content
        IDYSTransportOrderPackage.SetRange("Transport Order No.", "No.");
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                GrossWeight += IDYSTransportOrderPackage.GetPackageWeight();
            until IDYSTransportOrderPackage.Next() = 0;

        // Not assigned lines
        GrossWeight += GetCalculatedWeightForUnassignedLines();
    end;

    internal procedure GetCalculatedWeightForUnassignedLines() GrossWeight: Decimal
    var
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        DummyRecId: RecordId;
        ConversionFactor: Decimal;
    begin
        ConversionFactor := IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, "Carrier Entry No.");

        IDYSTransportOrderDelNote.SetLoadFields("Transport Order No.", "Transport Order Pkg. Record Id", "Gross Weight", Quantity);
        IDYSTransportOrderDelNote.SetRange("Transport Order No.", "No.");
        IDYSTransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", DummyRecId);
        if IDYSTransportOrderDelNote.FindSet() then
            repeat
                GrossWeight += ConversionFactor * IDYSTransportOrderDelNote."Gross Weight" * IDYSTransportOrderDelNote.Quantity;
            until IDYSTransportOrderDelNote.Next() = 0;
    end;

    [Obsolete('Moved to IDYS Transport Order Hdr. Mgt. codeunit', '18.5')]
    procedure UpdatePickupDate()
    begin
        IDYSTransportOrderHdrMgt.UpdatePickupDate(Rec);
    end;

    [Obsolete('Moved to IDYS Transport Order Hdr. Mgt. codeunit', '18.5')]
    procedure UpdateDeliveryDate()
    begin
        IDYSTransportOrderHdrMgt.UpdateDeliveryDate(Rec);
    end;


    #region [Sendcloud / Cargoson]
    procedure DetermineCustomsShipment()
    var
        SenderCountryRegion: Record "Country/Region";
        RecipientCountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
        CountryCode: Code[10];
    begin
        if "Country/Region Code (Pick-up)" <> '' then
            SenderCountryRegion.Get("Country/Region Code (Pick-up)")
        else begin
            CompanyInformation.Get();
            CountryCode := CompanyInformation.GetCompanyCountryRegionCode();
            if CountryCode <> '' then
                if SenderCountryRegion.Get(CountryCode) then;
        end;


        if "Country/Region Code (Ship-to)" <> '' then
            RecipientCountryRegion.Get("Country/Region Code (Ship-to)")
        else begin
            CompanyInformation.Get();
            CountryCode := CompanyInformation.GetCompanyCountryRegionCode();
            if CountryCode <> '' then
                if RecipientCountryRegion.Get(CountryCode) then;
        end;

        "Ship Outside EU" := (SenderCountryRegion.Code = '') or (RecipientCountryRegion.Code = ''); //customs cannot be determined
        if not "Ship Outside EU" then
            "Ship Outside EU" :=
                ((RecipientCountryRegion."EU Country/Region Code" <> '') and (SenderCountryRegion."EU Country/Region Code" = '')) or
                ((RecipientCountryRegion."EU Country/Region Code" = '') and (SenderCountryRegion."EU Country/Region Code" <> ''));
        if not "Ship Outside EU" then
            "Ship Outside EU" := (RecipientCountryRegion."EU Country/Region Code" = '') and (RecipientCountryRegion.Code <> SenderCountryRegion.Code);
    end;
    #endregion

#pragma warning disable AA0214
    procedure UpdateTotals()
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        IDYSTransportOrderPackage.SetRange("Transport Order No.", "No.");
        if IDYSTransportOrderPackage.FindSet(true) then
            repeat
                IDYSTransportOrderPackage.UpdateTotalWeight();
                IDYSTransportOrderPackage.UpdateTotalVolume();
                IDYSTransportOrderPackage.Modify(true);
            until IDYSTransportOrderPackage.Next() = 0;
    end;
#pragma warning restore
    procedure SetDefaultProvider(): Enum "IDYS Provider";
    var
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IsSendCloudEnabled: Boolean;
        IsnShiftShipEnabled: Boolean;
        IsTranssmartEnabled: Boolean;
        IsEasyPostEnabled: Boolean;
    begin
        // Check if multiple providers enabled
        IDYSProviderSetup.SetRange(Enabled, true);
        if IDYSProviderSetup.Count > 1 then
            exit;

        IsSendCloudEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Sendcloud, false);
        IsnShiftShipEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::"Delivery Hub", false);
        IsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Transsmart, false);
        IsEasyPostEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::EasyPost, false);

        if IsTranssmartEnabled xor IsnShiftShipEnabled xor IsSendCloudEnabled xor IsEasyPostEnabled then
            case true of
                IsTranssmartEnabled:
                    Validate(Provider, Provider::Transsmart);
                IsnShiftShipEnabled:
                    Validate(Provider, Provider::"Delivery Hub");
                IsSendCloudEnabled:
                    Validate(Provider, Provider::Sendcloud);
                IsEasyPostEnabled:
                    Validate(Provider, Provider::EasyPost);
            end;
    end;

    local procedure InsertDefaultTransportOrderPackage()
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        DefaultPackageTypeCode: Code[50];
    begin
        IProvider := Provider;
        IProvider.IsEnabled(true);

        if not IDYSSetup.Get() then
            exit;

        if SuppressDefaultPackageInsert then
            exit;

        if not IDYSSetup."Auto. Add One Default Package" then
            exit;

        case Provider of
            Provider::"Delivery Hub",
            Provider::EasyPost:
                begin
                    DefaultPackageTypeCode := IProvider.GetDefaultPackage("Carrier Entry No.", "Booking Profile Entry No.");
                    if DefaultPackageTypeCode = '' then
                        exit;

                    Clear(IDYSTransportOrderPackage);
                    IDYSTransportOrderPackage.SetRange("Carrier Entry No. Filter", Rec."Carrier Entry No.");
                    IDYSTransportOrderPackage.SetRange("Booking P. Entry No. Filter", IDYSProviderMgt.GetBookingProfileEntryNo("Carrier Entry No.", "Booking Profile Entry No."));
                    IDYSTransportOrderPackage.Init();
                    IDYSTransportOrderPackage.Validate("Transport Order No.", "No.");
                    IDYSTransportOrderPackage.Validate("Book. Prof. Package Type Code", DefaultPackageTypeCode);
                    IDYSTransportOrderPackage.Validate("System Created Entry", true);
                    IDYSTransportOrderPackage.Insert(true);
                end;
            else begin
                DefaultPackageTypeCode := IProvider.GetDefaultPackage("Carrier Entry No.", "Booking Profile Entry No.");
                if DefaultPackageTypeCode = '' then
                    exit;

                Clear(IDYSTransportOrderPackage);
                IDYSTransportOrderPackage.Init();
                IDYSTransportOrderPackage.Validate("Transport Order No.", "No.");
                IDYSTransportOrderPackage.PresetProvider(Rec.Provider);
                IDYSTransportOrderPackage.Validate("Provider Package Type Code", DefaultPackageTypeCode);
                IDYSTransportOrderPackage.Validate("System Created Entry", true);
                IDYSTransportOrderPackage.Insert(true);
            end;
        end;
    end;

    procedure SetSkipPackageValidation(Skip: Boolean)
    begin
        SkipPackageValidation := Skip;
    end;

    procedure SetLookupActorId(NewGlobalActorId: Text[30])
    begin
        GlobalActorId := NewGlobalActorId;
    end;

    procedure GetLookupActorId(): Text[30]
    begin
        exit(GlobalActorId);
    end;

    procedure SetSuppressDefaultPackageInsert(NewSuppressDefaultPackageInsert: Boolean)
    begin
        SuppressDefaultPackageInsert := NewSuppressDefaultPackageInsert;
    end;

    var
        Postcode: Record "Post Code";
        IDYSSetup: Record "IDYS Setup";
        IDYSTransportOrderHdrMgt: Codeunit "IDYS Transport Order Hdr. Mgt.";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IProvider: Interface "IDYS IProvider";
        SkipPackageValidation: Boolean;
        SuppressDefaultPackageInsert: Boolean;
        RenameErr: Label 'You cannot rename a %1.', comment = '%1 = Table Caption.';
        CreatedMsg: Label 'Created';
        CouldNotDeleteErr: Label 'Could not delete %1 %2.\\You cannot delete a %1 unless its %3 is either New or Recalled.', Comment = '%1 = Table Caption, %2 = No., %3 = Field Caption Status.';
        ProviderChangeNotAllowedErr: Label 'Changing the provider with status %1 is not allowed.', Comment = '%1 = status';
        ChangingShipFromShipToCountryQst: Label 'Changing the %1 will reset the selected services. \Do you want to continue? ', Comment = '%1 = Ship-to/Ship-from Country';
        EventLogEntryType: enum "IDYS Logging Level";
        GlobalActorId: Text[30];
}