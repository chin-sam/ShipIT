codeunit 11147648 "IDYS Create Worksheet Line"
{
    procedure SkipCheckSvcLevel(Skip: Boolean)
    begin
        SkipCheckServiceLevel := Skip;
    end;

    procedure FromSalesOrderLine(SalesLine: Record "Sales Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    var
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        ShippingAgentServices: Record "Shipping Agent Services";
        LocationFound: Boolean;
        IsHandled: Boolean;
        RecalcReceiptDate: Boolean;
    begin
        case SalesLine."Document Type" of
            SalesLine."Document Type"::Quote,
            SalesLine."Document Type"::Order:
                IDYSPublisher.OnBeforeFromSalesOrderLine(SalesLine, TransportWorksheetLine, IsHandled);
            SalesLine."Document Type"::"Return Order":
                IDYSPublisher.OnBeforeFromSalesReturnOrderLine(SalesLine, TransportWorksheetLine, IsHandled);
        end;
        if IsHandled then
            exit;

        if SalesLine."Type" <> SalesLine.Type::Item then
            exit(true);

        if not TransportWorksheetLine.IsTemporary() then //means a virtual carrier select
            if SalesLine."IDYS Quantity To Send" <= 0 then begin
                ErrorMessage := StrSubstNo(QtyToSendCannotBeZeroOrBelowErr, SalesLine."IDYS Quantity To Send");
                exit;
            end;

        if not Item.Get(SalesLine."No.") then
            exit(false);

        IDYSSetup.Get();
        if (not IDYSSetup."Allow All Item Types") and (Item."Type" <> Item."Type"::Inventory) then
            exit(true);

        if not (SalesLine."Document Type" in [SalesLine."Document Type"::Quote, SalesLine."Document Type"::Order, SalesLine."Document Type"::"Return Order"]) then
            SalesLine.FieldError("Document Type");

        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        if not CheckServiceLevel(SalesHeader."Shipping Agent Code", SalesHeader."Shipping Agent Service Code") then begin
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NoServiceLevelTok, StrSubstNo(NoServiceLevelMsg, SalesHeader."Shipping Agent Code", SalesHeader."Shipping Agent Service Code"));
            exit(false);
        end;

        TransportWorksheetLine.Init();
        TransportWorksheetLine.Validate("Source Document Table No.", Database::"Sales Header");
        TransportWorksheetLine.Validate("Source Document Type", SalesLine."Document Type");
        TransportWorksheetLine.Validate("Source Document No.", SalesLine."Document No.");
        TransportWorksheetLine.Validate("Source Document Line No.", SalesLine."Line No.");
        TransportWorksheetLine.Validate("Item No.", SalesLine."No.");
        TransportWorksheetLine.Validate("Variant Code", SalesLine."Variant Code");
        TransportWorksheetLine.Validate(Description, SalesLine.Description);
        TransportWorksheetLine.Validate("Description 2", SalesLine."Description 2");
        TransportWorksheetLine.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");
        TransportWorksheetLine.Validate("Qty. (Base)", Abs(SalesLine."IDYS Quantity To Send"));
        if (TransportWorksheetLine."Qty. (Base)" = 0) and TransportWorksheetLine.IsTemporary then
            TransportWorksheetLine.Validate("Qty. (Base)", Abs(SalesLine."Outstanding Qty. (Base)"));
        TransportWorksheetLine.Validate("E-Mail Type", SalesHeader."IDYS E-Mail Type");
        TransportWorksheetLine.Validate("Cost Center", SalesHeader."IDYS Cost Center");
        TransportWorksheetLine.Validate("Account No.", SalesHeader."IDYS Account No.");
        TransportWorksheetLine.Validate("Account No. (Invoice)", SalesHeader."IDYS Account No. (Bill-to)");
        TransportWorksheetLine.Validate("Do Not Insure", SalesHeader."IDYS Do Not Insure");
        TransportWorksheetLine.Validate("Source Document Description", SalesHeader."Posting Description");
        TransportWorksheetLine.Validate("Shipping Agent Code", SalesHeader."Shipping Agent Code");
        TransportWorksheetLine.Validate("Shipping Agent Service Code", SalesHeader."Shipping Agent Service Code");
        case true of
            (SalesLine."Document Type" = SalesLine."Document Type"::"Return Order") or
            (IDYSSetup."Base Preferred Date on" = IDYSSetup."Base Preferred Date on"::"Planned Date"):
                TransportWorksheetLine.Validate("Preferred Shipment Date", SalesLine."Planned Shipment Date");
            (SalesLine."Document Type" = SalesLine."Document Type"::"Order") and
            (IDYSSetup."Base Preferred Date on" = IDYSSetup."Base Preferred Date on"::"Posting Date"):
                begin
                    RecalcReceiptDate := true;
                    TransportWorksheetLine.Validate("Preferred Shipment Date", SalesHeader."Posting Date");
                end;
        end;

        if not ShippingAgentServices.Get(SalesLine."Shipping Agent Code", SalesLine."Shipping Agent Service Code") then
            ShippingAgentServices."Shipping Time" := SalesLine."Shipping Time";
        //when posting a warehouse the shipment agent is updated without validating dates, but the TO expects the actual shipping time
        if not RecalcReceiptDate then
            RecalcReceiptDate := ShippingAgentServices."Shipping Time" <> SalesLine."Shipping Time";

        if RecalcReceiptDate then begin
            TransferRoute.CalcPlannedReceiptDateForward(TransportWorksheetLine."Preferred Shipment Date", TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", SalesLine."Location Code", SalesLine."Shipping Agent Code", SalesLine."Shipping Agent Service Code");
            TransportWorksheetLine.Validate("Preferred Delivery Date");
        end else
            TransportWorksheetLine.Validate("Preferred Delivery Date", SalesLine."Planned Delivery Date");

        TransportWorksheetLine.Validate("Shipment Method Code", SalesHeader."Shipment Method Code");
        TransportWorksheetLine.Validate("External Document No.", SalesHeader."External Document No.");
        LocationFound := GetLocationAndCompanyInformation(SalesLine."Location Code", Location); // indien geen vestiging, dan company info

        case SalesLine."Document Type" of
            SalesLine."Document Type"::Quote,
            SalesLine."Document Type"::Order:
                begin
                    if LocationFound then
                        TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Location)
                    else
                        TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Company);

                    FillAddressFromLocation(TransportWorksheetLine, Location, "IDYS Address Type"::"Pick-up");
                    FillAddressFromSalesHeader(TransportWorksheetLine, SalesHeader, "IDYS Address Type"::"Ship-to");
                    FillAddressFromSalesHeader(TransportWorksheetLine, SalesHeader, "IDYS Address Type"::"Invoice");
                    IDYSPublisher.OnBeforeFinalizeFromSalesOrderLine(SalesLine, TransportWorksheetLine);
                end;
            SalesLine."Document Type"::"Return Order":
                begin
                    FillAddressFromSalesHeader(TransportWorksheetLine, SalesHeader, "IDYS Address Type"::"Pick-up");
                    if LocationFound then
                        TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Location)
                    else
                        TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Company);
                    FillAddressFromLocation(TransportWorksheetLine, Location, "IDYS Address Type"::"Ship-to");
                    FillAddressFromSalesHeader(TransportWorksheetLine, SalesHeader, "IDYS Address Type"::Invoice);
                    IDYSPublisher.OnBeforeFinalizeFromSalesReturnOrderLine(SalesLine, TransportWorksheetLine);
                end;
        end;
        exit(FinalizeTransportWorksheetLine(TransportWorksheetLine));
    end;

    procedure FromPurchaseOrderLine(PurchaseLine: Record "Purchase Line"; ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10]; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    var
        Item: Record Item;
        Location: Record Location;
        PurchaseHeader: Record "Purchase Header";
        ShippingAgentServices: Record "Shipping Agent Services";
        LocationFound: Boolean;
        IsHandled: Boolean;
        PlannedShipmentDate: Date;
    begin
        case PurchaseLine."Document Type" of
            PurchaseLine."Document Type"::Order:
                IDYSPublisher.OnBeforeFromPurchaseOrderLine(PurchaseLine, TransportWorksheetLine, IsHandled);
            PurchaseLine."Document Type"::"Return Order":
                IDYSPublisher.OnBeforeFromPurchaseReturnOrderLine(PurchaseLine, TransportWorksheetLine, IsHandled);
        end;
        if IsHandled then
            exit;

        if PurchaseLine."IDYS Quantity To Send" <= 0 then begin
            ErrorMessage := StrSubstNo(QtyToSendCannotBeZeroOrBelowErr, PurchaseLine."IDYS Quantity To Send");
            exit;
        end;
        if PurchaseLine."Type" <> PurchaseLine.Type::Item then
            exit(true);

        if not Item.Get(PurchaseLine."No.") then
            exit(false);

        IDYSSetup.Get();
        if (not IDYSSetup."Allow All Item Types") and (Item."Type" <> Item."Type"::Inventory) then
            exit(true);

        if not (PurchaseLine."Document Type" in [PurchaseLine."Document Type"::Order, PurchaseLine."Document Type"::"Return Order"]) then
            PurchaseLine.FieldError("Document Type");

        if not SkipCheckServiceLevel then
            if not CheckServiceLevel(ShippingAgentCode, ShippingAgentServiceCode) then begin
                if GuiAllowed() then
                    IDYSNotificationManagement.SendNotification(NoServiceLevelTok, StrSubstNo(NoServiceLevelMsg, ShippingAgentCode, ShippingAgentServiceCode));
                exit(false);
            end;
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");

        if ShippingAgentServices.Get(ShippingAgentCode, ShippingAgentServiceCode) then
            ShippingAgentServices.TestField("Shipping Time");

        TransportWorksheetLine.Init();
        TransportWorksheetLine.Validate("Source Document Table No.", Database::"Purchase Header");
        TransportWorksheetLine.Validate("Source Document Type", PurchaseLine."Document Type");
        TransportWorksheetLine.Validate("Source Document No.", PurchaseLine."Document No.");
        TransportWorksheetLine.Validate("Source Document Line No.", PurchaseLine."Line No.");
        TransportWorksheetLine.Validate("Item No.", PurchaseLine."No.");
        TransportWorksheetLine.Validate("Variant Code", PurchaseLine."Variant Code");
        TransportWorksheetLine.Validate(Description, PurchaseLine.Description);
        TransportWorksheetLine.Validate("Description 2", PurchaseLine."Description 2");
        TransportWorksheetLine.Validate("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
        TransportWorksheetLine.Validate("Qty. (Base)", PurchaseLine."IDYS Quantity To Send");
        TransportWorksheetLine.Validate("E-Mail Type", PurchaseHeader."IDYS E-Mail Type");
        TransportWorksheetLine.Validate("Cost Center", PurchaseHeader."IDYS Cost Center");
        TransportWorksheetLine.Validate("Account No.", PurchaseHeader."IDYS Account No.");
        TransportWorksheetLine.Validate("Account No. (Invoice)", PurchaseHeader."IDYS Acc. No. (Bill-to)");
        TransportWorksheetLine.Validate("Do Not Insure", PurchaseHeader."IDYS Do Not Insure");
        TransportWorksheetLine.Validate("Source Document Description", PurchaseHeader."Posting Description");
        TransportWorksheetLine.Validate("Shipping Agent Code", ShippingAgentCode);
        TransportWorksheetLine.Validate("Shipping Agent Service Code", ShippingAgentServiceCode);
        case IDYSSetup."Base Preferred Date on" of
            IDYSSetup."Base Preferred Date on"::"Planned Date":
                begin
                    if (PurchaseLine."Requested Receipt Date" <> 0D) and (PurchaseLine."Requested Receipt Date" > Today) then
                        TransportWorksheetLine.Validate("Preferred Delivery Date", PurchaseLine."Requested Receipt Date")
                    else
                        TransportWorksheetLine.Validate("Preferred Delivery Date", PurchaseLine."Planned Receipt Date");
                    if (TransportWorksheetLine."Preferred Delivery Date" <> 0D) then begin
                        TransferRoute.CalcPlanShipmentDateBackward(PlannedShipmentDate, TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", PurchaseLine."Location Code", ShippingAgentCode, ShippingAgentServiceCode);
                        TransportWorksheetLine.Validate("Preferred Shipment Date", PlannedShipmentDate);
                    end;
                end;
            IDYSSetup."Base Preferred Date on"::"Posting Date":
                begin
                    TransportWorksheetLine.Validate("Preferred Shipment Date", PurchaseHeader."Posting Date");
                    TransferRoute.CalcPlannedReceiptDateForward(TransportWorksheetLine."Preferred Shipment Date", TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", PurchaseLine."Location Code", ShippingAgentCode, ShippingAgentServiceCode);
                    TransportWorksheetLine.Validate("Preferred Delivery Date");
                end;
        end;

        TransportWorksheetLine.Validate("Shipment Method Code", PurchaseHeader."Shipment Method Code");
        LocationFound := GetLocationAndCompanyInformation(PurchaseLine."Location Code", Location); // indien geen vestiging, dan company info

        case PurchaseLine."Document Type" of
            PurchaseLine."Document Type"::Order:
                begin
                    if LocationFound then
                        TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Location)
                    else
                        TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Company);
                    FillAddressFromLocation(TransportWorksheetLine, Location, "IDYS Address Type"::"Ship-to");
                    FillAddressFromPurchaseHeader(TransportWorksheetLine, PurchaseHeader, "IDYS Address Type"::"Pick-up");
                    FillInvoiceAddrFromCompanyInfo(TransportWorksheetLine);
                    IDYSPublisher.OnBeforeFinalizeFromPurchaseOrderLine(PurchaseLine, TransportWorksheetLine);
                end;
            PurchaseLine."Document Type"::"Return Order":
                begin
                    if LocationFound then
                        TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Location)
                    else
                        TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Company);
                    FillAddressFromLocation(TransportWorksheetLine, Location, "IDYS Address Type"::"Pick-up");
                    FillAddressFromPurchaseHeader(TransportWorksheetLine, PurchaseHeader, "IDYS Address Type"::"Ship-to");
                    FillInvoiceAddrFromCompanyInfo(TransportWorksheetLine);
                    IDYSPublisher.OnBeforeFinalizeFromPurchaseReturnOrderLine(PurchaseLine, TransportWorksheetLine);
                end;
        end;
        exit(FinalizeTransportWorksheetLine(TransportWorksheetLine));
    end;

    procedure FromPurchaseReturnOrderLine(PurchaseLine: Record "Purchase Line"; ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10]; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    begin
        exit(FromPurchaseOrderLine(PurchaseLine, ShippingAgentCode, ShippingAgentServiceCode, TransportWorksheetLine))
    end;

    procedure FromServiceOrderLine(ServiceLine: Record "Service Line"; RequestedDeliveryDate: Date; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    var
        Item: Record Item;
        ServiceHeader: Record "Service Header";
        Location: Record Location;
        ShippingAgentServices: Record "Shipping Agent Services";
        LocationFound: Boolean;
        IsHandled: Boolean;
        PlannedShipmentDate: Date;
    begin
        IDYSPublisher.OnBeforeFromServiceOrderLine(ServiceLine, TransportWorksheetLine, IsHandled);
        if IsHandled then
            exit;

        if ServiceLine."IDYS Quantity To Send" <= 0 then begin
            ErrorMessage := StrSubstNo(QtyToSendCannotBeZeroOrBelowErr, ServiceLine."IDYS Quantity To Send");
            exit;
        end;

        if ServiceLine."Type" <> ServiceLine.Type::Item then
            exit(true);

        if not Item.Get(ServiceLine."No.") then
            exit(false);

        IDYSSetup.Get();
        if (not IDYSSetup."Allow All Item Types") and (Item."Type" <> Item."Type"::Inventory) then
            exit(true);

        ServiceLine.TestField("Document Type", ServiceLine."Document Type"::Order);
        ServiceHeader.Get(ServiceHeader."Document Type"::Order, ServiceLine."Document No.");
        if not CheckServiceLevel(ServiceHeader."Shipping Agent Code", ServiceHeader."Shipping Agent Service Code") then begin
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NoServiceLevelTok, StrSubstNo(NoServiceLevelMsg, ServiceHeader."Shipping Agent Code", ServiceHeader."Shipping Agent Service Code"));
            exit(false);
        end;

        TransportWorksheetLine.Init();
        TransportWorksheetLine.Validate("Source Document Table No.", Database::"Service Header");
        TransportWorksheetLine.Validate("Source Document Type", ServiceLine."Document Type");
        TransportWorksheetLine.Validate("Source Document No.", ServiceLine."Document No.");
        TransportWorksheetLine.Validate("Source Document Line No.", ServiceLine."Line No.");
        TransportWorksheetLine.Validate("Item No.", ServiceLine."No.");
        TransportWorksheetLine.Validate("Variant Code", ServiceLine."Variant Code");
        TransportWorksheetLine.Validate(Description, ServiceLine.Description);
        TransportWorksheetLine.Validate("Description 2", ServiceLine."Description 2");
        TransportWorksheetLine.Validate("Unit of Measure Code", ServiceLine."Unit of Measure Code");
        TransportWorksheetLine.Validate("Qty. (Base)", Abs(ServiceLine."IDYS Quantity To Send"));
        TransportWorksheetLine.Validate("E-Mail Type", ServiceHeader."IDYS E-Mail Type");
        TransportWorksheetLine.Validate("Cost Center", ServiceHeader."IDYS Cost Center");
        TransportWorksheetLine.Validate("Account No.", ServiceHeader."IDYS Account No.");
        TransportWorksheetLine.Validate("Account No. (Invoice)", ServiceHeader."IDYS Account No. (Bill-to)");
        TransportWorksheetLine.Validate("Do Not Insure", ServiceHeader."IDYS Do Not Insure");
        TransportWorksheetLine.Validate("Shipping Agent Code", ServiceHeader."Shipping Agent Code");
        TransportWorksheetLine.Validate("Shipping Agent Service Code", ServiceHeader."Shipping Agent Service Code");

        //when posting a warehouse the shipment agent is updated without validating dates, but the TO expects the actual shipping time
        if not ShippingAgentServices.Get(ServiceLine."Shipping Agent Code", ServiceLine."Shipping Agent Service Code") then
            ShippingAgentServices."Shipping Time" := ServiceLine."Shipping Time";

        case IDYSSetup."Base Preferred Date on" of
            IDYSSetup."Base Preferred Date on"::"Planned Date":
                if (RequestedDeliveryDate <> 0D) then begin
                    TransportWorksheetLine.Validate("Preferred Delivery Date", RequestedDeliveryDate);
                    TransferRoute.CalcPlanShipmentDateBackward(PlannedShipmentDate, TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", ServiceLine."Location Code", ServiceLine."Shipping Agent Code", ServiceLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Shipment Date", PlannedShipmentDate);
                end;
            IDYSSetup."Base Preferred Date on"::"Posting Date":
                begin
                    TransportWorksheetLine.Validate("Preferred Shipment Date", ServiceHeader."Posting Date");
                    TransferRoute.CalcPlannedReceiptDateForward(TransportWorksheetLine."Preferred Shipment Date", TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", ServiceLine."Location Code", ServiceLine."Shipping Agent Code", ServiceLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Delivery Date");
                end;
        end;

        TransportWorksheetLine.Validate("Shipment Method Code", ServiceHeader."Shipment Method Code");
        LocationFound := GetLocationAndCompanyInformation(ServiceLine."Location Code", Location); // indien geen vestiging, dan company info

        if LocationFound then
            TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Location)
        else
            TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Company);
        FillAddressFromLocation(TransportWorksheetLine, Location, "IDYS Address Type"::"Pick-up");
        FillAddressFromServiceOrder(TransportWorksheetLine, ServiceHeader, "IDYS Address Type"::"Ship-to");
        FillAddressFromServiceOrder(TransportWorksheetLine, ServiceHeader, "IDYS Address Type"::Invoice);
        IDYSPublisher.OnBeforeFinalizeFromServiceOrderLine(ServiceLine, TransportWorksheetLine);
        exit(FinalizeTransportWorksheetLine(TransportWorksheetLine));
    end;

    procedure FromSalesReturnOrderLine(SalesLine: Record "Sales Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    begin
        exit(FromSalesOrderLine(SalesLine, TransportWorksheetLine));
    end;

    procedure FromTransferOrderLine(TransferLine: Record "Transfer Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    var
        TransferHeader: Record "Transfer Header";
        Location: Record Location;
        LocationTo: Record Location;
        ShippingAgentServices: Record "Shipping Agent Services";
        IsHandled: Boolean;
        PlannedShipmentDate: Date;
        PlannedReceiptDate: Date;
    begin
        IDYSPublisher.OnBeforeFromTransferOrderLine(TransferLine, TransportWorksheetLine, IsHandled);
        if IsHandled then
            exit;

        if TransferLine."IDYS Quantity To Send" <= 0 then begin
            ErrorMessage := StrSubstNo(QtyToSendCannotBeZeroOrBelowErr, TransferLine."IDYS Quantity To Send");
            exit;
        end;
        TransferHeader.Get(TransferLine."Document No.");
        if not CheckServiceLevel(TransferHeader."Shipping Agent Code", TransferHeader."Shipping Agent Service Code") then
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NoServiceLevelTok, StrSubstNo(NoServiceLevelMsg, TransferHeader."Shipping Agent Code", TransferHeader."Shipping Agent Service Code"));

        IDYSSetup.Get();
        Location.Get(TransferHeader."Transfer-from Code");
        LocationTo.Get(TransferHeader."Transfer-to Code");
        CompanyInformation.Get();

        TransportWorksheetLine.Init();
        TransportWorksheetLine.Validate("Source Document Table No.", Database::"Transfer Header");
        TransportWorksheetLine.Validate("Source Document No.", TransferLine."Document No.");
        TransportWorksheetLine.Validate("Source Document Line No.", TransferLine."Line No.");
        TransportWorksheetLine.Validate("Item No.", TransferLine."Item No.");
        TransportWorksheetLine.Validate("Variant Code", TransferLine."Variant Code");
        TransportWorksheetLine.Validate(Description, TransferLine.Description);
        TransportWorksheetLine.Validate("Description 2", TransferLine."Description 2");
        TransportWorksheetLine.Validate("Unit of Measure Code", TransferLine."Unit of Measure Code");
        TransportWorksheetLine.Validate("Qty. (Base)", TransferLine."IDYS Quantity To Send");
        TransportWorksheetLine.Validate("E-Mail Type", TransferHeader."IDYS E-Mail Type");
        TransportWorksheetLine.Validate("Cost Center", TransferHeader."IDYS Cost Center");
        TransportWorksheetLine.Validate("Account No.", TransferHeader."IDYS Account No. (Ship-to)");
        TransportWorksheetLine.Validate("Account No. (Pick-up)", TransferHeader."IDYS Account No.");  // Pick-up
        TransportWorksheetLine.Validate("Do Not Insure", TransferHeader."IDYS Do Not Insure");
        //Investigate
        //Populate Account No. with IDYSSetup.Transsmart Account No.
        TransportWorksheetLine.Validate("Source Document Description", TransferLine."Transfer-from Code" + ' - ' + TransferLine."Transfer-to Code");
        TransportWorksheetLine.Validate("Shipping Agent Code", TransferHeader."Shipping Agent Code");
        TransportWorksheetLine.Validate("Shipping Agent Service Code", TransferHeader."Shipping Agent Service Code");

        //when posting a warehouse the shipment agent is updated without validating dates, but the TO expects the actual shipping time
        if not ShippingAgentServices.Get(TransferLine."Shipping Agent Code", TransferLine."Shipping Agent Service Code") then
            ShippingAgentServices."Shipping Time" := TransferLine."Shipping Time";
        case IDYSSetup."Base Preferred Date on" of
            IDYSSetup."Base Preferred Date on"::"Planned Date":
                begin
                    TransferRoute.CalcPlanReceiptDateBackward(PlannedReceiptDate, TransferLine."Receipt Date", TransferLine."Inbound Whse. Handling Time", TransferLine."Transfer-to Code", TransferLine."Shipping Agent Code", TransferLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Delivery Date", PlannedReceiptDate);
                    TransferRoute.CalcPlanShipmentDateBackward(PlannedShipmentDate, PlannedReceiptDate, ShippingAgentServices."Shipping Time", TransferLine."Transfer-from Code", TransferLine."Shipping Agent Code", TransferLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Shipment Date", PlannedShipmentDate);
                end;
            IDYSSetup."Base Preferred Date on"::"Posting Date":
                begin
                    TransportWorksheetLine.Validate("Preferred Shipment Date", TransferHeader."Posting Date");
                    TransferRoute.CalcPlannedReceiptDateForward(TransportWorksheetLine."Preferred Shipment Date", TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", TransferLine."Transfer-from Code", TransferLine."Shipping Agent Code", TransferLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Delivery Date");
                end;
        end;
        TransportWorksheetLine.Validate("Shipment Method Code", TransferHeader."Shipment Method Code");
        TransportWorksheetLine.Validate("External Document No.", TransferHeader."External Document No.");

        FillAddressFromTransferOrder(TransportWorksheetLine, TransferHeader, Location, "IDYS Address Type"::"Pick-up");
        FillAddressFromTransferOrder(TransportWorksheetLine, TransferHeader, LocationTo, "IDYS Address Type"::"Ship-to");
        FillInvoiceAddrFromCompanyInfo(TransportWorksheetLine);
        IDYSPublisher.OnBeforeFinalizeFromTransferOrderLine(TransferLine, TransportWorksheetLine);
        exit(FinalizeTransportWorksheetLine(TransportWorksheetLine));
    end;

    procedure FromWarehouseShipmentLine(WarehouseShipmentLine: Record "Warehouse Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    var
        Location: Record Location;
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine2: Record "Warehouse Shipment Line";
        ShippingAgentServices: Record "Shipping Agent Services";
        MessageTxt: Label '%1 %2', Locked = true;
        LocationFound: Boolean;
        IsHandled: Boolean;
    begin
        IDYSPublisher.OnBeforeFromWarehouseShipmentLine(WarehouseShipmentLine, TransportWorksheetLine, IsHandled);
        if IsHandled then
            exit;

        if WarehouseShipmentLine."IDYS Quantity To Send" <= 0 then begin
            ErrorMessage := StrSubstNo(QtyToSendCannotBeZeroOrBelowErr, WarehouseShipmentLine."IDYS Quantity To Send");
            exit;
        end;

        WarehouseShipmentHeader.Get(WarehouseShipmentLine."No.");
        if not SkipCheckServiceLevel then
            if not CheckServiceLevel(WarehouseShipmentHeader."Shipping Agent Code", WarehouseShipmentHeader."Shipping Agent Service Code") then begin
                if GuiAllowed() then
                    IDYSNotificationManagement.SendNotification(NoServiceLevelTok, StrSubstNo(NoServiceLevelMsg, WarehouseShipmentHeader."Shipping Agent Code", WarehouseShipmentHeader."Shipping Agent Service Code"));
                exit(false);
            end;
        IDYSSetup.Get();

        if ShippingAgentServices.Get(WarehouseShipmentHeader."Shipping Agent Code", WarehouseShipmentHeader."Shipping Agent Service Code") then
            ShippingAgentServices.TestField("Shipping Time");

        TransportWorksheetLine.Init();
        case WarehouseShipmentLine."Source Document" of
            WarehouseShipmentLine."Source Document"::"Sales Order", WarehouseShipmentLine."Source Document"::"Sales Return Order":
                TransportWorksheetLine.Validate("Source Document Table No.", Database::"Sales Header");
            WarehouseShipmentLine."Source Document"::"Purchase Order", WarehouseShipmentLine."Source Document"::"Purchase Return Order":
                TransportWorksheetLine.Validate("Source Document Table No.", Database::"Purchase Header");
            WarehouseShipmentLine."Source Document"::"Service Order":
                TransportWorksheetLine.Validate("Source Document Table No.", Database::"Service Header");
            WarehouseShipmentLine."Source Document"::"Outbound Transfer", WarehouseShipmentLine."Source Document"::"Inbound Transfer":
                TransportWorksheetLine.Validate("Source Document Table No.", Database::"Transfer Header");
        end;
        TransportWorksheetLine.Validate("Source Document Type", WarehouseShipmentLine."Source Subtype");
        TransportWorksheetLine.Validate("Source Document No.", WarehouseShipmentLine."Source No.");
        TransportWorksheetLine.Validate("Source Document Line No.", WarehouseShipmentLine."Source Line No.");
        TransportWorksheetLine.Validate("Item No.", WarehouseShipmentLine."Item No.");
        TransportWorksheetLine.Validate("Variant Code", WarehouseShipmentLine."Variant Code");
        TransportWorksheetLine.Validate(Description, WarehouseShipmentLine.Description);
        TransportWorksheetLine.Validate("Description 2", WarehouseShipmentLine."Description 2");
        TransportWorksheetLine.Validate("Unit of Measure Code", WarehouseShipmentLine."Unit of Measure Code");
        TransportWorksheetLine.Validate("Qty. (Base)", WarehouseShipmentLine."IDYS Quantity To Send");
        TransportWorksheetLine.Validate("Source Document Description", StrSubstNo(MessageTxt, WarehouseShipmentHeader.TableCaption(), WarehouseShipmentHeader."No."));
        TransportWorksheetLine.Validate("Shipping Agent Code", WarehouseShipmentHeader."Shipping Agent Code");
        TransportWorksheetLine.Validate("Shipping Agent Service Code", WarehouseShipmentHeader."Shipping Agent Service Code");
        TransportWorksheetLine.Validate("Do Not Insure", WarehouseShipmentLine."IDYS Do Not Insure");
        case IDYSSetup."Base Preferred Date on" of
            IDYSSetup."Base Preferred Date on"::"Planned Date":
                TransportWorksheetLine.Validate("Preferred Shipment Date", WarehouseShipmentLine."Shipment Date");
            IDYSSetup."Base Preferred Date on"::"Posting Date":
                TransportWorksheetLine.Validate("Preferred Shipment Date", WarehouseShipmentHeader."Posting Date");
        end;
        TransportWorksheetLine.Validate("Preferred Delivery Date", GetPlannedDeliveryDate(TransportWorksheetLine."Preferred Shipment Date", WarehouseShipmentHeader, WarehouseShipmentLine));
        TransportWorksheetLine.Validate("Shipment Method Code", WarehouseShipmentHeader."Shipment Method Code");
        TransportWorksheetLine.Validate("External Document No.", WarehouseShipmentHeader."External Document No.");
        LocationFound := GetLocationAndCompanyInformation(WarehouseShipmentLine."Location Code", Location); // indien geen vestiging, dan company info       

        if LocationFound then
            TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Location)
        else
            TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Company);
        FillAddressFromLocation(TransportWorksheetLine, Location, "IDYS Address Type"::"Pick-up");
        FillAddressFromWarehouseShipment(TransportWorksheetLine, WarehouseShipmentLine, "IDYS Address Type"::"Ship-to");
        FillAddressFromWarehouseShipment(TransportWorksheetLine, WarehouseShipmentLine, "IDYS Address Type"::Invoice);
        IDYSPublisher.OnBeforeFinalizeFromWarehouseShipmentLine(WarehouseShipmentLine, TransportWorksheetLine);
        TransportWorksheetLine.Include := true;
        TransportWorksheetLine.UpdateInclude();
        TransportWorksheetLine.Insert(true);

        //investigate
        // seems redundant needs inspection:
        // when removed use exit(FinalizeTransportWorksheetLine(TransportWorksheetLine));
        WarehouseShipmentLine2 := WarehouseShipmentLine;
        WarehouseShipmentLine2."IDYS Quantity To Send" := WarehouseShipmentLine."IDYS Quantity To Send";
        WarehouseShipmentLine2.Modify();
        // *

        if TransportWorksheetLine.Include = false then begin
            ErrorMessage := TransportWorksheetLine.GetErrorMessage();
            exit(false);
        end;
        exit(true);
    end;

    procedure FromPostedSalesShipmentLine(SalesShipmentLine: Record "Sales Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    var
        Item: Record Item;
        Location: Record Location;
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShippingAgentServices: Record "Shipping Agent Services";
        LocationFound: Boolean;
        IsHandled: Boolean;
        RecalcReceiptDate: Boolean;
    begin
        IDYSPublisher.OnBeforeFromPostedSalesShipmentLine(SalesShipmentLine, TransportWorksheetLine, IsHandled);
        if IsHandled then
            exit;

        if SalesShipmentLine."IDYS Quantity To Send" <= 0 then begin
            ErrorMessage := StrSubstNo(QtyToSendCannotBeZeroOrBelowErr, SalesShipmentLine."IDYS Quantity To Send");
            exit;
        end;

        if SalesShipmentLine."Type" <> SalesShipmentLine.Type::Item then
            exit(true);

        if not Item.Get(SalesShipmentLine."No.") then
            exit(false);

        IDYSSetup.Get();
        if (not IDYSSetup."Allow All Item Types") and (Item."Type" <> Item."Type"::Inventory) then
            exit(true);

        SalesShipmentHeader.Get(SalesShipmentLine."Document No.");
        if not SkipCheckServiceLevel then
            if not CheckServiceLevel(SalesShipmentHeader."Shipping Agent Code", SalesShipmentHeader."Shipping Agent Service Code") then begin
                if GuiAllowed() then
                    IDYSNotificationManagement.SendNotification(NoServiceLevelTok, StrSubstNo(NoServiceLevelMsg, SalesShipmentHeader."Shipping Agent Code", SalesShipmentHeader."Shipping Agent Service Code"));
                exit(false);
            end;

        TransportWorksheetLine.Init();
        TransportWorksheetLine.Validate("Source Document Table No.", Database::"Sales Shipment Header");
        TransportWorksheetLine.Validate("Source Document No.", SalesShipmentLine."Document No.");
        TransportWorksheetLine.Validate("Source Document Line No.", SalesShipmentLine."Line No.");
        TransportWorksheetLine.Validate(Book, IDYSSetup."After Posting Sales Orders" in
            [IDYSSetup."After Posting Sales Orders"::"Create and Book Transport Order(s)",
             IDYSSetup."After Posting Sales Orders"::"Create + Book and Print Transport Order(s)"]);
        TransportWorksheetLine.Validate(Print,
            IDYSSetup."After Posting Sales Orders" = IDYSSetup."After Posting Sales Orders"::"Create + Book and Print Transport Order(s)");
        TransportWorksheetLine.Validate("Item No.", SalesShipmentLine."No.");
        TransportWorksheetLine.Validate("Variant Code", SalesShipmentLine."Variant Code");
        TransportWorksheetLine.Validate(Description, SalesShipmentLine.Description);
        TransportWorksheetLine.Validate("Description 2", SalesShipmentLine."Description 2");
        TransportWorksheetLine.Validate("Unit of Measure Code", SalesShipmentLine."Unit of Measure Code");
        TransportWorksheetLine.Validate("Qty. (Base)", Abs(SalesShipmentLine."IDYS Quantity To Send"));
        TransportWorksheetLine.Validate("E-Mail Type", SalesShipmentHeader."IDYS E-Mail Type");
        TransportWorksheetLine.Validate("Cost Center", SalesShipmentHeader."IDYS Cost Center");
        TransportWorksheetLine.Validate("Account No.", SalesShipmentHeader."IDYS Account No.");
        TransportWorksheetLine.Validate("Account No. (Invoice)", SalesShipmentHeader."IDYS Account No. (Bill-to)");
        TransportWorksheetLine.Validate("Do Not Insure", SalesShipmentHeader."IDYS Do Not Insure");
        TransportWorksheetLine.Validate("Source Document Description", SalesShipmentHeader."Posting Description");
        TransportWorksheetLine.Validate("Shipping Agent Code", SalesShipmentHeader."Shipping Agent Code");
        TransportWorksheetLine.Validate("Shipping Agent Service Code", SalesShipmentHeader."Shipping Agent Service Code");
        case true of
            IDYSSetup."Base Preferred Date on" = IDYSSetup."Base Preferred Date on"::"Planned Date":
                TransportWorksheetLine.Validate("Preferred Shipment Date", SalesShipmentLine."Planned Shipment Date");
            IDYSSetup."Base Preferred Date on" = IDYSSetup."Base Preferred Date on"::"Posting Date":
                begin
                    RecalcReceiptDate := true;
                    TransportWorksheetLine.Validate("Preferred Shipment Date", SalesShipmentLine."Posting Date");
                end;
        end;

        if not ShippingAgentServices.Get(SalesShipmentHeader."Shipping Agent Code", SalesShipmentHeader."Shipping Agent Service Code") then
            ShippingAgentServices."Shipping Time" := SalesShipmentLine."Shipping Time";
        //when posting a warehouse the shipment agent is updated without validating dates, but the TO expects the actual shipping time
        if not RecalcReceiptDate then
            RecalcReceiptDate := ShippingAgentServices."Shipping Time" <> SalesShipmentLine."Shipping Time";

        if RecalcReceiptDate then begin
            TransferRoute.CalcPlannedReceiptDateForward(TransportWorksheetLine."Preferred Shipment Date", TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", SalesShipmentLine."Location Code", SalesShipmentHeader."Shipping Agent Code", SalesShipmentHeader."Shipping Agent Service Code");
            TransportWorksheetLine.Validate("Preferred Delivery Date");
        end else
            TransportWorksheetLine.Validate("Preferred Delivery Date", SalesShipmentLine."Planned Delivery Date");

        TransportWorksheetLine.Validate("Shipment Method Code", SalesShipmentHeader."Shipment Method Code");
        TransportWorksheetLine.Validate("External Document No.", SalesShipmentHeader."External Document No.");
        LocationFound := GetLocationAndCompanyInformation(SalesShipmentLine."Location Code", Location); // indien geen vestiging, dan company info

        if LocationFound then
            TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Location)
        else
            TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Company);
        FillAddressFromLocation(TransportWorksheetLine, Location, "IDYS Address Type"::"Pick-up");
        FillAddressFromSalesShipmentHeader(TransportWorksheetLine, SalesShipmentHeader, "IDYS Address Type"::"Ship-to");
        FillAddressFromSalesShipmentHeader(TransportWorksheetLine, SalesShipmentHeader, "IDYS Address Type"::"Invoice");
        IDYSPublisher.OnBeforeFinalizeFromPostedSalesShipmentLine(SalesShipmentLine, TransportWorksheetLine);
        exit(FinalizeTransportWorksheetLine(TransportWorksheetLine));
    end;

    procedure FromReturnShipmentLine(ReturnShipmentLine: Record "Return Shipment Line"; ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10]; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): boolean
    var
        Item: Record Item;
        Location: Record Location;
        ReturnShipmentHeader: Record "Return Shipment Header";
        ShippingAgentServices: Record "Shipping Agent Services";
        LocationFound: Boolean;
        IsHandled: Boolean;
    begin
        IDYSPublisher.OnBeforeFromReturnShipmentLine(ReturnShipmentLine, TransportWorksheetLine, IsHandled);
        if IsHandled then
            exit;
        if ReturnShipmentLine."IDYS Quantity To Send" <= 0 then begin
            ErrorMessage := StrSubstNo(QtyToSendCannotBeZeroOrBelowErr, ReturnShipmentLine."IDYS Quantity To Send");
            exit(false);
        end;
        if ReturnShipmentLine."Type" <> ReturnShipmentLine.Type::Item then
            exit(true);

        if not Item.Get(ReturnShipmentLine."No.") then
            exit(false);

        IDYSSetup.Get();
        if (not IDYSSetup."Allow All Item Types") and (Item."Type" <> Item."Type"::Inventory) then
            exit(true);

        if not SkipCheckServiceLevel then
            if not CheckServiceLevel(ShippingAgentCode, ShippingAgentServiceCode) then begin
                if GuiAllowed() then
                    IDYSNotificationManagement.SendNotification(NoServiceLevelTok, StrSubstNo(NoServiceLevelMsg, ShippingAgentCode, ShippingAgentServiceCode));
                exit(false);
            end;
        ReturnShipmentHeader.Get(ReturnShipmentLine."Document No.");

        if ShippingAgentServices.Get(ShippingAgentCode, ShippingAgentServiceCode) then
            ShippingAgentServices.TestField("Shipping Time");

        TransportWorksheetLine.Init();
        TransportWorksheetLine.Validate("Source Document Table No.", Database::"Return Shipment Header");
        TransportWorksheetLine.Validate("Source Document No.", ReturnShipmentLine."Document No.");
        TransportWorksheetLine.Validate("Source Document Line No.", ReturnShipmentLine."Line No.");
        TransportWorksheetLine.Validate(Book, IDYSSetup."After Posting Purch. Ret. Ord." in
            [IDYSSetup."After Posting Purch. Ret. Ord."::"Create and Book Transport Order(s)",
             IDYSSetup."After Posting Purch. Ret. Ord."::"Create + Book and Print Transport Order(s)"]);
        TransportWorksheetLine.Validate(Print,
            IDYSSetup."After Posting Purch. Ret. Ord." = IDYSSetup."After Posting Purch. Ret. Ord."::"Create + Book and Print Transport Order(s)");

        TransportWorksheetLine.Validate("Item No.", ReturnShipmentLine."No.");
        TransportWorksheetLine.Validate("Variant Code", ReturnShipmentLine."Variant Code");
        TransportWorksheetLine.Validate(Description, ReturnShipmentLine.Description);
        TransportWorksheetLine.Validate("Description 2", ReturnShipmentLine."Description 2");
        TransportWorksheetLine.Validate("Unit of Measure Code", ReturnShipmentLine."Unit of Measure Code");
        TransportWorksheetLine.Validate("Qty. (Base)", ReturnShipmentLine."IDYS Quantity To Send");
        TransportWorksheetLine.Validate("E-Mail Type", ReturnShipmentHeader."IDYS E-Mail Type");
        TransportWorksheetLine.Validate("Cost Center", ReturnShipmentHeader."IDYS Cost Center");
        TransportWorksheetLine.Validate("Account No.", ReturnShipmentHeader."IDYS Account No.");
        TransportWorksheetLine.Validate("Account No. (Invoice)", ReturnShipmentHeader."IDYS Account No. (Bill-to)");
        TransportWorksheetLine.Validate("Do Not Insure", ReturnShipmentHeader."IDYS Do Not Insure");
        TransportWorksheetLine.Validate("Source Document Description", ReturnShipmentHeader."Posting Description");
        TransportWorksheetLine.Validate("Shipping Agent Code", ShippingAgentCode);
        TransportWorksheetLine.Validate("Shipping Agent Service Code", ShippingAgentServiceCode);
        TransportWorksheetLine.Validate("Preferred Shipment Date", ReturnShipmentLine."Posting Date");
        TransferRoute.CalcPlannedReceiptDateForward(TransportWorksheetLine."Preferred Shipment Date", TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", ReturnShipmentLine."Location Code", ShippingAgentCode, ShippingAgentServiceCode);
        TransportWorksheetLine.Validate("Preferred Delivery Date");
        TransportWorksheetLine.Validate("Shipment Method Code", ReturnShipmentHeader."Shipment Method Code");
        LocationFound := GetLocationAndCompanyInformation(ReturnShipmentLine."Location Code", Location); // indien geen vestiging, dan company info

        if LocationFound then
            TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Location)
        else
            TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Company);
        FillAddressFromLocation(TransportWorksheetLine, Location, "IDYS Address Type"::"Pick-up");
        FillShipToAddrFromReturnShipmentHeader(TransportWorksheetLine, ReturnShipmentHeader);
        FillInvoiceAddrFromCompanyInfo(TransportWorksheetLine);
        IDYSPublisher.OnBeforeFinalizeFromReturnShipmentLine(ReturnShipmentLine, TransportWorksheetLine);
        exit(FinalizeTransportWorksheetLine(TransportWorksheetLine));
    end;

    procedure FromServiceShipmentLine(ServiceShipmentLine: Record "Service Shipment Line"; ShipmentMethodCode: Code[10]; ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10]; RequestedDeliveryDate: Date; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): boolean
    var
        Customer: Record Customer;
        Item: Record Item;
        Location: Record Location;
        ServiceShipmentHeader: Record "Service Shipment Header";
        ShippingAgentServices: Record "Shipping Agent Services";
        TransportDuration: DateFormula;
        LocationFound: Boolean;
        IsHandled: Boolean;
        PlannedShipmentDate: Date;
    begin
        IDYSPublisher.OnBeforeFromServiceShipmentLine(ServiceShipmentLine, TransportWorksheetLine, IsHandled);
        if IsHandled then
            exit;

        if ServiceShipmentLine."IDYS Quantity To Send" <= 0 then begin
            ErrorMessage := StrSubstNo(QtyToSendCannotBeZeroOrBelowErr, ServiceShipmentLine."IDYS Quantity To Send");
            exit(false);
        end;

        if ServiceShipmentLine."Type" <> ServiceShipmentLine.Type::Item then
            exit(true);

        if not Item.Get(ServiceShipmentLine."No.") then
            exit(false);

        IDYSSetup.Get();
        if (not IDYSSetup."Allow All Item Types") and (Item."Type" <> Item."Type"::Inventory) then
            exit(true);
        if not CheckServiceLevel(ShippingAgentCode, ShippingAgentServiceCode) then
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NoServiceLevelTok, StrSubstNo(NoServiceLevelMsg, ShippingAgentCode, ShippingAgentServiceCode));
        ServiceShipmentHeader.Get(ServiceShipmentLine."Document No.");

        if ShippingAgentServices.Get(ShippingAgentCode, ShippingAgentServiceCode) then begin
            ShippingAgentServices.TestField("Shipping Time");
            TransportDuration := ShippingAgentServices."Shipping Time";
        end else
            if (ServiceShipmentHeader."Customer No." <> '') and Customer.Get(ServiceShipmentHeader."Customer No.") then
                TransportDuration := Customer."Shipping Time";

        TransportWorksheetLine.Init();
        TransportWorksheetLine.Validate("Source Document Table No.", Database::"Service Shipment Header");
        TransportWorksheetLine.Validate("Source Document No.", ServiceShipmentLine."Document No.");
        TransportWorksheetLine.Validate("Source Document Line No.", ServiceShipmentLine."Line No.");
        TransportWorksheetLine.Validate(Book, IDYSSetup."After Posting Service Orders" in
            [IDYSSetup."After Posting Service Orders"::"Create and Book Transport Order(s)",
             IDYSSetup."After Posting Service Orders"::"Create + Book and Print Transport Order(s)"]);
        TransportWorksheetLine.Validate(Print,
            IDYSSetup."After Posting Service Orders" = IDYSSetup."After Posting Service Orders"::"Create + Book and Print Transport Order(s)");

        TransportWorksheetLine.Validate("Item No.", ServiceShipmentLine."No.");
        TransportWorksheetLine.Validate("Variant Code", ServiceShipmentLine."Variant Code");
        TransportWorksheetLine.Validate(Description, ServiceShipmentLine.Description);
        TransportWorksheetLine.Validate("Description 2", ServiceShipmentLine."Description 2");
        TransportWorksheetLine.Validate("Unit of Measure Code", ServiceShipmentLine."Unit of Measure Code");
        TransportWorksheetLine.Validate("Qty. (Base)", Abs(ServiceShipmentLine."IDYS Quantity To Send"));
        TransportWorksheetLine.Validate("E-Mail Type", ServiceShipmentHeader."IDYS E-Mail Type");
        TransportWorksheetLine.Validate("Cost Center", ServiceShipmentHeader."IDYS Cost Center");
        TransportWorksheetLine.Validate("Account No.", ServiceShipmentHeader."IDYS Account No.");
        TransportWorksheetLine.Validate("Account No. (Invoice)", ServiceShipmentHeader."IDYS Account No. (Bill-to)");
        TransportWorksheetLine.Validate("Do Not Insure", ServiceShipmentHeader."IDYS Do Not Insure");
        TransportWorksheetLine.Validate("Source Document Description", ServiceShipmentHeader."Posting Description");
        TransportWorksheetLine.Validate("Shipping Agent Code", ShippingAgentCode);
        TransportWorksheetLine.Validate("Shipping Agent Service Code", ShippingAgentServiceCode);

        //when posting a warehouse the shipment agent is updated without validating dates, but the TO expects the actual shipping time
        if not ShippingAgentServices.Get(ShippingAgentCode, ShippingAgentServiceCode) then
            ShippingAgentServices."Shipping Time" := TransportDuration;
        case IDYSSetup."Base Preferred Date on" of
            IDYSSetup."Base Preferred Date on"::"Planned Date":
                if (RequestedDeliveryDate <> 0D) then begin
                    TransportWorksheetLine.Validate("Preferred Delivery Date", RequestedDeliveryDate);
                    TransferRoute.CalcPlanShipmentDateBackward(PlannedShipmentDate, TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", ServiceShipmentLine."Location Code", ServiceShipmentHeader."IDYS Shipping Agent Code", ServiceShipmentHeader."IDYS Shipping Agent Srv Code");
                    TransportWorksheetLine.Validate("Preferred Shipment Date", PlannedShipmentDate);
                end;
            IDYSSetup."Base Preferred Date on"::"Posting Date":
                begin
                    TransportWorksheetLine.Validate("Preferred Shipment Date", ServiceShipmentHeader."Posting Date");
                    TransferRoute.CalcPlannedReceiptDateForward(TransportWorksheetLine."Preferred Shipment Date", TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", ServiceShipmentLine."Location Code", ServiceShipmentHeader."IDYS Shipping Agent Code", ServiceShipmentHeader."IDYS Shipping Agent Srv Code");
                    TransportWorksheetLine.Validate("Preferred Delivery Date");
                end;
        end;
        TransportWorksheetLine.Validate("Shipment Method Code", ShipmentMethodCode);
        LocationFound := GetLocationAndCompanyInformation(ServiceShipmentLine."Location Code", Location); // indien geen vestiging, dan company info

        if LocationFound then
            TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Location)
        else
            TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Company);

        FillAddressFromLocation(TransportWorksheetLine, Location, "IDYS Address Type"::"Pick-up");
        FillAddressFromServiceShipmentHeader(TransportWorksheetLine, ServiceShipmentHeader, "IDYS Address Type"::"Ship-to");
        FillAddressFromServiceShipmentHeader(TransportWorksheetLine, ServiceShipmentHeader, "IDYS Address Type"::Invoice);
        IDYSPublisher.OnBeforeFinalizeFromServiceShipmentLine(ServiceShipmentLine, TransportWorksheetLine);
        exit(FinalizeTransportWorksheetLine(TransportWorksheetLine));
    end;

    procedure FromTransferShipmentLine(TransferShipmentLine: Record "Transfer Shipment Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        Location: Record Location;
        LocationTo: Record Location;
        ShippingAgentServices: Record "Shipping Agent Services";
        InboundWhseHandlingTime: DateFormula;
        IsHandled: Boolean;
        PlannedReceiptDate: Date;
        PlannedShipmentDate: Date;
    begin
        IDYSPublisher.OnBeforeFromTransferShipmentLine(TransferShipmentLine, TransportWorksheetLine, IsHandled);
        if IsHandled then
            exit;
        if TransferShipmentLine."IDYS Quantity To Send" <= 0 then begin
            ErrorMessage := StrSubstNo(QtyToSendCannotBeZeroOrBelowErr, TransferShipmentLine."IDYS Quantity To Send");
            exit(false);
        end;
        TransferShipmentHeader.Get(TransferShipmentLine."Document No.");
        if not CheckServiceLevel(TransferShipmentHeader."Shipping Agent Code", TransferShipmentHeader."Shipping Agent Service Code") then
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NoServiceLevelTok, StrSubstNo(NoServiceLevelMsg, TransferShipmentHeader."Shipping Agent Code", TransferShipmentHeader."Shipping Agent Service Code"));
        IDYSSetup.Get();
        Location.Get(TransferShipmentHeader."Transfer-from Code");
        LocationTo.Get(TransferShipmentHeader."Transfer-to Code");
        CompanyInformation.Get();

        TransportWorksheetLine.Init();
        TransportWorksheetLine.Validate("Source Document Table No.", Database::"Transfer Shipment Header");
        TransportWorksheetLine.Validate("Source Document No.", TransferShipmentLine."Document No.");
        TransportWorksheetLine.Validate("Source Document Line No.", TransferShipmentLine."Line No.");
        TransportWorksheetLine.Validate(Book, IDYSSetup."After Posting Transfer Orders" in
            [IDYSSetup."After Posting Transfer Orders"::"Create and Book Transport Order(s)",
             IDYSSetup."After Posting Transfer Orders"::"Create + Book and Print Transport Order(s)"]);
        TransportWorksheetLine.Validate(Print,
            IDYSSetup."After Posting Transfer Orders" = IDYSSetup."After Posting Transfer Orders"::"Create + Book and Print Transport Order(s)");
        TransportWorksheetLine.Validate("Item No.", TransferShipmentLine."Item No.");
        TransportWorksheetLine.Validate("Variant Code", TransferShipmentLine."Variant Code");
        TransportWorksheetLine.Validate(Description, TransferShipmentLine.Description);
        TransportWorksheetLine.Validate("Description 2", TransferShipmentLine."Description 2");
        TransportWorksheetLine.Validate("Unit of Measure Code", TransferShipmentLine."Unit of Measure Code");
        TransportWorksheetLine.Validate("Qty. (Base)", TransferShipmentLine."IDYS Quantity To Send");
        TransportWorksheetLine.Validate("E-Mail Type", TransferShipmentHeader."IDYS E-Mail Type");
        TransportWorksheetLine.Validate("Cost Center", TransferShipmentHeader."IDYS Cost Center");
        TransportWorksheetLine.Validate("Account No. (Pick-up)", TransferShipmentHeader."IDYS Account No.");  // Pick-up
        TransportWorksheetLine.Validate("Account No.", TransferShipmentHeader."IDYS Account No. (Ship-to)");
        TransportWorksheetLine.Validate("Do Not Insure", TransferShipmentHeader."IDYS Do Not Insure");

        //Investigate
        //Populate Account No. with IDYSSetup.Transsmart Account No.
        TransportWorksheetLine.Validate("Source Document Description", TransferShipmentLine."Transfer-from Code" + ' - ' + TransferShipmentLine."Transfer-to Code");
        TransportWorksheetLine.Validate("Shipping Agent Code", TransferShipmentHeader."Shipping Agent Code");
        TransportWorksheetLine.Validate("Shipping Agent Service Code", TransferShipmentHeader."Shipping Agent Service Code");
        if not TransferShipmentHeader."Direct Transfer" then
            InboundWhseHandlingTime := Location."Inbound Whse. Handling Time";

        //when posting a warehouse the shipment agent is updated without validating dates, but the TO expects the actual shipping time
        if not ShippingAgentServices.Get(TransferShipmentLine."Shipping Agent Code", TransferShipmentLine."Shipping Agent Service Code") then
            ShippingAgentServices."Shipping Time" := TransferShipmentLine."Shipping Time";
        case IDYSSetup."Base Preferred Date on" of
            IDYSSetup."Base Preferred Date on"::"Planned Date":
                begin
                    TransferRoute.CalcPlanReceiptDateBackward(PlannedReceiptDate, TransferShipmentHeader."Receipt Date", InboundWhseHandlingTime, TransferShipmentLine."Transfer-to Code", TransferShipmentLine."Shipping Agent Code", TransferShipmentLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Delivery Date", PlannedReceiptDate);
                    TransferRoute.CalcPlanShipmentDateBackward(PlannedShipmentDate, PlannedReceiptDate, ShippingAgentServices."Shipping Time", TransferShipmentLine."Transfer-from Code", TransferShipmentLine."Shipping Agent Code", TransferShipmentLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Shipment Date", PlannedShipmentDate);
                end;
            IDYSSetup."Base Preferred Date on"::"Posting Date":
                begin
                    TransportWorksheetLine.Validate("Preferred Shipment Date", TransferShipmentHeader."Posting Date");
                    TransferRoute.CalcPlannedReceiptDateForward(TransportWorksheetLine."Preferred Shipment Date", TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", TransferShipmentLine."Transfer-from Code", TransferShipmentLine."Shipping Agent Code", TransferShipmentLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Delivery Date");
                end;
        end;
        TransportWorksheetLine.Validate("Shipment Method Code", TransferShipmentHeader."Shipment Method Code");
        TransportWorksheetLine.Validate("External Document No.", TransferShipmentHeader."External Document No.");

        FillAddressFromTransferShipmentHeader(TransportWorksheetLine, TransferShipmentHeader, Location, "IDYS Address Type"::"Pick-up");
        FillAddressFromTransferShipmentHeader(TransportWorksheetLine, TransferShipmentHeader, LocationTo, "IDYS Address Type"::"Ship-to");
        FillInvoiceAddrFromCompanyInfo(TransportWorksheetLine);
        IDYSPublisher.OnBeforeFinalizeFromTransferShipmentLine(TransferShipmentLine, TransportWorksheetLine);
        exit(FinalizeTransportWorksheetLine(TransportWorksheetLine));
    end;

    procedure FromTransferReceiptLine(TransferReceiptLine: Record "Transfer Receipt Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        Location: Record Location;
        LocationTo: Record Location;
        ShippingAgentServices: Record "Shipping Agent Services";
        InboundWhseHandlingTime: DateFormula;
        IsHandled: Boolean;
        PlannedReceiptDate: Date;
        PlannedShipmentDate: Date;
    begin
        IDYSPublisher.OnBeforeFromTransferReceiptLine(TransferReceiptLine, TransportWorksheetLine, IsHandled);
        if IsHandled then
            exit;
        if TransferReceiptLine."IDYS Quantity To Send" <= 0 then begin
            ErrorMessage := StrSubstNo(QtyToSendCannotBeZeroOrBelowErr, TransferReceiptLine."IDYS Quantity To Send");
            exit(false);
        end;
        TransferReceiptHeader.Get(TransferReceiptLine."Document No.");
        if not CheckServiceLevel(TransferReceiptHeader."Shipping Agent Code", TransferReceiptHeader."Shipping Agent Service Code") then
            if GuiAllowed() then
                IDYSNotificationManagement.SendNotification(NoServiceLevelTok, StrSubstNo(NoServiceLevelMsg, TransferReceiptHeader."Shipping Agent Code", TransferReceiptHeader."Shipping Agent Service Code"));
        IDYSSetup.Get();
        Location.Get(TransferReceiptHeader."Transfer-from Code");
        LocationTo.Get(TransferReceiptHeader."Transfer-to Code");
        CompanyInformation.Get();

        TransportWorksheetLine.Init();
        TransportWorksheetLine.Validate("Source Document Table No.", Database::"Transfer Receipt Header");
        TransportWorksheetLine.Validate("Source Document No.", TransferReceiptLine."Document No.");
        TransportWorksheetLine.Validate("Source Document Line No.", TransferReceiptLine."Line No.");
        TransportWorksheetLine.Validate(Book, IDYSSetup."After Posting Transfer Orders" in
            [IDYSSetup."After Posting Transfer Orders"::"Create and Book Transport Order(s)",
             IDYSSetup."After Posting Transfer Orders"::"Create + Book and Print Transport Order(s)"]);
        TransportWorksheetLine.Validate(Print,
            IDYSSetup."After Posting Transfer Orders" = IDYSSetup."After Posting Transfer Orders"::"Create + Book and Print Transport Order(s)");
        TransportWorksheetLine.Validate("Item No.", TransferReceiptLine."Item No.");
        TransportWorksheetLine.Validate("Variant Code", TransferReceiptLine."Variant Code");
        TransportWorksheetLine.Validate(Description, TransferReceiptLine.Description);
        TransportWorksheetLine.Validate("Description 2", TransferReceiptLine."Description 2");
        TransportWorksheetLine.Validate("Unit of Measure Code", TransferReceiptLine."Unit of Measure Code");
        TransportWorksheetLine.Validate("Qty. (Base)", TransferReceiptLine."IDYS Quantity To Send");
        TransportWorksheetLine.Validate("E-Mail Type", TransferReceiptHeader."IDYS E-Mail Type");
        TransportWorksheetLine.Validate("Cost Center", TransferReceiptHeader."IDYS Cost Center");
        TransportWorksheetLine.Validate("Account No. (Pick-up)", TransferReceiptHeader."IDYS Account No.");  // Pick-up
        TransportWorksheetLine.Validate("Account No.", TransferReceiptHeader."IDYS Account No. (Ship-to)");
        TransportWorksheetLine.Validate("Do Not Insure", TransferReceiptHeader."IDYS Do Not Insure");

        //Investigate
        //Populate Account No. with IDYSSetup.Transsmart Account No.
        TransportWorksheetLine.Validate("Source Document Description", TransferReceiptLine."Transfer-from Code" + ' - ' + TransferReceiptLine."Transfer-to Code");
        TransportWorksheetLine.Validate("Shipping Agent Code", TransferReceiptHeader."Shipping Agent Code");
        TransportWorksheetLine.Validate("Shipping Agent Service Code", TransferReceiptHeader."Shipping Agent Service Code");
        if not TransferReceiptHeader."Direct Transfer" then
            InboundWhseHandlingTime := Location."Inbound Whse. Handling Time";

        //when posting a warehouse the shipment agent is updated without validating dates, but the TO expects the actual shipping time
        if not ShippingAgentServices.Get(TransferReceiptLine."Shipping Agent Code", TransferReceiptLine."Shipping Agent Service Code") then
            ShippingAgentServices."Shipping Time" := TransferReceiptLine."Shipping Time";
        case IDYSSetup."Base Preferred Date on" of
            IDYSSetup."Base Preferred Date on"::"Planned Date":
                begin
                    TransferRoute.CalcPlanReceiptDateBackward(PlannedReceiptDate, TransferReceiptHeader."Receipt Date", InboundWhseHandlingTime, TransferReceiptLine."Transfer-to Code", TransferReceiptLine."Shipping Agent Code", TransferReceiptLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Delivery Date", PlannedReceiptDate);
                    TransferRoute.CalcPlanShipmentDateBackward(PlannedShipmentDate, PlannedReceiptDate, ShippingAgentServices."Shipping Time", TransferReceiptLine."Transfer-from Code", TransferReceiptLine."Shipping Agent Code", TransferReceiptLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Shipment Date", PlannedShipmentDate);
                end;
            IDYSSetup."Base Preferred Date on"::"Posting Date":
                begin
                    TransportWorksheetLine.Validate("Preferred Shipment Date", TransferReceiptHeader."Posting Date");
                    TransferRoute.CalcPlannedReceiptDateForward(TransportWorksheetLine."Preferred Shipment Date", TransportWorksheetLine."Preferred Delivery Date", ShippingAgentServices."Shipping Time", TransferReceiptLine."Transfer-from Code", TransferReceiptLine."Shipping Agent Code", TransferReceiptLine."Shipping Agent Service Code");
                    TransportWorksheetLine.Validate("Preferred Delivery Date");
                end;
        end;
        TransportWorksheetLine.Validate("Shipment Method Code", TransferReceiptHeader."Shipment Method Code");
        TransportWorksheetLine.Validate("External Document No.", TransferReceiptHeader."External Document No.");

        FillAddressFromTransferReceiptHeader(TransportWorksheetLine, TransferReceiptHeader, Location, "IDYS Address Type"::"Pick-up");
        FillAddressFromTransferReceiptHeader(TransportWorksheetLine, TransferReceiptHeader, LocationTo, "IDYS Address Type"::"Ship-to");
        FillInvoiceAddrFromCompanyInfo(TransportWorksheetLine);
        IDYSPublisher.OnBeforeFinalizeFromTransferReceiptLine(TransferReceiptLine, TransportWorksheetLine);
        exit(FinalizeTransportWorksheetLine(TransportWorksheetLine));
    end;

    procedure CheckServiceLevel(ShippingAgent: Code[10]; ServiceLevel: Code[10]): Boolean;
    var
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        RecordDoesNotExistsMsg: Label 'The %1 does not exists. Identification fields and values: %2=%3, %4=%5.', Comment = '%1 = IDYS Shipp. Agent Svc. Mapping record caprion, %2 = Shipping Agent Code field caption, %3 Shipping Agent Code field value, %4 = Shipping Agent Service Code field caption, %5 = Shipping Agent Service Code filed value';
        YouMustSpecifyFieldValueMsg: Label 'You must specify %1 in %2 %3=%4, %5=%6.', Comment = '%1 = Booking Profile Code (Ext.) filed value, %2 = IDYS Shipp. Agent Svc. Mapping record caprion, %3 = Shipping Agent Code field caption, %4 Shipping Agent Code field value, %5 = Shipping Agent Service Code field caption, %6 = Shipping Agent Service Code filed value';
    begin
        // Check if service level transsmart is specified.
        ErrorMessage := '';

        if SkipCheckServiceLevel then
            exit(true);

        if not IDYSShipAgentSvcMapping.Get(ShippingAgent, ServiceLevel) then begin
            ErrorMessage :=
                StrSubstNo(
                    RecordDoesNotExistsMsg,
                    IDYSShipAgentSvcMapping.TableCaption,
                    IDYSShipAgentSvcMapping.FieldCaption("Shipping Agent Code"), IDYSShipAgentSvcMapping."Shipping Agent Code",
                    IDYSShipAgentSvcMapping.FieldCaption("Shipping Agent Service Code"), IDYSShipAgentSvcMapping."Shipping Agent Service Code");
            exit(false);
        end;

        IDYSShipAgentSvcMapping.CalcFields(Provider);
        if not (IDYSShipAgentSvcMapping.Provider in [IDYSShipAgentSvcMapping.Provider::Sendcloud, IDYSShipAgentSvcMapping.Provider::EasyPost]) then
            if IDYSShipAgentSvcMapping."Booking Profile Entry No." = 0 then begin
                ErrorMessage :=
                    StrSubstNo(
                        YouMustSpecifyFieldValueMsg,
                        IDYSShipAgentSvcMapping.FieldCaption("Booking Profile Entry No."),
                        IDYSShipAgentSvcMapping.TableCaption,
                        IDYSShipAgentSvcMapping.FieldCaption("Shipping Agent Code"), IDYSShipAgentSvcMapping."Shipping Agent Code",
                        IDYSShipAgentSvcMapping.FieldCaption("Shipping Agent Service Code"), IDYSShipAgentSvcMapping."Shipping Agent Service Code");
                exit(false);
            end;

        exit(true);
    end;

    local procedure FillAddressFromLocation(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; Location: Record Location; IDYSAddressType: Enum "IDYS Address Type")
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    TransportWorksheetLine.Validate("No. (Pick-up)", Location.Code);
                    TransportWorksheetLine.Validate("Name (Pick-up)", Location.Name);
                    TransportWorksheetLine.Validate("Address (Pick-up)", Location.Address);
                    TransportWorksheetLine.Validate("Address 2 (Pick-up)", Location."Address 2");
                    TransportWorksheetLine.Validate("City (Pick-up)", Location.City);
                    TransportWorksheetLine.Validate("Post Code (Pick-up)", Location."Post Code");
                    TransportWorksheetLine.Validate("County (Pick-up)", Location.County);
                    TransportWorksheetLine.Validate("Country/Region Code (Pick-up)", Location."Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Pick-up)", Location.Contact);
                    TransportWorksheetLine.Validate("Phone No. (Pick-up)", Location."Phone No.");
                    TransportWorksheetLine.Validate("Fax No. (Pick-up)", Location."Fax No.");
                    TransportWorksheetLine.Validate("E-Mail (Pick-up)", Location."E-Mail");
                    TransportWorksheetLine.Validate("VAT Registration No. (Pick-up)", CompanyInformation."VAT Registration No.");
#if not BC17EORI
                    if Location."IDYS EORI Number" <> '' then
                        TransportWorksheetLine.Validate("EORI Number (Pick-up)", Location."IDYS EORI Number")
                    else
                        TransportWorksheetLine.Validate("EORI Number (Pick-up)", CompanyInformation."EORI Number");
#endif
                    TransportWorksheetLine.Validate("Account No. (Pick-up)", Location."IDYS Account No.");
                end;
            IDYSAddressType::"Ship-to":
                begin
                    TransportWorksheetLine.Validate("No. (Ship-to)", Location.Code);
                    TransportWorksheetLine.Validate("Name (Ship-to)", Location.Name);
                    TransportWorksheetLine.Validate("Address (Ship-to)", Location.Address);
                    TransportWorksheetLine.Validate("Address 2 (Ship-to)", Location."Address 2");
                    TransportWorksheetLine.Validate("City (Ship-to)", Location.City);
                    TransportWorksheetLine.Validate("Post Code (Ship-to)", Location."Post Code");
                    TransportWorksheetLine.Validate("County (Ship-to)", Location.County);
                    TransportWorksheetLine.Validate("Country/Region Code (Ship-to)", Location."Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Ship-to)", Location.Contact);
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", Location."Phone No.");
                    TransportWorksheetLine.Validate("Fax No. (Ship-to)", Location."Fax No.");
                    TransportWorksheetLine.Validate("E-Mail (Ship-to)", Location."E-Mail");
                    TransportWorksheetLine.Validate("VAT Registration No. (Ship-to)", CompanyInformation."VAT Registration No.");
#if not BC17EORI
                    if Location."IDYS EORI Number" <> '' then
                        TransportWorksheetLine.Validate("EORI Number (Ship-to)", Location."IDYS EORI Number")
                    else
                        TransportWorksheetLine.Validate("EORI Number (Ship-to)", CompanyInformation."EORI Number");
#endif
                    TransportWorksheetLine.Validate("Is Return", true);
                    TransportWorksheetLine.Validate("Account No.", Location."IDYS Account No.");
                end;
        end
    end;

    local procedure FillAddressFromPurchaseHeader(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; PurchaseHeader: Record "Purchase Header"; IDYSAddressType: Enum "IDYS Address Type")
    var
        Vendor: Record Vendor;
        OrderAddress: Record "Order Address";
    begin
        case IDYSAddressType of
            IDYSAddressType::"Ship-to":
                begin
                    TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Vendor);
                    TransportWorksheetLine.Validate("No. (Ship-to)", PurchaseHeader."Buy-from Vendor No.");
                    TransportWorksheetLine.Validate("Code (Ship-to)", PurchaseHeader."Ship-to Code");
                    TransportWorksheetLine.Validate("Name (Ship-to)", PurchaseHeader."Ship-to Name");
                    TransportWorksheetLine.Validate("Address (Ship-to)", PurchaseHeader."Ship-to Address");
                    TransportWorksheetLine.Validate("Address 2 (Ship-to)", PurchaseHeader."Ship-to Address 2");
                    TransportWorksheetLine.Validate("City (Ship-to)", PurchaseHeader."Ship-to City");
                    TransportWorksheetLine.Validate("Post Code (Ship-to)", PurchaseHeader."Ship-to Post Code");
                    TransportWorksheetLine.Validate("County (Ship-to)", PurchaseHeader."Ship-to County");
                    TransportWorksheetLine.Validate("Country/Region Code (Ship-to)", PurchaseHeader."Ship-to Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Ship-to)", PurchaseHeader."Ship-to Contact");
                    TransportWorksheetLine.Validate("VAT Registration No. (Ship-to)", PurchaseHeader."VAT Registration No.");
                    TransportWorksheetLine.Validate("Is Return", true);

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", PurchaseHeader."Ship-to Phone No.");
#endif
                    case true of
                        OrderAddress.Get(PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Order Address Code"):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Ship-to)", OrderAddress."Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Ship-to)", OrderAddress."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Ship-to)", OrderAddress."E-Mail");
                                Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Vendor."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Ship-to)", Vendor."EORI Number");
#endif
                            end;
                        Vendor.Get(PurchaseHeader."Buy-from Vendor No."):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Ship-to)", Vendor."Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Ship-to)", Vendor."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Ship-to)", Vendor."E-Mail");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Vendor."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Ship-to)", Vendor."EORI Number");
#endif
                            end;
                    end;
                end;
            IDYSAddressType::"Pick-up":
                begin
                    TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Vendor);
                    TransportWorksheetLine.Validate("No. (Pick-up)", PurchaseHeader."Buy-from Vendor No.");
                    TransportWorksheetLine.Validate("Name (Pick-up)", PurchaseHeader."Buy-from Vendor Name");
                    TransportWorksheetLine.Validate("Address (Pick-up)", PurchaseHeader."Buy-from Address");
                    TransportWorksheetLine.Validate("Address 2 (Pick-up)", PurchaseHeader."Buy-from Address 2");
                    TransportWorksheetLine.Validate("City (Pick-up)", PurchaseHeader."Buy-from City");
                    TransportWorksheetLine.Validate("Post Code (Pick-up)", PurchaseHeader."Buy-from Post Code");
                    TransportWorksheetLine.Validate("County (Pick-up)", PurchaseHeader."Buy-from County");
                    TransportWorksheetLine.Validate("Country/Region Code (Pick-up)", PurchaseHeader."Buy-from Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Pick-up)", PurchaseHeader."Buy-from Contact");
                    TransportWorksheetLine.Validate("VAT Registration No. (Pick-up)", PurchaseHeader."VAT Registration No.");

                    TransportWorksheetLine.Validate("Is Return", false);

                    case true of
                        OrderAddress.Get(PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Order Address Code"):
                            begin
                                TransportWorksheetLine.Validate("Phone No. (Pick-up)", OrderAddress."Phone No.");
                                TransportWorksheetLine.Validate("Fax No. (Pick-up)", OrderAddress."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Pick-up)", OrderAddress."E-Mail");
                                Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Pick-up)", Vendor."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Pick-up)", Vendor."EORI Number");
#endif
                            end;
                        Vendor.Get(PurchaseHeader."Buy-from Vendor No."):
                            begin
                                TransportWorksheetLine.Validate("Phone No. (Pick-up)", Vendor."Phone No.");
                                TransportWorksheetLine.Validate("Fax No. (Pick-up)", Vendor."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Pick-up)", Vendor."E-Mail");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Pick-up)", Vendor."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Pick-up)", Vendor."EORI Number");
#endif
                            end;
                    end;
                end;
        end;
    end;

    local procedure FillAddressFromSalesHeader(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; SalesHeader: Record "Sales Header"; IDYSAddressType: Enum "IDYS Address Type")
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Customer);
                    TransportWorksheetLine.Validate("No. (Pick-up)", SalesHeader."Sell-to Customer No.");
                    TransportWorksheetLine.Validate("Code (Pick-up)", SalesHeader."Ship-to Code");
                    TransportWorksheetLine.Validate("Name (Pick-up)", SalesHeader."Ship-to Name");
                    TransportWorksheetLine.Validate("Address (Pick-up)", SalesHeader."Ship-to Address");
                    TransportWorksheetLine.Validate("Address 2 (Pick-up)", SalesHeader."Ship-to Address 2");
                    TransportWorksheetLine.Validate("City (Pick-up)", SalesHeader."Ship-to City");
                    TransportWorksheetLine.Validate("Post Code (Pick-up)", SalesHeader."Ship-to Post Code");
                    TransportWorksheetLine.Validate("County (Pick-up)", SalesHeader."Ship-to County");
                    TransportWorksheetLine.Validate("Country/Region Code (Pick-up)", SalesHeader."Ship-to Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Pick-up)", SalesHeader."Ship-to Contact");
                    TransportWorksheetLine.Validate("VAT Registration No. (Pick-up)", SalesHeader."VAT Registration No.");
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
                    TransportWorksheetLine.Validate("Phone No. (Pick-up)", SalesHeader."Ship-to Phone No.");
#endif
                    case true of
                        ShipToAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code"):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Pick-up)", ShipToAddress."Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Pick-up)", ShipToAddress."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Pick-up)", ShipToAddress."E-Mail");
                                Customer.Get(SalesHeader."Sell-to Customer No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Pick-up)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Pick-up)", Customer."EORI Number");
#endif
                            end;
                        Customer.Get(SalesHeader."Sell-to Customer No."):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24                                
                                TransportWorksheetLine.Validate("Phone No. (Pick-up)", SalesHeader."Sell-to Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Pick-up)", Customer."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Pick-up)", SalesHeader."Sell-to E-Mail");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Pick-up)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Pick-up)", Customer."EORI Number");
#endif
                            end;
                    end;
                end;
            IDYSAddressType::"Ship-to":
                begin
                    TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Customer);
                    TransportWorksheetLine.Validate("No. (Ship-to)", SalesHeader."Sell-to Customer No.");
                    TransportWorksheetLine.Validate("Code (Ship-to)", SalesHeader."Ship-to Code");
                    TransportWorksheetLine.Validate("Name (Ship-to)", SalesHeader."Ship-to Name");
                    TransportWorksheetLine.Validate("Address (Ship-to)", SalesHeader."Ship-to Address");
                    TransportWorksheetLine.Validate("Address 2 (Ship-to)", SalesHeader."Ship-to Address 2");
                    TransportWorksheetLine.Validate("City (Ship-to)", SalesHeader."Ship-to City");
                    TransportWorksheetLine.Validate("Post Code (Ship-to)", SalesHeader."Ship-to Post Code");
                    TransportWorksheetLine.Validate("County (Ship-to)", SalesHeader."Ship-to County");
                    TransportWorksheetLine.Validate("Country/Region Code (Ship-to)", SalesHeader."Ship-to Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Ship-to)", SalesHeader."Ship-to Contact");
                    TransportWorksheetLine.Validate("VAT Registration No. (Ship-to)", SalesHeader."VAT Registration No.");
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", SalesHeader."Ship-to Phone No.");
#endif
                    case true of
                        ShipToAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code"):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Ship-to)", ShipToAddress."Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Ship-to)", ShipToAddress."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Ship-to)", ShipToAddress."E-Mail");
                                Customer.Get(SalesHeader."Sell-to Customer No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Ship-to)", Customer."EORI Number");
#endif
                            end;
                        Customer.Get(SalesHeader."Sell-to Customer No."):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Ship-to)", SalesHeader."Sell-to Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Ship-to)", Customer."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Ship-to)", SalesHeader."Sell-to E-Mail");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Ship-to)", Customer."EORI Number");
#endif
                            end;
                    end;
                end;
            IDYSAddressType::Invoice:
                case IDYSSetup."Address for Invoice Address" of
                    IDYSSetup."Address for Invoice Address"::"Bill-to Customer":
                        begin
                            TransportWorksheetLine.Validate("Source Type (Invoice)", TransportWorksheetLine."Source Type (Invoice)"::Customer);
                            TransportWorksheetLine.Validate("No. (Invoice)", SalesHeader."Bill-to Customer No.");
                            TransportWorksheetLine.Validate("Name (Invoice)", SalesHeader."Bill-to Name");
                            TransportWorksheetLine.Validate("Address (Invoice)", SalesHeader."Bill-to Address");
                            TransportWorksheetLine.Validate("Address 2 (Invoice)", SalesHeader."Bill-to Address 2");
                            TransportWorksheetLine.Validate("City (Invoice)", SalesHeader."Bill-to City");
                            TransportWorksheetLine.Validate("Post Code (Invoice)", SalesHeader."Bill-to Post Code");
                            TransportWorksheetLine.Validate("County (Invoice)", SalesHeader."Bill-to County");
                            TransportWorksheetLine.Validate("Country/Region Code (Invoice)", SalesHeader."Bill-to Country/Region Code");
                            TransportWorksheetLine.Validate("Contact (Invoice)", SalesHeader."Bill-to Contact");
                            TransportWorksheetLine.Validate("VAT Registration No. (Invoice)", SalesHeader."VAT Registration No.");
                            if Customer.Get(SalesHeader."Bill-to Customer No.") then begin
                                TransportWorksheetLine.Validate("Phone No. (Invoice)", Customer."Phone No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Invoice)", Customer."Mobile Phone No.");
                                TransportWorksheetLine.Validate("Fax No. (Invoice)", Customer."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Invoice)", Customer."E-Mail");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Invoice)", Customer."EORI Number");
#endif
                            end;
                        end;
                    IDYSSetup."Address for Invoice Address"::"Sell-to Customer":
                        begin
                            TransportWorksheetLine.Validate("Source Type (Invoice)", TransportWorksheetLine."Source Type (Invoice)"::Customer);
                            TransportWorksheetLine.Validate("No. (Invoice)", SalesHeader."Sell-to Customer No.");
                            TransportWorksheetLine.Validate("Name (Invoice)", SalesHeader."Sell-to Customer Name");
                            TransportWorksheetLine.Validate("Address (Invoice)", SalesHeader."Sell-to Address");
                            TransportWorksheetLine.Validate("Address 2 (Invoice)", SalesHeader."Sell-to Address 2");
                            TransportWorksheetLine.Validate("City (Invoice)", SalesHeader."Sell-to City");
                            TransportWorksheetLine.Validate("Post Code (Invoice)", SalesHeader."Sell-to Post Code");
                            TransportWorksheetLine.Validate("County (Invoice)", SalesHeader."Sell-to County");
                            TransportWorksheetLine.Validate("Country/Region Code (Invoice)", SalesHeader."Sell-to Country/Region Code");
                            TransportWorksheetLine.Validate("Contact (Invoice)", SalesHeader."Sell-to Contact");
                            TransportWorksheetLine.Validate("VAT Registration No. (Invoice)", SalesHeader."VAT Registration No.");
                            TransportWorksheetLine.Validate("Phone No. (Invoice)", SalesHeader."Sell-to Phone No.");
                            TransportWorksheetLine.Validate("E-Mail (Invoice)", SalesHeader."Sell-to E-Mail");

                            if Customer.Get(SalesHeader."Sell-to Customer No.") then begin
                                TransportWorksheetLine.Validate("Mobile Phone No. (Invoice)", Customer."Mobile Phone No.");
                                TransportWorksheetLine.Validate("Fax No. (Invoice)", Customer."Fax No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Invoice)", Customer."EORI Number");
#endif
                            end;
                        end;
                end;
        end;
    end;

    local procedure FillAddressFromSalesShipmentHeader(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; SalesShipmentHeader: Record "Sales Shipment Header"; IDYSAddressType: Enum "IDYS Address Type")
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
    begin
        case IDYSAddressType of
            IDYSAddressType::"Ship-to":
                begin
                    TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Customer);
                    TransportWorksheetLine.Validate("No. (Ship-to)", SalesShipmentHeader."Sell-to Customer No.");
                    TransportWorksheetLine.Validate("Code (Ship-to)", SalesShipmentHeader."Ship-to Code");
                    TransportWorksheetLine.Validate("Name (Ship-to)", SalesShipmentHeader."Ship-to Name");
                    TransportWorksheetLine.Validate("Address (Ship-to)", SalesShipmentHeader."Ship-to Address");
                    TransportWorksheetLine.Validate("Address 2 (Ship-to)", SalesShipmentHeader."Ship-to Address 2");
                    TransportWorksheetLine.Validate("City (Ship-to)", SalesShipmentHeader."Ship-to City");
                    TransportWorksheetLine.Validate("Post Code (Ship-to)", SalesShipmentHeader."Ship-to Post Code");
                    TransportWorksheetLine.Validate("County (Ship-to)", SalesShipmentHeader."Ship-to County");
                    TransportWorksheetLine.Validate("Country/Region Code (Ship-to)", SalesShipmentHeader."Ship-to Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Ship-to)", SalesShipmentHeader."Ship-to Contact");
                    TransportWorksheetLine.Validate("VAT Registration No. (Ship-to)", SalesShipmentHeader."VAT Registration No.");
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", SalesShipmentHeader."Ship-to Phone No.");
#endif
                    case true of
                        ShipToAddress.Get(SalesShipmentHeader."Sell-to Customer No.", SalesShipmentHeader."Ship-to Code"):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Ship-to)", ShipToAddress."Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Ship-to)", ShipToAddress."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Ship-to)", ShipToAddress."E-Mail");
                                Customer.Get(SalesShipmentHeader."Sell-to Customer No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Ship-to)", Customer."EORI Number");
#endif
                            end;
                        Customer.Get(SalesShipmentHeader."Sell-to Customer No."):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Ship-to)", SalesShipmentHeader."Sell-to Phone No.");
#endif
                                TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Customer."Mobile Phone No.");
                                TransportWorksheetLine.Validate("Fax No. (Ship-to)", Customer."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Ship-to)", SalesShipmentHeader."Sell-to E-Mail");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Ship-to)", Customer."EORI Number");
#endif
                            end;
                    end;
                end;
            IDYSAddressType::Invoice:
                case IDYSSetup."Address for Invoice Address" of
                    IDYSSetup."Address for Invoice Address"::"Bill-to Customer":
                        begin
                            TransportWorksheetLine.Validate("Source Type (Invoice)", TransportWorksheetLine."Source Type (Invoice)"::Customer);
                            TransportWorksheetLine.Validate("No. (Invoice)", SalesShipmentHeader."Bill-to Customer No.");
                            TransportWorksheetLine.Validate("Name (Invoice)", SalesShipmentHeader."Bill-to Name");
                            TransportWorksheetLine.Validate("Address (Invoice)", SalesShipmentHeader."Bill-to Address");
                            TransportWorksheetLine.Validate("Address 2 (Invoice)", SalesShipmentHeader."Bill-to Address 2");
                            TransportWorksheetLine.Validate("City (Invoice)", SalesShipmentHeader."Bill-to City");
                            TransportWorksheetLine.Validate("Post Code (Invoice)", SalesShipmentHeader."Bill-to Post Code");
                            TransportWorksheetLine.Validate("County (Invoice)", SalesShipmentHeader."Bill-to County");
                            TransportWorksheetLine.Validate("Country/Region Code (Invoice)", SalesShipmentHeader."Bill-to Country/Region Code");
                            TransportWorksheetLine.Validate("Contact (Invoice)", SalesShipmentHeader."Bill-to Contact");
                            TransportWorksheetLine.Validate("VAT Registration No. (Invoice)", SalesShipmentHeader."VAT Registration No.");
                            if Customer.Get(SalesShipmentHeader."Bill-to Customer No.") then begin
                                TransportWorksheetLine.Validate("Phone No. (Invoice)", Customer."Phone No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Invoice)", Customer."Mobile Phone No.");
                                TransportWorksheetLine.Validate("Fax No. (Invoice)", Customer."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Invoice)", Customer."E-Mail");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Invoice)", Customer."EORI Number");
#endif
                            end;
                        end;
                    IDYSSetup."Address for Invoice Address"::"Sell-to Customer":
                        begin
                            TransportWorksheetLine.Validate("Source Type (Invoice)", TransportWorksheetLine."Source Type (Invoice)"::Customer);
                            TransportWorksheetLine.Validate("No. (Invoice)", SalesShipmentHeader."Sell-to Customer No.");
                            TransportWorksheetLine.Validate("Name (Invoice)", SalesShipmentHeader."Sell-to Customer Name");
                            TransportWorksheetLine.Validate("Address (Invoice)", SalesShipmentHeader."Sell-to Address");
                            TransportWorksheetLine.Validate("Address 2 (Invoice)", SalesShipmentHeader."Sell-to Address 2");
                            TransportWorksheetLine.Validate("City (Invoice)", SalesShipmentHeader."Sell-to City");
                            TransportWorksheetLine.Validate("Post Code (Invoice)", SalesShipmentHeader."Sell-to Post Code");
                            TransportWorksheetLine.Validate("County (Invoice)", SalesShipmentHeader."Sell-to County");
                            TransportWorksheetLine.Validate("Country/Region Code (Invoice)", SalesShipmentHeader."Sell-to Country/Region Code");
                            TransportWorksheetLine.Validate("Contact (Invoice)", SalesShipmentHeader."Sell-to Contact");
                            TransportWorksheetLine.Validate("VAT Registration No. (Invoice)", SalesShipmentHeader."VAT Registration No.");
                            TransportWorksheetLine.Validate("Phone No. (Invoice)", SalesShipmentHeader."Sell-to Phone No.");
                            TransportWorksheetLine.Validate("E-Mail (Invoice)", SalesShipmentHeader."Sell-to E-Mail");

                            if Customer.Get(SalesShipmentHeader."Sell-to Customer No.") then begin
                                TransportWorksheetLine.Validate("Mobile Phone No. (Invoice)", Customer."Mobile Phone No.");
                                TransportWorksheetLine.Validate("Fax No. (Invoice)", Customer."Fax No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Invoice)", Customer."EORI Number");
#endif
                            end;
                        end;
                end;
        end;
    end;

    local procedure FillAddressFromServiceOrder(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; ServiceHeader: Record "Service Header"; IDYSAddressType: Enum "IDYS Address Type");
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
    begin
        case IDYSAddressType of
            IDYSAddressType::"Ship-to":
                begin
                    TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Customer);
                    TransportWorksheetLine.Validate("No. (Ship-to)", ServiceHeader."Customer No.");
                    TransportWorksheetLine.Validate("Code (Ship-to)", ServiceHeader."Ship-to Code");
                    TransportWorksheetLine.Validate("Name (Ship-to)", ServiceHeader."Ship-to Name");
                    TransportWorksheetLine.Validate("Address (Ship-to)", ServiceHeader."Ship-to Address");
                    TransportWorksheetLine.Validate("Address 2 (Ship-to)", ServiceHeader."Ship-to Address 2");
                    TransportWorksheetLine.Validate("City (Ship-to)", ServiceHeader."Ship-to City");
                    TransportWorksheetLine.Validate("Post Code (Ship-to)", ServiceHeader."Ship-to Post Code");
                    TransportWorksheetLine.Validate("County (Ship-to)", ServiceHeader."Ship-to County");
                    TransportWorksheetLine.Validate("Country/Region Code (Ship-to)", ServiceHeader."Ship-to Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Ship-to)", ServiceHeader."Ship-to Contact");
                    TransportWorksheetLine.Validate("VAT Registration No. (Ship-to)", ServiceHeader."VAT Registration No.");
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", ServiceHeader."Ship-to Phone");
#endif
                    case true of
                        ShipToAddress.Get(ServiceHeader."Customer No.", ServiceHeader."Ship-to Code"):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Ship-to)", ShipToAddress."Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Ship-to)", ShipToAddress."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Ship-to)", ShipToAddress."E-Mail");
                                Customer.Get(ServiceHeader."Customer No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Ship-to)", Customer."EORI Number");
#endif
                            end;
                        Customer.Get(ServiceHeader."Customer No."):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Ship-to)", ServiceHeader."Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Ship-to)", ServiceHeader."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Ship-to)", ServiceHeader."E-Mail");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Ship-to)", Customer."EORI Number");
#endif
                            end;
                    end;
                end;
            IDYSAddressType::Invoice:
                case IDYSSetup."Address for Invoice Address" of
                    IDYSSetup."Address for Invoice Address"::"Bill-to Customer":
                        begin
                            TransportWorksheetLine.Validate("Source Type (Invoice)", TransportWorksheetLine."Source Type (Invoice)"::Customer);
                            TransportWorksheetLine.Validate("No. (Invoice)", ServiceHeader."Bill-to Customer No.");
                            TransportWorksheetLine.Validate("Name (Invoice)", ServiceHeader."Bill-to Name");
                            TransportWorksheetLine.Validate("Address (Invoice)", ServiceHeader."Bill-to Address");
                            TransportWorksheetLine.Validate("Address 2 (Invoice)", ServiceHeader."Bill-to Address 2");
                            TransportWorksheetLine.Validate("City (Invoice)", ServiceHeader."Bill-to City");
                            TransportWorksheetLine.Validate("Post Code (Invoice)", ServiceHeader."Bill-to Post Code");
                            TransportWorksheetLine.Validate("County (Invoice)", ServiceHeader."Bill-to County");
                            TransportWorksheetLine.Validate("Country/Region Code (Invoice)", ServiceHeader."Bill-to Country/Region Code");
                            TransportWorksheetLine.Validate("Contact (Invoice)", ServiceHeader."Bill-to Contact");
                            TransportWorksheetLine.Validate("VAT Registration No. (Invoice)", ServiceHeader."VAT Registration No.");
                            if Customer.Get(ServiceHeader."Bill-to Customer No.") then begin
                                TransportWorksheetLine.Validate("Phone No. (Invoice)", Customer."Phone No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Invoice)", Customer."Mobile Phone No.");
                                TransportWorksheetLine.Validate("Fax No. (Invoice)", Customer."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Invoice)", Customer."E-Mail");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Invoice)", Customer."EORI Number");
#endif
                            end;
                        end;
                    IDYSSetup."Address for Invoice Address"::"Sell-to Customer":
                        begin
                            TransportWorksheetLine.Validate("Source Type (Invoice)", TransportWorksheetLine."Source Type (Invoice)"::Customer);
                            TransportWorksheetLine.Validate("No. (Invoice)", ServiceHeader."Customer No.");
                            TransportWorksheetLine.Validate("Name (Invoice)", ServiceHeader.Name);
                            TransportWorksheetLine.Validate("Address (Invoice)", ServiceHeader.Address);
                            TransportWorksheetLine.Validate("Address 2 (Invoice)", ServiceHeader."Address 2");
                            TransportWorksheetLine.Validate("City (Invoice)", ServiceHeader.City);
                            TransportWorksheetLine.Validate("Post Code (Invoice)", ServiceHeader."Post Code");
                            TransportWorksheetLine.Validate("County (Invoice)", ServiceHeader."County");
                            TransportWorksheetLine.Validate("Country/Region Code (Invoice)", ServiceHeader."Country/Region Code");
                            TransportWorksheetLine.Validate("Contact (Invoice)", ServiceHeader."Contact Name");
                            TransportWorksheetLine.Validate("VAT Registration No. (Invoice)", ServiceHeader."VAT Registration No.");
                            TransportWorksheetLine.Validate("Phone No. (Invoice)", ServiceHeader."Phone No.");
                            TransportWorksheetLine.Validate("Fax No. (Invoice)", ServiceHeader."Fax No.");
                            TransportWorksheetLine.Validate("E-Mail (Invoice)", ServiceHeader."E-Mail");

                            if Customer.Get(ServiceHeader."Customer No.") then begin
                                TransportWorksheetLine.Validate("Mobile Phone No. (Invoice)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Invoice)", Customer."EORI Number");
#endif
                            end;
                        end;
                end;
        end;
    end;

    local procedure FillAddressFromServiceShipmentHeader(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; ServiceShipmentHeader: Record "Service Shipment Header"; IDYSAddressType: enum "IDYS Address Type")
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
    begin
        case IDYSAddressType of
            IDYSAddressType::"Ship-to":
                begin
                    TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Customer);
                    TransportWorksheetLine.Validate("No. (Ship-to)", ServiceShipmentHeader."Customer No.");
                    TransportWorksheetLine.Validate("Code (Ship-to)", ServiceShipmentHeader."Ship-to Code");
                    TransportWorksheetLine.Validate("Name (Ship-to)", ServiceShipmentHeader."Ship-to Name");
                    TransportWorksheetLine.Validate("Address (Ship-to)", ServiceShipmentHeader."Ship-to Address");
                    TransportWorksheetLine.Validate("Address 2 (Ship-to)", ServiceShipmentHeader."Ship-to Address 2");
                    TransportWorksheetLine.Validate("City (Ship-to)", ServiceShipmentHeader."Ship-to City");
                    TransportWorksheetLine.Validate("Post Code (Ship-to)", ServiceShipmentHeader."Ship-to Post Code");
                    TransportWorksheetLine.Validate("County (Ship-to)", ServiceShipmentHeader."Ship-to County");
                    TransportWorksheetLine.Validate("Country/Region Code (Ship-to)", ServiceShipmentHeader."Ship-to Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Ship-to)", ServiceShipmentHeader."Ship-to Contact");
                    TransportWorksheetLine.Validate("VAT Registration No. (Ship-to)", ServiceShipmentHeader."VAT Registration No.");
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", ServiceShipmentHeader."Ship-to Phone");
#endif
                    case true of
                        ShipToAddress.Get(ServiceShipmentHeader."Customer No.", ServiceShipmentHeader."Ship-to Code"):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Ship-to)", ShipToAddress."Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Ship-to)", ShipToAddress."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Ship-to)", ShipToAddress."E-Mail");
                                Customer.Get(ServiceShipmentHeader."Customer No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Ship-to)", Customer."EORI Number");
#endif
                            end;
                        Customer.Get(ServiceShipmentHeader."Customer No."):
                            begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                                TransportWorksheetLine.Validate("Phone No. (Ship-to)", ServiceShipmentHeader."Phone No.");
#endif
                                TransportWorksheetLine.Validate("Fax No. (Ship-to)", ServiceShipmentHeader."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Ship-to)", ServiceShipmentHeader."E-Mail");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Ship-to)", Customer."EORI Number");
#endif
                            end;
                    end;
                end;
            IDYSAddressType::Invoice:
                case IDYSSetup."Address for Invoice Address" of
                    IDYSSetup."Address for Invoice Address"::"Bill-to Customer":
                        begin
                            TransportWorksheetLine.Validate("Source Type (Invoice)", TransportWorksheetLine."Source Type (Invoice)"::Customer);
                            TransportWorksheetLine.Validate("No. (Invoice)", ServiceShipmentHeader."Bill-to Customer No.");
                            TransportWorksheetLine.Validate("Name (Invoice)", ServiceShipmentHeader."Bill-to Name");
                            TransportWorksheetLine.Validate("Address (Invoice)", ServiceShipmentHeader."Bill-to Address");
                            TransportWorksheetLine.Validate("Address 2 (Invoice)", ServiceShipmentHeader."Bill-to Address 2");
                            TransportWorksheetLine.Validate("City (Invoice)", ServiceShipmentHeader."Bill-to City");
                            TransportWorksheetLine.Validate("Post Code (Invoice)", ServiceShipmentHeader."Bill-to Post Code");
                            TransportWorksheetLine.Validate("County (Invoice)", ServiceShipmentHeader."Bill-to County");
                            TransportWorksheetLine.Validate("Country/Region Code (Invoice)", ServiceShipmentHeader."Bill-to Country/Region Code");
                            TransportWorksheetLine.Validate("Contact (Invoice)", ServiceShipmentHeader."Bill-to Contact");
                            TransportWorksheetLine.Validate("VAT Registration No. (Invoice)", ServiceShipmentHeader."VAT Registration No.");
                            if Customer.Get(ServiceShipmentHeader."Bill-to Customer No.") then begin
                                TransportWorksheetLine.Validate("Phone No. (Invoice)", Customer."Phone No.");
                                TransportWorksheetLine.Validate("Mobile Phone No. (Invoice)", Customer."Mobile Phone No.");
                                TransportWorksheetLine.Validate("Fax No. (Invoice)", Customer."Fax No.");
                                TransportWorksheetLine.Validate("E-Mail (Invoice)", Customer."E-Mail");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Invoice)", Customer."EORI Number");
#endif
                            end;
                        end;
                    IDYSSetup."Address for Invoice Address"::"Sell-to Customer":
                        begin
                            TransportWorksheetLine.Validate("Source Type (Invoice)", TransportWorksheetLine."Source Type (Invoice)"::Customer);
                            TransportWorksheetLine.Validate("No. (Invoice)", ServiceShipmentHeader."Customer No.");
                            TransportWorksheetLine.Validate("Name (Invoice)", ServiceShipmentHeader.Name);
                            TransportWorksheetLine.Validate("Address (Invoice)", ServiceShipmentHeader.Address);
                            TransportWorksheetLine.Validate("Address 2 (Invoice)", ServiceShipmentHeader."Address 2");
                            TransportWorksheetLine.Validate("City (Invoice)", ServiceShipmentHeader.City);
                            TransportWorksheetLine.Validate("Post Code (Invoice)", ServiceShipmentHeader."Post Code");
                            TransportWorksheetLine.Validate("County (Invoice)", ServiceShipmentHeader."County");
                            TransportWorksheetLine.Validate("Country/Region Code (Invoice)", ServiceShipmentHeader."Country/Region Code");
                            TransportWorksheetLine.Validate("Contact (Invoice)", ServiceShipmentHeader."Contact Name");
                            TransportWorksheetLine.Validate("VAT Registration No. (Invoice)", ServiceShipmentHeader."VAT Registration No.");
                            TransportWorksheetLine.Validate("Phone No. (Invoice)", ServiceShipmentHeader."Phone No.");
                            TransportWorksheetLine.Validate("Fax No. (Invoice)", ServiceShipmentHeader."Fax No.");
                            TransportWorksheetLine.Validate("E-Mail (Invoice)", ServiceShipmentHeader."E-Mail");

                            if Customer.Get(ServiceShipmentHeader."Customer No.") then begin
                                TransportWorksheetLine.Validate("Mobile Phone No. (Invoice)", Customer."Mobile Phone No.");
#if not BC17EORI
                                TransportWorksheetLine.Validate("EORI Number (Invoice)", Customer."EORI Number");
#endif
                            end;
                        end;
                end;
        end;
    end;

    local procedure FillAddressFromTransferOrder(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; TransferHeader: Record "Transfer Header"; Location: Record Location; IDYSAddressType: enum "IDYS Address Type")
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Location);
                    TransportWorksheetLine.Validate("No. (Pick-up)", TransferHeader."Transfer-from Code");
                    TransportWorksheetLine.Validate("Name (Pick-up)", TransferHeader."Transfer-from Name");
                    TransportWorksheetLine.Validate("Address (Pick-up)", TransferHeader."Transfer-from Address");
                    TransportWorksheetLine.Validate("Address 2 (Pick-up)", TransferHeader."Transfer-from Address 2");
                    TransportWorksheetLine.Validate("City (Pick-up)", TransferHeader."Transfer-from City");
                    TransportWorksheetLine.Validate("Post Code (Pick-up)", TransferHeader."Transfer-from Post Code");
                    TransportWorksheetLine.Validate("County (Pick-up)", TransferHeader."Transfer-from County");
                    TransportWorksheetLine.Validate("Country/Region Code (Pick-up)", TransferHeader."Trsf.-from Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Pick-up)", TransferHeader."Transfer-from Contact");
                    TransportWorksheetLine.Validate("Phone No. (Pick-up)", Location."Phone No.");
                    TransportWorksheetLine.Validate("Fax No. (Pick-up)", Location."Fax No.");
                    TransportWorksheetLine.Validate("E-Mail (Pick-up)", Location."E-Mail");
                    TransportWorksheetLine.Validate("VAT Registration No. (Pick-up)", CompanyInformation."VAT Registration No.");
#if not BC17EORI
                    if Location."IDYS EORI Number" <> '' then
                        TransportWorksheetLine.Validate("EORI Number (Pick-up)", Location."IDYS EORI Number")
                    else
                        TransportWorksheetLine.Validate("EORI Number (Pick-up)", CompanyInformation."EORI Number");
#endif
                end;
            IDYSAddressType::"Ship-to":
                begin
                    TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Location);
                    TransportWorksheetLine.Validate("No. (Ship-to)", TransferHeader."Transfer-to Code");
                    TransportWorksheetLine.Validate("Name (Ship-to)", TransferHeader."Transfer-to Name");
                    TransportWorksheetLine.Validate("Address (Ship-to)", TransferHeader."Transfer-to Address");
                    TransportWorksheetLine.Validate("Address 2 (Ship-to)", TransferHeader."Transfer-to Address 2");
                    TransportWorksheetLine.Validate("City (Ship-to)", TransferHeader."Transfer-to City");
                    TransportWorksheetLine.Validate("Post Code (Ship-to)", TransferHeader."Transfer-to Post Code");
                    TransportWorksheetLine.Validate("County (Ship-to)", TransferHeader."Transfer-to County");
                    TransportWorksheetLine.Validate("Country/Region Code (Ship-to)", TransferHeader."Trsf.-to Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Ship-to)", TransferHeader."Transfer-to Contact");
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", Location."Phone No.");
                    TransportWorksheetLine.Validate("Fax No. (Ship-to)", Location."Fax No.");
                    TransportWorksheetLine.Validate("E-Mail (Ship-to)", Location."E-Mail");
                    TransportWorksheetLine.Validate("VAT Registration No. (Ship-to)", CompanyInformation."VAT Registration No.");
#if not BC17EORI
                    if Location."IDYS EORI Number" <> '' then
                        TransportWorksheetLine.Validate("EORI Number (Ship-to)", Location."IDYS EORI Number")
                    else
                        TransportWorksheetLine.Validate("EORI Number (Ship-to)", CompanyInformation."EORI Number");
#endif
                end;
        end
    end;

    local procedure FillAddressFromTransferShipmentHeader(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; TransferShipmentHeader: Record "Transfer Shipment Header"; Location: Record Location; IDYSAddressType: enum "IDYS Address Type")
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Location);
                    TransportWorksheetLine.Validate("No. (Pick-up)", TransferShipmentHeader."Transfer-from Code");
                    TransportWorksheetLine.Validate("Name (Pick-up)", TransferShipmentHeader."Transfer-from Name");
                    TransportWorksheetLine.Validate("Address (Pick-up)", TransferShipmentHeader."Transfer-from Address");
                    TransportWorksheetLine.Validate("Address 2 (Pick-up)", TransferShipmentHeader."Transfer-from Address 2");
                    TransportWorksheetLine.Validate("City (Pick-up)", TransferShipmentHeader."Transfer-from City");
                    TransportWorksheetLine.Validate("Post Code (Pick-up)", TransferShipmentHeader."Transfer-from Post Code");
                    TransportWorksheetLine.Validate("County (Pick-up)", TransferShipmentHeader."Transfer-from County");
                    TransportWorksheetLine.Validate("Country/Region Code (Pick-up)", TransferShipmentHeader."Trsf.-from Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Pick-up)", TransferShipmentHeader."Transfer-from Contact");
                    TransportWorksheetLine.Validate("Phone No. (Pick-up)", Location."Phone No.");
                    TransportWorksheetLine.Validate("Fax No. (Pick-up)", Location."Fax No.");
                    TransportWorksheetLine.Validate("E-Mail (Pick-up)", Location."E-Mail");
                    TransportWorksheetLine.Validate("VAT Registration No. (Pick-up)", CompanyInformation."VAT Registration No.");
#if not BC17EORI
                    if Location."IDYS EORI Number" <> '' then
                        TransportWorksheetLine.Validate("EORI Number (Pick-up)", Location."IDYS EORI Number")
                    else
                        TransportWorksheetLine.Validate("EORI Number (Pick-up)", CompanyInformation."EORI Number");
#endif
                end;
            IDYSAddressType::"Ship-to":
                begin
                    TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Location);
                    TransportWorksheetLine.Validate("No. (Ship-to)", TransferShipmentHeader."Transfer-to Code");
                    TransportWorksheetLine.Validate("Name (Ship-to)", TransferShipmentHeader."Transfer-to Name");
                    TransportWorksheetLine.Validate("Address (Ship-to)", TransferShipmentHeader."Transfer-to Address");
                    TransportWorksheetLine.Validate("Address 2 (Ship-to)", TransferShipmentHeader."Transfer-to Address 2");
                    TransportWorksheetLine.Validate("City (Ship-to)", TransferShipmentHeader."Transfer-to City");
                    TransportWorksheetLine.Validate("Post Code (Ship-to)", TransferShipmentHeader."Transfer-to Post Code");
                    TransportWorksheetLine.Validate("County (Ship-to)", TransferShipmentHeader."Transfer-to County");
                    TransportWorksheetLine.Validate("Country/Region Code (Ship-to)", TransferShipmentHeader."Trsf.-to Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Ship-to)", TransferShipmentHeader."Transfer-to Contact");
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", Location."Phone No.");
                    TransportWorksheetLine.Validate("Fax No. (Ship-to)", Location."Fax No.");
                    TransportWorksheetLine.Validate("E-Mail (Ship-to)", Location."E-Mail");
                    TransportWorksheetLine.Validate("VAT Registration No. (Ship-to)", CompanyInformation."VAT Registration No.");
#if not BC17EORI
                    if Location."IDYS EORI Number" <> '' then
                        TransportWorksheetLine.Validate("EORI Number (Ship-to)", Location."IDYS EORI Number")
                    else
                        TransportWorksheetLine.Validate("EORI Number (Ship-to)", CompanyInformation."EORI Number");
#endif
                end;
        end;
    end;

    local procedure FillAddressFromTransferReceiptHeader(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; TransferReceiptHeader: Record "Transfer Receipt Header"; Location: Record Location; IDYSAddressType: enum "IDYS Address Type")
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    TransportWorksheetLine.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)"::Location);
                    TransportWorksheetLine.Validate("No. (Pick-up)", TransferReceiptHeader."Transfer-from Code");
                    TransportWorksheetLine.Validate("Name (Pick-up)", TransferReceiptHeader."Transfer-from Name");
                    TransportWorksheetLine.Validate("Address (Pick-up)", TransferReceiptHeader."Transfer-from Address");
                    TransportWorksheetLine.Validate("Address 2 (Pick-up)", TransferReceiptHeader."Transfer-from Address 2");
                    TransportWorksheetLine.Validate("City (Pick-up)", TransferReceiptHeader."Transfer-from City");
                    TransportWorksheetLine.Validate("Post Code (Pick-up)", TransferReceiptHeader."Transfer-from Post Code");
                    TransportWorksheetLine.Validate("County (Pick-up)", TransferReceiptHeader."Transfer-from County");
                    TransportWorksheetLine.Validate("Country/Region Code (Pick-up)", TransferReceiptHeader."Trsf.-from Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Pick-up)", TransferReceiptHeader."Transfer-from Contact");
                    TransportWorksheetLine.Validate("Phone No. (Pick-up)", Location."Phone No.");
                    TransportWorksheetLine.Validate("Fax No. (Pick-up)", Location."Fax No.");
                    TransportWorksheetLine.Validate("E-Mail (Pick-up)", Location."E-Mail");
                    TransportWorksheetLine.Validate("VAT Registration No. (Pick-up)", CompanyInformation."VAT Registration No.");
#if not BC17EORI
                    if Location."IDYS EORI Number" <> '' then
                        TransportWorksheetLine.Validate("EORI Number (Pick-up)", Location."IDYS EORI Number")
                    else
                        TransportWorksheetLine.Validate("EORI Number (Pick-up)", CompanyInformation."EORI Number");
#endif
                end;
            IDYSAddressType::"Ship-to":
                begin
                    TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Location);
                    TransportWorksheetLine.Validate("No. (Ship-to)", TransferReceiptHeader."Transfer-to Code");
                    TransportWorksheetLine.Validate("Name (Ship-to)", TransferReceiptHeader."Transfer-to Name");
                    TransportWorksheetLine.Validate("Address (Ship-to)", TransferReceiptHeader."Transfer-to Address");
                    TransportWorksheetLine.Validate("Address 2 (Ship-to)", TransferReceiptHeader."Transfer-to Address 2");
                    TransportWorksheetLine.Validate("City (Ship-to)", TransferReceiptHeader."Transfer-to City");
                    TransportWorksheetLine.Validate("Post Code (Ship-to)", TransferReceiptHeader."Transfer-to Post Code");
                    TransportWorksheetLine.Validate("County (Ship-to)", TransferReceiptHeader."Transfer-to County");
                    TransportWorksheetLine.Validate("Country/Region Code (Ship-to)", TransferReceiptHeader."Trsf.-to Country/Region Code");
                    TransportWorksheetLine.Validate("Contact (Ship-to)", TransferReceiptHeader."Transfer-to Contact");
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", Location."Phone No.");
                    TransportWorksheetLine.Validate("Fax No. (Ship-to)", Location."Fax No.");
                    TransportWorksheetLine.Validate("E-Mail (Ship-to)", Location."E-Mail");
                    TransportWorksheetLine.Validate("VAT Registration No. (Ship-to)", CompanyInformation."VAT Registration No.");
#if not BC17EORI
                    if Location."IDYS EORI Number" <> '' then
                        TransportWorksheetLine.Validate("EORI Number (Ship-to)", Location."IDYS EORI Number")
                    else
                        TransportWorksheetLine.Validate("EORI Number (Ship-to)", CompanyInformation."EORI Number");
#endif
                end;
        end;
    end;

    local procedure FillAddressFromWarehouseShipment(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; WarehouseShipmentLine: Record "Warehouse Shipment Line"; IDYSAddressType: enum "IDYS Address Type");
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        ServiceHeader: Record "Service Header";
        Location: Record Location;
    begin
        case WarehouseShipmentLine."Source Document" of
            WarehouseShipmentLine."Source Document"::"Sales Order":
                begin
                    SalesHeader.Get(WarehouseShipmentLine."Source Subtype", WarehouseShipmentLine."Source No.");
                    FillAddressFromSalesHeader(TransportWorksheetLine, SalesHeader, IDYSAddressType);
                    if IDYSAddressType = IDYSAddressType::"Ship-to" then begin
                        TransportWorksheetLine.Validate("E-Mail Type", SalesHeader."IDYS E-Mail Type");
                        TransportWorksheetLine.Validate("Cost Center", SalesHeader."IDYS Cost Center");
                        TransportWorksheetLine.Validate("Account No.", SalesHeader."IDYS Account No.");
                        TransportWorksheetLine.Validate("Account No. (Invoice)", SalesHeader."IDYS Account No. (Bill-to)");
                    end;
                end;
            WarehouseShipmentLine."Source Document"::"Purchase Return Order":
                begin
                    PurchaseHeader.Get(WarehouseShipmentLine."Source Subtype", WarehouseShipmentLine."Source No.");
                    if IDYSAddressType = IDYSAddressType::"Ship-to" then begin
                        FillAddressFromPurchaseHeader(TransportWorksheetLine, PurchaseHeader, IDYSAddressType);
                        TransportWorksheetLine.Validate("E-Mail Type", PurchaseHeader."IDYS E-Mail Type");
                        TransportWorksheetLine.Validate("Cost Center", PurchaseHeader."IDYS Cost Center");
                        TransportWorksheetLine.Validate("Account No.", PurchaseHeader."IDYS Account No.");
                        TransportWorksheetLine.Validate("Account No. (Invoice)", PurchaseHeader."IDYS Acc. No. (Bill-to)");
                    end;
                    if IDYSAddressType = IDYSAddressType::"Invoice" then
                        FillInvoiceAddrFromCompanyInfo(TransportWorksheetLine);
                end;
            WarehouseShipmentLine."Source Document"::"Service Order":
                begin
                    ServiceHeader.Get(WarehouseShipmentLine."Source Subtype", WarehouseShipmentLine."Source No.");
                    FillAddressFromServiceOrder(TransportWorksheetLine, ServiceHeader, IDYSAddressType);
                    if IDYSAddressType = IDYSAddressType::"Ship-to" then begin
                        TransportWorksheetLine.Validate("E-Mail Type", ServiceHeader."IDYS E-Mail Type");
                        TransportWorksheetLine.Validate("Cost Center", ServiceHeader."IDYS Cost Center");
                        TransportWorksheetLine.Validate("Account No.", ServiceHeader."IDYS Account No.");
                        TransportWorksheetLine.Validate("Account No. (Invoice)", ServiceHeader."IDYS Account No. (Bill-to)");
                    end;
                end;
            WarehouseShipmentLine."Source Document"::"Outbound Transfer":
                begin
                    TransferHeader.Get(WarehouseShipmentLine."Source No.");
                    Location.Get(TransferHeader."Transfer-from Code");
                    if IDYSAddressType = IDYSAddressType::"Ship-to" then begin
                        FillAddressFromTransferOrder(TransportWorksheetLine, TransferHeader, Location, IDYSAddressType);
                        TransportWorksheetLine.Validate("E-Mail Type", TransferHeader."IDYS E-Mail Type");
                        TransportWorksheetLine.Validate("Cost Center", TransferHeader."IDYS Cost Center");
                        TransportWorksheetLine.Validate("Account No.", TransferHeader."IDYS Account No. (Ship-to)");
                        TransportWorksheetLine.Validate("Account No. (Pick-up)", TransferHeader."IDYS Account No.");  // Pick-up
                    end;
                    if IDYSAddressType = IDYSAddressType::Invoice then
                        FillInvoiceAddrFromCompanyInfo(TransportWorksheetLine);
                end;
        end;
    end;

    local procedure FillInvoiceAddrFromCompanyInfo(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line");
    begin
        TransportWorksheetLine.Validate("Source Type (Invoice)", TransportWorksheetLine."Source Type (Invoice)"::Company);
        TransportWorksheetLine.Validate("Name (Invoice)", CompanyInformation.Name);
        TransportWorksheetLine.Validate("Address (Invoice)", CompanyInformation.Address);
        TransportWorksheetLine.Validate("Address 2 (Invoice)", CompanyInformation."Address 2");
        TransportWorksheetLine.Validate("City (Invoice)", CompanyInformation.City);
        TransportWorksheetLine.Validate("Post Code (Invoice)", CompanyInformation."Post Code");
        TransportWorksheetLine.Validate("County (Invoice)", CompanyInformation.County);
        TransportWorksheetLine.Validate("Country/Region Code (Invoice)", CompanyInformation."Country/Region Code");
        TransportWorksheetLine.Validate("Phone No. (Invoice)", CompanyInformation."Phone No.");
        TransportWorksheetLine.Validate("Fax No. (Invoice)", CompanyInformation."Fax No.");
        TransportWorksheetLine.Validate("E-Mail (Invoice)", CompanyInformation."E-Mail");
        TransportWorksheetLine.Validate("VAT Registration No. (Invoice)", CompanyInformation."VAT Registration No.");
#if not BC17EORI
        TransportWorksheetLine.Validate("EORI Number (Invoice)", CompanyInformation."EORI Number");
#endif
    end;

    local procedure FillShipToAddrFromReturnShipmentHeader(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; ReturnShipmentHeader: Record "Return Shipment Header")
    var
        Vendor: Record Vendor;
        OrderAddress: Record "Order Address";
    begin
        TransportWorksheetLine.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)"::Vendor);
        TransportWorksheetLine.Validate("No. (Ship-to)", ReturnShipmentHeader."Buy-from Vendor No.");
        TransportWorksheetLine.Validate("Code (Ship-to)", ReturnShipmentHeader."Order Address Code");
        TransportWorksheetLine.Validate("Name (Ship-to)", ReturnShipmentHeader."Ship-to Name");
        TransportWorksheetLine.Validate("Address (Ship-to)", ReturnShipmentHeader."Ship-to Address");
        TransportWorksheetLine.Validate("Address 2 (Ship-to)", ReturnShipmentHeader."Ship-to Address 2");
        TransportWorksheetLine.Validate("City (Ship-to)", ReturnShipmentHeader."Ship-to City");
        TransportWorksheetLine.Validate("Post Code (Ship-to)", ReturnShipmentHeader."Ship-to Post Code");
        TransportWorksheetLine.Validate("County (Ship-to)", ReturnShipmentHeader."Ship-to County");
        TransportWorksheetLine.Validate("Country/Region Code (Ship-to)", ReturnShipmentHeader."Ship-to Country/Region Code");
        TransportWorksheetLine.Validate("Contact (Ship-to)", ReturnShipmentHeader."Ship-to Contact");
        TransportWorksheetLine.Validate("VAT Registration No. (Ship-to)", ReturnShipmentHeader."VAT Registration No.");
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
        TransportWorksheetLine.Validate("Phone No. (Ship-to)", ReturnShipmentHeader."Ship-to Phone No.");
#endif
        case true of
            OrderAddress.Get(ReturnShipmentHeader."Buy-from Vendor No.", ReturnShipmentHeader."Order Address Code"):
                begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", OrderAddress."Phone No.");
#endif
                    TransportWorksheetLine.Validate("Fax No. (Ship-to)", OrderAddress."Fax No.");
                    TransportWorksheetLine.Validate("E-Mail (Ship-to)", OrderAddress."E-Mail");
                    Vendor.Get(ReturnShipmentHeader."Buy-from Vendor No.");
                    TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Vendor."Mobile Phone No.");
#if not BC17EORI
                    TransportWorksheetLine.Validate("EORI Number (Ship-to)", Vendor."EORI Number");
#endif
                end;
            Vendor.Get(ReturnShipmentHeader."Buy-from Vendor No."):
                begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
                    TransportWorksheetLine.Validate("Phone No. (Ship-to)", Vendor."Phone No.");
#endif
                    TransportWorksheetLine.Validate("Fax No. (Ship-to)", Vendor."Fax No.");
                    TransportWorksheetLine.Validate("E-Mail (Ship-to)", Vendor."E-Mail");
                    TransportWorksheetLine.Validate("Mobile Phone No. (Ship-to)", Vendor."Mobile Phone No.");
#if not BC17EORI
                    TransportWorksheetLine.Validate("EORI Number (Ship-to)", Vendor."EORI Number");
#endif
                end;
        end;
    end;

    procedure FinalizeTransportWorksheetLine(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    var
        ProviderCarrier: Record "IDYS Provider Carrier";
        SourceDocumentService: Record "IDYS Source Document Service";
    begin
        TransportWorksheetLine.Include := true;

        // Copy Service Levels
        if ProviderCarrier.Get(TransportWorksheetLine."Carrier Entry No.") then
            if ProviderCarrier.Provider = ProviderCarrier.Provider::"Delivery Hub" then
                SourceDocumentService.CopyServiceLevels(TransportWorksheetLine."Source Document Table No.",
                                                        TransportWorksheetLine."Source Document Type",
                                                        TransportWorksheetLine."Source Document No.",
                                                        Database::"IDYS Transport Worksheet Line",
                                                        TransportWorksheetLine."Source Document Type",
                                                        TransportWorksheetLine."Source Document No.");

        TransportWorksheetLine.UpdateInclude();
        TransportWorksheetLine.Insert(true);
        if TransportWorksheetLine.Include = false then begin
            ErrorMessage := TransportWorksheetLine.GetErrorMessage();
            exit(false);
        end;
        exit(true)
    end;

    local procedure GetLocationAndCompanyInformation(LocationCode: code[10]; var Location: Record Location): Boolean;
    begin
        CompanyInformation.Get();
        Clear(Location);
        if Location.Get(LocationCode) then
            exit(true);
        Location.Name := CompanyInformation.Name;
        Location.Address := CompanyInformation.Address;
        Location."Address 2" := CompanyInformation."Address 2";
        Location.City := CompanyInformation.City;
        Location."Post Code" := CompanyInformation."Post Code";
        Location.County := CompanyInformation.County;
        Location."Country/Region Code" := CompanyInformation."Country/Region Code";
        Location."Phone No." := CompanyInformation."Phone No.";
        Location."Phone No. 2" := CompanyInformation."Phone No. 2";
        Location."Fax No." := CompanyInformation."Fax No.";
        Location."E-Mail" := CompanyInformation."E-Mail";
        Location.Contact := CompanyInformation."Contact Person";
        Location."IDYS Account No." := CompanyInformation."IDYS Account No.";

        exit(false);
    end;

    local procedure GetPlannedDeliveryDate(ShipmentDate: Date; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; WarehouseShipmentLine: Record "Warehouse Shipment Line"): Date;
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        PlannedReceiptDate: Date;
    begin
        WarehouseShipmentHeader.TestField("Shipping Agent Code");
        WarehouseShipmentHeader.TestField("Shipping Agent Service Code");
        WarehouseShipmentLine.TestField("Shipment Date");

        if ShippingAgentServices.Get(WarehouseShipmentHeader."Shipping Agent Code", WarehouseShipmentHeader."Shipping Agent Service Code") then;
        TransferRoute.CalcPlannedReceiptDateForward(ShipmentDate, PlannedReceiptDate, ShippingAgentServices."Shipping Time", WarehouseShipmentLine."Location Code", WarehouseShipmentHeader."Shipping Agent Code", WarehouseShipmentHeader."Shipping Agent Service Code");
        exit(PlannedReceiptDate);
    end;

    procedure GetErrorMessage(): Text
    begin
        exit(ErrorMessage);
    end;

    #region [Obsolete]
    [Obsolete('Replaced with local procedure', '19.7')]
    procedure GetLocationAndCompanyInfo(LocationCode: code[10]; var Location: Record Location; var CompanyInfo: Record "Company Information"): Boolean;
    begin
    end;

    [Obsolete('Removed due to wrongfully implemented flow', '21.0')]
    procedure FromPostedReturnReceiptLine(ReturnReceiptLine: Record "Return Receipt Line"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Boolean
    begin
    end;

    [Obsolete('No longer using the preferred date fields on the ReturnShipment that must be filled in manually', '18.5')]
    procedure FromReturnShipmentLine(ReturnShipmentLine: Record "Return Shipment Line"; ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10]; PreferredPickupDate: Date; PreferredDeliveryDate: Date; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): boolean
    begin
    end;
    #endregion

    var
        CompanyInformation: Record "Company Information";
        IDYSSetup: Record "IDYS Setup";
        TransferRoute: Record "Transfer Route";
        IDYSPublisher: Codeunit "IDYS Publisher";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        SkipCheckServiceLevel: Boolean;
        ErrorMessage: Text;
        NoServiceLevelTok: Label 'b40a6ae9-6688-4b07-a0ec-c3f0c8ce8822', Locked = true;
        NoServiceLevelMsg: Label 'No service level was found for shipping agent %1 and shipping agent service %2.', Comment = '%1=shipping agent,%2=service';
        QtyToSendCannotBeZeroOrBelowErr: Label '%1 cannot be zero or below zero.', Comment = '%1 is fieldcaption IDYS Qty. to Send';
}