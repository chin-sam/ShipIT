codeunit 11147709 "IDYS Sendcloud API Docs. Mgt."
{
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
        Succeeded: Boolean;
        IsModified: Boolean;
    begin
        GetSetup();

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeCreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        SCParcelMgt.CleanErrors(IDYSTransportOrderHeader."No.");
        ValidateTransportOrder(IDYSTransportOrderHeader);

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

        RequestDocument := SCParcelMgt.CreatePackageRequestContent(IDYSTransportOrderHeader);

        if AllowLogging and IDYSSetup."Enable Debug Mode" then begin
            IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", BookingTxt, "IDYS Logging Level"::Information, RequestDocument);
            Commit();
        end;

        ResponseDocument := PostPackages(RequestDocument);

        if AllowLogging then begin
            if PostSucceeded then begin
                if IDYSSetup."Enable Debug Mode" then
                    IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", UploadedTxt, "IDYS Logging Level"::Information, RequestDocument, ResponseDocument)
                else
                    IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", UploadedTxt, "IDYS Logging Level"::Information);
            end else
                IDYSLoggingHelper.WriteLogEntry(IDYSTransportOrderHeader."No.", ErrorBookingTxt, "IDYS Logging Level"::Error, RequestDocument, ResponseDocument);
            Commit();
        end;

        // Partially handle the response to update the header status
        Succeeded := SCParcelMgt.ContainsSuccessfullyProcessedParcel(ResponseDocument);
        if SCParcelMgt.CheckFailedParcels(ResponseDocument, IDYSTransportOrderHeader."No.") then begin
            if Succeeded then begin
                // Booked with errors
                IDYSTransportOrderHeader.Status := IDYSTransportOrderHeader.Status::Booked;
                IDYSTransportOrderHeader."Booked with Error" := true;
                ReturnValue := true;
            end else begin
                // Error
                IDYSTransportOrderHeader.Status := IDYSTransportOrderHeader.Status::Error;
                ReturnValue := false;
            end;
            IsModified := true;
        end else
            if Succeeded then begin
                // Booked
                IDYSTransportOrderHeader.Status := IDYSTransportOrderHeader.Status::Booked;
                IsModified := true;
                ReturnValue := true;
            end;

        if IsModified then begin
            IDYSTransportOrderHeader.Modify();
            Commit();
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterCreateAndBookDoc(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging, ReturnValue);
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

        if not SCParcelMgt.ProcessResponse(ResponseDocument, IDYSTransportOrderHeader."No.") then
            exit(false);

        // Update tracking information
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if TransportOrderPackage.FindLast() then begin
            IDYSTransportOrderHeader."Tracking No." := TransportOrderPackage."Tracking No.";
            IDYSTransportOrderHeader."Tracking Url" := TransportOrderPackage."Tracking Url";
        end;

        UpdateStatus(IDYSTransportOrderHeader);
        IDYSTransportOrderHeader.Modify(true);

        Commit();  // Save changes in case of an error in PrintIT
        exit(true);
    end;

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        DummyRecId: RecordId;
        IsHandled: Boolean;
        MissingShippingMethodMsg: Label 'All packages must have assigned service for Transport Order %1.', Comment = '%1 = Transport Order No.';
    begin
        OnBeforeValidateTransportOrder(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        if not (IDYSTransportOrderHeader.Status in [
            IDYSTransportOrderHeader.Status::New,
            IDYSTransportOrderHeader.Status::Recalled])
        then
            IDYSTransportOrderHeader.FieldError(Status);

        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSTransportOrderPackage.SetRange("Shipping Method Id", 0);
        if not IDYSTransportOrderPackage.IsEmpty() then
            Error(MissingShippingMethodMsg, IDYSTransportOrderHeader."No.");

        // Gross Weight is mandatory for linked lines (parcel_item/weight)
        IDYSTransportOrderDelNote.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderDelNote.FindSet() then
            repeat
                if IDYSTransportOrderDelNote."Transport Order Pkg. Record Id" <> DummyRecId then
                    IDYSTransportOrderDelNote.TestField("Gross Weight");
            until IDYSTransportOrderDelNote.Next() = 0;

        IDYSProviderMgt.CheckTransportOrder(IDYSTransportOrderHeader);
        OnAfterValidateTransportOrder(IDYSTransportOrderHeader);
    end;

    local procedure PostPackages(RequestDocument: JsonObject) ResponseDocument: JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        Statuscode: Integer;
    begin
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
        TempIDYMRESTParameters.Path := '/parcels?errors=verbose';
        TempIDYMRESTParameters.SetRequestContent(RequestDocument);

        Statuscode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);
        ResponseDocument := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
        PostSucceeded := (Statuscode = 200);
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

    procedure DoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        RecalledTxt: Label 'Recalled';
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeDoDeleteOrder(IDYSTransportOrderHeader, IsHandled);
            if IsHandled then
                exit;
        end;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter("Tracking No.", '<>%1', '');
        if TransportOrderPackage.FindSet(true) then begin
            repeat
                DoDelete(TransportOrderPackage);
            until TransportOrderPackage.Next() = 0;

            IDYSTransportOrderHeader.Get(IDYSTransportOrderHeader."No.");
            UpdateStatus(IDYSTransportOrderHeader);
            IDYSTransportOrderHeader.Modify();
            IDYSTransportOrderHeader.CreateLogEntry(RecalledTxt, "IDYS Logging Level"::Information);
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterDoDeleteOrder(IDYSTransportOrderHeader);
    end;

    local procedure DoDelete(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package");
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        Response: JsonObject;
        Statuscode: Integer;
        ErrorMessage: Text;
        IsHandled: Boolean;
        CancelPathLbl: Label '/parcels/%1/cancel', Locked = true;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeDoDeletePackage(IDYSTransportOrderPackage, IsHandled);
            if IsHandled then
                exit;
        end;

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
        TempIDYMRESTParameters.Path := StrSubstNo(CancelPathLbl, IDYSTransportOrderPackage."Sendcloud Parcel Id.");

        Statuscode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);

        if Statuscode in [200, 202, 400, 410] then begin
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
            SCParcelMgt.ProcessResponse(Response, IDYSTransportOrderPackage."Transport Order No.", IDYSTransportOrderPackage."Parcel Identifier");
        end else
            IDYMHTTPHelper.ParseError(TempIDYMRESTParameters, Statuscode, ErrorMessage, true);

        if Statuscode in [200, 410] then begin
            Clear(IDYSTransportOrderPackage.Created);
            Clear(IDYSTransportOrderPackage."Tracking No.");
            Clear(IDYSTransportOrderPackage."Tracking URL");
            IDYSSCParcelDocument.SetRange("Transport Order No.", IDYSTransportOrderPackage."Transport Order No.");
            IDYSSCParcelDocument.SetRange("Parcel Identifier", IDYSTransportOrderPackage."Parcel Identifier");
            IDYSSCParcelDocument.DeleteAll();

            if Statuscode = 200 then
                IDYSTransportOrderPackage.Validate(Status, 'Cancelled')
            else
                IDYSTransportOrderPackage.Validate(Status, 'Deleted');
            IDYSTransportOrderPackage.Modify(true);
        end;

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterDoDeletePackage(IDYSTransportOrderPackage);
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure Reset(var TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [Obsolete('Replaced with additional parameters')]
    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        // TODO:
        //  Could be implemented with:
        //   https://panel.sendcloud.sc/api/v2/labels/normal_printer/{id}
    end;

    local procedure GetSetup(): Boolean
    begin
        if not SetupLoaded then
            SetupLoaded := IDYSSetup.Get();

        if not ProviderSetupLoaded then begin
            IDYSSendcloudSetup.GetProviderSetup("IDYS Provider"::Sendcloud);
            ProviderSetupLoaded := true;
        end;

        exit(SetupLoaded and ProviderSetupLoaded);
    end;

    procedure IsBookable(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        if TransportOrderHeader.Status = TransportOrderHeader.Status::New then
            exit(true);
    end;

    procedure IsRebookable(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IsBookable(TransportOrderHeader));
    end;

    procedure DeleteAllowed(): Boolean
    begin
        exit(true);
    end;

    #region [Synchronize]
    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean) ReturnValue: JsonObject
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        TransportOrderPackage: Record "IDYS Transport Order Package";
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        Response: JsonObject;
        ErrorMessage: Text;
        Statuscode: Integer;
        IsHandled: Boolean;
        ParcelPathLbl: Label '/parcels/%1', Locked = true;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeGetDocument(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry, ReturnValue, IsHandled);
            if IsHandled then
                exit(ReturnValue);
        end;

        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter("Tracking No.", '<>%1', '');
        TransportOrderPackage.SetRange("On Hold", false);
        if TransportOrderPackage.FindSet() then
            repeat
                TempIDYMRESTParameters.Init();
                TempIDYMRESTParameters.Accept := 'application/json';
                TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
                TempIDYMRESTParameters.Path := StrSubstNo(ParcelPathLbl, TransportOrderPackage."Sendcloud Parcel Id.");

                Statuscode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);

                if not ((Statuscode = 404) and (TransportOrderPackage.Status = 'Deleted')) then  // Some packages (Unstamped letter) after deletion might not be retrievable
                    if Statuscode <> 200 then
                        IDYMHTTPHelper.ParseError(TempIDYMRESTParameters, Statuscode, ErrorMessage, true);
                Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
                SCParcelMgt.ProcessResponse_status(Response, TransportOrderPackage."Transport Order No.", TransportOrderPackage."Sendcloud Parcel Id.");
            until TransportOrderPackage.Next() = 0;

        UpdateStatus(IDYSTransportOrderHeader);
        IDYSTransportOrderHeader.Modify(true);
    end;

    procedure UpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateStatus(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter(Status, '<>%1', 'Delivered');
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
        TransportOrderPackage.SetRange("On Hold", true);
        if not TransportOrderPackage.IsEmpty() then begin
            IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::"On Hold");
            exit;
        end;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter(Status, '%1|%2|%3', 'Error collecting', 'Announcement failed', 'Announced: not collected');
        if not TransportOrderPackage.IsEmpty() then begin
            IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::Error);
            exit;
        end;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter(Status, '%1|%2', 'Delivery delayed', 'Unable to deliver');
        if not TransportOrderPackage.IsEmpty() then begin
            IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::Error);
            exit;
        end;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter(Status, '%1|%2|%3|%4', 'Cancellation requested', 'Cancelled upstream', 'Cancelled', 'Deleted');
        if not TransportOrderPackage.IsEmpty() then begin
            IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::Recalled);
            exit;
        end;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderPackage.SetFilter("Tracking No.", '<>%1', '');
        if not TransportOrderPackage.IsEmpty() then
            if IDYSTransportOrderHeader.Status <> IDYSTransportOrderHeader.Status::"Label Printed" then
                IDYSTransportOrderHeader.Validate(Status, IDYSTransportOrderHeader.Status::Booked);

        OnAfterUpdateStatus(IDYSTransportOrderHeader);
    end;
    #endregion
    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary) ReturnValue: JsonArray;
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        CompletelyShippedErr: Label 'Order is completely shipped already.';
        Document: JsonObject;
        Documents: JsonArray;
        AvgWeightPerPackage: Decimal;
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

        SourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        SourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        SourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
        if SourceDocumentPackage.IsEmpty() then
            exit;

        if IDYSSetup."Link Del. Lines with Packages" then
            AvgWeightPerPackage := Round(IDYSDocumentMgt.GetCalculatedWeight(SalesHeader) / SourceDocumentPackage.Count(), 0.01);
        if SourceDocumentPackage.FindSet() then
            repeat
                InitPackageFromSourceDocPackage(SourceDocumentPackage, TempIDYSTransportOrderHeader, AvgWeightPerPackage, Document);
                Documents.Add(Document);
            until SourceDocumentPackage.Next() = 0;

        exit(Documents);
    end;

    procedure InitPackageFromSourceDocPackage(var SourceDocumentPackage: Record "IDYS Source Document Package"; var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; AvgWeightPerPackage: Decimal; var Document: JsonObject)
    begin
        Clear(Document);
        IDYMJSONHelper.AddValue(Document, 'IsReturn', TempIDYSTransportOrderHeader."Is Return");
        IDYMJSONHelper.AddValue(Document, 'CountryRegionCodePickUp', TempIDYSTransportOrderHeader."Country/Region Code (Pick-up)");
        IDYMJSONHelper.AddValue(Document, 'CountryRegionCodeShipTo', TempIDYSTransportOrderHeader."Country/Region Code (Ship-to)");
        IDYMJSONHelper.AddValue(Document, 'OrderNo', TempIDYSTransportOrderHeader."No.");

        IDYMJSONHelper.AddValue(Document, 'ParcelIdentifier', SourceDocumentPackage."Parcel Identifier");
        IDYMJSONHelper.AddValue(Document, 'ActualWeight', 0);
        IDYMJSONHelper.AddValue(Document, 'TotalWeight', SourceDocumentPackage.Weight + AvgWeightPerPackage);
        IDYMJSONHelper.AddValue(Document, 'TotalVolume', Round(SourceDocumentPackage.Length * SourceDocumentPackage.Width * SourceDocumentPackage.Height, 1, '>'));
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary) ReturnValue: JsonArray;
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        Document: JsonObject;
        Documents: JsonArray;
        IsHandled: Boolean;
    begin
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

        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                Clear(Document);
                IDYMJSONHelper.AddValue(Document, 'IsReturn', IDYSTransportOrderHeader."Is Return");
                IDYMJSONHelper.AddValue(Document, 'CountryRegionCodePickUp', IDYSTransportOrderHeader."Country/Region Code (Pick-up)");
                IDYMJSONHelper.AddValue(Document, 'CountryRegionCodeShipTo', IDYSTransportOrderHeader."Country/Region Code (Ship-to)");
                IDYMJSONHelper.AddValue(Document, 'OrderNo', IDYSTransportOrderHeader."No.");  // Could be replaced with RecRef impl

                IDYMJSONHelper.AddValue(Document, 'ParcelIdentifier', IDYSTransportOrderPackage."Parcel Identifier");
                IDYMJSONHelper.AddValue(Document, 'ActualWeight', IDYSTransportOrderPackage."Actual Weight");
                IDYMJSONHelper.AddValue(Document, 'TotalWeight', IDYSTransportOrderPackage.GetPackageWeight());
                IDYMJSONHelper.AddValue(Document, 'TotalVolume', IDYSTransportOrderPackage.Volume);
                Documents.Add(Document);
            until IDYSTransportOrderPackage.Next() = 0;

        exit(Documents);
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
            Error(NotTemporaryErr, IDYSProviderCarrierSelect.TableCaption);

        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        IDYSProvCarrierSelectPck.DeleteAll();

        IDYSShipAgentSvcMapping.SetRange(Provider, IDYSShipAgentSvcMapping.Provider::Sendcloud);
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
                    OnSelectCarrierOnProviderCarrierSelectInsert(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, IDYSShipAgentSvcMapping);
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
        IDYSSCShippingPrice: Record "IDYS SC Shipping Price";
        IDYSSvcBookingProfile: Record "IDYS Svc. Booking Profile";
        Weight: Decimal;
        WithVolumeWeight: Boolean;
        ActualWeight: Decimal;
        TotalWeight: Decimal;
        TotalVolume: Decimal;
        IsReturn: Boolean;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeIsPackageApplicable(IDYSShipAgentSvcMapping, Package, LineNo, CreatedEntry, IsHandled);
            if IsHandled then
                exit(CreatedEntry);
        end;

        // Package variables
        ActualWeight := IDYMJSONHelper.GetDecimalValue(Package, 'ActualWeight');
        TotalWeight := IDYMJSONHelper.GetDecimalValue(Package, 'TotalWeight');
        TotalVolume := IDYMJSONHelper.GetDecimalValue(Package, 'TotalVolume');

        WithVolumeWeight := (((ActualWeight <> 0) and (ActualWeight < TotalVolume)) or
                             ((ActualWeight = 0) and (TotalWeight < TotalVolume)));

        // Order Variables
        IsReturn := IDYMJSONHelper.GetBooleanValue(Package, 'IsReturn');

        IDYSSvcBookingProfile.SetRange("Shipping Agent Code", IDYSShipAgentSvcMapping."Shipping Agent Code");
        IDYSSvcBookingProfile.SetRange("Shipping Agent Service Code", IDYSShipAgentSvcMapping."Shipping Agent Service Code");
        if IDYSSvcBookingProfile.FindSet() then
            repeat
                IDYSProviderCarrier.SetRange(Provider, "IDYS Provider"::Sendcloud);
                IDYSProviderCarrier.SetRange("Entry No.", IDYSSvcBookingProfile."Carrier Entry No.");
                if IDYSProviderCarrier.FindFirst() then begin
                    Weight := TotalWeight;
                    if ActualWeight <> 0 then
                        Weight := ActualWeight;
                    if IDYSProviderCarrier."Use Volume Weight" and WithVolumeWeight then
                        Weight := TotalVolume;

                    IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
                    IDYSProviderBookingProfile.SetRange("Entry No.", IDYSSvcBookingProfile."Booking Profile Entry No.");
                    IDYSProviderBookingProfile.SetRange("Is Return", IsReturn);
                    IDYSProviderBookingProfile.SetFilter("Min. Weight", '<%1', Weight);
                    IDYSProviderBookingProfile.SetFilter("Max. Weight", '>%1', Weight);
                    if IDYSProviderBookingProfile.FindFirst() then begin
                        IDYSSCShippingPrice.SetRange("Carrier Entry No.", IDYSProviderBookingProfile."Carrier Entry No.");
                        IDYSSCShippingPrice.SetRange("Booking Profile Entry No.", IDYSProviderBookingProfile."Entry No.");
                        IDYSSCShippingPrice.SetRange("Is Return", IsReturn);
                        IDYSSCShippingPrice.SetRange("Country (from)", GetISO2CountryRegionCode(CopyStr(IDYMJSONHelper.GetCodeValue(Package, 'CountryRegionCodePickUp'), 1, MaxStrLen(IDYSSCShippingPrice."Country (from)"))));
                        IDYSSCShippingPrice.SetRange("Country (to)", GetISO2CountryRegionCode(CopyStr(IDYMJSONHelper.GetCodeValue(Package, 'CountryRegionCodeShipTo'), 1, MaxStrLen(IDYSSCShippingPrice."Country (to)"))));
                        if IDYSSCShippingPrice.FindFirst() then begin
                            IDYSProvCarrierSelectPck.Init();
                            IDYSProvCarrierSelectPck."Transport Order No." := CopyStr(IDYMJSONHelper.GetCodeValue(Package, 'OrderNo'), 1, MaxStrLen(IDYSProvCarrierSelectPck."Transport Order No."));
                            IDYSProvCarrierSelectPck."Line No." := LineNo;
                            IDYSProvCarrierSelectPck."Carrier Entry No." := IDYSProviderBookingProfile."Carrier Entry No.";
                            IDYSProvCarrierSelectPck."Booking Profile Entry No." := IDYSProviderBookingProfile."Entry No.";
                            IDYSProvCarrierSelectPck."Carrier Name" := CopyStr(IDYSProviderCarrier.Name, 1, MaxStrLen(IDYSProvCarrierSelectPck."Carrier Name"));
                            IDYSProvCarrierSelectPck.Description := CopyStr(IDYSProviderBookingProfile.Description, 1, MaxStrLen(IDYSProvCarrierSelectPck.Description));
                            IDYSProvCarrierSelectPck."Price as Decimal" := IDYSSCShippingPrice.Price;
                            IDYSProvCarrierSelectPck."Min. Weight" := IDYSProviderBookingProfile."Min. Weight";
                            IDYSProvCarrierSelectPck."Max Weight" := IDYSProviderBookingProfile."Max. Weight";
                            IDYSProvCarrierSelectPck."Parcel Identifier" := CopyStr(IDYMJSONHelper.GetCodeValue(Package, 'ParcelIdentifier'), 1, MaxStrLen(IDYSProvCarrierSelectPck."Parcel Identifier"));
                            IDYSProvCarrierSelectPck."Shipping Method Id" := IDYSProviderBookingProfile.Id;
                            IDYSProvCarrierSelectPck.Weight := Weight;
                            if not CreatedEntry then
                                IDYSProvCarrierSelectPck.Include := true;
                            IDYSProvCarrierSelectPck.Insert(true);

                            CreatedEntry := true;
                        end;
                    end;
                end;
            until IDYSSvcBookingProfile.Next() = 0;
    end;

    // NOTE - could be used to get live prices
    // local procedure GetShippingPrice(Path: Text; var ErrorMessage: Text): Decimal
    // var
    //     TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
    //     IDYMIDYMHTTPHelper: Codeunit "IDYM Http Helper";
    //     ResponseArray: JsonArray;
    //     ResponseToken: JsonToken;
    //     StatusCode: Integer;
    //     PricePathLbl: Label '/shipping-price/?shipping_method_id=%1&from_country=%2&to_country=%3&weight=%4&weight_unit=kilogram', Locked = true;    
    // begin
    //     TempIDYMRESTParameters.Init();
    //     TempIDYMRESTParameters.Accept := 'application/json';
    //     TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
    //     TempIDYMRESTParameters.Path := CopyStr(Path, 1, MaxStrLen(TempIDYMRESTParameters.Path));

    //     StatusCode := IDYMIDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);
    //     if StatusCode = 200 then begin
    //         ResponseArray := TempIDYMRESTParameters.GetResponseBodyAsJSONArray();
    //         if ResponseArray.Get(0, ResponseToken) then
    //             exit(IDYMJSONHelper.GetDecimalValue(ResponseToken, 'price'));
    //     end;
    //     IDYMIDYMHTTPHelper.ParseError(TempIDYMRESTParameters, Statuscode, ErrorMessage, false);
    // end;

    local procedure GetISO2CountryRegionCode(CountryRegionCode: Code[10]): Code[2]
    var
        CountryRegion: Record "Country/Region";
        IDYSSCShippingMethodMgt: Codeunit "IDYS SC Shipping Method Mgt.";
    begin
        CountryRegion.Get(CountryRegionCode);
        CountryRegion.TestField("ISO Code");
        exit(IDYSSCShippingMethodMgt.GetCountryRegionISOCode(CountryRegionCode));
    end;

    #region [Set Shipping Method]
    procedure SetShippingMethod(var SalesHeader: Record "Sales Header")
    var
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        NonApplicableServiceTok: Label '9da06bfa-e90d-463f-8765-9f5be94f998e', Locked = true;
        AvgWeightPerPackage: Decimal;
        Document: JsonObject;
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

        // Approx weight per package
        IDYSSetup.Get();
        if IDYSSetup."Link Del. Lines with Packages" then
            AvgWeightPerPackage := Round(IDYSDocumentMgt.GetCalculatedWeight(SalesHeader) / IDYSSourceDocumentPackage.Count(), 0.01);
        if IDYSSourceDocumentPackage.FindSet() then
            repeat
                Clear(Document);
                IDYMJSONHelper.AddValue(Document, 'IsReturn', false);
                IDYMJSONHelper.AddValue(Document, 'CountryRegionCodePickUp', SalesHeader."Sell-to Country/Region Code");
                IDYMJSONHelper.AddValue(Document, 'CountryRegionCodeShipTo', SalesHeader."Ship-to Country/Region Code");
                IDYMJSONHelper.AddValue(Document, 'OrderNo', SalesHeader."No.");

                IDYMJSONHelper.AddValue(Document, 'ParcelIdentifier', IDYSSourceDocumentPackage."Parcel Identifier");
                IDYMJSONHelper.AddValue(Document, 'ActualWeight', 0);
                IDYMJSONHelper.AddValue(Document, 'TotalWeight', IDYSSourceDocumentPackage.Weight + AvgWeightPerPackage);
                IDYMJSONHelper.AddValue(Document, 'TotalVolume', Round(IDYSSourceDocumentPackage.Length * IDYSSourceDocumentPackage.Width * IDYSSourceDocumentPackage.Height, 1, '>'));
                Documents.Add(Document);
            until IDYSSourceDocumentPackage.Next() = 0;

        // Check if service applicable
        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", SalesHEader."No.");
        IDYSProvCarrierSelectPck.DeleteAll();

        if not IsServiceApplicable(IDYSShipAgentSvcMapping, Documents, 0) then begin
            IDYSNotificationManagement.SendNotification(NonApplicableServiceTok, NonApplicableServiceTxt);

            SalesHeader."Shipping Agent Service Code" := '';
            exit;
        end;

        // Validate packages
        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", SalesHeader."No.");
        IDYSProvCarrierSelectPck.SetRange("Line No.", 0);
        IDYSProvCarrierSelectPck.SetRange(Include, true);
        if IDYSProvCarrierSelectPck.FindSet() then
            repeat
                IDYSSourceDocumentPackage.SetRange("Parcel Identifier", IDYSProvCarrierSelectPck."Parcel Identifier");
                if IDYSSourceDocumentPackage.FindLast() then begin
                    IDYSSourceDocumentPackage.Validate("Shipping Method Id", IDYSProvCarrierSelectPck."Shipping Method Id");
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
        if not IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Sendcloud, SalesHeader."IDYS Provider") then
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

    procedure ResetSalesHeaderShippingMethod(var SalesHeader: Record "Sales Header")
    var
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
    begin
        IDYSSourceDocumentPackage.Reset();
        IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        IDYSSourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        IDYSSourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");

        IDYSSourceDocumentPackage.ModifyAll("Shipping Method Description", '');
        IDYSSourceDocumentPackage.ModifyAll("Shipping Method Id", 0);
    end;

    procedure SetShippingMethod(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        Document: JsonObject;
        Documents: JsonArray;
    begin
        // Reset shipping method
        ResetTransportOrderShippingMethod(TransportOrderHeader."No.");

        if not CheckShippingMethodConditions(TransportOrderHeader) then
            exit;

        if not IDYSShipAgentSvcMapping.Get(TransportOrderHeader."Shipping Agent Code", TransportOrderHeader."Shipping Agent Service Code") then
            Error(NotMappedServiceTxt);

        // Build package parameter
        IDYSTransportOrderPackage.Reset();
        IDYSTransportOrderPackage.SetRange("Transport Order No.", TransportOrderHeader."No.");
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                Clear(Document);
                IDYMJSONHelper.AddValue(Document, 'IsReturn', TransportOrderHeader."Is Return");
                IDYMJSONHelper.AddValue(Document, 'CountryRegionCodePickUp', TransportOrderHeader."Country/Region Code (Pick-up)");
                IDYMJSONHelper.AddValue(Document, 'CountryRegionCodeShipTo', TransportOrderHeader."Country/Region Code (Ship-to)");
                IDYMJSONHelper.AddValue(Document, 'OrderNo', TransportOrderHeader."No.");

                IDYMJSONHelper.AddValue(Document, 'ParcelIdentifier', IDYSTransportOrderPackage."Parcel Identifier");
                IDYMJSONHelper.AddValue(Document, 'ActualWeight', IDYSTransportOrderPackage."Actual Weight");
                IDYMJSONHelper.AddValue(Document, 'TotalWeight', IDYSTransportOrderPackage.GetPackageWeight());
                IDYMJSONHelper.AddValue(Document, 'TotalVolume', IDYSTransportOrderPackage.Volume);
                Documents.Add(Document);
            until IDYSTransportOrderPackage.Next() = 0;

        // Check if service applicable
        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", TransportOrderHeader."No.");
        IDYSProvCarrierSelectPck.DeleteAll();

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
                    IDYSTransportOrderPackage.Validate("Shipping Method Id", IDYSProvCarrierSelectPck."Shipping Method Id");
                    IDYSTransportOrderPackage.Validate("Shipping Method Description", CopyStr(IDYSProvCarrierSelectPck."Carrier Name" + ' - ' + IDYSProvCarrierSelectPck.Description, 1, MaxStrLen(IDYSTransportOrderPackage."Shipping Method Description")));
                    IDYSTransportOrderPackage.Modify();
                end;
            until IDYSProvCarrierSelectPck.Next() = 0;
    end;

    procedure CheckShippingMethodConditions(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        if not IDYSProviderMgt.IsProvider("IDYS Provider"::Sendcloud, TransportOrderHeader) then
            exit;

        if TransportOrderHeader."Shipping Agent Service Code" = '' then
            exit;
        exit(true);
    end;

    procedure ResetTransportOrderShippingMethod(TransportOrderNo: Code[20])
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        IDYSTransportOrderPackage.Reset();
        IDYSTransportOrderPackage.SetRange("Transport Order No.", TransportOrderNo);
        IDYSTransportOrderPackage.ModifyAll("Shipping Method Description", '');
        IDYSTransportOrderPackage.ModifyAll("Shipping Method Id", 0);
    end;
    #endregion

    #region [Obsolete]
    [Obsolete('Replaced with local procedure PostPackages()', '25.0')]
    procedure PostPackage(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Request: JsonObject; AllowLogging: Boolean) ResponseDocument: JsonObject
    begin
        exit(PostPackages(Request));
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '21.0')]
    procedure GetCalculatedWeight(var SalesHeader: Record "Sales Header") Return: Decimal
    begin
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsSendcloud(var TransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsSendcloud(var TransportOrderPackage: Record "IDYS Transport Order Package"): Boolean
    begin
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsSendcloud(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"): Boolean
    begin
    end;

    [Obsolete('Moved to IDYSProviderMgt', '21.0')]
    procedure IsSendcloudEnabled(): Boolean
    begin
    end;

    [Obsolete('Authorization is now associated with the license key', '23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnSetAuthorization(var Authorization: Guid)
    begin
    end;

    [Obsolete('Added new parameter', '23.0')]
    procedure TryDoLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
    end;

    [Obsolete('Replaced with OnAfterCreateAndBookDoc with add. parameters', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean)
    begin
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(CreateAndBookDocumentWithResponseHandling(IDYSTransportOrderHeader, AllowLogging));
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

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes") ReturnValue: JsonObject
    begin
        exit(GetDocument(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry));
    end;
    #endregion

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
    local procedure OnSelectCarrierOnProviderCarrierSelectInsert(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select"; IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsPackageApplicable(var IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping"; Package: JsonToken; LineNo: Integer; var CreatedEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateAndBookDoc(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject; var ReturnValue: Boolean; var IsHandled: Boolean)
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDoDeletePackage(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDoDeletePackage(var IDYSTransportOrderPackage: Record "IDYS Transport Order Package")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; var ReturnValue: JsonObject; var IsHandled: Boolean)
    begin
    end;

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSSendcloudSetup: Record "IDYS Setup";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        SCParcelMgt: Codeunit "IDYS SC Parcel Mgt.";
        IDYSLoggingHelper: Codeunit "IDYS Logging Helper";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        SetupLoaded: Boolean;
        PostSucceeded: Boolean;
        ProviderSetupLoaded: Boolean;
        LoggingLevel: Enum "IDYS Logging Level";
        BookingTxt: Label 'Booking';
        ErrorBookingTxt: Label 'Error while booking';
        HttpStatusCode: Integer;
        NotTemporaryErr: Label 'Parameter %1 is not temporary', Comment = '%1 = parameter name';
        NonApplicableServiceTxt: Label 'Service cannot be used with the current packages. Please use the carrier selection.';
        NotMappedServiceTxt: Label 'Service must be mapped on the Shipping Agent Mapping page.';
        UploadedTxt: Label 'Uploaded to Sendcloud portal';
        LabelPrintedTxt: Label 'Label printed';
}