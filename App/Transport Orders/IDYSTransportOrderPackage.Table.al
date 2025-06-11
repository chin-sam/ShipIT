table 11147672 "IDYS Transport Order Package"
{
    Caption = 'Transport Order Package';
    LookupPageId = "IDYS Transport Order Pck. List";

    fields
    {
        field(1; "Transport Order No."; Code[20])
        {
            Caption = 'Transport Order No.';
            NotBlank = true;
            TableRelation = "IDYS Transport Order Header";
            DataClassification = CustomerContent;
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

        field(10; "External ID"; Integer)
        {
            BlankZero = true;
            Caption = 'External ID';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(11; "License Plate No."; Code[20])
        {
            Caption = 'License Plate No.';
            DataClassification = CustomerContent;
        }

        field(15; "Provider Package Type Code"; Code[50])
        {
            Caption = 'Package Type Code';
            TableRelation = "IDYS Provider Package Type".Code;
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                TransportOrderHeader: Record "IDYS Transport Order Header";
                ProviderPackageType: Record "IDYS Provider Package Type";
                SpecialEquipment: Record "Special Equipment";
            begin
                if not TransportOrderHeader.Get("Transport Order No.") then
                    exit;

                if ExternalProvider <> ExternalProvider::Default then
                    ProviderPackageType.SetRange(Provider, ExternalProvider)
                else begin
                    TransportOrderHeader.TestField(Provider);
                    ProviderPackageType.SetRange(Provider, TransportOrderHeader.Provider);
                end;
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

                if not SkipUpdateTotals then begin
                    UpdateTotalVolume();
                    UpdateTotalWeight();
                end;

                if ProviderPackageType."Special Equipment Code" <> '' then begin
                    SpecialEquipment.Get(ProviderPackageType."Special Equipment Code");
                    Validate("Additional Reference", SpecialEquipment.Description);
                end else
                    Validate("Additional Reference", '');
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
                IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
                IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
            begin
                if Rec.GetFilter("Booking P. Entry No. Filter") <> '' then
                    Rec.CopyFilter("Booking P. Entry No. Filter", BookingProfPackageType."Booking Profile Entry No.")
                else
                    if Rec."Transport Order No." <> '' then
                        if IDYSTransportOrderHeader.Get(Rec."Transport Order No.") and (IDYSTransportOrderHeader."Booking Profile Entry No." <> 0) and (IDYSTransportOrderHeader."Carrier Entry No." <> 0) then
                            BookingProfPackageType.SetRange("Booking Profile Entry No.", IDYSProviderMgt.GetBookingProfileEntryNo(IDYSTransportOrderHeader."Carrier Entry No.", IDYSTransportOrderHeader."Booking Profile Entry No."));
                if Rec.GetFilter("Carrier Entry No. Filter") <> '' then
                    Rec.CopyFilter("Carrier Entry No. Filter", BookingProfPackageType."Carrier Entry No.")
                else
                    if Rec."Transport Order No." <> '' then
                        if IDYSTransportOrderHeader.Get(Rec."Transport Order No.") and (IDYSTransportOrderHeader."Carrier Entry No." <> 0) then
                            BookingProfPackageType.SetRange("Carrier Entry No.", IDYSTransportOrderHeader."Carrier Entry No.");
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

                if not SkipUpdateTotals then begin
                    UpdateTotalVolume();
                    UpdateTotalWeight();
                end;
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

            trigger OnValidate()
            var
                TransportOrderHeader: Record "IDYS Transport Order Header";
                ProviderPackageType: Record "IDYS Provider Package Type";
            begin
                if "Package Type Code" <> '' then begin
                    if TransportOrderHeader.Get("Transport Order No.") then
                        if ProviderPackageType.Get(TransportOrderHeader.Provider, "Package Type Code") then
                            Validate("Provider Package Type Code", ProviderPackageType.Code);
                end else
                    Validate("Provider Package Type Code", '');
            end;
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

        field(35; "Sub Status (External)"; Text[256])
        {
            Caption = 'Sub Status (External)';
            Editable = false;
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
                if not SkipUpdateTotals then begin
                    UpdateTotalVolume();
                    UpdateTotalWeight();
                end;
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
                if CurrFieldNo = FieldNo(Length) then
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
                if CurrFieldNo = FieldNo(Width) then
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
                if CurrFieldNo = FieldNo(Height) then
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
                if CurrFieldNo = FieldNo(Weight) then
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
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Volume';
            ObsoleteTag = '26.0';
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
            Editable = false;
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
        field(160; "Actual Delivery Date"; DateTime)
        {
            Caption = 'Actual Delivery Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(170; "Accepted By"; Text[80])
        {
            Caption = 'Accepted By';
            Editable = false;
            DataClassification = CustomerContent;
        }
        #region [Sendcloud]
        field(250; "Sendcloud Parcel Id."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Sendcloud Parcel Id.';
        }
        field(251; "Created"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Sent to Sendcloud';
        }
        // field(252; "Tracking URL"; Text[250])
        // {
        //     DataClassification = CustomerContent;
        //     Caption = 'Tracking URL';
        // }
        field(253; "Request Label"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Label';
        }
        field(254; "On Hold"; Boolean)  // doesn't have implementation
        {
            DataClassification = CustomerContent;
            Caption = 'On Hold';
        }
        field(255; "Shipping Method Description"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Shipping Method';
        }

        field(256; "Status"; Text[150]) // no longer sendcloud specific
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }

        field(257; "Actual Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Actual Weight';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if not SkipUpdateTotals then
                    UpdateTotalWeight();
            end;
        }

        field(258; "Additional Reference"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Additional Reference';
        }

        field(259; "Insured Value"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Insured Value';

            trigger OnValidate()
            var
                UseInsuredValueQst: Label 'Insured Value and Total Insured Value are mutually exclusive, are you sure you want to use Insured Value? This will remove the value (%1) for Total Insured Value.', Comment = '%1 = the Total Insured Value';
            begin
                if "Total Insured Value" <> 0 then
                    if Confirm(StrSubstNo(UseInsuredValueQst, "Total Insured Value"), false) then
                        "Total Insured Value" := 0
                    else
                        "Insured Value" := 0;
            end;
        }
        field(260; "Total Insured Value"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Insured Value';

            trigger OnValidate()
            var
                UseInsuredValueQst: Label 'Total Insured Value and Insured Value are mutually exclusive, are you sure you want to use Total Insured Value? This will remove the value (%1) for Insured Value.', Comment = '%1 = the Insured Value';
            begin
                if "Total Insured Value" <> 0 then
                    if Confirm(StrSubstNo(UseInsuredValueQst, "Insured Value"), false) then
                        "Insured Value" := 0
                    else
                        "Total Insured Value" := 0;
            end;
        }
        field(261; "Shipping Method Id"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Shipping Method Id';
        }
        #endregion

        #region [nShift Ship]
        field(200; "Package Tag"; Guid)
        {
            Caption = 'Shipment Tag';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(201; "Package No."; Text[50])
        {
            Caption = 'Package No.';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteReason = 'Duplicate';
            ObsoleteTag = '21.0';
        }

        field(202; "Tracking Url"; Text[250])
        {
            Caption = 'Tracking Url';
            Editable = false;
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(203; "Package Label Data"; Blob)
        {
            Caption = 'Package Label Data';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with the package documents';
            ObsoleteTag = '23.0';
        }

        field(204; "Load Meter"; Decimal)
        {
            Caption = 'Load Meter';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(205; "Package CSID"; integer)
        {
            Caption = 'Package CSID';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(206; "Carrier Entry No."; Integer)
        {
            CalcFormula = Lookup("IDYS Transport Order Header"."Carrier Entry No." where("No." = field("Transport Order No.")));
            FieldClass = FlowField;
            Editable = false;
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
        field(303; "Label Format"; Enum "IDYS DelHub Label Type")
        {
            Caption = 'Label Format';
            DataClassification = CustomerContent;
        }
        field(304; "Label Url"; Text[150])
        {
            Caption = 'Label Url';
            DataClassification = CustomerContent;
        }
        #endregion
        field(500; "System Created Entry"; Boolean)
        {
            Caption = 'System Created Entry';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(501; "API Carrier Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Carrier Entry No.';
            Editable = false;
            Description = 'Only used from API Codeunit with Temporary record';
        }
        field(502; "API Booking Profile Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Booking Profile Entry No.';
            Editable = false;
            Description = 'Only used from API Codeunit with Temporary record';
        }
    }

    keys
    {
        key(PK; "Transport Order No.", "Line No.")
        {
            SumIndexFields = Volume, "Total Weight";
        }
    }

    trigger OnInsert();
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        MinValue: Code[20];
        MaxValue: Code[20];
    begin
        if "Line No." = 0 then begin
            if "Transport Order No." = '' then
                if GetFilter("Transport Order No.") <> '' then
                    if TryGetTransportOrderNoRange(MinValue, MaxValue) then
                        if MinValue = MaxValue then
                            Validate("Transport Order No.", MinValue);
            TransportOrderPackage.SetRange("Transport Order No.", "Transport Order No.");
            if TransportOrderPackage.FindLast() then begin
                "Line No." := TransportOrderPackage."Line No." + 1;
                "Parcel Identifier" := IncStr(TransportOrderPackage."Parcel Identifier")
            end else begin
                "Line No." := 1;
                "Parcel Identifier" := Format("Transport Order No.") + '-' + Format("Line No.") + '-' + Format(1);
            end;
        end;
        if not SkipUpdateTotals then begin
            UpdateTotalVolume();
            UpdateTotalWeight();
        end;
    end;

    trigger OnDelete()
    var
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        DummyRecId: RecordId;
    begin
        TransportOrderDelNote.SetRange("Transport Order No.", Rec."Transport Order No.");
        TransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", Rec.RecordId);
        if not TransportOrderDelNote.IsEmpty() Then
            TransportOrderDelNote.ModifyAll("Transport Order Pkg. Record Id", DummyRecId);

        IDYSSCParcelDocument.SetRange("Transport Order No.", Rec."Transport Order No.");
        IDYSSCParcelDocument.SetRange("Parcel Identifier", Rec."Parcel Identifier");
        if not IDYSSCParcelDocument.IsEmpty() Then
            IDYSSCParcelDocument.DeleteAll();
    end;

    [TryFunction]
    local procedure TryGetTransportOrderNoRange(var MinValue: Code[20]; var MaxValue: Code[20])
    begin
        MinValue := GetRangeMin("Transport Order No.");
        MaxValue := GetRangeMax("Transport Order No.");
    end;

    procedure UpdateTotalVolume();
    begin
        Volume := Length * Width * Height;
    end;

    procedure UpdateTotalWeight()
    begin
        "Total Weight" := GetPackageWeight();
    end;

    procedure AssignedLines(): Integer
    var
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
    begin
        TransportOrderDelNote.SetRange("Transport Order No.", "Transport Order No.");
        TransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", RecordId());
        exit(TransportOrderDelNote.Count);
    end;

    procedure GetCalculatedWeight(): Decimal
    var
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        ConversionFactor: Decimal;
        GrossWeight: Decimal;
    begin
        if "Actual Weight" <> 0 then
            exit("Actual Weight");

        Calcfields("Carrier Entry No.");
        ConversionFactor := IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, "Carrier Entry No.");

        // Package weight
        GrossWeight := Rec.Weight;

        // Content weight
        TransportOrderDelNote.SetLoadFields("Transport Order No.", "Transport Order Pkg. Record Id", "Gross Weight", Quantity);
        TransportOrderDelNote.SetRange("Transport Order No.", "Transport Order No.");
        TransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", RecordId());
        if TransportOrderDelNote.FindSet() then
            repeat
                GrossWeight += ConversionFactor * TransportOrderDelNote."Gross Weight" * TransportOrderDelNote.Quantity;
            until TransportOrderDelNote.Next() = 0;
        exit(Round(GrossWeight, 0.01));
    end;

    procedure GetPackageWeight(): Decimal
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        IDYSSetup.Get();
        if "Actual Weight" <> 0 then
            exit("Actual Weight");

        if IDYSSetup."Link Del. Lines with Packages" then
            exit(GetCalculatedWeight());

        exit(Weight);
    end;

    procedure CopyFromTransportOrderPackage(TransportOrderPackage: Record "IDYS Transport Order Package")
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        TransportOrderHeader.Get(TransportOrderPackage."Transport Order No.");

        "Transport Order No." := TransportOrderPackage."Transport Order No.";
        "License Plate No." := TransportOrderPackage."License Plate No.";

        case TransportOrderHeader.Provider of
            TransportOrderHeader.Provider::Default,
            TransportOrderHeader.Provider::Sendcloud,
            TransportOrderHeader.Provider::Transsmart:
                Validate("Provider Package Type Code", TransportOrderPackage."Provider Package Type Code");
            TransportOrderHeader.Provider::"Delivery Hub",
            TransportOrderHeader.Provider::EasyPost:
                begin
                    SetRange("Carrier Entry No. Filter", TransportOrderHeader."Carrier Entry No.");
                    SetRange("Booking P. Entry No. Filter", IDYSProviderMgt.GetBookingProfileEntryNo(TransportOrderHeader."Carrier Entry No.", TransportOrderHeader."Booking Profile Entry No."));
                    Validate("Book. Prof. Package Type Code", TransportOrderPackage."Book. Prof. Package Type Code");
                end;
        end;
        "Package Type" := TransportOrderPackage."Package Type";
        Description := TransportOrderPackage.Description;
        Weight := TransportOrderPackage.Weight;
        Length := TransportOrderPackage.Length;
        Width := TransportOrderPackage.Width;
        Height := TransportOrderPackage.Height;
        Volume := TransportOrderPackage.Volume;
        "Request Label" := TransportOrderPackage."Request Label";
        "Actual Weight" := 0;
        "Additional Reference" := TransportOrderPackage."Additional Reference";
        "Insured Value" := TransportOrderPackage."Insured Value";
        "Total Insured Value" := TransportOrderPackage."Total Insured Value";
        "Linear UOM" := TransportOrderPackage."Linear UOM";
        "Mass UOM" := TransportOrderPackage."Mass UOM";
        #region [Sendcloud]
        "Shipping Method Id" := TransportOrderPackage."Shipping Method Id";
        "Shipping Method Description" := TransportOrderPackage."Shipping Method Description";
        #endregion
        UpdateTotalVolume();
        UpdateTotalWeight();
    end;

    procedure PresetProvider(Provider: Enum "IDYS Provider")
    begin
        ExternalProvider := Provider;
    end;

    procedure OpenShippingLabel(ThrowError: Boolean)
    var
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        DataCompression: Codeunit "Data Compression";
        UseZip: Boolean;
        FileOutStream: OutStream;
        FileInStream: InStream;
        ZipFilenameLbl: Label '%1.zip', Locked = true;
        FileName: Text;
        NoLabelErr: Label 'This transport order package does not contain a PDF label. Some carriers don''t support PDF labels. Please contact nShift for more information.';
    begin
        IDYSSCParcelDocument.SetRange("Transport Order No.", "Transport Order No.");
        IDYSSCParcelDocument.SetRange("Parcel Identifier", "Parcel Identifier");
        if IDYSSCParcelDocument.IsEmpty() and ThrowError then
            Error(NoLabelErr);

        if GuiAllowed() and not IDYSSCParcelDocument.IsEmpty() then begin
            if IDYSSCParcelDocument.Count > 1 then begin
                DataCompression.CreateZipArchive();
                UseZip := true;
            end;

            IDYSSCParcelDocument.SetAutoCalcFields(File);
            if IDYSSCParcelDocument.FindSet() then begin
                FileName := IDYSSCParcelDocument."File Name";
                repeat
                    IDYSSCParcelDocument."File".CreateInStream(FileInStream);
                    if UseZip then
                        DataCompression.AddEntry(FileInStream, IDYSSCParcelDocument."File Name")
                until IDYSSCParcelDocument.Next() = 0;
            end;

            TempBlob.CreateOutStream(FileOutStream);
            if UseZip then begin
                FileName := StrSubstNo(ZipFilenameLbl, IDYSSCParcelDocument."Parcel Identifier");
                DataCompression.SaveZipArchive(FileOutStream);
                DataCompression.CloseZipArchive();
            end else
                CopyStream(FileOutStream, FileInStream);

            FileManagement.BLOBExport(TempBlob, FileName, true);
        end;
    end;

    procedure SetPostponeTotals(NewSkipUpdateTotals: Boolean)
    begin
        SkipUpdateTotals := NewSkipUpdateTotals;
    end;

    [Obsolete('UpdateTotalVolume is called directly', '25.0')]
    procedure UpdateVolume();
    begin
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        ExternalProvider: Enum "IDYS Provider";
        SkipUpdateTotals: Boolean;
}
