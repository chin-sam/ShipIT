codeunit 11147685 "IDYS Publisher"
{
    EventSubscriberInstance = StaticAutomatic;

    [Obsolete('Replaced with OnBeforeInsertTransportOrder with add. parameters', '21.10')]
    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrder(var TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeInsertTransportOrder(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line");
    begin
    end;

    [Obsolete('Replaced with OnTransportOrderCreated with add. parameters', '21.10')]
    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrder(var TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnTransportOrderCreated(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line");
    begin
    end;

    [Obsolete('Replaced with OnBeforeInsertTransportOrderLine with add. parameters', '21.10')]
    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderLine(var TransportOrderLine: Record "IDYS Transport Order Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeInsertTransportOrderLine(var TransportOrderLine: Record "IDYS Transport Order Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line");
    begin
    end;

    [Obsolete('Replaced with OnAfterInsertTransportOrderLine with add. parameters', '21.10')]
    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderLine(var TransportOrderLine: Record "IDYS Transport Order Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterInsertTransportOrderLine(var TransportOrderLine: Record "IDYS Transport Order Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderDelNoteForSalesLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; SalesLine: Record "Sales Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderDelNoteForSalesLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; SalesLine: Record "Sales Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderDelNoteForPurchaseLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; PurchaseLine: Record "Purchase Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderDelNoteForPurchaseLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; PurchaseLine: Record "Purchase Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderDelNoteForTransferLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; TransferLine: Record "Transfer Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderDelNoteForTransferLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; TransferLine: Record "Transfer Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderDelNoteForServiceLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; ServiceLine: Record "Service Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderDelNoteForServiceLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; ServiceLine: Record "Service Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderDelNoteForSalesShipmentLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; SalesShipmentLine: Record "Sales Shipment Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderDelNoteForSalesShipmentLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; SalesShipmentLine: Record "Sales Shipment Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderDelNoteForReturnShipmentLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; ReturnShipmentLine: Record "Return Shipment Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderDelNoteForReturnShipmentLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; ReturnShipmentLine: Record "Return Shipment Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderDelNoteForReturnReceiptLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; ReturnReceiptLine: Record "Return Receipt Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderDelNoteForReturnReceiptLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; ReturnReceiptLine: Record "Return Receipt Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderDelNoteForTransferShipmentLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; TransferShipmentLine: Record "Transfer Shipment Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderDelNoteForTransferShipmentLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; TransferShipmentLine: Record "Transfer Shipment Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderDelNoteForServiceShipmentLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; ServiceShipmentLine: Record "Service Shipment Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderDelNoteForServiceShipmentLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; ServiceShipmentLine: Record "Service Shipment Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromSalesOrderLine(SalesLine: Record "Sales Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromSalesOrderLine(SalesLine: Record "Sales Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromSalesReturnOrderLine(SalesLine: Record "Sales Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromSalesReturnOrderLine(SalesLine: Record "Sales Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromPurchaseReturnOrderLine(PurchaseLine: Record "Purchase Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromPurchaseReturnOrderLine(PurchaseLine: Record "Purchase Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromServiceOrderLine(ServiceLine: Record "Service Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromServiceOrderLine(ServiceLine: Record "Service Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromTransferOrderLine(TransferLine: Record "Transfer Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromTransferOrderLine(TransferLine: Record "Transfer Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromWarehouseShipmentLine(WarehouseShipmentLine: Record "Warehouse Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromWarehouseShipmentLine(WarehouseShipmentLine: Record "Warehouse Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromPostedSalesShipmentLine(SalesShipmentLine: Record "Sales Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromPostedSalesShipmentLine(SalesShipmentLine: Record "Sales Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromReturnShipmentLine(ReturnShipmentLine: Record "Return Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromReturnShipmentLine(ReturnShipmentLine: Record "Return Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromServiceShipmentLine(ServiceShipmentLine: Record "Service Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromServiceShipmentLine(ServiceShipmentLine: Record "Service Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromTransferShipmentLine(TransferShipmentLine: Record "Transfer Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromTransferShipmentLine(TransferShipmentLine: Record "Transfer Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromPostedReturnReceiptLine(ReturnReceiptLine: Record "Return Receipt Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromPostedReturnReceiptLine(ReturnReceiptLine: Record "Return Receipt Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeTransportOrderBook(var TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterTransportOrderBook(var TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterUpdateTransportOrderFromTransSmart(IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterProviderCarrierSelectLookup(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary);
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterProviderCarrierSelectLookup_SalesHeader(var SalesHeader: Record "Sales Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary);
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromPurchaseOrderLine(PurchaseLine: Record "Purchase Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromPurchaseOrderLine(PurchaseLine: Record "Purchase Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFromTransferReceiptLine(TransferReceiptLine: Record "Transfer Receipt Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFinalizeFromTransferReceiptLine(TransferReceiptLine: Record "Transfer Receipt Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnBeforeCreateTransportOrderDelNoteForTransferReceiptLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; TransferReceiptLine: Record "Transfer Receipt Line");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterCreateTransportOrderDelNoteForTransferReceiptLine(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; TransferReceiptLine: Record "Transfer Receipt Line");
    begin
    end;
}