codeunit 11147703 "IDYS Cargoson API Docs. Mgt."
{
    #region [Booking]
    local procedure InitPickUpInformation(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        if DT2Date(IDYSTransportOrderHeader."Preferred Pick-up Date From") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Pick-up Date From", StrSubstNo(DateErr, Today));
        if DT2Date(IDYSTransportOrderHeader."Preferred Pick-up Date To") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Pick-up Date To", StrSubstNo(DateErr, Today));
        IDYMJSONHelper.AddValue(Document, 'collection_date', DT2Date(IDYSTransportOrderHeader."Preferred Pick-up Date From"));
        IDYMJSONHelper.AddValue(Document, 'collection_time_from', FormatTime(IDYSTransportOrderHeader."Preferred Pick-up Date From"));
        IDYMJSONHelper.AddValue(Document, 'collection_time_to', FormatTime(IDYSTransportOrderHeader."Preferred Pick-up Date To"));

        IDYMJSONHelper.AddValue(Document, 'collection_company_name', IDYSTransportOrderHeader."Name (Pick-up)");
        IDYMJSONHelper.AddValue(Document, 'collection_address_row_1', IDYSTransportOrderHeader."Address (Pick-up)");
        IDYMJSONHelper.AddValue(Document, 'collection_address_row_2', FormatAddress2(IDYSTransportOrderHeader, "IDYS Address Type"::"Pick-up"));
        IDYMJSONHelper.AddValue(Document, 'collection_postcode', IDYSTransportOrderHeader."Post Code (Pick-up)");
        IDYMJSONHelper.AddValue(Document, 'collection_city', IDYSTransportOrderHeader."City (Pick-up)");
        IDYMJSONHelper.AddValue(Document, 'collection_country', IDYSTransportOrderMgt.GetMappedCountryCode(IDYSTransportOrderHeader."Cntry/Rgn. Code (Pick-up) (TS)"));
        IDYMJSONHelper.AddValue(Document, 'collection_contact_name', IDYSTransportOrderHeader."Name (Pick-up)");
        IDYMJSONHelper.AddValue(Document, 'collection_contact_phone', IDYSTransportOrderHeader."Phone No. (Pick-up)");
        IDYMJSONHelper.AddValue(Document, 'collection_contact_email', IDYSTransportOrderHeader."E-Mail (Pick-up)");
    end;

    local procedure InitShipToInformation(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        if DT2Date(IDYSTransportOrderHeader."Preferred Delivery Date From") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Delivery Date From", StrSubstNo(DateErr, Today));
        if DT2Date(IDYSTransportOrderHeader."Preferred Delivery Date To") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Delivery Date To", StrSubstNo(DateErr, Today));
        IDYMJSONHelper.AddValue(Document, 'delivery_date', DT2Date(IDYSTransportOrderHeader."Preferred Delivery Date From"));
        IDYMJSONHelper.AddValue(Document, 'delivery_time_from', FormatTime(IDYSTransportOrderHeader."Preferred Delivery Date From"));
        IDYMJSONHelper.AddValue(Document, 'delivery_time_to', FormatTime(IDYSTransportOrderHeader."Preferred Delivery Date To"));

        IDYMJSONHelper.AddValue(Document, 'delivery_company_name', IDYSTransportOrderHeader."Name (Ship-to)");
        IDYMJSONHelper.AddValue(Document, 'delivery_address_row_1', IDYSTransportOrderHeader."Address (Ship-to)");
        IDYMJSONHelper.AddValue(Document, 'delivery_address_row_2', FormatAddress2(IDYSTransportOrderHeader, "IDYS Address Type"::"Ship-to"));
        IDYMJSONHelper.AddValue(Document, 'delivery_postcode', IDYSTransportOrderHeader."Post Code (Ship-to)");
        IDYMJSONHelper.AddValue(Document, 'delivery_city', IDYSTransportOrderHeader."City (Ship-to)");
        IDYMJSONHelper.AddValue(Document, 'delivery_country', IDYSTransportOrderMgt.GetMappedCountryCode(IDYSTransportOrderHeader."Cntry/Rgn. Code (Ship-to) (TS)"));
        IDYMJSONHelper.AddValue(Document, 'delivery_contact_name', IDYSTransportOrderHeader."Name (Ship-to)");
        IDYMJSONHelper.AddValue(Document, 'delivery_contact_phone', IDYSTransportOrderHeader."Phone No. (Ship-to)");
        IDYMJSONHelper.AddValue(Document, 'delivery_contact_email', IDYSTransportOrderHeader."E-Mail (Ship-to)");
    end;

    local procedure InitInvoiceInformation(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        if not IDYSTransportOrderHeader."Include Invoice Address" then
            exit;

        IDYMJSONHelper.AddValue(Document, 'freight_payer_company_name', IDYSTransportOrderHeader."Name (Invoice)");
        IDYMJSONHelper.AddValue(Document, 'freight_payer_address_row_1', IDYSTransportOrderHeader."Address (Invoice)");
        IDYMJSONHelper.AddValue(Document, 'freight_payer_address_row_2', FormatAddress2(IDYSTransportOrderHeader, "IDYS Address Type"::Invoice));
        IDYMJSONHelper.AddValue(Document, 'freight_payer_postcode', IDYSTransportOrderHeader."Post Code (Invoice)");
        IDYMJSONHelper.AddValue(Document, 'freight_payer_city', IDYSTransportOrderHeader."City (Invoice)");
        IDYMJSONHelper.AddValue(Document, 'freight_payer_country', IDYSTransportOrderMgt.GetMappedCountryCode(IDYSTransportOrderHeader."Cntry/Rgn. Code (Invoice) (TS)"));
        IDYMJSONHelper.AddValue(Document, 'freight_payer_contact_name', IDYSTransportOrderHeader."Name (Invoice)");
        IDYMJSONHelper.AddValue(Document, 'freight_payer_contact_phone', IDYSTransportOrderHeader."Phone No. (Invoice)");
        IDYMJSONHelper.AddValue(Document, 'freight_payer_contact_email', IDYSTransportOrderHeader."E-Mail (Invoice)");
        IDYMJSONHelper.AddValue(Document, 'freight_payer_code', IDYSTransportOrderHeader."Account No. (Invoice)");
    end;

    local procedure FormatAddress2(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; IDYSAddressType: Enum "IDYS Address Type"): Text
    var
        Address2: Text[100];
        County: Text[30];
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    Address2 := IDYSTransportOrderHeader."Address 2 (Pick-up)";
                    County := IDYSTransportOrderHeader."County (Pick-up)";
                end;
            IDYSAddressType::"Ship-to":
                begin
                    Address2 := IDYSTransportOrderHeader."Address 2 (Ship-to)";
                    County := IDYSTransportOrderHeader."County (Ship-to)";
                end;
            IDYSAddressType::Invoice:
                begin
                    Address2 := IDYSTransportOrderHeader."Address 2 (Invoice)";
                    County := IDYSTransportOrderHeader."County (Invoice)";
                end;
        end;

        if (County = '') or LowerCase(Address2).Contains(LowerCase(DelChr(County, '<>'))) then
            exit(Address2);
        exit(Address2 + ', ' + County);
    end;

    local procedure InitDocumentFromIDYSTransportOrderHeader(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        IDYSIncoterm: Record "IDYS Incoterm";
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        Options: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitDocumentFromIDYSTransportOrderHeader(Document, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        IDYMJSONHelper.AddValue(Document, 'customer_reference', IDYSTransportOrderHeader."No.");

        // Collection details
        InitPickUpInformation(Document, IDYSTransportOrderHeader);

        // Delivery details
        InitShipToInformation(Document, IDYSTransportOrderHeader);

        // Invoice details
        InitInvoiceInformation(Document, IDYSTransportOrderHeader);

        if IDYSIncoterm.Get(IDYSTransportOrderHeader."Incoterms Code") then
            IDYMJSONHelper.AddValue(Document, 'incoterms', IDYSIncoterm."Code");
        if IDYSTransportOrderHeader."Shipmt. Value" <> 0 then
            IDYMJSONHelper.AddValue(Document, 'goods_value', IDYSTransportOrderHeader."Shipmt. Value")
        else begin
            IDYSTransportOrderHeader.CalcFields("Calculated Shipment Value");
            IDYMJSONHelper.AddValue(Document, 'goods_value', IDYSTransportOrderHeader."Calculated Shipment Value");
        end;
        if IDYSTransportOrderHeader."Shipmt. Value Curr Code (TS)" <> '' then
            IDYMJSONHelper.AddValue(Document, 'goods_value_currency', IDYSTransportOrderHeader."Shipmt. Value Curr Code (TS)");

        IDYMJSONHelper.AddValue(Options, 'label_format', "IDYS Cargoson Label Format".Names().Get("IDYS Cargoson Label Format".Ordinals().IndexOf(IDYSTransportOrderHeader."Label Format".AsInteger())));
        IDYMJSONHelper.AddValue(Options, 'create_incomplete_shipment', false);

        // Not specified service_id would create incomplete shipment on the portal
        IDYSShipAgentSvcMapping.Get(IDYSTransportOrderHeader."Shipping Agent Code", IDYSTransportOrderHeader."Shipping Agent Service Code");
        IDYSProviderBookingProfile.Get(IDYSShipAgentSvcMapping."Booking Profile Entry No.", IDYSShipAgentSvcMapping."Carrier Entry No.");
        IDYMJSONHelper.AddValue(Options, 'direct_booking_service_id', IDYSProviderBookingProfile.ServiceId);
        IDYMJSONHelper.Add(Document, 'options', Options);

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitDocumentFromIDYSTransportOrderHeader(Document, IDYSTransportOrderHeader);
    end;

    local procedure InitPackagesFromTransportOrderPackages(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        Packages: JsonArray;
        Package: JsonObject;
        Weight: Decimal;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitPackagesFromTransportOrderPackages(Document, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if TransportOrderPackage.FindSet(true) then begin
            repeat
                Clear(Package);
                IDYMJSONHelper.AddValue(Package, 'quantity', 1);
                IDYMJSONHelper.AddValue(Package, 'package_type', TransportOrderPackage."Provider Package Type Code");

                Weight := TransportOrderPackage.GetPackageWeight();
                IDYMJSONHelper.AddValue(Package, 'weight', Weight);

                if TransportOrderPackage.Height <> 0 then
                    IDYMJSONHelper.AddValue(Package, 'height', TransportOrderPackage.Height);
                if TransportOrderPackage.Length <> 0 then
                    IDYMJSONHelper.AddValue(Package, 'length', TransportOrderPackage.Length);
                if TransportOrderPackage.Width <> 0 then
                    IDYMJSONHelper.AddValue(Package, 'width', TransportOrderPackage.Width);
                IDYMJSONHelper.AddValue(Package, 'description', TransportOrderPackage.Description);

                IDYMJSONHelper.Add(Packages, Package);
            until TransportOrderPackage.Next() = 0;
            IDYMJSONHelper.Add(Document, 'rows_attributes', Packages);
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitPackagesFromTransportOrderPackages(Document, IDYSTransportOrderHeader);
    end;

    local procedure InitDeliveryNotesFromTransportOrderDeliveryNotes(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        DeclarationItemAttributes: JsonArray;
        DeclarationItemAttribute: JsonObject;
        DeclarationAttribute: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitDeliveryNotesFromTransportOrderDeliveryNotes(Document, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        IDYSTransportOrderDelNote.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderDelNote.FindSet() then begin
            IDYMJSONHelper.AddValue(DeclarationAttribute, 'currency', IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)");
            repeat
                Clear(DeclarationItemAttribute);
                IDYMJSONHelper.AddValue(DeclarationItemAttribute, 'quantity', IDYSTransportOrderDelNote.Quantity);
                IDYMJSONHelper.AddValue(DeclarationItemAttribute, 'description', IDYSTransportOrderDelNote.Description);
                IDYMJSONHelper.AddValue(DeclarationItemAttribute, 'hs_code', IDYSTransportOrderDelNote."HS Code");
                IDYMJSONHelper.AddValue(DeclarationItemAttribute, 'unit_of_measure', 'KG');  // Default UOM
                IDYMJSONHelper.AddValue(DeclarationItemAttribute, 'origin_country', IDYSTransportOrderDelNote."Country of Origin");
                IDYMJSONHelper.AddValue(DeclarationItemAttribute, 'net_weight', Round(IDYSTransportOrderDelNote."Net Weight" * IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No."), IDYSProviderMgt.GetRoundingPrecision("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.")));
                IDYMJSONHelper.AddValue(DeclarationItemAttribute, 'gross_weight', Round(IDYSTransportOrderDelNote."Gross Weight" * IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No."), IDYSProviderMgt.GetRoundingPrecision("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.")));
                IDYMJSONHelper.AddValue(DeclarationItemAttribute, 'value', IDYSTransportOrderDelNote.Price);

                IDYMJSONHelper.Add(DeclarationItemAttributes, DeclarationItemAttribute);
            until IDYSTransportOrderDelNote.Next() = 0;
            IDYMJSONHelper.Add(DeclarationAttribute, 'declaration_items_attributes', DeclarationItemAttributes);
            IDYMJSONHelper.Add(Document, 'declaration_attributes', DeclarationAttribute);
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitDeliveryNotesFromTransportOrderDeliveryNotes(Document, IDYSTransportOrderHeader);
    end;

    local procedure PostDocument(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Document: JsonObject; AllowLogging: Boolean): JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        EndpointTxt: Label 'queries', Locked = true;
    begin
        GetSetup();

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
        TempIDYMRESTParameters.Path := EndpointTxt;
        TempIDYMRESTParameters."Acceptance Environment" := IDYSCargosonSetup."Transsmart Environment" = IDYSCargosonSetup."Transsmart Environment"::Acceptance;
        TempIDYMRESTParameters.SetRequestContent(Document);

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Cargoson, "IDYM Endpoint Usage"::Default);

        PostDocumentSucceeeded := TempIDYMRESTParameters."Status Code" = 201;
        if not PostDocumentSucceeeded then begin
            if AllowLogging then begin
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", ErrorBookingTxt, LoggingLevel::Error, Document, TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
                Commit();
            end;
            CargosonErrorHandler.Parse(TempIDYMRESTParameters, GuiAllowed());
            Error('');
        end;

        exit(TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
    end;

    local procedure PatchDocument(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Document: JsonObject; AllowLogging: Boolean): JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        EndpointTxt: Label 'bookings/%1', Locked = true;
        ReturnToken: JsonToken;
    begin
        GetSetup();

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::PATCH;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, IDYSTransportOrderHeader."Booking Reference");
        TempIDYMRESTParameters."Acceptance Environment" := IDYSCargosonSetup."Transsmart Environment" = IDYSCargosonSetup."Transsmart Environment"::Acceptance;
        TempIDYMRESTParameters.SetRequestContent(Document);

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Cargoson, "IDYM Endpoint Usage"::Default);

        PostDocumentSucceeeded := TempIDYMRESTParameters."Status Code" = 200;
        if not PostDocumentSucceeeded then begin
            if AllowLogging then begin
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", ErrorBookingTxt, LoggingLevel::Error, Document, TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
                Commit();
            end;
            CargosonErrorHandler.Parse(TempIDYMRESTParameters, GuiAllowed());
            Error('');
        end;

        TempIDYMRESTParameters.GetResponseBodyAsJSON().SelectToken('$.object', ReturnToken);
        exit(ReturnToken.AsObject());
    end;

    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; AllowLogging: Boolean): Boolean
    var
        Booked: Boolean;
        ResponseDocument: JsonObject;
        RequestDocument: JsonObject;
    begin
        Booked := CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging);
        if not Booked then
            exit(false);
        exit(HandleResponseAfterBooking(IDYSTransportOrderHeader, RequestDocument, ResponseDocument));
    end;

    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean) ReturnValue: Boolean
    var
        IDYMAppLicenseKey: Record "IDYM App License Key";
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        LicenseCheck: Codeunit "IDYS License Check";
        ErrorMessage: Text;
        IsHandled: Boolean;
    begin
        GetSetup();
        ValidateTransportOrder(IDYSTransportOrderHeader);

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeCreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        InitDocumentFromIDYSTransportOrderHeader(RequestDocument, IDYSTransportOrderHeader);
        InitPackagesFromTransportOrderPackages(RequestDocument, IDYSTransportOrderHeader);
        if IDYSTransportOrderHeader."Ship Outside EU" then
            InitDeliveryNotesFromTransportOrderDeliveryNotes(RequestDocument, IDYSTransportOrderHeader);

        //Pre-POST check if using ShipIT is allowed
        LicenseCheck.SetPostponeWriteTransactions();
        if not LicenseCheck.CheckLicense(IDYSSetup."License Entry No.", ErrorMessage, HttpStatusCode) then
            exit;

        if ApplicationAreaMgmtFacade.GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup, CompanyName()) then
            if ApplicationAreaSetup."IDYS Package Content" then begin
                IDYMAppLicenseKey.Get(IDYSSetup."License Entry No.");
                if not LicenseCheck.CheckLicenseProperty(IDYMAppLicenseKey."Entry No.", 'applicationarea', 'IDYS_PackageContent', GuiAllowed(), ErrorMessage, HttpStatusCode) then
                    exit;
            end;

        if AllowLogging and IDYSSetup."Enable Debug Mode" then begin
            IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", BookingTxt, LoggingLevel::Information, RequestDocument);
            Commit();
        end;

        // POST/PATCH the document
        if IDYSTransportOrderHeader."Booking Reference" <> '' then
            ResponseDocument := PatchDocument(IDYSTransportOrderHeader, RequestDocument, AllowLogging)
        else
            ResponseDocument := PostDocument(IDYSTransportOrderHeader, RequestDocument, AllowLogging);

        if PostDocumentSucceeeded then begin
            //Set status to booked so that TO status is correct even when processing the response fails
            IDYSTransportOrderHeader.Status := IDYSTransportOrderHeader.Status::Booked;
            IDYSTransportOrderHeader.Modify();
        end;
        if AllowLogging then
            if IDYSSetup."Enable Debug Mode" then
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", UploadedTxt, LoggingLevel::Information, RequestDocument, ResponseDocument)
            else
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", UploadedTxt, LoggingLevel::Information);
        if PostDocumentSucceeeded or AllowLogging then
            Commit();

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterCreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging);

        exit(true);
    end;

    procedure HandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject) ReturnValue: Boolean
    var
        ShipmentMethodMapping: Record "IDYS Shipment Method Mapping";
        IncotermsCode: Code[50];
        Document: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterBooking(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        // Update Header
        IDYSTransportOrderHeader.Validate("Booking Reference", CopyStr(IDYMJsonHelper.GetTextValue(ResponseDocument, 'reference'), 1, MaxStrLen(IDYSTransportOrderHeader."Booking Reference")));
        IDYSTransportOrderHeader.Validate("Booking Id", IDYMJsonHelper.GetIntegerValue(ResponseDocument, 'id'));

        IDYSTransportOrderHeader.Validate("Tracking No.", CopyStr(IDYMJsonHelper.GetTextValue(ResponseDocument, 'tracking_reference'), 1, MaxStrLen(IDYSTransportOrderHeader."Tracking No.")));
        IDYSTransportOrderHeader.Validate("Tracking Url", CopyStr(IDYMJsonHelper.GetTextValue(ResponseDocument, 'tracking_url'), 1, MaxStrLen(IDYSTransportOrderHeader."Tracking Url")));

        IDYSTransportOrderHeader.Validate("Label Url", CopyStr(IDYMJsonHelper.GetTextValue(ResponseDocument, 'label_url'), 1, MaxStrLen(IDYSTransportOrderHeader."Label Url")));
        IDYSTransportOrderHeader.Validate("CMR Url", CopyStr(IDYMJsonHelper.GetTextValue(ResponseDocument, 'cmr_url'), 1, MaxStrLen(IDYSTransportOrderHeader."CMR Url")));
        IDYSTransportOrderHeader.Validate("Waybill Url", CopyStr(IDYMJsonHelper.GetTextValue(ResponseDocument, 'waybill_url'), 1, MaxStrLen(IDYSTransportOrderHeader."Waybill Url")));
        IDYSTransportOrderHeader.Validate("Status (External)", CopyStr(IDYMJsonHelper.GetTextValue(ResponseDocument, 'booking_status'), 1, MaxStrLen(IDYSTransportOrderHeader."Status (External)")));

        IncotermsCode := CopyStr(IDYMJsonHelper.GetTextValue(ResponseDocument, 'incoterm_code'), 1, MaxStrLen(IncotermsCode));
        if IncotermsCode <> IDYSTransportOrderHeader."Shipment Method Code" then begin
            ShipmentMethodMapping.SetRange("Incoterms Code", IncotermsCode);
            if ShipmentMethodMapping.FindLast() then
                IDYSTransportOrderHeader.Validate("Shipment Method Code", ShipmentMethodMapping."Shipment Method Code");
        end;

        UpdateStatus(IDYSTransportOrderHeader);
        IDYSTransportOrderHeader.Modify(true);
        // Save changes in case of an error in Synchronize / PrintIT
        Commit();

        // Sleep ensures a time gap for shipment status updates in the API's asynchronous flow
        Sleep(1000);

        Document := Synchronize(IDYSTransportOrderHeader, false, false);
        exit(true);
    end;
    #endregion

    #region [GetStatus]
    procedure Synchronize(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean) ResponseDocument: JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        CarrierResponseMsgErr: Label 'Shipment error from the carrier: %1.', comment = '%1 = error message';
        CarrierResponseMsgTok: Label '06961461-a26a-44ad-bf38-8593fdae7540', Locked = true;
        EndpointTxt: Label 'bookings/%1', comment = '%1 = reference', Locked = true;
        FileName: Text;
        FullFileName: Text;
        RequestDocument: JsonObject;
        Options: JsonObject;
        IsHandled: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeSynchronize(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry, ResponseDocument, IsHandled);
            if IsHandled then
                exit(ResponseDocument);
        end;

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, IDYSTransportOrderHeader."Booking Reference");
        TempIDYMRESTParameters."Acceptance Environment" := IDYSCargosonSetup."Transsmart Environment" = IDYSCargosonSetup."Transsmart Environment"::Acceptance;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)  
        // Sync. Options
        // NOTE: The "include_associations" tag can be used to retrieve more details about the shipment.
        IDYMJSONHelper.AddValue(Options, 'label_format', "IDYS Cargoson Label Format".Names().Get("IDYS Cargoson Label Format".Ordinals().IndexOf(IDYSTransportOrderHeader."Label Format".AsInteger())));
        IDYMJsonHelper.Add(RequestDocument, 'options', Options);

        TempIDYMRESTParameters.SetRequestContent(RequestDocument);
#endif

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Cargoson, "IDYM Endpoint Usage"::Default);

        if TempIDYMRESTParameters."Status Code" <> 200 then begin
            if WriteLogEntry and TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject() then begin
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", ErrorSynchronizeTxt, LoggingLevel::Information, RequestDocument, TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
                Commit();
            end;
            CargosonErrorHandler.Parse(TempIDYMRESTParameters, false);
        end;

        ResponseDocument := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();

        if WriteLogEntry then begin
            if IDYSSetup."Enable Debug Mode" then
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", SynchronizeTxt, LoggingLevel::Information, RequestDocument, ResponseDocument)
            else
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", SynchronizeTxt, LoggingLevel::Information);
            Commit();
        end;

        IDYSTransportOrderHeader.Validate("Status (External)", CopyStr(IDYMJSONHelper.GetTextValue(ResponseDocument, 'latest_status'), 1, MaxStrLen(IDYSTransportOrderHeader."Status (External)")));
        IDYSTransportOrderHeader.Validate("Shipment Error", CopyStr(IDYMJSONHelper.GetTextValue(ResponseDocument, 'carrier_response_message'), 1, MaxStrLen(IDYSTransportOrderHeader."Shipment Error")));

        IDYSTransportOrderHeader.Validate("Tracking No.", CopyStr(IDYMJSONHelper.GetTextValue(ResponseDocument, 'tracking_reference'), 1, MaxStrLen(IDYSTransportOrderHeader."Tracking No.")));
        IDYSTransportOrderHeader.Validate("Tracking Url", CopyStr(IDYMJSONHelper.GetTextValue(ResponseDocument, 'tracking_url'), 1, MaxStrLen(IDYSTransportOrderHeader."Tracking Url")));

        IDYSTransportOrderHeader.Validate("Label Url", CopyStr(IDYMJSONHelper.GetTextValue(ResponseDocument, 'label_url'), 1, MaxStrLen(IDYSTransportOrderHeader."Label Url")));
        IDYSTransportOrderHeader.Validate("CMR Url", CopyStr(IDYMJSONHelper.GetTextValue(ResponseDocument, 'cmr_url'), 1, MaxStrLen(IDYSTransportOrderHeader."CMR Url")));
        IDYSTransportOrderHeader.Validate("Waybill Url", CopyStr(IDYMJSONHelper.GetTextValue(ResponseDocument, 'waybill_url'), 1, MaxStrLen(IDYSTransportOrderHeader."Waybill Url")));
        UpdateStatus(IDYSTransportOrderHeader);
        IDYSTransportOrderHeader.Modify();

        // Get files
        if IDYSTransportOrderHeader."Label Url" <> '' then begin
            FullFileName := GetFileName(IDYSTransportOrderHeader, 'Labels', FileName);
            if not IsDuplicate(IDYSTransportOrderHeader, FileName) then
                SaveFileToAttachments(IDYSTransportOrderHeader, IDYSTransportOrderHeader."Label Url", FullFileName, true);
        end;
        if IDYSTransportOrderHeader."CMR Url" <> '' then begin
            FullFileName := GetFileName(IDYSTransportOrderHeader, 'CMR', FileName);
            if not IsDuplicate(IDYSTransportOrderHeader, FileName) then
                SaveFileToAttachments(IDYSTransportOrderHeader, IDYSTransportOrderHeader."CMR Url", FullFileName, false);
        end;
        if IDYSTransportOrderHeader."Waybill Url" <> '' then begin
            FullFileName := GetFileName(IDYSTransportOrderHeader, 'Waybill', FileName);
            if not IsDuplicate(IDYSTransportOrderHeader, FileName) then
                SaveFileToAttachments(IDYSTransportOrderHeader, IDYSTransportOrderHeader."Waybill Url", FullFileName, false);
        end;

        if WriteLogEntry then
            IDYSTransportOrderHeader.CreateLogEntry(UpdatedTxt, LoggingLevel::Information);

        if IDYSTransportOrderHeader."Booked with Error" and GuiAllowed() then
            IDYSNotificationManagement.SendNotification(CarrierResponseMsgTok, StrSubstNo(CarrierResponseMsgErr, IDYSTransportOrderHeader."Shipment Error"));
    end;

    local procedure IsDuplicate(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; FileName: Text): Boolean
    var
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
    begin
        exit(DocumentAttachmentMgmt.IsDuplicateFile(Database::"IDYS Transport Order Header", IDYSTransportOrderHeader."No.", "Attachment Document Type"::Quote, 0, FileName, 'pdf'));
    end;

    local procedure GetFileName(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; CurrFileName: Text; var FileName: Text): Text
    var
        FileNameLbl: Label '%1.pdf', Locked = true;
    begin
        FileName := IDYSTransportOrderMgt.GetRecordIdText(IDYSTransportOrderHeader.RecordId) + '_' + CurrFileName;
        exit(StrSubstNo(FileNameLbl, FileName));
    end;

    local procedure SaveFileToAttachments(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; FileUrl: Text; var FileName: Text; IsCargosonLabel: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        SourceRecordRef: RecordRef;
        ContentOutStream: OutStream;
        ContentInStream: InStream;
    begin
        if HttpClient.Get(FileUrl, HttpResponseMessage) then
            if HttpResponseMessage.IsSuccessStatusCode() and (HttpResponseMessage.Content().ReadAs(ContentInStream)) then begin
                Clear(TempBlob);
                TempBlob.CreateOutStream(ContentOutStream);
                CopyStream(ContentOutStream, ContentInStream);
                SourceRecordRef.GetTable(IDYSTransportOrderHeader);
                IDYSTransportOrderMgt.SaveDocumentAttachmentFromRecRef(SourceRecordRef, TempBlob, FileName, 'pdf', IsCargosonLabel);
            end;
    end;

    procedure UpdateStatus(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IsHandled: Boolean;
    begin
        OnBeforeUpdateStatus(TransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        Clear(TransportOrderHeader."Booked with Error");

        case TransportOrderHeader."Status (External)" of
            '':
                TransportOrderHeader.Status := TransportOrderHeader.Status::New;
            'created', 'processing':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Uploaded;
            'booked', 'confirmed':
                if not (TransportOrderHeader.Status in [TransportOrderHeader.Status::"Label Printed"]) then
                    TransportOrderHeader.Status := TransportOrderHeader.Status::Booked;
            'delivered', 'completed':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Done;
            'rejected':
                begin
                    TransportOrderHeader."Booked with Error" := true;
                    TransportOrderHeader.Status := TransportOrderHeader.Status::Uploaded;
                end;
            'withdrawn':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Recalled;
        end;

        TransportOrderHeader.Validate(Status);
        OnAfterUpdateStatus(TransportOrderHeader);
    end;
    #endregion

    #region [Carrier Selection]
    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary) ReturnValue: JsonArray;
    var
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        TotalLinkedWeight: Decimal;
        CompletelyShippedErr: Label 'Order is completely shipped already.';
        Document: JsonObject;
        Documents: JsonArray;
        Package: JsonObject;
        Packages: JsonArray;
        IsHandled: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitSelectCarrierFromTemp(TempIDYSTransportOrderHeader, SalesHeader, IDYSProviderCarrierSelect, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        if SalesHeader."Completely Shipped" then
            Error(CompletelyShippedErr);
        TempIDYSTransportOrderHeader.Provider := SalesHeader."IDYS Provider";

        IDYSDocumentMgt.SalesHeader_CreateTempTransportOrder(SalesHeader, TempIDYSTransportOrderHeader);

        IDYSProviderCarrierSelect.SetRange("Transport Order No.", TempIDYSTransportOrderHeader."No.");
        IDYSProviderCarrierSelect.DeleteAll();

        IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        IDYSSourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        IDYSSourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
        if IDYSSourceDocumentPackage.IsEmpty() then
            exit;

        // Collection details
        InitPickUpInformation(Document, TempIDYSTransportOrderHeader);

        // Delivery details
        InitShipToInformation(Document, TempIDYSTransportOrderHeader);

        if IDYSSetup."Link Del. Lines with Packages" then
            TotalLinkedWeight := Round(IDYSDocumentMgt.GetCalculatedWeight(SalesHeader), 0.01);  // assigned to the first package
        if IDYSSourceDocumentPackage.FindSet() then begin
            repeat
                Clear(Package);
                IDYMJSONHelper.AddValue(Package, 'quantity', 1);
                IDYMJSONHelper.AddValue(Package, 'package_type', IDYSSourceDocumentPackage."Provider Package Type Code");
                IDYMJSONHelper.AddValue(Package, 'weight', IDYSSourceDocumentPackage.Weight + TotalLinkedWeight);
                if IDYSSourceDocumentPackage.Height <> 0 then
                    IDYMJSONHelper.AddValue(Package, 'height', IDYSSourceDocumentPackage.Height);
                if IDYSSourceDocumentPackage.Length <> 0 then
                    IDYMJSONHelper.AddValue(Package, 'length', IDYSSourceDocumentPackage.Length);
                if IDYSSourceDocumentPackage.Width <> 0 then
                    IDYMJSONHelper.AddValue(Package, 'width', IDYSSourceDocumentPackage.Width);
                IDYMJSONHelper.AddValue(Package, 'description', IDYSSourceDocumentPackage.Description);
                Packages.Add(Package);

                TotalLinkedWeight := 0;
            until IDYSSourceDocumentPackage.Next() = 0;
            IDYMJSONHelper.Add(Document, 'rows_attributes', Packages);
        end else
            Error(MissingPackagesErr);

        IDYMJSONHelper.AddValue(Document, 'request_external_partners', true);

        Documents.Add(Document);
        exit(Documents);
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary) ReturnValue: JsonArray;
    var
        Document: JsonObject;
        Documents: JsonArray;
        IsHandled: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        if not (IDYSTransportOrderHeader.Status in [
            IDYSTransportOrderHeader.Status::New,
            IDYSTransportOrderHeader.Status::Recalled])
        then
            IDYSTransportOrderHeader.FieldError(Status);

        IDYSProviderCarrierSelect.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSProviderCarrierSelect.DeleteAll();

        // Collection details
        InitPickUpInformation(Document, IDYSTransportOrderHeader);

        // Delivery details
        InitShipToInformation(Document, IDYSTransportOrderHeader);

        InitPackagesFromTransportOrderPackages(Document, IDYSTransportOrderHeader);
        IDYMJSONHelper.AddValue(Document, 'request_external_partners', true);

        Documents.Add(Document);
        exit(Documents);
    end;

    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray);
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        IDYMDataHelper: Codeunit "IDYM Data Helper";
        CurrencyCode: Code[10];
        Document: JsonToken;
        ResponseToken: JsonToken;
        ResponseObject: JsonObject;
        Prices: JsonArray;
        Price: JsonToken;
        Surcharges: JsonArray;
        Surcharge: JsonToken;
        DateAsText: Text;
        CarrierSelectLineNo: Integer;
        IsHandled: Boolean;
        EndpointTxt: Label 'freightPrices/list', Locked = true;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents, IsHandled);
            if IsHandled then
                exit;
        end;

        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSProvCarrierSelectPck.DeleteAll();

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
        TempIDYMRESTParameters.Path := EndpointTxt;
        TempIDYMRESTParameters."Acceptance Environment" := IDYSCargosonSetup."Transsmart Environment" = IDYSCargosonSetup."Transsmart Environment"::Acceptance;

        Documents.Get(0, Document);
        TempIDYMRESTParameters.SetRequestContent(Document.AsObject());

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Cargoson, "IDYM Endpoint Usage"::Default);
        if TempIDYMRESTParameters."Status Code" <> 200 then begin
            CargosonErrorHandler.Parse(TempIDYMRESTParameters, GuiAllowed());
            Error('');
        end;

        ResponseObject := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();

        Clear(CarrierSelectLineNo);
        if ResponseObject.SelectToken('$.object.prices', ResponseToken) then begin
            Prices := ResponseToken.AsArray();
            foreach Price in Prices do begin
                CarrierSelectLineNo += 1;

                IDYSProviderCarrierSelect.Init();
                IDYSProviderCarrierSelect."Transport Order No." := IDYSTransportOrderHeader."No.";
                IDYSProviderCarrierSelect."Line No." := CarrierSelectLineNo;

                IDYSProviderCarrier.SetRange(CarrierId, IDYMJSONHelper.GetIntegerValue(Price, 'id'));
                if IDYSProviderCarrier.FindFirst() then
                    IDYSProviderCarrierSelect."Carrier Entry No." := IDYSProviderCarrier."Entry No.";

                IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrierSelect."Carrier Entry No.");
                IDYSProviderBookingProfile.SetRange(ServiceId, IDYMJSONHelper.GetIntegerValue(Price, 'service_id'));
                if IDYSProviderBookingProfile.FindFirst() then
                    IDYSProviderCarrierSelect."Booking Profile Entry No." := IDYSProviderBookingProfile."Entry No.";

                IDYSProviderCarrierSelect."Carrier Name" := CopyStr(IDYMJSONHelper.GetTextValue(Price, 'carrier'), 1, MaxStrLen(IDYSProviderCarrierSelect."Carrier Name"));
                IDYSProviderCarrierSelect.Description := CopyStr(IDYMJSONHelper.GetTextValue(Price, 'service'), 1, MaxStrLen(IDYSProviderCarrierSelect.Description));
                IDYSProviderCarrierSelect."Price as Decimal" := IDYMJSONHelper.GetDecimalValue(Price, 'price');

                DateAsText := IDYMJSONHelper.GetTextValue(Price, 'estimated_collection_date');
                if DateAsText <> '' then
                    IDYSProviderCarrierSelect."Pickup Date" := IDYMDataHelper.TextToDate(DateAsText);
                DateAsText := IDYMJSONHelper.GetTextValue(Price, 'estimated_delivery_date');
                if DateAsText <> '' then
                    IDYSProviderCarrierSelect."Delivery Date" := IDYMDataHelper.TextToDate(DateAsText);
                IDYSProviderCarrierSelect."Transit Time (Days)" := CopyStr(IDYMJSONHelper.GetTextValue(Price, 'transit_time'), 1, MaxStrLen(IDYSProviderCarrierSelect."Transit Time (Days)"));

                // Surcharges
                CurrencyCode := CopyStr(IDYMJSONHelper.GetTextValue(Price, 'currency'), 1, MaxStrLen(CurrencyCode));
                if Price.AsObject().Contains('surcharges') then begin
                    Surcharges := IDYMJSONHelper.GetArray(Price, 'surcharges');
                    foreach Surcharge in Surcharges do begin
                        IDYSProvCarrierSelectPck.Init();
                        IDYSProvCarrierSelectPck."Transport Order No." := IDYSTransportOrderHeader."No.";
                        IDYSProvCarrierSelectPck."Line No." := IDYSProviderCarrierSelect."Line No.";

                        IDYSProvCarrierSelectPck."Charge Name" := CopyStr(IDYMJSONHelper.GetTextValue(Surcharge, 'identifier'), 1, MaxStrLen(IDYSProvCarrierSelectPck."Charge Name"));
                        IDYSProvCarrierSelectPck."Charge Amount" := CurrencyExchangeRate.ExchangeAmount(IDYMJSONHelper.GetDecimalValue(Surcharge, 'amount'), CurrencyCode, CurrencyCode, WorkDate());
                        IDYSProvCarrierSelectPck.Surcharges := true;
                        IDYSProvCarrierSelectPck.Insert(true);
                    end;
                end;

                if IDYSSessionVariables.CheckAuthorization() then
                    OnSelectCarrierOnProviderCarrierSelectInsert(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Price);
                IDYSProviderCarrierSelect.Insert(true);
            end;
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents);
    end;
    #endregion

    #region [Printing]
    procedure DoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") Printed: Boolean
    var
        Response: JsonToken;
    begin
        GetSetup();

        Printed := TryDoLabel(IDYSTransportOrderHeader, Response);
        if Printed then
            HandleResponseAfterPrinting(IDYSTransportOrderHeader, Response);
    end;

    procedure TryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Response: JsonToken) Printed: Boolean
    var
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeTryDoLabel(IDYSTransportOrderHeader, Printed, IsHandled);
            if IsHandled then
                exit(Printed);
        end;

        if not IDYSProviderMgt.IsPrintITEnabled(IDYSTransportOrderHeader.Provider) then
            exit(false);
        Printed := IDYSProviderMgt.PrintLabelFromDocumentAttachment(IDYSTransportOrderHeader);
    end;

    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    var
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterPrinting(Response, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;
        IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::"Label Printed");
        IDYSTransportOrderHeader.Modify();
        IDYSTransportOrderHeader.CreateLogEntry(LabelPrintedTxt, LoggingLevel::Information);
    end;
    #endregion

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        ShipmentValueMandatoryErr: Label 'Providing a shipment value is mandatory, but the shipment value couldn''t be calculated. Please register a shipment value manually.';
        IsHandled: Boolean;
    begin
        OnBeforeValidateTransportOrder(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSTransportOrderPackage.SetRange(Description, '');
        if IDYSTransportOrderPackage.FindFirst() then
            IDYSTransportOrderPackage.FieldError(Description);

        if not (IDYSTransportOrderHeader.Status in [IDYSTransportOrderHeader.Status::New, IDYSTransportOrderHeader.Status::Uploaded]) then
            IDYSTransportOrderHeader.FieldError(Status);
        IDYSTransportOrderHeader.TestField("Preferred Pick-up Date From");
        IDYSTransportOrderHeader.TestField("Preferred Pick-up Date To");
        IDYSTransportOrderHeader.TestField("Preferred Delivery Date From");
        IDYSTransportOrderHeader.TestField("Preferred Delivery Date To");

        IDYSTransportOrderHeader.TestField("Shipment Method Code");

        if DT2Date(IDYSTransportOrderHeader."Preferred Pick-up Date From") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Pick-up Date From", StrSubstNo(DateErr, Today));
        if DT2Date(IDYSTransportOrderHeader."Preferred Pick-up Date To") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Pick-up Date To", StrSubstNo(DateErr, Today));

        IDYSTransportOrderHeader.TestField("Name (Pick-up)");
        IDYSTransportOrderHeader.TestField("Address (Pick-up)");
        IDYSTransportOrderHeader.TestField("Post Code (Pick-up)");
        IDYSTransportOrderHeader.TestField("City (Pick-up)");

        IDYSTransportOrderHeader.TestField("Name (Ship-to)");
        IDYSTransportOrderHeader.TestField("Address (Ship-to)");
        IDYSTransportOrderHeader.TestField("Post Code (Ship-to)");
        IDYSTransportOrderHeader.TestField("City (Ship-to)");

        IDYSTransportOrderHeader.TestField("Name (Invoice)");
        IDYSTransportOrderHeader.TestField("Address (Invoice)");
        IDYSTransportOrderHeader.TestField("Post Code (Invoice)");
        IDYSTransportOrderHeader.TestField("City (Invoice)");

        IDYSTransportOrderHeader.CalcFields("Calculated Shipment Value");
        if (IDYSTransportOrderHeader."Shipmt. Value" = 0) and
           (IDYSTransportOrderHeader."Calculated Shipment Value" = 0)
        then
            IDYSTransportOrderHeader.FieldError("Shipmt. Value", ShipmentValueMandatoryErr);

        IDYSProviderMgt.CheckTransportOrder(IDYSTransportOrderHeader);
        OnAfterValidateTransportOrder(IDYSTransportOrderHeader);
    end;

    local procedure GetSetup(): Boolean
    begin
        if not SetupLoaded then
            SetupLoaded := IDYSSetup.Get();

        if not ProviderSetupLoaded then begin
            IDYSCargosonSetup.GetProviderSetup("IDYS Provider"::Cargoson);
            ProviderSetupLoaded := true;
        end;

        exit(SetupLoaded and ProviderSetupLoaded);
    end;

    local procedure FormatTime(input: DateTime): Text;
    begin
        exit(Format(input, 0, '<Hours24,2>:<Minutes,2>'));
    end;

    procedure OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    var
        CargosonProdDashboardUrlTxt: Label 'https://cargoson.com/en/queries/%1', Comment = '%1=booking id', Locked = true;
        CargosonAccDashboardUrlTxt: Label 'https://cargoson-staging.herokuapp.com/en/queries/%1', Comment = '%1=booking id', Locked = true;
    begin
        IDYSCargosonSetup.GetProviderSetup("IDYS Provider"::Cargoson);
        if IDYSCargosonSetup."Transsmart Environment" = IDYSCargosonSetup."Transsmart Environment"::Production then
            Hyperlink(StrSubstNo(CargosonProdDashboardUrlTxt, TransportOrderHeader."Booking Id"))
        else
            Hyperlink(StrSubstNo(CargosonAccDashboardUrlTxt, TransportOrderHeader."Booking Id"));
    end;

    procedure OpenAllInDashboard()
    var
        CargosonProdDashboardOverviewUrlTxt: Label 'https://cargoson.com/en/queries', Locked = true;
        CargosonAccDashboardOverviewUrlTxt: Label 'https://cargoson-staging.herokuapp.com/en/queries', Locked = true;
    begin
        IDYSCargosonSetup.GetProviderSetup("IDYS Provider"::Cargoson);
        if IDYSCargosonSetup."Transsmart Environment" = IDYSCargosonSetup."Transsmart Environment"::Production then
            Hyperlink(CargosonProdDashboardOverviewUrlTxt)
        else
            Hyperlink(CargosonAccDashboardOverviewUrlTxt);
    end;

    procedure IsBookable(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        if TransportOrderHeader.Status = TransportOrderHeader.Status::New then
            exit(true);
    end;

    procedure IsRebookable(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        if (TransportOrderHeader."Booking Reference" <> '') and TransportOrderHeader."Booked with Error" then
            exit(true);
    end;

    procedure DeleteAllowed(): Boolean
    begin
        // Delete is not allowed because uploaded documents will be handled with PATCH
        exit(false);
    end;

    procedure DoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        EndpointTxt: Label 'bookings/%1', comment = '%1 = reference', Locked = true;
        RecalledTxt: Label 'Recalled';
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeDoDeleteOrder(IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        GetSetup();

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::DELETE;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, IDYSTransportOrderHeader."Booking Reference");
        TempIDYMRESTParameters."Acceptance Environment" := IDYSCargosonSetup."Transsmart Environment" = IDYSCargosonSetup."Transsmart Environment"::Acceptance;

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Cargoson, "IDYM Endpoint Usage"::Default);

        if TempIDYMRESTParameters."Status Code" = 200 then begin
            IDYSTransportOrderHeader.CreateLogEntry(RecalledTxt, LoggingLevel::Information);
            IDYSTransportOrderHeader.Status := IDYSTransportOrderHeader.Status::Recalled;
            IDYSTransportOrderHeader.Modify();
            Commit();
        end else
            CargosonErrorHandler.Parse(TempIDYMRESTParameters, GuiAllowed());

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterDoDeleteOrder(IDYSTransportOrderHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitDocumentFromIDYSTransportOrderHeader(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDocumentFromIDYSTransportOrderHeader(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitPackagesFromTransportOrderPackages(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitPackagesFromTransportOrderPackages(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Printed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterPrinting(Response: JsonToken; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSelectCarrierFromTemp(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; var ReturnValue: JsonArray; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; var ReturnValue: JsonArray; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; Documents: JsonArray; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; Documents: JsonArray)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSelectCarrierOnProviderCarrierSelectInsert(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; ShipmentRate: JsonToken);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateTransportOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateTransportOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSynchronize(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; var ReturnValue: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitDeliveryNotesFromTransportOrderDeliveryNotes(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDeliveryNotesFromTransportOrderDeliveryNotes(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDoDeleteOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDoDeleteOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;
    #region [Obsolete]
    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(CreateAndBookDocumentWithResponseHandling(IDYSTransportOrderHeader, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean) ReturnValue: Boolean
    begin
        ReturnValue := CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure Synchronize(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes") ResponseDocument: JsonObject
    begin
        ResponseDocument := Synchronize(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure DoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
        Printed := DoLabel(IDYSTransportOrderHeader);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure TryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken) Printed: Boolean
    begin
        Printed := TryDoLabel(IDYSTransportOrderHeader, Response);
    end;
    #endregion

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSCargosonSetup: Record "IDYS Setup";
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        CargosonErrorHandler: Codeunit "IDYS Cargoson Error Handler";
        IDYSLoggingHelper: Codeunit "IDYS Logging Helper";
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        PostDocumentSucceeeded: Boolean;
        SetupLoaded: Boolean;
        ProviderSetupLoaded: Boolean;
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        BookingTxt: Label 'Booking';
        ErrorBookingTxt: Label 'Error while booking';
        UpdatedTxt: Label 'Updated from Cargoson';
        UploadedTxt: Label 'Uploaded to Cargoson';
        SynchronizeTxt: Label 'Synchronize';
        ErrorSynchronizeTxt: Label 'Error while synchronizing';
        LabelPrintedTxt: Label 'Label printed';
        DateErr: Label 'cannot be before %1.', Comment = '%1=Today';
        MissingPackagesErr: Label 'You cannot use the carrier selection without specifying packages.';
        LoggingLevel: Enum "IDYS Logging Level";
        HttpStatusCode: Integer;
}