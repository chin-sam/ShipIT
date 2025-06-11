codeunit 11147658 "IDYS Whse. Shpt. Line Events"
{

#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnBeforeCreateShptLineFromSalesLine', '', true, false)]
#pragma warning restore
    local procedure WhseCreateSourceDocument_OnBeforeCreateShptLineFromSalesLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; SalesLine: Record "Sales Line")
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Warehouse Mgt.", 'OnBeforeCreateShptLineFromSalesLine', '', true, false)]
    local procedure SalesWarehouseMgt_OnBeforeCreateShptLineFromSalesLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; SalesLine: Record "Sales Line")
#endif
    var
        SalesHeader: Record "Sales Header";
    begin
        WarehouseShipmentLine."IDYS Shipping Agent Code" := SalesLine."Shipping Agent Code";
        WarehouseShipmentLine."IDYS Shipping Agent Srv Code" := SalesLine."Shipping Agent Service Code";
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then begin
            WarehouseShipmentLine."IDYS Shipment Method Code" := SalesHeader."Shipment Method Code";
            WarehouseShipmentLine."IDYS Do Not Insure" := SalesHeader."IDYS Do Not Insure";
        end;
    end;
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnBeforeCreateShptLineFromTransLine', '', true, false)]
#pragma warning restore
    local procedure WhseCreateSourceDocument_OnBeforeCreateShptLineFromTransLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; TransferLine: Record "Transfer Line")
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Transfer Warehouse Mgt.", 'OnBeforeCreateShptLineFromTransLine', '', true, false)]
    local procedure TransferWarehouseMgt_OnBeforeCreateShptLineFromTransLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; TransferLine: Record "Transfer Line")
#endif
    var
        TranferHeader: Record "Transfer Header";
    begin
        WarehouseShipmentLine."IDYS Shipping Agent Code" := TransferLine."Shipping Agent Code";
        WarehouseShipmentLine."IDYS Shipping Agent Srv Code" := TransferLine."Shipping Agent Service Code";
        if TranferHeader.Get(TransferLine."Document No.") then begin
            WarehouseShipmentLine."IDYS Shipment Method Code" := TranferHeader."Shipment Method Code";
            WarehouseShipmentLine."IDYS Do Not Insure" := TranferHeader."IDYS Do Not Insure";
        end;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnBeforeCreateShptLineFromPurchLine', '', true, false)]
#pragma warning restore
    local procedure WhseCreateSourceDocument_OnBeforeCreateShptLineFromPurchLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; PurchaseLine: Record "Purchase Line")
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchases Warehouse Mgt.", 'OnFromPurchLine2ShptLineOnBeforeCreateShptLine', '', true, false)]
    local procedure PurchasesWarehouseMgt_OnBeforeCreateShptLineFromPurchLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; PurchaseLine: Record "Purchase Line")
#endif
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then begin
            WarehouseShipmentLine."IDYS Shipping Agent Code" := PurchaseHeader."IDYS Shipping Agent Code";
            WarehouseShipmentLine."IDYS Shipping Agent Srv Code" := PurchaseHeader."IDYS Shipping Agent Srv Code";
            WarehouseShipmentLine."IDYS Shipment Method Code" := PurchaseHeader."Shipment Method Code";
            WarehouseShipmentLine."IDYS Do Not Insure" := PurchaseHeader."IDYS Do Not Insure";
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnAfterCreateWhseDocuments', '', true, false)]
    local procedure GetSourceDocuments_OnAfterCreateWhseDocuments(WhseHeaderCreated: Boolean; var WhseShipmentHeader: Record "Warehouse Shipment Header")
    var
        IDYSSetup: Record "IDYS Setup";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        Update: Boolean;
    begin
        IDYSSetup.Get();
        if not IDYSSetup."Copy Ship. Agent to Whse-Docs" then
            exit;
        if (WhseShipmentHeader."No." = '') then
            exit;
        if WhseShipmentHeader."Shipping Agent Code" = '' then begin
            WarehouseShipmentLine.SetRange("No.", WhseShipmentHeader."No.");
            WarehouseShipmentLine.SetFilter("IDYS Shipping Agent Code", '<>%1', '');
            if WarehouseShipmentLine.FindFirst() then begin
                WarehouseShipmentLine.SetFilter("IDYS Shipping Agent Code", '<>%1&<>%2', '', WarehouseShipmentLine."IDYS Shipping Agent Code");
                Update := WarehouseShipmentLine.IsEmpty();
                if Update then begin
                    WhseShipmentHeader.Validate("Shipping Agent Code", WarehouseShipmentLine."IDYS Shipping Agent Code");
                    WarehouseShipmentLine.SetRange("IDYS Shipping Agent Code", WarehouseShipmentLine."IDYS Shipping Agent Code");
                    WarehouseShipmentLine.SetFilter("IDYS Shipping Agent Srv Code", '<>%1', '');
                    if WarehouseShipmentLine.FindFirst() then begin
                        WarehouseShipmentLine.SetFilter("IDYS Shipping Agent Srv Code", '<>%1&<>%2', '', WarehouseShipmentLine."IDYS Shipping Agent Srv Code");
                        if WarehouseShipmentLine.IsEmpty then
                            WhseShipmentHeader.Validate("Shipping Agent Service Code", WarehouseShipmentLine."IDYS Shipping Agent Srv Code");
                    end;
                end;
            end;
        end;

        if WhseShipmentHeader."Shipment Method Code" = '' then begin
            WarehouseShipmentLine.Reset();
            WarehouseShipmentLine.SetFilter("IDYS Shipment Method Code", '<>%1', '');
            if WarehouseShipmentLine.FindFirst() then begin
                WarehouseShipmentLine.SetFilter("IDYS Shipment Method Code", '<>%1&<>%2', '', WarehouseShipmentLine."IDYS Shipment Method Code");
                Update := WarehouseShipmentLine.IsEmpty();
                if Update then
                    WhseShipmentHeader.Validate("Shipment Method Code", WarehouseShipmentLine."IDYS Shipment Method Code");
            end;
        end;
        if Update then
            WhseShipmentHeader.Modify();
    end;
}