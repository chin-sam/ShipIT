table 11147653 "IDYS Vendor Setup"
{
    Caption = 'Vendor Setup';
    DataCaptionFields = "Vendor No.", "Vendor Name";
    ObsoleteReason = 'Moved vendor specific settings to the vendor table.';
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

        field(4; "Vendor Name"; Text[100])
        {
            CalcFormula = Lookup(Vendor.Name where("No." = field("Vendor No.")));
            Caption = 'Vendor Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Vendor No.")
        {
        }
    }
}