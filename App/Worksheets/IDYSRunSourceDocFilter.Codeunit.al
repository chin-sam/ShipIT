codeunit 11147645 "IDYS Run Source Doc. Filter"
{
    TableNo = "IDYS Transport Source Filter";

    trigger OnRun();
    begin
        ProcessSalesDocuments(Rec);
        ProcessPurchaseReturnOrders(Rec);
        ProcessServiceOrders(Rec);
        ProcessTransferOrders(Rec);
        ProcessSalesShipments(Rec);
        ProcessPurchaseReturnShipments(Rec);
        ProcessServiceShipments(Rec);
        ProcessTransferShipments(Rec);
    end;

    var
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;

    local procedure ProcessSalesDocuments(TransportSourceFilter: Record "IDYS Transport Source Filter");
    var
        TempSalesLineBuffer: Record "Sales Line" temporary;
        SalesHeader: Record "Sales Header";
        CreateWorksheetLine: Codeunit "IDYS Create Worksheet Line";
    begin
        if not TransportSourceFilter."Sales Orders" then
            exit;

        BufferSalesOrderLines(TempSalesLineBuffer);

        TempSalesLineBuffer.SetRange("Document Type", TempSalesLineBuffer."Document Type");
        TempSalesLineBuffer.SetRange(Type, TempSalesLineBuffer.Type::Item);

        TempSalesLineBuffer.SetFilter("Sell-to Customer No.", TransportSourceFilter."Sell-to Customer No. Filter");
        TempSalesLineBuffer.SetFilter("Shipping Agent Code", TransportSourceFilter."Shipping Agent Code Filter");
        TempSalesLineBuffer.SetFilter("Shipping Agent Service Code", TransportSourceFilter."Shipping Agent Service Filter");
        TempSalesLineBuffer.SetFilter("No.", TransportSourceFilter."Item No. Filter");
        TempSalesLineBuffer.SetFilter("Variant Code", TransportSourceFilter."Variant Code Filter");
        TempSalesLineBuffer.SetFilter("Unit of Measure Code", TransportSourceFilter."Unit of Measure Filter");
        TempSalesLineBuffer.SetFilter("Location Code", TransportSourceFilter."Location Code Filter");

        if TempSalesLineBuffer.FindSet() then
            repeat
                SalesHeader.SetRange("Document Type", TempSalesLineBuffer."Document Type");
                SalesHeader.SetRange("No.", TempSalesLineBuffer."Document No.");
                SalesHeader.SetFilter("Shipment Method Code", TransportSourceFilter."Shipment Method Code Filter");

                if not SalesHeader.IsEmpty() then
                    CreateWorksheetLine.FromSalesOrderLine(TempSalesLineBuffer, TempTransportWorksheetLineBuffer);
            until TempSalesLineBuffer.Next() = 0;
    end;

    local procedure ProcessPurchaseReturnOrders(TransportSourceFilter: Record "IDYS Transport Source Filter");
    var
        TempPurchaseLineBuffer: Record "Purchase Line" temporary;
        PurchaseHeader: Record "Purchase Header";
        CreateWorksheetLine: Codeunit "IDYS Create Worksheet Line";
    begin
        if not TransportSourceFilter."Purchase Return Orders" then
            exit;

        BufferPurchaseReturnOrderLines(TempPurchaseLineBuffer);

        TempPurchaseLineBuffer.SetRange("Document Type", TempPurchaseLineBuffer."Document Type"::"Return Order");
        TempPurchaseLineBuffer.SetRange(Type, TempPurchaseLineBuffer.Type::Item);

        TempPurchaseLineBuffer.SetFilter("Buy-from Vendor No.", TransportSourceFilter."Buy-from Vendor No. Filter");
        TempPurchaseLineBuffer.SetFilter("No.", TransportSourceFilter."Item No. Filter");
        TempPurchaseLineBuffer.SetFilter("Variant Code", TransportSourceFilter."Variant Code Filter");
        TempPurchaseLineBuffer.SetFilter("Unit of Measure Code", TransportSourceFilter."Unit of Measure Filter");
        TempPurchaseLineBuffer.SetFilter("Location Code", TransportSourceFilter."Location Code Filter");

        if TempPurchaseLineBuffer.FindSet() then
            repeat
                PurchaseHeader.SetRange("Document Type", TempPurchaseLineBuffer."Document Type");
                PurchaseHeader.SetRange("No.", TempPurchaseLineBuffer."Document No.");
                PurchaseHeader.SetFilter("Shipment Method Code", TransportSourceFilter."Shipment Method Code Filter");

                if not PurchaseHeader.IsEmpty() then
                    CreateWorksheetLine.FromPurchaseReturnOrderLine(TempPurchaseLineBuffer, '', '', TempTransportWorksheetLineBuffer);
            until TempPurchaseLineBuffer.Next() = 0;
    end;

    local procedure ProcessServiceOrders(TransportSourceFilter: Record "IDYS Transport Source Filter");
    var
        TempServiceLineBuffer: Record "Service Line" temporary;
        ServiceHeader: Record "Service Header";
        CreateWorksheetLine: Codeunit "IDYS Create Worksheet Line";
    begin
        if not TransportSourceFilter."Service Orders" then
            exit;

        BufferServiceLines(TempServiceLineBuffer);

        TempServiceLineBuffer.SetRange("Document Type", TempServiceLineBuffer."Document Type"::Order);
        TempServiceLineBuffer.SetRange(Type, TempServiceLineBuffer.Type::Item);

        TempServiceLineBuffer.SetFilter("Customer No.", TransportSourceFilter."Customer No. Filter");
        TempServiceLineBuffer.SetFilter("Shipping Agent Code", TransportSourceFilter."Shipping Agent Code Filter");
        TempServiceLineBuffer.SetFilter("Shipping Agent Service Code", TransportSourceFilter."Shipping Agent Service Filter");
        TempServiceLineBuffer.SetFilter("No.", TransportSourceFilter."Item No. Filter");
        TempServiceLineBuffer.SetFilter("Variant Code", TransportSourceFilter."Variant Code Filter");
        TempServiceLineBuffer.SetFilter("Unit of Measure Code", TransportSourceFilter."Unit of Measure Filter");
        TempServiceLineBuffer.SetFilter("Location Code", TransportSourceFilter."Location Code Filter");

        if TempServiceLineBuffer.FindSet() then
            repeat
                ServiceHeader.SetRange("Document Type", TempServiceLineBuffer."Document Type");
                ServiceHeader.SetRange("No.", TempServiceLineBuffer."Document No.");
                ServiceHeader.SetFilter("Shipment Method Code", TransportSourceFilter."Shipment Method Code Filter");

                if ServiceHeader.FindFirst() then
                    CreateWorksheetLine.FromServiceOrderLine(TempServiceLineBuffer, ServiceHeader."IDYS Requested Delivery Date", TempTransportWorksheetLineBuffer);
            until TempServiceLineBuffer.Next() = 0;
    end;

    local procedure ProcessTransferOrders(TransportSourceFilter: Record "IDYS Transport Source Filter");
    var
        TempTransferLineBuffer: Record "Transfer Line" temporary;
        TransferHeader: Record "Transfer Header";
        CreateWorksheetLine: Codeunit "IDYS Create Worksheet Line";
    begin
        if not TransportSourceFilter."Transfer Orders" then
            exit;

        BufferTransferOrderLines(TempTransferLineBuffer);

        TempTransferLineBuffer.SetFilter("Shipping Agent Code", TransportSourceFilter."Shipping Agent Code Filter");
        TempTransferLineBuffer.SetFilter("Shipping Agent Service Code", TransportSourceFilter."Shipping Agent Service Filter");
        TempTransferLineBuffer.SetFilter("Item No.", TransportSourceFilter."Item No. Filter");
        TempTransferLineBuffer.SetFilter("Variant Code", TransportSourceFilter."Variant Code Filter");
        TempTransferLineBuffer.SetFilter("Unit of Measure Code", TransportSourceFilter."Unit of Measure Filter");
        TempTransferLineBuffer.SetFilter("Transfer-from Code", TransportSourceFilter."Location Code Filter");

        if TempTransferLineBuffer.FindSet() then
            repeat
                TransferHeader.SetRange("No.", TempTransferLineBuffer."Document No.");
                TransferHeader.SetFilter("Shipment Method Code", TransportSourceFilter."Shipment Method Code Filter");

                if not TransferHeader.IsEmpty() then
                    CreateWorksheetLine.FromTransferOrderLine(TempTransferLineBuffer, TempTransportWorksheetLineBuffer);
            until TempTransferLineBuffer.Next() = 0;
    end;

    procedure Execute(TransportSourceFilter: Record "IDYS Transport Source Filter"): Integer
    var
        TransportWorksheetLine: Record "IDYS Transport Worksheet Line";
        TransportWorksheet: Page "IDYS Transport Worksheet";
        Cntr: Integer;
        LinesWillBeDeletedQst: Label 'All the existing lines in the %1 will be deleted.\\Do you want to continue?', Comment = '%1 = Transport Worksheet';
    begin
        if not TransportWorksheetLine.IsEmpty then
            if not Confirm(LinesWillBeDeletedQst, true, TransportWorksheet.Caption) then
                Error('');
        TransportWorksheetLine.DeleteAll();

        Run(TransportSourceFilter);

        if FindWorksheetLine(TransportWorksheetLine, '-') then
            repeat
                TransportWorksheetLine.Insert(true);
                Cntr += 1;
            until NextWorksheetLine(TransportWorksheetLine, 1) = 0;
        exit(Cntr);
    end;

    procedure ProcessSalesShipments(TransportSourceFilter: Record "IDYS Transport Source Filter");
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        DocumentMgt: Codeunit "IDYS Document Mgt.";
        CreateWorksheetLine: Codeunit "IDYS Create Worksheet Line";
        QtyToSend: Decimal;
        FromPostingDate: Date;
        ToPostingDate: Date;
    begin
        if not TransportSourceFilter."Posted Sales Shipments" then
            exit;

        FromPostingDate := CalcDate(TransportSourceFilter."From Posting Date Calculation");
        ToPostingDate := CalcDate(TransportSourceFilter."To Posting Date Calculation");

        SalesShipmentHeader.SetFilter("Sell-to Customer No.", TransportSourceFilter."Customer No. Filter");
        SalesShipmentHeader.SetFilter("Shipping Agent Code", TransportSourceFilter."Shipping Agent Code Filter");
        SalesShipmentHeader.SetFilter("Shipping Agent Service Code", TransportSourceFilter."Shipping Agent Service Filter");
        SalesShipmentHeader.SetFilter("Shipment Method Code", TransportSourceFilter."Shipment Method Code Filter");
        SalesShipmentHeader.SetRange("Posting Date", FromPostingDate, ToPostingDate);

        if SalesShipmentHeader.FindSet() then
            repeat
                SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
                SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
                SalesShipmentLine.SetFilter("No.", TransportSourceFilter."Item No. Filter");
                SalesShipmentLine.SetFilter("Variant Code", TransportSourceFilter."Variant Code Filter");
                SalesShipmentLine.SetFilter("Unit of Measure Code", TransportSourceFilter."Unit of Measure Filter");
                SalesShipmentLine.SetFilter("Location Code", TransportSourceFilter."Location Code Filter");

                if SalesShipmentLine.FindSet() then
                    repeat
                        QtyToSend :=
                            SalesShipmentLine."Quantity (Base)" -
                            DocumentMgt.GetSalesShipmentLineQtySent(SalesShipmentLine."Document No.", SalesShipmentLine."Line No.");

                        if QtyToSend > 0 then
                            CreateWorksheetLine.FromPostedSalesShipmentLine(SalesShipmentLine, TempTransportWorksheetLineBuffer);
                    until SalesShipmentLine.Next() = 0;
            until SalesShipmentHeader.Next() = 0;
    end;

    [Obsolete('Removed due to wrongfully implemented flow', '21.0')]
    procedure ProcessSalesReturnReceipts(TransportSourceFilter: Record "IDYS Transport Source Filter");
    var
    begin
    end;

    procedure ProcessPurchaseReturnShipments(TransportSourceFilter: Record "IDYS Transport Source Filter");
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
        ReturnShipmentLine: Record "Return Shipment Line";
        DocumentMgt: Codeunit "IDYS Document Mgt.";
        CreateWorksheetLine: Codeunit "IDYS Create Worksheet Line";
        QtyToSend: Decimal;
        FromPostingDate: Date;
        ToPostingDate: Date;
    begin
        if not TransportSourceFilter."Posted Purch. Return Shipments" then
            exit;

        FromPostingDate := CalcDate(TransportSourceFilter."From Posting Date Calculation");
        ToPostingDate := CalcDate(TransportSourceFilter."To Posting Date Calculation");

        ReturnShipmentHeader.SetFilter("Buy-from Vendor No.", TransportSourceFilter."Buy-from Vendor No. Filter");
        ReturnShipmentHeader.SetFilter("IDYS Shipping Agent Code", TransportSourceFilter."Shipping Agent Code Filter");
        ReturnShipmentHeader.SetFilter("IDYS Shipping Agent Srv Code", TransportSourceFilter."Shipping Agent Service Filter");
        ReturnShipmentHeader.SetFilter("Shipment Method Code", TransportSourceFilter."Shipment Method Code Filter");
        ReturnShipmentHeader.SetRange("Posting Date", FromPostingDate, ToPostingDate);

        if ReturnShipmentHeader.FindSet() then
            repeat
                ReturnShipmentLine.SetRange("Document No.", ReturnShipmentHeader."No.");
                ReturnShipmentLine.SetRange(Type, ReturnShipmentLine.Type::Item);
                ReturnShipmentLine.SetFilter("No.", TransportSourceFilter."Item No. Filter");
                ReturnShipmentLine.SetFilter("Variant Code", TransportSourceFilter."Variant Code Filter");
                ReturnShipmentLine.SetFilter("Unit of Measure Code", TransportSourceFilter."Unit of Measure Filter");
                ReturnShipmentLine.SetFilter("Location Code", TransportSourceFilter."Location Code Filter");

                if ReturnShipmentLine.FindSet() then
                    repeat
                        QtyToSend :=
                            ReturnShipmentLine."Quantity (Base)" -
                            DocumentMgt.GetReturnShipmentLineQtySent(ReturnShipmentLine."Document No.", ReturnShipmentLine."Line No.");

                        if QtyToSend > 0 then
                            CreateWorksheetLine.FromReturnShipmentLine(ReturnShipmentLine, '', '', TempTransportWorksheetLineBuffer);
                    until ReturnShipmentLine.Next() = 0;
            until ReturnShipmentHeader.Next() = 0;
    end;

    procedure ProcessServiceShipments(TransportSourceFilter: Record "IDYS Transport Source Filter");
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceShipmentLine: Record "Service Shipment Line";
        DocumentMgt: Codeunit "IDYS Document Mgt.";
        CreateWorksheetLine: Codeunit "IDYS Create Worksheet Line";
        QtyToSend: Decimal;
        FromPostingDate: Date;
        ToPostingDate: Date;
    begin
        if not TransportSourceFilter."Posted Service Shipments" then
            exit;

        FromPostingDate := CalcDate(TransportSourceFilter."From Posting Date Calculation");
        ToPostingDate := CalcDate(TransportSourceFilter."To Posting Date Calculation");

        ServiceShipmentHeader.SetFilter("Customer No.", TransportSourceFilter."Customer No. Filter");
        ServiceShipmentHeader.SetRange("Posting Date", FromPostingDate, ToPostingDate);
        ServiceShipmentHeader.SetFilter("IDYS Shipment Method Code", TransportSourceFilter."Shipment Method Code Filter");

        if ServiceShipmentHeader.FindSet() then
            repeat
                ServiceShipmentLine.SetRange("Document No.", ServiceShipmentHeader."No.");
                ServiceShipmentLine.SetRange(Type, ServiceShipmentLine.Type::Item);
                ServiceShipmentLine.SetFilter("No.", TransportSourceFilter."Item No. Filter");
                ServiceShipmentLine.SetFilter("Variant Code", TransportSourceFilter."Variant Code Filter");
                ServiceShipmentLine.SetFilter("Unit of Measure Code", TransportSourceFilter."Unit of Measure Filter");
                ServiceShipmentLine.SetFilter("Location Code", TransportSourceFilter."Location Code Filter");

                if ServiceShipmentLine.FindSet() then
                    repeat
                        QtyToSend :=
                            ServiceShipmentLine."Quantity (Base)" -
                            DocumentMgt.GetServiceShipmentLineQtySent(ServiceShipmentLine."Document No.", ServiceShipmentLine."Line No.");

                        if QtyToSend > 0 then
                            CreateWorksheetLine.FromServiceShipmentLine(ServiceShipmentLine, '', '', '', ServiceShipmentHeader."IDYS Requested Delivery Date", TempTransportWorksheetLineBuffer);
                    until ServiceShipmentLine.Next() = 0;
            until ServiceShipmentHeader.Next() = 0;
    end;

    procedure ProcessTransferShipments(TransportSourceFilter: Record "IDYS Transport Source Filter");
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
        DocumentMgt: Codeunit "IDYS Document Mgt.";
        CreateWorksheetLine: Codeunit "IDYS Create Worksheet Line";
        QtyToSend: Decimal;
        FromPostingDate: Date;
        ToPostingDate: Date;
    begin
        if not TransportSourceFilter."Posted Transfer Shipments" then
            exit;

        FromPostingDate := CalcDate(TransportSourceFilter."From Posting Date Calculation");
        ToPostingDate := CalcDate(TransportSourceFilter."To Posting Date Calculation");

        TransferShipmentHeader.SetFilter("Shipment Method Code", TransportSourceFilter."Shipment Method Code Filter");
        TransferShipmentHeader.SetRange("Posting Date", FromPostingDate, ToPostingDate);

        if TransferShipmentHeader.FindSet() then
            repeat
                TransferShipmentLine.SetRange("Document No.", TransferShipmentHeader."No.");
                TransferShipmentLine.SetFilter("Item No.", TransportSourceFilter."Item No. Filter");
                TransferShipmentLine.SetFilter("Variant Code", TransportSourceFilter."Variant Code Filter");
                TransferShipmentLine.SetFilter("Unit of Measure Code", TransportSourceFilter."Unit of Measure Filter");
                TransferShipmentLine.SetFilter("Transfer-From Code", TransportSourceFilter."Location Code Filter");

                if TransferShipmentLine.FindSet() then
                    repeat
                        QtyToSend :=
                            TransferShipmentLine."Quantity (Base)" -
                            DocumentMgt.GetServiceShipmentLineQtySent(TransferShipmentLine."Document No.", TransferShipmentLine."Line No.");

                        if QtyToSend > 0 then
                            CreateWorksheetLine.FromTransferShipmentLine(TransferShipmentLine, TempTransportWorksheetLineBuffer);
                    until TransferShipmentLine.Next() = 0;
            until TransferShipmentHeader.Next() = 0;
    end;

    procedure FindWorksheetLine(var Rec: Record "IDYS Transport Worksheet Line"; Which: Text) Found: Boolean;
    begin
        TempTransportWorksheetLineBuffer.Copy(Rec);
        Found := TempTransportWorksheetLineBuffer.Find(Which);

        if Found then
            Rec := TempTransportWorksheetLineBuffer;
    end;

    procedure NextWorksheetLine(var Rec: Record "IDYS Transport Worksheet Line"; Steps: Integer) ActualSteps: Integer;
    begin
        TempTransportWorksheetLineBuffer.Copy(Rec);
        ActualSteps := TempTransportWorksheetLineBuffer.NEXT(Steps);

        if ActualSteps > 0 then
            Rec := TempTransportWorksheetLineBuffer;
    end;

    local procedure BufferSalesOrderLines(var SalesLineBuffer: Record "Sales Line");
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("IDYS Quantity To Send", '<>%1', 0);
        if SalesLine.FindSet() then
            repeat
                BufferSalesOrderLine(SalesLine, SalesLineBuffer);
            until SalesLine.Next() = 0;
    end;

    local procedure BufferSalesOrderLine(SalesLine: Record "Sales Line"; var SalesLineBuffer: Record "Sales Line");
    begin
        SalesLineBuffer := SalesLine;
        SalesLineBuffer.Insert();
    end;

    local procedure BufferPurchaseReturnOrderLines(var PurchaseLineBuffer: Record "Purchase Line");
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::"Return Order");
        PurchaseLine.SetFilter("IDYS Quantity To Send", '<>%1', 0);
        if PurchaseLine.FindSet() then
            repeat
                BufferPurchaseReturnOrderLine(PurchaseLine, PurchaseLineBuffer);
            until PurchaseLine.Next() = 0;
    end;

    local procedure BufferPurchaseReturnOrderLine(PurchaseLine: Record "Purchase Line"; var PurchaseLineBuffer: Record "Purchase Line");
    begin
        PurchaseLineBuffer := PurchaseLine;
        PurchaseLineBuffer.Insert();
    end;

    local procedure BufferServiceLines(var ServiceLineBuffer: Record "Service Line");
    var
        ServiceLine: Record "Service Line";
    begin
        ServiceLine.SetRange("Document Type", ServiceLine."Document Type"::Order);
        ServiceLine.SetFilter("IDYS Quantity To Send", '<>%1', 0);
        if ServiceLine.FindSet() then
            repeat
                BufferServiceLine(ServiceLine, ServiceLineBuffer);
            until ServiceLine.Next() = 0;
    end;

    local procedure BufferServiceLine(ServiceLine: Record "Service Line"; var ServiceLineBuffer: Record "Service Line");
    begin
        ServiceLineBuffer := ServiceLine;
        ServiceLineBuffer.Insert();
    end;

    local procedure BufferTransferOrderLines(var TransferLineBuffer: Record "Transfer Line");
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetFilter("IDYS Quantity To Send", '<>%1', 0);
        TransferLine.SetRange("Derived From Line No.", 0);
        if TransferLine.FindSet() then
            repeat
                BufferTransferOrderLine(TransferLine, TransferLineBuffer);
            until TransferLine.Next() = 0;
    end;

    local procedure BufferTransferOrderLine(TransferLine: Record "Transfer Line"; var TransferLineBuffer: Record "Transfer Line");
    begin
        TransferLineBuffer := TransferLine;
        TransferLineBuffer.Insert();
    end;
}

