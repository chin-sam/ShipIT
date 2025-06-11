tableextension 11147650 "IDYS Return Shpt. Line Ext." extends "Return Shipment Line"
{
    fields
    {
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
            CalcFormula = sum("IDYS Transport Order Line"."Qty. (Base)" where("Source Document Table No." = const(6650),
                                                                           "Source Document No." = field("Document No."),
                                                                           "Source Document Line No." = field("Line No."),
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

    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeQtyToSendError(ReturnShipmentLine: Record "Return Shipment Line"; var IsHandled: Boolean);
    begin
    end;
}