codeunit 11147649 "IDYS Document Mgt."
{
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        CreateWorksheetLine: Codeunit "IDYS Create Worksheet Line";
        WhseShipmentNo: Code[20];
        OverShipQtyErr: Label 'An attempt was made to add more quantities to the transport order (%1) than the total quantity that was shipped (%2).', Comment = '%1 = Qty. to Send + Qty. Send, %2 = Quantity';
        ExceedQtyErr: Label '(%1) cannot exceed Quantity (%2) minus %3 (%4)', Comment = '%1 = Qty. to Send, %2 = Quantity, %3 = ShipIt Quantiy to send, %4 = Caption Quantity to send.';
        LineNoMsg: Label '%1=%2. %3', Comment = '%1 = Line No. field caption. %2 = Line No. field value. %3 = Error Message', Locked = true;

    procedure SalesOrder_CarrierSelect(var SalesHeader: Record "Sales Header")
    var
        TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header" temporary;
        TempIDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary;
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
        IDYSPublisher: Codeunit "IDYS Publisher";
        Documents: JsonArray;
    begin
        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(SalesHeader."Shipment Method Code", true) then
            exit;

        IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        IDYSSourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        IDYSSourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
        if IDYSSourceDocumentPackage.IsEmpty then
            Error(MissingPackagesErr);

        if SalesHeader."Completely Shipped" then begin
            Page.RunModal(Page::"IDYS Provider Carrier Select", TempIDYSProviderCarrierSelect);
            exit;
        end;

        SalesHeader.Testfield("IDYS Provider");
        IDYSIProvider := SalesHeader."IDYS Provider";
        IDYSIProvider.IsEnabled(true);

        Documents := IDYSIProvider.InitSelectCarrier(TempIDYSTransportOrderHeader, SalesHeader, TempIDYSProviderCarrierSelect);
        IDYSIProvider.SelectCarrier(TempIDYSTransportOrderHeader, TempIDYSProviderCarrierSelect, Documents);

        Commit();
        TempIDYSProviderCarrierSelect.SetRange(Provider, SalesHeader."IDYS Provider");
        if Page.RunModal(Page::"IDYS Provider Carrier Select", TempIDYSProviderCarrierSelect) = ACTION::LookupOK then begin
            IDYSPublisher.OnAfterProviderCarrierSelectLookup_SalesHeader(SalesHeader, TempIDYSProviderCarrierSelect);

            if SalesHeader."IDYS Provider" in [SalesHeader."IDYS Provider"::Sendcloud, SalesHeader."IDYS Provider"::EasyPost] then begin
                TempIDYSProviderCarrierSelect.CalcFields("Calculated Price");
                SalesHeader."IDYS Freight Amount" := TempIDYSProviderCarrierSelect."Calculated Price";
            end else
                SalesHeader."IDYS Freight Amount" := TempIDYSProviderCarrierSelect."Price as Decimal";
            SalesHeader.Modify();
            SalesHeader.CalcInvDiscForHeader();
        end;
    end;

    procedure SalesHeader_CreateTransportOrder(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        NothingToCreateMsg: Label 'The sales document does not contain any lines with %1 greater than 0.', Comment = '%1 = Quantity to send caption.';
        Cntr: Integer;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
        HasError: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeSalesHeader_CreateTransportOrder(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(SalesHeader."Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        // Update Header
        if UpdateServiceLevel(SalesHeader."Shipping Agent Code", SalesHeader."Shipping Agent Service Code", (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order")) then
            SalesHeader.Modify();
        SalesHeader.CalcInvDiscForHeader();

        if IDYSProviderMgt.CheckShipmentMethodCode(SalesHeader."IDYS Provider") then
            SalesHeader.TestField("Shipment Method Code");
        SalesHeader.TestField("Shipping Agent Code");
        SalesHeader.TestField("Shipping Agent Service Code");
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) then
            SalesHeader.FieldError("Document Type");
        Cntr := 0;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("IDYS Quantity To Send", '<>%1', 0);
        if SalesLine.FindSet() then begin
            repeat
                HasError := false;
                case SalesLine."Document Type" of
                    SalesLine."Document Type"::Order:
                        HasError := not CreateWorksheetLine.FromSalesOrderLine(SalesLine, TempTransportWorksheetLineBuffer);
                    SalesLine."Document Type"::"Return Order":
                        HasError := not CreateWorksheetLine.FromSalesReturnOrderLine(SalesLine, TempTransportWorksheetLineBuffer);
                end;

                if HasError then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] := StrSubstNo(LineNoMsg, SalesLine.FieldCaption("Line No."), SalesLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until SalesLine.Next() = 0;
            CreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, false);
        end else
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NothingToCreateTok, StrSubstNo(NothingToCreateMsg, SalesLine.FieldCaption("IDYS Quantity To Send")));

        OnAfterSalesHeader_CreateTransportOrder(SalesHeader);
    end;

    procedure SalesHeader_CreateTempTransportOrder(SalesHeader: Record "Sales Header"; var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        SalesLine: Record "Sales Line";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        CreateTptOrdWrksh: Codeunit "IDYS Create Tpt. Ord. (Wrksh.)";
        NothingToCreateMsg: Label 'The sales document does not contain any lines with %1 greater than 0.', Comment = '%1 = Quantity to send caption.';
        Cntr: Integer;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
        HasError: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeSalesHeader_CreateTempTransportOrder(SalesHeader, TempIDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(SalesHeader."Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        if IDYSProviderMgt.CheckShipmentMethodCode(SalesHeader."IDYS Provider") then
            SalesHeader.TestField("Shipment Method Code");
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Quote, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) then
            SalesHeader.FieldError("Document Type");
        Cntr := 0;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        //SalesLine.SetFilter("IDYS Quantity To Send", '<>%1', 0);
        if SalesLine.FindSet() then begin
            repeat
                CreateWorksheetLine.SkipCheckSvcLevel(true);
                HasError := false;
                case SalesLine."Document Type" of
                    SalesLine."Document Type"::Quote,  //NOTE: Only temporary TO is available for quote type
                    SalesLine."Document Type"::Order:
                        HasError := not CreateWorksheetLine.FromSalesOrderLine(SalesLine, TempTransportWorksheetLineBuffer);
                    SalesLine."Document Type"::"Return Order":
                        HasError := not CreateWorksheetLine.FromSalesReturnOrderLine(SalesLine, TempTransportWorksheetLineBuffer);
                end;

                if HasError then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] := StrSubstNo(LineNoMsg, SalesLine.FieldCaption("Line No."), SalesLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until SalesLine.Next() = 0;
            CreateTptOrdWrksh.CreateTempTransOrderHeader(TempTransportWorksheetLineBuffer, TempIDYSTransportOrderHeader);
        end else
            if GuiAllowed() then begin
                IDYSNotificationManagement.SendNotification(NothingToCreateTok, StrSubstNo(NothingToCreateMsg, SalesLine.FieldCaption("IDYS Quantity To Send")));
                Error('');
            end;

        OnAfterSalesHeader_CreateTempTransportOrder(SalesHeader, TempIDYSTransportOrderHeader);
    end;

    procedure PurchaseHeader_CreateTransportOrder(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        NothingToCreateMsg: Label 'The purchase document does not contain any lines with %1 greater than 0.', Comment = '%1 = Quantity to send caption.';
        Cntr: Integer;
        IsHandled: Boolean;
        HasError: Boolean;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
    begin
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Order:
                OnBeforePurchaseHeader_CreateTransportOrder(PurchaseHeader, IsHandled);
            PurchaseHeader."Document Type"::"Return Order":
                OnBeforePurchaseReturnHeader_CreateTransportOrder(PurchaseHeader, IsHandled);
        end;
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(PurchaseHeader."Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        // Update Header
        if UpdateServiceLevel(PurchaseHeader."IDYS Shipping Agent Code", PurchaseHeader."IDYS Shipping Agent Srv Code", (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order")) then
            PurchaseHeader.Modify();
        PurchaseHeader.TestField("IDYS Shipping Agent Code");
        PurchaseHeader.TestField("IDYS Shipping Agent Srv Code");
        if not (PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::"Return Order"]) then
            PurchaseHeader.FieldError("Document Type");

        Cntr := 0;

        CheckShippingSrvShippingTime(PurchaseHeader."IDYS Shipping Agent Code", PurchaseHeader."IDYS Shipping Agent Srv Code");

        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetFilter("IDYS Quantity to Send", '<>%1', 0);
        if PurchaseLine.FindSet() then begin
            repeat
                HasError := false;
                case PurchaseLine."Document Type" of
                    PurchaseLine."Document Type"::Order:
                        HasError := not CreateWorksheetLine.FromPurchaseOrderLine(
                            PurchaseLine,
                            PurchaseHeader."IDYS Shipping Agent Code",
                            PurchaseHeader."IDYS Shipping Agent Srv Code",
                            TempTransportWorksheetLineBuffer);
                    PurchaseLine."Document Type"::"Return Order":
                        HasError := not CreateWorksheetLine.FromPurchaseReturnOrderLine(
                    PurchaseLine,
                    PurchaseHeader."IDYS Shipping Agent Code",
                    PurchaseHeader."IDYS Shipping Agent Srv Code",
                    TempTransportWorksheetLineBuffer);
                end;

                if HasError then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] := StrSubstNo(LineNoMsg, PurchaseLine.FieldCaption("Line No."), PurchaseLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until PurchaseLine.Next() = 0;
            CreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, false);
        end else
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NothingToCreateTok, StrSubstNo(NothingToCreateMsg, PurchaseLine.FieldCaption("IDYS Quantity To Send")));
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Order:
                OnAfterPurchaseHeader_CreateTransportOrder(PurchaseHeader);
            PurchaseHeader."Document Type"::"Return Order":
                OnAfterPurchaseReturnHeader_CreateTransportOrder(PurchaseHeader);
        end;
    end;

    procedure PurchaseReturnHeader_CreateTransportOrder(PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader_CreateTransportOrder(PurchaseHeader);
    end;

    procedure ServiceHeader_CreateTransportOrder(ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        NothingToCreateMsg: Label 'The service document does not contain any lines with %1 greater than 0.', Comment = '%1 = Quantity to send caption.';
        Cntr: Integer;
        IsHandled: Boolean;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
    begin
        OnBeforeServiceHeader_CreateTransportOrder(ServiceHeader, IsHandled);
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(ServiceHeader."Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        if UpdateServiceLevel(ServiceHeader."Shipping Agent Code", ServiceHeader."Shipping Agent Service Code", false) then
            ServiceHeader.Modify();
        ServiceHeader.TestField("Shipping Agent Code");
        ServiceHeader.TestField("Shipping Agent Service Code");
        ServiceHeader.TestField("IDYS Requested Delivery Date");

        Cntr := 0;

        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetRange("Document Type", ServiceLine."Document Type"::"Order");
        ServiceLine.SetFilter("IDYS Quantity to Send", '<>%1', 0);
        if ServiceLine.FindSet() then begin
            repeat
                if not CreateWorksheetLine.FromServiceOrderLine(ServiceLine, ServiceHeader."IDYS Requested Delivery Date", TempTransportWorksheetLineBuffer) then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] := StrSubstNo(LineNoMsg, ServiceLine.FieldCaption("Line No."), ServiceLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until ServiceLine.Next() = 0;

            CreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, false);
        end else
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NothingToCreateTok, StrSubstNo(NothingToCreateMsg, ServiceLine.FieldCaption("IDYS Quantity To Send")));

        OnAfterServiceHeader_CreateTransportOrder(ServiceHeader);
    end;

    procedure TransferHeader_CreateTransportOrder(TransferHeader: Record "Transfer Header")
    var
        TransferLine: Record "Transfer Line";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        NothingToCreateMsg: Label 'The transfer document does not contain any lines with %1 greater than 0.', Comment = '%1 = Quantity to send caption.';
        Cntr: Integer;
        IsHandled: Boolean;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
    begin
        OnBeforeTransferHeader_CreateTransportOrder(TransferHeader, IsHandled);
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(TransferHeader."Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        if UpdateServiceLevel(TransferHeader."Shipping Agent Code", TransferHeader."Shipping Agent Service Code", false) then
            TransferHeader.Modify();
        TransferHeader.TestField("Shipping Agent Code");
        TransferHeader.TestField("Shipping Agent Service Code");

        if IDYSProviderMgt.CheckShipmentMethodCode(TransferHeader."IDYS Provider") then
            TransferHeader.TestField("Shipment Method Code");

        Cntr := 0;

        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.SetRange("Derived From Line No.", 0);
        TransferLine.SetFilter("IDYS Quantity to Send", '<>%1', 0);
        if TransferLine.FindSet() then begin
            repeat
                if not CreateWorksheetLine.FromTransferOrderLine(TransferLine, TempTransportWorksheetLineBuffer) then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] := StrSubstNo(LineNoMsg, TransferLine.FieldCaption("Line No."), TransferLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until TransferLine.Next() = 0;

            CreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, false);
        end else
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NothingToCreateTok, StrSubstNo(NothingToCreateMsg, TransferLine.FieldCaption("IDYS Quantity To Send")));

        OnAfterTransferHeader_CreateTransportOrder(TransferHeader);
    end;

    procedure WhseShipmtHdr_CreateTransportOrder(WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        WhseShipmtHdr_CreateTransportOrder(WarehouseShipmentHeader, false);
    end;

    procedure WhseShipmtHdr_CreateTransportOrder(WarehouseShipmentHeader: Record "Warehouse Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        NothingToCreateMsg: Label 'The warehouse shipment does not contain any lines with %1 greater than 0.', Comment = '%1 = Quantity to send caption.';
        Cntr: Integer;
        IsHandled: Boolean;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
    begin
        OnBeforeWhseShipmtHdr_CreateTransportOrder(WarehouseShipmentHeader, IsHandled, WithDelayedOpenTransportOrder);
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(WarehouseShipmentHeader."Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        if UpdateServiceLevel(WarehouseShipmentHeader."Shipping Agent Code", WarehouseShipmentHeader."Shipping Agent Service Code", false) then
            WarehouseShipmentHeader.Modify();
        WarehouseShipmentHeader.TestField("Shipping Agent Code");
        WarehouseShipmentHeader.TestField("Shipping Agent Service Code");

        if not IDYSShipAgentMapping.Get(WarehouseShipmentHeader."Shipping Agent Code") then
            IDYSShipAgentMapping.Init();
        if IDYSProviderMgt.CheckShipmentMethodCode(IDYSShipAgentMapping.Provider) then
            WarehouseShipmentHeader.TestField("Shipment Method Code");

        Cntr := 0;

        WarehouseShipmentLine.SetRange("No.", WarehouseShipmentHeader."No.");
        WarehouseShipmentLine.SetFilter("Source Document", '%1|%2|%3|%4',
            WarehouseShipmentLine."Source Document"::"Sales Order",
            WarehouseShipmentLine."Source Document"::"Purchase Return Order",
            WarehouseShipmentLine."Source Document"::"Service Order",
            WarehouseShipmentLine."Source Document"::"Outbound Transfer");
        WarehouseShipmentLine.SetFilter("IDYS Quantity to Send", '<>%1', 0);
        if WarehouseShipmentLine.FindSet() then begin
            repeat
                if not CreateWorksheetLine.FromWarehouseShipmentLine(WarehouseShipmentLine, TempTransportWorksheetLineBuffer) then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] :=
                            StrSubstNo(
                                LineNoMsg, WarehouseShipmentLine.FieldCaption("Line No."), WarehouseShipmentLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until WarehouseShipmentLine.Next() = 0;
            WhseShipmentNo := WarehouseShipmentHeader."No.";
            CreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, WithDelayedOpenTransportOrder);
        end else
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NothingToCreateTok, StrSubstNo(NothingToCreateMsg, WarehouseShipmentLine.FieldCaption("IDYS Quantity To Send")));

        OnAfterWhseShipmtHdr_CreateTransportOrder(WarehouseShipmentHeader, WithDelayedOpenTransportOrder);
    end;

    procedure SalesShipment_CreateTransportOrder(SalesShipmentHeader: Record "Sales Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        Cntr: Integer;
        IsHandled: Boolean;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
    begin
        OnBeforeSalesShipment_CreateTransportOrder(SalesShipmentHeader, WithDelayedOpenTransportOrder, IsHandled);
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(SalesShipmentHeader."Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        if UpdateServiceLevel(SalesShipmentHeader."Shipping Agent Code", SalesShipmentHeader."Shipping Agent Service Code", false) then
            SalesShipmentHeader.Modify();
        SalesShipmentHeader.TestField("Shipping Agent Code");
        SalesShipmentHeader.TestField("Shipping Agent Service Code");

        SalesShipmentHeader.CalcFields("IDYS Provider");
        if IDYSProviderMgt.CheckShipmentMethodCode(SalesShipmentHeader."IDYS Provider") then
            SalesShipmentHeader.TestField("Shipment Method Code");

        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SetFilter("IDYS Quantity to Send", '<>%1', 0);
        if SalesShipmentLine.FindSet() then begin
            repeat
                if not CreateWorksheetLine.FromPostedSalesShipmentLine(SalesShipmentLine, TempTransportWorksheetLineBuffer) then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] :=
                            StrSubstNo(
                                LineNoMsg, SalesShipmentLine.FieldCaption("Line No."), SalesShipmentLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until SalesShipmentLine.Next() = 0;
            CreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, WithDelayedOpenTransportOrder);
        end;

        OnAfterSalesShipment_CreateTransportOrder(SalesShipmentHeader, WithDelayedOpenTransportOrder);
    end;

    procedure ReturnShipment_CreateTransportOrder(ReturnShipmentHeader: Record "Return Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    var
        ReturnShipmentLine: Record "Return Shipment Line";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        Cntr: Integer;
        IsHandled: Boolean;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
    begin
        OnBeforeReturnShipment_CreateTransportOrder(ReturnShipmentHeader, IsHandled, WithDelayedOpenTransportOrder);
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(ReturnShipmentHeader."Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        if UpdateServiceLevel(ReturnShipmentHeader."IDYS Shipping Agent Code", ReturnShipmentHeader."IDYS Shipping Agent Srv Code", false) then
            ReturnShipmentHeader.Modify();
        ReturnShipmentHeader.TestField("IDYS Shipping Agent Code");
        ReturnShipmentHeader.TestField("IDYS Shipping Agent Srv Code");

        CheckShippingSrvShippingTime(ReturnShipmentHeader."IDYS Shipping Agent Code", ReturnShipmentHeader."IDYS Shipping Agent Srv Code");

        ReturnShipmentLine.SetRange("Document No.", ReturnShipmentHeader."No.");
        ReturnShipmentLine.SetFilter("IDYS Quantity to Send", '<>%1', 0);
        if ReturnShipmentLine.FindSet() then begin
            repeat
                if not CreateWorksheetLine.FromReturnShipmentLine(ReturnShipmentLine,
                    ReturnShipmentHeader."IDYS Shipping Agent Code",
                    ReturnShipmentHeader."IDYS Shipping Agent Srv Code",
                    TempTransportWorksheetLineBuffer)
                then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] :=
                            StrSubstNo(
                                LineNoMsg, ReturnShipmentLine.FieldCaption("Line No."), ReturnShipmentLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until ReturnShipmentLine.Next() = 0;
            CreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, WithDelayedOpenTransportOrder);
        end;

        OnAfterReturnShipment_CreateTransportOrder(ReturnShipmentHeader, WithDelayedOpenTransportOrder);
    end;

    procedure ServiceShipment_CreateTransportOrder(ServiceShipmentHeader: Record "Service Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    var
        ServiceShipmentLine: Record "Service Shipment Line";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        Cntr: Integer;
        IsHandled: Boolean;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
    begin
        OnBeforeServiceShipment_CreateTransportOrder(ServiceShipmentHeader, IsHandled, WithDelayedOpenTransportOrder);
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(ServiceShipmentHeader."IDYS Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        if UpdateServiceLevel(ServiceShipmentHeader."IDYS Shipping Agent Code", ServiceShipmentHeader."IDYS Shipping Agent Srv Code", false) then
            ServiceShipmentHeader.Modify();
        ServiceShipmentHeader.TestField("IDYS Shipping Agent Code");
        ServiceShipmentHeader.TestField("IDYS Shipping Agent Srv Code");

        ServiceShipmentHeader.CalcFields("IDYS Provider");
        if IDYSProviderMgt.CheckShipmentMethodCode(ServiceShipmentHeader."IDYS Provider") then
            ServiceShipmentHeader.TestField("IDYS Shipment Method Code");

        CheckShippingSrvShippingTime(ServiceShipmentHeader."IDYS Shipping Agent Code", ServiceShipmentHeader."IDYS Shipping Agent Srv Code");

        ServiceShipmentLine.SetRange("Document No.", ServiceShipmentHeader."No.");
        ServiceShipmentLine.SetFilter("IDYS Quantity to Send", '<>%1', 0);
        if ServiceShipmentLine.FindSet() then begin
            repeat
                if not CreateWorksheetLine.FromServiceShipmentLine(ServiceShipmentLine,
                    ServiceShipmentHeader."IDYS Shipment Method Code",
                    ServiceShipmentHeader."IDYS Shipping Agent Code",
                    ServiceShipmentHeader."IDYS Shipping Agent Srv Code",
                    ServiceShipmentHeader."IDYS Requested Delivery Date",
                    TempTransportWorksheetLineBuffer)
                then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] :=
                            StrSubstNo(
                                LineNoMsg, ServiceShipmentLine.FieldCaption("Line No."), ServiceShipmentLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until ServiceShipmentLine.Next() = 0;
            CreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, WithDelayedOpenTransportOrder);
        end;

        OnAfterServiceShipment_CreateTransportOrder(ServiceShipmentHeader, WithDelayedOpenTransportOrder);
    end;

    procedure TransferShipment_CreateTransportOrder(TransferShipmentHeader: Record "Transfer Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        Cntr: Integer;
        IsHandled: Boolean;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
    begin
        OnBeforeTransferShipment_CreateTransportOrder(TransferShipmentHeader, IsHandled, WithDelayedOpenTransportOrder);
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(TransferShipmentHeader."Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        if UpdateServiceLevel(TransferShipmentHeader."Shipping Agent Code", TransferShipmentHeader."Shipping Agent Service Code", false) then
            TransferShipmentHeader.Modify();
        TransferShipmentHeader.TestField("Shipping Agent Code");
        TransferShipmentHeader.TestField("Shipping Agent Service Code");
        TransferShipmentLine.SetRange("Document No.", TransferShipmentHeader."No.");
        TransferShipmentLine.SetFilter("IDYS Quantity to Send", '<>%1', 0);
        if TransferShipmentLine.FindSet() then begin
            repeat
                if not CreateWorksheetLine.FromTransferShipmentLine(TransferShipmentLine, TempTransportWorksheetLineBuffer) then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] :=
                            StrSubstNo(
                                LineNoMsg, TransferShipmentLine.FieldCaption("Line No."), TransferShipmentLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until TransferShipmentLine.Next() = 0;
            CreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, WithDelayedOpenTransportOrder);
        end;

        OnAfterTransferShipment_CreateTransportOrder(TransferShipmentHeader, WithDelayedOpenTransportOrder);
    end;

    procedure TransferReceipt_CreateTransportOrder(TransferReceiptHeader: Record "Transfer Receipt Header"; WithDelayedOpenTransportOrder: Boolean)
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
        TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary;
        Cntr: Integer;
        IsHandled: Boolean;
        ErrorMessageArr: array[10] of Text; // 10 notifications should be enough
    begin
        OnBeforeTransferReceipt_CreateTransportOrder(TransferReceiptHeader, IsHandled, WithDelayedOpenTransportOrder);
        if IsHandled then
            exit;

        if IDYSProviderMgt.IsSkipRequiredOnShipmentMethod(TransferReceiptHeader."Shipment Method Code", true) then begin
            SkipCreate := true;
            exit;
        end;

        if UpdateServiceLevel(TransferReceiptHeader."Shipping Agent Code", TransferReceiptHeader."Shipping Agent Service Code", false) then
            TransferReceiptHeader.Modify();
        TransferReceiptHeader.TestField("Shipping Agent Code");
        TransferReceiptHeader.TestField("Shipping Agent Service Code");
        TransferReceiptLine.SetRange("Document No.", TransferReceiptHeader."No.");
        TransferReceiptLine.SetFilter("IDYS Quantity to Send", '<>%1', 0);
        if TransferReceiptLine.FindSet() then begin
            repeat
                if not CreateWorksheetLine.FromTransferReceiptLine(TransferReceiptLine, TempTransportWorksheetLineBuffer) then begin
                    Cntr += 1;
                    if Cntr <= 10 then
                        ErrorMessageArr[Cntr] :=
                            StrSubstNo(
                                LineNoMsg, TransferReceiptLine.FieldCaption("Line No."), TransferReceiptLine."Line No.", CreateWorksheetLine.GetErrorMessage());
                end;
            until TransferReceiptLine.Next() = 0;
            CreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, WithDelayedOpenTransportOrder);
        end;

        OnAfterTransferReceipt_CreateTransportOrder(TransferReceiptHeader, WithDelayedOpenTransportOrder);
    end;

    procedure SetSalesLineQtyToSend(var SalesLine: Record "Sales Line"; QtyToSend: Decimal)
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        if SalesLine."Type" <> SalesLine."Type"::Item then
            exit;

        SalesLine.CalcFields("IDYS Quantity Sent");
        Item.Get(SalesLine."No.");

        IDYSSetup.Get();
        if not IDYSSetup."Allow All Item Types" then
            if Item."Type" <> Item."Type"::Inventory then
                exit;

        OnBeforeSalesLineCheckQtyToSend(SalesLine, QtyToSend, IsHandled);
        if not IsHandled then
            if CheckQtyToSend(SalesLine."Quantity (Base)", QtyToSend, SalesLine."IDYS Quantity Sent") then
                SalesLine.Validate("IDYS Quantity To Send", QtyToSend)
            else
                if QtyToSend < 0 then
                    SalesLine.FieldError("IDYS Quantity To Send", StrSubstNo(OverShipQtyErr, SalesLine."IDYS Quantity Sent", SalesLine."Qty. Shipped (Base)" + SalesLine."Qty. to Ship (Base)"))
                else
                    SalesLine.FieldError("IDYS Quantity To Send", StrSubstNo(ExceedQtyErr, QtyToSend, SalesLine."Quantity (Base)", SalesLine."IDYS Quantity Sent", SalesLine.FieldCaption("IDYS Quantity Sent")));
    end;

    [Obsolete('Replaced by method without QtyToSend paramater', '18.5')]
    procedure SetWarehouseShipmentLineQtyToSend(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; QtyToSend: Decimal)
    begin
        SetWarehouseShipmentLineQtyToSend(WarehouseShipmentLine);
    end;

    procedure CalcWarehouseShipmentLineQtyToSend(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var OutputSourceDocQtyToSend: Decimal): Decimal
    var
        Item: Record Item;
    begin
        IDYSSetup.Get();
        if not IDYSSetup."Allow All Item Types" then begin
            Item.Get(WarehouseShipmentLine."Item No.");
            if Item.Type <> Item.Type::Inventory then
                exit;
        end;

        IDYSSetup.Get();
        if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Posted documents" then
            exit(WarehouseShipmentLine."Qty. to Ship (Base)")
        else begin
            WarehouseShipmentLine.IDYSCalculateQtySent();
            OutputSourceDocQtyToSend := GetSourceDocLineQtyToSend(WarehouseShipmentLine);
            exit(OutputSourceDocQtyToSend - WarehouseShipmentLine."IDYS Quantity Sent");
        end;
    end;

    procedure SetWarehouseShipmentLineQtyToSend(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        Item: Record Item;
        SourceDocQty: Decimal;
        SourceDocQtyToSend: Decimal;
        QtyToSend: Decimal;
        IsHandled: Boolean;
    begin
        IDYSSetup.Get();
        if not IDYSSetup."Allow All Item Types" then begin
            Item.Get(WarehouseShipmentLine."Item No.");
            if Item.Type <> Item.Type::Inventory then
                exit;
        end;
        SourceDocQty := WarehouseShipmentLine.IDYSGetSourceDocLineQuantity();
        QtyToSend := CalcWarehouseShipmentLineQtyToSend(WarehouseShipmentLine, SourceDocQtyToSend);
        OnBeforeWhseShipmentLineCheckQtyToSend(WarehouseShipmentLine, SourceDocQty, QtyToSend, IsHandled);
        if not IsHandled then
            if CheckQtyToSend(SourceDocQty, QtyToSend, WarehouseShipmentLine."IDYS Quantity Sent") then begin
                if QtyToSend <> WarehouseShipmentLine."IDYS Quantity To Send" then //Important condition in a Tasklet scenario
                    WarehouseShipmentLine.Validate("IDYS Quantity To Send", QtyToSend)
            end else
                if QtyToSend < 0 then
                    WarehouseShipmentLine.FieldError("IDYS Quantity To Send", StrSubstNo(OverShipQtyErr, WarehouseShipmentLine."IDYS Quantity Sent", SourceDocQtyToSend))
                else
                    WarehouseShipmentLine.FieldError("IDYS Quantity To Send", StrSubstNo(ExceedQtyErr, QtyToSend, SourceDocQty, WarehouseShipmentLine."IDYS Quantity Sent", WarehouseShipmentLine.FieldCaption("IDYS Quantity Sent")));
    end;

    procedure GetSalesLineQtySent(SalesLine: Record "Sales Line"): Decimal
    begin
        SalesLine.CalcFields("IDYS Quantity Sent");
        exit(SalesLine."IDYS Quantity Sent");
    end;

    procedure SetPurchaseLineQtyToSend(var PurchaseLine: Record "Purchase Line"; QtyToSend: Decimal)
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        if PurchaseLine."Type" <> PurchaseLine."Type"::Item then
            exit;

        PurchaseLine.CalcFields("IDYS Quantity Sent");
        Item.Get(PurchaseLine."No.");

        IDYSSetup.Get();
        if not IDYSSetup."Allow All Item Types" then
            if Item."Type" <> Item."Type"::Inventory then
                exit;

        OnBeforePurchaseLineCheckQtyToSend(PurchaseLine, QtyToSend, IsHandled);
        if not IsHandled then
            if CheckQtyToSend(PurchaseLine."Quantity (Base)", QtyToSend, PurchaseLine."IDYS Quantity Sent") then
                PurchaseLine.Validate("IDYS Quantity To Send", QtyToSend)
            else
                if QtyToSend < 0 then
                    case PurchaseLine."Document Type" of
                        PurchaseLine."Document Type"::"Return Order":
                            PurchaseLine.FieldError("IDYS Quantity To Send", StrSubstNo(OverShipQtyErr, PurchaseLine."IDYS Quantity Sent", PurchaseLine."Return Qty. Shipped (Base)" + PurchaseLine."Return Qty. to Ship (Base)"));
                        PurchaseLine."Document Type"::Order:
                            PurchaseLine.FieldError("IDYS Quantity To Send", StrSubstNo(OverShipQtyErr, PurchaseLine."IDYS Quantity Sent", PurchaseLine."Qty. Received (Base)" + PurchaseLine."Qty. to Receive (Base)"));
                    end
                else
                    PurchaseLine.FieldError("IDYS Quantity To Send",
                        StrSubstNo(ExceedQtyErr,
                            QtyToSend,
                            PurchaseLine."Quantity (Base)",
                            PurchaseLine."IDYS Quantity Sent",
                            PurchaseLine.FieldCaption("IDYS Quantity Sent")));
    end;

    procedure GetPurchaseLineQtySent(PurchaseLine: Record "Purchase Line"): Decimal
    begin
        PurchaseLine.CalcFields("IDYS Quantity Sent");
        exit(PurchaseLine."IDYS Quantity Sent");
    end;

    procedure SetServiceOrderLineQtyToSend(var ServiceLine: Record "Service Line"; QtyToSend: Decimal)
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        if ServiceLine."Type" <> ServiceLine."Type"::Item then
            exit;

        ServiceLine.CalcFields("IDYS Quantity Sent");
        Item.Get(ServiceLine."No.");

        IDYSSetup.Get();
        if not IDYSSetup."Allow All Item Types" then
            if Item."Type" <> Item."Type"::Inventory then
                exit;

        OnBeforeServiceLineCheckQtyToSend(ServiceLine, QtyToSend, IsHandled);
        if not IsHandled then
            if CheckQtyToSend(ServiceLine."Quantity (Base)", QtyToSend, ServiceLine."IDYS Quantity Sent") then
                ServiceLine.Validate("IDYS Quantity To Send", QtyToSend)
            else
                if QtyToSend < 0 then
                    ServiceLine.FieldError("IDYS Quantity To Send", StrSubstNo(OverShipQtyErr, ServiceLine."IDYS Quantity Sent", ServiceLine."Qty. Shipped (Base)" + ServiceLine."Qty. to Ship (Base)"))
                else
                    ServiceLine.FieldError("IDYS Quantity To Send",
                        StrSubstNo(ExceedQtyErr,
                            QtyToSend,
                            ServiceLine."Quantity (Base)",
                            ServiceLine."IDYS Quantity Sent",
                            ServiceLine.FieldCaption("IDYS Quantity Sent")));
    end;

    procedure GetServiceOrderLineQtySent(ServiceLine: Record "Service Line"): Decimal
    begin
        ServiceLine.CalcFields("IDYS Quantity Sent");
        exit(ServiceLine."IDYS Quantity Sent");
    end;

    procedure SetTransferOrderLineQtyToSend(var TransferLine: Record "Transfer Line"; QtyToSend: Decimal)
    var
        IsHandled: Boolean;
    begin
        TransferLine.CalcFields("IDYS Quantity Sent");
        OnBeforeTransferLineCheckQtyToSend(TransferLine, QtyToSend, IsHandled);
        if not IsHandled then
            if CheckQtyToSend(TransferLine."Quantity (Base)", QtyToSend, TransferLine."IDYS Quantity Sent") then
                TransferLine.Validate("IDYS Quantity To Send", QtyToSend)
            else
                TransferLine.FieldError("IDYS Quantity To Send",
                    StrSubstNo(ExceedQtyErr,
                        QtyToSend,
                        TransferLine."Quantity (Base)",
                        TransferLine."IDYS Quantity Sent",
                        TransferLine.FieldCaption("IDYS Quantity Sent")));
    end;

    procedure GetTransferLineQtySent(TransferLine: Record "Transfer Line"): Decimal
    begin
        TransferLine.CalcFields("IDYS Quantity Sent");
        exit(TransferLine."IDYS Quantity Sent");
    end;

    procedure GetSalesShipmentLineQtyToSend(DocumentNo: Code[20]; LineNo: Integer; Quantity: Decimal): Decimal
    begin
        exit(Quantity - GetSalesShipmentLineQtySent(DocumentNo, LineNo));
    end;

    procedure GetSalesShipmentLineQtySent(DocumentNo: Code[20]; LineNo: Integer): Decimal
    var
        TransportOrderLine: Record "IDYS Transport Order Line";
    begin
        TransportOrderLine.SetCurrentKey("Source Document Type", "Source Document No.", "Source Document Line No.", "Order Header Status");
        TransportOrderLine.SetRange("Source Document Table No.", Database::"Sales Shipment Header");
        TransportOrderLine.SetRange("Source Document No.", DocumentNo);
        TransportOrderLine.SetRange("Source Document Line No.", LineNo);
        TransportOrderLine.SetFilter("Order Header Status", '<>%1', TransportOrderLine."Order Header Status"::Recalled);
        TransportOrderLine.CalcSums("Qty. (Base)");

        exit(TransportOrderLine."Qty. (Base)");
    end;

    procedure GetTransferShipmentLineQtyToSend(DocumentNo: Code[20]; LineNo: Integer; Quantity: Decimal): Decimal
    begin
        exit(Quantity - GetTransferShipmentLineQtySent(DocumentNo, LineNo));
    end;

    procedure GetTransferShipmentLineQtySent(DocumentNo: Code[20]; LineNo: Integer): Decimal
    var
        TransportOrderLine: Record "IDYS Transport Order Line";
    begin
        TransportOrderLine.SetCurrentKey("Source Document Type", "Source Document No.", "Source Document Line No.", "Order Header Status");
        TransportOrderLine.SetRange("Source Document Table No.", Database::"Transfer Shipment Header");
        TransportOrderLine.SetRange("Source Document No.", DocumentNo);
        TransportOrderLine.SetRange("Source Document Line No.", LineNo);
        TransportOrderLine.SetFilter("Order Header Status", '<>%1', TransportOrderLine."Order Header Status"::Recalled);
        TransportOrderLine.CalcSums("Qty. (Base)");

        exit(TransportOrderLine."Qty. (Base)");
    end;

    procedure GetReturnShipmentLineQtyToSend(DocumentNo: Code[20]; LineNo: Integer; Quantity: Decimal): Decimal
    begin
        exit(Quantity - GetReturnShipmentLineQtySent(DocumentNo, LineNo));
    end;

    procedure GetReturnShipmentLineQtySent(DocumentNo: Code[20]; LineNo: Integer): Decimal
    var
        TransportOrderLine: Record "IDYS Transport Order Line";
    begin
        TransportOrderLine.SetCurrentKey("Source Document Type", "Source Document No.", "Source Document Line No.", "Order Header Status");
        TransportOrderLine.SetRange("Source Document Table No.", Database::"Return Shipment Header");
        TransportOrderLine.SetRange("Source Document No.", DocumentNo);
        TransportOrderLine.SetRange("Source Document Line No.", LineNo);
        TransportOrderLine.SetFilter("Order Header Status", '<>%1', TransportOrderLine."Order Header Status"::Recalled);
        TransportOrderLine.CalcSums("Qty. (Base)");

        exit(TransportOrderLine."Qty. (Base)");
    end;

    procedure GetServiceShipmtLineQtyToSend(DocumentNo: Code[20]; LineNo: Integer; Quantity: Decimal): Decimal
    begin
        exit(Quantity - GetServiceShipmentLineQtySent(DocumentNo, LineNo));
    end;

    procedure GetServiceShipmentLineQtySent(DocumentNo: Code[20]; LineNo: Integer): Decimal
    var
        TransportOrderLine: Record "IDYS Transport Order Line";
    begin
        TransportOrderLine.SetCurrentKey("Source Document Type", "Source Document No.", "Source Document Line No.", "Order Header Status");
        TransportOrderLine.SetRange("Source Document Table No.", Database::"Service Shipment Header");
        TransportOrderLine.SetRange("Source Document No.", DocumentNo);
        TransportOrderLine.SetRange("Source Document Line No.", LineNo);
        TransportOrderLine.SetFilter("Order Header Status", '<>%1', TransportOrderLine."Order Header Status"::Recalled);
        TransportOrderLine.CalcSums("Qty. (Base)");

        exit(TransportOrderLine."Qty. (Base)");
    end;

    procedure GetTransportOrdersFilterFromSource(SourceDocTableNo: Integer; SourceDocType: Integer; SourceDocNo: Code[20]) FilterText: Text
    begin
        FilterText := FindTransportOrdersFromSource(SourceDocTableNo, SourceDocType, SourceDocNo);
    end;

    procedure FindAndOpenTransportOrdersFromSource(SourceDocTableNo: Integer; SourceDocType: Integer; SourceDocNo: Code[20])
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        FilterText: Text;
    begin
        FilterText := FindTransportOrdersFromSource(SourceDocTableNo, SourceDocType, SourceDocNo);
        if FilterText <> '' then begin
            TransportOrderHeader.FilterGroup(10);
            TransportOrderHeader.SetFilter("No.", FilterText);
            TransportOrderHeader.FilterGroup(0);
            if TransportOrderHeader.Count() = 1 then
                Page.RunModal(Page::"IDYS Transport Order Card", TransportOrderHeader)
            else
                Page.RunModal(0, TransportOrderHeader);
        end;
    end;

    procedure ShowSourceDocument(TransportOrderLine: Record "IDYS Transport Order Line")
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        ServiceHeader: Record "Service Header";
        TransferHeader: Record "Transfer Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        PageManagement: Codeunit "Page Management";
        IsHandled: Boolean;
    begin
        OnBeforeShowSourceDocument(TransportOrderLine, IsHandled);
        if IsHandled then
            exit;

        if TransportOrderLine."Source Document No." = '' then
            exit;
        case TransportOrderLine."Source Document Table No." of
            Database::"Sales Header":
                begin
                    SalesHeader.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.");
                    PageManagement.PageRun(SalesHeader);
                end;
            Database::"Purchase Header":
                begin
                    PurchaseHeader.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.");
                    PageManagement.PageRun(PurchaseHeader);
                end;
            Database::"Service Header":
                begin
                    ServiceHeader.Get(ServiceHeader."Document Type"::Order, TransportOrderLine."Source Document No.");
                    PageManagement.PageRun(ServiceHeader);
                end;
            Database::"Transfer Header":
                begin
                    TransferHeader.Get(TransportOrderLine."Source Document No.");
                    PageManagement.PageRun(TransferHeader);
                end;
            Database::"Transfer Shipment Header":
                begin
                    TransferShipmentHeader.Get(TransportOrderLine."Source Document No.");
                    Page.Run(Page::"Posted Transfer Shipment", TransferShipmentHeader);
                end;
            Database::"Transfer Receipt Header":
                begin
                    TransferReceiptHeader.Get(TransportOrderLine."Source Document No.");
                    Page.Run(Page::"Posted Transfer Receipt", TransferReceiptHeader);
                end;
            Database::"Sales Shipment Header":
                begin
                    SalesShipmentHeader.Get(TransportOrderLine."Source Document No.");
                    PageManagement.PageRun(SalesShipmentHeader);
                end;
            Database::"Return Shipment Header":
                begin
                    ReturnShipmentHeader.Get(TransportOrderLine."Source Document No.");
                    Page.Run(Page::"Posted Return Shipment", ReturnShipmentHeader);
                end;
            Database::"Service Shipment Header":
                begin
                    ServiceShipmentHeader.Get(TransportOrderLine."Source Document No.");
                    Page.RunModal(Page::"Posted Service Shipment", ServiceShipmentHeader);
                end;
        end;
    end;

    procedure ShowSourceDocument(TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        ServiceShipmentLine: Record "Service Shipment Line";
    begin
        case TransportWorksheetLine."Source Document Table No." of
            Database::"Sales Header":
                begin
                    SalesLine.SetRange("Document Type", TransportWorksheetLine."Source Document Type");
                    SalesLine.SetRange("Document No.", TransportWorksheetLine."Source Document No.");
                    SalesLine.SetRange("Line No.", TransportWorksheetLine."Source Document Line No.");
                    Page.Run(Page::"Sales Lines", SalesLine);
                end;
            Database::"Purchase Header":
                begin
                    PurchaseLine.SetRange("Document Type", TransportWorksheetLine."Source Document Type");
                    PurchaseLine.SetRange("Document No.", TransportWorksheetLine."Source Document No.");
                    PurchaseLine.SetRange("Line No.", TransportWorksheetLine."Source Document Line No.");
                    Page.Run(Page::"Purchase Lines", PurchaseLine);
                end;
            Database::"Service Header":
                begin
                    ServiceLine.SetRange("Document Type", TransportWorksheetLine."Source Document Type");
                    ServiceLine.SetRange("Document No.", TransportWorksheetLine."Source Document No.");
                    ServiceLine.SetRange("Line No.", TransportWorksheetLine."Source Document Line No.");
                    Page.Run(Page::"Service Lines", ServiceLine);
                end;

            Database::"Sales Shipment Header":
                begin
                    SalesShipmentLine.SetRange("Document No.", TransportWorksheetLine."Source Document No.");
                    SalesShipmentLine.SetRange("Line No.", TransportWorksheetLine."Source Document Line No.");
                    Page.Run(Page::"Posted Sales Shipment Lines", SalesShipmentLine);
                end;
            Database::"Return Shipment Header":
                begin
                    ReturnShipmentLine.SetRange("Document No.", TransportWorksheetLine."Source Document No.");
                    ReturnShipmentLine.SetRange("Line No.", TransportWorksheetLine."Source Document Line No.");
                    Page.Run(Page::"Posted Return Shipment Lines", ReturnShipmentLine);
                end;
            Database::"Service Shipment Header":
                begin
                    ServiceShipmentLine.SetRange("Document No.", TransportWorksheetLine."Source Document No.");
                    ServiceShipmentLine.SetRange("Line No.", TransportWorksheetLine."Source Document Line No.");
                    Page.Run(Page::"Posted Serv. Shpt. Line List", ServiceShipmentLine);
                end;
        end;
    end;

    local procedure CheckQtyToSend(Quantity: Decimal; QtyToSend: Decimal; QtySent: Decimal): Boolean
    var
    begin
        if Abs(QtyToSend) + Abs(QtySent) > Abs(Quantity) then
            exit(false);
        exit(true);
    end;

    local procedure CheckShippingSrvShippingTime(ShippingAgent: Code[10]; ShippingAgentSrv: Code[10])
    begin
        ShippingAgentServices.Get(ShippingAgent, ShippingAgentSrv);
        ShippingAgentServices.TestField("Shipping Time");
    end;

    procedure CreateTransportOrderFromWorksheetLine(var TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary; Cntr: Integer; ErrorMessageArr: array[10] of Text; WithDelayedOpenTransportOrder: Boolean);
    var
        CreateTptOrdWrksh: Codeunit "IDYS Create Tpt. Ord. (Wrksh.)";
        IsHandled: Boolean;
        NotAllLinesProcessedMsg: Label '%1 lines with quantities to send were not processed due to missing information.', Comment = '%1 = Integer value i.';
    begin
        OnBeforeCreateTransportOrderFromWorksheetLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, WithDelayedOpenTransportOrder, IsHandled);
        if IsHandled then
            exit;

        if WithDelayedOpenTransportOrder then
            CreateTptOrdWrksh.ToggleSkipOpenTransportOrder(WithDelayedOpenTransportOrder);
        if WhseShipmentNo <> '' then
            CreateTptOrdWrksh.SetWhseShipmentNo(WhseShipmentNo);
        CreateTptOrdWrksh.Run(TempTransportWorksheetLineBuffer);
        CreateTptOrdWrksh.GetTransportOrderLists(CreatedOrders, UpdatedOrders);

        OnAfterCreateTransportOrderFromWrkshLine(TempTransportWorksheetLineBuffer, Cntr, ErrorMessageArr, WithDelayedOpenTransportOrder, CreatedOrders, UpdatedOrders, WhseShipmentNo);

        if (GuiAllowed()) and (Cntr <> 0) then begin
            IDYSNotificationManagement.SendNotification(StrSubstNo(NotAllLinesProcessedMsg, Cntr));

            for Cntr := 1 to CompressArray(ErrorMessageArr) do
                IDYSNotificationManagement.SendNotification(ErrorMessageArr[Cntr]);
        end;
    end;

    local procedure GetSourceDocLineQtyToSend(WarehouseShipmentLine: Record "Warehouse Shipment Line") QtyToSend: Decimal
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        ServiceLine: Record "Service Line";
    begin
        case WarehouseShipmentLine."Source Type" of
            Database::"Sales Line":
                begin
                    SalesLine.Get(WarehouseShipmentLine."Source Subtype", WarehouseShipmentLine."Source No.", WarehouseShipmentLine."Source Line No.");
                    case SalesLine."Document Type" of
                        SalesLine."Document Type"::Order:
                            exit(WarehouseShipmentLine."Qty. to Ship (Base)" + SalesLine."Qty. Shipped (Base)");
                    end;
                end;
            Database::"Purchase Line":
                begin
                    PurchaseLine.Get(WarehouseShipmentLine."Source Subtype", WarehouseShipmentLine."Source No.", WarehouseShipmentLine."Source Line No.");
                    case PurchaseLine."Document Type" of
                        PurchaseLine."Document Type"::"Return Order":
                            exit(WarehouseShipmentLine."Qty. to Ship (Base)" + PurchaseLine."Return Qty. Shipped (Base)");
                    end;
                end;
            Database::"Transfer Line":
                begin
                    TransferLine.Get(WarehouseShipmentLine."Source No.", WarehouseShipmentLine."Source Line No.");
                    exit(WarehouseShipmentLine."Qty. to Ship (Base)" + TransferLine."Qty. Shipped (Base)");
                end;
            Database::"Service Line":
                begin
                    ServiceLine.Get(WarehouseShipmentLine."Source Subtype", WarehouseShipmentLine."Source No.", WarehouseShipmentLine."Source Line No.");
                    if ServiceLine."Document Type" = ServiceLine."Document Type"::Order then
                        exit(WarehouseShipmentLine."Qty. to Ship (Base)" + ServiceLine."Qty. Shipped (Base)");
                end;
            else
                OnGetSourceDocLineQtyToSendOnCaseSourceType(WarehouseShipmentLine, QtyToSend);
        end;
    end;

    local procedure FindTransportOrdersFromSource(SourceDocTableNo: Integer; SourceDocType: Integer; SourceDocNo: Code[20]) FilterText: Text
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        TransportOrderLine: Record "IDYS Transport Order Line";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecordRef: RecordRef;
    begin
        TransportOrderLine.SetCurrentKey("Source Document Table No.", "Source Document Type", "Source Document No.", "Order Header Status");
        if SourceDocTableNo = Database::"Warehouse Shipment Header" then begin
            IDYSSetup.Get();
            IDYSSetup.TestField("Base Transport Orders on", IDYSSetup."Base Transport Orders on"::"Unposted documents");
            WarehouseShipmentLine.SetRange("No.", SourceDocNo);
            if WarehouseShipmentLine.FindSet() then
                repeat
                    case WarehouseShipmentLine."Source Document" of
                        WarehouseShipmentLine."Source Document"::"Sales Order":
                            TransportOrderLine.SetRange("Source Document Table No.", Database::"Sales Header");
                        WarehouseShipmentLine."Source Document"::"Purchase Return Order":
                            TransportOrderLine.SetRange("Source Document Table No.", Database::"Purchase Header");
                        WarehouseShipmentLine."Source Document"::"Outbound Transfer":
                            TransportOrderLine.SetRange("Source Document Table No.", Database::"Transfer Header");
                        WarehouseShipmentLine."Source Document"::"Service Order":
                            TransportOrderLine.SetRange("Source Document Table No.", Database::"Service Header");
                    end;
                    TransportOrderLine.SetRange("Source Document Type", WarehouseShipmentLine."Source Subtype");
                    TransportOrderLine.SetRange("Source Document No.", WarehouseShipmentLine."Source No.");
                    TransportOrderLine.SetRange("Source Document Line No.", WarehouseShipmentLine."Source Line No.");
                    if TransportOrderLine.FindSet() then
                        repeat
                            TransportOrderLine.Mark(true);
                        until TransportOrderLine.Next() = 0;
                until WarehouseShipmentLine.Next() = 0;
            TransportOrderLine.MarkedOnly(true);
            TransportOrderLine.SetRange("Source Document Table No.");
            TransportOrderLine.SetRange("Source Document Type");
            TransportOrderLine.SetRange("Source Document No.");
            TransportOrderLine.SetRange("Source Document Line No.");
        end else begin
            TransportOrderLine.SetRange("Source Document Table No.", SourceDocTableNo);
            TransportOrderLine.SetRange("Source Document Type", SourceDocType);
            TransportOrderLine.SetRange("Source Document No.", SourceDocNo);
        end;
        RecordRef.GetTable(TransportOrderLine);
        TransportOrderLine.SetFilter("Order Header Status", '<>%1', TransportOrderLine."Order Header Status"::Archived);
        FilterText := SelectionFilterManagement.GetSelectionFilter(RecordRef, TransportOrderLine.FieldNo("Transport Order No."));
    end;

    local procedure UpdateServiceLevel(var ShippingAgent: Code[10]; var ServiceLevel: Code[10]; IsReturn: Boolean): Boolean
    var
        IDYSvcBookingProfile: Record "IDYS Svc. Booking Profile";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSSendcloudSetup: Record "IDYS Setup";
    begin
        // Select default method
        if IsReturn then
            exit(false);

        if (ShippingAgent <> '') and (ServiceLevel <> '') then
            exit(false);

        if not IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Sendcloud, false) then
            exit(false);

        IDYSSendcloudSetup.GetProviderSetup("IDYS Provider"::Sendcloud);
        if IDYSSendcloudSetup."Apply Shipping Rules" then begin
            IDYSProviderBookingProfile.SetRange(Id, 8);
            if IDYSProviderBookingProfile.FindLast() then begin
                // Find the mapped unstamped letter
                IDYSvcBookingProfile.SetRange("Carrier Entry No.", IDYSProviderBookingProfile."Carrier Entry No.");
                IDYSvcBookingProfile.SetRange("Booking Profile Entry No.", IDYSProviderBookingProfile."Entry No.");
                if IDYSvcBookingProfile.FindLast() then begin
                    ShippingAgent := IDYSvcBookingProfile."Shipping Agent Code";
                    ServiceLevel := IDYSvcBookingProfile."Shipping Agent Service Code";
                    exit(true);
                end;
            end;
        end;

        exit(false);
    end;

    procedure GetCalculatedWeight(var SalesHeader: Record "Sales Header") Return: Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                Return += Round(IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, SalesHeader."IDYS Carrier Entry No.") * SalesLine."Gross Weight" * SalesLine."IDYS Quantity To Send", IDYSProviderMgt.GetRoundingPrecision("IDYS Conversion Type"::Mass, SalesHeader."IDYS Carrier Entry No."))
            until SalesLine.Next() = 0;
    end;

    procedure CheckConditions() ReturnValue: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckConditions(CreatedOrders, UpdatedOrders, SkipCreate, ReturnValue, IsHandled);
        if IsHandled then
            exit(ReturnValue);

        if SkipCreate then
            exit(false);

        if CreatedOrders.Count() + UpdatedOrders.Count() > 1 then
            Error(MultipleTOOrdersErr);
        if CreatedOrders.Count() + UpdatedOrders.Count() < 1 then
            Error(EmptyTOOrdersListErr);
        exit(true);
    end;

    procedure GetLastCreatedTransportOrderNo() LastCreatedTransportOrderNo: Code[20]
    begin
        LastCreatedTransportOrderNo := CreatedOrders.Get(1);
        if LastCreatedTransportOrderNo <> '' then
            exit;

        LastCreatedTransportOrderNo := UpdatedOrders.Get(1);
        if LastCreatedTransportOrderNo <> '' then
            exit;
    end;

    procedure GetDefaultProvider(CurrentProvider: Enum "IDYS Provider"; var DefaultProvider: Enum "IDYS Provider"): Boolean
    var
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IsSendCloudEnabled: Boolean;
        IsnShiftShipEnabled: Boolean;
        IsTranssmartEnabled: Boolean;
        IsEasyPostEnabled: Boolean;
        IsCargosonEnabled: Boolean;
    begin
        // Check if multiple providers enabled
        IDYSProviderSetup.SetRange(Enabled, true);
        if IDYSProviderSetup.Count > 1 then
            exit;

        // Check if default provider is already set
        if IDYSProviderSetup.FindFirst() then
            if IDYSProviderSetup.Provider = CurrentProvider then
                exit;

        // Set default provider
        IsSendCloudEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Sendcloud, false);
        IsnShiftShipEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::"Delivery Hub", false);
        IsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Transsmart, false);
        IsEasyPostEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::EasyPost, false);
        IsCargosonEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Cargoson, false);

        if IsTranssmartEnabled xor IsnShiftShipEnabled xor IsSendCloudEnabled xor IsEasyPostEnabled then
            case true of
                IsTranssmartEnabled:
                    begin
                        DefaultProvider := "IDYS Provider"::Transsmart;
                        exit(true);
                    end;
                IsnShiftShipEnabled:
                    begin
                        DefaultProvider := "IDYS Provider"::"Delivery Hub";
                        exit(true);
                    end;
                IsSendCloudEnabled:
                    begin
                        DefaultProvider := "IDYS Provider"::Sendcloud;
                        exit(true);
                    end;
                IsEasyPostEnabled:
                    begin
                        DefaultProvider := "IDYS Provider"::EasyPost;
                        exit(true);
                    end;
                IsCargosonEnabled:
                    begin
                        DefaultProvider := "IDYS Provider"::Cargoson;
                        exit(true);
                    end;
            end;
        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetSourceDocLineQtyToSendOnCaseSourceType(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; QtyToSend: Decimal);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeServiceLineCheckQtyToSend(var ServiceLine: Record "Service Line"; QtoToSend: Decimal; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesLineCheckQtyToSend(var SalesLine: Record "Sales Line"; QtoToSend: Decimal; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchaseLineCheckQtyToSend(var PurchaseLine: Record "Purchase Line"; QtoToSend: Decimal; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferLineCheckQtyToSend(var TransferLine: Record "Transfer Line"; QtoToSend: Decimal; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseShipmentLineCheckQtyToSend(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; SourceDocQty: Decimal; QtoToSend: Decimal; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesHeader_CreateTransportOrder(SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSalesHeader_CreateTransportOrder(SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesHeader_CreateTempTransportOrder(SalesHeader: Record "Sales Header"; var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSalesHeader_CreateTempTransportOrder(SalesHeader: Record "Sales Header"; var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchaseReturnHeader_CreateTransportOrder(PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPurchaseReturnHeader_CreateTransportOrder(PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeServiceHeader_CreateTransportOrder(ServiceHeader: Record "Service Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterServiceHeader_CreateTransportOrder(ServiceHeader: Record "Service Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferHeader_CreateTransportOrder(TransferHeader: Record "Transfer Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferHeader_CreateTransportOrder(TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseShipmtHdr_CreateTransportOrder(WarehouseShipmentHeader: Record "Warehouse Shipment Header"; WithDelayedOpenTransportOrder: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWhseShipmtHdr_CreateTransportOrder(WarehouseShipmentHeader: Record "Warehouse Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesShipment_CreateTransportOrder(SalesShipmentHeader: Record "Sales Shipment Header"; WithDelayedOpenTransportOrder: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSalesShipment_CreateTransportOrder(SalesShipmentHeader: Record "Sales Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReturnShipment_CreateTransportOrder(ReturnShipmentHeader: Record "Return Shipment Header"; WithDelayedOpenTransportOrder: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReturnShipment_CreateTransportOrder(ReturnShipmentHeader: Record "Return Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeServiceShipment_CreateTransportOrder(ServiceShipmentHeader: Record "Service Shipment Header"; WithDelayedOpenTransportOrder: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterServiceShipment_CreateTransportOrder(ServiceShipmentHeader: Record "Service Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferShipment_CreateTransportOrder(TransferShipmentHeader: Record "Transfer Shipment Header"; WithDelayedOpenTransportOrder: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferShipment_CreateTransportOrder(TransferShipmentHeader: Record "Transfer Shipment Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateTransportOrderFromWorksheetLine(var TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary; Cntr: Integer; ErrorMessageArr: array[10] of Text; WithDelayedOpenTransportOrder: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTransportOrderFromWrkshLine(var TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary; var Cntr: Integer; ErrorMessageArr: array[10] of Text; WithDelayedOpenTransportOrder: Boolean; CreatedOrders: List of [Code[20]]; UpdatedOrders: List of [Code[20]]; WhseShipmentNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckConditions(CreatedOrders: List of [Code[20]]; UpdatedOrders: List of [Code[20]]; SkipCreate: Boolean; var ReturnValue: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowSourceDocument(TransportOrderLine: Record "IDYS Transport Order Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchaseHeader_CreateTransportOrder(PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPurchaseHeader_CreateTransportOrder(PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferReceipt_CreateTransportOrder(TransferReceiptHeader: Record "Transfer Receipt Header"; WithDelayedOpenTransportOrder: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferReceipt_CreateTransportOrder(TransferReceiptHeader: Record "Transfer Receipt Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    #region [Obsolete]
    [Obsolete('Removed due to wrongfully implemented flow', '21.0')]
    procedure ReturnReceipt_CreateTransportOrder(ReturnReceiptHeader: Record "Return Receipt Header"; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;

    [Obsolete('Removed due to wrongfully implemented flow', '21.0')]
    procedure GetReturnReceiptLineQtyToSend(DocumentNo: Code[20]; LineNo: Integer; Quantity: Decimal): Decimal
    begin
    end;

    [Obsolete('Removed due to wrongfully implemented flow', '21.0')]
    procedure GetReturnReceiptLineQtySent(DocumentNo: Code[20]; LineNo: Integer): Decimal
    begin
    end;

    [Obsolete('Replaced with OnAfterInsertTransportOrderFromWorksheetLine with add. parameters', '23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTransportOrderFromWorksheetLine(var TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary; var Cntr: Integer; ErrorMessageArr: array[10] of Text; WithDelayedOpenTransportOrder: Boolean)
    begin
    end;


    [Obsolete('Replaced with OnAfterCreateTransportOrderFromWrkshLine with add. parameters', '23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertTransportOrderFromWorksheetLine(var TempTransportWorksheetLineBuffer: Record "IDYS Transport Worksheet Line" temporary; var Cntr: Integer; ErrorMessageArr: array[10] of Text; WithDelayedOpenTransportOrder: Boolean; CreatedOrders: List of [Code[20]]; UpdatedOrders: List of [Code[20]])
    begin
    end;
    #endregion
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        IDYSIProvider: Interface "IDYS IProvider";
        CreatedOrders: List of [Code[20]];
        UpdatedOrders: List of [Code[20]];
        SkipCreate: Boolean;
        MissingPackagesErr: Label 'You cannot use the carrier selection without specifying the package(s).';
        MultipleTOOrdersErr: Label 'Multiple transport orders were created/updated. Contact your system administrator.';
        EmptyTOOrdersListErr: Label 'No transport orders were created/updated. Contact your system administrator.';
        NothingToCreateTok: Label 'eb335dfb-aaa4-4cfc-855b-bbfea8377fda', Locked = true;
}