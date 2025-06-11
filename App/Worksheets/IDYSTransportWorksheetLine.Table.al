table 11147667 "IDYS Transport Worksheet Line"
{
    Caption = 'Transport Worksheet Line';
    LookupPageId = "IDYS Transport Worksheet";

    fields
    {
        field(5; "Source Document Table No."; Integer)
        {
            DataClassification = CustomerContent;
        }

        field(6; "Source Table Caption"; Text[250])
        {
            Caption = 'Source Table';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object ID" = field("Source Document Table No."), "Object Type" = const(Table)));
            Editable = false;
        }

        field(10; "Source Document Type"; Enum "IDYS Source Document Type")
        {
            Caption = 'Source Document Type';
            DataClassification = CustomerContent;
        }

        field(20; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            TableRelation = if ("Source Document Table No." = const(36)) "Sales Header"."No." where("Document Type" = field("Source Document Type"))
            else
            if ("Source Document Table No." = const(38)) "Purchase Header"."No." where("Document Type" = field("Source Document Type"))
            else
            if ("Source Document Table No." = const(110)) "Sales Shipment Header"."No."
            else
            if ("Source Document Table No." = const(5740)) "Transfer Header"."No."
            else
            if ("Source Document Table No." = const(5744)) "Transfer Shipment Header"."No."
            else
            if ("Source Document Table No." = const(5746)) "Transfer Receipt Header"."No."
            else
            if ("Source Document Table No." = const(5900)) "Service Header"."No." where("Document Type" = field("Source Document Type"))
            else
            if ("Source Document Table No." = const(5990)) "Service Shipment Header"."No."
            else
            if ("Source Document Table No." = const(6650)) "Return Shipment Header"."No."
            else
            if ("Source Document Table No." = const(6660)) "Return Receipt Header"."No.";
            DataClassification = CustomerContent;
        }

        field(30; "Source Document Line No."; Integer)
        {
            Caption = 'Source Document Line No.';
            TableRelation = if ("Source Document Table No." = const(36)) "Sales Line"."Line No." where("Document Type" = field("Source Document Type"),
                                                                                                         "Document No." = field("Source Document No."),
                                                                                                         Type = const(Item))
            else
            if ("Source Document Table No." = const(38)) "Purchase Line"."Line No." where("Document Type" = filter(Order | "Return Order"),
                                                                                            "Document No." = field("Source Document No."),
                                                                                            Type = const(Item))
            else
            if ("Source Document Table No." = const(5900)) "Service Line"."Line No." where("Document Type" = const(Order),
                                                                                             "Document No." = field("Source Document No."),
                                                                                             Type = const(Item))
            else
            if ("Source Document Table No." = const(5740)) "Transfer Line"."Line No." where("Document No." = field("Source Document No."))
            else
            if ("Source Document Table No." = const(5744)) "Transfer Shipment Line"."Line No." where("Document No." = field("Source Document No."))
            else
            if ("Source Document Table No." = const(5746)) "Transfer Receipt Line"."Line No." where("Document No." = field("Source Document No."));
            DataClassification = CustomerContent;
        }

        field(40; Include; Boolean)
        {
            Caption = 'Include';
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate();
            begin
                if Include then
                    TestEssentialFields();
            end;
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
        field(100; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
            DataClassification = CustomerContent;
        }

        field(101; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(110; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(111; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            Editable = false;
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

        field(150; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemUnitofMeasure: Record "Item Unit of Measure";
            begin
                if ("Unit of Measure Code" <> '') and
                    ItemUnitofMeasure.Get("Item No.", "Unit of Measure Code")
                then begin
                    if "Qty. (Base)" <> Quantity * ItemUnitofMeasure."Qty. per Unit of Measure" then
                        Validate("Qty. (Base)", Quantity * ItemUnitofMeasure."Qty. per Unit of Measure");
                end else
                    if "Qty. (Base)" <> Quantity then
                        Validate("Qty. (Base)", Quantity);
            end;
        }

        field(151; "Qty. (Base)"; Decimal)
        {
            Caption = 'Qty. (Base)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            var
                ItemUnitofMeasure: Record "Item Unit of Measure";
            begin
                if ("Unit of Measure Code" <> '') and
                    ItemUnitofMeasure.Get("Item No.", "Unit of Measure Code")
                then begin
                    ItemUnitofMeasure.TestField("Qty. per Unit of Measure");
                    if "Qty. (Base)" <> Quantity * ItemUnitofMeasure."Qty. per Unit of Measure" then
                        Validate(Quantity, "Qty. (Base)" / ItemUnitofMeasure."Qty. per Unit of Measure")
                end else
                    if "Qty. (Base)" <> Quantity then
                        Validate(Quantity, "Qty. (Base)");
            end;
        }

        field(152; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            var
                ItemUnitofMeasure: Record "Item Unit of Measure";
            begin
                if ("Unit of Measure Code" <> '') and
                    ItemUnitofMeasure.Get("Item No.", "Unit of Measure Code")
                then
                    Validate("Qty. (Base)", Quantity * ItemUnitofMeasure."Qty. per Unit of Measure")
                else
                    Validate("Qty. (Base)", Quantity);
            end;
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
        field(200; "Source Document Description"; Text[100])
        {
            Caption = 'Source Document Description';
            DataClassification = CustomerContent;
        }

        field(210; "Combinability ID"; Code[40])
        {
            Caption = 'Combinability ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(220; "Package Type"; Code[50])
        {
            Caption = 'Package Type';
            DataClassification = CustomerContent;
            TableRelation = "IDYS Package Type";
            ObsoleteState = Pending;
            ObsoleteReason = 'Restructured with Provider level';
        }
        field(221; "Provider Package Type"; Code[50])
        {
            Caption = 'Package Type';
            DataClassification = CustomerContent;
        }
        field(1000; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ShippingAgentMapping: Record "IDYS Ship. Agent Mapping";
            begin
                if not ShippingAgentMapping.Get("Shipping Agent Code") then
                    ShippingAgentMapping.Init();
                Validate("Carrier Entry No.", ShippingAgentMapping."Carrier Entry No.");

                Validate("Shipping Agent Service Code", '');
                Validate("Provider Package Type", '');
            end;
        }
        field(1010; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                IDYSShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
            begin
                if not IDYSShippAgentSvcMapping.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                    IDYSShippAgentSvcMapping.Init();
                Validate("Booking Profile Entry No.", IDYSShippAgentSvcMapping."Booking Profile Entry No.");

                UpdateInclude();
            end;
        }

        field(1020; "Preferred Shipment Date"; Date)
        {
            Caption = 'Planned Shipment Date';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateInclude();
            end;
        }

        field(1030; "Preferred Delivery Date"; Date)
        {
            Caption = 'Planned Delivery Date';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateInclude();
            end;
        }

        field(1040; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateInclude();
            end;
        }

        field(2000; "Type (Pick-up)"; Option)
        {
            Caption = 'Type (Pick-up)';
            OptionCaption = ',,,Location,,,Customer,,,Vendor,Our Company';
            OptionMembers = ,,,Location,,,Customer,,,Vendor,Company;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Source Type (Pick-up)';
            ObsoleteTag = '21.0';
        }
        field(2001; "Source Type (Pick-up)"; Enum "IDYS Address Source Type")
        {
            Caption = 'Type (Pick-up)';
            DataClassification = CustomerContent;
        }
        field(2010; "No. (Pick-up)"; Code[20])
        {
            Caption = 'No. (Pick-up)';
            TableRelation = if ("Source Type (Pick-up)" = const(Location)) Location
            else
            if ("Source Type (Pick-up)" = const(Customer)) Customer
            else
            if ("Source Type (Pick-up)" = const(Vendor)) Vendor;
            DataClassification = CustomerContent;
        }

        field(2020; "Code (Pick-up)"; Code[10])
        {
            Caption = 'Code (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(2030; "Name (Pick-up)"; Text[100])
        {
            Caption = 'Name (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(2040; "Address (Pick-up)"; Text[100])
        {
            Caption = 'Address (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(2050; "Address 2 (Pick-up)"; Text[50])
        {
            Caption = 'Address 2 (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(2060; "Post Code (Pick-up)"; Code[20])
        {
            Caption = 'Post Code (Pick-up)';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                if CurrFieldNo = FieldNo("Post Code (Pick-up)") then
                    PostCode.ValidatePostCode("City (Pick-up)", "Post Code (Pick-up)", "County (Pick-up)", "Country/Region Code (Pick-up)", GuiAllowed());
            end;
        }

        field(2070; "City (Pick-up)"; Text[30])
        {
            Caption = 'City (Pick-up)';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                if CurrFieldNo = FieldNo("City (Pick-up)") then
                    PostCode.ValidateCity("City (Pick-up)", "Post Code (Pick-up)", "County (Pick-up)", "Country/Region Code (Pick-up)", GuiAllowed());
            end;
        }

        field(2080; "County (Pick-up)"; Text[30])
        {
            Caption = 'County (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(2090; "Country/Region Code (Pick-up)"; Code[10])
        {
            Caption = 'Country/Region Code (Pick-up)';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }

        field(2100; "Contact (Pick-up)"; Text[100])
        {
            Caption = 'Contact (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(2110; "Phone No. (Pick-up)"; Text[30])
        {
            Caption = 'Phone No. (Pick-up)';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(2111; "Mobile Phone No. (Pick-up)"; Text[30])
        {
            Caption = 'Mobile Phone No. (Pick-up)';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(2120; "Fax No. (Pick-up)"; Text[30])
        {
            Caption = 'Fax No. (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(2130; "E-Mail (Pick-up)"; Text[80])
        {
            Caption = 'E-Mail (Pick-up)';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }

        field(2140; "VAT Registration No. (Pick-up)"; Text[20])
        {
            Caption = 'VAT Registration No. (Pick-up)';
            DataClassification = CustomerContent;
        }

        field(3000; "Type (Ship-to)"; Option)
        {
            Caption = 'Type (Ship-to)';
            OptionCaption = ',,,Customer,,,Vendor,,,Location,Our Company';
            OptionMembers = ,,,Customer,,,Vendor,,,Location,Company;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Source Type (Pick-up)';
            ObsoleteTag = '21.0';
        }
        field(3001; "Source Type (Ship-to)"; Enum "IDYS Address Source Type")
        {
            Caption = 'Type (Ship-to)';
            DataClassification = CustomerContent;
        }
        field(3010; "No. (Ship-to)"; Code[20])
        {
            Caption = 'No. (Ship-to)';
            TableRelation = if ("Source Type (Ship-to)" = const(Customer)) Customer
            else
            if ("Source Type (Ship-to)" = const(Vendor)) Vendor
            else
            if ("Source Type (Ship-to)" = const(Location)) Location where("Use As In-Transit" = const(false));
            DataClassification = CustomerContent;
        }

        field(3020; "Code (Ship-to)"; Code[10])
        {
            Caption = 'Code (Ship-to)';
            TableRelation = if ("Source Type (Ship-to)" = const(Customer)) "Ship-to Address".Code where("Customer No." = field("No. (Ship-to)"))
            else
            if ("Source Type (Ship-to)" = const(Vendor)) "Order Address".Code where("Vendor No." = field("No. (Ship-to)"));
            DataClassification = CustomerContent;
        }

        field(3030; "Name (Ship-to)"; Text[100])
        {
            Caption = 'Name (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(3040; "Address (Ship-to)"; Text[100])
        {
            Caption = 'Address (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(3050; "Address 2 (Ship-to)"; Text[50])
        {
            Caption = 'Address 2 (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(3060; "Post Code (Ship-to)"; Code[20])
        {
            Caption = 'Post Code (Ship-to)';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                if CurrFieldNo = FieldNo("Post Code (Ship-to)") then
                    PostCode.ValidatePostCode("City (Ship-to)", "Post Code (Ship-to)", "County (Ship-to)", "Country/Region Code (Ship-to)", GuiAllowed());
            end;
        }

        field(3070; "City (Ship-to)"; Text[30])
        {
            Caption = 'City (Ship-to)';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                if CurrFieldNo = FieldNo("City (Ship-to)") then
                    PostCode.ValidateCity("City (Ship-to)", "Post Code (Ship-to)", "County (Ship-to)", "Country/Region Code (Ship-to)", GuiAllowed());
            end;
        }

        field(3080; "County (Ship-to)"; Text[30])
        {
            Caption = 'County (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(3090; "Country/Region Code (Ship-to)"; Code[10])
        {
            Caption = 'Country/Region Code (Ship-to)';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }

        field(3100; "Contact (Ship-to)"; Text[100])
        {
            Caption = 'Contact (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(3110; "Phone No. (Ship-to)"; Text[30])
        {
            Caption = 'Phone No. (Ship-to)';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(3111; "Mobile Phone No. (Ship-to)"; Text[30])
        {
            Caption = 'Mobile Phone No. (Ship-to)';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(3120; "Fax No. (Ship-to)"; Text[30])
        {
            Caption = 'Fax No. (Ship-to)';
            DataClassification = CustomerContent;
        }

        field(3130; "E-Mail (Ship-to)"; Text[80])
        {
            Caption = 'E-Mail (Ship-to)';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }

        field(3140; "VAT Registration No. (Ship-to)"; Text[20])
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
        }

        field(4010; "No. (Invoice)"; Code[20])
        {
            Caption = 'No. (Invoice)';
            TableRelation = if ("Source Type (Invoice)" = const(Customer)) Customer;
            DataClassification = CustomerContent;
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
        }

        field(4050; "Address 2 (Invoice)"; Text[50])
        {
            Caption = 'Address 2 (Invoice)';
            DataClassification = CustomerContent;
        }

        field(4060; "Post Code (Invoice)"; Code[20])
        {
            Caption = 'Post Code (Invoice)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if CurrFieldNo = FieldNo("Post Code (Invoice)") then
                    PostCode.ValidatePostCode("City (Invoice)", "Post Code (Invoice)", "County (Invoice)", "Country/Region Code (Invoice)", GuiAllowed());
            end;
        }

        field(4070; "City (Invoice)"; Text[30])
        {
            Caption = 'City (Invoice)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if CurrFieldNo = FieldNo("City (Invoice)") then
                    PostCode.ValidateCity("City (Invoice)", "Post Code (Invoice)", "County (Invoice)", "Country/Region Code (Invoice)", GuiAllowed());
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
        }

        field(4100; "Contact (Invoice)"; Text[100])
        {
            Caption = 'Contact (Invoice)';
            DataClassification = CustomerContent;
        }

        field(4110; "Phone No. (Invoice)"; Text[30])
        {
            Caption = 'Phone No. (Invoice)';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
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
        field(4150; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            Editable = false;
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;
        }
        field(4160; "Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            Editable = false;
            TableRelation = "IDYS Provider Booking Profile"."Entry No." where("Carrier Entry No." = field("Carrier Entry No."));
            DataClassification = CustomerContent;
        }
        field(4170; Provider; Enum "IDYS Provider")
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Provider where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Provider';
            Editable = false;
            FieldClass = FlowField;
        }

        field(4180; "Do Not Insure"; Boolean)
        {
            Caption = 'Do Not Insure';
            DataClassification = CustomerContent;
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
        #region [Sendcloud]
        field(9000; "Address Id. (Pick-up)"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sender Address';
            TableRelation = "IDYS SC Sender Address".Id;
            ObsoleteState = Removed;
            ObsoleteReason = 'Sender Address removed';
            ObsoleteTag = '21.0';
        }
        field(9001; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(9002; "Is Return"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Return';
        }
        #endregion
    }

    keys
    {
        key(PK; "Source Document Type", "Source Document No.", "Source Document Line No.")
        {
        }
        key(Key2; Include, "Combinability ID")
        {
        }
    }

    trigger OnInsert();
    var
        CombinabilityMgt: Codeunit "IDYS Combinability Mgt.";
    begin
        TestSourceDocTypeAllowed();
        "Combinability ID" := CombinabilityMgt.GetHashForTransportWorkshtLine(Rec);
    end;

    trigger OnModify();
    var
        CombinabilityMgt: Codeunit "IDYS Combinability Mgt.";
    begin
        TestSourceDocTypeAllowed();
        "Combinability ID" := CombinabilityMgt.GetHashForTransportWorkshtLine(Rec);
    end;

    trigger OnDelete()
    var
        SourceDocumentService: Record "IDYS Source Document Service";
        TransportWorksheetLine: Record "IDYS Transport Worksheet Line";
    begin
        // Clear Services
        TransportWorksheetLine.SetRange("Source Document Type", "Source Document Type");
        TransportWorksheetLine.SetRange("Source Document No.", "Source Document No.");
        TransportWorksheetLine.SetFilter("Source Document Line No.", '<>%1', "Source Document Line No.");
        if TransportWorksheetLine.IsEmpty() then begin
            SourceDocumentService.SetRange("Table No.", Database::"IDYS Transport Worksheet Line");
            SourceDocumentService.SetRange("Document Type", "Source Document Type");
            SourceDocumentService.SetRange("Document No.", "Source Document No.");
            SourceDocumentService.DeleteAll();
        end;
    end;

    procedure UpdateInclude();
    var
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        if not IDYSShipAgentMapping.Get("Shipping Agent Code") then
            IDYSShipAgentMapping.Init();

        ErrorMessage := '';

        case true of
            "Shipping Agent Code" = '':
                begin
                    Include := false;
                    ErrorMessage := StrSubstNo(FieldValueMustNotBeEmptyMsg, FieldCaption("Shipping Agent Code"));
                end;
            "Shipping Agent Service Code" = '':
                begin
                    Include := false;
                    ErrorMessage := StrSubstNo(FieldValueMustNotBeEmptyMsg, FieldCaption("Shipping Agent Service Code"));
                end;
            "Preferred Shipment Date" = 0D:
                begin
                    Include := false;
                    ErrorMessage := StrSubstNo(FieldValueMustNotBeEmptyMsg, FieldCaption("Preferred Shipment Date"));
                end;
            "Preferred Delivery Date" = 0D:
                begin
                    Include := false;
                    ErrorMessage := StrSubstNo(FieldValueMustNotBeEmptyMsg, FieldCaption("Preferred Delivery Date"));
                end;
            "Shipment Method Code" = '':
                if IDYSProviderMgt.CheckShipmentMethodCode(IDYSShipAgentMapping.Provider) then begin
                    Include := false;
                    ErrorMessage := StrSubstNo(FieldValueMustNotBeEmptyMsg, FieldCaption("Shipment Method Code"));
                end;
        end;
    end;

    procedure TestEssentialFields();
    var
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        TestField("Shipping Agent Code");
        TestField("Shipping Agent Service Code");
        TestField("Preferred Shipment Date");
        TestField("Preferred Delivery Date");

        if not IDYSShipAgentMapping.Get("Shipping Agent Code") then
            IDYSShipAgentMapping.Init();
        if IDYSProviderMgt.CheckShipmentMethodCode(IDYSShipAgentMapping.Provider) then
            TestField("Shipment Method Code");
    end;

    procedure TestSourceDocTypeAllowed();
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        IDYSSetup.Get();

        if not Rec.IsTemporary then
            case "Source Document Table No." of
                Database::"Sales Header",
                Database::"Purchase Header",
                Database::"Service Header",
                Database::"Transfer Header":
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Unposted documents");
                Database::"Sales Shipment Header",
                Database::"Return Shipment Header",
                Database::"Service Shipment Header",
                Database::"Return Receipt Header",
                Database::"Transfer Shipment Header",
                Database::"Transfer Receipt Header":
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Posted documents");
                else
                    Error(
                    UnknownErr,
                    FieldCaption("Source Document Type"),
                    "Source Document Type");
            end;
    end;

    procedure GetErrorMessage(): Text
    begin
        exit(ErrorMessage);
    end;

    var
        PostCode: Record "Post Code";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        UnknownErr: Label 'Unknown %1 (%2).', comment = '%1 = Caption of Source Document Type, %2 = Source Document Type.';
        FieldValueMustNotBeEmptyMsg: Label 'Field %1 value must not be empty.', Comment = '%1 = Name of field.';
        ErrorMessage: Text;
}

