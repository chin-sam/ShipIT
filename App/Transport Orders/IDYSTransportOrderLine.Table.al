table 11147670 "IDYS Transport Order Line"
{
    Caption = 'Transport Order Line';
    DrillDownPageID = "IDYS Transport Order Lines";
    LookupPageID = "IDYS Transport Order Lines";

    fields
    {
        field(1; "Transport Order No."; Code[20])
        {
            Caption = 'Transport Order No.';
            TableRelation = "IDYS Transport Order Header";
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate();
            var
                TransportOrderHeader: Record "IDYS Transport Order Header";
            begin
                if not TransportOrderHeader.Get("Transport Order No.") then
                    TransportOrderHeader.Init();

                "Order Header Status" := TransportOrderHeader.Status;
            end;
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(6; "Source Table Caption"; Text[250])
        {
            Caption = 'Source Table';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object ID" = field("Source Document Table No."), "Object Type" = const(Table)));
            Editable = false;
        }

        //TODO - Om naar standaard NAV table No + standaard optionstring.
        field(10; "Source Document Table No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(11; "Source Document Type"; Enum "IDYS Source Document Type")
        {
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(20; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            Editable = false;
            TableRelation = if ("Source Document Table No." = const(36)) "Sales Header"."No." where("Document Type" = field("Source Document Type"))
            else
            if ("Source Document Table No." = const(38)) "Purchase Header"."No." where("Document Type" = field("Source Document Type"))
            else
            if ("Source Document Table No." = const(5900)) "Service Header"."No." where("Document Type" = field("Source Document Type"))
            else
            if ("Source Document Table No." = const(5740)) "Transfer Header"."No."
            else
            if ("Source Document Table No." = const(5744)) "Transfer Shipment Header"."No."
            else
            if ("Source Document Table No." = const(5746)) "Transfer Receipt Header"."No."
            else
            if ("Source Document Table No." = const(110)) "Sales Shipment Header"."No.";
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                Validate("Source Document Line No.", 0);
            end;
        }

        field(30; "Source Document Line No."; Integer)
        {
            Caption = 'Source Document Line No.';
            Editable = false;
            TableRelation = if ("Source Document Table No." = const(36)) "Sales Line"."Line No." where("Document Type" = field("Source Document Type"),
                                                                                                         "Document No." = field("Source Document No."),
                                                                                                         Type = const(Item))
            else
            if ("Source Document Table No." = const(38)) "Purchase Line"."Line No." where("Document Type" = filter(Order | "Return Order"),
                                                                                            "Document No." = field("Source Document No."),
                                                                                            Type = const(Item))
            else
            if ("Source Document Table No." = const(5900)) "Service Line"."Line No." where("Document Type" = const(Order),
                                                                                             "Document No." = field("Source Document No."),
                                                                                             Type = const(Item))
            else
            if ("Source Document Table No." = const(5740)) "Transfer Line"."Line No." where("Document No." = field("Source Document No."))
            else
            if ("Source Document Table No." = const(5744)) "Transfer Shipment Line"."Line No." where("Document No." = field("Source Document No."))
            else
            if ("Source Document Table No." = const(5746)) "Transfer Receipt Line"."Line No." where("Document No." = field("Source Document No."));
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                SalesLine: Record "Sales Line";
                PurchaseLine: Record "Purchase Line";
                ServiceLine: Record "Service Line";
                SalesShipmentLine: Record "Sales Shipment Line";
                ReturnShipmentLine: Record "Return Shipment Line";
                ServiceShipmentLine: Record "Service Shipment Line";
                TransferLine: Record "Transfer Line";
                TransferShipmentLine: Record "Transfer Shipment Line";
                TransferReceiptLine: Record "Transfer Receipt Line";
            begin
                case "Source Document Table No." of
                    Database::"Sales Header":
                        begin
                            if not SalesLine.Get("Source Document Type", "Source Document No.", "Source Document Line No.") then
                                SalesLine.Init();

                            Validate("Item No.", SalesLine."No.");
                            Validate("Variant Code", SalesLine."Variant Code");
                            Validate("Item Category Code", SalesLine."Item Category Code");
                            Validate(Description, SalesLine.Description);
                            Validate("Description 2", SalesLine."Description 2");
                        end;
                    Database::"Purchase Header":
                        begin
                            if not PurchaseLine.Get("Source Document Type", "Source Document No.", "Source Document Line No.") then
                                PurchaseLine.Init();

                            Validate("Item No.", PurchaseLine."No.");
                            Validate("Variant Code", PurchaseLine."Variant Code");
                            Validate("Item Category Code", PurchaseLine."Item Category Code");
                            Validate(Description, PurchaseLine.Description);
                            Validate("Description 2", PurchaseLine."Description 2");
                        end;
                    Database::"Service Header":
                        begin
                            if not ServiceLine.Get("Source Document Type", "Source Document No.", "Source Document Line No.") then
                                ServiceLine.Init();

                            Validate("Item No.", ServiceLine."No.");
                            Validate("Variant Code", ServiceLine."Variant Code");
                            Validate("Item Category Code", ServiceLine."Item Category Code");
                            Validate(Description, ServiceLine.Description);
                            Validate("Description 2", ServiceLine."Description 2");
                        end;
                    Database::"Sales Shipment Header":
                        begin
                            if not SalesShipmentLine.Get("Source Document No.", "Source Document Line No.") then
                                SalesShipmentLine.Init();

                            Validate("Item No.", SalesShipmentLine."No.");
                            Validate("Variant Code", SalesShipmentLine."Variant Code");
                            Validate("Item Category Code", SalesShipmentLine."Item Category Code");
                            Validate(Description, SalesShipmentLine.Description);
                            Validate("Description 2", SalesShipmentLine."Description 2");
                        end;
                    Database::"Return Shipment Header":
                        begin
                            if not ReturnShipmentLine.Get("Source Document No.", "Source Document Line No.") then
                                ReturnShipmentLine.Init();

                            Validate("Item No.", ReturnShipmentLine."No.");
                            Validate("Variant Code", ReturnShipmentLine."Variant Code");
                            Validate("Item Category Code", ReturnShipmentLine."Item Category Code");
                            Validate(Description, ReturnShipmentLine.Description);
                            Validate("Description 2", ReturnShipmentLine."Description 2");
                        end;
                    Database::"Service Shipment Header":
                        begin
                            if not ServiceShipmentLine.Get("Source Document No.", "Source Document Line No.") then
                                ServiceShipmentLine.Init();

                            Validate("Item No.", ServiceShipmentLine."No.");
                            Validate("Variant Code", ServiceShipmentLine."Variant Code");
                            Validate("Item Category Code", ServiceShipmentLine."Item Category Code");
                            Validate(Description, ServiceShipmentLine.Description);
                            Validate("Description 2", ServiceShipmentLine."Description 2");
                        end;
                    Database::"Transfer Header":
                        begin
                            if not TransferLine.Get("Source Document No.", "Source Document Line No.") then
                                TransferLine.Init();

                            Validate("Item No.", TransferLine."Item No.");
                            Validate("Variant Code", TransferLine."Variant Code");
                            Validate("Item Category Code", TransferLine."Item Category Code");
                            Validate(Description, TransferLine.Description);
                            Validate("Description 2", TransferLine."Description 2");
                        end;
                    Database::"Transfer Shipment Header":
                        begin
                            if not TransferShipmentLine.Get("Source Document No.", "Source Document Line No.") then
                                TransferShipmentLine.Init();

                            Validate("Item No.", TransferShipmentLine."Item No.");
                            Validate("Variant Code", TransferShipmentLine."Variant Code");
                            Validate("Item Category Code", TransferShipmentLine."Item Category Code");
                            Validate(Description, TransferShipmentLine.Description);
                            Validate("Description 2", TransferShipmentLine."Description 2");
                        end;

                    Database::"Transfer Receipt Header":
                        begin
                            if not TransferReceiptLine.Get("Source Document No.", "Source Document Line No.") then
                                TransferReceiptLine.Init();

                            Validate("Item No.", TransferReceiptLine."Item No.");
                            Validate("Variant Code", TransferReceiptLine."Variant Code");
                            Validate("Item Category Code", TransferReceiptLine."Item Category Code");
                            Validate(Description, TransferReceiptLine.Description);
                            Validate("Description 2", TransferReceiptLine."Description 2");
                        end;
                end;
            end;
        }
        field(100; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(101; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(102; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(110; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(111; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(150; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemUnitofMeasure: Record "Item Unit of Measure";
            begin
                if ("Unit of Measure Code" <> '') and
                    ItemUnitofMeasure.Get("Item No.", "Unit of Measure Code")
                then
                    Validate("Qty. (Base)", Quantity * ItemUnitofMeasure."Qty. per Unit of Measure")
                else
                    Validate("Qty. (Base)", Quantity);
            end;
        }
        field(151; Amount; Decimal)
        {
            Caption = 'Transport Value';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
        }
        field(152; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(153; "Qty. (Base)"; Decimal)
        {
            Caption = 'Qty. (Base)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(154; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            var
                ItemUnitofMeasure: Record "Item Unit of Measure";
            begin
                if ("Unit of Measure Code" <> '') and
                    ItemUnitofMeasure.Get("Item No.", "Unit of Measure Code")
                then
                    Validate("Qty. (Base)", Quantity * ItemUnitofMeasure."Qty. per Unit of Measure")
                else
                    Validate("Qty. (Base)", Quantity);
            end;
        }
        field(200; "Order Header Status"; Option)
        {
            Caption = 'Order Header Status';
            Editable = false;
            InitValue = New;
            OptionCaption = ',,,New,,,Uploaded,,,,,,Booked,,,Label Printed,,,Recalled,,,,,,Archived';
            OptionMembers = ,,,New,,,Uploaded,,,,,,Booked,,,"Label Printed",,,Recalled,,,,,,Archived;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Transport Order No.", "Line No.")
        {
            Clustered = false;
            SumIndexFields = Amount, Quantity, "Qty. (Base)";
        }
        key(Key2; "Source Document Table No.", "Source Document No.", "Source Document Line No.", "Order Header Status")
        {
            SumIndexFields = Quantity, "Qty. (Base)";
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with the Key4';
            ObsoleteTag = '24.0';
        }
        key(Key3; "Source Document Table No.", "Source Document Type", "Source Document No.", "Transport Order No.")
        {
        }
        key(Key4; "Source Document Table No.", "Source Document Type", "Source Document No.", "Source Document Line No.", "Order Header Status")
        {
            SumIndexFields = Quantity, "Qty. (Base)";
        }
        key(Key5; "Item Category Code") { }
    }

    trigger OnDelete()
    var
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
    begin
        IDYSTransportOrderDelNote.SetRange("Transport Order No.", Rec."Transport Order No.");
        IDYSTransportOrderDelNote.SetRange("Transport Order Line No.", Rec."Line No.");
        if not IDYSTransportOrderDelNote.IsEmpty() then
            IDYSTransportOrderDelNote.DeleteAll();
    end;
}