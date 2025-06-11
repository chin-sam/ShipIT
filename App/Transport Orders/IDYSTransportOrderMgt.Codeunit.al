codeunit 11147673 "IDYS Transport Order Mgt."
{
    procedure Cleanup(): Integer
    var
        Setup: Record "IDYS Setup";
    begin
        Setup.Get();
        exit(Cleanup(Today() - Setup."Retention Period (Days)"))
    end;

    procedure Cleanup(CleanupDate: Date): Integer
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        DeletedArchivedCount: Integer;
        DeletedDoneCount: Integer;
        DeletedRecalledCount: Integer;
        DeletedMsg: Label 'Successfully deleted %1 archived, %2 completed and %3 recalled transport orders.', Comment = '%1=archived,%2=done,%3=recalled';
        DeletedTok: Label '1849db73-483c-46b6-8270-9b8b00bce310', Locked = true;
    begin
        TransportOrderHeader.SetRange(Status, TransportOrderHeader.Status::Archived);
        TransportOrderHeader.SetFilter("Document Date", '<%1', CleanupDate);
        DeletedArchivedCount := TransportOrderHeader.Count();
        TransportOrderHeader.DeleteAll(true);

        Clear(TransportOrderHeader);
        TransportOrderHeader.SetRange(Status, TransportOrderHeader.Status::Done);
        TransportOrderHeader.SetFilter("Document Date", '<%1', CleanupDate);
        DeletedDoneCount := TransportOrderHeader.Count();
        if not TransportOrderHeader.IsEmpty() then begin
            TransportOrderHeader.ModifyAll("Allow Deletion", true);
            TransportOrderHeader.DeleteAll(true);
        end;

        Clear(TransportOrderHeader);
        TransportOrderHeader.SetRange(Status, TransportOrderHeader.Status::Recalled);
        TransportOrderHeader.SetFilter("Document Date", '<%1', CleanupDate);
        DeletedRecalledCount := TransportOrderHeader.Count();
        TransportOrderHeader.DeleteAll(true);

        if GuiAllowed() then
            IDYSNotificationManagement.SendNotification(DeletedTok, StrSubstNo(DeletedMsg, DeletedArchivedCount, DeletedDoneCount, DeletedRecalledCount));

        exit(DeletedArchivedCount + DeletedDoneCount + DeletedRecalledCount);
    end;

    procedure Archive(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        EventLogEntryType: Enum "IDYS Logging Level";
        ArchivedMsg: Label 'Archived';
    begin
        IDYSSetup.Get();
        if IDYSSetup."Remove Attachments on Arch." then
            DeleteAttachments(TransportOrderHeader);

        TransportOrderHeader.Validate("Archived By", UserId());
        TransportOrderHeader.Validate("Archived On", Today());
        TransportOrderHeader.Validate(Status, TransportOrderHeader.Status::Archived);
        TransportOrderHeader.Modify();

        TransportOrderHeader.CreateLogEntry(ArchivedMsg, EventLogEntryType::Information);
    end;

    procedure BookAction(var TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        IDYSSetup.Get();
        if IDYSSetup."Background Booking" then begin
            if TransportOrderHeader.Status = TransportOrderHeader.Status::Recalled then
                TransportOrderHeader.Status := TransportOrderHeader.Status::New;
            TransportOrderHeader.Validate("Booking Method", TransportOrderHeader."Booking Method"::Background);
            TransportOrderHeader.Validate("Booking Scheduled On", CurrentDateTime());
            TransportOrderHeader.Validate("Booking Scheduled By", UserId());
            TransportOrderHeader.Validate("Shipment Error", '');
            TransportOrderHeader.Modify(false);
            exit;
        end;

        Book(TransportOrderHeader);
    end;

    procedure Book(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        ErrorCode: enum "IDYS Error Codes";
    begin
        InitializeBooking(TransportOrderHeader);
        ValidateTransportOrderFieldsLength(TransportOrderHeader);
        if IDYSIProvider.IsBookable(TransportOrderHeader) then
            IDYSIProvider.CreateAndBookDocumentWithResponseHandling(TransportOrderHeader, ErrorCode, true)
        else begin
            IDYSIProvider.GetDocument(TransportOrderHeader, false, false, ErrorCode);
            if IDYSIProvider.IsRebookable(TransportOrderHeader) then begin
                if IDYSIProvider.DeleteAllowed() then
                    IDYSIProvider.DoDelete(TransportOrderHeader);
                IDYSIProvider.CreateAndBookDocumentWithResponseHandling(TransportOrderHeader, ErrorCode, true);
            end;
        end;
        if not IDYSSetup."Skip Source Docs Upd after TO" then
            WriteTrackingNoToSourceDoc(TransportOrderHeader);

        IDYSAPIHelper.SyncTransportOrders();
        IDYSPublisher.OnAfterTransportOrderBook(TransportOrderHeader);
    end;

    procedure TryBook(var TransportOrderHeader: Record "IDYS Transport Order Header") Booked: Boolean
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        ResponseDocument: JsonObject;
        RequestDocument: JsonObject;
        BookErrMessageErr: Label 'An error occurred during the Transport Order book action.\\%1', Comment = '%1 Error Message';
    begin
        Clear(ErrorMessage);
        InitializeBooking(TransportOrderHeader);
        ValidateTransportOrderFieldsLength(TransportOrderHeader);
        // Check and refresh bearer token before using try functions
        IDYSProviderMgt.Authenticate(TransportOrderHeader.Provider);
        Booked := TryBook(TransportOrderHeader, RequestDocument, ResponseDocument);
        if Booked then
            Booked := IDYSIProvider.HandleResponseAfterBooking(TransportOrderHeader, RequestDocument, ResponseDocument);
        if not Booked then begin
            ErrorMessage := StrSubstNo(BookErrMessageErr, GetLastErrorText());
            exit;
        end;
        if not IDYSSetup."Skip Source Docs Upd after TO" then
            WriteTrackingNoToSourceDoc(TransportOrderHeader);

        IDYSAPIHelper.SyncTransportOrders();
        IDYSPublisher.OnAfterTransportOrderBook(TransportOrderHeader);
    end;

    [TryFunction]
    local procedure TryBook(var TransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject)
    var
        ErrorCode: enum "IDYS Error Codes";
    begin
        if IDYSIProvider.IsBookable(TransportOrderHeader) then
            IDYSIProvider.CreateAndBookDocument(TransportOrderHeader, RequestDocument, ResponseDocument, ErrorCode, false)
        else begin
            IDYSIProvider.GetDocument(TransportOrderHeader, false, false, ErrorCode);
            if IDYSIProvider.IsRebookable(TransportOrderHeader) then begin
                if IDYSIProvider.DeleteAllowed() then
                    IDYSIProvider.DoDelete(TransportOrderHeader);
                IDYSIProvider.CreateAndBookDocument(TransportOrderHeader, RequestDocument, ResponseDocument, ErrorCode, false);
            end;
        end;
    end;

    procedure TryPrint(var TransportOrderHeader: Record "IDYS Transport Order Header"; SkipInitialization: Boolean) Printed: Boolean
    var
        PrintResponse: JsonToken;
        PrintErrMessageErr: Label 'An error occurred during the Transport Order print action.\\%1', Comment = '%1 Error Message';
    begin
        Clear(ErrorMessage);
        if not SkipInitialization then
            InitializeBooking(TransportOrderHeader);
        Printed := TryPrint(TransportOrderHeader, PrintResponse);
        if Printed then
            IDYSIProvider.HandleResponseAfterPrinting(TransportOrderHeader, PrintResponse)
        else
            ErrorMessage := StrSubstNo(PrintErrMessageErr, GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryPrint(var TransportOrderHeader: Record "IDYS Transport Order Header"; var PrintResponse: JsonToken)
    var
        ErrorCode: enum "IDYS Error Codes";
    begin
        IDYSIProvider.PrintLabel(TransportOrderHeader, ErrorCode, PrintResponse);
    end;

    local procedure InitializeBooking(var TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        LoadSetup();
        TransportOrderHeader.TestField(Provider);
        IDYSIProvider := TransportOrderHeader.Provider;
        IDYSIProvider.IsEnabled(true);

        IDYSPublisher.OnBeforeTransportOrderBook(TransportOrderHeader);
    end;

    procedure ValidateTransportOrderFieldsLength(var TransportOrder: Record "IDYS Transport Order Header") Validated: Boolean
    var
        IDYSFieldSetup: Record "IDYS Field Setup";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        TempErrorMessage: Record "Error Message" temporary;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StyleExpression: Text;
        FieldNo: Integer;
        MaxFieldNo: Integer;
        ErrorMsg: Text;
    begin
        TempErrorMessage.DeleteAll();
        IDYSSetup.Get();
        if IDYSShipAgentMapping.Get(TransportOrder."Shipping Agent Code") then begin
            RecRef.Open(Database::"IDYS Transport Order Header");
            RecRef.Copy(TransportOrder);
            MaxFieldNo := RecRef.FieldCount();
            for FieldNo := 1 to MaxFieldNo do begin
                FieldRef := RecRef.FieldIndex(FieldNo);
                if FieldRef.Type in [FieldRef.Type::Code, FieldRef.Type::Text] then begin
                    StyleExpression := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", FieldRef.Number, StrLen(FieldRef.Value));
                    Clear(ErrorMsg);
                    if StyleExpression <> '' then begin
                        if IDYSFieldSetup."Truncate Field Length" then
                            FieldRef.Value := CopyStr(FieldRef.Value, 1, IDYSFieldSetup."Max. Allowed Field Length");
                        ErrorMsg := StrSubstNo(ExceedsLengthErr, FieldRef.Caption, IDYSFieldSetup."Max. Allowed Field Length");
                    end;
                    if IDYSFieldSetup.Mandatory then
                        if StrLen(FieldRef.Value) = 0 then
                            ErrorMsg := StrSubstNo(MandatoryFieldErr, FieldRef.Caption);
                    if ErrorMsg <> '' then begin
                        TempErrorMessage.ID := TempErrorMessage.ID + 1;
                        TempErrorMessage."Message Type" := TempErrorMessage."Message Type"::Error;
#if not (BC17 or BC18 or BC19 or BC20)
                        TempErrorMessage.Message := CopyStr(ErrorMsg, 1, MaxStrLen(TempErrorMessage.Message));
#else
                        TempErrorMessage.Description := CopyStr(ErrorMsg, 1, MaxStrLen(TempErrorMessage.Description));
#endif
                        TempErrorMessage.Insert();
                    end;
                end;
            end;
            RecRef.Close();
        end;

        if TempErrorMessage.FindSet() then begin
            TempErrorMessage.ShowErrorMessages(true);
            exit(false);
        end;

        exit(true);
    end;

    procedure BookAndPrintAction(var TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        Book(TransportOrderHeader);
        Print(TransportOrderHeader);
    end;

    procedure TryBookAndPrint(var TransportOrderHeader: Record "IDYS Transport Order Header"; var Booked: Boolean; var Printed: Boolean) Successful: Boolean
    begin
        Booked := TryBook(TransportOrderHeader);
        if not Booked then
            exit(false);
        if TransportOrderHeader.Print then begin
            Printed := TryPrint(TransportOrderHeader, true);
            Successful := Printed;
        end else
            Successful := true;
    end;

    procedure CarrierSelect(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        TempProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary;
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        Documents: JsonArray;
    begin
        IDYSTransportOrderPackage.SetRange("Transport Order No.", TransportOrderHeader."No.");
        if IDYSTransportOrderPackage.IsEmpty() then
            Error(MissingPackagesErr);

        if not (TransportOrderHeader.Status in [TransportOrderHeader.Status::New, TransportOrderHeader.Status::Uploaded, TransportOrderHeader.Status::Recalled])
        then begin
            Page.RunModal(Page::"IDYS Provider Carrier Select", TempProviderCarrierSelect);
            exit;
        end;

        TransportOrderHeader.TestField(Provider);
        IDYSIProvider := TransportOrderHeader.Provider;
        IDYSIProvider.IsEnabled(true);

        Documents := IDYSIProvider.InitSelectCarrier(TransportOrderHeader, TempProviderCarrierSelect);
        IDYSIProvider.SelectCarrier(TransportOrderHeader, TempProviderCarrierSelect, Documents);

        Commit();
        TempProviderCarrierSelect.SetRange(Provider, TransportOrderHeader.Provider);
        if Page.RunModal(Page::"IDYS Provider Carrier Select", TempProviderCarrierSelect) = ACTION::LookupOK then
            IDYSPublisher.OnAfterProviderCarrierSelectLookup(TransportOrderHeader, TempProviderCarrierSelect);
    end;

    procedure Print(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        ErrorCode: Enum "IDYS Error Codes";
    begin
        LoadSetup();
        TransportOrderHeader.TestField(Provider);
        IDYSIProvider := TransportOrderHeader.Provider;
        IDYSIProvider.IsEnabled(true);

        IDYSIProvider.PrintLabelWithResponseHandling(TransportOrderHeader, ErrorCode);
        IDYSIProvider.GetDocument(TransportOrderHeader, true, true, ErrorCode);
    end;

    procedure Print(var TransportOrderPackage: Record "IDYS Transport Order Package")
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        TranssmartAPIDocsMgt: Codeunit "IDYS Transsmart API Docs. Mgt.";
        SendcloudAPIDocsMgt: Codeunit "IDYS Sendcloud API Docs. Mgt.";
        EasyPostAPIDocsMgt: Codeunit "IDYS EasyPost API Docs. Mgt.";
    begin
        LoadSetup();
        TransportOrderHeader.Get(TransportOrderPackage."Transport Order No.");

        case TransportOrderHeader.Provider of
            TransportOrderHeader.Provider::Transsmart:
                begin
                    TransportOrderHeader.TestField(Provider);
                    IDYSIProvider := TransportOrderHeader.Provider;
                    IDYSIProvider.IsEnabled(true);

                    TranssmartAPIDocsMgt.DoLabel(TransportOrderPackage);
                    TranssmartAPIDocsMgt.GetStatus(TransportOrderHeader, true, true)
                end;
            TransportOrderHeader.Provider::EasyPost:
                EasyPostAPIDocsMgt.TryDoPackageLabel(TransportOrderPackage);
            TransportOrderHeader.Provider::Sendcloud:
                SendcloudAPIDocsMgt.TryDoPackageLabel(TransportOrderPackage);
        end;
    end;

    procedure ProcessTransportOrders(var TransportOrderHeader: Record "IDYS Transport Order Header"; IDYSPerformedTOAction: Enum "IDYS Performed TO Action")
    var
        Cntr: Integer;
        TotalCntr: Integer;
        NoProcessedMsg: Label '%1 transport orders have been %2', Comment = '%1 = No. of processed transport orders, %2 = Action Performed';
        ProcessQst: Label '%1 transport orders will be %2, do you want to continue?', Comment = '%1 = No. of transport orders, %2 = Action to perform';
    begin
        if GuiAllowed() then begin
            TotalCntr := TransportOrderHeader.Count;
            if TotalCntr > 1 then
                if not Confirm(ProcessQst, false, TotalCntr, LowerCase(Format(IDYSPerformedTOAction))) then
                    Error('');
        end;
        if TransportOrderHeader.FindSet() then
            repeat
                Cntr += 1;
                case IDYSPerformedTOAction of
                    IDYSPerformedTOAction::Booked:
                        BookAction(TransportOrderHeader);
                    IDYSPerformedTOAction::Printed:
                        Print(TransportOrderHeader);
                    IDYSPerformedTOAction::"Booked & Printed":
                        BookAndPrintAction(TransportOrderHeader);
                    IDYSPerformedTOAction::Synchronized:
                        Synchronize(TransportOrderHeader);
                    IDYSPerformedTOAction::Archived:
                        Archive(TransportOrderHeader);
                    IDYSPerformedTOAction::Recalled:
                        Recall(TransportOrderHeader);
                end;
            until TransportOrderHeader.Next() = 0;
        if GuiAllowed and (Cntr > 1) then
            Message(NoProcessedMsg, Cntr, LowerCase(Format(IDYSPerformedTOAction)));
    end;

    procedure Recall(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        ErrorCode: enum "IDYS Error Codes";
    begin
        LoadSetup();
        TransportOrderHeader.TestField(Provider);
        IDYSIProvider := TransportOrderHeader.Provider;
        IDYSIProvider.IsEnabled(true);

        IDYSIProvider.DoDelete(TransportOrderHeader);
        IDYSIProvider.GetDocument(TransportOrderHeader, true, true, ErrorCode);
    end;

    procedure Reset(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSSCParcelMgt: Codeunit "IDYS SC Parcel Mgt.";
    begin
        LoadSetup();
        TransportOrderHeader.TestField(Provider);

        IDYSIProvider := TransportOrderHeader.Provider;
        IDYSIProvider.IsEnabled(true);
        IDYSProviderMgt.Reset(TransportOrderHeader);

        IDYSSCParcelMgt.CleanErrors(TransportOrderHeader."No.");
        WriteTrackingNoToSourceDoc(TransportOrderHeader);
    end;

    procedure Synchronize(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        TempTransportOrderHeaderBuffer: Record "IDYS Transport Order Header" temporary;
        ErrorCode: enum "IDYS Error Codes";
    begin
        // Synch changes:
        // 1. from NAV to Transsmart, then;
        // 2. from Transsmart to NAV.

        // However, if #1 is allowed depends on the status of the shipment (>'LABL' = not allowed)
        // The status test cannot take place on the local NAV data, because the status may have
        // been changed via e.g. the dashboard.

        // Therefore, we:
        // 1. Call DoStatus to get the updated document, but store it in a temporary record buffer
        // 2. Determine the NAV status based on that temporary record buffer
        // 3. If that NAV status allows editing, call UpdateDocument to save our local changes to Transsmart
        // 4. Get the latest version from Transsmart and store that in NAV

        LoadSetup();
        TransportOrderHeader.TestField(Provider);
        IDYSIProvider := TransportOrderHeader.Provider;
        IDYSIProvider.IsEnabled(true);

        TempTransportOrderHeaderBuffer := TransportOrderHeader;
        TempTransportOrderHeaderBuffer.Insert();
        IDYSIProvider.GetDocument(TransportOrderHeader, true, true, ErrorCode);

        WriteTrackingNoToSourceDoc(TransportOrderHeader);
    end;

    procedure Trace(TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        TransportOrderHeader.TestField("Tracking Url");
        Hyperlink(TransportOrderHeader."Tracking Url");
    end;

    procedure Unarchive(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        EventLogEntryType: Enum "IDYS Logging Level";
        UnarchivedMsg: Label 'Unarchived';
    begin
        TransportOrderHeader.TestField(Provider);
        IDYSIProvider := TransportOrderHeader.Provider;
        IDYSIProvider.IsEnabled(true);

        IDYSIProvider.UpdateStatus(TransportOrderHeader);
        Clear(TransportOrderHeader."Archived By");
        Clear(TransportOrderHeader."Archived On");
        TransportOrderHeader.Modify();

        TransportOrderHeader.CreateLogEntry(UnarchivedMsg, EventLogEntryType::Information);
    end;

    local procedure WriteTrackingNoToSourceDoc(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        TransportOrderLine: Record "IDYS Transport Order Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        ServiceHeader: Record "Service Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        UpdatePostedDocuments: Codeunit "IDYS Update Posted Documents";
        xSourceDocType: Option;
        xSourceDocNo: Code[20];
        UpdateHeader: Boolean;
        CanContinue: Boolean;
    begin
        xSourceDocNo := '';
        // Write Tracking No. to underlying Posted Sales Shipments, Sales Order or Sales Return Order.
        TransportOrderLine.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        TransportOrderLine.SetLoadFields("Source Document Table No.", "Source Document Type", "Source Document No.", "Source Document Line No.");
        if TransportOrderLine.FindSet() then
            repeat
                UpdateHeader := (xSourceDocType <> TransportOrderLine."Source Document Type".AsInteger()) or (xSourceDocNo <> TransportOrderLine."Source Document No.");
                xSourceDocType := TransportOrderLine."Source Document Type".AsInteger();
                xSourceDocNo := TransportOrderLine."Source Document No.";
                case TransportOrderLine."Source Document Table No." of
                    Database::"Sales Header":
                        CanContinue := SalesHeader.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.");
                    Database::"Purchase Header":
                        CanContinue := PurchaseHeader.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.");
                    Database::"Transfer Header":
                        CanContinue := TransferHeader.Get(TransportOrderLine."Source Document No.");
                    Database::"Service Header":
                        CanContinue := ServiceHeader.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.");
                    Database::"Sales Shipment Header":
                        CanContinue := SalesShipmentHeader.Get(TransportOrderLine."Source Document No.");
                    Database::"Transfer Shipment Header":
                        CanContinue := TransferShipmentHeader.Get(TransportOrderLine."Source Document No.");
                    Database::"Transfer Receipt Header":
                        CanContinue := TransferReceiptHeader.Get(TransportOrderLine."Source Document No.");
                    Database::"Return Shipment Header":
                        CanContinue := ReturnShipmentHeader.Get(TransportOrderLine."Source Document No.");
                    Database::"Service Shipment Header":
                        CanContinue := ServiceShipmentHeader.Get(TransportOrderLine."Source Document No.");
                end;
                if CanContinue then
                    case TransportOrderLine."Source Document Table No." of
                        Database::"Sales Header":
                            UpdatePostedDocuments.UpdateSalesDocumentTrackingInfo(SalesHeader, TransportOrderLine."Source Document Line No.", IDYSTransportOrderHeader, UpdateHeader);
                        Database::"Purchase Header":
                            UpdatePostedDocuments.UpdatePurchaseDocumentTrackingInfo(PurchaseHeader, TransportOrderLine."Source Document Line No.", IDYSTransportOrderHeader, UpdateHeader);
                        Database::"Transfer Header":
                            UpdatePostedDocuments.UpdateTransferOrderTrackingInfo(TransferHeader, TransportOrderLine."Source Document Line No.", IDYSTransportOrderHeader, UpdateHeader);
                        Database::"Service Header":
                            UpdatePostedDocuments.UpdateServiceOrderTrackingInfo(ServiceHeader, TransportOrderLine."Source Document Line No.", IDYSTransportOrderHeader, UpdateHeader);
                        Database::"Sales Shipment Header":
                            UpdatePostedDocuments.UpdateSalesShipmentTrackingInfo(SalesShipmentHeader, TransportOrderLine."Source Document Line No.", IDYSTransportOrderHeader, UpdateHeader);
                        Database::"Transfer Shipment Header":
                            UpdatePostedDocuments.UpdateTransferShipmentTrackingInfo(TransferShipmentHeader, TransportOrderLine."Source Document Line No.", IDYSTransportOrderHeader, UpdateHeader);
                        Database::"Transfer Receipt Header":
                            UpdatePostedDocuments.UpdateTransferReceiptTrackingInfo(TransferReceiptHeader, TransportOrderLine."Source Document Line No.", IDYSTransportOrderHeader, UpdateHeader);
                        Database::"Return Shipment Header":
                            UpdatePostedDocuments.UpdateReturnShipmentTrackingInfo(ReturnShipmentHeader, TransportOrderLine."Source Document Line No.", IDYSTransportOrderHeader, UpdateHeader);
                        Database::"Service Shipment Header":
                            UpdatePostedDocuments.UpdateServiceShipmentTrackingInfo(ServiceShipmentHeader, TransportOrderLine."Source Document Line No.", IDYSTransportOrderHeader, UpdateHeader);
                    end;
                OnAfterWriteTrackingNoToSourceDoc(IDYSTransportOrderHeader, TransportOrderLine, UpdateHeader);
            until TransportOrderLine.Next() = 0;
    end;

    procedure GetMappedCountryCode(CountryCode: Code[10]): Code[10];
    var
        IDYSCountryRegionMapping: Record "IDYS Country/Region Mapping";
    begin
        if IDYSCountryRegionMapping.Get(CountryCode) then
            exit(IDYSCountryRegionMapping."Country/Region Code (External)");

        exit(CountryCode);
    end;

    local procedure LoadSetup()
    begin
        if not SetupLoaded then begin
            SetupLoaded := true;
            if not IDYSSetup.Get() then
                IDYSSetup.Init();
        end;
    end;

    procedure SaveDocumentAttachmentFromRecRef(SourceRecordRef: RecordRef; var TempBlob: Codeunit "Temp Blob"; var FileName: Text; FileExtension: Text; IsLabel: Boolean)
    var
        DocumentAttachment: Record "Document Attachment";
        AttachmentInStream: InStream;
        FileNameLbl: Label '%1.%2', Locked = true;
    begin
        DocumentAttachment.InitFieldsFromRecRef(SourceRecordRef);

        case SourceRecordRef.Number() of
            Database::"IDYS Transport Order Header":
                begin
                    DocumentAttachment.Validate("No.", SourceRecordRef.Field(1).Value);
                    DocumentAttachment.Validate("IDYS API Document", true);
                    DocumentAttachment.Validate("IDYS Label", IsLabel);
                end;
        end;

        if FileName = '' then
            FileName := StrSubstNo(FileNameLbl, GetRecordIdText(SourceRecordRef.RecordId), FileExtension);

        TempBlob.CreateInStream(AttachmentInStream);
        DocumentAttachment.SaveAttachmentFromStream(AttachmentInStream, SourceRecordRef, FileName);
    end;

    procedure SetShippingMethod(TransportOrderHeaderNo: Code[20])
    var
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        if not IDYSTransportOrderHeader.Get(TransportOrderHeaderNo) then
            exit;

        IDYSProviderMgt.SetShippingMethod(IDYSTransportOrderHeader);
    end;

    procedure GetRecordIdText(RecordId: RecordId): Text
    var
        RecIdText: Text;
        RecIdList: List of [Text];
        counter: Integer;
    begin
        RecIdList := Format(RecordId, 0, 0).Split(':');
        for counter := 1 to RecIdList.Count() do
            if (counter mod 2 = 0) then
                RecIdText += RecIdList.Get(counter) + '_';

        RecIdText := DelChr(DelChr(RecIdText), '>', '_').Replace(',', '_');

        exit(RecIdText);
    end;

    procedure DeleteAttachments(var TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        if TransportOrderHeader.IsTemporary() then
            exit;

        DocumentAttachment.SetRange("Table ID", Database::"IDYS Transport Order Header");
        DocumentAttachment.SetRange("No.", TransportOrderHeader."No.");
        if not DocumentAttachment.IsEmpty() then
            DocumentAttachment.DeleteAll();
    end;

    procedure GetDefaultTransportOrderNoSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        TransportOrderNoSeriesTxt: Label 'TRNSP-ORD';
        TransportOrderNoSeriesDescTxt: Label 'Transport Order';
    begin
        if NoSeries.Get(TransportOrderNoSeriesTxt) then
            exit(NoSeries.Code);

        NoSeries.Init();
        NoSeries.Code := TransportOrderNoSeriesTxt;
        NoSeries.Description := TransportOrderNoSeriesDescTxt;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Validate("Starting No.", TransportOrderNoSeriesTxt + '000001');
        NoSeriesLine.Validate("Increment-by No.", 1);
        NoSeriesLine.Insert(true);

        exit(NoSeries.Code);
    end;

    procedure GetErrorMessage(): Text
    begin
        exit(ErrorMessage);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWriteTrackingNoToSourceDoc(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; TransportOrderLine: Record "IDYS Transport Order Line"; var UpdateHeader: Boolean)
    begin
    end;

    #region [Obsolete]

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure BookAction(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes")
    begin
        BookAction(TransportOrderHeader);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure Book(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes")
    begin
        Book(TransportOrderHeader);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure TryBook(var TransportOrderHeader: Record "IDYS Transport Order Header"; var ErrorCode: Enum "IDYS Error Codes") Booked: Boolean
    begin
        exit(TryBook(TransportOrderHeader));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    [TryFunction]
    local procedure TryBook(var TransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; var ErrorCode: Enum "IDYS Error Codes")
    begin
        TryBook(TransportOrderHeader, RequestDocument, ResponseDocument);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure TryPrint(var TransportOrderHeader: Record "IDYS Transport Order Header"; var ErrorCode: Enum "IDYS Error Codes"; SkipInitialization: Boolean) Printed: Boolean
    begin
        exit(TryPrint(TransportOrderHeader, SkipInitialization));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    [TryFunction]
    local procedure TryPrint(var TransportOrderHeader: Record "IDYS Transport Order Header"; var PrintResponse: JsonToken; var ErrorCode: Enum "IDYS Error Codes")
    begin
        TryPrint(TransportOrderHeader, PrintResponse);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure BookAndPrintAction(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes")
    begin
        BookAndPrintAction(TransportOrderHeader);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure TryBookAndPrint(var TransportOrderHeader: Record "IDYS Transport Order Header"; var Booked: Boolean; var Printed: Boolean; var ErrorCode: Enum "IDYS Error Codes") Successful: Boolean
    begin
        exit(TryBookAndPrint(TransportOrderHeader, Booked, Printed));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure Print(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes")
    begin
        Print(TransportOrderHeader);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure Print(var TransportOrderPackage: Record "IDYS Transport Order Package"; ErrorCode: Enum "IDYS Error Codes")
    begin
        Print(TransportOrderPackage);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure ProcessTransportOrders(var TransportOrderHeader: Record "IDYS Transport Order Header"; IDYSPerformedTOAction: Enum "IDYS Performed TO Action"; ErrorCode: Enum "IDYS Error Codes")
    begin
        ProcessTransportOrders(TransportOrderHeader, IDYSPerformedTOAction);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure Recall(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes")
    begin
        Recall(TransportOrderHeader);
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure Synchronize(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes")
    begin
        Synchronize(TransportOrderHeader);
    end;

    [Obsolete('Moved to IDYSTranssmartAPIDocsMgt', '19.7')]
    procedure OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [Obsolete('Moved to IDYSTranssmartAPIDocsMgt', '19.7')]
    procedure OpenAllInDashboard()
    begin
    end;

    [Obsolete('New parameter added', '23.0')]
    procedure SaveDocumentAttachmentFromRecRef(SourceRecordRef: RecordRef; var TempBlob: Codeunit "Temp Blob"; var FileName: Text)
    begin
    end;

    [Obsolete('New parameter added', '25.0')]
    procedure SaveDocumentAttachmentFromRecRef(SourceRecordRef: RecordRef; var TempBlob: Codeunit "Temp Blob"; var FileName: Text; FileExtension: Text)
    begin
    end;
    #endregion
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSPublisher: Codeunit "IDYS Publisher";
        IDYSAPIHelper: Codeunit "IDYS API Helper";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        IDYSIProvider: Interface "IDYS IProvider";
        SetupLoaded: Boolean;
        ErrorMessage: Text;
        MissingPackagesErr: Label 'You cannot use the carrier selection without specifying the package(s).';
        ExceedsLengthErr: Label 'Fields "%1" value length exceedes max length of %2 for this carrier.', Comment = '%1 - field name; %2 - maximum field length';
        MandatoryFieldErr: Label 'The value is required for field "%1".', Comment = '%1 - field name';
}