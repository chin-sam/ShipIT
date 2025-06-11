codeunit 11147721 "IDYS Provider Mgt."
{

    procedure GetConversionFactor(IDYSConversionType: Enum "IDYS Conversion Type"; CarrierEntryNo: Integer): Decimal
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
    begin
        if IDYSProviderCarrier.Get(CarrierEntryNo) then
            case IDYSConversionType of
                IDYSConversionType::Mass:
                    if IDYSProviderCarrier."Conversion Factor (Mass)" <> 0 then
                        exit(IDYSProviderCarrier."Conversion Factor (Mass)");
                IDYSConversionType::Linear:
                    if IDYSProviderCarrier."Conversion Factor (Linear)" <> 0 then
                        exit(IDYSProviderCarrier."Conversion Factor (Linear)");
                IDYSConversionType::Volume:
                    if IDYSProviderCarrier."Conversion Factor (Volume)" <> 0 then
                        exit(IDYSProviderCarrier."Conversion Factor (Volume)");
            end;

        exit(GetConversionFactor(IDYSConversionType, IDYSProviderCarrier.Provider));
    end;

    local procedure GetConversionFactor(IDYSConversionType: Enum "IDYS Conversion Type"; IDYSProvider: Enum "IDYS Provider"): Decimal
    begin
        IDYSProvSetup.GetProviderSetup(IDYSProvider);

        case IDYSConversionType of
            IDYSConversionType::Mass:
                exit(IDYSProvSetup."Conversion Factor (Mass)");
            IDYSConversionType::Linear:
                exit(IDYSProvSetup."Conversion Factor (Linear)");
            IDYSConversionType::Volume:
                exit(IDYSProvSetup."Conversion Factor (Volume)");
        end;
    end;

    procedure GetRoundingPrecision(IDYSConversionType: Enum "IDYS Conversion Type"; CarrierEntryNo: Integer): Decimal
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
    begin
        if IDYSProviderCarrier.Get(CarrierEntryNo) then
            case IDYSConversionType of
                IDYSConversionType::Mass:
                    if IDYSProviderCarrier."Rounding Precision (Mass)" <> 0 then
                        exit(IDYSProviderCarrier."Rounding Precision (Mass)");
                IDYSConversionType::Linear:
                    if IDYSProviderCarrier."Rounding Precision (Linear)" <> 0 then
                        exit(IDYSProviderCarrier."Rounding Precision (Linear)");
                IDYSConversionType::Volume:
                    if IDYSProviderCarrier."Rounding Precision (Volume)" <> 0 then
                        exit(IDYSProviderCarrier."Rounding Precision (Volume)");
            end;

        exit(GetRoundingPrecision(IDYSConversionType, IDYSProviderCarrier.Provider));
    end;

    procedure GetRoundingPrecision(IDYSConversionType: Enum "IDYS Conversion Type"; IDYSProvider: Enum "IDYS Provider"): Decimal
    begin
        LoadSetup();
        IDYSProvSetup.GetProviderSetup(IDYSProvider);

        case IDYSConversionType of
            IDYSConversionType::Mass:
                exit(IDYSProvSetup."Rounding Precision (Mass)");
            IDYSConversionType::Linear:
                exit(IDYSProvSetup."Rounding Precision (Linear)");
            IDYSConversionType::Volume:
                exit(IDYSProvSetup."Rounding Precision (Volume)");
        end;
    end;

    procedure IsProvider(IDYSProvider: Enum "IDYS Provider"; var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        if TransportOrderHeader.Provider <> IDYSProvider then
            exit(false);
        exit(IsProviderEnabled(IDYSProvider, false));
    end;

    procedure IsProviderEnabled(IDYSProvider: Enum "IDYS Provider"; CheckAgainst: Enum "IDYS Provider"): Boolean
    begin
        if IDYSProvider <> CheckAgainst then
            exit(false);
        exit(IsProviderEnabled(IDYSProvider, false));
    end;

    procedure IsProvider(IDYSProvider: Enum "IDYS Provider"; var TransportOrderPackage: Record "IDYS Transport Order Package"): Boolean
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        TransportOrderHeader.Get(TransportOrderPackage."Transport Order No.");
        exit(IsProvider(IDYSProvider, TransportOrderHeader));
    end;

    procedure IsProvider(IDYSProvider: Enum "IDYS Provider"; var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"): Boolean
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        TransportOrderHeader.Get(TransportOrderDelNote."Transport Order No.");
        exit(IsProvider(IDYSProvider, TransportOrderHeader));
    end;

    procedure IsProviderEnabled(IDYSProvider: Enum "IDYS Provider"; ThrowError: Boolean): Boolean
    var
        ProviderSetup: Record "IDYS Provider Setup";
        ProvideIsNotEnabledErr: Label 'Provider (%1) is not enabled.', comment = '%1 = provider';
    begin
        if not ProviderSetup.Get(IDYSProvider) or not ProviderSetup.Enabled then
            if ThrowError then
                Error(ProvideIsNotEnabledErr, IDYSProvider);
        exit(ProviderSetup.Enabled);
    end;

    procedure IsInsuranceEnabled(IDYSProvider: Enum "IDYS Provider"): Boolean
    var
        ProviderSetup: Record "IDYS Setup";
    begin
        case IDYSProvider of
            IDYSProvider::Transsmart:
                begin
                    ProviderSetup.GetProviderSetup(IDYSProvider);
                    exit(ProviderSetup."Enable Insurance");
                end;
        end;
    end;

    procedure GetItemUOMDefaultPackage(var ItemUnitOfMeasure: Record "Item Unit of Measure"; Provider: Enum "IDYS Provider"; ShippingAgentCode: Code[10]; ShippingAgentSvcCode: Code[10]) ProviderPackageTypeCode: Code[50]
    var
        IDYSItemUOMPackage: Record "IDYS Item UOM Package";
        IDYSItemUOMProfilePackage: Record "IDYS Item UOM Profile Package";
        IsHandled: Boolean;
    begin
        OnBeforeGetItemUOMDefaultPackage(ItemUnitOfMeasure, Provider, ShippingAgentCode, ShippingAgentSvcCode, ProviderPackageTypeCode, IsHandled);
        if IsHandled then
            exit(ProviderPackageTypeCode);

        IDYSItemUOMPackage.SetRange("Item No.", ItemUnitofMeasure."Item No.");
        IDYSItemUOMPackage.SetRange("Code", ItemUnitofMeasure."Code");
        IDYSItemUOMPackage.SetRange("IDYS Provider", Provider);
        if IDYSItemUOMPackage.FindLast() then begin
            IDYSItemUOMPackage.CalcFields("Profile Packages");
            if IDYSItemUOMPackage."Profile Packages" then begin
                // Provider Profile Default Package
                IDYSItemUOMProfilePackage.SetRange("Item No.", ItemUnitofMeasure."Item No.");
                IDYSItemUOMProfilePackage.SetRange("Code", ItemUnitofMeasure."Code");
                IDYSItemUOMProfilePackage.SetRange("Item UOM Package Entry No.", IDYSItemUOMPackage."Entry No.");
                IDYSItemUOMProfilePackage.SetRange("Shipping Agent Code (Mapped)", ShippingAgentCode);
                if not (Provider = Provider::EasyPost) then
                    IDYSItemUOMProfilePackage.SetRange("Ship. Agent Svc. Code (Mapped)", ShippingAgentSvcCode);
                if IDYSItemUOMProfilePackage.FindLast() then
                    ProviderPackageTypeCode := IDYSItemUOMProfilePackage."Provider Package Type Code";
            end else
                // Provider Default Package
                ProviderPackageTypeCode := IDYSItemUOMPackage."Provider Package Type Code";
        end;

        OnAfterGetItemUOMDefaultPackage(ItemUnitOfMeasure, Provider, ShippingAgentCode, ShippingAgentSvcCode, ProviderPackageTypeCode);
    end;

    procedure CreateDefaultTransportOrderPackages(IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IDYSTransportOrderLine: Record "IDYS Transport Order Line";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IProvider: Interface "IDYS IProvider";
        Skipped: Boolean;
        IsHandled: Boolean;
        DefaultPackageTypeCode: Code[50];
    begin
        OnBeforeCreateDefaultTransportOrderPackages(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSTransportOrderPackage.SetRange("System Created Entry", true);
        if not IDYSTransportOrderPackage.IsEmpty() then
            IDYSTransportOrderPackage.DeleteAll(true);

        IDYSTransportOrderLine.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderLine.FindSet() then
            repeat
                if (IDYSTransportOrderLine."Unit of Measure Code" <> '') and
                    ItemUnitofMeasure.Get(IDYSTransportOrderLine."Item No.", IDYSTransportOrderLine."Unit of Measure Code")
                then begin
                    ItemUnitofMeasure.CalcFields("IDYS Default Provider Packages");
                    if ItemUnitofMeasure."IDYS Default Provider Packages" then begin
                        DefaultPackageTypeCode := GetItemUOMDefaultPackage(ItemUnitofMeasure, IDYSTransportOrderHeader.Provider, IDYSTransportOrderHeader."Shipping Agent Code", IDYSTransportOrderHeader."Shipping Agent Service Code");
                        if DefaultPackageTypeCode <> '' then
                            InsertTransportOrderPackage(IDYSTransportOrderHeader, DefaultPackageTypeCode, IDYSTransportOrderLine.Quantity)
                    end else
                        Skipped := true;
                end;
            until IDYSTransportOrderLine.Next() = 0;

        // Recreate default package
        IDYSSetup.Get();
        if Skipped and IDYSSetup."Auto. Add One Default Package" then begin
            IProvider := IDYSTransportOrderHeader.Provider;
            DefaultPackageTypeCode := IProvider.GetDefaultPackage(IDYSTransportOrderHeader."Carrier Entry No.", IDYSTransportOrderHeader."Booking Profile Entry No.");
            if DefaultPackageTypeCode <> '' then
                InsertTransportOrderPackage(IDYSTransportOrderHeader, DefaultPackageTypeCode, 1);
        end;

        OnAfterCreateDefaultTransportOrderPackages(IDYSTransportOrderHeader);
    end;

    procedure CreateDefaultSourceDocumentPackages(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        SourceDocumentPackage: Record "IDYS Source Document Package";
        IProvider: Interface "IDYS IProvider";
        Skipped: Boolean;
        DefaultPackageTypeCode: Code[50];
        IsHandled: Boolean;
    begin
        OnBeforeCreateDefaultSourceDocumentPackages(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        SourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        SourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        SourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
        SourceDocumentPackage.SetRange("System Created Entry", true);
        if not SourceDocumentPackage.IsEmpty() then
            SourceDocumentPackage.DeleteAll();

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetLoadFields("No.", "Unit of Measure Code", Quantity);
        if SalesLine.FindSet() then
            repeat
                if (SalesLine."Unit of Measure Code" <> '') and
                    ItemUnitofMeasure.Get(SalesLine."No.", SalesLine."Unit of Measure Code")
                then begin
                    ItemUnitofMeasure.CalcFields("IDYS Default Provider Packages");
                    if ItemUnitofMeasure."IDYS Default Provider Packages" then begin
                        DefaultPackageTypeCode := GetItemUOMDefaultPackage(ItemUnitofMeasure, SalesHeader."IDYS Provider", SalesHeader."Shipping Agent Code", SalesHeader."Shipping Agent Service Code");
                        if DefaultPackageTypeCode <> '' then
                            InsertSourceDocumentPackage(SalesHeader, DefaultPackageTypeCode, SalesLine.Quantity)
                    end else
                        Skipped := true;
                end;
            until SalesLine.Next() = 0;

        //recreate default package
        IDYSSetup.Get();
        if Skipped and IDYSSetup."Auto. Add One Default Package" then begin
            IProvider := SalesHeader."IDYS Provider";
            DefaultPackageTypeCode := IProvider.GetDefaultPackage(SalesHeader."IDYS Carrier Entry No.", SalesHeader."IDYS Booking Profile Entry No.");
            if DefaultPackageTypeCode <> '' then
                InsertSourceDocumentPackage(SalesHeader, DefaultPackageTypeCode, 1);
        end;

        OnAfterCreateDefaultSourceDocumentPackages(SalesHeader);
    end;

    procedure InsertSourceDocumentPackage(SalesHeader: Record "Sales Header"; PackageTypeCode: Code[50]; Qty: Decimal)
    var
        IsHandled: Boolean;
    begin
        OnBeforeInsertSourceDocumentPackage(SalesHeader, PackageTypeCode, Qty, IsHandled);
        if IsHandled then
            exit;
        InsertSourceDocumentPackage(SalesHeader."Document Type", SalesHeader."No.", SalesHeader."IDYS Provider", SalesHeader."IDYS Carrier Entry No.", SalesHeader."IDYS Booking Profile Entry No.", PackageTypeCode, Qty);
        OnAfterInsertSourceDocumentPackage(SalesHeader, PackageTypeCode, Qty);
    end;

    local procedure InsertSourceDocumentPackage(DocType: Enum "IDYS Source Document Type"; DocumentNo: Code[20]; Provider: Enum "IDYS Provider"; CarrierEntryNo: Integer; BookingProfileEntryNo: Integer; PackageTypeCode: Code[50]; Qty: Decimal)
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
        QtyInteger: Integer;
        i: Integer;
        ConvertErr: Label 'Failed to create sales package lines. Quantity must be an integer.';
    begin
        if Qty mod 1 <> 0 then
            Error(ConvertErr);
        QtyInteger := Qty;

        for i := 1 to QtyInteger do begin
            Clear(SourceDocumentPackage);
            SourceDocumentPackage.Init();
            SourceDocumentPackage.Validate("Table No.", Database::"Sales Header");
            SourceDocumentPackage.Validate("Document Type", DocType);
            SourceDocumentPackage.Validate("Document No.", DocumentNo);

            if Provider in [Provider::"Delivery Hub", Provider::EasyPost] then begin
                SourceDocumentPackage.SetRange("Carrier Entry No. Filter", CarrierEntryNo);
                SourceDocumentPackage.SetRange("Booking P. Entry No. Filter", IDYSProviderMgt.GetBookingProfileEntryNo(CarrierEntryNo, BookingProfileEntryNo));
                SourceDocumentPackage.Validate("Book. Prof. Package Type Code", PackageTypeCode);
            end else
                SourceDocumentPackage.Validate("Provider Package Type Code", PackageTypeCode);
            SourceDocumentPackage.Validate("System Created Entry", true);
            SourceDocumentPackage.Insert(true);
        end;
    end;

    procedure InsertTransportOrderPackage(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; PackageTypeCode: Code[50]; Qty: Decimal)
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        QtyInteger: Integer;
        i: Integer;
        IsHandled: Boolean;
        ConvertErr: Label 'Failed to create transport order package lines. Quantity must be an integer.';
    begin
        OnBeforeInsertTransportOrderPackage(IDYSTransportOrderHeader, PackageTypeCode, Qty, IsHandled);
        if IsHandled then
            exit;

        if Qty mod 1 <> 0 then
            Error(ConvertErr);
        QtyInteger := Qty;

        for i := 1 to QtyInteger do begin
            Clear(IDYSTransportOrderPackage);
            IDYSTransportOrderPackage.Init();
            IDYSTransportOrderPackage.Validate("Transport Order No.", IDYSTransportOrderHeader."No.");

            if IDYSTransportOrderHeader.Provider in [IDYSTransportOrderHeader.Provider::"Delivery Hub", IDYSTransportOrderHeader.Provider::EasyPost] then begin
                IDYSTransportOrderPackage.SetRange("Carrier Entry No. Filter", IDYSTransportOrderHeader."Carrier Entry No.");
                IDYSTransportOrderPackage.SetRange("Booking P. Entry No. Filter", IDYSProviderMgt.GetBookingProfileEntryNo(IDYSTransportOrderHeader."Carrier Entry No.", IDYSTransportOrderHeader."Booking Profile Entry No."));
                IDYSTransportOrderPackage.Validate("Book. Prof. Package Type Code", PackageTypeCode);
            end else
                IDYSTransportOrderPackage.Validate("Provider Package Type Code", PackageTypeCode);
            IDYSTransportOrderPackage.Validate("System Created Entry", true);
            IDYSTransportOrderPackage.Insert(true);
        end;

        OnAfterInsertTransportOrderPackage(IDYSTransportOrderHeader, PackageTypeCode, Qty);
    end;

    procedure Reset(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        DocumentAttachment: Record "Document Attachment";
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        LastParcelIdentifier: Code[30];
        IsHandled: Boolean;
    begin
        OnBeforeReset(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        // Reset packages
        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderPackage.FindLast() then begin
            LastParcelIdentifier := IDYSTransportOrderPackage."Parcel Identifier";
            if IDYSTransportOrderPackage.FindSet(true) then
                repeat
                    IsHandled := false;
                    OnBeforeResetPackage(IDYSTransportOrderHeader, IDYSTransportOrderPackage, LastParcelIdentifier, IsHandled);
                    if not IsHandled then begin
                        IDYSSCParcelDocument.SetRange("Transport Order No.", IDYSTransportOrderPackage."Transport Order No.");
                        IDYSSCParcelDocument.SetRange("Parcel Identifier", IDYSTransportOrderPackage."Parcel Identifier");
                        if not IDYSSCParcelDocument.IsEmpty() then
                            IDYSSCParcelDocument.DeleteAll();

                        IDYSTransportOrderPackage."Parcel Identifier" := IncStr(LastParcelIdentifier);

                        Clear(IDYSTransportOrderPackage."Sendcloud Parcel Id.");
                        Clear(IDYSTransportOrderPackage.Created);
                        Clear(IDYSTransportOrderPackage."Tracking No.");
                        Clear(IDYSTransportOrderPackage."Tracking URL");
                        Clear(IDYSTransportOrderPackage."Sub Status (External)");
                        Clear(IDYSTransportOrderPackage."Package CSID");
                        Clear(IDYSTransportOrderPackage."Package Tag");

                        Clear(IDYSTransportOrderPackage."Shipping Method Id");
                        Clear(IDYSTransportOrderPackage."Shipping Method Description");
                        Clear(IDYSTransportOrderPackage."Shipment Id");
                        Clear(IDYSTransportOrderPackage."Package Id");
                        Clear(IDYSTransportOrderPackage."Rate Id");
                        Clear(IDYSTransportOrderPackage."Label Url");

                        IDYSTransportOrderPackage.Validate(Status, '');
                        IDYSTransportOrderPackage.Modify(true);

                        IDYSSCParcelDocument.SetRange("Transport Order No.", IDYSTransportOrderPackage."Transport Order No.");
                        IDYSSCParcelDocument.SetRange("Parcel Identifier", IDYSTransportOrderPackage."Parcel Identifier");
                        if not IDYSSCParcelDocument.IsEmpty() then
                            IDYSSCParcelDocument.DeleteAll();

                        LastParcelIdentifier := IDYSTransportOrderPackage."Parcel Identifier";
                    end;
                until IDYSTransportOrderPackage.Next() = 0;
        end;

        // Reset order
        IsHandled := false;
        OnBeforeResetOrder(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        Clear(IDYSTransportOrderHeader."Shipment Error");
        Clear(IDYSTransportOrderHeader."Status (External)");
        Clear(IDYSTransportOrderHeader."Sub Status (External)");
        Clear(IDYSTransportOrderHeader."Tracking No.");
        Clear(IDYSTransportOrderHeader."Tracking URL");
        Clear(IDYSTransportOrderHeader."Shipment Tag");
        Clear(IDYSTransportOrderHeader."Shipment CSID");
        Clear(IDYSTransportOrderHeader."Booked with Error");
        Clear(IDYSTransportOrderHeader."Booking Reference");
        Clear(IDYSTransportOrderHeader."Booking Id");
        Clear(IDYSTransportOrderHeader."Label Url");
        Clear(IDYSTransportOrderHeader."CMR Url");
        Clear(IDYSTransportOrderHeader."Waybill Url");

        IDYSTransportOrderHeader.Status := IDYSTransportOrderHeader.Status::New;
        IDYSTransportOrderHeader.Modify();

        // Remove attachements
        DocumentAttachment.SetRange("Table ID", Database::"IDYS Transport Order Header");
        DocumentAttachment.SetRange("No.", IDYSTransportOrderHeader."No.");
        if not DocumentAttachment.IsEmpty() then
            DocumentAttachment.DeleteAll();

        OnAfterReset(IDYSTransportOrderHeader);
    end;

    procedure GetMeasurementCaptions(IDYSProvider: Enum "IDYS Provider"; var DistanceCaption: Text; var VolumeCaption: Text; var MassCaption: Text)
    var
        IDYSDefaultProvider: Codeunit "IDYS Default Provider";
        IDYSDelHubProvider: Codeunit "IDYS DelHub Provider";
        IDYSSendcloudProvider: Codeunit "IDYS Sendcloud Provider";
        IDYSTranssmartProvider: Codeunit "IDYS Transsmart Provider";
        IDYSEasyPostProvider: Codeunit "IDYS EasyPost Provider";
        IDYSCargosonProvider: Codeunit "IDYS Cargoson Provider";
    begin
        // NOTE: replaced interface procedure because of the error AS0066
        case IDYSProvider of
            IDYSProvider::Default:
                IDYSDefaultProvider.GetMeasurementCaptions(DistanceCaption, VolumeCaption, MassCaption);
            IDYSProvider::"Delivery Hub":
                IDYSDelHubProvider.GetMeasurementCaptions(DistanceCaption, VolumeCaption, MassCaption);
            IDYSProvider::Sendcloud:
                IDYSSendcloudProvider.GetMeasurementCaptions(DistanceCaption, VolumeCaption, MassCaption);
            IDYSProvider::Transsmart:
                IDYSTranssmartProvider.GetMeasurementCaptions(DistanceCaption, VolumeCaption, MassCaption);
            IDYSProvider::Cargoson:
                IDYSCargosonProvider.GetMeasurementCaptions(DistanceCaption, VolumeCaption, MassCaption);
            IDYSProvider::EasyPost:
                IDYSEasyPostProvider.GetMeasurementCaptions(DistanceCaption, VolumeCaption, MassCaption);
        end;
    end;

    procedure GetMeasurementCaption(FieldCaption: Text; Measure: Text): Text
    begin
        if Measure = '' then
            exit(FieldCaption);
        exit(StrSubstNo(MeasurementLbl, FieldCaption, Measure));
    end;

    procedure RunUserSetupPage(IDYSProvider: Enum "IDYS Provider")
    begin
        case IDYSProvider of
            IDYSProvider::Transsmart:
                Page.Run(Page::"IDYS User Setup");
            IDYSProvider::"Delivery Hub":
                Page.Run(Page::"IDYS Delivery Hub User Setup");
        end;
    end;

    procedure CheckShipmentMethodCode(IDYSProvider: Enum "IDYS Provider"): Boolean
    begin
        if not (IDYSProvider in [IDYSProvider::"Delivery Hub"]) then
            exit(true);
        exit(false);
    end;

    procedure GetBookingProfileEntryNo(CarrierEntryNo: Integer; BookingProfileEntryNo: Integer): Integer
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
    begin
        if IDYSProviderCarrier.Get(CarrierEntryNo) then
            if IDYSProviderCarrier.Provider = IDYSProviderCarrier.Provider::EasyPost then
                exit(0);
        exit(BookingProfileEntryNo);
    end;

    local procedure LoadSetup()
    begin
        if ProviderSetupLoaded then
            exit;

        IDYSProvSetup.Get();
        ProviderSetupLoaded := true;
    end;

    procedure IsSkipRequiredOnShipmentMethod(ShipmentMethodCode: Code[10]; ShowNotification: Boolean): Boolean
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        if (ShipmentMethodCode <> '') and ShipmentMethod.Get(ShipmentMethodCode) then
            if ShipmentMethod."IDYS Skip Transport Order" then begin
                if GuiAllowed() and ShowNotification then
                    IDYSNotificationManagement.SendSkipTransportCreationNotification();
                exit(true);
            end;
    end;

    procedure CheckTransportOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        NoPackagesTok: Label '72900679-cd2a-4fff-a60b-4142aed74a9b', Locked = true;
        NoPackagesMsg: Label 'No package lines found, at least one package should be specified for Transport Order %1.', Comment = '%1 = Transport Order No.';
        IsHandled: Boolean;
    begin
        OnBeforeCheckTransportOrder(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;
        // All generic checks in between the ValidateTransportOrder() implementations
        IDYSTransportOrderHeader.TestField("Shipping Agent Code");
        IDYSTransportOrderHeader.TestField("Shipping Agent Service Code");
        IDYSTransportOrderHeader.TestField("Carrier Entry No.");

        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderPackage.IsEmpty() then
            if GuiAllowed() then begin
                IDYSNotificationManagement.SendNotification(NoPackagesTok, StrSubstNo(NoPackagesMsg, IDYSTransportOrderHeader."No."));
                Error('');
            end else
                Error(NoPackagesMsg, IDYSTransportOrderHeader."No.");

        CheckLinkedDelLines(IDYSTransportOrderHeader);
        OnAfterCheckTransportOrder(IDYSTransportOrderHeader);
    end;

    procedure CheckLinkedDelLines(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        DummyRecId: RecordId;
        IsHandled: Boolean;
        DelNotesAssignedErr: Label 'All Delivery Note lines for Transport Order %1 must be assigned to a package.', Comment = '%1 = Transport Order No.';
    begin
        IDYSSetup.Get();
        if IDYSSetup."Link Del. Lines with Packages" then begin
            OnBeforeCheckLinkedDelLines(IDYSTransportOrderHeader, IsHandled);
            IDYSTransportOrderDelNote.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
            IDYSTransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", DummyRecId);
            if not IDYSTransportOrderDelNote.IsEmpty() then
                Error(DelNotesAssignedErr, IDYSTransportOrderHeader."No.");
        end;
    end;

    procedure Authenticate(IDYSProvider: Enum "IDYS Provider")
    var
        IDYSAPIHelper: Codeunit "IDYS API Helper";
    begin
        if IDYSProvider <> IDYSProvider::Transsmart then
            exit;

        IDYSAPIHelper.Authenticate();
    end;

    procedure SetShippingMethod(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IDYSSendcloudAPIDocsMgt: Codeunit "IDYS Sendcloud API Docs. Mgt.";
        IDYSEasyPostAPIDocsMgt: Codeunit "IDYS EasyPost API Docs. Mgt.";
    begin
        case IDYSTransportOrderHeader.Provider of
            IDYSTransportOrderHeader.Provider::Sendcloud:
                IDYSSendcloudAPIDocsMgt.SetShippingMethod(IDYSTransportOrderHeader);
            IDYSTransportOrderHeader.Provider::EasyPost:
                IDYSEasyPostAPIDocsMgt.SetShippingMethod(IDYSTransportOrderHeader);
        end;
    end;

    #region [PrintIT]
    procedure PrintLabelFromDocumentAttachment(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") Printed: Boolean
    var
        DocumentAttachment: Record "Document Attachment";
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        FileInStream: InStream;
        FileAsBase64: Text;
        FileOutStream: OutStream;
    begin
        DocumentAttachment.SetRange("Table ID", Database::"IDYS Transport Order Header");
        DocumentAttachment.SetRange("No.", IDYSTransportOrderHeader."No.");
        DocumentAttachment.SetRange("IDYS Label", true);
        if DocumentAttachment.FindSet() then
            repeat
                if DocumentAttachment."Document Reference ID".HasValue then begin
                    TempBlob.CreateOutStream(FileOutStream);
                    DocumentAttachment."Document Reference ID".ExportStream(FileOutStream);
                    TempBlob.CreateInStream(FileInStream);
                    FileAsBase64 := Base64Convert.ToBase64(FileInStream);
                    PrintLabel(FileAsBase64, DocumentAttachment."File Name", DocumentAttachment."File Extension", Printed);
                end;
            until DocumentAttachment.Next() = 0;
    end;

    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") Printed: Boolean
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                PrintLabel(IDYSTransportOrderPackage, Printed);
            until IDYSTransportOrderPackage.Next() = 0;
    end;

    procedure PrintLabel(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var Printed: Boolean)
    var
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        Base64Convert: Codeunit "Base64 Convert";
        FileManagement: Codeunit "File Management";
        FileInStream: InStream;
        FileAsBase64: Text;
    begin
        IDYSSCParcelDocument.SetAutoCalcFields(File);
        IDYSSCParcelDocument.SetRange("Transport Order No.", IDYSTransportOrderPackage."Transport Order No.");
        IDYSSCParcelDocument.SetRange("Parcel Identifier", IDYSTransportOrderPackage."Parcel Identifier");
        if IDYSSCParcelDocument.FindSet() then
            repeat
                IDYSSCParcelDocument."File".CreateInStream(FileInStream);
                FileAsBase64 := Base64Convert.ToBase64(FileInStream);
                PrintLabel(FileAsBase64, FileManagement.GetFileNameWithoutExtension(IDYSSCParcelDocument."File Name"), FileManagement.GetExtension(IDYSSCParcelDocument."File Name"), Printed);
            until IDYSSCParcelDocument.Next() = 0;
    end;

    local procedure PrintLabel(FileAsBase64: Text; FileName: Text; FileExtension: Text; var Printed: Boolean)
    var
        IDYPPrinter: Record "IDYP Printer";
        IDYPPrintNodeManagement: Codeunit "IDYP PrintNode Management";
        LabelPrinted: Boolean;
    begin
        if IDYPPrinter.Get(IDYPPrintNodeManagement.GetUserPrinter(FileExtension)) and (FileAsBase64 <> '') then begin
            LabelPrinted := IDYPPrintNodeManagement.PrintJob(IDYPPrinter, IDYPPrintNodeManagement.InitPrinting(IDYPPrinter, FileAsBase64, LowerCase(FileExtension) = 'pdf', FileName));

            // The label was printed at least once
            if LabelPrinted and not Printed then
                Printed := true;
        end;
    end;

    procedure IsPrintITEnabled(Provider: Enum "IDYS Provider"): Boolean
    var
        IDYSProviderSetup: Record "IDYS Setup";
    begin
        IDYSProviderSetup.GetProviderSetup(Provider);
        if IDYSProviderSetup."Enable PrintIT Printing" then
            exit(true);
    end;
    #endregion

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYS Verify Setup", 'OnVerifySetup', '', true, false)]
    local procedure IDYSVerifySetup_OnVerifySetup(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary)
    var
        IDYSDelHubProvider: Codeunit "IDYS DelHub Provider";
        IDYSSendcloudProvider: Codeunit "IDYS Sendcloud Provider";
        IDYSTranssmartProvider: Codeunit "IDYS Transsmart Provider";
        IDYSEasyPostProvider: Codeunit "IDYS EasyPost Provider";
        IDYSCargosonProvider: Codeunit "IDYS Cargoson Provider";
    begin
        if IsProviderEnabled("IDYS Provider"::"Delivery Hub", false) then
            IDYSTranssmartProvider.VerifySetup(TempSetupVerificationResultBuffer);
        if IsProviderEnabled("IDYS Provider"::Sendcloud, false) then
            IDYSSendcloudProvider.VerifySetup(TempSetupVerificationResultBuffer);
        if IsProviderEnabled("IDYS Provider"::Transsmart, false) then
            IDYSDelHubProvider.VerifySetup(TempSetupVerificationResultBuffer);
        if IsProviderEnabled("IDYS Provider"::EasyPost, false) then
            IDYSEasyPostProvider.VerifySetup(TempSetupVerificationResultBuffer);
        if IsProviderEnabled("IDYS Provider"::Cargoson, false) then
            IDYSCargosonProvider.VerifySetup(TempSetupVerificationResultBuffer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYS Publisher", 'OnAfterProviderCarrierSelectLookup', '', true, false)]
    local procedure IDYSPublisher_OnAfterProviderCarrierSelectLookup(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select")
    var
        IDYSDelHubProvider: Codeunit "IDYS DelHub Provider";
        IDYSSendcloudProvider: Codeunit "IDYS Sendcloud Provider";
        IDYSTranssmartProvider: Codeunit "IDYS Transsmart Provider";
        IDYSEasyPostProvider: Codeunit "IDYS EasyPost Provider";
        IDYSCargosonProvider: Codeunit "IDYS Cargoson Provider";
    begin
        if not IsProviderEnabled(TransportOrderHeader.Provider, false) then
            exit;

        case TransportOrderHeader.Provider of
            "IDYS Provider"::"Delivery Hub":
                IDYSDelHubProvider.ProviderCarrierSelectLookup(TransportOrderHeader, TempProviderCarrierSelect);
            "IDYS Provider"::EasyPost:
                IDYSEasyPostProvider.ProviderCarrierSelectLookup(TransportOrderHeader, TempProviderCarrierSelect);
            "IDYS Provider"::Sendcloud:
                IDYSSendCloudProvider.ProviderCarrierSelectLookup(TransportOrderHeader, TempProviderCarrierSelect);
            "IDYS Provider"::Transsmart:
                IDYSTranssmartProvider.ProviderCarrierSelectLookup(TransportOrderHeader, TempProviderCarrierSelect);
            "IDYS Provider"::Cargoson:
                IDYSCargosonProvider.ProviderCarrierSelectLookup(TransportOrderHeader, TempProviderCarrierSelect);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYS Publisher", 'OnAfterProviderCarrierSelectLookup_SalesHeader', '', true, false)]
    local procedure IDYSPublisher_OnAfterProviderCarrierSelectLookup_SalesHeader(var SalesHeader: Record "Sales Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select")
    var
        IDYSDelHubProvider: Codeunit "IDYS DelHub Provider";
        IDYSSendcloudProvider: Codeunit "IDYS Sendcloud Provider";
        IDYSTranssmartProvider: Codeunit "IDYS Transsmart Provider";
        IDYSEasyPostProvider: Codeunit "IDYS EasyPost Provider";
        IDYSCargosonProvider: Codeunit "IDYS Cargoson Provider";
    begin
        if not IsProviderEnabled(SalesHeader."IDYS Provider", false) then
            exit;

        case SalesHeader."IDYS Provider" of
            "IDYS Provider"::"Delivery Hub":
                IDYSDelHubProvider.ProviderCarrierSelectLookup_SalesHeader(SalesHeader, TempProviderCarrierSelect);
            "IDYS Provider"::EasyPost:
                IDYSEasyPostProvider.ProviderCarrierSelectLookup_SalesHeader(SalesHeader, TempProviderCarrierSelect);
            "IDYS Provider"::Sendcloud:
                IDYSSendcloudProvider.ProviderCarrierSelectLookup_SalesHeader(SalesHeader, TempProviderCarrierSelect);
            "IDYS Provider"::Transsmart:
                IDYSTranssmartProvider.ProviderCarrierSelectLookup_SalesHeader(SalesHeader, TempProviderCarrierSelect);
            "IDYS Provider"::Cargoson:
                IDYSCargosonProvider.ProviderCarrierSelectLookup_SalesHeader(SalesHeader, TempProviderCarrierSelect);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"IDYS Transport Order Header", 'OnAfterValidateEvent', 'Shipping Agent Code', true, false)]
    local procedure IDYSTransportOrderHeader_OnAfterValidateShippingAgentCode(var Rec: Record "IDYS Transport Order Header"; var xRec: Record "IDYS Transport Order Header"; CurrFieldNo: Integer)
    var
        IDYSSendcloudProvider: Codeunit "IDYS Sendcloud Provider";
        IDYSEasyPostProvider: Codeunit "IDYS EasyPost Provider";
    begin
        if not IsProviderEnabled(Rec.Provider, false) then
            exit;

        // Avoid double validation when selecting service
        if CurrFieldNo = 0 then
            exit;

        case Rec.Provider of
            "IDYS Provider"::EasyPost:
                IDYSEasyPostProvider.IDYSTransportOrderHeader_ValidateShippingAgentCode(Rec, xRec, CurrFieldNo);
            "IDYS Provider"::Sendcloud:
                IDYSSendcloudProvider.IDYSTransportOrderHeader_ValidateShippingAgentCode(Rec, xRec, CurrFieldNo);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Shipping Agent Code', true, false)]
    local procedure SalesHeader_OnAfterValidateShippingAgentCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        IDYSSendcloudAPIDocsMgt: Codeunit "IDYS Sendcloud API Docs. Mgt.";
        IDYSEasypostAPIDocsMgt: Codeunit "IDYS EasyPost API Docs. Mgt.";
    begin
        if not IsProviderEnabled(Rec."IDYS Provider", false) then
            exit;

        // Avoid double validation when selecting service
        if CurrFieldNo = 0 then
            exit;

        // Reset shipping method
        case Rec."IDYS Provider" of
            "IDYS Provider"::EasyPost:
                IDYSEasypostAPIDocsMgt.ResetSalesHeaderShippingMethod(Rec);
            "IDYS Provider"::Sendcloud:
                IDYSSendcloudAPIDocsMgt.ResetSalesHeaderShippingMethod(Rec);

        end;
    end;

    #region [Select Default Shipping Price]
    [EventSubscriber(ObjectType::Table, Database::"IDYS Transport Order Header", 'OnAfterValidateEvent', 'Shipping Agent Service Code', true, false)]
    local procedure IDYSTransportOrderHeader_OnAfterValidateShippingAgentServiceCode(var Rec: Record "IDYS Transport Order Header"; var xRec: Record "IDYS Transport Order Header"; CurrFieldNo: Integer)
    var
        IDYSSendcloudAPIDocsMgt: Codeunit "IDYS Sendcloud API Docs. Mgt.";
        IDYSEasypostAPIDocsMgt: Codeunit "IDYS EasyPost API Docs. Mgt.";
    begin
        if not IsProviderEnabled(Rec.Provider, false) then
            exit;

        // Avoid double validation when selecting service
        if CurrFieldNo = 0 then
            exit;

        case Rec.Provider of
            "IDYS Provider"::EasyPost:
                IDYSEasypostAPIDocsMgt.SetShippingMethod(Rec);
            "IDYS Provider"::Sendcloud:
                IDYSSendcloudAPIDocsMgt.SetShippingMethod(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Shipping Agent Service Code', true, false)]
    local procedure SalesHeader_OnAfterValidateShippingAgentServiceCode(CurrFieldNo: Integer; var Rec: Record "Sales Header")
    var
        IDYSSendcloudAPIDocsMgt: Codeunit "IDYS Sendcloud API Docs. Mgt.";
        IDYSEasypostAPIDocsMgt: Codeunit "IDYS EasyPost API Docs. Mgt.";
    begin
        if not IsProviderEnabled(Rec."IDYS Provider", false) then
            exit;

        // Avoid double validation when selecting service
        if CurrFieldNo = 0 then
            exit;

        case Rec."IDYS Provider" of
            "IDYS Provider"::EasyPost:
                IDYSEasypostAPIDocsMgt.SetShippingMethod(Rec);
            "IDYS Provider"::Sendcloud:
                IDYSSendcloudAPIDocsMgt.SetShippingMethod(Rec);
        end;
    end;
    #endregion

    [EventSubscriber(ObjectType::Table, Database::"IDYS Transport Order Header", 'OnAfterValidateEvent', 'Country/Region Code (Ship-to)', true, false)]
    local procedure IDYSTransportOrderHeader_OnAfterValidateCountryRegionCodeShipto(var Rec: Record "IDYS Transport Order Header")
    begin
        if not IsProviderEnabled(Rec.Provider, false) then
            exit;

        case Rec.Provider of
            "IDYS Provider"::Sendcloud, "IDYS Provider"::Cargoson:
                Rec.DetermineCustomsShipment();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"IDYS Transport Order Package", 'OnBeforeInsertEvent', '', true, false)]
    local procedure IDYSTransportOrderPackage_OnBeforeInsertEvent(RunTrigger: Boolean; var Rec: Record "IDYS Transport Order Package")
    var
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSEasyPostProvider: Codeunit "IDYS EasyPost Provider";
        IDYSSendCloudProvider: Codeunit "IDYS SendCloud Provider";
    begin
        if not IDYSTransportOrderHeader.Get(Rec."Transport Order No.") then
            exit;

        if not IsProviderEnabled(IDYSTransportOrderHeader.Provider, false) then
            exit;
        case IDYSTransportOrderHeader.Provider of
            IDYSTransportOrderHeader.Provider::EasyPost:
                IDYSEasyPostProvider.IDYSTransportOrderPackage_OnBeforeInsertEvent(RunTrigger, Rec);
            IDYSTransportOrderHeader.Provider::Sendcloud:
                IDYSSendCloudProvider.IDYSTransportOrderPackage_OnBeforeInsertEvent(RunTrigger, Rec);
        end;
    end;

    #region [Obsolete]
    [Obsolete('New parameter added', '23.0')]
    procedure IsSkipRequiredOnShipmentMethod(ShipmentMethodCode: Code[10]): Boolean
    begin
    end;

    [Obsolete('The code moved to the tables', '22.0')]
    procedure GetShipFromCountryCode(SourceTableNo: Integer; SourceSystemId: Guid) ShipFromCountryCode: Code[10]
    begin
    end;

    [Obsolete('Authorization is now associated with the license key', '23.0')]
    [NonDebuggable]
    procedure CheckAuthorization(Authorization: Guid; Provider: Enum "IDYS Provider")
    begin
    end;
    #endregion

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckTransportOrder(var TransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckTransportOrder(var TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckLinkedDelLines(var TransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetItemUOMDefaultPackage(ItemUnitOfMeasure: Record "Item Unit of Measure"; Provider: Enum "IDYS Provider"; ShippingAgentCode: Code[10]; ShippingAgentSvcCode: Code[10]; var ProviderPackageTypeCode: Code[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetItemUOMDefaultPackage(ItemUnitOfMeasure: Record "Item Unit of Measure"; Provider: Enum "IDYS Provider"; ShippingAgentCode: Code[10]; ShippingAgentSvcCode: Code[10]; var ProviderPackageTypeCode: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDefaultTransportOrderPackages(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDefaultTransportOrderPackages(IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDefaultSourceDocumentPackages(SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDefaultSourceDocumentPackages(SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSourceDocumentPackage(SalesHeader: Record "Sales Header"; PackageTypeCode: Code[50]; Qty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSourceDocumentPackage(SalesHeader: Record "Sales Header"; PackageTypeCode: Code[50]; Qty: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTransportOrderPackage(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; PackageTypeCode: Code[50]; Qty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertTransportOrderPackage(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; PackageTypeCode: Code[50]; Qty: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReset(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetPackage(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var LastParcelIdentifier: Code[30]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReset(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSProvSetup: Record "IDYS Setup";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        ProviderSetupLoaded: Boolean;
        MeasurementLbl: Label '%1 (%2)', Locked = true;
}