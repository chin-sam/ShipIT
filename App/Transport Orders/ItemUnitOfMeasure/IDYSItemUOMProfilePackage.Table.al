table 11147707 "IDYS Item UOM Profile Package"
{
    Caption = 'Item Unit Of Measure Profile Package';

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
        field(3; "Item UOM Package Entry No."; Integer)
        {
            Caption = 'Item UOM Package Entry No.';
            DataClassification = CustomerContent;
        }
        field(4; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Changed Table Relation';
            ObsoleteTag = '21.0';
        }

        field(11; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Changed Table Relation';
            ObsoleteTag = '21.0';
        }

        field(12; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;
        }

        field(13; "Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            TableRelation = "IDYS Provider Booking Profile";
            DataClassification = CustomerContent;
        }

        field(14; "Provider Package Type Code"; Code[50])
        {
            Caption = 'Default Package Type Code';
            TableRelation = "IDYS BookingProf. Package Type"."Package Type Code" where("Carrier Entry No." = field("Carrier Entry No."), "Booking Profile Entry No." = field("Booking Profile Entry No."));
            DataClassification = CustomerContent;
        }
        field(15; "Shipping Agent Code (Mapped)"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "IDYS Ship. Agent Mapping" where(Provider = field("Provider Filter"));
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ShippingAgentMapping: Record "IDYS Ship. Agent Mapping";
            begin
                if not ShippingAgentMapping.Get("Shipping Agent Code (Mapped)") then
                    ShippingAgentMapping.Init();
                Validate("Carrier Entry No.", ShippingAgentMapping."Carrier Entry No.");
                Validate("Ship. Agent Svc. Code (Mapped)", '');

                if "Shipping Agent Code (Mapped)" <> '' then
                    CheckDuplicates();
            end;
        }

        field(16; "Ship. Agent Svc. Code (Mapped)"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "IDYS Ship. Agent Svc. Mapping"."Shipping Agent Service Code" where("Shipping Agent Code" = field("Shipping Agent Code (Mapped)"));
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                IDYSShippAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
            begin
                if not IDYSShippAgentSvcMapping.Get("Shipping Agent Code (Mapped)", "Ship. Agent Svc. Code (Mapped)") then
                    IDYSShippAgentSvcMapping.Init();
                Validate("Booking Profile Entry No.", IDYSShippAgentSvcMapping."Booking Profile Entry No.");

                if "Ship. Agent Svc. Code (Mapped)" <> '' then
                    CheckDuplicates();
            end;
        }
        field(17; "Provider Filter"; Enum "IDYS Provider")
        {
            Caption = 'Provider Filter';
            FieldClass = FlowFilter;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Item No.", "Code", "Item UOM Package Entry No.", "Entry No.")
        {
        }
    }

    local procedure CheckDuplicates()
    var
        IDYSItemUOMProfilePackage: Record "IDYS Item UOM Profile Package";
    begin
        IDYSItemUOMProfilePackage.Reset();
        IDYSItemUOMProfilePackage.SetRange("Item No.", "Item No.");
        IDYSItemUOMProfilePackage.SetRange("Code", "Code");
        IDYSItemUOMProfilePackage.SetRange("Item UOM Package Entry No.", "Item UOM Package Entry No.");
        IDYSItemUOMProfilePackage.SetRange("Shipping Agent Code (Mapped)", "Shipping Agent Code (Mapped)");
        IDYSItemUOMProfilePackage.SetRange("Ship. Agent Svc. Code (Mapped)", "Ship. Agent Svc. Code (Mapped)");
        if not IDYSItemUOMProfilePackage.IsEmpty() then
            Error(DuplicateErr);
    end;

    var
        DuplicateErr: Label 'The Default Package Type is already specified.';
}