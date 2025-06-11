tableextension 11147657 "IDYS Return Receipt Line" extends "Return Receipt Line"
{
    //NOTE - Obsolete - Removed due to wrongfully implemented flow
    fields
    {
        field(11147639; "IDYS Quantity To Send"; Decimal)
        {
            Caption = 'ShipIT Quantity to Send';
            Editable = false;
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }

        field(11147640; "IDYS Quantity Sent"; Decimal)
        {
            Caption = 'ShipIT Quantity Sent';
            Editable = false;
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
            CalcFormula = sum("IDYS Transport Order Line"."Qty. (Base)" where("Source Document Table No." = const(6660),
                                                                           "Source Document No." = field("Document No."),
                                                                           "Source Document Line No." = field("Line No."),
                                                                           "Order Header Status" = filter(<> Recalled)));
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }

        field(11147641; "IDYS Tracking No."; Code[50])
        {
            Caption = 'ShipIT Tracking No.';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }

        field(11147642; "IDYS Tracking URL"; Text[250])
        {
            Caption = 'ShipIT Tracking URL';
            Editable = false;
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }

        field(11147643; "IDYS Transport Value"; Decimal)
        {
            Caption = 'Transport Value Excl. VAT';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
    }

    [IntegrationEvent(false, false)]
    local procedure IDYSOnBeforeQtyToSendError(ReturnReceiptLine: Record "Return Receipt Line"; var IsHandled: Boolean);
    begin
    end;
}