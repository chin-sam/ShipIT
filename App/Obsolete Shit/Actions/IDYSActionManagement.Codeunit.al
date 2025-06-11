codeunit 11147641 "IDYS Action Management"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured';
    //ObsoleteTag = '19.7';

    [Obsolete('Moved to IDYSTranssmartMDataMgt', '19.7')]
    procedure IDYSSetup_UpdateMasterData(ShowNotifications: Boolean): Boolean
    begin
    end;

    [Obsolete('Moved to IDYSTranssmartMDataMgt', '19.7')]
    procedure IDYSSetup_UpdateCombinabilityID()
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure SalesHeader_CreateTransportOrder(SalesHeader: Record "Sales Header")
    begin
    end;

    [Obsolete('Replaced with SalesHeader_CreateTransportOrder', '18.5')]
    procedure SalesReturnHeader_CreateTransportOrder(SalesHeader: Record "Sales Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure PurchaseReturnHeader_CreateTransportOrder(PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure ServiceHeader_CreateTransportOrder(ServiceHeader: Record "Service Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure TransferHeader_CreateTransportOrder(TransferHeader: Record "Transfer Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure WhseShipmtHdr_CreateTransportOrder(WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure SalesShipment_CreateTransportOrder(SalesShipmentHeader: Record "Sales Shipment Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure SalesShipment_CreateTransportOrder(SalesShipmentHeader: Record "Sales Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure ReturnShipment_CreateTransportOrder(ReturnShipmentHeader: Record "Return Shipment Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure ReturnShipment_CreateTransportOrder(ReturnShipmentHeader: Record "Return Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure ServiceShipment_CreateTransportOrder(ServiceShipmentHeader: Record "Service Shipment Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure ServiceShipment_CreateTransportOrder(ServiceShipmentHeader: Record "Service Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure TransferShipment_CreateTransportOrder(TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure TransferShipment_CreateTransportOrder(TransferShipmentHeader: Record "Transfer Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure ReturnReceipt_CreateTransportOrder(ReturnReceiptHeader: Record "Return Receipt Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure ReturnReceipt_CreateTransportOrder(ReturnReceiptHeader: Record "Return Receipt Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_BookAction(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes")
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_Book(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes")
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_CarrierSelect(var TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure SalesOrder_CarrierSelect(var SalesHeader: Record "Sales Header")
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_BookAndPrintAction(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes")
    begin
    end;

    [Obsolete('Unused', '18.6')]
    procedure TransportOrder_PrintAction(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes")
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_Synchronize(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes")
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_Recall(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes")
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_Print(var TransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes")
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_OpenAllInDashboard()
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_Trace(TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_Archive(var TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [Obsolete('Moved to IDYSTransportOrderMgt', '18.6')]
    procedure TransportOrder_Unarchive(var TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [Obsolete('No longer used', '18.6')]
    procedure TransportOrderLine_ShowDoc(TransportOrderLine: Record "IDYS Transport Order Line")
    begin

    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure TransportOrderLine_ShowSourceDoc(TransportOrderLine: Record "IDYS Transport Order Line")
    begin
    end;

    [Obsolete('Moved to IDYSDocumentMgt', '18.6')]
    procedure TransportWorksheet_SourceDoc(TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [Obsolete('No longer used', '18.6')]
    procedure TptWorksheet_CreateTransportOrders(TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    procedure TransportSourceFilter_Run(TransportSourceFilter: Record "IDYS Transport Source Filter"): Integer
    begin
    end;
}

