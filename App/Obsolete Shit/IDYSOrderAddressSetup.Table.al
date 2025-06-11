table 11147655 "IDYS Order Address Setup"
{
    Caption = 'ShipIT Order Address Setup';
    ObsoleteReason = 'Moved ship-to address specific settings to the ship-to address table.';
    ObsoleteState = Pending;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }

        field(2; "Order Address Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = "Order Address".Code where("Vendor No." = field("Vendor No."));
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
    }

    keys
    {
        key(PK; "Vendor No.", "Order Address Code")
        {
        }
    }
}