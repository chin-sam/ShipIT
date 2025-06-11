tableextension 11147646 "IDYS Whse. Shpt. Line Ext." extends "Warehouse Shipment Line"
{
    fields
    {
        modify("Qty. to Ship")
        {
            trigger OnAfterValidate()
            var
                IDYSSessionVariables: Codeunit "IDYS Session Variables";
                IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
            begin
                if not IDYSSessionVariables.SetupIsCompleted() then
                    exit;

                IDYSDocumentMgt.SetWarehouseShipmentLineQtyToSend(Rec);
            end;
        }
        field(11147639; "IDYS Quantity To Send"; Decimal)
        {
            Caption = 'ShipIT Quantity to Send';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            BlankZero = true;

            trigger OnValidate()
            var
                IsHandled: Boolean;
                CannotSendMoreErr: Label '%1 cannot exceed %2.', Comment = '%1=The IDYS field,%2= The Qty field';
            begin
                if "IDYS Quantity To Send" > IDYSGetSourceDocLineQuantity() then begin
                    IDYSOnBeforeQtyToSendError(Rec, IsHandled);
                    if not IsHandled then
                        Error(CannotSendMoreErr, FieldCaption("IDYS Quantity To Send"), FieldCaption("Qty. (Base)"));
                end;
                IDYSUpdateQuantityToSendOnSourceDoc();
            end;
        }

        field(11147640; "IDYS Quantity Sent"; Decimal)
        {
            Caption = 'ShipIT Quantity Sent';
            Editable = false;
            DecimalPlaces = 0 : 5;
            BlankZero = true;
            FieldClass = FlowField;
            CalcFormula = sum("IDYS Transport Order Line"."Qty. (Base)" where("Source Document Table No." = field("IDYS Source Table Filter"),
                                                                          "Source Document Type" = field("IDYS Source Doc. Type Filter"),
                                                                          "Source Document No." = field("Source No."),
                                                                          "Source Document Line No." = field("Source Line No."),
                                                                          "Order Header Status" = filter(<> Recalled)));
        }
        field(11147641; "IDYS Source Table Filter"; Integer)
        {
            Caption = 'Source Table Filter';
            FieldClass = FlowFilter;
            Editable = false;
        }
        field(11147642; "IDYS Source Doc. Type Filter"; Enum "IDYS Source Document Type")
        {
            Caption = 'Source Document Type Filter';
            FieldClass = FlowFilter;
            Editable = false;
        }
        field(11147644; "IDYS Shipping Agent Code"; Code[10])
        {
            Caption = 'Source Shipping Agent Code';
            TableRelation = "Shipping Agent".Code;
            DataClassification = CustomerContent;
        }
        field(11147645; "IDYS Shipping Agent Srv Code"; Code[10])
        {
            Caption = 'Source Shipping Agent Service Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("IDYS Shipping Agent Code"));
        }
        field(11147646; "IDYS Shipment Method Code"; Code[10])
        {
            Caption = 'Source Shipment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipment Method".Code;
        }
        field(11147647; "IDYS Do Not Insure"; Boolean)
        {
            Caption = 'Do Not Insure';
            DataClassification = CustomerContent;
        }
    }

    trigger OnAfterDelete()
    var
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        CannotDeleteErr: Label 'You cannot delete this %1, because it is associated with one or more transport orders.', Comment = '%1 = Table Caption.';
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if IDYSGetQtySentToCarrier() > 0 then
            Error(CannotDeleteErr, TableCaption());
    end;

    procedure IDYSGetQtySentToCarrier(): Decimal
    var
        IDYSTransportOrderLine: Record "IDYS Transport Order Line";
    begin
        IDYSTransportOrderLine.SetRange("Source Document Type", "Source Document");
        IDYSTransportOrderLine.SetRange("Source Document No.", "Source No.");
        IDYSTransportOrderLine.SetRange("Source Document Line No.", "Source Line No.");
        IDYSTransportOrderLine.SetFilter("Order Header Status", '<>%1', IDYSTransportOrderLine."Order Header Status"::Recalled);
        IDYSTransportOrderLine.CalcSums("Qty. (Base)");

        exit(IDYSTransportOrderLine."Qty. (Base)");
    end;

    [Obsolete('QtySent is now deducted in SetWarehouseShipmentLineQtyToSend itself', '18.5')]
    procedure IDYSSetQtyToSendToCarrier(QtyToSend: Decimal)
    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
    begin
        IDYSDocumentMgt.SetWarehouseShipmentLineQtyToSend(Rec);
    end;

    procedure IDYSCalculateQtySent()
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        IDYSSetup.Get();
        if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Posted documents" then
            SetRange("IDYS Source Table Filter", 0)
        else
            case "Source Document" of
                "Source Document"::"Sales Order", "Source Document"::"Sales Return Order":
                    begin
                        SetRange("IDYS Source Table Filter", Database::"Sales Header");
                        if "Source Document" = "Source Document"::"Sales Order" then
                            SetRange("IDYS Source Doc. Type Filter", "IDYS Source Doc. Type Filter"::"1");
                        if "Source Document" = "Source Document"::"Sales Return Order" then
                            SetRange("IDYS Source Doc. Type Filter", "IDYS Source Doc. Type Filter"::"5");
                    end;
                "Source Document"::"Purchase Return Order":
                    begin
                        SetRange("IDYS Source Table Filter", Database::"Purchase Header");
                        SetRange("IDYS Source Doc. Type Filter", "IDYS Source Doc. Type Filter"::"5");
                    end;
                "Source Document"::"Purchase Order":
                    begin
                        SetRange("IDYS Source Table Filter", Database::"Purchase Header");
                        SetRange("IDYS Source Doc. Type Filter", "IDYS Source Doc. Type Filter"::"1");
                    end;
                "Source Document"::"Service Order":
                    begin
                        SetRange("IDYS Source Doc. Type Filter", "IDYS Source Doc. Type Filter"::"1");
                        SetRange("IDYS Source Table Filter", Database::"Service Header");
                    end;
                "Source Document"::"Outbound Transfer", "Source Document"::"Inbound Transfer":
                    SetRange("IDYS Source Table Filter", Database::"Transfer Header");
            end;
        CalcFields("IDYS Quantity Sent");
    end;

    procedure IDYSGetSourceDocLineQuantity() SourceDocQuantity: Decimal
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        ServiceLine: Record "Service Line";
    begin
        case "Source Type" of
            Database::"Sales Line":
                begin
                    SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    exit(SalesLine."Quantity (Base)");
                end;
            Database::"Purchase Line":
                begin
                    PurchaseLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    exit(PurchaseLine."Quantity (Base)");
                end;
            Database::"Transfer Line":
                begin
                    TransferLine.Get("Source No.", "Source Line No.");
                    exit(TransferLine."Quantity (Base)");
                end;
            Database::"Service Line":
                begin
                    ServiceLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    exit(ServiceLine."Quantity (Base)");
                end;
            else
                IDYSOnGetSourceDocLineQuantityOnCaseSourceType(Rec, SourceDocQuantity);
        end;
    end;

    procedure IDYSUpdateQuantityToSendOnSourceDoc()
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        ServiceLine: Record "Service Line";
    begin
        case "Source Type" of
            Database::"Sales Line":
                begin
                    SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    if SalesLine."IDYS Quantity To Send" <> "IDYS Quantity To Send" then begin
                        SalesLine.Validate("IDYS Quantity To Send", "IDYS Quantity To Send");
                        SalesLine.Modify();
                    end;
                end;
            Database::"Purchase Line":
                begin
                    PurchaseLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    if PurchaseLine."IDYS Quantity To Send" <> "IDYS Quantity To Send" then begin
                        PurchaseLine.Validate("IDYS Quantity To Send", "IDYS Quantity To Send");
                        PurchaseLine.Modify();
                    end;
                end;
            Database::"Transfer Line":
                begin
                    TransferLine.Get("Source No.", "Source Line No.");
                    if TransferLine."IDYS Quantity To Send" <> "IDYS Quantity To Send" then begin
                        TransferLine.Validate("IDYS Quantity To Send", "IDYS Quantity To Send");
                        TransferLine.Modify();
                    end;
                end;
            Database::"Service Line":
                begin
                    ServiceLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    if ServiceLine."IDYS Quantity To Send" <> "IDYS Quantity To Send" then begin
                        ServiceLine.Validate("IDYS Quantity To Send", "IDYS Quantity To Send");
                        ServiceLine.Modify();
                    end;
                end;
            else
                IDYSUpdateQuantityToSendOnSourceDocOnCaseSourceType(Rec);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSOnGetSourceDocLineQuantityOnCaseSourceType(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; SourceDocQuantity: Decimal);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSUpdateQuantityToSendOnSourceDocOnCaseSourceType(var WarehouseShipmentLine: Record "Warehouse Shipment Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeQtyToSendError(WarehouseShipmentLine: Record "Warehouse Shipment Line"; var IsHandled: Boolean);
    begin
    end;
}