codeunit 11147668 "IDYS Transfer Post Events"
{
    Permissions = tabledata "IDYS Source Document Service" = RIMD;
    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterCheckBeforePost', '', true, false)]
    local procedure TransferHeader_OnAfterCheckBeforePost(var TransferHeader: Record "Transfer Header")
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        Setup: Record "IDYS Setup";
    begin
        if Setup.Get() then
            if (Setup."Base Transport Orders on" = Setup."Base Transport Orders on"::"Posted documents") and
               (Setup."After Posting Transfer Orders" <> Setup."After Posting Transfer Orders"::"Do nothing")
            then begin
                TransferHeader.TestField("Shipping Agent Code");
                TransferHeader.TestField("Shipping Agent Service Code");
                if IDYSProviderMgt.CheckShipmentMethodCode(TransferHeader."IDYS Provider") then
                    TransferHeader.TestField("Shipment Method Code");
                ShippingAgentServices.Get(TransferHeader."Shipping Agent Code", TransferHeader."Shipping Agent Service Code");
                ShippingAgentServices.TestField(ShippingAgentServices."Shipping Time");
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Header", 'OnAfterCopyFromTransferHeader', '', true, false)]
    local procedure TransferShipmentHeader_OnAfterCopyFromTransferHeader(var TransferShipmentHeader: Record "Transfer Shipment Header"; TransferHeader: Record "Transfer Header")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;
        TransferShipmentHeader."IDYS Tracking No." := TransferHeader."IDYS Tracking No.";
        TransferShipmentHeader."IDYS Tracking Url" := TransferHeader."IDYS Tracking Url";
        TransferShipmentHeader."IDYS Cost Center" := TransferHeader."IDYS Cost Center";
        TransferShipmentHeader."IDYS E-Mail Type" := TransferHeader."IDYS E-Mail Type";
        TransferShipmentHeader."IDYS Account No." := TransferHeader."IDYS Account No.";  // Pick-up
        TransferShipmentHeader."IDYS Account No. (Ship-to)" := TransferHeader."IDYS Account No. (Ship-to)";
        TransferShipmentHeader."IDYS Do Not Insure" := TransferHeader."IDYS Do Not Insure";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterInsertTransShptHeader', '', true, false)]
    local procedure TransferOrderPostShipment_OnAfterInsertTransShptHeader(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        IDYSSourceDocumentService: Record "IDYS Source Document Service";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;
        IDYSSourceDocumentService.CopyServiceLevels(Database::"Transfer Header", "IDYS Source Document Type"::"0", TransferHeader."No.", Database::"Transfer Shipment Header", "IDYS Source Document Type"::"0", TransferShipmentHeader."No.")
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Line", 'OnAfterCopyFromTransferLine', '', true, false)]
    local procedure TransferShipmentLine_OnAfterCopyFromTransferLine(var TransferShipmentLine: Record "Transfer Shipment Line"; TransferLine: Record "Transfer Line")
    begin
        TransferShipmentLine."IDYS Quantity To Send" := TransferShipmentLine."Quantity (Base)";
        TransferShipmentLine."IDYS Tracking No." := TransferLine."IDYS Tracking No.";
        TransferShipmentLine."IDYS Tracking Url" := TransferLine."IDYS Tracking Url";
    end;


    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Line", 'OnAfterCopyFromTransferLine', '', true, false)]
    local procedure TransferReceiptLine_OnAfterCopyFromTransferLine(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line")
    begin
        TransferReceiptLine."IDYS Quantity To Send" := TransferReceiptLine."Quantity (Base)";
        TransferReceiptLine."IDYS Tracking No." := TransferLine."IDYS Tracking No.";
        TransferReceiptLine."IDYS Tracking Url" := TransferLine."IDYS Tracking Url";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeNewTransferLineInsert', '', true, false)]
    local procedure TransferOrderPostShipment_OnBeforeNewTransferLineInsert(var NewTransferLine: Record "Transfer Line")
    begin
        NewTransferLine.IDYSCalcAndUpdateQtyToSendToCarrier();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnRunOnBeforeCommit', '', true, false)]
    local procedure TransferOrderPostShipment_OnRunOnBeforeCommit(var TransferHeader: Record "Transfer Header"; TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        IDYSSetup.Get();

        if IDYSSetup."After Posting Transfer Orders" = IDYSSetup."After Posting Transfer Orders"::"Do nothing" then
            exit;
        IDYSDocumentManagement.TransferShipment_CreateTransportOrder(TransferShipmentHeader, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterTransferOrderPostShipment', '', true, false)]
    local procedure TransferOrderPostShipment_OnAfterPostShipment(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        IDYSSetup: Record "IDYS Setup";
        BatchProcessingSessionMap: Record "Batch Processing Session Map";
        IDYSCreateTptOrdWrksh: Codeunit "IDYS Create Tpt. Ord. (Wrksh.)";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        IDYSSetup.Get();
        if IDYSSetup."After Posting Transfer Orders" = IDYSSetup."After Posting Transfer Orders"::"Do nothing" then
            exit;

        if not IsNullGuid(TransferHeader."IDYS Whse Post Batch ID") then begin
            IDYSCreateTptOrdWrksh.UpdateBatchIDOnRegister(Database::"Transfer Shipment Header", TransferShipmentHeader."No.", TransferHeader.RecordId, TransferHeader."IDYS Whse Post Batch ID");
            exit;
        end;

        BatchProcessingSessionMap.SetRange("Record ID", TransferHeader.RecordId);
        BatchProcessingSessionMap.SetRange("User ID", UserSecurityId());
        BatchProcessingSessionMap.SetRange("Session ID", SessionId());
        if BatchProcessingSessionMap.FindFirst() then;
        if not IsNullGuid(BatchProcessingSessionMap."Batch ID") then
            IDYSCreateTptOrdWrksh.UpdateBatchIDOnRegister(Database::"Transfer Shipment Header", TransferShipmentHeader."No.", TransferHeader.RecordId, BatchProcessingSessionMap."Batch ID")
        else
            IDYSCreateTptOrdWrksh.ConvertRegisterIntoListAndShowTransportOrder(Database::"Transfer Shipment Header", TransferShipmentHeader."No.");
    end;

    var
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
}