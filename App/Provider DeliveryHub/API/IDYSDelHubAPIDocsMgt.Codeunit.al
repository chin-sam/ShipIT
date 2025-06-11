codeunit 11147717 "IDYS DelHub API Docs. Mgt."
{
    local procedure InitDocumentFromIDYSTransportOrderHeader(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        IDYSCurrencyMapping: Record "IDYS Currency Mapping";
        ShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSSourceDocumentService: Record "IDYS Source Document Service";
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
        Services: JsonArray;
        Addresses: JsonArray;
        Address: JsonObject;
        References: JsonArray;
        Reference: JsonObject;
        Amount: JsonObject;
        Amounts: JsonArray;
        Message: JsonObject;
        Messages: JsonArray;
        IsHandled: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitDocumentFromIDYSTransportOrderHeader(Document, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        //   0 - eSkUnknown, 1 - eSkNormal, 2 - eSkComeback, 3 - eSkGroup
        IDYMJSONHelper.AddValue(Document, 'Kind', 1);
        IDYMJSONHelper.AddValue(Document, 'ActorCSID', GetCurrentActor(IDYSTransportOrderHeader));
        if IDYSShipAgentSvcMapping.Get(IDYSTransportOrderHeader."Shipping Agent Code", IDYSTransportOrderHeader."Shipping Agent Service Code") then
            if IDYSProviderBookingProfile.Get(IDYSShipAgentSvcMapping."Booking Profile Entry No.", IDYSShipAgentSvcMapping."Carrier Entry No.") then
                IDYMJSONHelper.AddValue(Document, 'ProdCSID', IDYSProviderBookingProfile.ProdCSID);

        // Services
        IDYSSourceDocumentService.SetRange("Table No.", Database::"IDYS Transport Order Header");
        IDYSSourceDocumentService.SetRange("Document No.", IDYSTransportOrderHeader."No.");
        if IDYSSourceDocumentService.FindSet() then begin
            repeat
                if IDYSServiceLevelOther.Get(IDYSSourceDocumentService."Service Level Code (Other)") then
                    Services.Add(IDYSServiceLevelOther.ServiceID);
            until IDYSSourceDocumentService.Next() = 0;
            IDYMJSONHelper.Add(Document, 'Services', Services);
        end;

        // OrderNo
        if IDYSTransportOrderHeader."Customer Order (Ref)" <> '' then
            IDYMJSONHelper.AddValue(Document, 'OrderNo', IDYSTransportOrderHeader."Customer Order (Ref)")
        else
            if IDYSTransportOrderHeader."Delivery Id (Ref)" <> '' then
                IDYMJSONHelper.AddValue(Document, 'OrderNo', IDYSTransportOrderHeader."Delivery Id (Ref)")
            else
                IDYMJSONHelper.AddValue(Document, 'OrderNo', IDYSTransportOrderHeader."No.");

        #region [Amounts]
        //  2 - eSamkPrice2 - Spot Price
        if IDYSTransportOrderHeader."Spot Pr." <> 0 then begin
            Clear(Amount);
            IDYMJSONHelper.AddValue(Amount, 'Kind', 2);
            IDYMJSONHelper.AddValue(Amount, 'CurrencyCode', IDYSTransportOrderHeader."Spot Price Curr Code (TS)");
            IDYMJSONHelper.AddValue(Amount, 'Value', IDYSTransportOrderHeader."Spot Pr.");
            IDYMJSONHelper.Add(Amounts, Amount);
            IDYMJSONHelper.Add(Document, 'Amounts', Amounts);
        end;

        //  10 - eSamkInvoiceAmount
        if IDYSTransportOrderHeader."Shipmt. Value" <> 0 then begin
            Clear(Amount);
            IDYMJSONHelper.AddValue(Amount, 'Kind', 10);
            if IDYSCurrencyMapping.Get(IDYSTransportOrderHeader."Shipment Value Curr Code") then
                IDYMJSONHelper.AddValue(Amount, 'CurrencyCode', IDYSCurrencyMapping."Currency Value");
            IDYMJSONHelper.AddValue(Amount, 'Value', IDYSTransportOrderHeader."Shipmt. Value");
            IDYMJSONHelper.Add(Amounts, Amount);
            IDYMJSONHelper.Add(Document, 'Amounts', Amounts);
        end;
        #endregion

        #region [Messages]
        Clear(Messages);
        if IDYSTransportOrderHeader.Instruction <> '' then begin
            Clear(Message);
            IDYMJSONHelper.AddValue(Message, 'Kind', 2);
            IDYMJSONHelper.AddValue(Message, 'Text', IDYSTransportOrderHeader.Instruction);
            IDYMJSONHelper.Add(Messages, Message);
            IDYMJSONHelper.Add(Document, 'Messages', Messages);
        end;
        #endregion

        #region [Addresses]        
        CreateAddressFromTransportOrder(Addresses, IDYSTransportOrderHeader, 1); // 1 - Receiver
        CreateAddressFromTransportOrder(Addresses, IDYSTransportOrderHeader, 2); // 2 - Sender
        // 4 - Payer
        if ShipAgentMapping.Get(IDYSTransportOrderHeader."Shipping Agent Code") then;
        if not ShipAgentMapping."Blank Invoice Address" then
            CreateAddressFromTransportOrder(Addresses, IDYSTransportOrderHeader, 4);

        // 10 - eSakDropPoint
        if IDYSTransportOrderHeader."Service Point (Ref)" <> '' then begin
            Clear(Address);
            IDYMJSONHelper.AddValue(Address, 'Kind', 10);
            IDYMJSONHelper.AddValue(Address, 'CustNo', IDYSTransportOrderHeader."Service Point (Ref)");
            IDYMJSONHelper.Add(Addresses, Address);
        end;

        IDYMJSONHelper.Add(Document, 'Addresses', Addresses);
        #endregion

        #region [References]
        Clear(References);

        // 5 - eSrkProjectName
        if IDYSTransportOrderHeader."Project (Ref)" <> '' then begin
            Clear(Reference);
            IDYMJSONHelper.AddValue(Reference, 'Kind', 5);
            IDYMJSONHelper.AddValue(Reference, 'Value', IDYSTransportOrderHeader."Project (Ref)");
            IDYMJSONHelper.Add(References, Reference);
        end;

        // 7 - eSrkReceiverReference
        if IDYSTransportOrderHeader."Your Reference (Ref)" <> '' then begin
            Clear(Reference);
            IDYMJSONHelper.AddValue(Reference, 'Kind', 7);
            IDYMJSONHelper.AddValue(Reference, 'Value', IDYSTransportOrderHeader."Your Reference (Ref)");
            IDYMJSONHelper.Add(References, Reference);
        end;

        // 32 - eSrkOrderNumberAdditional
        if IDYSTransportOrderHeader."Order No. (Ref)" <> '' then begin
            Clear(Reference);
            IDYMJSONHelper.AddValue(Reference, 'Kind', 32);
            IDYMJSONHelper.AddValue(Reference, 'Value', IDYSTransportOrderHeader."Order No. (Ref)");
            IDYMJSONHelper.Add(References, Reference);
        end;

        // 63 - eSrkCustomField1
        if IDYSTransportOrderHeader."Other (Ref)" <> '' then begin
            Clear(Reference);
            IDYMJSONHelper.AddValue(Reference, 'Kind', 63);
            IDYMJSONHelper.AddValue(Reference, 'Value', IDYSTransportOrderHeader."Other (Ref)");
            IDYMJSONHelper.Add(References, Reference);
        end;

        // 108 - eSrkPickupStartDatetime
        if IDYSTransportOrderHeader."Preferred Pick-up Date From" <> 0DT then begin
            Clear(Reference);
            IDYMJSONHelper.AddValue(Reference, 'Kind', 108);
            IDYMJSONHelper.AddValue(Reference, 'Value', IDYSTransportOrderHeader."Preferred Pick-up Date From");
            IDYMJSONHelper.Add(References, Reference);
        end;

        // 109 - eSrkPickupEndDatetime
        if IDYSTransportOrderHeader."Preferred Pick-up Date To" <> 0DT then begin
            Clear(Reference);
            IDYMJSONHelper.AddValue(Reference, 'Kind', 109);
            IDYMJSONHelper.AddValue(Reference, 'Value', IDYSTransportOrderHeader."Preferred Pick-up Date To");
            IDYMJSONHelper.Add(References, Reference);
        end;

        // 110 - eSrkDeliveryStartDatetime
        if IDYSTransportOrderHeader."Preferred Delivery Date From" <> 0DT then begin
            Clear(Reference);
            IDYMJSONHelper.AddValue(Reference, 'Kind', 110);
            IDYMJSONHelper.AddValue(Reference, 'Value', IDYSTransportOrderHeader."Preferred Delivery Date From");
            IDYMJSONHelper.Add(References, Reference);
        end;

        // 110 - eSrkDeliveryEndDatetime
        if IDYSTransportOrderHeader."Preferred Delivery Date To" <> 0DT then begin
            Clear(Reference);
            IDYMJSONHelper.AddValue(Reference, 'Kind', 111);
            IDYMJSONHelper.AddValue(Reference, 'Value', IDYSTransportOrderHeader."Preferred Delivery Date To");
            IDYMJSONHelper.Add(References, Reference);
        end;

        IDYMJSONHelper.Add(Document, 'References', References);
        #endregion

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitDocumentFromIDYSTransportOrderHeader(Document, IDYSTransportOrderHeader);
    end;

    procedure InitPackagesFromSourceDocPackages(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SourceDocumentPackage: Record "IDYS Source Document Package";
        Lines: JsonArray;
        Line: JsonObject;
        Reference: JsonObject;
        References: JsonArray;
        ContentValue: Text;
        IsHandled: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitPackagesFromSourceDoc(Document, IDYSTransportOrderHeader, SalesHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        SourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        SourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        SourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");

        if SourceDocumentPackage.FindSet() then
            repeat
                Clear(Line);
                IDYMJSONHelper.AddValue(Line, 'Number', 1);
                IDYMJSONHelper.AddValue(Line, 'PkgWeight', SourceDocumentPackage."Total Weight");
                IDYMJSONHelper.AddValue(Line, 'Height', SourceDocumentPackage.Height);
                IDYMJSONHelper.AddValue(Line, 'Length', SourceDocumentPackage.Length);
                IDYMJSONHelper.AddValue(Line, 'Width', SourceDocumentPackage.Width);
                IDYMJSONHelper.AddValue(Line, 'GoodsTypeID', SourceDocumentPackage."Provider Package Type Code");
                if SourceDocumentPackage."Load Meter" <> 0 then
                    IDYMJSONHelper.AddValue(Line, 'Loadmeter', SourceDocumentPackage."Load Meter");

                #region [References]
                Clear(References);

                Clear(Reference);
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if SalesLine.FindFirst() then
                    ContentValue := SalesLine.Description;
                if ContentValue = '' then
                    ContentValue := 'Missing Content Value';

                IDYMJSONHelper.AddValue(Reference, 'Kind', 23);
                IDYMJSONHelper.AddValue(Reference, 'Value', ContentValue);  // Line content - Contents, is what is in the moved goods. Could be something like, textiles, medical equipment, toys, electronics. Not for customs, but simply to tell the carrier what they are moving. It is mandatory for many carriers, but not all.
                IDYMJSONHelper.Add(References, Reference);

                Clear(Reference);
                IDYMJSONHelper.AddValue(Reference, 'Kind', 24);
                IDYMJSONHelper.AddValue(Reference, 'Value', SourceDocumentPackage."Line No.");
                IDYMJSONHelper.Add(References, Reference);


                IDYMJSONHelper.Add(Line, 'References', References);
                IDYMJSONHelper.Add(Lines, Line);
            #endregion
            until SourceDocumentPackage.Next() = 0;
        IDYMJSONHelper.Add(Document, 'Lines', Lines);
        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitPackagesFromSourceDoc(Document, IDYSTransportOrderHeader, SalesHeader);
    end;

    local procedure InitPackagesFromTransportOrderPackages(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        IDYSTransportOrderLine: Record "IDYS Transport Order Line";
        Lines: JsonArray;
        Line: JsonObject;
        Reference: JsonObject;
        References: JsonArray;
        ContentValue: Text;
        IsHandled: Boolean;
    begin
        GetSetup();
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitPackagesFromTransportOrderPackages(Document, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if TransportOrderPackage.FindSet() then
            repeat
                Clear(Line);
                IDYMJSONHelper.AddValue(Line, 'Number', 1);
                IDYMJSONHelper.AddValue(Line, 'PkgWeight', TransportOrderPackage.GetPackageWeight());
                IDYMJSONHelper.AddValue(Line, 'Height', TransportOrderPackage.Height);
                IDYMJSONHelper.AddValue(Line, 'Length', TransportOrderPackage.Length);
                IDYMJSONHelper.AddValue(Line, 'Width', TransportOrderPackage.Width);
                IDYMJSONHelper.AddValue(Line, 'GoodsTypeID', TransportOrderPackage."Provider Package Type Code");
                if TransportOrderPackage."Load Meter" <> 0 then
                    IDYMJSONHelper.AddValue(Line, 'Loadmeter', TransportOrderPackage."Load Meter");

                #region [References]
                Clear(References);

                Clear(Reference);
                IDYSTransportOrderDelNote.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
                if IDYSTransportOrderDelNote.FindFirst() then
                    ContentValue := IDYSTransportOrderDelNote.Description
                else begin
                    IDYSTransportOrderLine.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
                    if IDYSTransportOrderLine.FindFirst() then
                        ContentValue := IDYSTransportOrderLine.Description;
                end;
                if ContentValue = '' then
                    ContentValue := 'Missing Content Value';

                IDYMJSONHelper.AddValue(Reference, 'Kind', 23);
                IDYMJSONHelper.AddValue(Reference, 'Value', ContentValue);  // Line content - Contents, is what is in the moved goods. Could be something like, textiles, medical equipment, toys, electronics. Not for customs, but simply to tell the carrier what they are moving. It is mandatory for many carriers, but not all.
                IDYMJSONHelper.Add(References, Reference);

                Clear(Reference);
                IDYMJSONHelper.AddValue(Reference, 'Kind', 24);
                IDYMJSONHelper.AddValue(Reference, 'Value', TransportOrderPackage."Line No.");
                IDYMJSONHelper.Add(References, Reference);


                IDYMJSONHelper.Add(Line, 'References', References);
                IDYMJSONHelper.Add(Lines, Line);
            #endregion
            until TransportOrderPackage.Next() = 0;

        IDYMJSONHelper.Add(Document, 'Lines', Lines);
        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitPackagesFromTransportOrderPackages(Document, IDYSTransportOrderHeader);
    end;

    local procedure InitDeliveryNotesFromTransportOrderDeliveryNotes(var document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        IDYSTransportOrderLine: Record "IDYS Transport Order Line";
        xTransportOrderPackageRecId: RecordId;
        DetailGroups: JsonArray;
        CustomsArticleObject: JsonObject;
        CustomsInfoObject: JsonObject;
        Row: JsonObject;
        Rows: JsonArray;
        Details: JsonArray;
        DetailsLine: JsonObject;
        RowNo: Integer;
        PackageLineNo: Integer;
        IsHandled: Boolean;
        ShipmentValue: Decimal;
    begin
        /*
            DetailGroupKind
                0	DgrkUnknown	 
                1	DgrkCustomsArticle	 
                2	DgrkCustomsInfo	 
                4	DgrkFedExCustomsInformation	 
                5	DrgkDHLFiling	 
                6	OrderData
        */
        GetSetup();
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitDeliveryNotesFromTransportOrderDeliveryNotes(Document, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        // 1 - DgrkCustomsArticle
        RowNo := 0;
        PackageLineNo := 0;
        Clear(xTransportOrderPackageRecId);
        IDYMJSONHelper.AddValue(CustomsArticleObject, 'GroupID', 1);

        IDYSTransportOrderDelNote.SetCurrentKey("Transport Order Pkg. Record Id");
        IDYSTransportOrderDelNote.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderDelNote.FindSet() then
            repeat
                Clear(Row);
                Clear(Details);
                RowNo += 1;
                IDYSTransportOrderLine.Get(IDYSTransportOrderDelNote."Transport Order No.", IDYSTransportOrderDelNote."Transport Order Line No.");

                if IDYSSetup."Link Del. Lines with Packages" then begin
                    if xTransportOrderPackageRecId <> IDYSTransportOrderDelNote."Transport Order Pkg. Record Id" then begin
                        RowNo := 1;
                        PackageLineNo += 1;
                    end;

                    xTransportOrderPackageRecId := IDYSTransportOrderDelNote."Transport Order Pkg. Record Id";
                    IDYMJSONHelper.AddValue(Row, 'LineNo', PackageLineNo);
                end;
                IDYMJSONHelper.AddValue(Row, 'RowNo', RowNo);

                // eDekArticleNo
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 1);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderDelNote."Article Id");
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekUnitValue
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 2);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderDelNote.Price);
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekTariffCode
                if IDYSTransportOrderDelNote."HS Code" <> '' then begin
                    Clear(DetailsLine);
                    IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 3);
                    IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderDelNote."HS Code");
                    IDYMJSONHelper.Add(Details, DetailsLine);
                end;

                // eDekCountryOfOrigin
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 4);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderDelNote."Country of Origin");
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekQuantity
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 5);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderDelNote.Quantity);
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekUnitWeight
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 6);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', Round(IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.") * IDYSTransportOrderDelNote."Gross Weight", IDYSProviderMgt.GetRoundingPrecision("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.")));
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekDescrOfGoods
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 7);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderDelNote.Description);
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekUnitOfMeasure
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 8);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', GetMappedUnitOfMeasure(IDYSTransportOrderLine."Unit of Measure Code"));
                //Take unit of measure from the transport order line
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekTotalWeight
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 9);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', Round(IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.") * IDYSTransportOrderDelNote."Gross Weight" * IDYSTransportOrderDelNote.Quantity, IDYSProviderMgt.GetRoundingPrecision("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.")));
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekTotalValue
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 10);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderDelNote.Price * IDYSTransportOrderDelNote.Quantity);
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekCustomsValue
                if IDYSTransportOrderDelNote.Price <> 0 then begin
                    Clear(DetailsLine);
                    IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 16);
                    IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderDelNote.Price);
                    IDYMJSONHelper.Add(Details, DetailsLine);
                end;

                // eDekCustomsArticleCurrency
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 17);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)");
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekCustomsArticleCommodityCode
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 18);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderDelNote."HS Code");
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekNettoWeight
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 36);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', Round(IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.") * IDYSTransportOrderDelNote."Net Weight" * IDYSTransportOrderDelNote.Quantity, IDYSProviderMgt.GetRoundingPrecision("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.")));
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekProductCode
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 186);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderDelNote."Serial No.");
                IDYMJSONHelper.Add(Details, DetailsLine);

                // eDekWeightUOM
                Clear(DetailsLine);
                IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 517);
                IDYMJSONHelper.AddValue(DetailsLine, 'Value', 'g');
                IDYMJSONHelper.Add(Details, DetailsLine);

                IDYMJSONHelper.Add(Row, 'Details', Details);
                IDYMJSONHelper.Add(Rows, Row);
            until IDYSTransportOrderDelNote.Next() = 0;
        IDYMJSONHelper.Add(CustomsArticleObject, 'Rows', Rows);
        IDYMJSONHelper.Add(DetailGroups, CustomsArticleObject);

        // 2 - DgrkCustomsInfo
        RowNo := 0;
        PackageLineNo := 0;
        Clear(xTransportOrderPackageRecId);
        Clear(Rows);
        Clear(Details);
        IDYMJSONHelper.AddValue(CustomsInfoObject, 'GroupID', 2);

        // eDekInvoiceNumber
        Clear(DetailsLine);
        IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 19);
        if IDYSTransportOrderHeader."Invoice (Ref)" <> '' then
            IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderHeader."Invoice (Ref)")
        else
            IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderHeader."No.");
        IDYMJSONHelper.Add(Details, DetailsLine);

        // eDekReasonForExport
        if IDYSTransportOrderHeader."Reason of Export" <> '' then begin
            Clear(DetailsLine);
            IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 20);
            IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderHeader."Reason of Export");
            IDYMJSONHelper.Add(Details, DetailsLine);
        end;

        // eDekCustomsInfoCurrency
        if IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)" <> '' then begin
            Clear(DetailsLine);
            IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 21);
            IDYMJSONHelper.AddValue(DetailsLine, 'Value', IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)");
            IDYMJSONHelper.Add(Details, DetailsLine);
        end;

        // eDekChargesValue
        if IDYSTransportOrderHeader."Shipmt. Value" <> 0 then
            ShipmentValue := IDYSTransportOrderHeader."Shipmt. Value"
        else begin
            IDYSTransportOrderHeader.CalcFields("Calculated Shipment Value");
            ShipmentValue := IDYSTransportOrderHeader."Calculated Shipment Value";
        end;

        if ShipmentValue <> 0 then begin
            Clear(DetailsLine);
            IDYMJSONHelper.AddValue(DetailsLine, 'KindID', 29);

            IDYMJSONHelper.AddValue(DetailsLine, 'Value', ShipmentValue);
            IDYMJSONHelper.Add(Details, DetailsLine);
        end;

        IDYMJSONHelper.Add(CustomsInfoObject, 'Details', Details);
        IDYMJSONHelper.Add(DetailGroups, CustomsInfoObject);

        IDYMJSONHelper.Add(Document, 'DetailGroups', DetailGroups);
        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitDeliveryNotesFromTransportOrderDeliveryNotes(Document, IDYSTransportOrderHeader);
    end;

    #region [Synchronize]
    procedure GetShipmentAdditionalInformation(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean): JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        StatusId: Integer;
        Document: JsonObject;
        EmptyRequestDocument: JsonObject;
        StatusLine: JsonToken;
        Status: JsonObject;
        EndpointTxt: Label '/shipments/%1/additional-information', Locked = true;
        IsHandled: Boolean;
    begin
        GetSetup();
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters."Acceptance Environment" := IDYSDeliveryHubSetup."Transsmart Environment" = IDYSDeliveryHubSetup."Transsmart Environment"::Acceptance;
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, DelChr(IDYSTransportOrderHeader."Shipment Tag", '<>', '{}'));

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::DeliveryHubData, "IDYM Endpoint Usage"::Default);

        if not ((TempIDYMRESTParameters."Status Code" in [200, 201]) or (TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject())) then begin
            if TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject() then begin
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", ErrorSynchronizeTxt, LoggingLevel::Error, EmptyRequestDocument, TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
                Commit();
            end;
            IDYSDelHubErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;

        Document := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();

        if WriteLogEntry then begin
            if IDYSSetup."Enable Debug Mode" then
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", SynchronizeTxt, LoggingLevel::Information, EmptyRequestDocument, Document)
            else
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", SynchronizeTxt, LoggingLevel::Information);
            Commit();
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterGetShipmentAdditionalInfo(Document.AsToken(), IDYSTransportOrderHeader, UpdateHeader, IsHandled);
        if not IsHandled then begin
            foreach StatusLine in IDYMJSONHelper.GetArray(Document, 'latestStatuses') do begin
                Status := IDYMJSONHelper.GetObject(StatusLine, 'status');
                StatusId := IDYMJSONHelper.GetIntegerValue(Status.AsToken(), 'normalizedStatusId');

                if (IDYMJSONHelper.GetTextValue(StatusLine, 'shipmentUuid') <> '') then
                    if (IDYMJSONHelper.GetTextValue(StatusLine, 'packageUuid') = '') then begin
                        IDYSTransportOrderHeader."Status (External)" := CopyStr(GetStatus(StatusId), 1, MaxStrLen(IDYSTransportOrderHeader."Status (External)"));
                        IDYSTransportOrderHeader."Sub Status (External)" := CopyStr(GetStatusDescription(StatusId), 1, MaxStrLen(IDYSTransportOrderPackage."Sub Status (External)"));
                    end else begin
                        IDYSTransportOrderPackage.Reset();
                        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
                        IDYSTransportOrderPackage.SetRange("Package Tag", IDYMJSONHelper.GetGuidValue(StatusLine, 'packageUuid'));
                        if IDYSTransportOrderPackage.FindFirst() then begin
                            IDYSTransportOrderPackage.Status := CopyStr(GetStatus(StatusId), 1, MaxStrLen(IDYSTransportOrderPackage.Status));
                            IDYSTransportOrderPackage."Sub Status (External)" := CopyStr(GetStatusDescription(StatusId), 1, MaxStrLen(IDYSTransportOrderPackage."Sub Status (External)"));
                            IDYSTransportOrderPackage.Modify(true);
                        end;
                    end;
            end;
            UpdateStatus(IDYSTransportOrderHeader);
            if IDYSSessionVariables.CheckAuthorization() then
                OnGetShipmentAdditionalInformationOnBeforeModifySalesHeader(Document.AsToken(), IDYSTransportOrderHeader, UpdateHeader);
            IDYSTransportOrderHeader.Modify(true);
            if IDYSSessionVariables.CheckAuthorization() then
                OnGetShipmentAdditionalInformationOnAfterModifySalesHeader(Document.AsToken(), IDYSTransportOrderHeader, UpdateHeader);
        end;
        if WriteLogEntry then
            IDYSTransportOrderHeader.CreateLogEntry(UpdatedTxt, LoggingLevel::Information);

        exit(Document);
    end;

    procedure UpdateStatus(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IsHandled: Boolean;
    begin
        OnBeforeUpdateStatus(TransportOrderHeader, IsHandled);
        if IsHandled then
            exit;
        case TransportOrderHeader."Status (External)" of
            '', 'DH_UPLOAD':
                if not (TransportOrderHeader.Status in [TransportOrderHeader.Status::"Label Printed", TransportOrderHeader.Status::Recalled]) then
                    TransportOrderHeader.Status := TransportOrderHeader.Status::Uploaded;
            'DH_TRANS':
                if not (TransportOrderHeader.Status in [TransportOrderHeader.Status::"Label Printed", TransportOrderHeader.Status::Recalled]) then
                    TransportOrderHeader.Status := TransportOrderHeader.Status::Booked;
            'DH_DELIV':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Done;
            'DH_DELETED':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Recalled;
            'DH_C_EXC', 'DH_R_EXC', 'DH_S_EXC', 'ERROR':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Error;
        end;

        if (TransportOrderHeader.Status = TransportOrderHeader.Status::Uploaded) and (TransportOrderHeader."Tracking No." <> '') then
            TransportOrderHeader.Status := TransportOrderHeader.Status::Booked;

        TransportOrderHeader.Validate(Status);
        OnAfterUpdateStatus(TransportOrderHeader);
    end;

    local procedure GetStatus(StatusId: Integer): Text
    begin
        case StatusId of
            1002:
                exit('DH_DELETED'); // Deleted
            1000 .. 1999:
                exit('DH_UPLOAD'); // Uploaded 
            2000 .. 2999:
                exit('DH_TRANS'); // In Transit, Booked
            3000 .. 3999:
                exit('DH_DELIV'); // Delivered
            4000 .. 4999:
                exit('DH_INFO'); // Information
            5000 .. 5999:
                exit('DH_C_EXC'); // Carrier exception  
            6000 .. 6999:
                exit('DH_R_EXC'); // Receiver Exception
            7000 .. 7999:
                exit('DH_S_EXC'); // Sender Exception
            else
                exit('ERROR');  // Exception
        end;
    end;

    local procedure GetStatusDescription(StatusId: Integer): Text;
    begin
        case StatusId of
            1000:
                exit('Created');
            1001:
                exit('Transmit');
            1002:
                exit('Deleted');
            1003:
                exit('Internal');
            1004:
                exit('Customer advised');
            1005:
                exit('Undelete');
            1007:
                exit('Onboarded to container');
            1008:
                exit('Offboarded from container');
            2000:
                exit('In Transit');
            2001:
                exit('Out for delivery');
            2002:
                exit('Ready for pickup');
            2003:
                exit('Arrived at terminal/hub');
            2004:
                exit('Collected by carrier');
            2005:
                exit('Customs Clearance');
            2008:
                exit('Departed from terminal/hub');
            3000:
                exit('Delivered');
            3001:
                exit('Partially delivered');
            3002:
                exit('Carded');
            3003:
                exit('Delivered to neighbor');
            4000:
                exit('Other status');
            4001:
                exit('Update ETA');
            4002:
                exit('Change of address');
            4003:
                exit('Notification(s)/Advise');
            4004:
                exit('Booking information confirmed');
            4005:
                exit('Measurement/Price Update');
            5000:
                exit('Carrier Exception');
            5001:
                exit('Other incident');
            5002:
                exit('Delayed');
            5003:
                exit('Damaged');
            5004:
                exit('Change to delivery');
            5005:
                exit('Misrouted');
            5006:
                exit('Failed delivery attempt');
            5007:
                exit('Return to sender');
            5008:
                exit('Lost');
            5009:
                exit('Force majeure');
            6000:
                exit('Other incident');
            6001:
                exit('Return to sender');
            6002:
                exit('Customer refused');
            6003:
                exit('No property access');
            6004:
                exit('Delivery canceled');
            6005:
                exit('Carded');
            7000:
                exit('Other incident');
            7001:
                exit('Delivery canceled');
            7002:
                exit('Return to sender');
            7003:
                exit('Insufficient address');
            7004:
                exit('Missing booking info');
            else
                exit('Unknown');
        end;
    end;
    #endregion

    procedure GetTrackingURL(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Document: JsonObject;
        EndpointTxt: Label '/ShipServer/%1/shipments/%2/TrackingURL', Locked = true;
    begin
        GetSetup();
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters."Acceptance Environment" := IDYSDeliveryHubSetup."Transsmart Environment" = IDYSDeliveryHubSetup."Transsmart Environment"::Acceptance;
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, GetCurrentActor(IDYSTransportOrderHeader), DelChr(IDYSTransportOrderHeader."Shipment Tag", '<>', '{}'));

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::Default);

        Document := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
        exit(Document);
    end;

    procedure PostDocument(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Document: JsonObject; AllowLogging: Boolean): JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonObject;
        EndpointTxt: Label '/ShipServer/%1/shipments', Locked = true;
    begin
        GetSetup();

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters."Acceptance Environment" := IDYSDeliveryHubSetup."Transsmart Environment" = IDYSDeliveryHubSetup."Transsmart Environment"::Acceptance;
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, GetCurrentActor(IDYSTransportOrderHeader));
        TempIDYMRESTParameters.SetRequestContent(Document);

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::Default);

        PostDocumentSucceeeded := (TempIDYMRESTParameters."Status Code" = 201) and TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject();
        if not PostDocumentSucceeeded then begin
            if AllowLogging and TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject() then begin
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", ErrorBookingTxt, LoggingLevel::Error, Document, TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
                Commit();
            end;
            IDYSDelHubErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;

        Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
        exit(Response);
    end;

    //*****************************************
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

    local procedure InitPrinting(var Options: JsonObject)
    var
        IsHandled: Boolean;
    begin
        GetSetup();
        GetPrintingUserSetup();

        OnBeforeInitPrinting(Options, IsHandled);
        if IsHandled then
            exit;

        IDYSUserSetup.TestField("Label Type");
        if IDYSUserSetup."Enable Drop Zone Printing" then begin
            // if a printer is not found, base64 is returned
            IDYSUserSetup.TestField("Ticket Username");
            IDYSUserSetup.TestField("Workstation ID");
            IDYSUserSetup.TestField("Drop Zone Label Printer Key");
        end;

        // Options
        Options.Add('Labels', Format(IDYSUserSetup."Label Type"));
        if IDYSUserSetup."Enable Drop Zone Printing" then begin
            Options.Add('TicketUserName', IDYSUserSetup."Ticket Username");
            Options.Add('WorkstationID', IDYSUserSetup."Workstation ID");
            Options.Add('DropZoneLabelPrinterKey', IDYSUserSetup."Drop Zone Label Printer Key");
        end;
    end;

    #region CarrierSelect
    procedure InitCarrierSelection(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary) ReturnValue: JsonArray;
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        DataBodyJsonObject: JsonObject;
        CompletelyShippedErr: Label 'Order is completely shipped already.';
        AddPackageToSalesDocErr: Label 'Create a package for Sales %1 %2', Comment = '%1 = Document Type, %2 = Sales Document No.';
        IsHandled: Boolean;
    begin
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

        SourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        SourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        SourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
        if SourceDocumentPackage.IsEmpty() then
            Error(AddPackageToSalesDocErr, SalesHeader."Document Type", SalesHeader."No.");

        InitPackagesFromSourceDocPackages(DataBodyJsonObject, TempIDYSTransportOrderHeader, SalesHeader);

        exit(InitSelectCarrier(TempIDYSTransportOrderHeader, DataBodyJsonObject));
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        ShipAdvisesRequestJsonObject: JsonObject;
        DataBodyJsonObject: JsonObject;
        AddPackageToToErr: Label 'Create a package for Transport Order: %2', Comment = '%2 = Transport Order No.';
    begin
        IDYSProviderCarrierSelect.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSProviderCarrierSelect.DeleteAll();

        if not IsNullGuid(SalesHeaderSystemID) then begin
            ShipAdvisesRequestJsonObject := CreateShipAdviseRequestDocument(IDYSTransportOrderHeader);
            exit(GetAvailableServices(ShipAdvisesRequestJsonObject, IDYSTransportOrderHeader));
        end;

        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if TransportOrderPackage.IsEmpty() then
            Error(AddPackageToToErr, IDYSTransportOrderHeader."No.");

        InitPackagesFromTransportOrderPackages(DataBodyJsonObject, IDYSTransportOrderHeader);

        exit(InitSelectCarrier(IDYSTransportOrderHeader, DataBodyJsonObject));
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; DataBodyJsonObject: JsonObject): JsonArray;
    var
        ShipAdvisesRequestJsonObject: JsonObject;
    begin
        ShipAdvisesRequestJsonObject := CreateShipAdviseRequestDocument(IDYSTransportOrderHeader, DataBodyJsonObject);
        exit(GetAvailableServices(ShipAdvisesRequestJsonObject, IDYSTransportOrderHeader));
    end;

    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray)
    var
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        ProviderBookingProfile: Record "IDYS Provider Booking Profile";
        ServiceLevelOther: Record "IDYS Service Level (Other)";
        LineNo: Integer;
        ShipmentDateTime: DateTime;
        IsHandled: Boolean;
        DocumentJsonToken: JsonToken;
        DocumentJsonObject: JsonObject;
        ServiceJsonArray: JsonArray;
        ServiceJsonToken: JsonToken;
        ServiceJsonObject: JsonObject;
        ProductGoodsTypeJsonObject: JsonObject;
        ServiceName: Text;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents, IsHandled);
            if IsHandled then
                exit;
        end;

        GetSetup();

        IDYSProviderCarrierSelect.SetCurrentKey("Carrier Entry No.", "Booking Profile Entry No.");
        if not IDYSProviderCarrierSelect.IsTemporary then
            Error(NotTemporaryErr, IDYSProviderCarrierSelect.TableCaption);

        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSProvCarrierSelectPck.DeleteAll();

        foreach DocumentJsonToken in Documents do begin
            DocumentJsonObject := DocumentJsonToken.AsObject();
            LineNo += 1;
            Clear(ServiceName);
            IDYSProviderCarrierSelect.Init();
            IDYSProviderCarrierSelect."Transport Order No." := IDYSTransportOrderHeader."No.";
            IDYSProviderCarrierSelect."Line No." := LineNo;

            // Insert not mapped one
            ProviderBookingProfile.SetCurrentKey(ProdCSID);
            if IDYSDeliveryHubSetup."Transsmart Account Code" = IDYSTransportOrderHeader.GetLookupActorId() then
                ProviderBookingProfile.SetRange("Actor Id", '')
            else
                ProviderBookingProfile.SetRange("Actor Id", IDYSTransportOrderHeader.GetLookupActorId());

            ProviderBookingProfile.SetRange(ProdCSID, IDYMJSONHelper.GetIntegerValue(DocumentJsonObject, 'ProdCSID'));
            ProviderBookingProfile.FindFirst();

            IDYSProviderCarrierSelect.Init();
            IDYSProviderCarrierSelect.Provider := IDYSProviderCarrierSelect.Provider::"Delivery Hub";
            IDYSProviderCarrierSelect.Validate("Carrier Entry No.", ProviderBookingProfile."Carrier Entry No.");
            IDYSProviderCarrierSelect.Validate("Booking Profile Entry No.", ProviderBookingProfile."Entry No.");
            IDYSProviderCarrierSelect."Carrier Name" := CopyStr(IDYMJSONHelper.GetTextValue(DocumentJsonObject, 'ProdName'), 1, MaxStrLen(IDYSProviderCarrierSelect."Carrier Name"));
            IDYSProviderCarrierSelect.Description := CopyStr(ProviderBookingProfile.Description, 1, MaxStrLen(IDYSProviderCarrierSelect.Description));
            IDYSProviderCarrierSelect."Price as Decimal" := IDYMJSONHelper.GetDecimalValue(DocumentJsonObject, 'Price');

            ShipAgentSvcMapping.SetRange("Booking Profile Entry No.", ProviderBookingProfile."Entry No.");
            ShipAgentSvcMapping.SetRange("Carrier Entry No.", ProviderBookingProfile."Carrier Entry No.");
            if ShipAgentSvcMapping.FindFirst() then
                IDYSProviderCarrierSelect."Svc. Mapping RecordId" := ShipAgentSvcMapping.RecordId;

            ShipmentDateTime := IDYMJSONHelper.GetDateTimeValue(DocumentJsonObject, 'DeliveryDate');
            IDYSProviderCarrierSelect."Delivery Date" := DT2Date(ShipmentDateTime);
            IDYSProviderCarrierSelect."Delivery Time" := DT2Time(ShipmentDateTime);
            ShipmentDateTime := IDYMJSONHelper.GetDateTimeValue(DocumentJsonObject, 'CutOffTime');
            IDYSProviderCarrierSelect."Pickup Date" := DT2Date(ShipmentDateTime);

            if DocumentJsonObject.Contains('Services') then begin
                ServiceJsonArray := IDYMJSONHelper.GetArray(DocumentJsonObject, 'Services');
                foreach ServiceJsonToken in ServiceJsonArray do begin
                    ServiceJsonObject := ServiceJsonToken.AsObject();
                    ServiceLevelOther.SetRange(ServiceID, IDYMJSONHelper.GetIntegerValue(ServiceJsonObject, 'serviceid'));
                    ServiceLevelOther.FindFirst();

                    IDYSProvCarrierSelectPck.Init();
                    IDYSProvCarrierSelectPck."Transport Order No." := IDYSTransportOrderHeader."No.";
                    IDYSProvCarrierSelectPck."Line No." := LineNo;
                    IDYSProvCarrierSelectPck."Carrier Entry No." := ProviderBookingProfile."Carrier Entry No.";
                    IDYSProvCarrierSelectPck."Booking Profile Entry No." := ProviderBookingProfile."Entry No.";
                    IDYSProvCarrierSelectPck."Carrier Name" := CopyStr(IDYSProviderCarrierSelect."Carrier Name", 1, MaxStrLen(IDYSProvCarrierSelectPck."Carrier Name"));
                    IDYSProvCarrierSelectPck.Description := CopyStr(IDYMJSONHelper.GetTextValue(ServiceJsonObject, 'name'), 1, MaxStrLen(IDYSProvCarrierSelectPck.Description));
                    IDYSProvCarrierSelectPck.Include := true;
                    IDYSProvCarrierSelectPck."Service Level Code (Other)" := ServiceLevelOther.Code;
                    IDYSProvCarrierSelectPck.Insert(true);

                    if ServiceName = '' then
                        ServiceName := IDYMJSONHelper.GetTextValue(ServiceJsonObject, 'name');
                end;
            end;
            if ServiceName <> '' then
                IDYSProviderCarrierSelect."Description" := CopyStr(IDYSProviderCarrierSelect."Description" + ' ' + ServiceName, 1, MaxStrLen(IDYSProviderCarrierSelect."Description"));

            if DocumentJsonObject.Contains('ProductGoodsType') then begin
                ProductGoodsTypeJsonObject := IDYMJSONHelper.GetObject(DocumentJsonObject, 'ProductGoodsType');
                IDYSProviderCarrierSelect."Package Type Code" := CopyStr(IDYMJSONHelper.GetCodeValue(ProductGoodsTypeJsonObject, 'GoodsTypeId'), 1, MaxStrLen(IDYSProviderCarrierSelect."Package Type Code"));
            end;
            if IDYSSessionVariables.CheckAuthorization() then
                OnSelectCarrierOnProviderCarrierSelectInsert(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, ShipAgentSvcMapping);
            IDYSProviderCarrierSelect.Insert();
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents);
    end;

    local procedure CreateShipAdviseRequestDocument(var TransportOrderHeader: Record "IDYS Transport Order Header"; DataBodyJsonObject: JsonObject) RequestDocument: JsonObject
    var
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeCreateShipAdviseRequest(TransportOrderHeader, RequestDocument, IsHandled);
            if IsHandled then
                exit(RequestDocument);
        end;
        RequestDocument := InitRequestDocumentFromIDYSTransportOrderHeader(TransportOrderHeader, DataBodyJsonObject);
    end;

    local procedure GetAvailableServices(Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") ResponseJsonArray: JsonArray
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        ResponseJsonObject: JsonObject;
        EndpointTxt: Label '/ShipServer/%1/shipAdvises', Locked = true;
        ShipAdvisesErr: Label 'Retrieving the ship advises failed with error code %1 (error message: %2)', comment = '%1 = http error code, %2 = error message from api call';
        IsHandled: Boolean;
        ErrorText: Text;
    begin
        GetSetup();
        IDYSTransportOrderHeader.SetLookupActorId(FindActor(IDYSTransportOrderHeader));

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters."Acceptance Environment" := IDYSDeliveryHubSetup."Transsmart Environment" = IDYSDeliveryHubSetup."Transsmart Environment"::Acceptance;
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, IDYSTransportOrderHeader.GetLookupActorId());
        TempIDYMRESTParameters.SetRequestContent(Document);

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::Default);
        if (TempIDYMRESTParameters."Status Code" in [200, 201]) and TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject() then begin
            ResponseJsonObject := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
            if ResponseJsonObject.Contains('Products') then begin
                ResponseJsonArray := IDYMJSONHelper.GetArray(ResponseJsonObject, 'Products');
                if IDYSSessionVariables.CheckAuthorization() then begin
                    OnAfterGetAvailableServices(ResponseJsonArray, TempIDYMRESTParameters, IDYSTransportOrderHeader, IsHandled);
                    if IsHandled then
                        exit(ResponseJsonArray);
                end;
            end else begin
                if ResponseJsonObject.Contains('Message') then
                    ErrorText := IDYMJSONHelper.GetTextValue(ResponseJsonObject, 'Message')
                else
                    ErrorText := TempIDYMRESTParameters.GetResponseBodyAsString();
                Error(ShipAdvisesErr, TempIDYMRestParameters."Status Code", ErrorText);
            end;
        end else
            IDYSDelHubErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
    end;

    local procedure InitRequestDocumentFromIDYSTransportOrderHeader(var TransportOrderHeader: Record "IDYS Transport Order Header"; DataBodyJsonObject: JsonObject) ShipAdvisesRequestJsonDocument: JsonObject
    var
        AddressesJsonArray: JsonArray;
        OptionsJsonObject: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitRequestDocumentFromTransportOrderHeader(TransportOrderHeader, ShipAdvisesRequestJsonDocument, IsHandled);
            if IsHandled then
                exit;
        end;

        CreateAddressFromTransportOrder(AddressesJsonArray, TransportOrderHeader, 1); // 1 - Receiver
        CreateAddressFromTransportOrder(AddressesJsonArray, TransportOrderHeader, 2); // 2 - Sender
        IDYMJSONHelper.Add(DataBodyJsonObject, 'Addresses', AddressesJsonArray);

        IDYMJSONHelper.Add(ShipAdvisesRequestJsonDocument, 'data', DataBodyJsonObject);
        //IDYMJSONHelper.AddValue(OptionsJsonObject, 'ServiceLevel', 'Standard'); //TODO determine what to use, setup??
        IDYMJSONHelper.AddValue(OptionsJsonObject, 'Price', '1');
        IDYMJSONHelper.AddValue(OptionsJsonObject, 'EarliestPickup', TransportOrderHeader."Preferred Pick-up Date From");
        IDYMJSONHelper.AddValue(OptionsJsonObject, 'Deliverydate', TransportOrderHeader."Preferred Delivery Date From");

        IDYMJSONHelper.Add(ShipAdvisesRequestJsonDocument, 'options', OptionsJsonObject);
    end;

    procedure DoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        EndpointTxt: Label '/ShipServer/%1/shipments/%2', Locked = true;
        RecalledTxt: Label 'Recalled';
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeDoDeleteOrder(IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        GetSetup();
        IDYSTransportOrderHeader.SetLookupActorId(FindActor(IDYSTransportOrderHeader));
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters."Acceptance Environment" := IDYSDeliveryHubSetup."Transsmart Environment" = IDYSDeliveryHubSetup."Transsmart Environment"::Acceptance;
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::DELETE;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, IDYSTransportOrderHeader.GetLookupActorId(), IDYSTransportOrderHeader."Shipment Tag");
        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::Default);

        if (TempIDYMRESTParameters."Status Code" in [200, 201]) then begin
            // There is a scenario where, after synchronization, the latest status is not retrieved due to a delay on the other integration end. This results in an incorrect status.
            IDYSTransportOrderHeader.CreateLogEntry(RecalledTxt, LoggingLevel::Information);
            IDYSTransportOrderHeader.Status := IDYSTransportOrderHeader.Status::Recalled;
            IDYSTransportOrderHeader.Modify();
            Commit();
        end else
            IDYSDelHubErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterDoDeleteOrder(IDYSTransportOrderHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDoDeleteOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDoDeleteOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateShipAdviseRequest(TransportOrderHeader: Record "IDYS Transport Order Header"; var RequestJsonObject: JsonObject; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAvailableServices(var ResponseJsonArray: JsonArray; var TempIDYMRESTParameters: Record "IDYM REST Parameters"; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean);
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
    local procedure OnSelectCarrierOnProviderCarrierSelectInsert(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping");
    begin
    end;
    #endregion

    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean) ReturnValue: Boolean
    var
        LicenseCheck: Codeunit "IDYS License Check";
        ErrorMessage: Text;
        Data: JsonObject;
        Options: JsonObject;
        IsHandled: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeCreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
            ValidateTransportOrder(IDYSTransportOrderHeader);
            OnBeforeCreateDocumentWithTO(IDYSTransportOrderHeader, Data, Options, IsHandled);
        end else
            ValidateTransportOrder(IDYSTransportOrderHeader);

        InitDocumentFromIDYSTransportOrderHeader(Data, IDYSTransportOrderHeader);
        InitPackagesFromTransportOrderPackages(Data, IDYSTransportOrderHeader);
        InitDeliveryNotesFromTransportOrderDeliveryNotes(Data, IDYSTransportOrderHeader);
        InitPrinting(Options);
        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterCreateDocumentWithTO(IDYSTransportOrderHeader, Data, Options);
        IDYMJSONHelper.Add(RequestDocument, 'data', Data);
        IDYMJSONHelper.Add(RequestDocument, 'options', Options);

        //Pre-POST check if using ShipIT is allowed
        LicenseCheck.SetPostponeWriteTransactions();
        if not LicenseCheck.CheckLicense(IDYSSetup."License Entry No.", ErrorMessage, HttpStatusCode) then
            exit;

        if AllowLogging and IDYSSetup."Enable Debug Mode" then begin
            IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", BookingTxt, LoggingLevel::Information, RequestDocument);
            Commit();
        end;

        //POST the document
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

    procedure HandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject): Boolean
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        Packages: JsonArray;
        Package: JsonToken;
        Lines: JsonArray;
        Line: JsonToken;
        Reference: JsonToken;
        Tracking: JsonObject;
        Document: JsonObject;
        IsHandled: Boolean;
        SuccessFull: Boolean;
    begin
        GetSetup();
        GetPrintingUserSetup();

        if IDYSSessionVariables.CheckAuthorization() then
            OnBeforeHandleResponseAfterBooking(ResponseDocument, IDYSTransportOrderHeader, SuccessFull, IsHandled);
        if not IsHandled then begin
            // Lines
            Lines := IDYMJSONHelper.GetArray(ResponseDocument.AsToken(), 'Lines');
            foreach Line in Lines do
                foreach Reference in IDYMJSONHelper.GetArray(Line, 'References') do
                    if IDYMJSONHelper.GetTextValue(Reference, 'Kind') = '24' then
                        if IDYSTransportOrderPackage.Get(IDYSTransportOrderHeader."No.", IDYMJSONHelper.GetIntegerValue(Reference, 'Value')) then begin
                            Packages := IDYMJSONHelper.GetArray(Line, 'Pkgs');
                            Packages.Get(0, Package);

                            IDYSTransportOrderPackage."Package CSID" := IDYMJSONHelper.GetIntegerValue(Package, 'PkgCSID');
                            IDYSTransportOrderPackage."Package Tag" := CopyStr(IDYMJSONHelper.GetTextValue(Package, 'PkgTag'), 1, MaxStrlen(IDYSTransportOrderPackage."Package Tag"));
                            IDYSTransportOrderPackage."Tracking No." := CopyStr(IDYMJSONHelper.GetTextValue(Package, 'PkgNo'), 1, MaxStrLen(IDYSTransportOrderPackage."Tracking No."));
                            IDYSTransportOrderPackage.Modify(true);
                        end;

            // Tracking
            IDYSTransportOrderHeader.Validate("Shipment Tag", IDYMJSONHelper.GetTextValue(ResponseDocument, 'ShpTag'));
            IDYSTransportOrderHeader.Validate("Shipment CSID", IDYMJSONHelper.GetIntegerValue(ResponseDocument, 'ShpCSID'));
            IDYSTransportOrderHeader.Validate("Tracking No.", IDYMJSONHelper.GetTextValue(ResponseDocument, 'ShpNo'));
            Tracking := GetTrackingURL(IDYSTransportOrderHeader);

            IDYSTransportOrderHeader.Validate("Tracking Url", IDYMJSONHelper.GetTextValue(Tracking, 'TrackingURL'));
            UpdateStatus(IDYSTransportOrderHeader);
            IDYSTransportOrderHeader.Modify(true);

            Lines := IDYMJSONHelper.GetArray(Tracking.AsToken(), 'Pkgs');
            foreach Line in Lines do begin
                IDYSTransportOrderPackage.Reset();
                IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
                IDYSTransportOrderPackage.SetRange("Tracking No.", IDYMJSONHelper.GetTextValue(Line, 'PkgNo'));
                if IDYSTransportOrderPackage.FindFirst() then begin
                    IDYSTransportOrderPackage."Tracking Url" := CopyStr(IDYMJSONHelper.GetTextValue(Line, 'TrackingURL'), 1, MaxStrLen(IDYSTransportOrderPackage."Tracking Url"));
                    IDYSTransportOrderPackage.Modify(true);
                end;
            end;

            // Statuses
            Document := GetShipmentAdditionalInformation(IDYSTransportOrderHeader, false, true);
            SuccessFull := true;
            if IDYSSessionVariables.CheckAuthorization() then
                OnAfterHandleResponseAfterBooking(ResponseDocument, IDYSTransportOrderHeader, SuccessFull);
        end;
        exit(SuccessFull);
    end;

    procedure OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    var
        DeliveryHubDashboardUrlTxt: label 'https://www.consignorportal.com/ui/sv/view?id=%1&iframe-modal-content=&req-auth=1', Comment = '%1 = Shipment tag', Locked = true;
    begin
        Hyperlink(StrSubstNo(DeliveryHubDashboardUrlTxt, TransportOrderHeader."Shipment Tag"));
    end;

    procedure OpenAllInDashboard();
    var
        DeliveryHubDashboardUrlTxt: label 'https://www.consignorportal.com/ui?iframe-modal-content=&req-auth=1', Locked = true;
    begin
        Hyperlink(DeliveryHubDashboardUrlTxt);
    end;

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        IsHandled: Boolean;
        ShipmentValueMandatoryErr: Label 'Providing a shipment value is mandatory, but the shipment value couldn''t be calculated. Please register a shipment value manually.';
        DateErr: Label 'cannot be before %1.', Comment = '%1=Today';
    begin
        GetSetup();
        OnBeforeValidateTransportOrder(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;
        if not (IDYSTransportOrderHeader.Status in [
            IDYSTransportOrderHeader.Status::New])
        then
            IDYSTransportOrderHeader.FieldError(Status);
        IDYSTransportOrderHeader.TestField("Preferred Pick-up Date From");
        IDYSTransportOrderHeader.TestField("Preferred Pick-up Date To");
        IDYSTransportOrderHeader.TestField("Preferred Delivery Date From");
        IDYSTransportOrderHeader.TestField("Preferred Delivery Date To");

        if DT2Date(IDYSTransportOrderHeader."Preferred Pick-up Date From") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Pick-up Date From", StrSubstNo(DateErr, Today));
        if DT2Date(IDYSTransportOrderHeader."Preferred Pick-up Date To") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Pick-up Date To", StrSubstNo(DateErr, Today));

        IDYSTransportOrderHeader.CalcFields("Calculated Shipment Value");

        IDYSTransportOrderHeader.TestField("Name (Pick-up)");
        IDYSTransportOrderHeader.TestField("Street (Pick-up)");
        IDYSTransportOrderHeader.TestField("Post Code (Pick-up)");
        IDYSTransportOrderHeader.TestField("City (Pick-up)");

        IDYSTransportOrderHeader.TestField("Name (Ship-to)");
        IDYSTransportOrderHeader.TestField("Street (Ship-to)");
        IDYSTransportOrderHeader.TestField("Post Code (Ship-to)");
        IDYSTransportOrderHeader.TestField("City (Ship-to)");

        IDYSTransportOrderHeader.TestField("Name (Invoice)");
        IDYSTransportOrderHeader.TestField("Street (Invoice)");
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
        exit(true);
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsDeliveryHub(NewProvider: Enum "IDYS Provider"): Boolean
    begin
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsDeliveryHub(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsDeliveryHub(var TransportOrderPackage: Record "IDYS Transport Order Package"): Boolean
    begin
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsDeliveryHubEnabled(): Boolean
    begin
    end;

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
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        RequestDocument: JsonObject;
        Options: JsonObject;
        Data: JsonObject;
        LabelReprintEndpointTxt: Label '/ShipServer/%1/Shipments/LabelReprint', Locked = true;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeTryDoLabelPrinted(IDYSTransportOrderHeader, Response, Printed, IsHandled);
            if IsHandled then
                exit(Printed);
        end;
        InitPrinting(Options);

        if not (IDYSTransportOrderHeader.Status in [
            IDYSTransportOrderHeader.Status::Uploaded,
            IDYSTransportOrderHeader.Status::Booked,
            IDYSTransportOrderHeader.Status::"Label Printed"])
        then
            IDYSTransportOrderHeader.FieldError(Status);

        // Data
        Data.Add('ShpCSID', IDYSTransportOrderHeader."Shipment CSID");
        IDYMJSONHelper.Add(RequestDocument, 'data', Data);
        IDYMJSONHelper.Add(RequestDocument, 'options', Options);

        // Send to printer
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters."Acceptance Environment" := IDYSDeliveryHubSetup."Transsmart Environment" = IDYSDeliveryHubSetup."Transsmart Environment"::Acceptance;
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
        TempIDYMRESTParameters.Path := StrSubstNo(LabelReprintEndpointTxt, GetCurrentActor(IDYSTransportOrderHeader));
        TempIDYMRESTParameters.SetRequestContent(RequestDocument);

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::Default);
        Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        if not (TempIDYMRESTParameters."Status Code" In [200, 201]) then begin
            IDYSDelHubErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;
        exit(true);
    end;

    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        Base64Convert: Codeunit "Base64 Convert";
        ContentOutStream: OutStream;
        Base64EncodedLabel: Text;
        Line: JsonToken;
        IsHandled: Boolean;
        FilenameLbl: Label '%1.pdf', Locked = true;
    begin
        GetPrintingUserSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterPrinting(Response, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;
        if not IDYSUserSetup."Enable Drop Zone Printing" then
            foreach Line in IDYMJSONHelper.GetArray(Response, 'Labels') do begin
                IDYSTransportOrderPackage.Reset();
                IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
                IDYSTransportOrderPackage.SetRange("Tracking No.", IDYMJSONHelper.GetTextValue(Line, 'PkgNo'));
                if IDYSTransportOrderPackage.FindFirst() then begin
                    Base64EncodedLabel := IDYMJSONHelper.GetTextValue(Line, 'Content');
                    if Base64EncodedLabel <> '' then begin
                        // Delete label
                        IDYSSCParcelDocument.SetRange("Transport Order No.", IDYSTransportOrderPackage."Transport Order No.");
                        IDYSSCParcelDocument.SetRange("Parcel Identifier", IDYSTransportOrderPackage."Parcel Identifier");
                        IDYSSCParcelDocument.DeleteAll();

                        // Insert label
                        IDYSSCParcelDocument.Init();
                        IDYSSCParcelDocument."Parcel Identifier" := IDYSTransportOrderPackage."Parcel Identifier";
                        IDYSSCParcelDocument."Transport Order No." := IDYSTransportOrderPackage."Transport Order No.";
                        IDYSSCParcelDocument."File Name" := StrSubstNo(FilenameLbl, IDYSTransportOrderPackage."Parcel Identifier");
                        IDYSSCParcelDocument."File".CreateOutStream(ContentOutStream);
                        Base64Convert.FromBase64(Base64EncodedLabel, ContentOutStream);
                        IDYSSCParcelDocument.Insert(true);
                    end;
                end;
            end;

        IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::"Label Printed");
        IDYSTransportOrderHeader.Modify();
        IDYSTransportOrderHeader.CreateLogEntry(LabelPrintedTxt, LoggingLevel::Information);
    end;

    local procedure GetSetup(): Boolean
    begin
        if not SetupLoaded then
            SetupLoaded := IDYSSetup.Get();

        if not ProviderSetupLoaded then begin
            IDYSDeliveryHubSetup.GetProviderSetup("IDYS Provider"::"Delivery Hub");
            ProviderSetupLoaded := true;
        end;

        exit(SetupLoaded);
    end;

    local procedure GetMappedUnitOfMeasure(UOMCode: Code[10]): Code[10];
    var
        IDYSUnitOfMeasureMapping: Record "IDYS Unit Of Measure Mapping";
    begin
        if IDYSUnitOfMeasureMapping.Get(UOMCode) then
            exit(IDYSUnitOfMeasureMapping."Unit of Measure (External)");
        exit(UOMCode);
    end;

    local procedure GetPrintingUserSetup()
    begin
        if not IDYSUserSetup.Get(UserId()) then begin
            IDYSUserSetup.Reset();
            IDYSUserSetup.SetRange(Default, true);
            if not IDYSUserSetup.FindFirst() then
                Error(UserSetupErr);
        end;
    end;

    procedure CreateAddressFromTransportOrder(var AddressJsonArray: JsonArray; var TransportOrderHeader: Record "IDYS Transport Order Header"; Kind: Integer)
    var
        AddressJsonObject: JsonObject;
    begin
        IDYMJSONHelper.AddValue(AddressJsonObject, 'Kind', Kind);
        case Kind of
            1:
                begin
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Name1', TransportOrderHeader."Name (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Street1', TransportOrderHeader."Address (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Street2', TransportOrderHeader."Address 2 (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'PostCode', TransportOrderHeader."Post Code (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'City', TransportOrderHeader."City (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'State', TransportOrderHeader."County (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Phone', TransportOrderHeader."Phone No. (Ship-to)");
                    if TransportOrderHeader."Mobile Phone No. (Ship-to)" <> '' then
                        IDYMJSONHelper.AddValue(AddressJsonObject, 'Mobile', TransportOrderHeader."Mobile Phone No. (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Fax', TransportOrderHeader."Fax No. (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'VATNo', TransportOrderHeader."VAT Registration No. (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'VOECNumber', TransportOrderHeader."EORI Number (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Email', TransportOrderHeader."E-Mail (Ship-to)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'CountryCode', TransportOrderHeader."Cntry/Rgn. Code (Ship-to) (TS)");  //External Country Code / ISO 3166
                    if TransportOrderHeader."Contact (Ship-to)" <> '' then
                        IDYMJSONHelper.AddValue(AddressJsonObject, 'Attention', TransportOrderHeader."Contact (Ship-to)")
                    else
                        IDYMJSONHelper.AddValue(AddressJsonObject, 'Attention', TransportOrderHeader."Name (Ship-to)");
                end;
            2:
                begin
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Name1', TransportOrderHeader."Name (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Street1', TransportOrderHeader."Address (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Street2', TransportOrderHeader."Address 2 (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'PostCode', TransportOrderHeader."Post Code (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'City', TransportOrderHeader."City (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'State', TransportOrderHeader."County (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Phone', TransportOrderHeader."Phone No. (Pick-up)");
                    if TransportOrderHeader."Mobile Phone No. (Pick-up)" <> '' then
                        IDYMJSONHelper.AddValue(AddressJsonObject, 'Mobile', TransportOrderHeader."Mobile Phone No. (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Fax', TransportOrderHeader."Fax No. (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'VATNo', TransportOrderHeader."VAT Registration No. (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'VOECNumber', TransportOrderHeader."EORI Number (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Email', TransportOrderHeader."E-Mail (Pick-up)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'CountryCode', TransportOrderHeader."Cntry/Rgn. Code (Pick-up) (TS)");  //External Country Code / ISO 3166
                    if TransportOrderHeader."Contact (Pick-up)" <> '' then
                        IDYMJSONHelper.AddValue(AddressJsonObject, 'Attention', TransportOrderHeader."Contact (Pick-up)")
                    else
                        IDYMJSONHelper.AddValue(AddressJsonObject, 'Attention', TransportOrderHeader."Name (Pick-up)");
                    if TransportOrderHeader."Customer (Ref)" <> '' then
                        IDYMJSONHelper.AddValue(AddressJsonObject, 'CustNo', TransportOrderHeader."Customer (Ref)");
                end;
            4:
                begin
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Name1', TransportOrderHeader."Name (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Street1', TransportOrderHeader."Address (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Street2', TransportOrderHeader."Address 2 (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'PostCode', TransportOrderHeader."Post Code (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'City', TransportOrderHeader."City (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'State', TransportOrderHeader."County (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Phone', TransportOrderHeader."Phone No. (Invoice)");
                    if TransportOrderHeader."Mobile Phone No. (Invoice)" <> '' then
                        IDYMJSONHelper.AddValue(AddressJsonObject, 'Mobile', TransportOrderHeader."Mobile Phone No. (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Fax', TransportOrderHeader."Fax No. (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'VATNo', TransportOrderHeader."VAT Registration No. (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'VOECNumber', TransportOrderHeader."EORI Number (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'Email', TransportOrderHeader."E-Mail (Invoice)");
                    IDYMJSONHelper.AddValue(AddressJsonObject, 'CountryCode', TransportOrderHeader."Cntry/Rgn. Code (Invoice) (TS)");  //External Country Code / ISO 3166
                    if TransportOrderHeader."Contact (Invoice)" <> '' then
                        IDYMJSONHelper.AddValue(AddressJsonObject, 'Attention', TransportOrderHeader."Contact (Invoice)")
                    else
                        IDYMJSONHelper.AddValue(AddressJsonObject, 'Attention', TransportOrderHeader."Name (Invoice)");
                end;
        end;
        IDYMJSONHelper.Add(AddressJsonArray, AddressJsonObject);
    end;

    procedure IsAllowedToShip(ServiceEntryNo: Integer; ShipToCountryCode: Code[10]) Allowed: Boolean
    var
        IDYSDelHubAPISvcCountry: Record "IDYS DelHub API Svc. Country";
    begin
        //Ship-to
        IDYSDelHubAPISvcCountry.Reset();
        IDYSDelHubAPISvcCountry.SetRange("Service Entry No.", ServiceEntryNo);
        IDYSDelHubAPISvcCountry.SetRange("Entry Type", IDYSDelHubAPISvcCountry."Entry Type"::"Ship-to");
        IDYSDelHubAPISvcCountry.SetFilter("Country Code (Mapped)", '%1|%2', '', ShipToCountryCode);
        Allowed := not IDYSDelHubAPISvcCountry.IsEmpty();

        //Ship-to (denied)
        if Allowed then begin
            IDYSDelHubAPISvcCountry.SetRange("Entry Type", IDYSDelHubAPISvcCountry."Entry Type"::"Ship-to (Denied)");
            IDYSDelHubAPISvcCountry.SetRange("Country Code (Mapped)", ShipToCountryCode);
            Allowed := IDYSDelHubAPISvcCountry.IsEmpty();
        end;
    end;

    local procedure GetCurrentActor(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") ActorId: Text[30]
    begin
        OnBeforeGetActor(IDYSTransportOrderHeader, ActorId);
        if ActorId <> '' then
            exit(ActorId);

        GetSetup();
        IDYSTransportOrderHeader.CalcFields("Actor Id");
        if IDYSTransportOrderHeader."Actor Id" = '' then
            exit(IDYSDeliveryHubSetup."Transsmart Account Code");
        exit(IDYSTransportOrderHeader."Actor Id");
    end;

    local procedure FindActor(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") ActorId: Text[30]
    var
        Location: Record Location;
    begin
        OnBeforeFindActor(IDYSTransportOrderHeader, ActorId);
        if ActorId <> '' then
            exit(ActorId);

        GetSetup();
        // Ship-To Location, Pick-up Location
        if IDYSTransportOrderHeader."Source Type (Ship-to)" = IDYSTransportOrderHeader."Source Type (Ship-to)"::Location then
            if Location.Get(IDYSTransportOrderHeader."No. (Ship-to)") then
                if Location."IDYS Actor Id" <> '' then
                    exit(Location."IDYS Actor Id");

        if IDYSTransportOrderHeader."Source Type (Pick-up)" = IDYSTransportOrderHeader."Source Type (Pick-up)"::Location then
            if Location.Get(IDYSTransportOrderHeader."No. (Pick-up)") then
                if Location."IDYS Actor Id" <> '' then
                    exit(Location."IDYS Actor Id");

        exit(IDYSDeliveryHubSetup."Transsmart Account Code");
    end;
    #region [Obsolete]
    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetShipmentAdditionalInformation(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes"): JsonObject
    begin
        exit(GetShipmentAdditionalInformation(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetTrackingURL(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"): JsonObject
    begin
        exit(GetTrackingURL(IDYSTransportOrderHeader));
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

    [IntegrationEvent(true, false)]
    local procedure OnBeforeFindActor(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var ActorId: Text[30])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetActor(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var ActorId: Text[30])
    begin
    end;

    [Obsolete('Authorization is now associated with the license key', '23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnSetAuthorization(var Authorization: Guid)
    begin
    end;

    [Obsolete('Replaced with OnBeforeCreateDocumentWithTO()')]
    [IntegrationEvent(true, false)]
    local procedure OnBeforeCreateDocument(var Data: JsonObject; var Options: JsonObject; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCreateDocumentWithTO(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Data: JsonObject; var Options: JsonObject; var IsHandled: Boolean);
    begin
    end;

    [Obsolete('Replaced with OnAfterCreateDocumentWithTO()')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDocument(var Data: JsonObject; var Options: JsonObject);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDocumentWithTO(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Data: JsonObject; var Options: JsonObject);
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
    local procedure OnBeforeInitDocumentFromIDYSTransportOrderHeader(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDocumentFromIDYSTransportOrderHeader(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitPackagesFromTransportOrderPackages(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitPackagesFromSourceDoc(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitPackagesFromTransportOrderPackages(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitPackagesFromSourceDoc(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; SalesHeader: Record "Sales Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitDeliveryNotesFromTransportOrderDeliveryNotes(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDeliveryNotesFromTransportOrderDeliveryNotes(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeHandleResponseAfterBooking(ResponseDocument: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SuccessFull: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterHandleResponseAfterBooking(ResponseDocument: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SuccessFull: Boolean);
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
    local procedure OnBeforeValidateTransportOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateTransportOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [Obsolete('Removed ErrorCode. Replace with OnAfterGetShipmentAdditionalInfo()', '25.0')]
    [IntegrationEvent(true, false)]
    local procedure OnAfterGetShipmentAdditionalInformation(Document: JsonToken; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; ErrorCode: Enum "IDYS Error Codes"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGetShipmentAdditionalInfo(Document: JsonToken; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetShipmentAdditionalInformationOnBeforeModifySalesHeader(Document: JsonToken; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetShipmentAdditionalInformationOnAfterModifySalesHeader(Document: JsonToken; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    begin
    end;

    [Obsolete('Removed ErrorCode. Replace with OnBeforeTryDoLabelPrinted()', '25.0')]
    [IntegrationEvent(true, false)]
    local procedure OnBeforeTryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken; var Printed: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeTryDoLabelPrinted(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Response: JsonToken; var Printed: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterPrinting(Response: JsonToken; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitPrinting(var Options: JsonObject; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSelectCarrierFromTemp(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; var ReturnValue: JsonArray; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeInitRequestDocumentFromTransportOrderHeader(var TransportOrderHeader: Record "IDYS Transport Order Header"; var ShipAdvisesRequestJsonDocument: JsonObject; var IsHandled: Boolean)
    begin
    end;

    #region [Obsolete]

    [Obsolete('Removed SalesHeaderSystemId. Replaced by InitCarrierSelection', '25.0')]
    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary) ReturnValue: JsonArray;
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        DataBodyJsonObject: JsonObject;
        CompletelyShippedErr: Label 'Order is completely shipped already.';
        AddPackageToSalesDocErr: Label 'Create a package for Sales %1 %2', Comment = '%1 = Document Type, %2 = Sales Document No.';
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitSelectCarrierFromTemp(TempIDYSTransportOrderHeader, SalesHeader, IDYSProviderCarrierSelect, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        if not SalesHeader.IsTemporary() then
            SalesHeaderSystemID := SalesHeader.SystemId;
        InitCarrierSelection(TempIDYSTransportOrderHeader, SalesHeader, IDYSProviderCarrierSelect);

        if SalesHeader."Completely Shipped" then
            Error(CompletelyShippedErr);

        SalesHeader.TestField("Completely Shipped", false);
        TempIDYSTransportOrderHeader.Provider := SalesHeader."IDYS Provider";

        IDYSDocumentMgt.SalesHeader_CreateTempTransportOrder(SalesHeader, TempIDYSTransportOrderHeader);

        IDYSProviderCarrierSelect.SetRange("Transport Order No.", TempIDYSTransportOrderHeader."No.");
        IDYSProviderCarrierSelect.DeleteAll();

        exit(InitSelectCarrier(TempIDYSTransportOrderHeader, IDYSProviderCarrierSelect));
    end;

    [Obsolete('Added SalesHeader', '25.0')]
    procedure InitPackagesFromSourceDocPackages(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SourceDocumentPackage: Record "IDYS Source Document Package";
        Lines: JsonArray;
        Line: JsonObject;
        Reference: JsonObject;
        References: JsonArray;
        ContentValue: Text;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitPackagesFromSourceDocPackages(Document, IDYSTransportOrderHeader, SalesHeaderSystemID, IsHandled);
            if IsHandled then
                exit;
        end;
        SalesHeader.GetBySystemId(SalesHeaderSystemID);

        InitPackagesFromSourceDocPackages(Document, IDYSTransportOrderHeader, SalesHeader);

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitPackagesFromSourceDocPackages(Document, IDYSTransportOrderHeader, SalesHeaderSystemID);
    end;

    [Obsolete('Added DataBodyJsonObject', '25.0')]
    local procedure CreateShipAdviseRequestDocument(var TransportOrderHeader: Record "IDYS Transport Order Header") RequestDocument: JsonObject
    var
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeCreateShipAdviseRequest(TransportOrderHeader, RequestDocument, IsHandled);
            if IsHandled then
                exit(RequestDocument);
        end;
        RequestDocument := InitRequestDocumentFromIDYSTransportOrderHeader(TransportOrderHeader);
    end;

    [Obsolete('Added DataBodyJsonObject', '25.0')]
    local procedure InitRequestDocumentFromIDYSTransportOrderHeader(var TransportOrderHeader: Record "IDYS Transport Order Header") ShipAdvisesRequestJsonDocument: JsonObject
    var
        SalesHeader: Record "Sales Header";
        TransportOrderPackage: Record "IDYS Transport Order Package";
        SourceDocumentPackage: Record "IDYS Source Document Package";
        DataBodyJsonObject: JsonObject;
        AddressesJsonArray: JsonArray;
        OptionsJsonObject: JsonObject;
        IsHandled: Boolean;
        AddPackageToToErr: Label 'Create a package for Transport Order: %2', Comment = '%2 = Transport Order No.';
        AddPackageToSalesDocErr: Label 'Create a package for Sales %1 %2', Comment = '%1 = Document Type, %2 = Sales Document No.';
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitRequestDocumentFromIDYSTransportOrderHeader(TransportOrderHeader, SalesHeaderSystemID, ShipAdvisesRequestJsonDocument, IsHandled);
            if IsHandled then
                exit;
        end;

        CreateAddressFromTransportOrder(AddressesJsonArray, TransportOrderHeader, 1); // 1 - Receiver
        CreateAddressFromTransportOrder(AddressesJsonArray, TransportOrderHeader, 2); // 2 - Sender
        IDYMJSONHelper.Add(DataBodyJsonObject, 'Addresses', AddressesJsonArray);

        if not IsNullGuid(SalesHeaderSystemID) then begin
            SalesHeader.GetBySystemId(SalesHeaderSystemId);
            SourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
            SourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
            SourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
            if SourceDocumentPackage.IsEmpty() then
                Error(AddPackageToSalesDocErr, SalesHeader."Document Type", SalesHeader."No.");
            InitPackagesFromSourceDocPackages(DataBodyJsonObject, TransportOrderHeader)
        end else begin
            TransportOrderPackage.SetRange("Transport Order No.", TransportOrderHeader."No.");
            if TransportOrderPackage.IsEmpty() then
                Error(AddPackageToToErr, TransportOrderHeader."No.");
            InitPackagesFromTransportOrderPackages(DataBodyJsonObject, TransportOrderHeader);
        end;

        IDYMJSONHelper.Add(ShipAdvisesRequestJsonDocument, 'data', DataBodyJsonObject);
        //IDYMJSONHelper.AddValue(OptionsJsonObject, 'ServiceLevel', 'Standard'); //TODO determine what to use, setup??
        IDYMJSONHelper.AddValue(OptionsJsonObject, 'Price', '1');
        IDYMJSONHelper.AddValue(OptionsJsonObject, 'EarliestPickup', TransportOrderHeader."Preferred Pick-up Date From");
        IDYMJSONHelper.AddValue(OptionsJsonObject, 'Deliverydate', TransportOrderHeader."Preferred Delivery Date From");

        IDYMJSONHelper.Add(ShipAdvisesRequestJsonDocument, 'options', OptionsJsonObject);
    end;

    [Obsolete('Removed SalesHeaderSystemID', '25.0')]
    procedure SetSalesHeaderSystemId(NewSalesHeaderSystemId: Guid)
    begin
        SalesHeaderSystemId := NewSalesHeaderSystemId;
    end;

    [Obsolete('Removed SalesHeaderSystemID', '25.0')]
    procedure GetSalesHeaderSystemId(): Guid
    begin
        exit(SalesHeaderSystemId);
    end;

    [Obsolete('Replace with OnBeforeInitPackagesFromSourceDoc()', '25.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitPackagesFromSourceDocPackages(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; SalesHeaderSystemID: Guid; var IsHandled: Boolean);
    begin
    end;

    [Obsolete('Replace with OnAfterInitPackagesFromSourceDoc()', '25.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterInitPackagesFromSourceDocPackages(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; SalesHeaderSystemID: Guid);
    begin
    end;

    [Obsolete('Replace with OnBeforeInitRequestDocumentFromTransportOrderHeader()', '25.0')]
    [IntegrationEvent(true, false)]
    local procedure OnBeforeInitRequestDocumentFromIDYSTransportOrderHeader(var TransportOrderHeader: Record "IDYS Transport Order Header"; SalesHeaderSystemID: Guid; var ShipAdvisesRequestJsonDocument: JsonObject; var IsHandled: Boolean)
    begin
    end;


    #endregion

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSDeliveryHubSetup: Record "IDYS Setup";
        IDYSUserSetup: Record "IDYS User Setup";
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        IDYSDelHubErrorHandler: Codeunit "IDYS DelHub Error Handler";
        IDYSLoggingHelper: Codeunit "IDYS Logging Helper";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        SalesHeaderSystemID: Guid;
        SetupLoaded: Boolean;
        PostDocumentSucceeeded: Boolean;
        ProviderSetupLoaded: Boolean;
        LoggingLevel: Enum "IDYS Logging Level";
        HttpStatusCode: Integer;
        BookingTxt: Label 'Booking';
        SynchronizeTxt: Label 'Synchronize';
        ErrorSynchronizeTxt: Label 'Error while synchronizing';
        ErrorBookingTxt: Label 'Error while booking';
        UploadedTxt: Label 'Uploaded to nShift Ship';
        LabelPrintedTxt: Label 'Label printed';
        UserSetupErr: Label 'User Setup not found';
        UpdatedTxt: Label 'Updated from nShift Ship';
        NotTemporaryErr: Label 'Parameter %1 is not temporary', Comment = '%1 = parameter name';
}