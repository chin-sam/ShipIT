page 11147690 "IDYS Tpt. Ord. Details Factbox"
{
    Caption = 'Transport Order Details';
    PageType = CardPart;
    SourceTable = "IDYS Transport Order Line";

    layout
    {
        area(Content)
        {
            field(TransportOrderOrCountFld; TransportOrderOrCount)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number of Transport Orders or the Transport Order No. when only one Transport Order exists.';
                Caption = '(No. of) Transport Order(s)';

                trigger OnDrillDown()
                var
                    IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    MinValue: Code[20];
                    MaxValue: Code[20];
                    SourceDocTableNo: Integer;
                    SourceDocType: Integer;
                begin
                    if TryGetSourceDocNoRange(MinValue, MaxValue, SourceDocTableNo) then
                        if MinValue = MaxValue then begin
                            if TryGetSourceDocTypeRange(SourceDocType) then;
                            IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(SourceDocTableNo, SourceDocType, MinValue);
                        end;
                end;
            }

            field("Order Header Status"; Rec."Order Header Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the status of the last (booked) transport order.';
            }
            field("TranspOrderHeader Calculated Shipment Value"; CalculatedShipmentValue)
            {
                Caption = 'Calculated Shipment Value';
                ApplicationArea = All;
                ToolTip = 'Specifies the calculated shipment value. A transport value is mandatory in the communication with most carriers. If the calculated transport value is zero or incorrect, then the actual shipment value can be used to register the correct amount.';
            }
            field("TranspOrderHeader Shipment Value"; TransportOrderHeader."Shipmt. Value")
            {
                Caption = 'Actual Shipment Value';
                ApplicationArea = All;
                ToolTip = 'Specifies the actual shipment value. When the calculated shipment value doesn''t represent the real transport value, the actual transport value can be entered in this field.';
            }

            field("TranspOrderHeader Shipment Cost"; TransportOrderHeader."Shipmt. Cost")
            {
                Caption = 'Shipment Cost';
                ApplicationArea = All;
                ToolTip = 'Specifies the total shipment cost.';
            }

            field("TranspOrderHeader Spot Price"; TransportOrderHeader."Spot Pr.")
            {
                Caption = 'Spot Price';
                ApplicationArea = All;
                ToolTip = 'Specifies the total spot price.';
            }

            field("TranspOrderHeader Tracking No."; TransportOrderHeader."Tracking No.")
            {
                Caption = 'Tracking No.';
                ApplicationArea = All;
                ToolTip = 'Specifies the tracking no. of the last booked transport order.';
            }

            field("TranspOrderHeader Tracking Url"; TransportOrderHeader."Tracking Url")
            {
                Caption = 'Tracking Url';
                ExtendedDatatype = URL;
                ApplicationArea = All;
                ToolTip = 'Specifies the tracking URL of the last booked transport order.';
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    var
        TransportOrderHeader2: Record "IDYS Transport Order Header";
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
        FilterText: Text;
        MinValue: Code[20];
        MaxValue: Code[20];
        SourceDocTableNo: Integer;
        SourceDocType: Integer;
        NoOfTransportOrders: Integer;
    begin
        Clear(TransportOrderHeader);
        Clear(TransportOrderOrCount);
        if TryGetSourceDocNoRange(MinValue, MaxValue, SourceDocTableNo) then
            if MinValue = MaxValue then begin
                if TryGetSourceDocTypeRange(SourceDocType) then;
                FilterText := IDYSDocumentMgt.GetTransportOrdersFilterFromSource(SourceDocTableNo, SourceDocType, MinValue);
            end;

        if FilterText <> '' then begin
            TransportOrderHeader.SetFilter("No.", FilterText);
            NoOfTransportOrders := TransportOrderHeader.Count();
        end else
            NoOfTransportOrders := Rec.Count();
        if NoOfTransportOrders > 1 then
            TransportOrderOrCount := Format(NoOfTransportOrders);
        if NoOfTransportOrders > 0 then begin
            TransportOrderHeader.SetRange(Status, TransportOrderHeader.Status::Booked);
            if not TransportOrderHeader.FindLast() then begin
                TransportOrderHeader.SetRange(Status);
                TransportOrderHeader.FindLast();
            end;
            if NoOfTransportOrders = 1 then
                TransportOrderOrCount := Rec."Transport Order No.";
        end;
        if Rec."Transport Order No." <> '' then
            TransportOrderHeader.Get(Rec."Transport Order No.");
        if FilterText <> '' then begin
            TransportOrderHeader.CalcSums("Shipmt. Value", "Shipmt. Cost", "Spot Pr.");
            CalculatedShipmentValue := 0;
            TransportOrderHeader2.CopyFilters(TransportOrderHeader);
            TransportOrderHeader2.SetAutoCalcFields("Calculated Shipment Value");
            TransportOrderHeader2.SetLoadFields("Calculated Shipment Value");
            if TransportOrderHeader2.FindSet() then
                repeat
                    CalculatedShipmentValue += TransportOrderHeader2."Calculated Shipment Value";
                until TransportOrderHeader2.Next() = 0;
        end else
            if TransportOrderHeader."No." <> '' then begin
                TransportOrderHeader.CalcFields("Calculated Shipment Value");
                CalculatedShipmentValue := TransportOrderHeader."Calculated Shipment Value";
                TransportOrderHeader.CalcSums("Shipmt. Value", "Shipmt. Cost", "Spot Pr.");
            end;
    end;

    [TryFunction]
    local procedure TryGetSourceDocNoRange(var MinValue: Code[20]; var MaxValue: Code[20]; var SourceDocTableNo: Integer)
    begin
        MinValue := Rec.GetRangeMin("Source Document No.");
        MaxValue := Rec.GetRangeMax("Source Document No.");
        SourceDocTableNo := Rec.GetRangeMin("Source Document Table No.");
    end;

    [TryFunction]
    local procedure TryGetSourceDocTypeRange(var SourceDocType: Integer)
    var
        SourceDocumentType: Enum "IDYS Source Document Type";
    begin
        SourceDocumentType := Rec.GetRangeMin("Source Document Type");
        SourceDocType := SourceDocumentType.AsInteger();
    end;

    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        TransportOrderOrCount: Text;
        CalculatedShipmentValue: Decimal;
}