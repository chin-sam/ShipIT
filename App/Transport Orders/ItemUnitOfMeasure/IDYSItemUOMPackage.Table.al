table 11147706 "IDYS Item UOM Package"
{
    Caption = 'Item Unit Of Measure Package';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }
        field(3; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "IDYS Provider"; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            ValuesAllowed = Transsmart, "Delivery Hub", Sendcloud, EasyPost;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IDYSItemUOMPackage: Record "IDYS Item UOM Package";
                DuplicateErr: Label 'The default Package Type for Provider %1 is already specified.', comment = '%1 = provider';
            begin
                IDYSItemUOMPackage.SetRange("Item No.", "Item No.");
                IDYSItemUOMPackage.SetRange("Code", "Code");
                IDYSItemUOMPackage.SetRange("IDYS Provider", "IDYS Provider");
                if not IDYSItemUOMPackage.IsEmpty() then
                    Error(DuplicateErr, "IDYS Provider");

                Validate("Provider Package Type Code", '');
            end;
        }

        field(11; "Provider Package Type Code"; Code[50])
        {
            Caption = 'Default Package Type Code';
            TableRelation = "IDYS Provider Package Type".Code where(Provider = field("IDYS Provider"));
            DataClassification = CustomerContent;
        }

        field(12; "Profile Packages"; Boolean)
        {
            Caption = 'Default Profile Package Lines';
            FieldClass = FlowField;
            CalcFormula = Exist("IDYS Item UOM Profile Package" where("Item No." = field("Item No."), "Code" = field("Code"), "Item UOM Package Entry No." = field("Entry No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.", "Code", "Entry No.")
        {
        }
    }
}