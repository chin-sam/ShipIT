table 11147660 "IDYS Transport Order Del. Note"
{
    Caption = 'Transport Order Delivery Note';

    fields
    {
        field(1; "Transport Order No."; Code[20])
        {
            Caption = 'Transport Order No.';
            NotBlank = true;
            TableRelation = "IDYS Transport Order Header";
            DataClassification = CustomerContent;
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Transport Order Line No."; Integer)
        {
            Caption = 'Transport Order Line No.';
            DataClassification = SystemMetadata;
            TableRelation = "IDYS Transport Order Line"."Line No." where("Transport Order No." = field("Transport Order No."));
        }

        field(10; "Article Id"; Text[64])
        {
            Caption = 'Article Id';
            DataClassification = CustomerContent;
        }

        field(11; "Article Name"; Text[64])
        {
            Caption = 'Article Name';
            DataClassification = CustomerContent;
        }

        field(12; Description; Text[64])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(13; Price; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency";
            AutoFormatType = 2;
        }

        field(14; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CheckOverAssignment();
            end;
        }

        field(15; "Quantity Backorder"; Decimal)
        {
            Caption = 'Quantity Backorder';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }

        field(16; "Quantity Order"; Decimal)
        {
            Caption = 'Quantity Order';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }

        field(17; "Serial No."; Text[64])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }

        field(18; "Country of Origin"; Code[10])
        {
            Caption = 'Country of Origin Code';
            TableRelation = "IDYS Country/Region Mapping";
            DataClassification = CustomerContent;
        }

        field(19; "HS Code"; Text[64])
        {
            Caption = 'HS Code';
            DataClassification = CustomerContent;
        }

        field(20; "Reason of Export"; Text[64])
        {
            Caption = 'Reason of Export';
            DataClassification = CustomerContent;
        }

        field(21; Currency; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = "IDYS Currency Mapping";
            DataClassification = CustomerContent;
        }
        field(22; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
            begin
                if not SkipUpdateTotals then begin
                    IDYSTransportOrderHeader.Get("Transport Order No.");
                    IDYSTransportOrderHeader.UpdateTotals();
                end;
            end;
        }
        field(23; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(24; "Transport Order Pkg. Record Id"; RecordId)
        {
            Caption = 'Transport Order Pkg. Record Id';
            DataClassification = SystemMetadata;
        }
        #region Transsmart
        field(25; "Quantity UOM"; Code[20])
        {
            Caption = 'Quantity UOM';
            DataClassification = CustomerContent;
        }
        field(26; "Quantity m2"; Decimal)
        {
            Caption = 'Quantity m2';
            DataClassification = CustomerContent;
        }
        field(27; "Item No."; Code[20])
        {
            TableRelation = Item;
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(28; "Variant Code"; Code[10])
        {
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(29; "Item Reference No."; Code[50])
        {
            TableRelation = "Item Reference"."Reference No." where("Reference Type" = const("Bar Code"), "Item No." = field("Item No."), "Variant Code" = field("Variant Code"));
            ValidateTableRelation = false;
            Caption = 'Item Reference No.';
            DataClassification = CustomerContent;
        }
        field(30; Quality; Text[64])
        {
            Caption = 'Quality';
            DataClassification = CustomerContent;
        }
        field(31; Composition; Text[128])
        {
            Caption = 'Composition';
            DataClassification = CustomerContent;
        }
        field(32; "Assembly Instructions"; Text[1024])
        {
            Caption = 'Assembly Instructions';
            DataClassification = CustomerContent;
        }
        field(33; "Weight UOM"; Code[3])
        {
            Caption = 'Weight UOM';
            DataClassification = CustomerContent;
        }
        field(34; "HS Code Description"; Text[100])
        {
            Caption = 'HS Code Description';
            DataClassification = CustomerContent;
        }
        field(35; Returnable; Boolean)
        {
            Caption = 'Returnable';
            DataClassification = CustomerContent;
        }
        #endregion Transsmart
    }

    keys
    {
        key(PK; "Transport Order No.", "Line No.")
        {
        }
        key(Key1; "Transport Order No.", "Transport Order Line No.")
        {
        }
        key(Key2; "Transport Order No.", "Transport Order Pkg. Record Id")
        {
        }
    }

    trigger OnInsert();
    var
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        MinValue: Code[20];
        MaxValue: Code[20];
    begin
        if "Line No." = 0 then begin
            if "Transport Order No." = '' then
                if GetFilter("Transport Order No.") <> '' then
                    if TryGetTransportOrderNoRange(MinValue, MaxValue) then
                        if MinValue = MaxValue then
                            Validate("Transport Order No.", MinValue);
            TransportOrderDelNote.SetRange("Transport Order No.", "Transport Order No.");
            if "Transport Order Line No." <> 0 then begin
                if TransportOrderDelNote.Get("Transport Order No.", "Transport Order Line No.") then begin
                    TransportOrderDelNote.SetRange("Line No.", "Transport Order Line No.", "Transport Order Line No." + 9999);
                    TransportOrderDelNote.FindLast();
                    Validate("Line No.", TransportOrderDelNote."Line No." + 1);
                    TransportOrderDelNote.SetRange("Line No.");
                end else
                    Validate("Line No.", "Transport Order Line No.");
            end else begin
                if TransportOrderDelNote.FindLast() then;
                "Line No." := TransportOrderDelNote."Line No." + 10000;
            end;
        end;
    end;

    [TryFunction]
    local procedure TryGetTransportOrderNoRange(var MinValue: Code[20]; var MaxValue: Code[20])
    begin
        MinValue := GetRangeMin("Transport Order No.");
        MaxValue := GetRangeMax("Transport Order No.");
    end;

    local procedure CheckOverAssignment()
    var
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        TransportOrderLine: Record "IDYS Transport Order Line";
        IsHandled: Boolean;
        ExceedQtyErr: Label 'The total quantities on the %1 (%2) exceeds the quantity on the %3 (%4).', Comment = '%1 = DelNote tablecaption, %2 = DelNote Total Quantities, %3 = Transport Order Line tablecaption, %4 = Transport Order Line Quantity';
    begin
        TransportOrderLine.Get(Rec."Transport Order No.", Rec."Transport Order Line No.");
        TransportOrderDelNote.SetRange("Transport Order No.", "Transport Order No.");
        TransportOrderDelNote.SetRange("Transport Order Line No.", "Transport Order Line No.");
        TransportOrderDelNote.SetFilter("Line No.", '<>%1', Rec."Line No.");
        TransportOrderDelNote.CalcSums(Quantity);
        if TransportOrderDelNote.Quantity + Rec.Quantity > TransportOrderLine."Qty. (Base)" then begin
            OnBeforeCheckDelNoteQuantities(TransportOrderLine, TransportOrderDelNote.Quantity, IsHandled);
            if not IsHandled then
                Error(ExceedQtyErr,
                    TransportOrderDelNote.TableCaption,
                    TransportOrderDelNote.Quantity,
                    TransportOrderLine.TableCaption,
                    TransportOrderLine."Qty. (Base)");
        end;
    end;

    procedure IsAssigned(): Boolean
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        if TransportOrderPackage.Get("Transport Order Pkg. Record Id") then
            exit(true);
    end;

    procedure SplitLine(SplitQuantity: Decimal)
    var
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        DummyRecId: RecordId;
    begin
        if SplitQuantity <= 0 then
            Error(EmptyQuantityErr);

        if SplitQuantity >= Quantity then
            Error(WrongQuantityErr);

        TransportOrderDelNote := Rec;
        TransportOrderDelNote.Quantity := SplitQuantity;
        TransportOrderDelNote."Transport Order Pkg. Record Id" := DummyRecId;
        TransportOrderDelNote."Line No." := 0;
        TransportOrderDelNote.Insert(true);

        Quantity -= SplitQuantity;
        Modify();
    end;

    procedure SetPostponeTotals(NewSkipUpdateTotals: Boolean)
    begin
        SkipUpdateTotals := NewSkipUpdateTotals;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDelNoteQuantities(TransportOrderLine: Record "IDYS Transport Order Line"; DelNoteQty: Decimal; var IsHandled: Boolean)
    begin
    end;

    var
        WrongQuantityErr: Label 'Entered quantity cannot be equal to or higher than the original quantity.';
        EmptyQuantityErr: Label 'Entered quantity cannot be equal to or less than zero.';
        SkipUpdateTotals: Boolean;
}