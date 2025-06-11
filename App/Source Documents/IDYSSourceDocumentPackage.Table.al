table 11147708 "IDYS Source Document Package"
{
    Caption = 'Source Document Package';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = if ("Table No." = Const(11147669)) "IDYS Transport Order Header"."No."
            else
            if ("Table No." = Const(36)) "Sales Header"."No." where("Document Type" = field("Document Type"))
            else
            if ("Table No." = Const(38)) "Purchase Header"."No." where("Document Type" = field("Document Type"))
            else
            if ("Table No." = Const(110)) "Sales Shipment Header"."No."
            else
            if ("Table No." = Const(6650)) "Return Shipment Header"."No."
            else
            if ("Table No." = Const(6660)) "Return Receipt Header"."No."
            else
            if ("Table No." = Const(5740)) "Transfer Header"."No."
            else
            if ("Table No." = Const(5744)) "Transfer Shipment Header"."No."
            else
            if ("Table No." = Const(5900)) "Service Header"."No." where("Document Type" = field("Document Type"))
            else
            if ("Table No." = Const(5990)) "Service Shipment Header"."No.";
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        field(3; "Parcel Identifier"; Code[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Parcel Identifier';
        }

        field(4; "Table No."; Integer)
        {
            Caption = 'Table No.';
            Editable = false;
            DataClassification = SystemMetadata;
        }

        field(5; "Document Type"; Enum "IDYS Source Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
            DataClassification = SystemMetadata;
        }

        field(10; "External ID"; Integer)
        {
            BlankZero = true;
            Caption = 'External ID';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(14; "Provider Filter"; Enum "IDYS Provider")
        {
            Caption = 'Provider Filter';
            FieldClass = FlowFilter;
        }
        field(15; "Provider Package Type Code"; Code[50])
        {
            Caption = 'Package Type Code';
            TableRelation = "IDYS Provider Package Type".Code;
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ProviderPackageType: Record "IDYS Provider Package Type";
            begin
                // NOTE: Required as a filter because of the flow:
                //  OnValidateProvider_TransportOrderHeader -> InsertDefaultPackage()
                if Rec.GetFilter("Provider Filter") <> '' then
                    Rec.CopyFilter("Provider Filter", ProviderPackageType.Provider);
                ProviderPackageType.SetRange(Code, "Provider Package Type Code");
                if not ProviderPackageType.FindFirst() then
                    ProviderPackageType.Init();

                "Package Type" := ProviderPackageType.Type;
                Description := CopyStr(ProviderPackageType.Description, 1, MaxStrLen(Description));
                Length := ProviderPackageType.Length;
                Width := ProviderPackageType.Width;
                Height := ProviderPackageType.Height;
                Weight := ProviderPackageType.Weight;
                "Linear UOM" := ProviderPackageType."Linear UOM";
                "Mass UOM" := ProviderPackageType."Mass UOM";

                UpdateTotalVolume();
                UpdateTotalWeight();
            end;
        }
        field(16; "Book. Prof. Package Type Code"; Code[50])
        {
            Caption = 'Package Type Code';
            TableRelation = "IDYS BookingProf. Package Type"."Package Type Code" where("Carrier Entry No." = field("Carrier Entry No. Filter"), "Booking Profile Entry No." = field("Booking P. Entry No. Filter"));
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                BookingProfPackageType: Record "IDYS BookingProf. Package Type";
            begin
                if Rec.GetFilter("Booking P. Entry No. Filter") <> '' then
                    Rec.CopyFilter("Booking P. Entry No. Filter", BookingProfPackageType."Booking Profile Entry No.");
                if Rec.GetFilter("Carrier Entry No. Filter") <> '' then
                    Rec.CopyFilter("Carrier Entry No. Filter", BookingProfPackageType."Carrier Entry No.");
                BookingProfPackageType.SetRange("Package Type Code", "Book. Prof. Package Type Code");
                if not BookingProfPackageType.FindFirst() then
                    BookingProfPackageType.Init();

                "Provider Package Type Code" := BookingProfPackageType."Package Type Code";
                "Package Type" := CopyStr(BookingProfPackageType.Description, 1, MaxStrLen(Rec."Package Type"));
                Description := CopyStr(BookingProfPackageType.Description, 1, MaxStrLen(Description));
                Length := BookingProfPackageType.Length;
                Width := BookingProfPackageType.Width;
                Height := BookingProfPackageType.Height;
                Weight := BookingProfPackageType.Weight;
                "Linear UOM" := BookingProfPackageType."Linear UOM";
                "Mass UOM" := BookingProfPackageType."Mass UOM";
                "User Defined" := BookingProfPackageType."User Defined";

                UpdateTotalVolume();
                UpdateTotalWeight();
            end;
        }
        field(17; "User Defined"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(20; "Package Type Code"; Code[50])
        {
            Caption = 'Package Type Code';
            TableRelation = "IDYS Package Type";
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Restructured with Provider level';
        }

        field(21; "Package Type"; Text[50])
        {
            Caption = 'Package Type';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(22; "Package Type Description"; Text[128])
        {
            Caption = 'Package Type Description';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with field Description';
            ObsoleteTag = '25.0';
        }

        field(30; Description; Text[128])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(40; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 0;
            MinValue = 0;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Quantity replaced with multiplication action on a subpage';
            ObsoleteTag = '21.0';

            trigger OnValidate();
            begin
                UpdateTotalVolume();
                UpdateTotalWeight();
            end;
        }

        field(50; Length; Decimal)
        {
            Caption = 'Length';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateTotalVolume();
            end;
        }

        field(60; Width; Decimal)
        {
            Caption = 'Width';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateTotalVolume();
            end;
        }

        field(70; Height; Decimal)
        {
            Caption = 'Height';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateTotalVolume();
            end;
        }

        field(80; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateTotalWeight();
            end;
        }

        field(100; Volume; Decimal)
        {
            Caption = 'Volume';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(110; "Total Volume"; Decimal)
        {
            Caption = 'Total Volume';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(120; "Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(140; "Tracking No."; Code[50])
        {
            Caption = 'Tracking No.';
            DataClassification = CustomerContent;
        }

        field(150; "Linear UOM"; Code[3])
        {
            Caption = 'Linear UOM';
            DataClassification = CustomerContent;
        }

        field(151; "Mass UOM"; Code[3])
        {
            Caption = 'Mass UOM';
            DataClassification = CustomerContent;
        }
        field(204; "Load Meter"; Decimal)
        {
            Caption = 'Load Meter';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(211; "Booking P. Entry No. Filter"; Integer)
        {
            FieldClass = FlowFilter;
            TableRelation = "IDYS Provider Booking Profile"."Entry No.";
            Caption = 'Booking Profile Entry No.';
        }
        field(212; "Carrier Entry No. Filter"; Integer)
        {
            FieldClass = FlowFilter;
            TableRelation = "IDYS Provider Booking Profile"."Carrier Entry No.";
            Caption = 'Carrier Entry No. Filter';
        }

        #region [Sendcloud]
        field(255; "Shipping Method Description"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Shipping Method';
        }
        field(261; "Shipping Method Id"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Shipping Method Id';
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
        field(500; "System Created Entry"; Boolean)
        {
            Caption = 'System Created Entry';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Table No.", "Document Type", "Document No.", "Line No.")
        {
            SumIndexFields = "Total Volume", "Total Weight";
        }
    }

    trigger OnInsert();
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
    begin
        if "Line No." = 0 then begin
            SourceDocumentPackage.SetRange("Table No.", "Table No.");
            SourceDocumentPackage.SetRange("Document Type", "Document Type");
            SourceDocumentPackage.SetRange("Document No.", "Document No.");
            if SourceDocumentPackage.FindLast() then begin
                "Line No." := SourceDocumentPackage."Line No." + 1;
                "Parcel Identifier" := IncStr(SourceDocumentPackage."Parcel Identifier")
            end else begin
                "Line No." := 1;
                "Parcel Identifier" := Format("Document No.") + '-' + Format("Line No.") + '-' + Format(1);
            end;
        end;
        UpdateTotalVolume();
        UpdateTotalWeight();
    end;

    procedure UpdateTotalVolume();
    begin
        Volume := Length * Width * Height;
        "Total Volume" := Volume;
    end;

    procedure UpdateTotalWeight();
    begin
        "Total Weight" := Weight;
    end;

    procedure CopyFromSourceDocumentPackage(SourceDocumentPackage: Record "IDYS Source Document Package")
    var
        SalesHeader: Record "Sales Header";
    begin
        if SourceDocumentPackage."Table No." <> Database::"Sales Header" then
            exit;

        if not SalesHeader.Get(SourceDocumentPackage."Document Type", SourceDocumentPackage."Document No.") then
            exit;

        "Table No." := SourceDocumentPackage."Table No.";
        "Document Type" := SourceDocumentPackage."Document Type";
        "Document No." := SourceDocumentPackage."Document No.";

        case SalesHeader."IDYS Provider" of
            SalesHeader."IDYS Provider"::Default,
            SalesHeader."IDYS Provider"::Sendcloud,
            SalesHeader."IDYS Provider"::Transsmart,
            SalesHeader."IDYS Provider"::Cargoson:
                Validate("Provider Package Type Code", SourceDocumentPackage."Provider Package Type Code");
            SalesHeader."IDYS Provider"::"Delivery Hub",
            SalesHeader."IDYS Provider"::EasyPost:
                begin
                    SetRange("Carrier Entry No. Filter", SalesHeader."IDYS Carrier Entry No.");
                    SetRange("Booking P. Entry No. Filter", IDYSProviderMgt.GetBookingProfileEntryNo(SalesHeader."IDYS Carrier Entry No.", SalesHeader."IDYS Booking Profile Entry No."));
                    Validate("Book. Prof. Package Type Code", SourceDocumentPackage."Book. Prof. Package Type Code");
                end;
        end;
        "Package Type" := SourceDocumentPackage."Package Type";
        Description := SourceDocumentPackage.Description;
        Weight := SourceDocumentPackage.Weight;
        Length := SourceDocumentPackage.Length;
        Width := SourceDocumentPackage.Width;
        Height := SourceDocumentPackage.Height;
        Volume := SourceDocumentPackage.Volume;
        "Linear UOM" := SourceDocumentPackage."Linear UOM";
        "Mass UOM" := SourceDocumentPackage."Mass UOM";
        #region [Sendcloud]
        "Shipping Method Id" := SourceDocumentPackage."Shipping Method Id";
        "Shipping Method Description" := SourceDocumentPackage."Shipping Method Description";
        #endregion

        UpdateTotalVolume();
        UpdateTotalWeight();
    end;

    procedure MultiplyPackageByQuantity(Qty: Decimal)
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
        QtyInteger: Integer;
        i: Integer;
        ConvertErr: label 'Quantity must be an integer.';
    begin
        if Qty mod 1 <> 0 then
            Error(ConvertErr);
        QtyInteger := Qty;

        for i := 1 to QtyInteger do begin
            Clear(SourceDocumentPackage);
            SourceDocumentPackage.Init();
            SourceDocumentPackage."Line No." := 0;
            SourceDocumentPackage.CopyFromSourceDocumentPackage(Rec);
            SourceDocumentPackage.Validate("System Created Entry", true);
            SourceDocumentPackage.Insert(true);
        end;
    end;

    [Obsolete('UpdateTotalVolume is called directly', '25.0')]
    procedure UpdateVolume();
    begin
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
}

