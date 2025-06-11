codeunit 11147670 "IDYS Whse Activity Post Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnBeforeRun', '', true, false)]
    local procedure WhsePostShipment_OnBeforeRun(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        WarehouseShipment: Record "Warehouse Shipment Header";
        IDYSWarehouseShipmentLine: Record "Warehouse Shipment Line";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        Setup: Record "IDYS Setup";
        DoTest: Boolean;
    begin
        if Setup.Get() then
            if Setup."Base Transport Orders on" <> Setup."Base Transport Orders on"::"Posted documents" then
                exit;
        IDYSWarehouseShipmentLine.CopyFilters(WarehouseShipmentLine);
        IDYSWarehouseShipmentLine.SetRange("Source Document", IDYSWarehouseShipmentLine."Source Document"::"Sales Order");
        if not IDYSWarehouseShipmentLine.IsEmpty() then
            DoTest := Setup."After Posting Sales Orders" <> Setup."After Posting Sales Orders"::"Do nothing";
        if not DoTest then begin
            IDYSWarehouseShipmentLine.SetRange("Source Document", IDYSWarehouseShipmentLine."Source Document"::"Outbound Transfer");
            if not IDYSWarehouseShipmentLine.IsEmpty() then
                DoTest := Setup."After Posting Transfer Orders" <> Setup."After Posting Transfer Orders"::"Do nothing";
        end;
        if not DoTest then begin
            IDYSWarehouseShipmentLine.SetRange("Source Document", IDYSWarehouseShipmentLine."Source Document"::"Purchase Return Order");
            if not IDYSWarehouseShipmentLine.IsEmpty() then
                DoTest := Setup."After Posting Purch. Ret. Ord." <> Setup."After Posting Purch. Ret. Ord."::"Do nothing";
        end;
        if not DoTest then begin
            IDYSWarehouseShipmentLine.SetRange("Source Document", IDYSWarehouseShipmentLine."Source Document"::"Service Order");
            if not IDYSWarehouseShipmentLine.IsEmpty() then
                DoTest := Setup."After Posting Service Orders" <> Setup."After Posting Service Orders"::"Do nothing";
        end;
        if DoTest then
            if WarehouseShipment.Get(WarehouseShipmentLine."No.") then begin
                WarehouseShipment.TestField("Shipping Agent Code");
                WarehouseShipment.TestField("Shipping Agent Service Code");
                if not IDYSShipAgentMapping.Get(WarehouseShipment."Shipping Agent Code") then
                    IDYSShipAgentMapping.Init();
                if IDYSProviderMgt.CheckShipmentMethodCode(IDYSShipAgentMapping.Provider) then
                    WarehouseShipment.TestField("Shipment Method Code");
                ShippingAgentServices.Get(WarehouseShipment."Shipping Agent Code", WarehouseShipment."Shipping Agent Service Code");
                ShippingAgentServices.TestField(ShippingAgentServices."Shipping Time");
            end;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnInitSourceDocumentHeaderOnBeforeSalesHeaderModify', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Whse. Post Shipment", 'OnInitSourceDocumentHeaderOnBeforeSalesHeaderModify', '', true, false)]
#endif
    local procedure WhsePostShipment_OnInitSourceDocumentHeaderOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header"; var ModifyHeader: Boolean; var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        if IsNullGuid(WarehouseShipmentHeader."IDYS Whse Post Batch ID") then
            WarehouseShipmentHeader.Validate("IDYS Whse Post Batch ID", CreateGuid());
        SalesHeader."IDYS Whse Post Batch ID" := WarehouseShipmentHeader."IDYS Whse Post Batch ID";
        ModifyHeader := true;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnInitSourceDocumentHeaderOnBeforePurchHeaderModify', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Whse. Post Shipment", 'OnInitSourceDocumentHeaderOnBeforePurchHeaderModify', '', true, false)]
#endif
    local procedure WhsePostShipment_OnInitSourceDocumentHeaderOnBeforePurchHeaderModify(var PurchaseHeader: Record "Purchase Header"; var ModifyHeader: Boolean; var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        if IsNullGuid(WarehouseShipmentHeader."IDYS Whse Post Batch ID") then
            WarehouseShipmentHeader.Validate("IDYS Whse Post Batch ID", CreateGuid());
        PurchaseHeader."IDYS Whse Post Batch ID" := WarehouseShipmentHeader."IDYS Whse Post Batch ID";
        ModifyHeader := true;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnInitSourceDocumentHeaderOnBeforeTransHeaderModify', '', true, false)]
    local procedure WhsePostShipment_OnInitSourceDocumentHeaderOnBeforeTransHeaderModify(var TransferHeader: Record "Transfer Header"; var ModifyHeader: Boolean; var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        if IsNullGuid(WarehouseShipmentHeader."IDYS Whse Post Batch ID") then
            WarehouseShipmentHeader.Validate("IDYS Whse Post Batch ID", CreateGuid());
        TransferHeader."IDYS Whse Post Batch ID" := WarehouseShipmentHeader."IDYS Whse Post Batch ID";
        ModifyHeader := true;
    end;    
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnBeforePostSourceHeader', '', true, false)]
    local procedure WhsePostShipment_OnInitSourceDocumentHeaderOnBeforeTransHeaderModify(GlobalSourceHeader: Variant; var WhseShptLine: Record "Warehouse Shipment Line"; WhsePostParameters: Record "Whse. Post Parameters" temporary)
    var
        TransferHeader: Record "Transfer Header";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        SourceRecRef: RecordRef;
    begin
        // NOTE: Missing integration event in BC25: OnInitSourceDocumentHeaderOnBeforeTransHeaderModify()
        SourceRecRef.GetTable(GlobalSourceHeader);
        case SourceRecRef.Number of
            Database::"Transfer Header":
                begin
                    WarehouseShipmentHeader.Get(WhseShptLine."No.");
                    TransferHeader := GlobalSourceHeader;
                    if IsNullGuid(WarehouseShipmentHeader."IDYS Whse Post Batch ID") then begin
                        WarehouseShipmentHeader.Validate("IDYS Whse Post Batch ID", CreateGuid());
                        WarehouseShipmentHeader.Modify();
                    end;
                    TransferHeader."IDYS Whse Post Batch ID" := WarehouseShipmentHeader."IDYS Whse Post Batch ID";
                    TransferHeader.Modify();
                end;
        end;
    end;
#endif

#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnInitSourceDocumentHeaderOnBeforeServiceHeaderModify', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv. Whse Post-Shipment", 'OnInitSourceDocumentHeaderOnBeforeServiceHeaderModify', '', true, false)]
#endif
    local procedure WhsePostShipment_OnInitSourceDocumentHeaderOnBeforeServiceHeaderModify(var ServiceHeader: Record "Service Header"; var ModifyHeader: Boolean; var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        if IsNullGuid(WarehouseShipmentHeader."IDYS Whse Post Batch ID") then
            WarehouseShipmentHeader.Validate("IDYS Whse Post Batch ID", CreateGuid());
        ServiceHeader."IDYS Whse Post Batch ID" := WarehouseShipmentHeader."IDYS Whse Post Batch ID";
        ModifyHeader := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnInitSourceDocumentHeaderOnBeforeSalesHeaderModify', '', true, false)]
    local procedure WhsePostReceipt_OnInitSourceDocumentHeaderOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header"; var ModifyHeader: Boolean; var WarehouseReceiptHeader: Record "Warehouse Receipt Header")
    begin
        if IsNullGuid(WarehouseReceiptHeader."IDYS Whse Post Batch ID") then
            WarehouseReceiptHeader.Validate("IDYS Whse Post Batch ID", CreateGuid());
        SalesHeader."IDYS Whse Post Batch ID" := WarehouseReceiptHeader."IDYS Whse Post Batch ID";
        ModifyHeader := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnAfterPostWhseShipment', '', true, false)]
    local procedure WhsePostShipment_OnAfterPostWhseShipment(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        IDYSCreateTptOrdWrksh: Codeunit "IDYS Create Tpt. Ord. (Wrksh.)";
    begin
        if not IsNullGuid(WarehouseShipmentHeader."IDYS Whse Post Batch ID") then begin
            IDYSCreateTptOrdWrksh.ConvertRegisterIntoListAndShowTransportOrder(WarehouseShipmentHeader."IDYS Whse Post Batch ID");
            Clear(WarehouseShipmentHeader."IDYS Whse Post Batch ID");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnCodeOnAfterPostSourceDocuments', '', true, false)]
    local procedure WhsePostReceipt_OnCodeOnAfterPostSourceDocuments(var WarehouseReceiptHeader: Record "Warehouse Receipt Header")
    var
        IDYSCreateTptOrdWrksh: Codeunit "IDYS Create Tpt. Ord. (Wrksh.)";
    begin
        if not IsNullGuid(WarehouseReceiptHeader."IDYS Whse Post Batch ID") then
            IDYSCreateTptOrdWrksh.ConvertRegisterIntoListAndShowTransportOrder(WarehouseReceiptHeader."IDYS Whse Post Batch ID");
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
}