codeunit 11147700 "IDYS Transport Order API Mgt."
{
    Permissions =
#if BC17 or BC18 or BC19 or BC20 or BC21
        tabledata "Item Ledger Entry" = r,
#endif
        tabledata "Sales Shipment Header" = r,
        tabledata "Sales Shipment Line" = r,
        tabledata "Return Shipment Header" = r,
        tabledata "Return Shipment Line" = r,
        tabledata "Transfer Shipment Header" = r,
        tabledata "Transfer Shipment Line" = r,
        tabledata "Service Shipment Header" = r,
        tabledata "Service Shipment Line" = r,
        tabledata "IDYS Provider Package Type" = rimd,
        tabledata "IDYS BookingProf. Package Type" = rimd,
        tabledata "IDYS Provider Setup" = rimd,
        tabledata "IDYS Setup" = rimd;

    procedure AddTransportOrderPackageContent(TransportOrderPackage: Record "IDYS Transport Order Package"; TransportOrderLineNo: Integer; SourceLineRecordId: RecordId; QtyBase: Decimal; NetWeight: Decimal; GrossWeight: Decimal)
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        TransferLine: Record "Transfer Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        ServiceShipmentLine: Record "Service Shipment Line";
        IDYSSetup: Record "IDYS Setup";
        TransportOrderLine: Record "IDYS Transport Order Line";
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        CreateTptOrdWrksh: Codeunit "IDYS Create Tpt. Ord. (Wrksh.)";
    begin
        TransportOrderDelNote.SetPostponeTotals(SkipUpdateTotals);

        IDYSSetup.Get();
        IDYSSetup.TestField("Link Del. Lines with Packages");
        if TransportOrderLineNo <> 0 then
            TransportOrderLine.Get(TransportOrderPackage."Transport Order No.", TransportOrderLineNo)
        else
            TransportOrderLine.Get(TransportOrderPackage."Transport Order No.", FindTransportOrderLineBySource(SourceLineRecordId, TransportOrderPackage."Transport Order No."));
        case SourceLineRecordId.TableNo of
            database::"Sales Line":
                begin
                    SalesLine.Get(SourceLineRecordId);
                    if NetWeight <> 0 then
                        SalesLine."Net Weight" := NetWeight;
                    if GrossWeight <> 0 then
                        SalesLine."Gross Weight" := GrossWeight;
                    CreateTptOrdWrksh.PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, SalesLine."Currency Code", QtyBase, SalesLine."Quantity (Base)", SalesLine."Gross Weight", SalesLine."Net Weight", SalesLine.Type = SalesLine.Type::Item);
                end;
            database::"Purchase Line":
                begin
                    PurchaseLine.Get(SourceLineRecordId);
                    if NetWeight <> 0 then
                        PurchaseLine."Net Weight" := NetWeight;
                    if GrossWeight <> 0 then
                        PurchaseLine."Gross Weight" := GrossWeight;
                    CreateTptOrdWrksh.PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, PurchaseLine."Currency Code", QtyBase, PurchaseLine."Quantity (Base)", PurchaseLine."Gross Weight", PurchaseLine."Net Weight", PurchaseLine.Type = PurchaseLine.Type::Item);
                end;
            database::"Transfer Line":
                begin
                    TransferLine.Get(SourceLineRecordId);
                    if NetWeight <> 0 then
                        TransferLine."Net Weight" := NetWeight;
                    if GrossWeight <> 0 then
                        TransferLine."Gross Weight" := GrossWeight;
                    CreateTptOrdWrksh.PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, '', QtyBase, TransferLine."Quantity (Base)", TransferLine."Gross Weight", TransferLine."Net Weight", true);
                end;
            database::"Service Line":
                begin
                    ServiceLine.Get(SourceLineRecordId);
                    if NetWeight <> 0 then
                        ServiceLine."Net Weight" := NetWeight;
                    if GrossWeight <> 0 then
                        ServiceLine."Gross Weight" := GrossWeight;
                    CreateTptOrdWrksh.PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, ServiceLine."Currency Code", QtyBase, ServiceLine."Quantity (Base)", ServiceLine."Gross Weight", ServiceLine."Net Weight", ServiceLine.Type = ServiceLine.Type::Item);
                end;
            database::"Sales Shipment Line":
                begin
                    SalesShipmentLine.Get(SourceLineRecordId);
                    SalesShipmentLine.CalcFields("Currency Code");
                    if NetWeight <> 0 then
                        SalesShipmentLine."Net Weight" := NetWeight;
                    if GrossWeight <> 0 then
                        SalesShipmentLine."Gross Weight" := GrossWeight;
                    CreateTptOrdWrksh.PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, SalesShipmentLine."Currency Code", QtyBase, SalesShipmentLine."Quantity (Base)", SalesShipmentLine."Gross Weight", SalesShipmentLine."Net Weight", SalesShipmentLine.Type = SalesShipmentLine.Type::Item);
                end;
            database::"Return Shipment Line":
                begin
                    ReturnShipmentLine.Get(SourceLineRecordId);
                    ReturnShipmentLine.CalcFields("Currency Code");
                    if NetWeight <> 0 then
                        ReturnShipmentLine."Net Weight" := NetWeight;
                    if GrossWeight <> 0 then
                        ReturnShipmentLine."Gross Weight" := GrossWeight;
                    CreateTptOrdWrksh.PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, ReturnShipmentLine."Currency Code", QtyBase, ReturnShipmentLine."Quantity (Base)", ReturnShipmentLine."Gross Weight", ReturnShipmentLine."Net Weight", ReturnShipmentLine.Type = ReturnShipmentLine.Type::Item);
                end;
            database::"Transfer Shipment Line":
                begin
                    TransferShipmentLine.Get(SourceLineRecordId);
                    if NetWeight <> 0 then
                        TransferShipmentLine."Net Weight" := NetWeight;
                    if GrossWeight <> 0 then
                        TransferShipmentLine."Gross Weight" := GrossWeight;
                    CreateTptOrdWrksh.PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, '', QtyBase, TransferShipmentLine."Quantity (Base)", TransferShipmentLine."Gross Weight", TransferShipmentLine."Net Weight", true);
                end;
            database::"Service Shipment Line":
                begin
                    ServiceShipmentLine.Get(SourceLineRecordId);
                    if NetWeight <> 0 then
                        ServiceShipmentLine."Net Weight" := NetWeight;
                    if GrossWeight <> 0 then
                        ServiceShipmentLine."Gross Weight" := GrossWeight;
                    CreateTptOrdWrksh.PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, ServiceShipmentLine."Currency Code", QtyBase, ServiceShipmentLine."Quantity (Base)", ServiceShipmentLine."Gross Weight", ServiceShipmentLine."Net Weight", ServiceShipmentLine.Type = ServiceShipmentLine.Type::Item);
                end;
        end;
        TransportOrderDelNote.Validate("Transport Order Pkg. Record Id", TransportOrderPackage.RecordId);
        TransportOrderDelNote.Insert(true);
    end;

    procedure AddTransportOrderPackages(var TempTransportOrderPackage: Record "IDYS Transport Order Package")
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        TransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        TotalLoadMeter: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeAddTransportOrderPackages(TempTransportOrderPackage, IsHandled);
        if IsHandled then
            exit;
        if TempTransportOrderPackage.FindSet() then begin
            repeat
                if TempTransportOrderPackage."Transport Order No." <> '' then
                    TransportOrderNo := TempTransportOrderPackage."Transport Order No.";
                if TransportOrderHeader."No." <> TransportOrderNo then begin
#pragma warning disable AA0205
                    if TotalLoadMeter <> 0 then begin
#pragma warning restore AA0205
                        TransportOrderHeader.Validate("Load Meter", TotalLoadMeter);
                        TransportOrderHeader.Modify();
                    end;
                    IDYSTransportOrderPackage.LockTable();
                    IDYSTransportOrderPackage.SetRange("Transport Order No.", TransportOrderNo);
                    IDYSTransportOrderPackage.SetRange("System Created Entry", true);
                    if not IDYSTransportOrderPackage.IsEmpty() then
                        IDYSTransportOrderPackage.DeleteAll(true);
                    IDYSTransportOrderPackage.SetRange("Transport Order No.");
                    IDYSTransportOrderPackage.SetRange("System Created Entry");
                    TransportOrderHeader.Get(TransportOrderNo);
                    TotalLoadMeter := 0;
                end;
                IDYSTransportOrderPackage.SetPostponeTotals(SkipUpdateTotals);
                IDYSTransportOrderPackage.Init();
                IDYSTransportOrderPackage."Transport Order No." := TransportOrderHeader."No.";
                IDYSTransportOrderPackage."Line No." := 0;
                PutTransportOrderPackage(IDYSTransportOrderPackage);
                // Update package fields based on Provider
                case TransportOrderHeader.Provider of
                    "IDYS Provider"::Default,
                    "IDYS Provider"::Transsmart,
                    "IDYS Provider"::Sendcloud,
                    "IDYS Provider"::Cargoson:
                        IDYSTransportOrderPackage.Validate("Provider Package Type Code", TempTransportOrderPackage."Provider Package Type Code");
                    "IDYS Provider"::"Delivery Hub",
                    "IDYS Provider"::Easypost:
                        begin
                            if TempTransportOrderPackage."API Carrier Entry No." <> 0 then
                                IDYSTransportOrderPackage.SetRange("Carrier Entry No. Filter", TempTransportOrderPackage."API Carrier Entry No.");
                            if TempTransportOrderPackage."API Booking Profile Entry No." <> 0 then
                                IDYSTransportOrderPackage.SetRange("Booking P. Entry No. Filter", IDYSProviderMgt.GetBookingProfileEntryNo(TempTransportOrderPackage."Carrier Entry No.", TempTransportOrderPackage."API Booking Profile Entry No."));
                            IDYSTransportOrderPackage.Validate("Book. Prof. Package Type Code", TempTransportOrderPackage."Provider Package Type Code");
                        end;
                end;
                if IDYSTransportOrderPackage.Weight <> TempTransportOrderPackage.Weight then
                    IDYSTransportOrderPackage.Validate("Actual Weight", TempTransportOrderPackage.Weight);
                IDYSTransportOrderPackage.Validate(Height, TempTransportOrderPackage.Height);
                IDYSTransportOrderPackage.Validate(Width, TempTransportOrderPackage.Width);
                IDYSTransportOrderPackage.Validate(Length, TempTransportOrderPackage.Length);
                IDYSTransportOrderPackage.Validate("Load Meter", TempTransportOrderPackage."Load Meter");
                TotalLoadMeter += IDYSTransportOrderPackage."Load Meter";
                IDYSTransportOrderPackage.UpdateTotalVolume();
                IDYSTransportOrderPackage.UpdateTotalWeight();
                IDYSTransportOrderPackage.Validate("License Plate No.", TempTransportOrderPackage."License Plate No.");
                IDYSTransportOrderPackage.Modify(true);
            until TempTransportOrderPackage.Next() = 0;
            if TotalLoadMeter <> 0 then begin
                TransportOrderHeader.Validate("Load Meter", TotalLoadMeter);
                TransportOrderHeader.Modify();
            end;
        end;
    end;

    procedure CheckIfTransportOrderBelongsToWhseShipment(TransportOrderNumber: Code[20]; WhseShipmentNo: Code[20]) ProcessTransportOrder: Boolean
    var
#if BC17 or BC18 or BC19 or BC20 or BC21
        ItemLedgerEntry: Record "Item Ledger Entry";
#endif
        SalesShipmentLine: Record "Sales Shipment Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        ServiceShipmentLine: Record "Service Shipment Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        IDYSTransportOrderLine: Record "IDYS Transport Order Line";
        IsHandled: Boolean;
    begin
        OnBeforeCheckIfTransportOrderBelongsToWhseShipment(TransportOrderNumber, WhseShipmentNo, ProcessTransportOrder, IsHandled);
        if IsHandled then
            exit;

        PostedWhseShipmentLine.SetRange("Whse. Shipment No.", WhseShipmentNo);
        IDYSTransportOrderLine.SetRange("Transport Order No.", TransportOrderNumber);
        if not IDYSTransportOrderLine.FindFirst() then
            exit;
        case IDYSTransportOrderLine."Source Document Table No." of
            Database::"Sales Shipment Header":
                begin
                    SalesShipmentLine.Get(IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.");
                    PostedWhseShipmentLine.SetRange("Source Type", Database::"Sales Line");
                    PostedWhseShipmentLine.SetRange("Source Subtype", "Sales Document Type"::Order.AsInteger);
                    PostedWhseShipmentLine.SetRange("Source No.", SalesShipmentLine."Order No.");
                    PostedWhseShipmentLine.SetRange("Source Line No.", SalesShipmentLine."Order Line No.");
                end;
            Database::"Return Shipment Header":
                begin
                    ReturnShipmentLine.Get(IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.");
                    PostedWhseShipmentLine.SetRange("Source Type", Database::"Purchase Line");
                    PostedWhseShipmentLine.SetRange("Source Subtype", "Purchase Document Type"::"Return Order".AsInteger);
                    PostedWhseShipmentLine.SetRange("Source No.", ReturnShipmentLine."Return Order No.");
                    PostedWhseShipmentLine.SetRange("Source Line No.", ReturnShipmentLine."Return Order Line No.");
                end;
            Database::"Transfer Shipment Header":
                begin
                    TransferShipmentLine.Get(IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.");
                    PostedWhseShipmentLine.SetRange("Source Type", Database::"Transfer Line");
                    PostedWhseShipmentLine.SetRange("Source No.", TransferShipmentLine."Transfer Order No.");
#if BC17 or BC18 or BC19 or BC20 or BC21
                    ItemLedgerEntry.Get(TransferShipmentLine."Item Shpt. Entry No.");
                    PostedWhseShipmentLine.SetRange("Source Line No.", ItemLedgerEntry."Order Line No.");
#else
                    PostedWhseShipmentLine.SetRange("Source Line No.", TransferShipmentLine."Trans. Order Line No.");
#endif
                end;
            Database::"Service Shipment Header":
                begin
                    ServiceShipmentLine.Get(IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.");
                    PostedWhseShipmentLine.SetRange("Source Type", Database::"Service Line");
                    PostedWhseShipmentLine.SetRange("Source Subtype", "Service Document Type"::Order.AsInteger);
                    PostedWhseShipmentLine.SetRange("Source No.", ServiceShipmentLine."Order No.");
                    PostedWhseShipmentLine.SetRange("Source Line No.", ServiceShipmentLine."Order Line No.");
                end;
            else
                exit;
        end;
        exit(not PostedWhseShipmentLine.IsEmpty());
    end;

    procedure CreateTransportOrder(SourceDocumentRecordId: RecordId) LastCreatedTransportOrderNo: Code[20]
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        ServiceHeader: Record "Service Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        IDYSSetup: Record "IDYS Setup";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
    begin
        IDYSSetup.Get();
        case SourceDocumentRecordId.TableNo of
            Database::"Sales Header":
                begin
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Unposted documents");
                    SalesHeader.Get(SourceDocumentRecordId);
                    IDYSDocumentMgt.SalesHeader_CreateTransportOrder(SalesHeader);
                    if IDYSDocumentMgt.CheckConditions() then
                        LastCreatedTransportOrderNo := IDYSDocumentMgt.GetLastCreatedTransportOrderNo();
                end;
            Database::"Purchase Header":
                begin
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Unposted documents");
                    PurchaseHeader.Get(SourceDocumentRecordId);
                    PurchaseHeader.TestField("Document Type", PurchaseHeader."Document Type"::"Return Order");
                    IDYSDocumentMgt.PurchaseReturnHeader_CreateTransportOrder(PurchaseHeader);
                    if IDYSDocumentMgt.CheckConditions() then
                        LastCreatedTransportOrderNo := IDYSDocumentMgt.GetLastCreatedTransportOrderNo();
                end;
            Database::"Transfer Header":
                begin
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Unposted documents");
                    TransferHeader.Get(SourceDocumentRecordId);
                    IDYSDocumentMgt.TransferHeader_CreateTransportOrder(TransferHeader);
                    if IDYSDocumentMgt.CheckConditions() then
                        LastCreatedTransportOrderNo := IDYSDocumentMgt.GetLastCreatedTransportOrderNo();
                end;
            Database::"Service Header":
                begin
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Unposted documents");
                    ServiceHeader.Get(SourceDocumentRecordId);
                    IDYSDocumentMgt.ServiceHeader_CreateTransportOrder(ServiceHeader);
                    if IDYSDocumentMgt.CheckConditions() then
                        LastCreatedTransportOrderNo := IDYSDocumentMgt.GetLastCreatedTransportOrderNo();
                end;
            Database::"Warehouse Shipment Header":
                begin
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Unposted documents");
                    WarehouseShipmentHeader.Get(SourceDocumentRecordId);
                    IDYSDocumentMgt.WhseShipmtHdr_CreateTransportOrder(WarehouseShipmentHeader, true);
                    if IDYSDocumentMgt.CheckConditions() then
                        LastCreatedTransportOrderNo := IDYSDocumentMgt.GetLastCreatedTransportOrderNo();
                end;
            Database::"Sales Shipment Header":
                begin
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Posted documents");
                    SalesShipmentHeader.Get(SourceDocumentRecordId);
                    IDYSDocumentMgt.SalesShipment_CreateTransportOrder(SalesShipmentHeader, true);
                    if IDYSDocumentMgt.CheckConditions() then
                        LastCreatedTransportOrderNo := IDYSDocumentMgt.GetLastCreatedTransportOrderNo();
                end;
            Database::"Return Shipment Header":
                begin
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Posted documents");
                    ReturnShipmentHeader.Get(SourceDocumentRecordId);
                    IDYSDocumentMgt.ReturnShipment_CreateTransportOrder(ReturnShipmentHeader, true);
                    if IDYSDocumentMgt.CheckConditions() then
                        LastCreatedTransportOrderNo := IDYSDocumentMgt.GetLastCreatedTransportOrderNo();
                end;
            Database::"Transfer Shipment Header":
                begin
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Posted documents");
                    TransferShipmentHeader.Get(SourceDocumentRecordId);
                    IDYSDocumentMgt.TransferShipment_CreateTransportOrder(TransferShipmentHeader, true);
                    if IDYSDocumentMgt.CheckConditions() then
                        LastCreatedTransportOrderNo := IDYSDocumentMgt.GetLastCreatedTransportOrderNo();
                end;
            Database::"Transfer Receipt Header":
                begin
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Posted documents");
                    TransferReceiptHeader.Get(SourceDocumentRecordId);
                    IDYSDocumentMgt.TransferReceipt_CreateTransportOrder(TransferReceiptHeader, true);
                    if IDYSDocumentMgt.CheckConditions() then
                        LastCreatedTransportOrderNo := IDYSDocumentMgt.GetLastCreatedTransportOrderNo();
                end;
            Database::"Service Shipment Header":
                begin
                    IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Posted documents");
                    ServiceShipmentHeader.Get(SourceDocumentRecordId);
                    IDYSDocumentMgt.ServiceShipment_CreateTransportOrder(ServiceShipmentHeader, true);
                    if IDYSDocumentMgt.CheckConditions() then
                        LastCreatedTransportOrderNo := IDYSDocumentMgt.GetLastCreatedTransportOrderNo();
                end;
        end;
    end;

    procedure FindTransportOrderLineBySource(TransportOrderNumber: Code[20]; SourceTable: Integer; SourceNo: Code[20]; SourceLineNo: Integer; var OutputSourceRecordId: RecordId): Integer;
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        ServiceLine: Record "Service Line";
#if BC17 or BC18 or BC19 or BC20 or BC21
        ItemLedgerEntry: Record "Item Ledger Entry";
#endif
        SalesShipmentLine: Record "Sales Shipment Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        ServiceShipmentLine: Record "Service Shipment Line";
        IDYSSetup: Record "IDYS Setup";
        IDYSTransportOrderLine: Record "IDYS Transport Order Line";
    begin
        IDYSSetup.Get();
        IDYSTransportOrderLine.SetRange("Transport Order No.", TransportOrderNumber);
        case SourceTable of
            Database::"Sales Line":
                if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents" then begin
                    IDYSTransportOrderLine.SetRange("Source Document Table No.", Database::"Sales Header");
                    IDYSTransportOrderLine.SetRange("Source Document Type", "Sales Document Type"::Order.AsInteger);
                    IDYSTransportOrderLine.SetRange("Source Document No.", SourceNo);
                    IDYSTransportOrderLine.SetRange("Source Document Line No.", SourceLineNo);
                    if IDYSTransportOrderLine.FindFirst() then begin
                        SalesLine.Get(SalesLine."Document Type"::Order, SourceNo, SourceLineNo);
                        OutputSourceRecordId := SalesLine.RecordId();
                        exit(IDYSTransportOrderLine."Line No.");
                    end;
                end else begin
                    SalesShipmentLine.SetRange("Order No.", SourceNo);
                    SalesShipmentLine.SetRange("Order Line No.", SourceLineNo);
                    SalesShipmentLine.FindLast();
                    IDYSTransportOrderLine.SetRange("Source Document Table No.", Database::"Sales Shipment Header");
                    IDYSTransportOrderLine.SetRange("Source Document No.", SalesShipmentLine."Document No.");
                    IDYSTransportOrderLine.SetRange("Source Document Line No.", SalesShipmentLine."Line No.");
                    if IDYSTransportOrderLine.FindFirst() then begin
                        OutputSourceRecordId := SalesShipmentLine.RecordId();
                        exit(IDYSTransportOrderLine."Line No.");
                    end;
                end;
            Database::"Purchase Line":
                if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents" then begin
                    IDYSTransportOrderLine.SetRange("Source Document Table No.", Database::"Purchase Header");
                    IDYSTransportOrderLine.SetRange("Source Document Type", "Purchase Document Type"::"Return Order".AsInteger);
                    IDYSTransportOrderLine.SetRange("Source Document No.", SourceNo);
                    IDYSTransportOrderLine.SetRange("Source Document Line No.", SourceLineNo);
                    if IDYSTransportOrderLine.FindFirst() then begin
                        PurchaseLine.Get(PurchaseLine."Document Type"::"Return Order", SourceNo, SourceLineNo);
                        OutputSourceRecordId := PurchaseLine.RecordId();
                        exit(IDYSTransportOrderLine."Line No.");
                    end;
                end else begin
                    ReturnShipmentLine.SetRange("Return Order No.", SourceNo);
                    ReturnShipmentLine.SetRange("Return Order Line No.", SourceLineNo);
                    ReturnShipmentLine.FindLast();
                    IDYSTransportOrderLine.SetRange("Source Document Table No.", Database::"Return Shipment Header");
                    IDYSTransportOrderLine.SetRange("Source Document No.", ReturnShipmentLine."Document No.");
                    IDYSTransportOrderLine.SetRange("Source Document Line No.", ReturnShipmentLine."Line No.");
                    if IDYSTransportOrderLine.FindFirst() then begin
                        OutputSourceRecordId := ReturnShipmentLine.RecordId();
                        exit(IDYSTransportOrderLine."Line No.");
                    end;
                end;
            Database::"Transfer Line":
                if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents" then begin
                    IDYSTransportOrderLine.SetRange("Source Document Table No.", Database::"Transfer Header");
                    IDYSTransportOrderLine.SetRange("Source Document No.", SourceNo);
                    IDYSTransportOrderLine.SetRange("Source Document Line No.", SourceLineNo);
                    if IDYSTransportOrderLine.FindFirst() then begin
                        TransferLine.Get(SourceNo, SourceLineNo);
                        OutputSourceRecordId := TransferLine.RecordId();
                        exit(IDYSTransportOrderLine."Line No.");
                    end;
                end else begin
                    TransferShipmentLine.SetRange("Transfer Order No.", SourceNo);
#if BC17 or BC18 or BC19 or BC20 or BC21
                    ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.");
                    ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Transfer);
                    ItemLedgerEntry.SetRange("Order No.", SourceNo);
                    ItemLedgerEntry.SetRange("Order Line No.", SourceLineNo);
                    ItemLedgerEntry.FindLast();
                    TransferShipmentLine.SetRange("Item Shpt. Entry No.", ItemLedgerEntry."Entry No.");
#else                    
                    TransferShipmentLine.SetRange("Trans. Order Line No.", SourceLineNo);
#endif
                    TransferShipmentLine.FindLast();
                    IDYSTransportOrderLine.SetRange("Source Document Table No.", Database::"Transfer Shipment Header");
                    IDYSTransportOrderLine.SetRange("Source Document No.", TransferShipmentLine."Document No.");
                    IDYSTransportOrderLine.SetRange("Source Document Line No.", TransferShipmentLine."Line No.");
                    if IDYSTransportOrderLine.FindFirst() then begin
                        OutputSourceRecordId := TransferShipmentLine.RecordId();
                        exit(IDYSTransportOrderLine."Line No.");
                    end;
                end;
            Database::"Service Line":
                if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents" then begin
                    IDYSTransportOrderLine.SetRange("Source Document Table No.", Database::"Service Header");
                    IDYSTransportOrderLine.SetRange("Source Document Type", "Service Document Type"::Order.AsInteger);
                    IDYSTransportOrderLine.SetRange("Source Document No.", SourceNo);
                    IDYSTransportOrderLine.SetRange("Source Document Line No.", SourceLineNo);
                    if IDYSTransportOrderLine.FindFirst() then begin
                        ServiceLine.Get(ServiceLine."Document Type"::Order, SourceNo, SourceLineNo);
                        OutputSourceRecordId := ServiceLine.RecordId();
                        exit(IDYSTransportOrderLine."Line No.");
                    end;
                end else begin
                    ServiceShipmentLine.SetRange("Order No.", SourceNo);
                    ServiceShipmentLine.SetRange("Order Line No.", SourceLineNo);
                    ServiceShipmentLine.FindLast();
                    IDYSTransportOrderLine.SetRange("Source Document Table No.", Database::"Service Shipment Header");
                    IDYSTransportOrderLine.SetRange("Source Document No.", ServiceShipmentLine."Document No.");
                    IDYSTransportOrderLine.SetRange("Source Document Line No.", ServiceShipmentLine."Line No.");
                    if IDYSTransportOrderLine.FindFirst() then begin
                        OutputSourceRecordId := ServiceShipmentLine.RecordId();
                        exit(IDYSTransportOrderLine."Line No.");
                    end;
                end;
        end;
    end;

    procedure GetPackageTypes(var TempIDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type")
    var
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IDYSProvider: enum "IDYS Provider";
        ParameterNotTempErr: Label 'TempIDYSBookingProfPackageType parameter must be temporary';
    begin
        if not TempIDYSBookingProfPackageType.IsTemporary() then
            Error(ParameterNotTempErr);
        TempIDYSBookingProfPackageType.Reset();
        TempIDYSBookingProfPackageType.DeleteAll();

        // Identify Active ShipIT365 Providers
        IDYSProviderSetup.SetRange(Enabled, true);
        if IDYSProviderSetup.FindSet() then
            repeat
                case IDYSProviderSetup.Provider of
                    IDYSProvider::Default,
                    IDYSProvider::Transsmart,
                    IDYSProvider::Sendcloud,
                    IDYSProvider::Cargoson:
                        begin
                            IDYSProviderPackageType.Reset();
                            IDYSProviderPackageType.SetRange(Provider, IDYSProviderSetup.Provider);
                            if IDYSProviderPackageType.FindSet() then
                                repeat
                                    TempIDYSBookingProfPackageType.Init();
                                    ConvertProviderPackageTypeToBookingProfPackageType(TempIDYSBookingProfPackageType, IDYSProviderPackageType);
                                    TempIDYSBookingProfPackageType.Insert();
                                until IDYSProviderPackageType.Next() = 0;
                        end;
                    IDYSProvider::"Delivery Hub",
                    IDYSProvider::Easypost:
                        begin
                            IDYSBookingProfPackageType.Reset();
                            IDYSBookingProfPackageType.SetAutoCalcFields(Provider, "Carrier Name", "Booking Profile Description");
                            IDYSBookingProfPackageType.SetRange(Provider, IDYSProviderSetup.Provider);
                            if IDYSBookingProfPackageType.FindSet() then
                                repeat
                                    TempIDYSBookingProfPackageType.Init();
                                    TempIDYSBookingProfPackageType := IDYSBookingProfPackageType;
                                    TempIDYSBookingProfPackageType."API Provider" := TempIDYSBookingProfPackageType.Provider;
                                    TempIDYSBookingProfPackageType.Insert();
                                until IDYSBookingProfPackageType.Next() = 0;
                        end;
                end;
            until IDYSProviderSetup.Next() = 0;
    end;

    procedure PutTransportOrderPackage(var TransportOrderPackage: Record "IDYS Transport Order Package") NewLineNo: Integer
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        if not IDYSTransportOrderPackage.Get(TransportOrderPackage."Transport Order No.", TransportOrderPackage."Line No.") then begin
            IDYSTransportOrderPackage := TransportOrderPackage;
            IDYSTransportOrderPackage.Insert(true);
        end else begin
            IDYSTransportOrderPackage.TransferFields(TransportOrderPackage);
            IDYSTransportOrderPackage.Modify(true);
        end;
        TransportOrderPackage := IDYSTransportOrderPackage;
        exit(IDYSTransportOrderPackage."Line No.");
    end;

    procedure ReassignDelNoteLinesPerPackage(var TempPackageContentBuffer: Record "IDYS Package Content Buffer")
    var
        IDYSSetup: Record "IDYS Setup";
        TransportOrderPackage: Record "IDYS Transport Order Package";
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        xTONumber: Code[20];
        IsHandled: Boolean;
        NotLicensedErr: Label 'Linking Packages to delivery note lines is not licensed in this environment.';
    begin
        IDYSSetup.Get();
        if not IDYSSetup."Link Del. Lines with Packages" then
            Error(NotLicensedErr);
        OnBeforeReassignDelNoteLinesPerPackage(TempPackageContentBuffer, IsHandled);
        if IsHandled then
            exit;
        if TempPackageContentBuffer.FindSet() then
            repeat
                TempPackageContentBuffer.TestField("Transport Order No.");
#pragma warning disable AA0205
                if xTONumber <> TempPackageContentBuffer."Transport Order No." then begin
#pragma warning restore AA0205
                    if xTONumber <> '' then
                        IDYSTransportOrderMgt.SetShippingMethod(xTONumber);
                    TransportOrderDelNote.SetRange("Transport Order No.", TempPackageContentBuffer."Transport Order No.");
                    if not TransportOrderDelNote.IsEmpty() then
                        TransportOrderDelNote.DeleteAll();
                    xTONumber := TempPackageContentBuffer."Transport Order No.";
                end;
                TransportOrderPackage.Get(TempPackageContentBuffer."Transport Order No.", TempPackageContentBuffer."Package Line No.");
                AddTransportOrderPackageContent(TransportOrderPackage, TempPackageContentBuffer."Transport Order Line No.", TempPackageContentBuffer."Source RecordId", TempPackageContentBuffer."Qty. (Base)", TempPackageContentBuffer."Net Weight", TempPackageContentBuffer."Gross Weight");
            until TempPackageContentBuffer.Next() = 0;
        if xTONumber <> '' then
            IDYSTransportOrderMgt.SetShippingMethod(xTONumber);
    end;

    local procedure ConvertProviderPackageTypeToBookingProfPackageType(var TempIDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type"; IDYSProviderPackageType: Record "IDYS Provider Package Type")
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        TempIDYSBookingProfPackageType."Carrier Entry No." := IDYSProviderPackageType.Provider.AsInteger() * -1;
        TempIDYSBookingProfPackageType."Booking Profile Entry No." := 0;
        TempIDYSBookingProfPackageType."API Provider" := IDYSProviderPackageType.Provider;
        TempIDYSBookingProfPackageType."Package Type Code" := IDYSProviderPackageType.Code;
        TempIDYSBookingProfPackageType.Description := IDYSProviderPackageType.Description;
        TempIDYSBookingProfPackageType.Length := IDYSProviderPackageType.Length;
        TempIDYSBookingProfPackageType.Width := IDYSProviderPackageType.Width;
        TempIDYSBookingProfPackageType.Height := IDYSProviderPackageType.Height;
        TempIDYSBookingProfPackageType."Linear UOM" := IDYSProviderPackageType."Linear UOM";
        TempIDYSBookingProfPackageType."Mass UOM" := IDYSProviderPackageType."Mass UOM";
        TempIDYSBookingProfPackageType."Special Equipment Code" := IDYSProviderPackageType."Special Equipment Code";
        IDYSSetup.GetProviderSetup(IDYSProviderPackageType.Provider);
        TempIDYSBookingProfPackageType.Default := IDYSSetup."Default Provider Package Type" = IDYSProviderPackageType.Code;
        TempIDYSBookingProfPackageType.Weight := IDYSProviderPackageType.Weight;
    end;

    local procedure FindTransportOrderLineBySource(SourceLineRecordId: RecordId; TransportOrderNumber: Code[20]): Integer
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        ServiceLine: Record "Service Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        ServiceShipmentLine: Record "Service Shipment Line";
        TransportOrderLine: Record "IDYS Transport Order Line";
    begin
        case SourceLineRecordId.TableNo of
            Database::"Sales Line":
                begin
                    SalesLine.Get(SourceLineRecordId);
                    TransportOrderLine.SetRange("Transport Order No.", TransportOrderNumber);
                    TransportOrderLine.SetRange("Source Document Table No.", Database::"Sales Header");
                    TransportOrderLine.SetRange("Source Document Type", SalesLine."Document Type");
                    TransportOrderLine.SetRange("Source Document No.", SalesLine."Document No.");
                    TransportOrderLine.SetRange("Source Document Line No.", SalesLine."Line No.");
                end;
            Database::"Purchase Line":
                begin
                    PurchaseLine.Get(SourceLineRecordId);
                    TransportOrderLine.SetRange("Transport Order No.", TransportOrderNumber);
                    TransportOrderLine.SetRange("Source Document Table No.", Database::"Purchase Header");
                    TransportOrderLine.SetRange("Source Document Type", PurchaseLine."Document Type");
                    TransportOrderLine.SetRange("Source Document No.", PurchaseLine."Document No.");
                    TransportOrderLine.SetRange("Source Document Line No.", PurchaseLine."Line No.");
                end;
            Database::"Transfer Line":
                begin
                    TransferLine.Get(SourceLineRecordId);
                    TransportOrderLine.SetRange("Transport Order No.", TransportOrderNumber);
                    TransportOrderLine.SetRange("Source Document Table No.", Database::"Transfer Header");
                    TransportOrderLine.SetRange("Source Document No.", TransferLine."Document No.");
                    TransportOrderLine.SetRange("Source Document Line No.", TransferLine."Line No.");
                end;
            Database::"Service Line":
                begin
                    ServiceLine.Get(SourceLineRecordId);
                    TransportOrderLine.SetRange("Transport Order No.", TransportOrderNumber);
                    TransportOrderLine.SetRange("Source Document Table No.", Database::"Service Header");
                    TransportOrderLine.SetRange("Source Document Type", ServiceLine."Document Type");
                    TransportOrderLine.SetRange("Source Document No.", ServiceLine."Document No.");
                    TransportOrderLine.SetRange("Source Document Line No.", ServiceLine."Line No.");
                end;
            Database::"Sales Shipment Line":
                begin
                    SalesShipmentLine.Get(SourceLineRecordId);
                    TransportOrderLine.SetRange("Transport Order No.", TransportOrderNumber);
                    TransportOrderLine.SetRange("Source Document Table No.", Database::"Sales Shipment Header");
                    TransportOrderLine.SetRange("Source Document No.", SalesShipmentLine."Document No.");
                    TransportOrderLine.SetRange("Source Document Line No.", SalesShipmentLine."Line No.");
                end;
            Database::"Return Shipment Line":
                begin
                    ReturnShipmentLine.Get(SourceLineRecordId);
                    TransportOrderLine.SetRange("Transport Order No.", TransportOrderNumber);
                    TransportOrderLine.SetRange("Source Document Table No.", Database::"Return Shipment Header");
                    TransportOrderLine.SetRange("Source Document No.", ReturnShipmentLine."Document No.");
                    TransportOrderLine.SetRange("Source Document Line No.", ReturnShipmentLine."Line No.");
                end;
            Database::"Transfer Shipment Line":
                begin
                    TransferShipmentLine.Get(SourceLineRecordId);
                    TransportOrderLine.SetRange("Transport Order No.", TransportOrderNumber);
                    TransportOrderLine.SetRange("Source Document Table No.", Database::"Transfer Shipment Header");
                    TransportOrderLine.SetRange("Source Document No.", TransferShipmentLine."Document No.");
                    TransportOrderLine.SetRange("Source Document Line No.", TransferShipmentLine."Line No.");
                end;
            Database::"Service Shipment Line":
                begin
                    ServiceShipmentLine.Get(SourceLineRecordId);
                    TransportOrderLine.SetRange("Transport Order No.", TransportOrderNumber);
                    TransportOrderLine.SetRange("Source Document Table No.", Database::"Service Shipment Header");
                    TransportOrderLine.SetRange("Source Document No.", ServiceShipmentLine."Document No.");
                    TransportOrderLine.SetRange("Source Document Line No.", ServiceShipmentLine."Line No.");
                end;
        end;
        TransportOrderLine.FindFirst();
        exit(TransportOrderLine."Line No.");
    end;

    procedure SetTransportOrderNo(NewTransportOrderNo: Code[20])
    begin
        TransportOrderNo := NewTransportOrderNo;
    end;

    procedure SetPostponeTotals(NewSkipUpdateTotals: Boolean)
    begin
        SkipUpdateTotals := NewSkipUpdateTotals;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckIfTransportOrderBelongsToWhseShipment(TransportOrderNumber: Code[20]; WhseShipmentNo: Code[20]; var ProcessTransportOrder: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddTransportOrderPackages(var TempTransportOrderPackage: Record "IDYS Transport Order Package"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReassignDelNoteLinesPerPackage(var TempPackageContentBuffer: Record "IDYS Package Content Buffer"; var IsHandled: Boolean)
    begin
    end;

    var
        TransportOrderNo: Code[20];
        SkipUpdateTotals: Boolean;
}