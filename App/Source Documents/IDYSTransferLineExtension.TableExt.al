tableextension 11147643 "IDYS Transfer Line Extension" extends "Transfer Line"
{
    fields
    {
        modify("Qty. to Ship")
        {
            trigger OnAfterValidate()
            var
                IDYSSessionVariables: Codeunit "IDYS Session Variables";
            begin
                if not IDYSSessionVariables.SetupIsCompleted() then
                    exit;

                if ("Item No." <> '') or (Quantity > 0) then //LS Retail exception Quantity validated as 0 but Item No. is not populated
                    IDYSCalcAndUpdateQtyToSendToCarrier();
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
                if "IDYS Quantity To Send" > "Quantity (Base)" then begin
                    IDYSOnBeforeQtyToSendError(Rec, IsHandled);
                    if not IsHandled then
                        Error(CannotSendMoreErr, FieldCaption("IDYS Quantity To Send"), FieldCaption("Quantity (Base)"));
                end;
            end;
        }

        field(11147640; "IDYS Quantity Sent"; Decimal)
        {
            Caption = 'ShipIT Quantity Sent';
            Editable = false;
            DecimalPlaces = 0 : 5;
            BlankZero = true;
            FieldClass = FlowField;
            CalcFormula = sum("IDYS Transport Order Line"."Qty. (Base)" where("Source Document Table No." = const(5740),
                                                                         "Source Document No." = field("Document No."),
                                                                         "Source Document Line No." = field("Line No."),
                                                                         "Order Header Status" = filter(<> Recalled)));
        }

        field(11147642; "IDYS Tracking No."; Code[50])
        {
            Caption = 'ShipIT Tracking No.';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(11147643; "IDYS Tracking URL"; Text[250])
        {
            Caption = 'ShipIT Tracking URL';
            Editable = false;
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
    }

    [Obsolete('Replaced by IDYSCalcQtyToSendToCarrier', '18.5')]
    procedure IDYSInitQtyToSendToCarrier(UseQty: Decimal)
    begin
        IDYSCalcAndUpdateQtyToSendToCarrier();
    end;

    [Obsolete('Replaced by IDYSCalcAndUpdateQtyToSendToCarrier', '21.10')]
    procedure IDYSCalcQtyToSendToCarrier()
    begin
        IDYSCalcAndUpdateQtyToSendToCarrier();
    end;

    procedure IDYSCalculateQtyToSendToCarrier(): Decimal
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
    begin
        if IDYSCheckWhseShipmentLineExists() then
            exit;
        IDYSSetup.Get();
        if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Posted documents" then
            exit("Qty. to Ship (Base)")
        else
            exit("Qty. to Ship (Base)" + "Qty. Shipped (Base)" - IDYSDocumentMgt.GetTransferLineQtySent(Rec));
    end;

    procedure IDYSCalcAndUpdateQtyToSendToCarrier()
    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
    begin
        if IDYSCheckWhseShipmentLineExists() then
            exit;
        IDYSDocumentMgt.SetTransferOrderLineQtyToSend(Rec, IDYSCalculateQtyToSendToCarrier());
    end;

    local procedure IDYSCheckWhseShipmentLineExists(): Boolean
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WarehouseShipmentLine.SetSourceFilter(Database::"Transfer Line", 0, "Document No.", "Line No.", true);
        exit(not WarehouseShipmentLine.IsEmpty());
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeQtyToSendError(TransferLine: Record "Transfer Line"; var IsHandled: Boolean);
    begin
    end;
}