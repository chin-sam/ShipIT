table 11147654 "IDYS Ship-to Address Setup"
{
    Caption = 'ShipIT Ship-to Address Setup';
    ObsoleteReason = 'Moved ship-to address specific settings to the ship-to address table.';
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
        field(2; "Ship-to Address Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Customer No."));
            DataClassification = CustomerContent;
        }
        field(3; "E-Mail Type"; Code[127])
        {
            Caption = 'E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            DataClassification = CustomerContent;
        }
        field(4; "Cost Center"; Code[127])
        {
            Caption = 'Cost Center';
            TableRelation = "IDYS Cost Center";
            DataClassification = CustomerContent;
        }
        field(10; "Account No."; Code[32])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Customer No.", "Ship-to Address Code")
        {
        }
    }
}