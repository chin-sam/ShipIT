codeunit 11147643 "IDYS Transsmart API Docs. Mgt."
{
    local procedure InitDocumentFromIDYSTransportOrderHeader(var Document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSServiceLevelTime: Record "IDYS Service Level (Time)";
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
        IDYSIncoterm: Record "IDYS Incoterm";
        IDYSCostCenter: Record "IDYS Cost Center";
        Addresses: JsonArray;
        Address: JsonObject;
        additionalRefs: JsonArray;
        AdditionalRef: JsonObject;
        LanguageCode: Text;
        IsHandled: Boolean;
        DateErr: Label 'cannot be before %1.', Comment = '%1=Today';
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitDocumentFromIDYSTransportOrderHeader(Document, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        IDYMJSONHelper.AddValue(Document, 'reference', IDYSTransportOrderHeader."No.");
        IDYMJSONHelper.AddValue(Document, 'description', IDYSTransportOrderHeader.Description);
        IDYMJSONHelper.AddValue(Document, 'mailType', IDYSTransportOrderHeader."E-Mail Type");
        IDYMJSONHelper.AddValue(Document, 'loadmeters', IDYSTransportOrderHeader."Load Meter");
        IDYMJSONHelper.AddValue(Document, 'instruction', IDYSTransportOrderHeader.Instruction);
        if IDYSTransportOrderHeader."Shipmt. Value" <> 0 then
            IDYMJSONHelper.AddValue(Document, 'value', IDYSTransportOrderHeader."Shipmt. Value")
        else begin
            IDYSTransportOrderHeader.CalcFields("Calculated Shipment Value");
            IDYMJSONHelper.AddValue(Document, 'value', IDYSTransportOrderHeader."Calculated Shipment Value");
        end;
        IDYMJSONHelper.AddValue(Document, 'currency', IDYSTransportOrderHeader."Shipmt. Value Curr Code (TS)");
        IDYMJSONHelper.AddValue(Document, 'valueCurrency', IDYSTransportOrderHeader."Shipmt. Value Curr Code (TS)");
        IDYMJSONHelper.AddValue(Document, 'spotPriceCurrency', IDYSTransportOrderHeader."Spot Price Curr Code (TS)");
        IDYMJSONHelper.AddValue(Document, 'spotPrice', IDYSTransportOrderHeader."Spot Pr.");

        case IDYSTransportOrderHeader."Service Type Enum" of
            IDYSTransportOrderHeader."Service Type Enum"::Docs:
                IDYMJSONHelper.AddValue(Document, 'service', 'DOCS');

            IDYSTransportOrderHeader."Service Type Enum"::"Non-Docs":
                IDYMJSONHelper.AddValue(Document, 'service', 'NON-DOCS');

            IDYSTransportOrderHeader."Service Type Enum"::Envelope:
                IDYMJSONHelper.AddValue(Document, 'service', 'ENVELOPE');

            else
                IDYSTransportOrderHeader.FieldError("Service Type Enum");
        end;

        if IDYSProviderCarrier.Get(IDYSTransportOrderHeader."Carrier Entry No.") then begin
            IDYMJSONHelper.AddValue(Document, 'carrier', IDYSProviderCarrier."Transsmart Carrier Code");
            IDYMJSONHelper.AddValue(Document, 'executingCarrier', IDYSProviderCarrier."Transsmart Carrier Code");
        end;

        if IDYSServiceLevelTime.Get(IDYSTransportOrderHeader."Service Level Code (Time)") then
            IDYMJSONHelper.AddValue(Document, 'serviceLevelTime', IDYSServiceLevelTime."Code");

        if IDYSServiceLevelOther.Get(IDYSTransportOrderHeader."Service Level Code (Other)") then
            IDYMJSONHelper.AddValue(Document, 'serviceLevelOther', IDYSServiceLevelOther."Code");

        if IDYSIncoterm.Get(IDYSTransportOrderHeader."Incoterms Code") then
            IDYMJSONHelper.AddValue(Document, 'incoterms', IDYSIncoterm."Code");

        if IDYSCostCenter.Get(IDYSTransportOrderHeader."Cost Center") then
            IDYMJSONHelper.AddValue(Document, 'costCenter', IDYSCostCenter."Code");

        if IDYSTransportOrderHeader.Insure then
            IDYMJSONHelper.AddValue(Document, 'insurance', IDYSTransportOrderHeader.Insure);

        LanguageCode := FindLanguageCode(IDYSTransportOrderHeader);
        if LanguageCode <> '' then
            IDYMJSONHelper.AddValue(Document, 'language', LowerCase(LanguageCode));

        // Pickup Date/Time
        if DT2Date(IDYSTransportOrderHeader."Preferred Pick-up Date From") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Pick-up Date From", StrSubstNo(DateErr, Today));
        if DT2Date(IDYSTransportOrderHeader."Preferred Pick-up Date To") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Pick-up Date To", StrSubstNo(DateErr, Today));
        IDYMJSONHelper.AddValue(Document, 'pickupDate', DT2Date(IDYSTransportOrderHeader."Preferred Pick-up Date From"));
        IDYMJSONHelper.AddValue(Document, 'pickupTime', FormatTime(IDYSTransportOrderHeader."Preferred Pick-up Date From"));
        IDYMJSONHelper.AddValue(Document, 'pickupTimeTo', FormatTime(IDYSTransportOrderHeader."Preferred Pick-up Date To"));

        // Delivery Date/Time
        if DT2Date(IDYSTransportOrderHeader."Preferred Delivery Date From") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Delivery Date From", StrSubstNo(DateErr, Today));
        if DT2Date(IDYSTransportOrderHeader."Preferred Delivery Date To") < Today then
            IDYSTransportOrderHeader.FieldError("Preferred Delivery Date To", StrSubstNo(DateErr, Today));
        IDYMJSONHelper.AddValue(Document, 'requestedDeliveryDate', DT2Date(IDYSTransportOrderHeader."Preferred Delivery Date From"));
        IDYMJSONHelper.AddValue(Document, 'requestedDeliveryTime', FormatTime(IDYSTransportOrderHeader."Preferred Delivery Date From"));
        IDYMJSONHelper.AddValue(Document, 'requestedDeliveryTimeTo', FormatTime(IDYSTransportOrderHeader."Preferred Delivery Date To"));

        // Pickup address
        Clear(Address);
        IDYMJSONHelper.AddValue(Address, 'type', 'SEND');
        if IDYSTransportOrderHeader."Account No. (Pick-up)" <> '' then
            IDYMJSONHelper.AddValue(Address, 'accountNumber', IDYSTransportOrderHeader."Account No. (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'name', CopyStr(IDYSTransportOrderHeader."Name (Pick-up)", 1, 64));
        IDYMJSONHelper.AddValue(Address, 'addressLine1', CopyStr(IDYSTransportOrderHeader."Street (Pick-up)", 1, 64));
        IDYMJSONHelper.AddValue(Address, 'houseNo', CopyStr(IDYSTransportOrderHeader."House No. (Pick-up)", 1, 16));
        IDYMJSONHelper.AddValue(Address, 'addressLine2', CopyStr(IDYSTransportOrderHeader."Address 2 (Pick-up)", 1, 64));
        IDYMJSONHelper.AddValue(Address, 'city', IDYSTransportOrderHeader."City (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'zipCode', CopyStr(IDYSTransportOrderHeader."Post Code (Pick-up)", 1, 16));
        IDYMJSONHelper.AddValue(Address, 'state', CopyStr(IDYSTransportOrderHeader."County (Pick-up)", 1, 16));
        IDYMJSONHelper.AddValue(Address, 'country', IDYSTransportOrderMgt.GetMappedCountryCode(IDYSTransportOrderHeader."Cntry/Rgn. Code (Pick-up) (TS)"));
        IDYMJSONHelper.AddValue(Address, 'contact', CopyStr(IDYSTransportOrderHeader."Contact (Pick-up)", 1, 64));
        if IDYSTransportOrderHeader."Mobile Phone No. (Pick-up)" <> '' then
            IDYMJSONHelper.AddValue(Address, 'telNo', IDYSTransportOrderHeader."Mobile Phone No. (Pick-up)")
        else
            IDYMJSONHelper.AddValue(Address, 'telNo', IDYSTransportOrderHeader."Phone No. (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'faxNo', IDYSTransportOrderHeader."Fax No. (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'email', IDYSTransportOrderHeader."E-Mail (Pick-up)");
        IDYMJSONHelper.AddValue(Address, 'vatNumber', IDYSTransportOrderHeader."VAT Registration No. (Pick-up)");
        if IDYSTransportOrderHeader."EORI Number (Pick-up)" <> '' then
            IDYMJSONHelper.AddValue(Address, 'eoriNumber', IDYSTransportOrderHeader."EORI Number (Pick-up)");
        if IDYSTransportOrderHeader."Source Type (Pick-up)" = IDYSTransportOrderHeader."Source Type (Pick-up)"::Customer then
            IDYMJSONHelper.AddValue(Address, 'customerNumber', IDYSTransportOrderHeader."No. (Pick-up)");
        IDYMJSONHelper.Add(Addresses, Address);

        // Delivery address
        Clear(Address);
        IDYMJSONHelper.AddValue(Address, 'type', 'RECV');
        if IDYSTransportOrderHeader."Account No." <> '' then
            IDYMJSONHelper.AddValue(Address, 'accountNumber', IDYSTransportOrderHeader."Account No.");  // Ship-to
        IDYMJSONHelper.AddValue(Address, 'name', CopyStr(IDYSTransportOrderHeader."Name (Ship-to)", 1, 64));
        IDYMJSONHelper.AddValue(Address, 'addressLine1', CopyStr(IDYSTransportOrderHeader."Street (Ship-to)", 1, 64));
        IDYMJSONHelper.AddValue(Address, 'houseNo', CopyStr(IDYSTransportOrderHeader."House No. (Ship-to)", 1, 16));
        IDYMJSONHelper.AddValue(Address, 'addressLine2', CopyStr(IDYSTransportOrderHeader."Address 2 (Ship-to)", 1, 64));
        IDYMJSONHelper.AddValue(Address, 'city', IDYSTransportOrderHeader."City (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'zipCode', CopyStr(IDYSTransportOrderHeader."Post Code (Ship-to)", 1, 16));
        IDYMJSONHelper.AddValue(Address, 'state', CopyStr(IDYSTransportOrderHeader."County (Ship-to)", 1, 16));
        IDYMJSONHelper.AddValue(Address, 'country', IDYSTransportOrderMgt.GetMappedCountryCode(IDYSTransportOrderHeader."Cntry/Rgn. Code (Ship-to) (TS)"));
        IDYMJSONHelper.AddValue(Address, 'contact', CopyStr(IDYSTransportOrderHeader."Contact (Ship-to)", 1, 64));
        if IDYSTransportOrderHeader."Mobile Phone No. (Ship-to)" <> '' then
            IDYMJSONHelper.AddValue(Address, 'telNo', IDYSTransportOrderHeader."Mobile Phone No. (Ship-to)")
        else
            IDYMJSONHelper.AddValue(Address, 'telNo', IDYSTransportOrderHeader."Phone No. (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'faxNo', IDYSTransportOrderHeader."Fax No. (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'email', IDYSTransportOrderHeader."E-Mail (Ship-to)");
        IDYMJSONHelper.AddValue(Address, 'vatNumber', IDYSTransportOrderHeader."VAT Registration No. (Ship-to)");
        if IDYSTransportOrderHeader."EORI Number (Ship-to)" <> '' then
            IDYMJSONHelper.AddValue(Address, 'eoriNumber', IDYSTransportOrderHeader."EORI Number (Ship-to)");
        if IDYSTransportOrderHeader."Source Type (Ship-to)" = IDYSTransportOrderHeader."Source Type (Ship-to)"::Customer then
            IDYMJSONHelper.AddValue(Address, 'customerNumber', IDYSTransportOrderHeader."No. (Ship-to)");
        IDYMJSONHelper.Add(Addresses, Address);

        // Invoice address
        Clear(Address);
        IDYMJSONHelper.AddValue(Address, 'type', 'INVC');
        if (IDYSTransportOrderHeader."Account No. (Invoice)" <> '') and (IDYSTransportOrderHeader."Account No. (Invoice)" <> IDYSTransportOrderHeader."Account No.") then
            IDYMJSONHelper.AddValue(Address, 'accountNumber', IDYSTransportOrderHeader."Account No. (Invoice)");
        IDYMJSONHelper.AddValue(Address, 'name', CopyStr(IDYSTransportOrderHeader."Name (Invoice)", 1, 64));
        IDYMJSONHelper.AddValue(Address, 'addressLine1', CopyStr(IDYSTransportOrderHeader."Street (Invoice)", 1, 64));
        IDYMJSONHelper.AddValue(Address, 'houseNo', CopyStr(IDYSTransportOrderHeader."House No. (Invoice)", 1, 16));
        IDYMJSONHelper.AddValue(Address, 'addressLine2', CopyStr(IDYSTransportOrderHeader."Address 2 (Invoice)", 1, 64));
        IDYMJSONHelper.AddValue(Address, 'city', IDYSTransportOrderHeader."City (Invoice)");
        IDYMJSONHelper.AddValue(Address, 'zipCode', CopyStr(IDYSTransportOrderHeader."Post Code (Invoice)", 1, 16));
        IDYMJSONHelper.AddValue(Address, 'state', CopyStr(IDYSTransportOrderHeader."County (Invoice)", 1, 16));
        IDYMJSONHelper.AddValue(Address, 'country', IDYSTransportOrderMgt.GetMappedCountryCode(IDYSTransportOrderHeader."Cntry/Rgn. Code (Invoice) (TS)"));
        IDYMJSONHelper.AddValue(Address, 'contact', CopyStr(IDYSTransportOrderHeader."Contact (Invoice)", 1, 64));
        if IDYSTransportOrderHeader."Mobile Phone No. (Invoice)" <> '' then
            IDYMJSONHelper.AddValue(Address, 'telNo', IDYSTransportOrderHeader."Mobile Phone No. (Invoice)")
        else
            IDYMJSONHelper.AddValue(Address, 'telNo', IDYSTransportOrderHeader."Phone No. (Invoice)");
        IDYMJSONHelper.AddValue(Address, 'faxNo', IDYSTransportOrderHeader."Fax No. (Invoice)");
        IDYMJSONHelper.AddValue(Address, 'email', IDYSTransportOrderHeader."E-Mail (Invoice)");
        IDYMJSONHelper.AddValue(Address, 'vatNumber', IDYSTransportOrderHeader."VAT Registration No. (Invoice)");
        if IDYSTransportOrderHeader."Source Type (Invoice)" = IDYSTransportOrderHeader."Source Type (Invoice)"::Customer then
            IDYMJSONHelper.AddValue(Address, 'customerNumber', IDYSTransportOrderHeader."No. (Invoice)");
        IDYMJSONHelper.Add(Addresses, Address);

        // Add the pickup, delivery and invoice addresses to the document
        IDYMJSONHelper.Add(Document, 'addresses', Addresses);

        // // Additional references
        if IDYSTransportOrderHeader."Invoice (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'INVOICE');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Invoice (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Customer Order (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'CUSTOMERORDER');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Customer Order (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Order No. (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'ORDER');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Order No. (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Delivery Note (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'DELIVERYNOTE');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Delivery Note (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Delivery Id (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'DELIVERYID');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Delivery Id (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Other (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'OTHER');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Other (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Service Point (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'SERVICEPOINT');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Service Point (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Project (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'PROJECT');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Project (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Your Reference (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'YOUR_REFERENCE');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Your Reference (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Engineer (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'ENGINEER');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Engineer (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Agent (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'AGENTREFERENCE');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Agent (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Customer (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'CUSTOMER');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Customer (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Driver ID (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'DRIVER_ID');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Driver ID (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;
        if IDYSTransportOrderHeader."Route ID (Ref)" <> '' then begin
            Clear(AdditionalRef);
            IDYMJSONHelper.AddValue(AdditionalRef, 'type', 'ROUTE_ID');
            IDYMJSONHelper.AddValue(AdditionalRef, 'value', IDYSTransportOrderHeader."Route ID (Ref)");
            IDYMJSONHelper.Add(additionalRefs, AdditionalRef);
        end;

        // Add the additional references
        if additionalRefs.Count > 0 then
            IDYMJSONHelper.Add(Document, 'additionalReferences', additionalRefs);

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitDocumentFromIDYSTransportOrderHeader(Document, IDYSTransportOrderHeader);
    end;

    local procedure InitPackagesFromTransportOrderPackages(var document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        Packages: JsonArray;
        Package: JsonObject;
        AdditionalReference: JsonObject;
        AdditionalReferences: JsonArray;
        Measurements: JsonObject;
        LineNo: Integer;
        Weight: Decimal;
        TotalWeight: Decimal;
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
                LineNo += 1;

                Clear(Package);
                IDYMJSONHelper.AddValue(Package, 'lineNo', LineNo);
                IDYMJSONHelper.AddValue(Package, 'packageType', TransportOrderPackage."Package Type");
                IDYMJSONHelper.AddValue(Package, 'quantity', 1);
                IDYMJSONHelper.AddValue(Package, 'description', TransportOrderPackage.Description);
                if TransportOrderPackage."License Plate No." <> '' then begin
                    Clear(AdditionalReferences);
                    Clear(AdditionalReference);
                    IDYMJSONHelper.AddValue(AdditionalReference, 'type', 'DELIVERYID');
                    IDYMJSONHelper.AddValue(AdditionalReference, 'value', TransportOrderPackage."License Plate No.");
                    IDYMJSONHelper.Add(AdditionalReferences, AdditionalReference);
                    IDYMJSONHelper.Add(Package, 'additionalReferences', AdditionalReferences);
                end;

                Clear(Measurements);
                IDYMJSONHelper.AddValue(Measurements, 'length', TransportOrderPackage.Length);
                IDYMJSONHelper.AddValue(Measurements, 'width', TransportOrderPackage.Width);
                IDYMJSONHelper.AddValue(Measurements, 'height', TransportOrderPackage.Height);

                Weight := TransportOrderPackage.GetPackageWeight();
                TotalWeight += Weight;
                IDYMJSONHelper.AddValue(Measurements, 'weight', Weight);
                IDYMJSONHelper.AddValue(Measurements, 'linearUom', TransportOrderPackage."Linear UOM");
                IDYMJSONHelper.AddValue(Measurements, 'massUom', TransportOrderPackage."Mass UOM");
                IDYMJSONHelper.Add(Package, 'measurements', Measurements);

                if IDYSSetup."Link Del. Lines with Packages" then
                    InitLinkedDeliveryNotesFromTransportOrderPackages(Package, IDYSTransportOrderHeader, TransportOrderPackage);

                IDYMJSONHelper.Add(Packages, Package);

                // Create a link between shipment line number and transport order package before the booking
                if ApplyExternalId then begin
                    TransportOrderPackage.Validate("External ID", LineNo);
                    TransportOrderPackage.Modify();
                end;
            until TransportOrderPackage.Next() = 0;

            IDYMJSONHelper.Add(Document, 'packages', Packages);

            Clear(Measurements);
            IDYMJSONHelper.AddValue(Measurements, 'numberOfPackages', TransportOrderPackage.Count());
            IDYMJSONHelper.AddValue(Measurements, 'calculatedWeight', TotalWeight);
            IDYMJSONHelper.Add(Document, 'measurements', Measurements);
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitPackagesFromTransportOrderPackages(Document, IDYSTransportOrderHeader);
    end;

    local procedure InitPackagesFromSalesOrderPackages(var document: JsonObject; var SalesHeader: Record "Sales Header");
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        Packages: JsonArray;
        Package: JsonObject;
        Measurements: JsonObject;
        LineNo: Integer;
        TotalWeight: Decimal;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitPackagesFromSalesOrderPackages(Document, SalesHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        SourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        SourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        SourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
        if SourceDocumentPackage.FindSet() then begin
            repeat
                LineNo += 1;

                Clear(Package);
                IDYMJSONHelper.AddValue(Package, 'lineNo', LineNo);
                IDYMJSONHelper.AddValue(Package, 'packageType', SourceDocumentPackage."Package Type");
                IDYMJSONHelper.AddValue(Package, 'quantity', 1);
                Clear(Measurements);
                IDYMJSONHelper.AddValue(Measurements, 'length', SourceDocumentPackage.Length);
                IDYMJSONHelper.AddValue(Measurements, 'width', SourceDocumentPackage.Width);
                IDYMJSONHelper.AddValue(Measurements, 'height', SourceDocumentPackage.Height);
                IDYMJSONHelper.AddValue(Measurements, 'weight', SourceDocumentPackage.Weight);
                IDYMJSONHelper.Add(Package, 'measurements', Measurements);

                IDYMJSONHelper.Add(Packages, Package);

                TotalWeight += SourceDocumentPackage.Weight;
            until SourceDocumentPackage.Next() = 0;

            // There are no links (Package Content) at the Sales Order level
            // Not calculating the total weight when it is mandatory to specify the package content can reflect in the price differences
            if IDYSSetup."Link Del. Lines with Packages" then
                TotalWeight += IDYSDocumentMgt.GetCalculatedWeight(SalesHeader);

            IDYMJSONHelper.AddValue(Document, 'numberOfPackages', SourceDocumentPackage.Count());
            IDYMJSONHelper.AddValue(Document, 'weight', TotalWeight);
            IDYMJSONHelper.AddValue(Document, 'calculatedWeight', TotalWeight);
            IDYMJSONHelper.AddValue(Document, 'linearUom', SourceDocumentPackage."Linear UOM");
            IDYMJSONHelper.AddValue(Document, 'massUom', SourceDocumentPackage."Mass UOM");
            IDYMJSONHelper.Add(Document, 'packages', Packages);
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitPackagesFromSalesOrderPackages(Document, SalesHeader);
    end;

    local procedure InitDeliveryNotesFromTransportOrderDeliveryNotes(var document: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        deliveryNoteInfo: JsonArray;
        deliveryNoteInfoLine: JsonObject;
        deliveryNoteInformation: JsonObject;
        LineNo: Integer;
        TotalPrice: Decimal;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitDeliveryNotesFromTransportOrderDeliveryNotes(Document, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        IDYSTransportOrderDelNote.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderDelNote.FindSet() then begin
            TotalPrice := 0;
            repeat
                deliveryNoteInfoLine := InitDeliveryNote(IDYSTransportOrderHeader, IDYSTransportOrderDelNote, LineNo, TotalPrice);
                IDYMJSONHelper.Add(deliveryNoteInfo, deliveryNoteInfoLine);
            until IDYSTransportOrderDelNote.Next() = 0;
            IDYMJSONHelper.AddValue(DeliveryNoteInformation, 'currency', IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)");
            IDYMJSONHelper.AddValue(DeliveryNoteInformation, 'price', TotalPrice);
            IDYMJSONHelper.Add(DeliveryNoteInformation, 'deliveryNoteLines', deliveryNoteInfo);
            IDYMJSONHelper.Add(document, 'deliveryNoteInformation', DeliveryNoteInformation);
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitDeliveryNotesFromTransportOrderDeliveryNotes(Document, IDYSTransportOrderHeader);
    end;

    local procedure InitDeliveryNote(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note"; var LineNo: Integer; var TotalPrice: Decimal) deliveryNoteInfoLine: JsonObject
    var
        IDYSTransportOrderLine: Record "IDYS Transport Order Line";
        Currency: Record Currency;
        TransferShipmentHeader: Record "Transfer Shipment Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        IsHandled: Boolean;
        IncludeReturnable: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitDeliveryNote(IDYSTransportOrderHeader, IDYSTransportOrderDelNote, LineNo, TotalPrice, deliveryNoteInfoLine, IsHandled);
            if IsHandled then
                exit(deliveryNoteInfoLine);
        end;

        GetSetup();

        LineNo += 1;
        if IDYSTransportOrderDelNote.Currency <> '' then begin
            Currency.Get(IDYSTransportOrderDelNote.Currency);
            Currency.TestField("Amount Rounding Precision");
        end else
            Currency.InitRoundingPrecision();
        TotalPrice := TotalPrice + Round(IDYSTransportOrderDelNote.Price * IDYSTransportOrderDelNote.Quantity, Currency."Amount Rounding Precision");
        Clear(deliveryNoteInfoLine);
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'lineNumber', LineNo);
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'price', IDYSTransportOrderDelNote.Price);
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'articleId', IDYSTransportOrderDelNote."Article Id");
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'countryOrigin', IDYSTransportOrderDelNote."Country of Origin");
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'description', IDYSTransportOrderDelNote.Description);
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'quantity', IDYSTransportOrderDelNote.Quantity);
        if IDYSSetup."Enable Beta features" then
            IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'quantityUom', IDYSTransportOrderDelNote."Quantity UOM");
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'quantityBackorder', IDYSTransportOrderDelNote."Quantity Backorder");
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'quantityOrder', IDYSTransportOrderDelNote."Quantity Order");
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'grossWeight', Round(IDYSTransportOrderDelNote."Gross Weight" * IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No."), IDYSProviderMgt.GetRoundingPrecision("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.")));
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'nettWeight', Round(IDYSTransportOrderDelNote."Net Weight" * IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No."), IDYSProviderMgt.GetRoundingPrecision("IDYS Conversion Type"::Mass, IDYSTransportOrderHeader."Carrier Entry No.")));
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'serialNumber', IDYSTransportOrderDelNote."Serial No.");
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'hsCode', IDYSTransportOrderDelNote."HS Code");
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'articleName', IDYSTransportOrderDelNote."Article Name");
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'reasonOfExport', IDYSTransportOrderDelNote."Reason of Export");
        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'currency', IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)");
        if IDYSSetup."Enable Beta features" then begin
            IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'nettPrice', IDYSTransportOrderDelNote.Price);
            if IDYSTransportOrderDelNote."Quantity m2" <> 0 then
                IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'quantityM2', IDYSTransportOrderDelNote."Quantity m2");
            if IDYSTransportOrderDelNote."Item Reference No." <> '' then
                IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'articleEanCode', IDYSTransportOrderDelNote."Item Reference No.");
            if IDYSTransportOrderDelNote.Quality <> '' then
                IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'quality', IDYSTransportOrderDelNote.Quality);
            if IDYSTransportOrderDelNote.Composition <> '' then
                IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'composition', IDYSTransportOrderDelNote.Composition);
            if IDYSTransportOrderDelNote."Assembly Instructions" <> '' then
                IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'assemblyInstructions', IDYSTransportOrderDelNote."Assembly Instructions");
            if IDYSTransportOrderDelNote."Weight UOM" <> '' then
                IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'weightUom', IDYSTransportOrderDelNote."Weight UOM");
            if IDYSTransportOrderDelNote."HS Code Description" <> '' then
                IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'hsCodeDescription', IDYSTransportOrderDelNote."HS Code Description");
            OnBeforeSetReturnable(IDYSTransportOrderDelNote, IncludeReturnable);
            if IncludeReturnable then
                IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'returnable', IDYSTransportOrderDelNote.Returnable);
        end;
        if (IDYSTransportOrderDelNote."Transport Order Line No." <> 0) and
            IDYSTransportOrderLine.Get(IDYSTransportOrderDelNote."Transport Order No.", IDYSTransportOrderDelNote."Transport Order Line No.")
        then
            case IDYSTransportOrderLine."Source Document Table No." of
                Database::"Transfer Shipment Header":
                    if TransferShipmentHeader.Get(IDYSTransportOrderLine."Source Document No.") and
                        (TransferShipmentHeader."Transfer Order No." <> '')
                    then
                        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'customerOrder', TransferShipmentHeader."Transfer Order No.")
                    else
                        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'customerOrder', IDYSTransportOrderLine."Source Document No.");
                Database::"Sales Shipment Header":
                    if SalesShipmentHeader.Get(IDYSTransportOrderLine."Source Document No.") and
                        (SalesShipmentHeader."Order No." <> '')
                    then
                        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'customerOrder', SalesShipmentHeader."Order No.")
                    else
                        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'customerOrder', IDYSTransportOrderLine."Source Document No.");
                Database::"Return Shipment Header":
                    if ReturnShipmentHeader.Get(IDYSTransportOrderLine."Source Document No.") and
                        (ReturnShipmentHeader."Return Order No." <> '')
                    then
                        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'customerOrder', ReturnShipmentHeader."Return Order No.")
                    else
                        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'customerOrder', IDYSTransportOrderLine."Source Document No.");
                Database::"Service Shipment Header":
                    if ServiceShipmentHeader.Get(IDYSTransportOrderLine."Source Document No.") and
                        (ServiceShipmentHeader."Order No." <> '')
                    then
                        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'customerOrder', ServiceShipmentHeader."Order No.")
                    else
                        IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'customerOrder', IDYSTransportOrderLine."Source Document No.");
                else
                    IDYMJSONHelper.AddValue(deliveryNoteInfoLine, 'customerOrder', IDYSTransportOrderLine."Source Document No.");
            end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitDeliveryNote(IDYSTransportOrderHeader, IDYSTransportOrderDelNote, LineNo, TotalPrice, deliveryNoteInfoLine);
    end;

    local procedure FindLanguageCode(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") LanguageCode: Text
    var
        IDYSLanguageMapping: Record "IDYS Language Mapping";
        Customer: Record Customer;
        IsHandled: Boolean;
    begin
        OnBeforeFindLanguageCode(IDYSTransportOrderHeader, LanguageCode, IsHandled);
        if IsHandled then
            exit(LanguageCode);

        // Use Customer language code
        if IDYSTransportOrderHeader."Source Type (Ship-to)" = IDYSTransportOrderHeader."Source Type (Ship-to)"::Customer then
            if Customer.Get(IDYSTransportOrderHeader."No. (Ship-to)") then
                if IDYSLanguageMapping.Get(Customer."Language Code") then
                    exit(IDYSLanguageMapping."Language Code (External)");
    end;

    #region [Linked Delivery Notes]
    local procedure InitLinkedDeliveryNotesFromTransportOrderPackages(var Package: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var TransportOrderPackage: Record "IDYS Transport Order Package");
    var
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        deliveryNoteInfo: JsonArray;
        deliveryNoteInformation: JsonObject;
        deliveryNoteInfoLine: JsonObject;
        TotalPrice: Decimal;
        LineNo: Integer;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInitLinkedDeliveryNotesFromTransportOrderPackages(Package, IDYSTransportOrderHeader, TransportOrderPackage, IsHandled);
            if IsHandled then
                exit;
        end;

        IDYSTransportOrderDelNote.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSTransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", TransportOrderPackage.RecordId);
        if IDYSTransportOrderDelNote.FindSet() then begin
            TotalPrice := 0;
            repeat
                deliveryNoteInfoLine := InitDeliveryNote(IDYSTransportOrderHeader, IDYSTransportOrderDelNote, LineNo, TotalPrice);
                IDYMJSONHelper.Add(deliveryNoteInfo, deliveryNoteInfoLine);
            until IDYSTransportOrderDelNote.Next() = 0;
            IDYMJSONHelper.AddValue(DeliveryNoteInformation, 'currency', IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)");
            IDYMJSONHelper.AddValue(DeliveryNoteInformation, 'price', TotalPrice);
            IDYMJSONHelper.Add(DeliveryNoteInformation, 'deliveryNoteLines', deliveryNoteInfo);
            IDYMJSONHelper.Add(Package, 'deliveryNoteInfo', DeliveryNoteInformation);
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInitLinkedDeliveryNotesFromTransportOrderPackages(Package, IDYSTransportOrderHeader, TransportOrderPackage);
    end;
    #endregion

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
        IDYMAppLicenseKey: Record "IDYM App License Key";
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        LicenseCheck: Codeunit "IDYS License Check";
        RequestDocuments: JsonArray;
        ErrorMessage: Text;
        IsHandled: Boolean;
    begin
        IDYSSetup.Get();

        ValidateTransportOrder(IDYSTransportOrderHeader);

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeCreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        ApplyExternalId := true;
        InitDocumentFromIDYSTransportOrderHeader(RequestDocument, IDYSTransportOrderHeader);
        InitPackagesFromTransportOrderPackages(RequestDocument, IDYSTransportOrderHeader);
        if not IDYSSetup."Link Del. Lines with Packages" then
            InitDeliveryNotesFromTransportOrderDeliveryNotes(RequestDocument, IDYSTransportOrderHeader);
        RequestDocuments.Add(RequestDocument);

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

        //POST the document
        ResponseDocument := PostDocument(IDYSTransportOrderHeader, RequestDocuments, AllowLogging);

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
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterBooking(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        GetSetup();
        exit(HandleResponseAfterCreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument));
    end;

    procedure HandleResponseAfterCreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject) ReturnValue: Boolean
    var
        IDYMAppLicenseKey: Record "IDYM App License Key";
        Document: JsonObject;
        IsHandled: Boolean;
    begin
        Document := GetStatus(IDYSTransportOrderHeader, false, false);

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterCreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, Document, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        // Update transport order header with the information from Transsmart
        UpdateDocumentHeader(IDYSTransportOrderHeader, Document);

        case HttpStatusCode of
            403, 500 .. 511:
                if IDYMAppLicenseKey.Get(IDYSSetup."License Entry No.") and (IDYMAppLicenseKey."License Grace Period Start" = 0DT) then begin
                    IDYMAppLicenseKey.Validate("License Grace Period Start", CurrentDateTime());
                    IDYMAppLicenseKey.Modify();
                end;
            0, 200:
                if IDYMAppLicenseKey.Get(IDYSSetup."License Entry No.") and (IDYMAppLicenseKey."License Grace Period Start" <> 0DT) then begin
                    Clear(IDYMAppLicenseKey."License Grace Period Start");
                    IDYMAppLicenseKey.Modify();
                end;
        end;

        exit(true);
    end;

    procedure CreateDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Documents: JsonArray; var Document: JsonObject) ReturnValue: Boolean;
    var
        IsHandled: Boolean;
    begin
        OnBeforeCreateDocument(IDYSTransportOrderHeader, Documents, Document, ReturnValue, IsHandled);
        if IsHandled then
            exit;

        IDYSSetup.Get();

        IDYSTransportOrderHeader.TestField(Status, IDYSTransportOrderHeader.Status::New);

        InitDocumentFromIDYSTransportOrderHeader(Document, IDYSTransportOrderHeader);
        InitPackagesFromTransportOrderPackages(Document, IDYSTransportOrderHeader);
        if not IDYSSetup."Link Del. Lines with Packages" then
            InitDeliveryNotesFromTransportOrderDeliveryNotes(Document, IDYSTransportOrderHeader);
        Documents.Add(Document);
        exit(true);
    end;

    #region [Synchronize]
    procedure Synchronize(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean) ReturnJsonObject: JsonObject
    var
        InsuranceResponse: JsonToken;
    begin
        GetSetup();

        ReturnJsonObject := GetStatus(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry);

        // Get Insurance Information
        if IDYSTransportOrderHeader.Insure and (IDYSTransportOrderHeader.Status >= IDYSTransportOrderHeader.Status::"Label Printed") then
            if GetInsuranceInformation(IDYSTransportOrderHeader, InsuranceResponse) then begin
                HandleResponseAfterGetInsuranceInformation(IDYSTransportOrderHeader, InsuranceResponse);
                IDYSTransportOrderHeader.Modify();
            end;
    end;

    procedure GetStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean): JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Document: JsonObject;
        EndpointTxt: Label '/v2/statuses/%1/shipments/%2?isDetailed=Yes&currentStatusOnly=Yes', Locked = true;
        EmptyRequestDocument: JsonObject;
        ReturnValue: JsonObject;
        IsHandled: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeGetStatus(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code", IDYSTransportOrderHeader."No."), false, IDYSSetup, TempIDYMRESTParameters, BaseURI::Transsmart);
        if TempIDYMRESTParameters."Status Code" <> 200 then begin
            if WriteLogEntry and TempIDYMRESTParameters.GetResponseBodyAsJSON().IsObject() then begin
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", ErrorSynchronizeTxt, LoggingLevel::Information, EmptyRequestDocument, TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
                Commit();
            end;
            TranssmartErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), false);
        end;

        Document := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();

        if WriteLogEntry then begin
            if IDYSSetup."Enable Debug Mode" then
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", SynchronizeTxt, LoggingLevel::Information, EmptyRequestDocument, Document)
            else
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", SynchronizeTxt, LoggingLevel::Information);
            Commit();
        end;

        if UpdateHeader then
            UpdateDocumentHeader(IDYSTransportOrderHeader, Document);

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
            '', 'NONE':
                TransportOrderHeader.Status := TransportOrderHeader.Status::New;
            'NEW':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Uploaded;
            'BOOK':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Booked;
            'LABL':
                TransportOrderHeader.Status := TransportOrderHeader.Status::"Label Printed";
            'REFU', 'DEL':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Recalled;
            'DONE', 'APOD':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Done;
            'ERR':
                TransportOrderHeader.Status := TransportOrderHeader.Status::Error;
            'ONHOLD':
                TransportOrderHeader.Status := TransportOrderHeader.Status::"On Hold";
        end;

        // Transsmart API doesn't necessarily change status to booked when a shipment is booked.
        // If the Tracking No. is filled in, however, the shipment should be considered "booked".
        if (TransportOrderHeader.Status = TransportOrderHeader.Status::Uploaded) and (TransportOrderHeader."Tracking No." <> '') then
            TransportOrderHeader.Status := TransportOrderHeader.Status::Booked;

        TransportOrderHeader.Validate(Status);
        OnAfterUpdateStatus(TransportOrderHeader);
    end;

    local procedure UpdateStatus(Document: JsonObject; var SubStatus: Text[256]) Status: Text[150]
    var
        Statuses: JsonArray;
        StatusJsonToken: JsonToken;
        SubStatusJsonObject: JsonObject;
    begin
        Statuses := IDYMJSONHelper.GetArray(Document, 'statuses');
        if Statuses.Get(0, StatusJsonToken) then begin
            Status := CopyStr(IDYMJSONHelper.GetCodeValue(StatusJsonToken, 'code'), 1, 150);
            if IDYMJSONHelper.TryGetObject(StatusJsonToken.AsObject(), 'subStatus') = 1 then begin
                SubStatusJsonObject := IDYMJSONHelper.GetObject(StatusJsonToken.AsObject(), 'subStatus');
                SubStatus := CopyStr(IDYMJSONHelper.GetTextValue(SubStatusJsonObject, 'description'), 1, 256);
            end;
        end;
    end;
    #endregion
    procedure UpdateDocumentHeader(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Document: JsonObject)
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        ProviderCarrier: Record "IDYS Provider Carrier";
        ShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        ProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSTransportOrderHdrMgt: Codeunit "IDYS Transport Order Hdr. Mgt.";
        IDYSPublisher: Codeunit "IDYS Publisher";
        ShipmentLines: JsonArray;
        ShipmentLine: JsonToken;
        SubStatus: Text[256];
        Cntr: Integer;
        IsHandled: Boolean;
        RecalcMapping: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeUpdateDocumentHeader(IDYSTransportOrderHeader, Document, IsHandled);
            if IsHandled then
                exit;
        end;

        // Update
        if ShipAgentMapping.Get(IDYSTransportOrderHeader."Shipping Agent Code") then
            RecalcMapping := ShipAgentMapping."Carrier Entry No." <> IDYSTransportOrderHeader."Carrier Entry No.";

        IDYSTransportOrderHeader.CalcFields("Carrier Code (Ext.)");
        if RecalcMapping or (IDYSTransportOrderHeader."Carrier Code (Ext.)" <> IDYMJSONHelper.GetCodeValue(Document, 'carrier')) then begin
            ProviderCarrier.SetRange(Provider, ProviderCarrier.Provider::Transsmart);
            ProviderCarrier.SetRange("Transsmart Carrier Code", CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'carrier'), 1, MaxStrLen(IDYSTransportOrderHeader."Carrier Code (Ext.)")));
            if ProviderCarrier.FindFirst() then begin
                IDYSTransportOrderHeader.Validate("Carrier Entry No.", ProviderCarrier."Entry No.");
                ShipAgentMapping.Reset();
                ShipAgentMapping.SetRange(Provider, ShipAgentMapping.Provider::Transsmart);
                ShipAgentMapping.SetRange("Carrier Entry No.", ProviderCarrier."Entry No.");
                if ShipAgentMapping.Count() = 1 then begin
                    ShipAgentMapping.FindFirst();
                    IDYSTransportOrderHeader.Validate("Shipping Agent Code", ShipAgentMapping."Shipping Agent Code");
                end;
            end;
        end;

        RecalcMapping := false;
        if ShipAgentSvcMapping.Get(IDYSTransportOrderHeader."Shipping Agent Code", IDYSTransportOrderHeader."Shipping Agent Service Code") then
            RecalcMapping := (ShipAgentSvcMapping."Booking Profile Entry No." <> IDYSTransportOrderHeader."Booking Profile Entry No.") or
                (ShipAgentSvcMapping."Carrier Entry No." <> IDYSTransportOrderHeader."Carrier Entry No.");

        if RecalcMapping or
           (IDYSTransportOrderHeader."Service Level Code (Time)" <> IDYMJSONHelper.GetCodeValue(Document, 'serviceLevelTime')) or
           (IDYSTransportOrderHeader."Service Level Code (Other)" <> IDYMJSONHelper.GetCodeValue(Document, 'serviceLevelOther'))
        then begin
            ProviderBookingProfile.SetRange(Provider, ProviderBookingProfile.Provider::Transsmart);
            ProviderBookingProfile.SetRange("Carrier Entry No.", IDYSTransportOrderHeader."Carrier Entry No.");
            ProviderBookingProfile.SetRange("Service Level Code (Time)", CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'serviceLevelTime'), 1, MaxStrLen(ProviderBookingProfile."Service Level Code (Time)")));
            ProviderBookingProfile.SetRange("Service Level Code (Other)", CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'serviceLevelOther'), 1, MaxStrLen(ProviderBookingProfile."Service Level Code (Other)")));
            if ProviderBookingProfile.FindFirst() then begin
                if IDYSTransportOrderHeader."Carrier Entry No." <> ProviderBookingProfile."Carrier Entry No." then
                    IDYSTransportOrderHeader.Validate("Carrier Entry No.", ProviderBookingProfile."Carrier Entry No.");
                IDYSTransportOrderHeader.Validate("Booking Profile Entry No.", ProviderBookingProfile."Entry No.");
                ShipAgentSvcMapping.Reset();
                ShipAgentSvcMapping.SetRange("Carrier Entry No.", ProviderBookingProfile."Carrier Entry No.");
                ShipAgentSvcMapping.SetRange("Booking Profile Entry No.", ProviderBookingProfile."Entry No.");
                if ShipAgentSvcMapping.FindFirst() then begin
                    if IDYSTransportOrderHeader."Shipping Agent Code" <> ShipAgentSvcMapping."Shipping Agent Code" then
                        IDYSTransportOrderHeader.Validate("Shipping Agent Code", ShipAgentSvcMapping."Shipping Agent Code");
                    IDYSTransportOrderHeader.Validate("Shipping Agent Service Code", ShipAgentSvcMapping."Shipping Agent Service Code");
                end;
            end;
        end;

        if IDYSTransportOrderHeader."Tracking No." <> IDYMJSONHelper.GetCodeValue(Document, 'airwaybill') then
            IDYSTransportOrderHeader."Tracking No." := CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'airwaybill'), 1, MaxStrLen(IDYSTransportOrderHeader."Tracking No."));

        if IDYSTransportOrderHeader."Tracking Url" <> IDYMJSONHelper.GetTextValue(Document, 'trackAndTraceUrl') then
            IDYSTransportOrderHeader."Tracking Url" := CopyStr(IDYMJSONHelper.GetTextValue(Document, 'trackAndTraceUrl'), 1, MaxStrLen(IDYSTransportOrderHeader."Tracking Url"));

        if IDYSTransportOrderHeader."Accepted By" <> IDYMJSONHelper.GetCodeValue(Document, 'acceptedBy') then
            IDYSTransportOrderHeader."Accepted By" := CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'acceptedBy'), 1, MaxStrLen(IDYSTransportOrderHeader."Accepted By"));

        // Overwrite
        IDYSTransportOrderHeader."Shipmt. Value Curr Code (TS)" := CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'currency'), 1, MaxStrLen(IDYSTransportOrderHeader."Shipmt. Value Curr Code (TS)"));
        IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)" := CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'currency'), 1, MaxStrLen(IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)"));
        IDYSTransportOrderHeader."Spot Price Curr Code (TS)" := CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'currency'), 1, MaxStrLen(IDYSTransportOrderHeader."Spot Price Curr Code (TS)"));
        IDYSTransportOrderHeader."Spot Pr." := IDYMJSONHelper.GetDecimalValue(Document, 'price');
        IDYSTransportOrderHeader."Shipmt. Cost" := IDYMJSONHelper.GetDecimalValue(Document, 'price');
        IDYSTransportOrderHeader."Carrier Weight" := IDYMJSONHelper.GetDecimalValue(Document, 'weight');
        IDYSTransportOrderHeader."Actual Delivery Date" := ConvertDateTime(IDYMJSONHelper.GetTextValue(Document, 'actualDeliveryDate'));
        IDYSTransportOrderHdrMgt.UpdateCurrencies(IDYSTransportOrderHeader);

        // Status update
        IDYSTransportOrderHeader."Status (External)" := CopyStr(UpdateStatus(Document, SubStatus), 1, MaxStrLen(IDYSTransportOrderHeader."Status (External)"));
        IDYSTransportOrderHeader."Sub Status (External)" := SubStatus;
        UpdateStatus(IDYSTransportOrderHeader);

        // shipmentlines update
        if IDYMJSONHelper.TryGetObject(Document, 'shipmentLines') = 2 then begin
            ShipmentLines := IDYMJSONHelper.GetArray(Document, 'shipmentLines');
            for Cntr := 0 to ShipmentLines.Count() - 1 do
                if ShipmentLines.Get(Cntr, ShipmentLine) then begin
                    TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
                    TransportOrderPackage.SetRange("External ID", IDYMJSONHelper.GetIntegerValue(ShipmentLine, 'lineNumber'));
                    if TransportOrderPackage.FindFirst() then begin
                        TransportOrderPackage.Status := CopyStr(UpdateStatus(ShipmentLine.AsObject(), SubStatus), 1, MaxStrLen(TransportOrderPackage.Status));
                        TransportOrderPackage."Sub Status (External)" := SubStatus;
                        TransportOrderPackage."Tracking No." := CopyStr(IDYMJSONHelper.GetCodeValue(ShipmentLine, 'airwaybill'), 1, MaxStrLen(TransportOrderPackage."Tracking No."));
                        if TransportOrderPackage."Accepted By" <> IDYMJSONHelper.GetCodeValue(ShipmentLine, 'acceptedBy') then
                            TransportOrderPackage."Accepted By" := CopyStr(IDYMJSONHelper.GetCodeValue(ShipmentLine, 'acceptedBy'), 1, MaxStrLen(TransportOrderPackage."Accepted By"));
                        TransportOrderPackage."Actual Delivery Date" := ConvertDateTime(IDYMJSONHelper.GetTextValue(Document, 'actualDeliveryDate'));
                        TransportOrderPackage.Modify();
                    end;
                end;
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnUpdateDocumentHeaderOnBeforeModifyTransportOrderHeader(IDYSTransportOrderHeader, Document);
        IDYSTransportOrderHeader.Modify(true);
        IDYSPublisher.OnAfterUpdateTransportOrderFromTransSmart(IDYSTransportOrderHeader);
    end;

    local procedure ConvertDateTime(DateTimeAsText: Text) ReturnDateTime: DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        InputVariant: Variant;
    begin
        if not GetDateTimeValue(DateTimeAsText, ReturnDateTime) then begin
            // This evaluation uses 'nl' as the culture name.
            InputVariant := ReturnDateTime;
            if TypeHelper.Evaluate(InputVariant, DateTimeAsText, '', 'nl') then
                ReturnDateTime := InputVariant;
        end;
    end;

    [TryFunction]
    local procedure GetDateTimeValue(DateTimeAsText: Text; var ReturnDateTime: DateTime)
    begin
        ReturnDateTime := IDYMJSONHelper.GetDateTimeValue(DateTimeAsText);
    end;

    procedure PostDocument(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Documents: JsonArray; AllowLogging: Boolean): JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonArray;
        Document: JsonToken;
        EndpointTxt: Label '/v2/shipments/%1/BOOK', Locked = true;
    begin
        GetSetup();

        TempIDYMRESTParameters.SetRequestContent(Documents);
        IDYSAPIHelper.ExecutePost(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code"), true, TempIDYMRESTParameters, BaseURI::Transsmart);

        PostDocumentSucceeeded := TempIDYMRESTParameters."Status Code" = 200;
        if not PostDocumentSucceeeded then begin
            Documents.Get(0, Document);
            if AllowLogging then begin
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", ErrorBookingTxt, LoggingLevel::Error, Document.AsObject(), TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject());
                Commit();
            end;
            TranssmartErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;

        Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsArray();
        Response.Get(0, Document);
        exit(Document.AsObject());
    end;

    procedure UpdateIDYSTransportOrderHeaderFromDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Document: JsonObject)
    var
        IDYSTransportOrderHdrMgt: Codeunit "IDYS Transport Order Hdr. Mgt.";
        IDYSPublisher: Codeunit "IDYS Publisher";
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeUpdateIDYSTransportOrderHeaderFromDocument(IDYSTransportOrderHeader, Document, IsHandled);
            if IsHandled then
                exit;
        end;

        if IDYSTransportOrderHeader."Tracking No." <> IDYMJSONHelper.GetCodeValue(Document, 'airwayBillNumber') then
            IDYSTransportOrderHeader."Tracking No." := CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'airwayBillNumber'), 1, MaxStrLen(IDYSTransportOrderHeader."Tracking No."));

        if IDYSTransportOrderHeader."Tracking Url" <> IDYMJSONHelper.GetTextValue(Document, 'trackingAndTraceUrl') then
            IDYSTransportOrderHeader."Tracking Url" := CopyStr(IDYMJSONHelper.GetTextValue(Document, 'trackingAndTraceUrl'), 1, MaxStrLen(IDYSTransportOrderHeader."Tracking Url"));

        IDYSTransportOrderHeader."Shipmt. Value Curr Code (TS)" := CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'currency'), 1, MaxStrLen(IDYSTransportOrderHeader."Shipmt. Value Curr Code (TS)"));
        IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)" := CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'currency'), 1, MaxStrLen(IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)"));
        IDYSTransportOrderHeader."Spot Price Curr Code (TS)" := CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'spotPriceCurrency'), 1, MaxStrLen(IDYSTransportOrderHeader."Spot Price Curr Code (TS)"));
        IDYSTransportOrderHeader."Status (External)" := CopyStr(IDYMJSONHelper.GetCodeValue(Document, 'shipmentStatusCode'), 1, MaxStrLen(IDYSTransportOrderHeader."Status (External)"));
        IDYSTransportOrderHeader."Spot Pr." := IDYMJSONHelper.GetDecimalValue(Document, 'spotPrice');
        IDYSTransportOrderHeader."Shipmt. Cost" := IDYMJSONHelper.GetDecimalValue(Document, 'price');
        IDYSTransportOrderHeader."Load Meter" := IDYMJSONHelper.GetDecimalValue(Document, 'loadmeters');

        UpdateStatus(IDYSTransportOrderHeader);
        IDYSTransportOrderHdrMgt.UpdateCurrencies(IDYSTransportOrderHeader);

        if IDYSSessionVariables.CheckAuthorization() then
            OnUpdateTransportOrderHeaderFromDocumentOnBeforeModifyTransportOrderHeader(IDYSTransportOrderHeader, Document);
        IDYSTransportOrderHeader.Modify(true);
        IDYSPublisher.OnAfterUpdateTransportOrderFromTransSmart(IDYSTransportOrderHeader);
    end;

    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary) ReturnValue: JsonArray;
    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        CompletelyShippedErr: Label 'Order is completely shipped already.';
        Document: JsonObject;
        Documents: JsonArray;
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

        CreateDocument(TempIDYSTransportOrderHeader, Documents, Document);
        if SalesHeader."No." <> '' then
            InitPackagesFromSalesOrderPackages(Document, SalesHeader);
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
            IDYSTransportOrderHeader.Status::Uploaded,
            IDYSTransportOrderHeader.Status::Recalled])
        then
            IDYSTransportOrderHeader.FieldError(Status);

        IDYSProviderCarrierSelect.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSProviderCarrierSelect.DeleteAll();

        CreateDocument(IDYSTransportOrderHeader, Documents, Document);
        exit(Documents);
    end;

    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray);
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        ShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        IDYMDataHelper: Codeunit "IDYM Data Helper";
        IDYSTransportOrderHdrMgt: Codeunit "IDYS Transport Order Hdr. Mgt.";
        CheckShippingInformation: Boolean;
        Response: JsonArray;
        RespToken: JsonToken;
        ShipmentRates: JsonArray;
        ShipmentRate: JsonToken;
        DummyObj: JsonObject;
        InsuranceResponse: JsonToken;
        InsuranceAmount: Decimal;
        InsuranceCurrency: Code[10];
        ShipmentCurrency: Code[10];
        ShipmentDetails: JsonObject;
        InsuranceInformationRetrieved: Boolean;
        InsuranceCompany: Text;
        InsuranceCharges: JsonArray;
        InsuranceCharge: JsonToken;
        DateAsText: Text;
        i: Integer;
        IsHandled: Boolean;
        EndpointTxt: Label '/v2/rates/%1', Locked = true;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents, IsHandled);
            if IsHandled then
                exit;
        end;

        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSProvCarrierSelectPck.DeleteAll();

        TempIDYMRESTParameters.SetRequestContent(Documents);
        IDYSAPIHelper.ExecutePost(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code"), true, TempIDYMRESTParameters, BaseURI::Transsmart);
        if TempIDYMRESTParameters."Status Code" <> 200 then begin
            TranssmartErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;
        Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsArray();
        Response.Get(0, RespToken);

        // Get insurance information
        if IDYSTranssmartSetup."Enable Insurance" then
            if GetInsuranceAmount(IDYSTransportOrderHeader, Documents, InsuranceResponse) then begin
                InsuranceInformationRetrieved := true;

                ShipmentDetails := IDYMJSONHelper.GetObject(RespToken, 'shipmentDetails');
                ShipmentCurrency := IDYSTransportOrderHdrMgt.GetCurrencyCode(CopyStr(IDYMJSONHelper.GetTextValue(ShipmentDetails, 'currency'), 1, MaxStrLen(ShipmentCurrency)));
                InsuranceCurrency := IDYSTransportOrderHdrMgt.GetCurrencyCode(CopyStr(IDYMJSONHelper.GetTextValue(InsuranceResponse, 'currency'), 1, MaxStrLen(InsuranceCurrency)));

                InsuranceCompany := IDYMJSONHelper.GetTextValue(InsuranceResponse, 'company');
                InsuranceAmount := CurrencyExchangeRate.ExchangeAmount(IDYMJSONHelper.GetDecimalValue(InsuranceResponse, 'premium'), InsuranceCurrency, ShipmentCurrency, WorkDate());
                if InsuranceResponse.AsObject().Contains('charges') then begin
                    InsuranceCharges := IDYMJSONHelper.GetArray(Response, 'charges');
                    Clear(i);
                    foreach InsuranceCharge in InsuranceCharges do begin
                        i += 1;

                        IDYSProvCarrierSelectPck.Init();
                        IDYSProvCarrierSelectPck."Transport Order No." := IDYSTransportOrderHeader."No.";
                        IDYSProvCarrierSelectPck."Entry No." := i;

                        IDYSProvCarrierSelectPck."Charge Name" := CopyStr(IDYMJSONHelper.GetTextValue(InsuranceCharge, 'name'), 1, MaxStrLen(IDYSProvCarrierSelectPck."Charge Name"));
                        IDYSProvCarrierSelectPck."Charge Amount" := CurrencyExchangeRate.ExchangeAmount(IDYMJSONHelper.GetDecimalValue(InsuranceCharge, 'value'), InsuranceCurrency, ShipmentCurrency, WorkDate());
                        IDYSProvCarrierSelectPck."Transsmart Insurance" := true;
                        IDYSProvCarrierSelectPck.Insert();
                    end;
                end;
            end;

        Clear(i);
        if RespToken.AsObject().Contains('rates') then begin
            ShipmentRates := IDYMJSONHelper.GetArray(RespToken, 'rates');
            foreach ShipmentRate in ShipmentRates do begin
                i += 1;

                IDYSProviderCarrierSelect.Init();
                IDYSProviderCarrierSelect."Transport Order No." := IDYSTransportOrderHeader."No.";
                IDYSProviderCarrierSelect."Line No." := i;
                IDYSProviderCarrierSelect."Transsmart Carrier Code" := CopyStr(IDYMJSONHelper.GetCodeValue(ShipmentRate, 'carrier'), 1, MaxStrLen(IDYSProviderCarrierSelect."Transsmart Carrier Code"));
                IDYSProviderCarrier.SetRange("Transsmart Carrier Code", IDYSProviderCarrierSelect."Transsmart Carrier Code");
                if IDYSProviderCarrier.FindFirst() then
                    IDYSProviderCarrierSelect."Carrier Entry No." := IDYSProviderCarrier."Entry No.";

                IDYSProviderCarrierSelect."Carrier Name" := CopyStr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'carrierDescription'), 1, MaxStrLen(IDYSProviderCarrierSelect."Carrier Name"));
                IDYSProviderCarrierSelect.Description := CopyStr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'description'), 1, MaxStrLen(IDYSProviderCarrierSelect.Description));
                IDYSProviderCarrierSelect."Service Level Code (Time)" := CopyStr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'serviceLevelTime'), 1, MaxStrLen(IDYSProviderCarrierSelect."Service Level Code (Time)"));
                IDYSProviderCarrierSelect."Service Level Time" := CopyStr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'serviceLevelTimeDescription'), 1, MaxStrLen(IDYSProviderCarrierSelect."Service Level Time"));
                IDYSProviderCarrierSelect."Service Level Code (Other)" := CopyStr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'serviceLevelOther'), 1, MaxStrLen(IDYSProviderCarrierSelect."Service Level Code (Other)"));
                IDYSProviderCarrierSelect."Service Level Other" := CopyStr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'serviceLevelOtherDescription'), 1, MaxStrLen(IDYSProviderCarrierSelect."Service Level Other"));
                IDYSProviderCarrierSelect."Price as Decimal" := IDYMJsonHelper.GetDecimalValue(ShipmentRate, 'price');
                DateAsText := IDYMJSONHelper.GetTextValue(ShipmentRate, 'pickupDate');
                if Uppercase(DateAsText) <> 'NOT AVAILABLE' then
                    IDYSProviderCarrierSelect."Pickup Date" := IDYMDataHelper.TextToDate(DateAsText)
                else
                    IDYSProviderCarrierSelect."Not Available" := true;
                DateAsText := IDYMJSONHelper.GetTextValue(ShipmentRate, 'deliveryDate');
                if Uppercase(DateAsText) <> 'NOT AVAILABLE' then
                    IDYSProviderCarrierSelect."Delivery Date" := IDYMDataHelper.TextToDate(DateAsText)
                else
                    IDYSProviderCarrierSelect."Not Available" := true;

                IDYSProviderCarrierSelect."Delivery Time" := IDYMDataHelper.TextToTime(IDYMJSONHelper.GetTextValue(ShipmentRate, 'deliveryTime'));
                IDYSProviderCarrierSelect."Transit Time (Hours)" := copystr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'transitTimeHours'), 1, MaxStrLen(IDYSProviderCarrierSelect."Transit Time (Hours)"));
                IDYSProviderCarrierSelect."Transit Time Description" := copystr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'transitTimeDescription'), 1, MaxStrLen(IDYSProviderCarrierSelect."Transit Time Description"));

                IDYSProviderCarrierSelect."Calculated Weight" := Format(IDYMJSONHelper.GetTextValue(ShipmentRate, 'calculatedWeight'));
                IDYSProviderCarrierSelect."Calculated Weight UOM" := copystr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'calculatedWeightUom'), 1, maxstrlen(IDYSProviderCarrierSelect."Calculated Weight UOM"));

                IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrierSelect."Carrier Entry No.");
                IDYSProviderBookingProfile.SetRange("Service Level Code (Time)", CopyStr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'serviceLevelTime'), 1, MaxStrLen(IDYSProviderCarrierSelect."Service Level Code (Time)")));
                IDYSProviderBookingProfile.SetRange("Service Level Code (Other)", CopyStr(IDYMJSONHelper.GetTextValue(ShipmentRate, 'serviceLevelOther'), 1, MaxStrLen(IDYSProviderCarrierSelect."Service Level Code (Other)")));
                if IDYSProviderBookingProfile.FindFirst() then
                    IDYSProviderCarrierSelect."Booking Profile Entry No." := IDYSProviderBookingProfile."Entry No.";

                if IDYSTranssmartSetup."Enable Insurance" and InsuranceInformationRetrieved then begin
                    IDYSProviderCarrierSelect."Insurance Company" := CopyStr(InsuranceCompany, 1, MaxStrLen(IDYSProviderCarrierSelect."Carrier Name"));
                    IDYSProviderCarrierSelect."Insurance Amount" := InsuranceAmount;

                    if IDYSTransportOrderHeader.IsTemporary() then begin
                        // Sales Order Carrier Selection
                        if not IDYSTransportOrderHeader."Do Not Insure" then begin
                            CheckShippingInformation := true;
                            if IDYSTranssmartSetup."Enable Min. Shipment Amount" then
                                CheckShippingInformation := IDYSTransportOrderHeader.Insure;

                            if CheckShippingInformation then begin
                                ShipAgentMapping.SetRange("Carrier Entry No.", IDYSProviderCarrierSelect."Carrier Entry No.");
                                ShipAgentMapping.SetRange(Insure, true);
                                if not ShipAgentMapping.IsEmpty() then begin
                                    ShipAgentSvcMapping.SetRange("Carrier Entry No.", IDYSProviderCarrierSelect."Carrier Entry No.");
                                    ShipAgentSvcMapping.SetRange("Booking Profile Entry No.", IDYSProviderCarrierSelect."Booking Profile Entry No.");
                                    ShipAgentSvcMapping.SetRange(Insure, true);
                                    if not ShipAgentSvcMapping.IsEmpty() then begin
                                        IDYSProviderCarrierSelect.Insure := true;
                                        IDYSProviderCarrierSelect."Price as Decimal" += InsuranceAmount;
                                    end;
                                end;
                            end;
                        end;
                    end else
                        // Transport Order Carrier Selection
                        if IDYSTransportOrderHeader.Insure then begin
                            IDYSProviderCarrierSelect.Insure := true;
                            IDYSProviderCarrierSelect."Price as Decimal" += InsuranceAmount;
                        end;
                end;

                if IDYSSessionVariables.CheckAuthorization() then
                    OnSelectCarrierOnProviderCarrierSelectInsert(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, ShipmentRate);
                IDYSProviderCarrierSelect.Insert(true);
            end;
        end else
            if RespToken.AsObject().Contains('errors') then begin
                DummyObj := IDYMJSONHelper.GetObject(RespToken, 'errors');
                TranssmartErrorHandler.Parse(DummyObj.AsToken(), GuiAllowed());
                Error('');
            end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents);
    end;

    procedure GetInsuranceAmount(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Documents: JsonArray; var ResponseToken: JsonToken) ReturnValue: Boolean
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonArray;
        ShipmentValue: Decimal;
        IsHandled: Boolean;
        Document: JsonToken;
        EndpointTxt: Label '/v2/rates/%1/insurance?currency=%2&countryFrom=%3&countryTo=%4&value=%5', Locked = true;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeGetInsuranceAmount(IDYSTransportOrderHeader, Documents, ResponseToken, IsHandled, ReturnValue);
            if IsHandled then
                exit(ReturnValue);
        end;

        Documents.Get(0, Document);
        ShipmentValue := Round(IDYMJSONHelper.GetDecimalValue(Document, 'value'), 0.01);
        IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code", IDYSTransportOrderHeader."Shipmt. Value Curr Code (TS)", IDYSTransportOrderHeader."Cntry/Rgn. Code (Pick-up) (TS)", IDYSTransportOrderHeader."Cntry/Rgn. Code (Ship-to) (TS)", Format(ShipmentValue, 0, 9)), false, IDYSSetup, TempIDYMRESTParameters, BaseURI::Transsmart);
        if TempIDYMRESTParameters."Status Code" = 200 then begin
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsArray();
            exit(Response.Get(0, ResponseToken));
        end;
    end;

    procedure GetInsuranceInformation(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var ResponseToken: JsonToken) ReturnValue: Boolean
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IsHandled: Boolean;
        EndpointTxt: Label '/v2/rates/%1/insurance/%2', Locked = true;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeGetInsuranceInformation(IDYSTransportOrderHeader, ResponseToken, IsHandled, ReturnValue);
            if IsHandled then
                exit(ReturnValue);
        end;

        IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code", IDYSTransportOrderHeader."No."), false, IDYSSetup, TempIDYMRESTParameters, BaseURI::Transsmart);
        ResponseToken := TempIDYMRESTParameters.GetResponseBodyAsJSON();
        exit(TempIDYMRESTParameters."Status Code" in [200, 202]);
    end;

    procedure HandleResponseAfterGetInsuranceInformation(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    begin
        IDYSTransportOrderHeader."Insurance Status Description" := CopyStr(IDYMJSONHelper.GetTextValue(Response, 'description'), 1, MaxStrLen(IDYSTransportOrderHeader."Insurance Status Description"));
        IDYSTransportOrderHeader."Insurance Company" := CopyStr(IDYMJSONHelper.GetTextValue(Response, 'company'), 1, MaxStrLen(IDYSTransportOrderHeader."Insurance Company"));
        IDYSTransportOrderHeader."Insurance Amount" := IDYMJSONHelper.GetDecimalValue(Response, 'premium');
        IDYSTransportOrderHeader."Insured Value" := IDYMJSONHelper.GetDecimalValue(Response, 'insuredValue');
        IDYSTransportOrderHeader."Claim Url" := CopyStr(IDYMJSONHelper.GetTextValue(Response, 'claimLink'), 1, MaxStrLen(IDYSTransportOrderHeader."Claim Url"));
        IDYSTransportOrderHeader."Policy Url" := CopyStr(IDYMJSONHelper.GetTextValue(Response, 'policyLink'), 1, MaxStrLen(IDYSTransportOrderHeader."Policy Url"));
    end;

    procedure DoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        API: Enum "IDYS API";
        EndpointTxt: Label '/v2/shipments/%1/%2', Locked = true;
        RecallIsNotAllowedErr: Label 'Recall is not permitted due to applied insurance during the booking process.';
        RecallIsNotAllowedTok: Label '455a2b62-735e-43b0-ab9c-5fd5c8cddbff', Locked = true;
    begin
        GetSetup();
        if IDYSTransportOrderHeader.Insure and (IDYSTransportOrderHeader.Status >= IDYSTransportOrderHeader.Status::"Label Printed") then
            if GuiAllowed() then begin
                IDYSNotificationManagement.SendNotification(RecallIsNotAllowedTok, RecallIsNotAllowedErr);
                Error('');
            end else
                Error(RecallIsNotAllowedErr);

        IDYSAPIHelper.ExecuteDelete(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code", IDYSTransportOrderHeader."No."), TempIDYMRESTParameters, API::Transsmart);

        UpdateStatus(IDYSTransportOrderHeader);
        IDYSTransportOrderHeader.Modify();
        IDYSTransportOrderHeader.CreateLogEntry(RecalledTxt, LoggingLevel::Information);
    end;

    #region [Printing]
    procedure DoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") Printed: Boolean
    var
        Response: JsonToken;
        EndpointTxt: Label '/v2/prints/%1/%2', Locked = true;
    begin
        GetSetup();

        Printed := TryDoLabel(IDYSTransportOrderHeader, StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code", IDYSTransportOrderHeader."No."), Response);
        if Printed then
            HandleResponseAfterPrinting(IDYSTransportOrderHeader, Response);
    end;

    procedure DoLabel(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package") Printed: Boolean
    var
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        Response: JsonToken;
        EndpointPckTxt: Label '/v2/prints/%1/%2/%3', Locked = true;
    begin
        GetSetup();
        IDYSTransportOrderHeader.Get(IDYSTransportOrderPackage."Transport Order No.");

        Printed := TryDoLabel(IDYSTransportOrderHeader, StrSubstNo(EndpointPckTxt, IDYSTranssmartSetup."Transsmart Account Code", IDYSTransportOrderHeader."No.", IDYSTransportOrderPackage."Tracking No."), Response);
        if Printed then
            HandleResponseAfterPrinting(IDYSTransportOrderPackage, Response);
    end;

    procedure TryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Response: JsonToken) Printed: Boolean
    var
        EndpointTxt: Label '/v2/prints/%1/%2', Locked = true;
    begin
        GetSetup();
        exit(TryDoLabel(IDYSTransportOrderHeader, StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code", IDYSTransportOrderHeader."No."), Response));
    end;

    procedure TryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Path: Text; var Response: JsonToken) Printed: Boolean
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeTryDoLabelPrinted(IDYSTransportOrderHeader, Response, Printed, IsHandled);
            if IsHandled then
                exit(Printed);
        end;

        if not (IDYSTransportOrderHeader.Status in [
            IDYSTransportOrderHeader.Status::Uploaded,
            IDYSTransportOrderHeader.Status::Booked,
            IDYSTransportOrderHeader.Status::"Label Printed"])
        then
            IDYSTransportOrderHeader.FieldError(Status);

        GetSetup();

        // Send to printer
        IDYSAPIHelper.ExecuteGet(Path, false, IDYSSetup, TempIDYMRESTParameters, BaseURI::Transsmart);
        if TempIDYMRESTParameters."Status Code" <> 200 then begin
            TranssmartErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;
        exit(true);
    end;

    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYSTransportOrderHeader2: Record "IDYS Transport Order Header";
        Base64Convert: Codeunit "Base64 Convert";
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        SourceRecordRef: RecordRef;
        FileOutStream: OutStream;
        FileInStream: InStream;
        PrintResponse: JsonToken;
        Documents: JsonArray;
        Document: JsonToken;
        InsuranceResponse: JsonToken;
        Base64EncodedLabel: Text;
        IsHandled: Boolean;
        FileName: Text;
        FileExtension: Text;
        EntryAdded: Boolean;
        EndpointRawTxt: Label '/v2/prints/%1/%2?rawJob=true', Locked = true;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterPrinting(Response, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        GetSetup();

        // Virtual print to PDF
        IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointRawTxt, IDYSTranssmartSetup."Transsmart Account Code", IDYSTransportOrderHeader."No."), false, IDYSSetup, TempIDYMRESTParameters, BaseURI::Transsmart);
        Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterVirtualPrinting(Response, IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        if IDYSTranssmartSetup."Enable Insurance" then
            if GetInsuranceInformation(IDYSTransportOrderHeader, InsuranceResponse) then
                HandleResponseAfterGetInsuranceInformation(IDYSTransportOrderHeader, InsuranceResponse);

        IDYSTransportOrderHeader2 := IDYSTransportOrderHeader;
        IDYSTransportOrderHeader2.SetRecFilter();
        SourceRecordRef.GetTable(IDYSTransportOrderHeader2);

        DataCompression.CreateZipArchive();

        if Response.AsArray().Get(0, PrintResponse) then begin
            // shipmentDocs
            if PrintResponse.AsObject().Contains('shipmentDocs') then begin
                Documents := IDYMJSONHelper.GetArray(PrintResponse, 'shipmentDocs');
                foreach Document in Documents do
                    if GetFileDetails(Document, FileName, Base64EncodedLabel, FileExtension) then begin
                        Clear(TempBlob);
                        TempBlob.CreateOutStream(FileOutStream);
                        Base64Convert.FromBase64(Base64EncodedLabel, FileOutStream);

                        // New Entry
                        TempBlob.CreateInStream(FileInStream);
                        DataCompression.AddEntry(FileInStream, StrSubstNo(FileNameLbl, FileName, FileExtension));
                        EntryAdded := true;
                    end;
            end;

            // packageDocs
            if PrintResponse.AsObject().Contains('packageDocs') then begin
                Documents := IDYMJSONHelper.GetArray(PrintResponse, 'packageDocs');
                foreach Document in Documents do begin
                    IDYSTransportOrderPackage.Reset();
                    IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
                    IDYSTransportOrderPackage.SetRange("Tracking No.", IDYMJsonHelper.GetTextValue(Document, 'airwaybillNumber'));
                    if IDYSTransportOrderPackage.FindFirst() then
                        if GetFileDetails(Document, FileName, Base64EncodedLabel, FileExtension) then begin
                            InsertPackageDocument(IDYSSCParcelDocument, IDYSTransportOrderPackage, Base64EncodedLabel, IDYMJSONHelper.GetTextValue(Document, 'templateID'), FileExtension);

                            // New Entry
                            IDYSSCParcelDocument."File".CreateInStream(FileInStream);
                            DataCompression.AddEntry(FileInStream, IDYSSCParcelDocument."File Name");
                            EntryAdded := true;
                        end;
                end;
            end;
        end;

        if EntryAdded then begin
            Clear(TempBlob);
            Clear(FileName);
            DataCompression.SaveZipArchive(TempBlob);
            IDYSTransportOrderMgt.SaveDocumentAttachmentFromRecRef(SourceRecordRef, TempBlob, FileName, 'zip', false);
        end;
        DataCompression.CloseZipArchive();

        IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::"Label Printed");
        IDYSTransportOrderHeader.Modify();

        IDYSTransportOrderHeader.CreateLogEntry(LabelPrintedTxt, LoggingLevel::Information);

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterHandleResponseAfterPrinting(Response, IDYSTransportOrderHeader);
    end;

    local procedure GetFileDetails(var Document: JsonToken; var FileName: Text; var Base64EncodedLabel: Text; var FileExtension: Text): Boolean
    begin
        if not Document.AsObject().Contains('data') then
            exit(false);

        FileExtension := LowerCase(IDYMJSONHelper.GetTextValue(Document, 'fileFormat'));

        if LowerCase(IDYMJSONHelper.GetTextValue(Document, 'encodingFormat')) <> 'base64' then
            exit(false);

        Base64EncodedLabel := IDYMJSONHelper.GetTextValue(Document, 'data');
        if Base64EncodedLabel = '' then
            exit(false);

        FileName := IDYMJSONHelper.GetTextValue(Document, 'docType') + '_' + IDYMJSONHelper.GetTextValue(Document, 'templateID');
        exit(true);
    end;

    procedure HandleResponseAfterPrinting(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; Response: JsonToken)
    var
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        PrintResponse: JsonToken;
        Documents: JsonArray;
        Document: JsonToken;
        Base64EncodedLabel: Text;
        IsHandled: Boolean;
        FileName: Text;
        FileExtension: Text;
        EndpointPckRawTxt: Label '/v2/prints/%1/%2/%3?rawJob=true', Locked = true;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterPrintingPackage(Response, IDYSTransportOrderPackage, IsHandled);
            if IsHandled then
                exit;
        end;

        GetSetup();

        // Virtual print to PDF
        IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointPckRawTxt, IDYSTranssmartSetup."Transsmart Account Code", IDYSTransportOrderPackage."Transport Order No.", IDYSTransportOrderPackage."Tracking No."), false, IDYSSetup, TempIDYMRESTParameters, BaseURI::Transsmart);
        Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeHandleResponseAfterVirtualPrintingPackage(Response, IDYSTransportOrderPackage, IsHandled);
            if IsHandled then
                exit;
        end;

        if Response.AsArray().Get(0, PrintResponse) then
            // packageDocs
            if PrintResponse.AsObject().Contains('packageDocs') then begin
                Documents := IDYMJSONHelper.GetArray(PrintResponse, 'packageDocs');
                foreach Document in Documents do
                    if GetFileDetails(Document, FileName, Base64EncodedLabel, FileExtension) then
                        InsertPackageDocument(IDYSSCParcelDocument, IDYSTransportOrderPackage, Base64EncodedLabel, IDYMJSONHelper.GetTextValue(Document, 'templateID'), FileExtension)
            end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterHandleResponseAfterPrintingPackage(Response, IDYSTransportOrderPackage);
    end;

    local procedure InsertPackageDocument(var IDYSSCParcelDocument: Record "IDYS SC Parcel Document"; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; Base64EncodedLabel: Text; TemplateId: Text; FileExtension: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
        FileOutStream: OutStream;
        ReturnFileNameLbl: Label '%1_RETURN.%2', Locked = true;
        FileName: Text[150];
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeInsertPackageDocument(IDYSSCParcelDocument, IDYSTransportOrderPackage, Base64EncodedLabel, TemplateId, FileExtension, IsHandled);
            if IsHandled then
                exit;
        end;

        if UpperCase(TemplateId).Contains('RETURN') then
            FileName := CopyStr(StrSubstNo(ReturnFileNameLbl, IDYSTransportOrderPackage."Parcel Identifier", FileExtension), 1, MaxStrLen(FileName))
        else
            FileName := CopyStr(StrSubstNo(FileNameLbl, IDYSTransportOrderPackage."Parcel Identifier", FileExtension), 1, MaxStrLen(FileName));

        // Delete label
        IDYSSCParcelDocument.SetRange("Transport Order No.", IDYSTransportOrderPackage."Transport Order No.");
        IDYSSCParcelDocument.SetRange("Parcel Identifier", IDYSTransportOrderPackage."Parcel Identifier");
        IDYSSCParcelDocument.SetRange("File Name", FileName);
        IDYSSCParcelDocument.DeleteAll();

        // Insert label
        IDYSSCParcelDocument.Init();
        IDYSSCParcelDocument."Parcel Identifier" := IDYSTransportOrderPackage."Parcel Identifier";
        IDYSSCParcelDocument."Transport Order No." := IDYSTransportOrderPackage."Transport Order No.";
        IDYSSCParcelDocument."File Name" := FileName;
        IDYSSCParcelDocument."File".CreateOutStream(FileOutStream);
        Base64Convert.FromBase64(Base64EncodedLabel, FileOutStream);
        IDYSSCParcelDocument.Insert(true);

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterInsertPackageDocument(IDYSSCParcelDocument);
    end;
    #endregion

    #region [Insurance]
    procedure IsInsuranceApplicable(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    var
        CountryRegion: Record "Country/Region";
        TransportOrderLine: Record "IDYS Transport Order Line";
        ItemCategory: Record "Item Category";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        CalculatedShipmentValueLCY: Decimal;
        IsHandled: Boolean;
        ReturnValue: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeSetApplyInsurance(TransportOrderHeader, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        GetSetup();

        // Shipping Agent Mapping
        ShipAgentMapping.SetRange("Shipping Agent Code", TransportOrderHeader."Shipping Agent Code");
        ShipAgentMapping.SetRange(Insure, true);
        if ShipAgentMapping.IsEmpty() then
            exit(false);

        // Shipping Agent Service Mapping
        ShipAgentSvcMapping.SetRange("Shipping Agent Code", TransportOrderHeader."Shipping Agent Code");
        ShipAgentSvcMapping.SetRange("Shipping Agent Service Code", TransportOrderHeader."Shipping Agent Service Code");
        ShipAgentSvcMapping.SetRange(Insure, true);
        if ShipAgentMapping.IsEmpty() then
            exit(false);

        CountryRegion.SetRange(Code, TransportOrderHeader."Country/Region Code (Ship-to)");
        CountryRegion.SetRange("IDYS Insure", true);
        if CountryRegion.IsEmpty() then
            exit(false);

        if IDYSTranssmartSetup."Enable Min. Shipment Amount" then begin
            TransportOrderLine.SetCurrentKey("Item Category Code");
            TransportOrderLine.SetRange("Transport Order No.", TransportOrderHeader."No.");
            if TransportOrderLine.FindSet() then
                repeat
                    TransportOrderLine.SetRange("Item Category Code", TransportOrderLine."Item Category Code");

                    // Calc Shipment Value
                    if ItemCategory.Get(TransportOrderLine."Item Category Code") then begin
                        TransportOrderHeader.SetRange("Item Category Code Filter", TransportOrderLine."Item Category Code");
                        TransportOrderHeader.CalcFields("Calculated Shipment Value");

                        CalculatedShipmentValueLCY := CurrencyExchangeRate.ExchangeAmount(TransportOrderHeader."Calculated Shipment Value", TransportOrderHeader."Shipment Value Curr Code", '', WorkDate());
                        if CalculatedShipmentValueLCY >= ItemCategory."IDYS Min. Shipmt. Amount (LCY)" then
                            exit(true);
                    end;

                    TransportOrderLine.FindLast();
                    TransportOrderLine.SetRange("Item Category Code");
                until TransportOrderLine.Next() = 0;
        end else
            exit(true);
    end;

    procedure IsInsuranceApplicable(var TempTransportWorksheetLine: Record "IDYS Transport Worksheet Line" temporary; var TempTransportOrderHeader: Record "IDYS Transport Order Header" temporary; var AmountPerItemCategory: Dictionary of [Code[20], Decimal]): Boolean
    var
        ItemCategory: Record "Item Category";
        ItemCategoryCode: Code[20];
        ItemCategoryAmount: Decimal;
    begin
        foreach ItemCategoryCode in AmountPerItemCategory.Keys() do begin
            AmountPerItemCategory.Get(ItemCategoryCode, ItemCategoryAmount);
            if ItemCategoryCode <> '' then
                if ItemCategory.Get(ItemCategoryCode) then
                    if ItemCategoryAmount >= ItemCategory."IDYS Min. Shipmt. Amount (LCY)" then
                        exit(true);
        end;
    end;
    #endregion

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        ShipmentValueMandatoryErr: Label 'Providing a shipment value is mandatory, but the shipment value couldn''t be calculated. Please register a shipment value manually.';
        DateErr: Label 'cannot be before %1.', Comment = '%1=Today';
        IsHandled: Boolean;
    begin
        OnBeforeValidateTransportOrder(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        if not (IDYSTransportOrderHeader.Status in [
            IDYSTransportOrderHeader.Status::New,
            IDYSTransportOrderHeader.Status::Recalled])
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

        IDYSTransportOrderHeader.TestField("Service Level Code (Time)");
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

    local procedure GetSetup(): Boolean
    begin
        if not SetupLoaded then
            SetupLoaded := IDYSSetup.Get();

        if not ProviderSetupLoaded then begin
            IDYSTranssmartSetup.GetProviderSetup("IDYS Provider"::Transsmart);
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
        TranssmartProdDashboardUrlTxt: Label 'https://my.transsmart.com/dashboard/shipments/shipment/%1/%2', Comment = '%1=reference', Locked = true;
        TranssmartAccDashboardUrlTxt: Label 'https://accept-my.transsmart.com/dashboard/shipments/shipment/%1/%2', Comment = '%1=reference', Locked = true;
    begin
        IDYSTranssmartSetup.GetProviderSetup("IDYS Provider"::Transsmart);
        if IDYSTranssmartSetup."Transsmart Environment" = IDYSTranssmartSetup."Transsmart Environment"::Production then
            Hyperlink(StrSubstNo(TranssmartProdDashboardUrlTxt, IDYSTranssmartSetup."Transsmart Account Code", TransportOrderHeader."No."))
        else
            Hyperlink(StrSubstNo(TranssmartAccDashboardUrlTxt, IDYSTranssmartSetup."Transsmart Account Code", TransportOrderHeader."No."));
    end;

    procedure OpenAllInDashboard()
    var
        TranssmartProdDashboardOverviewUrlTxt: Label 'https://my.transsmart.com/dashboard/shipments/overview', Locked = true;
        TranssmartAccDashboardOverviewUrlTxt: Label 'https://accept-my.transsmart.com/dashboard/shipments/overview', Locked = true;
    begin
        IDYSTranssmartSetup.GetProviderSetup("IDYS Provider"::Transsmart);
        if IDYSTranssmartSetup."Transsmart Environment" = IDYSTranssmartSetup."Transsmart Environment"::Production then
            Hyperlink(TranssmartProdDashboardOverviewUrlTxt)
        else
            Hyperlink(TranssmartAccDashboardOverviewUrlTxt);
    end;

    procedure IsBookable(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        if TransportOrderHeader.Status in [TransportOrderHeader.Status::New, TransportOrderHeader.Status::Recalled] then
            exit(true);
    end;

    procedure IsRebookable(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        if TransportOrderHeader."Status (External)" in ['ERR', 'REFU', 'NONE', 'DEL'] then
            exit(true);
    end;

    procedure DeleteAllowed(): Boolean
    begin
        exit(true);
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
    local procedure OnBeforeInitPackagesFromSalesOrderPackages(var Document: JsonObject; var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitPackagesFromSalesOrderPackages(var Document: JsonObject; var SalesHeader: Record "Sales Header")
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
    local procedure OnBeforeInitDeliveryNote(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note"; var LineNo: Integer; var TotalPrice: Decimal; var deliveryNoteInfoLine: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDeliveryNote(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note"; var LineNo: Integer; var TotalPrice: Decimal; var deliveryNoteInfoLine: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitLinkedDeliveryNotesFromTransportOrderPackages(var Package: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var TransportOrderPackage: Record "IDYS Transport Order Package"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitLinkedDeliveryNotesFromTransportOrderPackages(var Package: JsonObject; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var TransportOrderPackage: Record "IDYS Transport Order Package")
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
    local procedure OnBeforeHandleResponseAfterPrintingPackage(Response: JsonToken; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Documents: JsonArray; var Document: JsonObject; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterCreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject; var Document: JsonObject; var ReturnValue: Boolean; var IsHandled: Boolean)
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
    local procedure OnBeforeUpdateDocumentHeader(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Document: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateIDYSTransportOrderHeaderFromDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Document: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateTransportOrderHeaderFromDocumentOnBeforeModifyTransportOrderHeader(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Document: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateDocumentHeaderOnBeforeModifyTransportOrderHeader(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Document: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTryDoLabelPrinted(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Response: JsonToken; var Printed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterHandleResponseAfterPrinting(Response: JsonToken; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterVirtualPrinting(Response: JsonToken; var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterHandleResponseAfterPrintingPackage(Response: JsonToken; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterVirtualPrintingPackage(Response: JsonToken; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPackageDocument(var IDYSSCParcelDocument: Record "IDYS SC Parcel Document"; var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; Base64EncodedLabel: Text; TemplateId: Text; FileExtension: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPackageDocument(var IDYSSCParcelDocument: Record "IDYS SC Parcel Document")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; var ReturnValue: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetInsuranceAmount(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Documents: JsonArray; var ResponseToken: JsonToken; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetInsuranceInformation(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var ResponseToken: JsonToken; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetApplyInsurance(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindLanguageCode(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var LanguageCode: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetReturnable(IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note"; var IncludeReturnable: Boolean)
    begin
    end;

    #region [Obsolete]
    [Obsolete('Replaced with GetStatus()', '24.0')]
    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes"): JsonObject
    begin
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsTranssmart(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsTranssmart(var TransportOrderPackage: Record "IDYS Transport Order Package"): Boolean
    begin
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsTranssmartEnabled(): Boolean
    begin
    end;

    [Obsolete('Authorization is now associated with the license key', '23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnSetAuthorization(var Authorization: Guid)
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '21.0')]
    procedure GetCalculatedWeight(var SalesHeader: Record "Sales Header") Return: Decimal
    begin
    end;

    [Obsolete('Added AllowLogging parameter', '19.7')]
    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"): Boolean
    begin
    end;

#pragma warning disable AL0432
    [Obsolete('Added Documents parameter', '19.7')]
    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSCarrierSelect: Record "IDYS Carrier Select" temporary);
    begin
    end;

    [Obsolete('Restructured SelectCarrier procedure', '19.7')]
    procedure SelectCarrier(var SalesHeader: Record "Sales Header"; var IDYSCarrierSelect: Record "IDYS S.Ord Carrier Select" temporary);
    begin
    end;

    [Obsolete('Restructured SelectCarrier procedure', '19.7')]
    procedure SelectCarrier(var SalesHeader: Record "Sales Header"; var IDYSCarrierSelect: Record "IDYS Carrier Select" temporary);
    begin
    end;

    [Obsolete('Moved to TransportOrderMgt', '19.7')]
    procedure WriteTrackingNoToSourceDoc(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;
#pragma warning restore AL0432    

    [Obsolete('Added Parameter AllowLogging', '19.6')]
    procedure PostDocument(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Documents: JsonArray): JsonObject
    begin
    end;

    [Obsolete('Restructured SelectCarrier procedure', '19.7')]
    procedure CreateDocument(var SalesHeader: Record "Sales Header"; var Documents: JsonArray; var Document: JsonObject): Boolean;
    begin
    end;

    [Obsolete('Added Response parameter to this procedure', '18.8')]
    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [Obsolete('Added Response parameter to this procedure', '18.8')]
    procedure TryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
    end;

    [Obsolete('Removed due to interface implementation', '19.7')]
    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"): JsonObject
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
    procedure Synchronize(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes") ReturnJsonObject: JsonObject
    begin
        exit(Synchronize(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes"): JsonObject
    begin
        exit(GetStatus(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure DoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
        exit(DoLabel(IDYSTransportOrderHeader));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure DoLabel(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
        exit(DoLabel(IDYSTransportOrderPackage));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure TryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken) Printed: Boolean
    begin
        exit(TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure TryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; Path: Text; var Response: JsonToken) Printed: Boolean
    begin
        exit(TryDoLabel(IDYSTransportOrderHeader, Path, Response));
    end;

    [Obsolete('Removed ErrorCode. Replace with OnBeforeTryDoLabelPrinted', '25.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeTryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken; var Printed: Boolean; var IsHandled: Boolean)
    begin
    end;
    #endregion

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSTranssmartSetup: Record "IDYS Setup";
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        IDYSAPIHelper: Codeunit "IDYS API Helper";
        TranssmartErrorHandler: Codeunit "IDYS Transsmart Error Handler";
        IDYSLoggingHelper: Codeunit "IDYS Logging Helper";
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        PostDocumentSucceeeded: Boolean;
        SetupLoaded: Boolean;
        ProviderSetupLoaded: Boolean;
        ApplyExternalId: Boolean;
        BookingTxt: Label 'Booking';
        ErrorBookingTxt: Label 'Error while booking';
        UpdatedTxt: Label 'Updated from nShift Transsmart';
        UploadedTxt: Label 'Uploaded to nShift Transsmart';
        SynchronizeTxt: Label 'Synchronize';
        ErrorSynchronizeTxt: Label 'Error while synchronizing';
        LabelPrintedTxt: Label 'Label printed';
        RecalledTxt: Label 'Recalled';
        FileNameLbl: Label '%1.%2', Locked = true;
        LoggingLevel: Enum "IDYS Logging Level";
        BaseURI: Enum "IDYS API";
        HttpStatusCode: Integer;
}