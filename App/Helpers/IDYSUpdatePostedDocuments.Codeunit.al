codeunit 11147691 "IDYS Update Posted Documents"
{
    Permissions =
        tabledata "Sales Header" = im,
        tabledata "Sales Line" = im,
        tabledata "Purchase Header" = im,
        tabledata "Purchase Line" = im,
        tabledata "Service Header" = im,
        tabledata "Service Line" = im,
        tabledata "Transfer Header" = im,
        tabledata "Transfer Line" = im,
        tabledata "Warehouse Shipment Line" = im,
        tabledata "Sales Shipment Header" = im,
        tabledata "Sales Shipment Line" = im,
        tabledata "Return Receipt Header" = im,
        tabledata "Return Receipt Line" = im,
        tabledata "Return Shipment Header" = im,
        tabledata "Return Shipment Line" = im,
        tabledata "Service Shipment Header" = im,
        tabledata "Service Shipment Line" = im,
        tabledata "Transfer Shipment Header" = im,
        tabledata "Transfer Shipment Line" = im;

    procedure UpdateSalesDocumentTrackingInfo(var SalesHeader: Record "Sales Header"; SalesLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    var
        SalesLine: Record "Sales Line";
        xSalesHeader: Record "Sales Header";
        xSalesLine: Record "Sales Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateSalesDocumentTrackingInfo(SalesHeader, SalesLineNo, IDYSTransportOrderHeader, UpdateHeader, IsHandled);
        if IsHandled then
            exit;

        xSalesHeader := SalesHeader;

        if UpdateHeader then begin
#pragma warning disable AL0432
            SalesHeader."Package Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(SalesHeader."Package Tracking No."));
#pragma warning restore AL0432
            SalesHeader."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(SalesHeader."IDYS Tracking No."));
            SalesHeader."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(SalesHeader."IDYS Tracking URL"));
            SalesHeader."Shipment Method Code" := IDYSTransportOrderHeader."Shipment Method Code";
            SalesHeader."Shipping Agent Code" := IDYSTransportOrderHeader."Shipping Agent Code"; //std BC does this as well without validation when posting warehouse shipments
            SalesHeader."Shipping Agent Service Code" := IDYSTransportOrderHeader."Shipping Agent Service Code";

#pragma warning disable AL0432
            if (xSalesHeader."Package Tracking No." <> SalesHeader."Package Tracking No.") or
#pragma warning restore AL0432
                (xSalesHeader."IDYS Tracking No." <> SalesHeader."IDYS Tracking No.") or
                (xSalesHeader."IDYS Tracking URL" <> SalesHeader."IDYS Tracking URL") or
                (xSalesHeader."Shipment Method Code" <> SalesHeader."Shipment Method Code") or
                (xSalesHeader."Shipping Agent Code" <> SalesHeader."Shipping Agent Code") or
                (xSalesHeader."Shipping Agent Service Code" <> SalesHeader."Shipping Agent Service Code")
            then
                SalesHeader.Modify();
        end;

        if (SalesLineNo <> 0) and SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", SalesLineNo) then begin
            xSalesLine := SalesLine;
            SalesLine."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(SalesLine."IDYS Tracking No."));
            SalesLine."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(SalesLine."IDYS Tracking URL"));

            if (xSalesLine."IDYS Tracking No." <> SalesLine."IDYS Tracking No.") or
                (xSalesLine."IDYS Tracking URL" <> SalesLine."IDYS Tracking URL")
            then
                SalesLine.Modify();
        end;

        OnAfterUpdateSalesDocumentTrackingInfo(SalesHeader, SalesLineNo, IDYSTransportOrderHeader, UpdateHeader);
    end;

    procedure UpdatePurchaseDocumentTrackingInfo(var PurchaseHeader: Record "Purchase Header"; PurchaseLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    var
        PurchaseLine: Record "Purchase Line";
        xPurchaseHeader: Record "Purchase Header";
        xPurchaseLine: Record "Purchase Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdatePurchaseDocumentTrackingInfo(PurchaseHeader, PurchaseLineNo, IDYSTransportOrderHeader, UpdateHeader, IsHandled);
        if IsHandled then
            exit;

        xPurchaseHeader := PurchaseHeader;

        if UpdateHeader then begin
            PurchaseHeader."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(PurchaseHeader."IDYS Tracking No."));
            PurchaseHeader."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(PurchaseHeader."IDYS Tracking URL"));
            PurchaseHeader."Shipment Method Code" := IDYSTransportOrderHeader."Shipment Method Code";
            PurchaseHeader."IDYS Shipping Agent Code" := IDYSTransportOrderHeader."Shipping Agent Code"; //std BC does this as well without validation when posting warehouse shipments
            PurchaseHeader."IDYS Shipping Agent Srv Code" := IDYSTransportOrderHeader."Shipping Agent Service Code";

            if (xPurchaseHeader."IDYS Tracking No." <> PurchaseHeader."IDYS Tracking No.") or
                (xPurchaseHeader."IDYS Tracking URL" <> PurchaseHeader."IDYS Tracking URL") or
                (xPurchaseHeader."Shipment Method Code" <> PurchaseHeader."Shipment Method Code") or
                (xPurchaseHeader."IDYS Shipping Agent Code" <> PurchaseHeader."IDYS Shipping Agent Code") or
                (xPurchaseHeader."IDYS Shipping Agent Srv Code" <> PurchaseHeader."IDYS Shipping Agent Srv Code")
            then
                PurchaseHeader.Modify();
        end;

        if (PurchaseLineNo <> 0) and PurchaseLine.Get(PurchaseHeader."Document Type", PurchaseHeader."No.", PurchaseLineNo) then begin
            xPurchaseLine := PurchaseLine;
            PurchaseLine."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(PurchaseLine."IDYS Tracking No."));
            PurchaseLine."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(PurchaseLine."IDYS Tracking URL"));

            if (xPurchaseLine."IDYS Tracking No." <> PurchaseLine."IDYS Tracking No.") or
                (xPurchaseLine."IDYS Tracking URL" <> PurchaseLine."IDYS Tracking URL")
            then
                PurchaseLine.Modify();
        end;

        OnAfterUpdatePurchaseDocumentTrackingInfo(PurchaseHeader, PurchaseLineNo, IDYSTransportOrderHeader, UpdateHeader);
    end;

    procedure UpdateTransferOrderTrackingInfo(var TransferHeader: Record "Transfer Header"; TransferLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    var
        TransferLine: Record "Transfer Line";
        xTransferHeader: Record "Transfer Header";
        xTransferLine: Record "Transfer Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateTransferOrderTrackingInfo(TransferHeader, TransferLineNo, IDYSTransportOrderHeader, UpdateHeader, IsHandled);
        if IsHandled then
            exit;

        xTransferHeader := TransferHeader;

        if UpdateHeader then begin
            TransferHeader."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(TransferHeader."IDYS Tracking No."));
            TransferHeader."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(TransferHeader."IDYS Tracking URL"));
            TransferHeader."Shipment Method Code" := IDYSTransportOrderHeader."Shipment Method Code";
            TransferHeader."Shipping Agent Code" := IDYSTransportOrderHeader."Shipping Agent Code"; //std BC does this as well without validation when posting warehouse shipments
            TransferHeader."Shipping Agent Service Code" := IDYSTransportOrderHeader."Shipping Agent Service Code";

            if (xTransferHeader."IDYS Tracking No." <> TransferHeader."IDYS Tracking No.") or
                (xTransferHeader."IDYS Tracking URL" <> TransferHeader."IDYS Tracking URL") or
                (xTransferHeader."Shipment Method Code" <> TransferHeader."Shipment Method Code") or
                (xTransferHeader."Shipping Agent Code" <> TransferHeader."Shipping Agent Code") or
                (xTransferHeader."Shipping Agent Service Code" <> TransferHeader."Shipping Agent Service Code")
            then
                TransferHeader.Modify();
        end;

        if (TransferLineNo <> 0) and TransferLine.Get(TransferHeader."No.", TransferLineNo) then begin
            xTransferLine := TransferLine;
            TransferLine."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(TransferLine."IDYS Tracking No."));
            TransferLine."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(TransferLine."IDYS Tracking URL"));

            if (xTransferLine."IDYS Tracking No." <> TransferLine."IDYS Tracking No.") or
                (xTransferLine."IDYS Tracking URL" <> TransferLine."IDYS Tracking URL")
            then
                TransferLine.Modify();
        end;

        OnAfterUpdateTransferOrderTrackingInfo(TransferHeader, TransferLineNo, IDYSTransportOrderHeader, UpdateHeader);
    end;

    procedure UpdateServiceOrderTrackingInfo(var ServiceHeader: Record "Service Header"; ServiceLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    var
        ServiceLine: Record "Service Line";
        xServiceHeader: Record "Service Header";
        xServiceLine: Record "Service Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateServiceOrderTrackingInfo(ServiceHeader, ServiceLineNo, IDYSTransportOrderHeader, UpdateHeader, IsHandled);
        if IsHandled then
            exit;

        xServiceHeader := ServiceHeader;

        if UpdateHeader then begin
            ServiceHeader."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(ServiceHeader."IDYS Tracking No."));
            ServiceHeader."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(ServiceHeader."IDYS Tracking URL"));
            ServiceHeader."Shipment Method Code" := IDYSTransportOrderHeader."Shipment Method Code";
            ServiceHeader."Shipping Agent Code" := IDYSTransportOrderHeader."Shipping Agent Code"; //std BC does this as well without validation when posting warehouse shipments
            ServiceHeader."Shipping Agent Service Code" := IDYSTransportOrderHeader."Shipping Agent Service Code";

            if (xServiceHeader."IDYS Tracking No." <> ServiceHeader."IDYS Tracking No.") or
                (xServiceHeader."IDYS Tracking URL" <> ServiceHeader."IDYS Tracking URL") or
                (xServiceHeader."Shipment Method Code" <> ServiceHeader."Shipment Method Code") or
                (xServiceHeader."Shipping Agent Code" <> ServiceHeader."Shipping Agent Code") or
                (xServiceHeader."Shipping Agent Service Code" <> ServiceHeader."Shipping Agent Service Code")
            then
                ServiceHeader.Modify();
        end;

        if (ServiceLineNo <> 0) and ServiceLine.Get(ServiceHeader."Document Type", ServiceHeader."No.", ServiceLineNo) then begin
            xServiceLine := ServiceLine;
            ServiceLine."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(ServiceLine."IDYS Tracking No."));
            ServiceLine."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(ServiceLine."IDYS Tracking URL"));

            if (xServiceLine."IDYS Tracking No." <> ServiceLine."IDYS Tracking No.") or
                (xServiceLine."IDYS Tracking URL" <> ServiceLine."IDYS Tracking URL")
            then
                ServiceLine.Modify();
        end;

        OnAfterUpdateServiceOrderTrackingInfo(ServiceHeader, ServiceLineNo, IDYSTransportOrderHeader, UpdateHeader);
    end;

    [Obsolete('Added Parameters', '19.6')]
    procedure UpdateSalesShipmentTrackingInfo(var SalesShipmentHeader: Record "Sales Shipment Header"; IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    procedure UpdateSalesShipmentTrackingInfo(var SalesShipmentHeader: Record "Sales Shipment Header"; SalesShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        xSalesShipmentHeader: Record "Sales Shipment Header";
        xSalesShipmentLine: Record "Sales Shipment Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateSalesShipmentTrackingInfo(SalesShipmentHeader, SalesShipmentLineNo, IDYSTransportOrderHeader, UpdateHeader, IsHandled);
        if IsHandled then
            exit;

        xSalesShipmentHeader := SalesShipmentHeader;

        if UpdateHeader then begin
#pragma warning disable AL0432
            SalesShipmentHeader."Package Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(SalesShipmentHeader."Package Tracking No."));
#pragma warning restore AL0432
            SalesShipmentHeader."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(SalesShipmentHeader."IDYS Tracking No."));
            SalesShipmentHeader."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(SalesShipmentHeader."IDYS Tracking URL"));
            SalesShipmentHeader."Shipment Method Code" := IDYSTransportOrderHeader."Shipment Method Code";
            SalesShipmentHeader."Shipping Agent Code" := IDYSTransportOrderHeader."Shipping Agent Code";
            SalesShipmentHeader."Shipping Agent Service Code" := IDYSTransportOrderHeader."Shipping Agent Service Code";

#pragma warning disable AL0432
            if (xSalesShipmentHeader."Package Tracking No." <> SalesShipmentHeader."Package Tracking No.") or
#pragma warning restore AL0432
                (xSalesShipmentHeader."IDYS Tracking No." <> SalesShipmentHeader."IDYS Tracking No.") or
                (xSalesShipmentHeader."IDYS Tracking URL" <> SalesShipmentHeader."IDYS Tracking URL") or
                (xSalesShipmentHeader."Shipment Method Code" <> SalesShipmentHeader."Shipment Method Code") or
                (xSalesShipmentHeader."Shipping Agent Code" <> SalesShipmentHeader."Shipping Agent Code") or
                (xSalesShipmentHeader."Shipping Agent Service Code" <> SalesShipmentHeader."Shipping Agent Service Code")
            then
                SalesShipmentHeader.Modify();
        end;

        if (SalesShipmentLineNo <> 0) and SalesShipmentLine.Get(SalesShipmentHeader."No.", SalesShipmentLineNo) then begin
            xSalesShipmentLine := SalesShipmentLine;
            SalesShipmentLine."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(SalesShipmentLine."IDYS Tracking No."));
            SalesShipmentLine."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(SalesShipmentLine."IDYS Tracking URL"));

            if (xSalesShipmentLine."IDYS Tracking No." <> SalesShipmentLine."IDYS Tracking No.") or
                (xSalesShipmentLine."IDYS Tracking URL" <> SalesShipmentLine."IDYS Tracking URL")
            then
                SalesShipmentLine.Modify();
        end;

        OnAfterUpdateSalesShipmentTrackingInfo(SalesShipmentHeader, SalesShipmentLineNo, IDYSTransportOrderHeader, UpdateHeader);
    end;

    [Obsolete('Removed due to wrongfully implemented flow', '21.0')]
    procedure UpdateReturnReceiptTrackingInfo(var ReturnReceiptHeader: Record "Return Receipt Header"; ReturnReceiptLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    begin
    end;

    procedure UpdateReturnShipmentTrackingInfo(var ReturnShipmentHeader: Record "Return Shipment Header"; ReturnShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    var
        ReturnShipmentLine: Record "Return Shipment Line";
        xReturnShipmentHeader: Record "Return Shipment Header";
        xReturnShipmentLine: Record "Return Shipment Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateReturnShipmentTrackingInfo(ReturnShipmentHeader, ReturnShipmentLineNo, IDYSTransportOrderHeader, UpdateHeader, IsHandled);
        if IsHandled then
            exit;

        xReturnShipmentHeader := ReturnShipmentHeader;

        if UpdateHeader then begin
            ReturnShipmentHeader."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(ReturnShipmentHeader."IDYS Tracking No."));
            ReturnShipmentHeader."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(ReturnShipmentHeader."IDYS Tracking URL"));
            ReturnShipmentHeader."Shipment Method Code" := IDYSTransportOrderHeader."Shipment Method Code";
            ReturnShipmentHeader."IDYS Shipping Agent Code" := IDYSTransportOrderHeader."Shipping Agent Code";
            ReturnShipmentHeader."IDYS Shipping Agent Srv Code" := IDYSTransportOrderHeader."Shipping Agent Service Code";

            if (xReturnShipmentHeader."IDYS Tracking No." <> ReturnShipmentHeader."IDYS Tracking No.") or
                (xReturnShipmentHeader."IDYS Tracking URL" <> ReturnShipmentHeader."IDYS Tracking URL") or
                (xReturnShipmentHeader."Shipment Method Code" <> ReturnShipmentHeader."Shipment Method Code") or
                (xReturnShipmentHeader."IDYS Shipping Agent Code" <> ReturnShipmentHeader."IDYS Shipping Agent Code") or
                (xReturnShipmentHeader."IDYS Shipping Agent Srv Code" <> ReturnShipmentHeader."IDYS Shipping Agent Srv Code")
            then
                ReturnShipmentHeader.Modify();
        end;

        if (ReturnShipmentLineNo <> 0) and ReturnShipmentLine.Get(ReturnShipmentHeader."No.", ReturnShipmentLineNo) then begin
            xReturnShipmentLine := ReturnShipmentLine;
            ReturnShipmentLine."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(ReturnShipmentLine."IDYS Tracking No."));
            ReturnShipmentLine."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(ReturnShipmentLine."IDYS Tracking URL"));

            if (xReturnShipmentLine."IDYS Tracking No." <> ReturnShipmentLine."IDYS Tracking No.") or
                (xReturnShipmentLine."IDYS Tracking URL" <> ReturnShipmentLine."IDYS Tracking URL")
            then
                ReturnShipmentLine.Modify();
        end;

        OnAfterUpdateReturnShipmentTrackingInfo(ReturnShipmentHeader, ReturnShipmentLineNo, IDYSTransportOrderHeader, UpdateHeader);
    end;

    procedure UpdateTransferShipmentTrackingInfo(var TransferShipmentHeader: Record "Transfer Shipment Header"; TransferShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        xTransferShipmentHeader: Record "Transfer Shipment Header";
        xTransferShipmentLine: Record "Transfer Shipment Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateTransferShipmentTrackingInfo(TransferShipmentHeader, TransferShipmentLineNo, IDYSTransportOrderHeader, UpdateHeader, IsHandled);
        if IsHandled then
            exit;

        xTransferShipmentHeader := TransferShipmentHeader;

        if UpdateHeader then begin
            TransferShipmentHeader."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(TransferShipmentHeader."IDYS Tracking No."));
            TransferShipmentHeader."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(TransferShipmentHeader."IDYS Tracking URL"));
            TransferShipmentHeader."Shipment Method Code" := IDYSTransportOrderHeader."Shipment Method Code";
            TransferShipmentHeader."Shipping Agent Code" := IDYSTransportOrderHeader."Shipping Agent Code";
            TransferShipmentHeader."Shipping Agent Service Code" := IDYSTransportOrderHeader."Shipping Agent Service Code";

            if (xTransferShipmentHeader."IDYS Tracking No." <> TransferShipmentHeader."IDYS Tracking No.") or
                (xTransferShipmentHeader."IDYS Tracking URL" <> TransferShipmentHeader."IDYS Tracking URL") or
                (xTransferShipmentHeader."Shipment Method Code" <> TransferShipmentHeader."Shipment Method Code") or
                (xTransferShipmentHeader."Shipping Agent Code" <> TransferShipmentHeader."Shipping Agent Code") or
                (xTransferShipmentHeader."Shipping Agent Service Code" <> TransferShipmentHeader."Shipping Agent Service Code")
            then
                TransferShipmentHeader.Modify();
        end;

        if (TransferShipmentLineNo <> 0) and TransferShipmentLine.Get(TransferShipmentHeader."No.", TransferShipmentLineNo) then begin
            xTransferShipmentLine := TransferShipmentLine;
            TransferShipmentLine."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(TransferShipmentLine."IDYS Tracking No."));
            TransferShipmentLine."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(TransferShipmentLine."IDYS Tracking URL"));

            if (xTransferShipmentLine."IDYS Tracking No." <> TransferShipmentLine."IDYS Tracking No.") or
                (xTransferShipmentLine."IDYS Tracking URL" <> TransferShipmentLine."IDYS Tracking URL")
            then
                TransferShipmentLine.Modify();
        end;

        OnAfterUpdateTransferShipmentTrackingInfo(TransferShipmentHeader, TransferShipmentLineNo, IDYSTransportOrderHeader, UpdateHeader);
    end;

    procedure UpdateTransferReceiptTrackingInfo(var TransferReceiptHeader: Record "Transfer Receipt Header"; TransferReceiptLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
        xTransferReceiptHeader: Record "Transfer Receipt Header";
        xTransferReceiptLine: Record "Transfer Receipt Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateTransferReceiptTrackingInfo(TransferReceiptHeader, TransferReceiptLineNo, IDYSTransportOrderHeader, UpdateHeader, IsHandled);
        if IsHandled then
            exit;

        xTransferReceiptHeader := TransferReceiptHeader;

        if UpdateHeader then begin
            TransferReceiptHeader."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(TransferReceiptHeader."IDYS Tracking No."));
            TransferReceiptHeader."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(TransferReceiptHeader."IDYS Tracking URL"));
            TransferReceiptHeader."Shipment Method Code" := IDYSTransportOrderHeader."Shipment Method Code";
            TransferReceiptHeader."Shipping Agent Code" := IDYSTransportOrderHeader."Shipping Agent Code";
            TransferReceiptHeader."Shipping Agent Service Code" := IDYSTransportOrderHeader."Shipping Agent Service Code";

            if (xTransferReceiptHeader."IDYS Tracking No." <> TransferReceiptHeader."IDYS Tracking No.") or
                (xTransferReceiptHeader."IDYS Tracking URL" <> TransferReceiptHeader."IDYS Tracking URL") or
                (xTransferReceiptHeader."Shipment Method Code" <> TransferReceiptHeader."Shipment Method Code") or
                (xTransferReceiptHeader."Shipping Agent Code" <> TransferReceiptHeader."Shipping Agent Code") or
                (xTransferReceiptHeader."Shipping Agent Service Code" <> TransferReceiptHeader."Shipping Agent Service Code")
            then
                TransferReceiptHeader.Modify();
        end;

        if (TransferReceiptLineNo <> 0) and TransferReceiptLine.Get(TransferReceiptHeader."No.", TransferReceiptLineNo) then begin
            xTransferReceiptLine := TransferReceiptLine;
            TransferReceiptLine."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(TransferReceiptLine."IDYS Tracking No."));
            TransferReceiptLine."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(TransferReceiptLine."IDYS Tracking URL"));

            if (xTransferReceiptLine."IDYS Tracking No." <> TransferReceiptLine."IDYS Tracking No.") or
                (xTransferReceiptLine."IDYS Tracking URL" <> TransferReceiptLine."IDYS Tracking URL")
            then
                TransferReceiptLine.Modify();
        end;

        OnAfterUpdateTransferReceiptTrackingInfo(TransferReceiptHeader, TransferReceiptLineNo, IDYSTransportOrderHeader, UpdateHeader);
    end;

    procedure UpdateServiceShipmentTrackingInfo(var ServiceShipmentHeader: Record "Service Shipment Header"; ServiceShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean);
    var
        ServiceShipmentLine: Record "Service Shipment Line";
        xServiceShipmentHeader: Record "Service Shipment Header";
        xServiceShipmentLine: Record "Service Shipment Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateServiceShipmentTrackingInfo(ServiceShipmentHeader, ServiceShipmentLineNo, IDYSTransportOrderHeader, UpdateHeader, IsHandled);
        if IsHandled then
            exit;

        xServiceShipmentHeader := ServiceShipmentHeader;

        if UpdateHeader then begin
            ServiceShipmentHeader."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(ServiceShipmentHeader."IDYS Tracking No."));
            ServiceShipmentHeader."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(ServiceShipmentHeader."IDYS Tracking URL"));
            ServiceShipmentHeader."IDYS Shipment Method Code" := IDYSTransportOrderHeader."Shipment Method Code";
            ServiceShipmentHeader."IDYS Shipping Agent Code" := IDYSTransportOrderHeader."Shipping Agent Code";
            ServiceShipmentHeader."IDYS Shipping Agent Srv Code" := IDYSTransportOrderHeader."Shipping Agent Service Code";

            if (xServiceShipmentHeader."IDYS Tracking No." <> ServiceShipmentHeader."IDYS Tracking No.") or
                (xServiceShipmentHeader."IDYS Tracking URL" <> ServiceShipmentHeader."IDYS Tracking URL") or
                (xServiceShipmentHeader."IDYS Shipment Method Code" <> ServiceShipmentHeader."IDYS Shipment Method Code") or
                (xServiceShipmentHeader."IDYS Shipping Agent Code" <> ServiceShipmentHeader."IDYS Shipping Agent Code") or
                (xServiceShipmentHeader."IDYS Shipping Agent Srv Code" <> ServiceShipmentHeader."IDYS Shipping Agent Srv Code")
            then
                ServiceShipmentHeader.Modify();
        end;

        if (ServiceShipmentLineNo <> 0) and ServiceShipmentLine.Get(ServiceShipmentHeader."No.", ServiceShipmentLineNo) then begin
            xServiceShipmentLine := ServiceShipmentLine;
            ServiceShipmentLine."IDYS Tracking No." := CopyStr(IDYSTransportOrderHeader."Tracking No.", 1, MaxStrLen(ServiceShipmentLine."IDYS Tracking No."));
            ServiceShipmentLine."IDYS Tracking URL" := CopyStr(IDYSTransportOrderHeader."Tracking Url", 1, MaxStrLen(ServiceShipmentLine."IDYS Tracking URL"));

            if (xServiceShipmentLine."IDYS Tracking No." <> xServiceShipmentLine."IDYS Tracking No.") or
                (xServiceShipmentLine."IDYS Tracking URL" <> xServiceShipmentLine."IDYS Tracking URL")
            then
                ServiceShipmentLine.Modify();
        end;

        OnAfterUpdateServiceShipmentTrackingInfo(ServiceShipmentHeader, ServiceShipmentLineNo, IDYSTransportOrderHeader, UpdateHeader);
    end;

    procedure UpdateQtyToSendOnDocs(TransportOrderLine: Record "IDYS Transport Order Line");
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        TransferLine: Record "Transfer Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        ServiceShipmentLine: Record "Service Shipment Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferReceiptLine: Record "Transfer Receipt Line";
        ConvertedTableId: Integer;
        IsHandled: Boolean;
    begin
        OnBeforeUpdateQtyToSendOnDocs(TransportOrderLine, IsHandled);
        if IsHandled then
            exit;

        case TransportOrderLine."Source Document Table No." of
            Database::"Sales Header":
                if SalesLine.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    UpdateQtyToSendOnSalesLine(SalesLine);
                    ConvertedTableId := Database::"Sales Line";
                end;
            Database::"Purchase Header":
                if PurchaseLine.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    UpdateQtyToSendOnPurchaseLine(PurchaseLine);
                    ConvertedTableId := Database::"Purchase Line";
                end;
            Database::"Service Header":
                if ServiceLine.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    UpdateQtyToSendOnServiceLine(ServiceLine);
                    ConvertedTableId := Database::"Service Line";
                end;
            Database::"Transfer Header":
                if TransferLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    UpdateQtyToSendOnTransferLine(TransferLine);
                    ConvertedTableId := Database::"Transfer Line";
                end;
            Database::"Sales Shipment Header":
                if SalesShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then
                    UpdateQtyToSendOnSalesShipmentLine(SalesShipmentLine);
            Database::"Return Shipment Header":
                if ReturnShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then
                    UpdateQtyToSendOnReturnShipmentLine(ReturnShipmentLine);
            Database::"Service Shipment Header":
                if ServiceShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then
                    UpdateQtyToSendOnServiceShipmentLine(ServiceShipmentLine);
            Database::"Transfer Shipment Header":
                if TransferShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then
                    UpdateQtyToSendOnTransferShipmentLine(TransferShipmentLine);
            Database::"Transfer Receipt Header":
                if TransferReceiptLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then
                    UpdateQtyToSendOnTransferReceiptLine(TransferReceiptLine);
        end;
        if ConvertedTableId <> 0 then begin
            WarehouseShipmentLine.SetSourceFilter(ConvertedTableId, TransportOrderLine."Source Document Type".AsInteger(), TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.", true);
            if WarehouseShipmentLine.FindSet(true) then
                repeat
                    UpdateQtyToSendOnWarehouseShipmentLine(WarehouseShipmentLine);
                until WarehouseShipmentLine.Next() = 0;
        end;
    end;

    procedure ResetQtyToSendOnDocs(TransportOrderLine: Record "IDYS Transport Order Line");
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        TransferLine: Record "Transfer Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        ServiceShipmentLine: Record "Service Shipment Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferReceiptLine: Record "Transfer Receipt Line";
        ConvertedTableId: Integer;
        IsHandled: Boolean;
    begin
        OnBeforeResetQtyToSendOnDocs(TransportOrderLine, IsHandled);
        if IsHandled then
            exit;

        case TransportOrderLine."Source Document Table No." of
            Database::"Sales Header":
                if SalesLine.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    UpdateQtyToSendOnSalesLine(SalesLine);
                    ConvertedTableId := Database::"Sales Line";
                end;
            Database::"Purchase Header":
                if PurchaseLine.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    UpdateQtyToSendOnPurchaseLine(PurchaseLine);
                    ConvertedTableId := Database::"Purchase Line";
                end;
            Database::"Service Header":
                if ServiceLine.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    UpdateQtyToSendOnServiceLine(ServiceLine);
                    ConvertedTableId := Database::"Service Line";
                end;
            Database::"Transfer Header":
                if TransferLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    UpdateQtyToSendOnTransferLine(TransferLine);
                    ConvertedTableId := Database::"Transfer Line";
                end;
            Database::"Sales Shipment Header":
                if SalesShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then
                    UpdateQtyToSendOnSalesShipmentLine(SalesShipmentLine);
            Database::"Return Shipment Header":
                if ReturnShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then
                    UpdateQtyToSendOnReturnShipmentLine(ReturnShipmentLine);
            Database::"Service Shipment Header":
                if ServiceShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then
                    UpdateQtyToSendOnServiceShipmentLine(ServiceShipmentLine);
            Database::"Transfer Shipment Header":
                if TransferShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then
                    UpdateQtyToSendOnTransferShipmentLine(TransferShipmentLine);
            Database::"Transfer Receipt Header":
                if TransferReceiptLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then
                    UpdateQtyToSendOnTransferReceiptLine(TransferReceiptLine);
        end;
        if ConvertedTableId <> 0 then begin
            WarehouseShipmentLine.SetSourceFilter(ConvertedTableId, TransportOrderLine."Source Document Type".AsInteger(), TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.", true);
            if WarehouseShipmentLine.FindSet(true) then
                repeat
                    UpdateQtyToSendOnWarehouseShipmentLine(WarehouseShipmentLine);
                until WarehouseShipmentLine.Next() = 0;
        end;
    end;

    local procedure UpdateQtyToSendOnSalesLine(var SalesLine: Record "Sales Line")
    begin
        if SalesLine."IDYS Quantity To Send" <> SalesLine.IDYSCalculateQtyToSendToCarrier() then begin
            SalesLine.IDYSCalcAndUpdateQtyToSendToCarrier();
            SalesLine.Modify();
        end;
    end;

    local procedure UpdateQtyToSendOnPurchaseLine(var PurchaseLine: Record "Purchase Line")
    begin
        if PurchaseLine."IDYS Quantity To Send" <> PurchaseLine.IDYSCalculateQtyToSendToCarrier() then begin
            PurchaseLine.IDYSCalcAndUpdateQtyToSendToCarrier();
            PurchaseLine.Modify();
        end;
    end;

    local procedure UpdateQtyToSendOnServiceLine(var ServiceLine: Record "Service Line")
    begin
        if ServiceLine."IDYS Quantity To Send" <> ServiceLine.IDYSCalcQtyToSendToCarrier() then begin
            ServiceLine.IDYSInitQtyToSendToCarrier();
            ServiceLine.Modify();
        end;
    end;

    local procedure UpdateQtyToSendOnTransferLine(var TransferLine: Record "Transfer Line")
    begin
        if TransferLine."IDYS Quantity To Send" <> TransferLine.IDYSCalculateQtyToSendToCarrier() then begin
            TransferLine.IDYSCalcAndUpdateQtyToSendToCarrier();
            TransferLine.Modify();
        end;
    end;

    local procedure CalcQtyToSendOnSalesShipmentLine(var SalesShipmentLine: Record "Sales Shipment Line"): Decimal
    begin
        SalesShipmentLine.CalcFields("IDYS Quantity Sent");
        exit(Abs(SalesShipmentLine."Quantity (Base)") - SalesShipmentLine."IDYS Quantity Sent");
    end;

    local procedure CalcQtyToSendOnReturnShipmentLine(var ReturnShipmentLine: Record "Return Shipment Line"): Decimal
    begin
        ReturnShipmentLine.CalcFields("IDYS Quantity Sent");
        exit(ReturnShipmentLine."Quantity (Base)" - ReturnShipmentLine."IDYS Quantity Sent");
    end;

    local procedure CalcQtyToSendOnServiceShipmentLine(var ServiceShipmentLine: Record "Service Shipment Line"): Decimal
    begin
        ServiceShipmentLine.CalcFields("IDYS Quantity Sent");
        exit(Abs(ServiceShipmentLine."Quantity (Base)") - ServiceShipmentLine."IDYS Quantity Sent");
    end;

    local procedure CalcQtyToSendOnTransferShipmentLine(var TransferShipmentLine: Record "Transfer Shipment Line"): Decimal
    begin
        TransferShipmentLine.CalcFields("IDYS Quantity Sent");
        exit(TransferShipmentLine."Quantity (Base)" - TransferShipmentLine."IDYS Quantity Sent");
    end;

    local procedure CalcQtyToSendOnTransferReceiptLine(var TransferReceiptLine: Record "Transfer Receipt Line"): Decimal
    begin
        TransferReceiptLine.CalcFields("IDYS Quantity Sent");
        exit(TransferReceiptLine."Quantity (Base)" - TransferReceiptLine."IDYS Quantity Sent");
    end;

    local procedure UpdateQtyToSendOnSalesShipmentLine(var SalesShipmentLine: Record "Sales Shipment Line")
    var
        QtyToSend: Decimal;
    begin
        QtyToSend := CalcQtyToSendOnSalesShipmentLine(SalesShipmentLine);
        if SalesShipmentLine."IDYS Quantity To Send" <> QtyToSend then begin
            SalesShipmentLine.Validate("IDYS Quantity To Send", QtyToSend);
            SalesShipmentLine.Modify();
        end;
    end;

    local procedure UpdateQtyToSendOnReturnShipmentLine(var ReturnShipmentLine: Record "Return Shipment Line")
    var
        QtyToSend: Decimal;
    begin
        QtyToSend := CalcQtyToSendOnReturnShipmentLine(ReturnShipmentLine);
        if ReturnShipmentLine."IDYS Quantity To Send" <> QtyToSend then begin
            ReturnShipmentLine.Validate("IDYS Quantity To Send", QtyToSend);
            ReturnShipmentLine.Modify();
        end;
    end;

    local procedure UpdateQtyToSendOnServiceShipmentLine(var ServiceShipmentLine: Record "Service Shipment Line")
    var
        QtyToSend: Decimal;
    begin
        QtyToSend := CalcQtyToSendOnServiceShipmentLine(ServiceShipmentLine);
        if ServiceShipmentLine."IDYS Quantity To Send" <> QtyToSend then begin
            ServiceShipmentLine.Validate("IDYS Quantity To Send", QtyToSend);
            ServiceShipmentLine.Modify();
        end;
    end;

    local procedure UpdateQtyToSendOnTransferShipmentLine(var TransferShipmentLine: Record "Transfer Shipment Line")
    var
        QtyToSend: Decimal;
    begin
        QtyToSend := CalcQtyToSendOnTransferShipmentLine(TransferShipmentLine);
        if TransferShipmentLine."IDYS Quantity To Send" <> QtyToSend then begin
            TransferShipmentLine.Validate("IDYS Quantity To Send", QtyToSend);
            TransferShipmentLine.Modify();
        end;
    end;

    local procedure UpdateQtyToSendOnTransferReceiptLine(var TransferReceiptLine: Record "Transfer Receipt Line")
    var
        QtyToSend: Decimal;
    begin
        QtyToSend := CalcQtyToSendOnTransferReceiptLine(TransferReceiptLine);
        if TransferReceiptLine."IDYS Quantity To Send" <> QtyToSend then begin
            TransferReceiptLine.Validate("IDYS Quantity To Send", QtyToSend);
            TransferReceiptLine.Modify();
        end;
    end;

    local procedure UpdateQtyToSendOnWarehouseShipmentLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        QtyToSend: Decimal;
        DummySourceDocQtyToSend: Decimal;
    begin
        QtyToSend := IDYSDocumentMgt.CalcWarehouseShipmentLineQtyToSend(WarehouseShipmentLine, DummySourceDocQtyToSend);
        if WarehouseShipmentLine."IDYS Quantity To Send" <> QtyToSend then begin
            IDYSDocumentMgt.SetWarehouseShipmentLineQtyToSend(WarehouseShipmentLine);
            WarehouseShipmentLine.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSalesDocumentTrackingInfo(var SalesHeader: Record "Sales Header"; SalesLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateSalesDocumentTrackingInfo(var SalesHeader: Record "Sales Header"; SalesLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdatePurchaseDocumentTrackingInfo(var PurchaseHeader: Record "Purchase Header"; PurchaseLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdatePurchaseDocumentTrackingInfo(var PurchaseHeader: Record "Purchase Header"; PurchaseLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateTransferOrderTrackingInfo(var TransferHeader: Record "Transfer Header"; TransferLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateTransferOrderTrackingInfo(var TransferHeader: Record "Transfer Header"; TransferLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateServiceOrderTrackingInfo(var ServiceHeader: Record "Service Header"; ServiceLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateServiceOrderTrackingInfo(var ServiceHeader: Record "Service Header"; ServiceLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSalesShipmentTrackingInfo(var SalesShipmentHeader: Record "Sales Shipment Header"; SalesShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateSalesShipmentTrackingInfo(var SalesShipmentHeader: Record "Sales Shipment Header"; SalesShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateTransferShipmentTrackingInfo(var TransferShipmentHeader: Record "Transfer Shipment Header"; TransferShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateTransferShipmentTrackingInfo(var TransferShipmentHeader: Record "Transfer Shipment Header"; TransferShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateReturnShipmentTrackingInfo(var ReturnShipmentHeader: Record "Return Shipment Header"; ReturnShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateReturnShipmentTrackingInfo(var ReturnShipmentHeader: Record "Return Shipment Header"; ReturnShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateServiceShipmentTrackingInfo(var ServiceShipmentHeader: Record "Service Shipment Header"; ServiceShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateServiceShipmentTrackingInfo(var ServiceShipmentHeader: Record "Service Shipment Header"; ServiceShipmentLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeUpdateQtyToSendOnDocs(TransportOrderLine: Record "IDYS Transport Order Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeResetQtyToSendOnDocs(TransportOrderLine: Record "IDYS Transport Order Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateTransferReceiptTrackingInfo(var TransferReceiptHeader: Record "Transfer Receipt Header"; TransferReceiptLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateTransferReceiptTrackingInfo(var TransferReceiptHeader: Record "Transfer Receipt Header"; TransferReceiptLineNo: Integer; IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean)
    begin
    end;
}