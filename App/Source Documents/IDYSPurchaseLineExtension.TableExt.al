tableextension 11147642 "IDYS Purchase Line Extension" extends "Purchase Line"
{
    fields
    {
        modify("Return Qty. to Ship")
        {
            trigger OnAfterValidate()
            var
                IDYSSessionVariables: Codeunit "IDYS Session Variables";
            begin
                if not IDYSSessionVariables.SetupIsCompleted() then
                    exit;
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
                Item: Record Item;
                IDYSSetup: Record "IDYS Setup";
                IsHandled: Boolean;
                CannotSendMoreErr: Label '%1 cannot exceed %2.', Comment = '%1=The IDYS field,%2= The Qty field';
            begin
                if not Item.Get("No.") then
                    exit;

                IDYSSetup.Get();
                if not IDYSSetup."Allow All Item Types" then
                    Item.TestField(Type, Item.Type::Inventory);
                if Abs("IDYS Quantity To Send") > Abs("Quantity (Base)") then begin
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
            FieldClass = FlowField;
            DecimalPlaces = 0 : 5;
            BlankZero = true;
            CalcFormula = sum("IDYS Transport Order Line"."Qty. (Base)" where("Source Document Table No." = const(38),
                                                                           "Source Document No." = field("Document No."),
                                                                           "Source Document Line No." = field("Line No."),
                                                                           "Source Document Type" = field("Document Type"),
                                                                           "Order Header Status" = filter(<> Recalled)));
        }

        field(11147641; "IDYS Tracking No."; Code[50])
        {
            Caption = 'ShipIT Tracking No.';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(11147642; "IDYS Tracking URL"; Text[250])
        {
            Caption = 'ShipIT Tracking URL';
            Editable = false;
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }

        field(11147643; "IDYS Transport Value"; Decimal)
        {
            Caption = 'Transport Value Excl. VAT';
            DataClassification = CustomerContent;
            Editable = false;
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
        case "Document Type" of
            "Document Type"::"Return Order":
                if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Posted documents" then
                    exit("Return Qty. to Ship (Base)")
                else
                    exit("Return Qty. to Ship (Base)" + "Return Qty. Shipped (Base)" - IDYSDocumentMgt.GetPurchaseLineQtySent(Rec));
            "Document Type"::Order:
                if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Posted documents" then
                    exit("Qty. to Receive (Base)")
                else
                    exit("Qty. to Receive (Base)" + "Qty. Received (Base)" - IDYSDocumentMgt.GetPurchaseLineQtySent(Rec));
        end;

    end;

    procedure IDYSCalcAndUpdateQtyToSendToCarrier()
    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
    begin
        if IDYSCheckWhseShipmentLineExists() then
            exit;
        IDYSDocumentMgt.SetPurchaseLineQtyToSend(Rec, IDYSCalculateQtyToSendToCarrier());
    end;

    local procedure IDYSCheckWhseShipmentLineExists(): Boolean
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WarehouseShipmentLine.SetSourceFilter(Database::"Purchase Line", "Document Type".AsInteger(), "Document No.", "Line No.", true);
        exit(not WarehouseShipmentLine.IsEmpty());
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeQtyToSendError(PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean);
    begin
    end;
}