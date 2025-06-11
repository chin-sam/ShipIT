codeunit 11147722 "IDYS EasyPost API Docs. Mgt."
{
    #region [Carrier Select]
    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary) ReturnValue: JsonArray;
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
        IDYSEasyPostShippingRate: Record "IDYS EasyPost Shipping Rate";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        CompletelyShippedErr: Label 'Order is completely shipped already.';
        Document: JsonObject;
        Documents: JsonArray;
        TotalLinkedWeight: Decimal;
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

        SalesHeader.TestField("Completely Shipped", false);
        TempIDYSTransportOrderHeader.Provider := SalesHeader."IDYS Provider";

        IDYSDocumentMgt.SalesHeader_CreateTempTransportOrder(SalesHeader, TempIDYSTransportOrderHeader);

        IDYSProviderCarrierSelect.SetRange("Transport Order No.", TempIDYSTransportOrderHeader."No.");
        IDYSProviderCarrierSelect.DeleteAll();

        IDYSEasyPostShippingRate.DeleteAll();

        SourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        SourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        SourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
        if SourceDocumentPackage.IsEmpty() then
            exit;

        if IDYSSetup."Link Del. Lines with Packages" then
            TotalLinkedWeight := Round(IDYSDocumentMgt.GetCalculatedWeight(SalesHeader), 0.01);  // assigned to the first package
        if SourceDocumentPackage.FindSet() then
            repeat
                InitPackageFromSourceDocPackage(SourceDocumentPackage, TempIDYSTransportOrderHeader, IDYSProviderCarrierSelect, TotalLinkedWeight, Document);
                if IDYSSessionVariables.CheckAuthorization() then
                    OnInitSelectCarrierOnBeforeAddSourceDocument(TempIDYSTransportOrderHeader, SalesHeader, SourceDocumentPackage);
                Documents.Add(Document);
            until SourceDocumentPackage.Next() = 0
        else
            Error(MissingPackagesErr);

        exit(Documents);
    end;

    procedure InitPackageFromSourceDocPackage(var SourceDocumentPackage: Record "IDYS Source Document Package"; var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; TotalLinkedWeight: Decimal; var Document: JsonObject) ReturnValue: JsonArray;
    var
        RequestDocument: JsonObject;
        ResponseDocument: JsonObject;
        Parcel: JsonObject;
    begin
        Clear(Document);

        // Get Rates
        InitDocumentFromIDYSTransportOrderHeader(Document, TempIDYSTransportOrderHeader);
        if not SourceDocumentPackage."User Defined" then
            if SourceDocumentPackage."Book. Prof. Package Type Code" <> '' then
                IDYMJSONHelper.AddValue(Parcel, 'predefined_package', SourceDocumentPackage."Book. Prof. Package Type Code");
        IDYMJSONHelper.AddValue(Parcel, 'weight', SourceDocumentPackage.Weight + TotalLinkedWeight);
        if SourceDocumentPackage.Height <> 0 then
            IDYMJSONHelper.AddValue(Parcel, 'height', SourceDocumentPackage.Height);
        if SourceDocumentPackage.Length <> 0 then
            IDYMJSONHelper.AddValue(Parcel, 'length', SourceDocumentPackage.Length);
        if SourceDocumentPackage.Width <> 0 then
            IDYMJSONHelper.AddValue(Parcel, 'width', SourceDocumentPackage.Width);
        IDYMJSONHelper.Add(Document, 'parcel', Parcel);

        InitDeliveryNotesFromTransportOrderDeliveryNotes(Document, TempIDYSTransportOrderHeader);
        InitOptions(Document, TempIDYSTransportOrderHeader);
        IDYMJSONHelper.AddVariantValue(Document, 'is_return', TempIDYSTransportOrderHeader."Is Return");
        IDYMJSONHelper.Add(RequestDocument, 'shipment', Document);

        if CreateShipment(TempIDYSTransportOrderHeader, RequestDocument, ResponseDocument, true) then
            HandleResponseAfterCreateShipment(SourceDocumentPackage, ResponseDocument);

        // Package Information
        IDYMJSONHelper.AddValue(Document, 'OrderNo', TempIDYSTransportOrderHeader."No.");
        IDYMJSONHelper.AddValue(Document, 'ParcelIdentifier', SourceDocumentPackage."Parcel Identifier");
        IDYMJSONHelper.AddValue(Document, 'TotalWeight', SourceDocumentPackage.Weight + TotalLinkedWeight);
        TotalLinkedWeight := 0;
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary) ReturnValue: JsonArray;
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSEasyPostShippingRate: Record "IDYS EasyPost Shipping Rate";
        Document: JsonObject;
        Documents: JsonArray;
        RequestDocument: JsonObject;
        ResponseDocument: JsonObject;
        Parcel: JsonObject;
        Weight: Decimal;
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
            IDYSTransportOrderHeader.Status::Uploaded,
            IDYSTransportOrderHeader.Status::Recalled])
        then
            IDYSTransportOrderHeader.FieldError(Status);

        IDYSProviderMgt.CheckLinkedDelLines(IDYSTransportOrderHeader);

        IDYSProviderCarrierSelect.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSProviderCarrierSelect.DeleteAll();

        IDYSEasyPostShippingRate.DeleteAll();

        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                Clear(Document);
                Clear(RequestDocument);

                Weight := IDYSTransportOrderPackage.GetPackageWeight();
                if IDYSTransportOrderPackage."Actual Weight" <> 0 then
                    Weight := IDYSTransportOrderPackage."Actual Weight";

                // Get Rates
                InitDocumentFromIDYSTransportOrderHeader(Document, IDYSTransportOrderHeader);
                Clear(Parcel);
                if not IDYSTransportOrderPackage."User Defined" then
                    if IDYSTransportOrderPackage."Book. Prof. Package Type Code" <> '' then
                        IDYMJSONHelper.AddValue(Parcel, 'predefined_package', IDYSTransportOrderPackage."Book. Prof. Package Type Code");
                IDYMJSONHelper.AddValue(Parcel, 'weight', Weight);
                if IDYSTransportOrderPackage.Height <> 0 then
                    IDYMJSONHelper.AddValue(Parcel, 'height', IDYSTransportOrderPackage.Height);
                if IDYSTransportOrderPackage.Length <> 0 then
                    IDYMJSONHelper.AddValue(Parcel, 'length', IDYSTransportOrderPackage.Length);
                if IDYSTransportOrderPackage.Width <> 0 then
                    IDYMJSONHelper.AddValue(Parcel, 'width', IDYSTransportOrderPackage.Width);
                IDYMJSONHelper.Add(Document, 'parcel', Parcel);

                InitDeliveryNotesFromTransportOrderDeliveryNotes(Document, IDYSTransportOrderHeader, IDYSTransportOrderPackage);
                InitOptions(Document, IDYSTransportOrderHeader, IDYSTransportOrderPackage);
                IDYMJSONHelper.AddVariantValue(Document, 'is_return', IDYSTransportOrderHeader."Is Return");
                IDYMJSONHelper.Add(RequestDocument, 'shipment', Document);

                if CreateShipment(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, true) then
                    HandleResponseAfterCreateShipment(IDYSTransportOrderPackage, ResponseDocument);

                Clear(Document);
                IDYMJSONHelper.AddValue(Document, 'OrderNo', IDYSTransportOrderHeader."No.");
                IDYMJSONHelper.AddValue(Document, 'ParcelIdentifier', IDYSTransportOrderPackage."Parcel Identifier");
                IDYMJSONHelper.AddValue(Document, 'TotalWeight', Weight);

                if IDYSSessionVariables.CheckAuthorization() then
                    OnInitSelectCarrierOnBeforeAddTransportOrderPackage(IDYSTransportOrderHeader, IDYSTransportOrderPackage, Document);
                Documents.Add(Document);
            until IDYSTransportOrderPackage.Next() = 0
        else
            Error(MissingPackagesErr);

        exit(Documents);
    end;

    local procedure InitOptions(var RequestDocument: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        DummyTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        InitOptions(RequestDocument, IDYSTransportOrderHeader, DummyTransportOrderPackage);
    end;

    local procedure InitOptions(var RequestDocument: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package")
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSIncoterm: Record "IDYS Incoterm";
        IDYSLabelType: Enum "IDYS DelHub Label Type";
        Options: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitOptions(RequestDocument, IDYSTransportOrderHeader, IDYSTransportOrderPackage, IsHandled);
            if IsHandled then
                exit;
        end;

        if IDYSTransportOrderHeader."Carrier Entry No." <> 0 then
            if IDYSProviderCarrier.Get(IDYSTransportOrderHeader."Carrier Entry No.") then
                IDYMJSONHelper.AddValue(RequestDocument, 'carrier_accounts', IDYSProviderCarrier."Carrier Id");

        if IDYSTransportOrderHeader."Invoice (Ref)" <> '' then
            IDYMJSONHelper.AddValue(Options, 'invoice_number', IDYSTransportOrderHeader."Invoice (Ref)");
        if IDYSTransportOrderHeader.Instruction <> '' then
            IDYMJSONHelper.AddValue(Options, 'handling_instructions', IDYSTransportOrderHeader.Instruction);

        if IDYSIncoterm.Get(IDYSTransportOrderHeader."Incoterms Code") then
            IDYMJSONHelper.AddValue(Options, 'incoterm', IDYSIncoterm."Code");

        if IDYSTransportOrderPackage.Description <> '' then
            IDYMJSONHelper.AddValue(Options, 'content_description', IDYSTransportOrderPackage.Description);

        //IDYMJSONHelper.AddValue(Options, 'postage_label_inline', true);  // This returns label_file which contains .png as base64
        IDYSLabelType := IDYSTransportOrderPackage."Label Format";
        if IDYSLabelType = IDYSLabelType::none then
            IDYSLabelType := IDYSEasyPostSetup."Default Label Type";
        IDYMJSONHelper.AddValue(Options, 'label_format', UpperCase(Format(IDYSLabelType)));

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitOptions(RequestDocument, IDYSTransportOrderHeader, IDYSTransportOrderPackage, Options);

        IDYMJSONHelper.Add(RequestDocument, 'options', Options);
    end;

    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray);
    var
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        LineNo: Integer;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents, IsHandled);
            if IsHandled then
                exit;
        end;

        if not IDYSProviderCarrierSelect.IsTemporary then
            Error(NotTempororaryErr, IDYSProviderCarrierSelect.TableCaption);

        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSProvCarrierSelectPck.DeleteAll();

        IDYSShipAgentSvcMapping.SetRange(Provider, IDYSShipAgentSvcMapping.Provider::EasyPost);
        IDYSShipAgentSvcMapping.SetAutoCalcFields("Shipping Agent Service Desc.");
        if IDYSShipAgentSvcMapping.FindSet() then
            repeat
                LineNo += 1;
                IDYSProviderCarrierSelect.Init();
                IDYSProviderCarrierSelect."Transport Order No." := IDYSTransportOrderHeader."No.";
                IDYSProviderCarrierSelect."Line No." := LineNo;

                IDYSProviderCarrierSelect."Carrier Entry No." := IDYSShipAgentSvcMapping."Carrier Entry No.";
                IDYSProviderCarrierSelect."Svc. Mapping RecordId" := IDYSShipAgentSvcMapping.RecordId;
                IDYSProviderCarrierSelect."Shipping Agent Service Desc." := IDYSShipAgentSvcMapping."Shipping Agent Service Desc.";
                if IDYSSessionVariables.CheckAuthorization() then
                    OnSelectCarrierOnBeforeProviderCarrierSelectInsert(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, IDYSShipAgentSvcMapping);
                IDYSProviderCarrierSelect.Insert();

                if not IsServiceApplicable(IDYSShipAgentSvcMapping, Documents, LineNo) then
                    IDYSProviderCarrierSelect.Delete();
            until IDYSShipAgentSvcMapping.Next() = 0;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents);
    end;

    procedure IsServiceApplicable(var IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping"; Packages: JsonArray; LineNo: Integer): Boolean
    var
        Package: JsonToken;
    begin
        foreach Package in Packages do
            if not IsPackageApplicable(IDYSShipAgentSvcMapping, Package, LineNo) then
                exit(false);
        exit(true);
    end;

    local procedure IsPackageApplicable(var IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping"; Package: JsonToken; LineNo: Integer) CreatedEntry: Boolean
    var
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSEasyPostShippingRate: Record "IDYS EasyPost Shipping Rate";
        IDYSSvcBookingProfile: Record "IDYS Svc. Booking Profile";
        TotalWeight: Decimal;
        ParcelIdentifier: Code[30];
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeIsPackageApplicable(IDYSShipAgentSvcMapping, Package, LineNo, CreatedEntry, IsHandled);
            if IsHandled then
                exit(CreatedEntry);
        end;

        // Package variables
        TotalWeight := IDYMJSONHelper.GetDecimalValue(Package, 'TotalWeight');
        ParcelIdentifier := CopyStr(IDYMJSONHelper.GetCodeValue(Package, 'ParcelIdentifier'), 1, MaxStrLen(IDYSProvCarrierSelectPck."Parcel Identifier"));

        IDYSSvcBookingProfile.SetRange("Shipping Agent Code", IDYSShipAgentSvcMapping."Shipping Agent Code");
        IDYSSvcBookingProfile.SetRange("Shipping Agent Service Code", IDYSShipAgentSvcMapping."Shipping Agent Service Code");
        if IDYSSvcBookingProfile.FindSet() then
            repeat
                IDYSProviderCarrier.SetRange(Provider, "IDYS Provider"::EasyPost);
                IDYSProviderCarrier.SetRange("Entry No.", IDYSSvcBookingProfile."Carrier Entry No.");
                if IDYSProviderCarrier.FindFirst() then begin
                    IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
                    IDYSProviderBookingProfile.SetRange("Entry No.", IDYSSvcBookingProfile."Booking Profile Entry No.");
                    if IDYSProviderBookingProfile.FindFirst() then begin
                        IDYSEasyPostShippingRate.SetRange("Carrier Entry No.", IDYSProviderBookingProfile."Carrier Entry No.");
                        IDYSEasyPostShippingRate.SetRange("Booking Profile Entry No.", IDYSProviderBookingProfile."Entry No.");
                        IDYSEasyPostShippingRate.SetRange("Parcel Identifier", ParcelIdentifier);
                        if IDYSEasyPostShippingRate.FindFirst() then begin
                            IDYSProvCarrierSelectPck.Init();
                            IDYSProvCarrierSelectPck."Transport Order No." := CopyStr(IDYMJSONHelper.GetCodeValue(Package, 'OrderNo'), 1, MaxStrLen(IDYSProvCarrierSelectPck."Transport Order No."));
                            IDYSProvCarrierSelectPck."Line No." := LineNo;
                            IDYSProvCarrierSelectPck."Carrier Entry No." := IDYSProviderBookingProfile."Carrier Entry No.";
                            IDYSProvCarrierSelectPck."Booking Profile Entry No." := IDYSProviderBookingProfile."Entry No.";
                            IDYSProvCarrierSelectPck."Carrier Name" := CopyStr(IDYSProviderCarrier.Name, 1, MaxStrLen(IDYSProvCarrierSelectPck."Carrier Name"));
                            IDYSProvCarrierSelectPck.Description := CopyStr(IDYSProviderBookingProfile.Description, 1, MaxStrLen(IDYSProvCarrierSelectPck.Description));
                            IDYSProvCarrierSelectPck."Parcel Identifier" := ParcelIdentifier;
                            IDYSProvCarrierSelectPck."Shipment Id" := IDYSEasyPostShippingRate."Shipment Id";
                            IDYSProvCarrierSelectPck."Package Id" := IDYSEasyPostShippingRate."Package Id";
                            IDYSProvCarrierSelectPck."Rate Id" := IDYSEasyPostShippingRate."Rate Id";
                            IDYSProvCarrierSelectPck."Price as Decimal" := IDYSEasyPostShippingRate.Price;
                            IDYSProvCarrierSelectPck.Weight := TotalWeight;

                            if not CreatedEntry then
                                IDYSProvCarrierSelectPck.Include := true;
                            IDYSProvCarrierSelectPck.Insert(true);

                            CreatedEntry := true;
                        end;
                    end;
                end;
            until IDYSSvcBookingProfile.Next() = 0;
    end;

    local procedure CreateShipment(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean): Boolean
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        EndpointTxt: Label '/shipments', Locked = true;
    begin
        GetSetup();

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
        TempIDYMRESTParameters.Path := EndpointTxt;
        TempIDYMRESTParameters.SetRequestContent(RequestDocument);

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::EasyPost, "IDYM Endpoint Usage"::Default);

        if (TempIDYMRESTParameters."Status Code" <> 201) or not TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject() then begin
            if AllowLogging and TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject() then begin
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", ErrorCreateShipmentTxt, LoggingLevel::Error, RequestDocument, TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
                Commit();
            end;
            IDYSEasyPostErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;

        ResponseDocument := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
        exit(true);
    end;

    local procedure HandleResponseAfterCreateShipment(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; ResponseDocument: JsonObject) ReturnValue: Boolean
    var
        Package: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterCreateShipment(IDYSTransportOrderPackage, ResponseDocument, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;


        IDYSEasyPostErrorHandler.Parse(ResponseDocument.AsToken(), GuiAllowed());

        Package := IDYMJSONHelper.GetObject(ResponseDocument, 'parcel');

        IDYSTransportOrderPackage."Shipment Id" := CopyStr(IDYMJSONHelper.GetTextValue(ResponseDocument, 'id'), 1, MaxStrLen(IDYSTransportOrderPackage."Shipment Id"));
        IDYSTransportOrderPackage."Package Id" := CopyStr(IDYMJSONHelper.GetTextValue(Package, 'id'), 1, MaxStrLen(IDYSTransportOrderPackage."Package Id"));
        IDYSTransportOrderPackage."Rate Id" := SaveShippingRates(ResponseDocument, IDYSTransportOrderPackage."Parcel Identifier");
        IDYSTransportOrderPackage.Modify(true);

        exit(true);
    end;

    local procedure HandleResponseAfterCreateShipment(var IDYSSourceDocumentPackage: Record "IDYS Source Document Package"; ResponseDocument: JsonObject) ReturnValue: Boolean
    var
        IDYSEasyPostShippingRate: Record "IDYS EasyPost Shipping Rate";
        Rate: JsonToken;
        Rates: JsonArray;
        Package: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterCreateShipmentFromSourceDoc(IDYSSourceDocumentPackage, ResponseDocument, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;


        IDYSEasyPostErrorHandler.Parse(ResponseDocument.AsToken(), GuiAllowed());

        Package := IDYMJSONHelper.GetObject(ResponseDocument, 'parcel');
        Rates := IDYMJSONHelper.GetArray(ResponseDocument, 'rates');
        foreach Rate in Rates do begin
            Clear(IDYSEasyPostShippingRate);

            IDYSEasyPostShippingRate."Carrier Entry No." := GetCarrierEntryNo(IDYMJSONHelper.GetTextValue(Rate, 'carrier_account_id'));
            IDYSEasyPostShippingRate."Booking Profile Entry No." := GetBookingProfileNo(IDYSEasyPostShippingRate."Carrier Entry No.", IDYMJSONHelper.GetTextValue(Rate, 'service'));
            IDYSEasyPostShippingRate."Last Update" := CurrentDateTime;
            IDYSEasyPostShippingRate.Price := IDYMJSONHelper.GetDecimalValue(Rate, 'rate');

            IDYSEasyPostShippingRate."Shipment Id" := CopyStr(IDYMJSONHelper.GetTextValue(Rate, 'shipment_id'), 1, MaxStrLen(IDYSEasyPostShippingRate."Shipment Id"));
            IDYSEasyPostShippingRate."Package Id" := CopyStr(IDYMJSONHelper.GetTextValue(Package, 'id'), 1, MaxStrLen(IDYSEasyPostShippingRate."Package Id"));
            IDYSEasyPostShippingRate."Rate Id" := CopyStr(IDYMJSONHelper.GetTextValue(Rate, 'id'), 1, MaxStrLen(IDYSEasyPostShippingRate."Rate Id"));
            IDYSEasyPostShippingRate."Parcel Identifier" := IDYSSourceDocumentPackage."Parcel Identifier";

            if not IDYSEasyPostShippingRate.Insert() then
                IDYSEasyPostShippingRate.Modify();
        end;

        exit(true);
    end;

    local procedure SaveShippingRates(ResponseDocument: JsonObject; ParcelIdentifier: Code[30]) DefaultRateId: Text[100]
    var
        IDYSEasyPostShippingRate: Record "IDYS EasyPost Shipping Rate";
        Rate: JsonToken;
        Rates: JsonArray;
        Package: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeSaveShippingRates(ResponseDocument, IDYSEasyPostShippingRate, Rate, IsHandled, DefaultRateId);
            if IsHandled then
                exit(DefaultRateId);
        end;

        // This function saves all shipping rates and returns a default one
        Package := IDYMJSONHelper.GetObject(ResponseDocument, 'parcel');

        Rates := IDYMJSONHelper.GetArray(ResponseDocument, 'rates');
        foreach Rate in Rates do begin
            Clear(IDYSEasyPostShippingRate);

            IDYSEasyPostShippingRate."Carrier Entry No." := GetCarrierEntryNo(IDYMJSONHelper.GetTextValue(Rate, 'carrier_account_id'));
            IDYSEasyPostShippingRate."Booking Profile Entry No." := GetBookingProfileNo(IDYSEasyPostShippingRate."Carrier Entry No.", IDYMJSONHelper.GetTextValue(Rate, 'service'));
            IDYSEasyPostShippingRate."Last Update" := CurrentDateTime;

            IDYSEasyPostShippingRate.Price := IDYMJSONHelper.GetDecimalValue(Rate, 'rate');

            IDYSEasyPostShippingRate."Shipment Id" := CopyStr(IDYMJSONHelper.GetTextValue(Rate, 'shipment_id'), 1, MaxStrLen(IDYSEasyPostShippingRate."Shipment Id"));
            IDYSEasyPostShippingRate."Package Id" := CopyStr(IDYMJSONHelper.GetTextValue(Package, 'id'), 1, MaxStrLen(IDYSEasyPostShippingRate."Package Id"));
            IDYSEasyPostShippingRate."Rate Id" := CopyStr(IDYMJSONHelper.GetTextValue(Rate, 'id'), 1, MaxStrLen(IDYSEasyPostShippingRate."Rate Id"));
            IDYSEasyPostShippingRate."Parcel Identifier" := ParcelIdentifier;

            if not IDYSEasyPostShippingRate.Insert() then
                IDYSEasyPostShippingRate.Modify();

            if DefaultRateId = '' then
                DefaultRateId := IDYSEasyPostShippingRate."Rate Id";
        end;
    end;

    local procedure GetCarrierEntryNo(CarrierId: Text): Integer
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
    begin
        IDYSProviderCarrier.SetRange("Carrier Id", CarrierId);
        if IDYSProviderCarrier.FindFirst() then
            exit(IDYSProviderCarrier."Entry No.");
    end;

    local procedure GetBookingProfileNo(CarrierEntryNo: Integer; ServiceNameText: Text): Integer
    var
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
    begin
        IDYSProviderBookingProfile.SetRange("Carrier Entry No.", CarrierEntryNo);
        IDYSProviderBookingProfile.SetRange(Description, ServiceNameText);
        if IDYSProviderBookingProfile.FindFirst() then
            exit(IDYSProviderBookingProfile."Entry No.");
    end;
    #endregion

    #region [Booking]
    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; AllowLogging: Boolean): Boolean
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
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        LicenseCheck: Codeunit "IDYS License Check";
        ErrorMessage: Text;
        Rate: JsonObject;
        Package: JsonObject;
        Tracker: JsonObject;
        PostageLabel: JsonObject;
        FileNameLbl: Label 'label-%1.%2', Locked = true;
        LicenseUnitsLbl: Label 'carriers';
        ContentOutStream: OutStream;
        ContentInStream: InStream;
        IsHandled: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeCreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        ValidateTransportOrder(IDYSTransportOrderHeader);

        //Pre-POST check if using ShipIT is allowed
        IDYMAppHub.SetPostponeWriteTransactions();
        IDYMAppHub.SetErrorUnitName(LicenseUnitsLbl);
        LicenseCheck.SetPostponeWriteTransactions();
        if not LicenseCheck.CheckLicense(IDYSSetup."License Entry No.", ErrorMessage, HttpStatusCode) then
            exit;

        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderPackage.FindSet(true) then begin
            repeat
                Clear(Rate);
                Clear(RequestDocument);

                // Rate
                IDYMJSONHelper.AddValue(Rate, 'id', IDYSTransportOrderPackage."Rate Id");
                IDYMJSONHelper.Add(RequestDocument, 'rate', Rate);

                if AllowLogging and IDYSSetup."Enable Debug Mode" then begin
                    IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", BookingTxt, LoggingLevel::Information, RequestDocument);
                    Commit();
                end;
                ResponseDocument := BuyShipment(IDYSTransportOrderPackage, RequestDocument, AllowLogging);

                if PostDocumentSucceeeded then begin
                    //Set status to booked so that TO status is correct even when processing the response fails
                    IDYSTransportOrderHeader.Status := IDYSTransportOrderHeader.Status::Booked;
                    IDYSTransportOrderHeader.Modify();
                end;
                if AllowLogging then
                    if IDYSSetup."Enable Debug Mode" then
                        IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", UploadedTxt, "IDYS Logging Level"::Information, RequestDocument, ResponseDocument)
                    else
                        IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", UploadedTxt, "IDYS Logging Level"::Information);
                if PostDocumentSucceeeded or AllowLogging then
                    Commit();

                Package := IDYMJSONHelper.GetObject(ResponseDocument, 'parcel');
                Tracker := IDYMJSONHelper.GetObject(ResponseDocument, 'tracker');
                PostageLabel := IDYMJSONHelper.GetObject(ResponseDocument, 'postage_label');

                // Tracking information
                IDYSTransportOrderPackage."Tracking No." := CopyStr(IDYMJSONHelper.GetTextValue(Tracker, 'tracking_code'), 1, MaxStrLen(IDYSTransportOrderPackage."Tracking No."));
                IDYSTransportOrderPackage."Tracking Url" := CopyStr(IDYMJSONHelper.GetTextValue(Tracker, 'public_url'), 1, MaxStrLen(IDYSTransportOrderPackage."Tracking Url"));
                IDYSTransportOrderPackage.Status := CopyStr(IDYMJSONHelper.GetTextValue(Tracker, 'status'), 1, MaxStrLen(IDYSTransportOrderPackage.Status));
                IDYSTransportOrderPackage."Sub Status (External)" := CopyStr(IDYMJSONHelper.GetTextValue(Tracker, 'status_detail'), 1, MaxStrLen(IDYSTransportOrderPackage."Sub Status (External)"));
                IDYSTransportOrderPackage."Label Url" := CopyStr(IDYMJSONHelper.GetTextValue(PostageLabel, 'label_url'), 1, MaxStrLen(IDYSTransportOrderPackage."Label Url"));

                if IDYSSessionVariables.CheckAuthorization() then
                    OnBeforeModifyTransportOrderPackage(IDYSTransportOrderPackage, ResponseDocument);
                IDYSTransportOrderPackage.Modify(true);

                // Get Label
                if IDYSTransportOrderPackage."Label Url" <> '' then
                    if HttpClient.Get(IDYSTransportOrderPackage."Label Url", HttpResponseMessage) then
                        if HttpResponseMessage.IsSuccessStatusCode() and (HttpResponseMessage.Content().ReadAs(ContentInStream)) then begin
                            IDYSSCParcelDocument.Init();
                            IDYSSCParcelDocument."Parcel Identifier" := IDYSTransportOrderPackage."Parcel Identifier";
                            IDYSSCParcelDocument."Transport Order No." := IDYSTransportOrderPackage."Transport Order No.";
                            IDYSSCParcelDocument."File Name" := StrSubstNo(FileNameLbl, IDYSTransportOrderPackage."Parcel Identifier", LowerCase(Format((IDYSTransportOrderPackage."Label Format"))));
                            IDYSSCParcelDocument."File".CreateOutStream(ContentOutStream);
                            CopyStream(ContentOutStream, ContentInStream);

                            if IDYSSessionVariables.CheckAuthorization() then
                                OnCreateAndBookDocumentOnBeforeInsertParcelDocument(IDYSSCParcelDocument, ResponseDocument);
                            IDYSSCParcelDocument.Insert(true);
                        end;
            until IDYSTransportOrderPackage.Next() = 0;

            if IDYSSessionVariables.CheckAuthorization() then
                OnAfterCreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging);
            exit(true);
        end;
    end;

    procedure BuyShipment(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; Document: JsonObject; AllowLogging: Boolean) Response: JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        EndpointTxt: Label '/shipments/%1/buy', Locked = true;
    begin
        GetSetup();

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, IDYSTransportOrderPackage."Shipment Id");
        TempIDYMRESTParameters.SetRequestContent(Document);

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::EasyPost, "IDYM Endpoint Usage"::Default);

        PostDocumentSucceeeded := (TempIDYMRESTParameters."Status Code" = 200) and TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject();
        if not PostDocumentSucceeeded then begin
            if AllowLogging and TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject() then begin
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderPackage."Transport Order No.", ErrorBuyShipmentTxt, LoggingLevel::Error, Document, TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
                Commit();
            end;
            IDYSEasyPostErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;
        Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
    end;

    procedure HandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject) ReturnValue: Boolean
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterBooking(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        GetSetup();

        // Update tracking information
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if TransportOrderPackage.FindLast() then begin
            IDYSTransportOrderHeader."Tracking No." := TransportOrderPackage."Tracking No.";
            IDYSTransportOrderHeader."Tracking Url" := TransportOrderPackage."Tracking Url";
        end;

        // Update status
        UpdateStatus(IDYSTransportOrderHeader);
        IDYSTransportOrderHeader.Modify(true);

        Commit();  // Save changes in case of an error in PrintIT
        exit(true);
    end;
    #endregion

    #region [Synchronize]
    procedure GetShipmentAdditionalInformation(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean) ReturnValue: JsonObject
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        Response: JsonObject;
        Tracker: JsonObject;
        IsHandled: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeGetShipmentAdditionalInformation(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        IDYSTransportOrderPackage.Reset();
        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderPackage.FindSet(true) then
            repeat
                Response := RetrieveShipment(IDYSTransportOrderPackage, WriteLogEntry);
                Tracker := IDYMJSONHelper.GetObject(Response, 'tracker');

                IDYSTransportOrderPackage.Status := CopyStr(IDYMJSONHelper.GetTextValue(Tracker, 'status'), 1, MaxStrLen(IDYSTransportOrderPackage.Status));
                IDYSTransportOrderPackage."Sub Status (External)" := CopyStr(IDYMJSONHelper.GetTextValue(Tracker, 'status_detail'), 1, MaxStrLen(IDYSTransportOrderPackage."Sub Status (External)"));
                if IDYSSessionVariables.CheckAuthorization() then
                    OnGetShipmentAdditionalInformationOnBeforeTransportOrderPackageModify(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry, ReturnValue, IDYSTransportOrderPackage);

                IDYSTransportOrderPackage.Modify(true);
            until IDYSTransportOrderPackage.Next() = 0;

        UpdateStatus(IDYSTransportOrderHeader);
        IDYSTransportOrderHeader.Modify(true);

        IDYSTransportOrderHeader.CreateLogEntry(UpdatedTxt, LoggingLevel::Information);
    end;

    local procedure RetrieveShipment(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; AllowLogging: Boolean) Response: JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        EndpointTxt: Label '/shipments/%1', Locked = true;
    begin
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, IDYSTransportOrderPackage."Shipment Id");

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::EasyPost, "IDYM Endpoint Usage"::Default);
        if (TempIDYMRESTParameters."Status Code" <> 200) or not TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject() then begin
            if AllowLogging and TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject() then begin
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderPackage."Transport Order No.", ErrorSyncShipmentTxt, LoggingLevel::Error, DummyJsonObject, TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
                Commit();
            end;
            IDYSEasyPostErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;
        Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
    end;
    #endregion

    #region [Set Shipping Method]
    procedure ResetSalesHeaderShippingMethod(var SalesHeader: Record "Sales Header")
    var
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
    begin
        IDYSSourceDocumentPackage.Reset();
        IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        IDYSSourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        IDYSSourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
        if not IDYSSourceDocumentPackage.IsEmpty() then begin
            IDYSSourceDocumentPackage.ModifyAll("Shipping Method Description", '');
            IDYSSourceDocumentPackage.ModifyAll("Shipment Id", '');
            IDYSSourceDocumentPackage.ModifyAll("Package Id", '');
            IDYSSourceDocumentPackage.ModifyAll("Rate Id", '');
        end;
    end;

    procedure SetShippingMethod(var SalesHeader: Record "Sales Header")
    var
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
        IDYSEasyPostShippingRate: Record "IDYS EasyPost Shipping Rate";
        TempIDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary;
        TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header" temporary;
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        NonApplicableServiceTok: Label '186a822e-e2ae-45e7-a91b-518ede89a7a8', Locked = true;
        Documents: JsonArray;
    begin
        // Reset shipping method
        ResetSalesHeaderShippingMethod(SalesHeader);

        if not CheckShippingMethodConditions(SalesHeader) then
            exit;

        if not IDYSShipAgentSvcMapping.Get(SalesHeader."Shipping Agent Code", SalesHeader."Shipping Agent Service Code") then
            Error(NotMappedServiceTxt);

        // Set Base Filters
        IDYSSourceDocumentPackage.Reset();
        IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        IDYSSourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        IDYSSourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");

        // Reset carrier selection data
        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", SalesHeader."No.");
        IDYSProvCarrierSelectPck.DeleteAll();
        IDYSEasyPostShippingRate.DeleteAll();

        // Get Rates
        Documents := InitSelectCarrier(TempIDYSTransportOrderHeader, SalesHeader, TempIDYSProviderCarrierSelect);

        // Check if service applicable
        if not IsServiceApplicable(IDYSShipAgentSvcMapping, Documents, 0) then begin
            IDYSNotificationManagement.SendNotification(NonApplicableServiceTok, NonApplicableServiceTxt);

            SalesHeader."Shipping Agent Service Code" := '';
            exit;
        end;

        // Validate packages
        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", TempIDYSTransportOrderHeader."No.");
        IDYSProvCarrierSelectPck.SetRange("Line No.", 0);
        IDYSProvCarrierSelectPck.SetRange(Include, true);
        if IDYSProvCarrierSelectPck.FindSet() then
            repeat
                IDYSSourceDocumentPackage.SetRange("Parcel Identifier", IDYSProvCarrierSelectPck."Parcel Identifier");
                if IDYSSourceDocumentPackage.FindLast() then begin
                    IDYSSourceDocumentPackage.Validate("Shipment Id", IDYSProvCarrierSelectPck."Shipment Id");
                    IDYSSourceDocumentPackage.Validate("Package Id", IDYSProvCarrierSelectPck."Package Id");
                    IDYSSourceDocumentPackage.Validate("Rate Id", IDYSProvCarrierSelectPck."Rate Id");
                    IDYSSourceDocumentPackage.Validate("Shipping Method Description", CopyStr(IDYSProvCarrierSelectPck."Carrier Name" + ' - ' + IDYSProvCarrierSelectPck.Description, 1, MaxStrLen(IDYSSourceDocumentPackage."Shipping Method Description")));
                    IDYSSourceDocumentPackage.Modify();
                end;
            until IDYSProvCarrierSelectPck.Next() = 0;
    end;

    procedure CheckShippingMethodConditions(var SalesHeader: Record "Sales Header"): Boolean
    var
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
        SalesLine: Record "Sales Line";
    begin
        if not IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::EasyPost, SalesHeader."IDYS Provider") then
            exit;

        if SalesHeader."Shipping Agent Service Code" = '' then
            exit;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.IsEmpty() then
            exit;

        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Quote, SalesHeader."Document Type"::Order]) then
            exit;

        IDYSSourceDocumentPackage.Reset();
        IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        IDYSSourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        IDYSSourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
        if IDYSSourceDocumentPackage.IsEmpty() then
            exit;

        exit(true);
    end;

    procedure ResetTransportOrderShippingMethod(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        IDYSTransportOrderPackage.Reset();
        IDYSTransportOrderPackage.SetRange("Transport Order No.", TransportOrderHeader."No.");
        if not IDYSTransportOrderPackage.IsEmpty() then begin
            IDYSTransportOrderPackage.ModifyAll("Shipping Method Description", '');
            IDYSTransportOrderPackage.ModifyAll("Shipment Id", '');
            IDYSTransportOrderPackage.ModifyAll("Package Id", '');
            IDYSTransportOrderPackage.ModifyAll("Rate Id", '');
        end;
    end;

    procedure SetShippingMethod(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSEasyPostShippingRate: Record "IDYS EasyPost Shipping Rate";
        TempIDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary;
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        Documents: JsonArray;
    begin
        // Reset shipping method
        ResetTransportOrderShippingMethod(TransportOrderHeader);

        if not CheckShippingMethodConditions(TransportOrderHeader) then
            exit;

        if not IDYSShipAgentSvcMapping.Get(TransportOrderHeader."Shipping Agent Code", TransportOrderHeader."Shipping Agent Service Code") then
            Error(NotMappedServiceTxt);

        // Reset carrier selection data
        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", TransportOrderHeader."No.");
        IDYSProvCarrierSelectPck.DeleteAll();
        IDYSEasyPostShippingRate.DeleteAll();

        // Get Rates
        Documents := InitSelectCarrier(TransportOrderHeader, TempIDYSProviderCarrierSelect);

        // Check if service applicable
        if not IsServiceApplicable(IDYSShipAgentSvcMapping, Documents, 0) then
            Error(NonApplicableServiceTxt);

        // Validate packages
        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", TransportOrderHeader."No.");
        IDYSProvCarrierSelectPck.SetRange("Line No.", 0);
        IDYSProvCarrierSelectPck.SetRange(Include, true);
        if IDYSProvCarrierSelectPck.FindSet() then
            repeat
                IDYSTransportOrderPackage.SetRange("Transport Order No.", TransportOrderHeader."No.");
                IDYSTransportOrderPackage.SetRange("Parcel Identifier", IDYSProvCarrierSelectPck."Parcel Identifier");
                if IDYSTransportOrderPackage.FindLast() then begin
                    IDYSTransportOrderPackage.Validate("Shipment Id", IDYSProvCarrierSelectPck."Shipment Id");
                    IDYSTransportOrderPackage.Validate("Package Id", IDYSProvCarrierSelectPck."Package Id");
                    IDYSTransportOrderPackage.Validate("Rate Id", IDYSProvCarrierSelectPck."Rate Id");
                    IDYSTransportOrderPackage.Validate("Shipping Method Description", CopyStr(IDYSProvCarrierSelectPck."Carrier Name" + ' - ' + IDYSProvCarrierSelectPck.Description, 1, MaxStrLen(IDYSTransportOrderPackage."Shipping Method Description")));
                    IDYSTransportOrderPackage.Modify();
                end;
            until IDYSProvCarrierSelectPck.Next() = 0;
    end;

    procedure CheckShippingMethodConditions(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        if not IDYSProviderMgt.IsProvider("IDYS Provider"::EasyPost, TransportOrderHeader) then
            exit;
        if TransportOrderHeader."Shipping Agent Service Code" = '' then
            exit;
        exit(true);
    end;
    #endregion

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IsHandled: Boolean;
    begin
        OnBeforeValidateTransportOrder(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;
        if not (IDYSTransportOrderHeader.Status in [
            IDYSTransportOrderHeader.Status::New])
        then
            IDYSTransportOrderHeader.FieldError(Status);

        IDYSTransportOrderHeader.TestField("Name (Pick-up)");
        IDYSTransportOrderHeader.TestField("Street (Pick-up)");
        IDYSTransportOrderHeader.TestField("Post Code (Pick-up)");
        IDYSTransportOrderHeader.TestField("County (Pick-up)");
        IDYSTransportOrderHeader.TestField("Country/Region Code (Pick-up)");
        IDYSTransportOrderHeader.TestField("City (Pick-up)");

        IDYSTransportOrderHeader.TestField("Name (Ship-to)");
        IDYSTransportOrderHeader.TestField("Street (Ship-to)");
        IDYSTransportOrderHeader.TestField("Post Code (Ship-to)");
        IDYSTransportOrderHeader.TestField("County (Ship-to)");
        IDYSTransportOrderHeader.TestField("Country/Region Code (Ship-to)");
        IDYSTransportOrderHeader.TestField("City (Ship-to)");

        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                IDYSTransportOrderPackage.TestField("Rate Id");
                IDYSTransportOrderPackage.TestField("Shipment Id");
                IDYSTransportOrderPackage.TestField("Package Id");
            until IDYSTransportOrderPackage.Next() = 0;

        IDYSProviderMgt.CheckTransportOrder(IDYSTransportOrderHeader);
        OnAfterValidateTransportOrder(IDYSTransportOrderHeader);
    end;

    local procedure InitDocumentFromIDYSTransportOrderHeader(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        Address: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitDocumentFromIDYSTransportOrderHeader(Document, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        // to_address
        Clear(Address);
        IDYMJSONHelper.AddValue(Address, 'name', IDYSTransportOrderHeader."Name (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'street1', IDYSTransportOrderHeader."Address (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'street2', IDYSTransportOrderHeader."Address 2 (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'zip', IDYSTransportOrderHeader."Post Code (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'city', IDYSTransportOrderHeader."City (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'state', IDYSTransportOrderHeader."County (Ship-to)");
        if IDYSTransportOrderHeader."Mobile Phone No. (Ship-to)" <> '' then
            IDYMJSONHelper.AddValue(Address, 'phone', IDYSTransportOrderHeader."Mobile Phone No. (Ship-to)")
        else
            IDYMJSONHelper.AddValue(Address, 'phone', IDYSTransportOrderHeader."Phone No. (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'email', IDYSTransportOrderHeader."E-Mail (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'country', IDYSTransportOrderHeader."Cntry/Rgn. Code (Ship-to) (TS)");  //External Country Code / ISO 3166

        // NOTE: federal_tax_id
        // An Employer Identification Number (EIN) is also known as a Federal Tax Identification Number
        // CompanyInformation."EIN Number" or CompanyInformation."Federal ID No."

        // NOTE: state_tax_id
        // No information about the state_tax_id in the business central.
        // There is a good chance that you can't specify state_tax_id in the system
        // You can set up tax calculation per state

        // Implement these fields with the specific case only
        IDYMJSONHelper.Add(Document, 'to_address', Address);

        // from_address
        Clear(Address);
        IDYMJSONHelper.AddValue(Address, 'name', IDYSTransportOrderHeader."Name (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'street1', IDYSTransportOrderHeader."Address (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'street2', IDYSTransportOrderHeader."Address 2 (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'zip', IDYSTransportOrderHeader."Post Code (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'city', IDYSTransportOrderHeader."City (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'state', IDYSTransportOrderHeader."County (Pick-up)");
        if IDYSTransportOrderHeader."Mobile Phone No. (Pick-up)" <> '' then
            IDYMJSONHelper.AddValue(Address, 'phone', IDYSTransportOrderHeader."Mobile Phone No. (Pick-up)")
        else
            IDYMJSONHelper.AddValue(Address, 'phone', IDYSTransportOrderHeader."Phone No. (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'email', IDYSTransportOrderHeader."E-Mail (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'country', IDYSTransportOrderHeader."Cntry/Rgn. Code (Pick-up) (TS)");  //External Country Code / ISO 3166

        IDYMJSONHelper.Add(Document, 'from_address', Address);
        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitDocumentFromIDYSTransportOrderHeader(Document, IDYSTransportOrderHeader);
    end;

    local procedure InitDeliveryNotesFromTransportOrderDeliveryNotes(var document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        DummyTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        InitDeliveryNotesFromTransportOrderDeliveryNotes(document, IDYSTransportOrderHeader, DummyTransportOrderPackage);
    end;

    local procedure InitDeliveryNotesFromTransportOrderDeliveryNotes(var document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package");
    var
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        DummyRecId: RecordId;
        CustomsInfoObject: JsonObject;
        CustomsItemsArr: JsonArray;
        CustomsItem: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitDeliveryNotesFromTransportOrderDeliveryNotes(Document, IDYSTransportOrderHeader, IDYSTransportOrderPackage, IsHandled);
            if IsHandled then
                exit;
        end;

        IDYMJSONHelper.AddValue(CustomsInfoObject, 'contents_type', "IDYS EasyPost Contents Type".Names().Get("IDYS EasyPost Contents Type".Ordinals().IndexOf(IDYSTransportOrderHeader."Contents Type".AsInteger())));
        if IDYSTransportOrderHeader."Contents Type" = IDYSTransportOrderHeader."Contents Type"::other then
            IDYMJSONHelper.AddValue(CustomsInfoObject, 'contents_explanation', IDYSTransportOrderHeader."Contents Explanation");
        IDYMJSONHelper.AddValue(CustomsInfoObject, 'customs_certify', IDYSTransportOrderHeader."Customs Certify");
        IDYMJSONHelper.AddValue(CustomsInfoObject, 'customs_signer', IDYSTransportOrderHeader."Customs Signer");
        IDYMJSONHelper.AddValue(CustomsInfoObject, 'non_delivery_option', LowerCase(Format(IDYSTransportOrderHeader."Non Delivery Options")));
        IDYMJSONHelper.AddValue(CustomsInfoObject, 'eel_pfc', IDYSTransportOrderHeader."EEL / PFC");

        IDYMJSONHelper.AddValue(CustomsInfoObject, 'restriction_type', "IDYS EasyPost Restriction Type".Names().Get("IDYS EasyPost Restriction Type".Ordinals().IndexOf(IDYSTransportOrderHeader."Restriction Type".AsInteger())));
        if IDYSTransportOrderHeader."Restriction Type" <> IDYSTransportOrderHeader."Restriction Type"::none then
            IDYMJSONHelper.AddValue(CustomsInfoObject, 'restriction_comments', IDYSTransportOrderHeader."Restriction Comments");

        if IDYSTransportOrderPackage.RecordId <> DummyRecId then begin  // With sales header (Temp TO) this case will always be false
            IDYSTransportOrderDelNote.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
            IDYSTransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", IDYSTransportOrderPackage.RecordId);
            if IDYSTransportOrderDelNote.FindSet() then
                repeat
                    Clear(CustomsItem);
                    IDYMJSONHelper.AddValue(CustomsItem, 'description', IDYSTransportOrderDelNote.Description);
                    IDYMJSONHelper.AddValue(CustomsItem, 'quantity', IDYSTransportOrderDelNote.Quantity);
                    IDYMJSONHelper.AddValue(CustomsItem, 'value', IDYSTransportOrderDelNote.Price * IDYSTransportOrderDelNote.Quantity);
                    IDYMJSONHelper.AddValue(CustomsItem, 'weight', Round(IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.") * IDYSTransportOrderDelNote."Gross Weight" * IDYSTransportOrderDelNote.Quantity, IDYSProviderMgt.GetRoundingPrecision("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.")));
                    IDYMJSONHelper.AddValue(CustomsItem, 'hs_tariff_number', IDYSTransportOrderDelNote."HS Code");
                    IDYMJSONHelper.AddValue(CustomsItem, 'origin_country', IDYSTransportOrderDelNote."Country of Origin");
                    IDYMJSONHelper.AddValue(CustomsItem, 'code', IDYSTransportOrderDelNote."Article Id");  // SKU/UPC or other product identifier

                    if IDYSSessionVariables.CheckAuthorization() then
                        OnBeforeAddCustomItem(IDYSTransportOrderHeader, IDYSTransportOrderPackage, IDYSTransportOrderDelNote, CustomsItem);
                    IDYMJSONHelper.Add(CustomsItemsArr, CustomsItem);
                until IDYSTransportOrderDelNote.Next() = 0;
        end;

        IDYMJSONHelper.Add(CustomsInfoObject, 'customs_items', CustomsItemsArr);
        IDYMJSONHelper.Add(Document, 'customs_info', CustomsInfoObject);

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitDeliveryNotesFromTransportOrderDeliveryNotes(Document, IDYSTransportOrderHeader);
    end;

    procedure UpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateStatus(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter(Status, '<>%1', 'delivered');
        if TransportOrderPackage.IsEmpty() then begin
            IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::Done);
            exit;
        end;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter(Status, '<>%1', '');
        if TransportOrderPackage.IsEmpty() then begin
            IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::New);
            exit;
        end;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter(Status, '%1|%2|%3|%4', 'unknown', 'pre_transit', 'in_transit', 'out_for_delivery');
        if not TransportOrderPackage.IsEmpty() then begin
            if IDYSTransportOrderHeader.Status <> IDYSTransportOrderHeader.Status::"Label Printed" then
                IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::Booked);
            exit;
        end;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter(Status, '%1', 'failure');
        if not TransportOrderPackage.IsEmpty() then begin
            IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::Error);
            exit;
        end;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter(Status, '%1|%2', 'return_to_sender', 'cancelled');
        if not TransportOrderPackage.IsEmpty() then begin
            IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::Recalled);
            exit;
        end;
    end;

    procedure OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        Hyperlink(TransportOrderHeader."Tracking Url");
    end;

    procedure OpenAllInDashboard();
    var
        EasyPostDashboardUrlTxt: label 'https://www.easypost.com/account/shipments', Locked = true;
    begin
        Hyperlink(EasyPostDashboardUrlTxt);
    end;

    procedure IsBookable(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        if TransportOrderHeader.Status in [TransportOrderHeader.Status::New] then
            exit(true);
    end;

    procedure IsRebookable(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(false);
    end;

    procedure DeleteAllowed(): Boolean
    begin
        exit(false);
    end;

    #region [Printing]
    procedure DoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") Printed: Boolean
    var
        Response: JsonToken;
    begin
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
        CheckPrintingConditions(IDYSTransportOrderHeader);
        Printed := IDYSProviderMgt.PrintLabel(IDYSTransportOrderHeader);
    end;

    procedure TryDoPackageLabel(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package") Printed: Boolean
    var
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeTryDoPackageLabel(IDYSTransportOrderPackage, Printed, IsHandled);
            if IsHandled then
                exit(Printed);
        end;

        IDYSTransportOrderHeader.Get(IDYSTransportOrderPackage."Transport Order No.");
        if not IDYSProviderMgt.IsPrintITEnabled(IDYSTransportOrderHeader.Provider) then
            exit(false);

        CheckPrintingConditions(IDYSTransportOrderHeader);
        IDYSProviderMgt.PrintLabel(IDYSTransportOrderPackage, Printed);
    end;

    local procedure CheckPrintingConditions(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        if not (IDYSTransportOrderHeader.Status in [
            IDYSTransportOrderHeader.Status::Uploaded,
            IDYSTransportOrderHeader.Status::Booked,
            IDYSTransportOrderHeader.Status::"Label Printed"])
        then
            IDYSTransportOrderHeader.FieldError(Status);
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Printed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTryDoPackageLabel(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var Printed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterPrinting(Response: JsonToken; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;
    #endregion

    #region [Get Setup]
    local procedure GetSetup(): Boolean
    begin
        if not SetupLoaded then
            SetupLoaded := IDYSSetup.Get();

        if not ProviderSetupLoaded then begin
            IDYSEasyPostSetup.GetProviderSetup("IDYS Provider"::EasyPost);
            ProviderSetupLoaded := true;
        end;

        exit(SetupLoaded);
    end;
    #endregion

    #region [Obsolete]
    [Obsolete('Authorization is now associated with the license key', '23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnSetAuthorization(var Authorization: Guid)
    begin
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(CreateAndBookDocument(IDYSTransportOrderHeader, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean) ReturnValue: Boolean
    begin
        exit(CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetShipmentAdditionalInformation(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes") ReturnValue: JsonObject
    begin
        exit(GetShipmentAdditionalInformation(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure DoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
        exit(DoLabel(IDYSTransportOrderHeader));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure TryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken) Printed: Boolean
    begin
        exit(TryDoLabel(IDYSTransportOrderHeader, Response));
    end;
    #endregion

    #region [Integration Events]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSelectCarrierFromTemp(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; var ReturnValue: JsonArray; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; var ReturnValue: JsonArray; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitSelectCarrierOnBeforeAddTransportOrderPackage(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var TransportOrderPackage: Record "IDYS Transport Order Package"; var Document: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitSelectCarrierOnBeforeAddSourceDocument(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var SourceDocumentPackage: Record "IDYS Source Document Package")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitOptions(var RequestDocument: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitOptions(var RequestDocument: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var Options: JsonObject)
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
    local procedure OnBeforeIsPackageApplicable(var IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping"; Package: JsonToken; LineNo: Integer; var CreatedEntry: Boolean; var IsHandled: Boolean)
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
    local procedure OnBeforeUpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterCreateShipment(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; ResponseDocument: JsonObject; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterCreateShipmentFromSourceDoc(var IDYSSourceDocumentPackage: Record "IDYS Source Document Package"; ResponseDocument: JsonObject; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSaveShippingRates(ResponseDocument: JsonObject; var IDYSEasyPostShippingRate: Record "IDYS EasyPost Shipping Rate"; Rate: JsonToken; var IsHandled: Boolean; var DefaultRateId: Text[100])
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
    local procedure OnBeforeModifyTransportOrderPackage(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; ResponseDocument: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateAndBookDocumentOnBeforeInsertParcelDocument(var IDYSSCParcelDocument: Record "IDYS SC Parcel Document"; ResponseDocument: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('Unused', '22.10')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterRetrieveShipment(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; AllowLogging: Boolean; Response: JsonObject)
    begin
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
    local procedure OnBeforeInitDeliveryNotesFromTransportOrderDeliveryNotes(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDeliveryNotesFromTransportOrderDeliveryNotes(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddCustomItem(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note"; var CustomsItem: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSelectCarrierOnBeforeProviderCarrierSelectInsert(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetShipmentAdditionalInformation(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; var ReturnValue: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetShipmentAdditionalInformationOnBeforeTransportOrderPackageModify(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; var ReturnValue: JsonObject; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package")
    begin
    end;
    #endregion
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSEasyPostSetup: Record "IDYS Setup";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        IDYMAppHub: Codeunit "IDYM Apphub";
        IDYSEasyPostErrorHandler: Codeunit "IDYS EasyPost Error Handler";
        IDYSLoggingHelper: Codeunit "IDYS Logging Helper";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        SetupLoaded: Boolean;
        PostDocumentSucceeeded: Boolean;
        ProviderSetupLoaded: Boolean;
        DummyJsonObject: JsonObject;
        BookingTxt: Label 'Booking';
        ErrorCreateShipmentTxt: Label 'Error while booking the shipment';
        ErrorBuyShipmentTxt: Label 'Error while buying the shipment';
        ErrorSyncShipmentTxt: Label 'Error while retrieving the shipment';
        UploadedTxt: Label 'Uploaded to EasyPost';
        UpdatedTxt: Label 'Updated from EasyPost';
        LoggingLevel: Enum "IDYS Logging Level";
        HttpStatusCode: Integer;
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        MissingPackagesErr: Label 'You cannot use the carrier selection without specifying packages.';
        NotTempororaryErr: Label 'Parameter %1 is not temporary', Comment = '%1 = parameter name';
        NotMappedServiceTxt: Label 'Service must be mapped on the Shipping Agent Mapping page.';
        NonApplicableServiceTxt: Label 'Service cannot be used with the current packages. Please use the carrier selection.';
        LabelPrintedTxt: Label 'Label printed';
}