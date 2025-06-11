tableextension 11147645 "IDYS Service Line Extension" extends "Service Line"
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
                if (Type <> Type::" ") and (Quantity <> 0) and ("Document Type" <> "Document Type"::"Credit Memo") then
                    IDYSInitQtyToSendToCarrier();
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
                if (Type <> Type::" ") and (Quantity <> 0) and ("Document Type" <> "Document Type"::"Credit Memo") then
                    IDYSInitQtyToSendToCarrier();
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
            CalcFormula = sum("IDYS Transport Order Line"."Qty. (Base)" where("Source Document Table No." = const(5900),
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

    procedure IDYSCalcQtyToSendToCarrier(): Decimal
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        QtySent: Decimal;
    begin
        if IDYSCheckWhseShipmentLineExists() then
            exit;
        IDYSSetup.Get();
        QtySent := IDYSDocumentMgt.GetServiceOrderLineQtySent(Rec);
        if "Qty. to Ship (Base)" < 0 then
            QtySent := QtySent * -1;
        if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Posted documents" then
            exit("Qty. to Ship (Base)")
        else
            exit("Qty. to Ship (Base)" + "Qty. Shipped (Base)" - QtySent);
    end;

    procedure IDYSInitQtyToSendToCarrier()
    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
    begin
        if IDYSCheckWhseShipmentLineExists() then
            exit;
        IDYSDocumentMgt.SetServiceOrderLineQtyToSend(Rec, IDYSCalcQtyToSendToCarrier());
    end;

    local procedure IDYSCheckWhseShipmentLineExists(): Boolean
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WarehouseShipmentLine.SetSourceFilter(Database::"Service Line", "Document Type".AsInteger(), "Document No.", "Line No.", true);
        exit(not WarehouseShipmentLine.IsEmpty());
    end;

    procedure IDYSLineRequiresShipmentOrReceipt(): Boolean
    var
        Location: Record Location;
    begin
        if ("Document Type" <> "Document Type"::Order) or ("Type" <> "Type"::Item) then
            exit(false);
        exit(Location.RequireReceive("Location Code") or Location.RequireShipment("Location Code"));
    end;

    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeQtyToSendError(ServiceLine: Record "Service Line"; var IsHandled: Boolean);
    begin
    end;
}