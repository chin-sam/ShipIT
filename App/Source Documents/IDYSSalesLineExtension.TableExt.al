tableextension 11147640 "IDYS Sales Line Extension" extends "Sales Line"
{
    fields
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                IDYSSessionVariables: Codeunit "IDYS Session Variables";
            begin
                if not IDYSSessionVariables.SetupIsCompleted() then
                    exit;

                if "Type" <> "Type"::Item then
                    exit;

                IDYSCalcAndUpdateQtyToSendToCarrier();
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                Location: Record Location;
                IDYSSessionVariables: Codeunit "IDYS Session Variables";
            begin
                if not IDYSSessionVariables.SetupIsCompleted() then
                    exit;

                if "Type" <> "Type"::Item then
                    exit;

                if "Document Type" <> "Document Type"::"Return Order" then
                    exit;

                if Location.RequireReceive("Location Code") then
                    IDYSCalcAndUpdateQtyToSendToCarrier();
            end;
        }
        modify("Qty. to Ship")
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
        modify("Return Qty. to Receive")
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
        modify("Drop Shipment")
        {
            trigger OnAfterValidate()
            var
                IDYSSessionVariables: Codeunit "IDYS Session Variables";
            begin
                if not IDYSSessionVariables.SetupIsCompleted() then
                    exit;

                if (xRec."Drop Shipment" <> "Drop Shipment") AND (Quantity <> 0) then
                    if "Drop Shipment" then
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
            DecimalPlaces = 0 : 5;
            BlankZero = true;
            FieldClass = FlowField;
            CalcFormula = sum("IDYS Transport Order Line"."Qty. (Base)" where("Source Document Table No." = const(36),
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
            DataClassification = SystemMetadata;
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
        Location: Record Location;
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        QtySent: Decimal;
    begin
        if IDYSCheckWhseShipmentLineExists() then
            exit;
        IDYSSetup.Get();
        QtySent := IDYSDocumentMgt.GetSalesLineQtySent(Rec);
        if "Qty. to Ship (Base)" < 0 then
            QtySent := QtySent * -1;
        case "Document Type" of
            "Document Type"::Quote,
            "Document Type"::Order:
                if Location.RequireShipment("Location Code") or (IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Posted documents") then
                    exit("Qty. to Ship (Base)")
                else
                    exit("Qty. to Ship (Base)" + "Qty. Shipped (Base)" - QtySent);
            "Document Type"::"Return Order":
                if Location.RequireReceive("Location Code") then
                    exit("Quantity (Base)" - QtySent)
                else
                    exit("Return Qty. to Receive (Base)" + "Return Qty. Received (Base)" - QtySent);
        end;
    end;

    procedure IDYSCalcAndUpdateQtyToSendToCarrier()
    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
    begin
        if IDYSCheckWhseShipmentLineExists() then
            exit;
        IDYSDocumentMgt.SetSalesLineQtyToSend(Rec, IDYSCalculateQtyToSendToCarrier());
    end;

    local procedure IDYSCheckWhseShipmentLineExists(): Boolean
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WarehouseShipmentLine.SetSourceFilter(Database::"Sales Line", "Document Type".AsInteger(), "Document No.", "Line No.", true);
        exit(not WarehouseShipmentLine.IsEmpty());
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeQtyToSendError(SalesLine: Record "Sales Line"; var IsHandled: Boolean);
    begin
    end;
}