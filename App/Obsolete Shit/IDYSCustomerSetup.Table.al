table 11147652 "IDYS Customer Setup"
{
    Caption = 'ShipIT Customer Setup';
    DataCaptionFields = "Customer No.", "Customer Name";
    ObsoleteReason = 'Moved customer specific settings to the customer table.';
    ObsoleteState = Pending;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            NotBlank = true;
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }

        field(2; "E-Mail Type"; Code[127])
        {
            Caption = 'E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            DataClassification = CustomerContent;
        }

        field(3; "Cost Center"; Code[127])
        {
            Caption = 'Cost Center';
            TableRelation = "IDYS Cost Center";
            DataClassification = CustomerContent;
        }

        field(4; "Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name where("No." = field("Customer No.")));
            Caption = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(10; "Account No."; Code[32])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Customer No.")
        {
        }
    }
}