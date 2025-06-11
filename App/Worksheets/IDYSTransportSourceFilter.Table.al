table 11147668 "IDYS Transport Source Filter"
{
    Caption = 'Transport Source Filter';
    DataCaptionFields = "Code", Description;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(3; "Sales Orders"; Boolean)
        {
            Caption = 'Sales Orders';
            Description = 'Documents';
            DataClassification = CustomerContent;
        }

        field(4; "Purchase Return Orders"; Boolean)
        {
            Caption = 'Purchase Return Orders';
            DataClassification = CustomerContent;
        }

        field(5; "Service Orders"; Boolean)
        {
            Caption = 'Service Orders';
            DataClassification = CustomerContent;
        }

        field(6; "Transfer Orders"; Boolean)
        {
            Caption = 'Transfer Orders';
            DataClassification = CustomerContent;
        }

        field(7; "Posted Sales Shipments"; Boolean)
        {
            Caption = 'Posted Sales Shipments';
            DataClassification = CustomerContent;
        }

        field(8; "Posted Purch. Return Shipments"; Boolean)
        {
            Caption = 'Posted Purch. Return Shipments';
            DataClassification = CustomerContent;
        }

        field(9; "Posted Service Shipments"; Boolean)
        {
            Caption = 'Posted Service Shipments';
            DataClassification = CustomerContent;
        }

        field(10; "Shipping Agent Code Filter"; Code[100])
        {
            Caption = 'Shipping Agent Code Filter';
            Description = 'Shipping';
            TableRelation = "Shipping Agent";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(11; "Shipping Agent Service Filter"; Code[100])
        {
            Caption = 'Shipping Agent Service Filter';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code Filter"));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(12; "Shipment Method Code Filter"; Code[100])
        {
            Caption = 'Shipment Method Code Filter';
            TableRelation = "Shipment Method";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(13; "E-Mail Type Filter"; Text[100])
        {
            Caption = 'E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(14; "Cost Center Filter"; Text[100])
        {
            Caption = 'Cost Center';
            TableRelation = "IDYS Cost Center";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(15; "Item No. Filter"; Code[100])
        {
            Caption = 'Item No. Filter';
            Description = 'Item';
            TableRelation = Item;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(16; "Variant Code Filter"; Code[100])
        {
            Caption = 'Variant Code Filter';
            TableRelation = "Item Variant".Code;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(17; "Unit of Measure Filter"; Code[100])
        {
            Caption = 'Unit of Measure Filter';
            TableRelation = "Unit of Measure";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(18; "Sell-to Customer No. Filter"; Code[100])
        {
            Caption = 'Sell-to Customer No. Filter';
            Description = 'Sales';
            TableRelation = Customer;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(19; "Buy-from Vendor No. Filter"; Code[100])
        {
            Caption = 'Buy-from Vendor No. Filter';
            Description = 'Purchase';
            TableRelation = Vendor;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(20; "Customer No. Filter"; Code[100])
        {
            Caption = 'Customer No. Filter';
            Description = 'Service';
            TableRelation = Customer;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(21; "Location Code Filter"; Code[100])
        {
            Caption = 'Location Code Filter';
            Description = 'Warehouse';
            TableRelation = Location;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }

        field(22; "From Posting Date Calculation"; DateFormula)
        {
            Caption = 'From Posting Date Calculation';
            Description = 'Posted documents';
            InitValue = '-14D';
            DataClassification = CustomerContent;
        }

        field(23; "To Posting Date Calculation"; DateFormula)
        {
            Caption = 'To Posting Date Calculation';
            InitValue = '+1D';
            DataClassification = CustomerContent;
        }
        field(30; "Posted Transfer Shipments"; Boolean)
        {
            Caption = 'Posted Transfer Shipments';
            DataClassification = CustomerContent;
        }
        field(31; "Sales Return Orders"; Boolean)
        {
            Caption = 'Sales Return Orders';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(32; "Posted Return Receipts"; Boolean)
        {
            Caption = 'Posted Return Receipts';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
        }
    }
}