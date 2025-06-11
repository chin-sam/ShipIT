codeunit 11147692 "IDYS Undo Posting Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Sales Shipment Line", 'OnBeforeCheckSalesShptLine', '', true, false)]
    local procedure UndoSalesShipmentLine_OnBeforeCheckSalesShptLine(var SalesShipmentLine: Record "Sales Shipment Line")
    var
        SalesLine: Record "Sales Line";
    begin
        CheckIfTransportOrderLineExists(Database::"Sales Shipment Header", SalesShipmentLine."Document No.", SalesShipmentLine."Line No.");
        if SalesLine.Get(SalesLine."Document Type"::Order, SalesShipmentLine."Order No.", SalesShipmentLine."Order Line No.") then
            CheckIfTransportOrderLineExists(Database::"Sales Header", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Purchase Receipt Line", 'OnBeforeCheckPurchRcptLine', '', true, false)]
    local procedure UndoPurchaseReceiptLine_OnBeforeCheckPurchRcptLine(var PurchRcptLine: Record "Purch. Rcpt. Line")
    begin
        CheckIfTransportOrderLineExists(Database::"Purch. Rcpt. Header", PurchRcptLine."Document No.", PurchRcptLine."Line No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Return Shipment Line", 'OnBeforeCheckReturnShptLine', '', true, false)]
    local procedure UndoReturnShipmentLine_OnBeforeCheckReturnShptLine(var ReturnShptLine: Record "Return Shipment Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CheckIfTransportOrderLineExists(Database::"Return Shipment Header", ReturnShptLine."Document No.", ReturnShptLine."Line No.");
        if PurchaseLine.Get(PurchaseLine."Document Type"::"Return Order", ReturnShptLine."Return Order No.", ReturnShptLine."Return Order Line No.") then
            CheckIfTransportOrderLineExists(Database::"Purchase Header", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", PurchaseLine."Line No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Service Shipment Line", 'OnBeforeCheckServShptLine', '', true, false)]
    local procedure UndoServiceShipmentLine_OnBeforeCheckServShptLine(var ServiceShptLine: Record "Service Shipment Line")
    var
        ServiceLine: Record "Service Line";
    begin
        CheckIfTransportOrderLineExists(Database::"Service Shipment Header", ServiceShptLine."Document No.", ServiceShptLine."Line No.");
        if ServiceLine.Get(ServiceLine."Document Type"::Order, ServiceShptLine."Order No.", ServiceShptLine."Order Line No.") then
            CheckIfTransportOrderLineExists(Database::"Service Header", ServiceLine."Document Type".AsInteger(), ServiceLine."Document No.", ServiceLine."Line No.");
    end;

    local procedure CheckIfTransportOrderLineExists(TableID: Integer; "Source No.": Code[20]; "Source Line No.": Integer)
    var
        TransportOrderExistsErr: Label 'At least one Transport Order exists (%1) for the line(s) that is (are) being reversed. Please remove the lines on the transport order(s) prior to reversing the shipment.', Comment = '%1 = Transport Order No.';
    begin
        TransportOrderLine.SetRange("Source Document Table No.", TableID);
        TransportOrderLine.SetRange("Source Document No.", "Source No.");
        TransportOrderLine.SetRange("Source Document Line No.", "Source Line No.");
        if TransportOrderLine.FindFirst() then
            Error(TransportOrderExistsErr, TransportOrderLine."Transport Order No.");
    end;

    local procedure CheckIfTransportOrderLineExists(TableID: Integer; DocType: Integer; "Source No.": Code[20]; "Source Line No.": Integer)
    begin
        TransportOrderLine.SetRange("Source Document Type", DocType);
        CheckIfTransportOrderLineExists(TableID, "Source No.", "Source Line No.");
    end;

    var
        TransportOrderLine: Record "IDYS Transport Order Line";
}