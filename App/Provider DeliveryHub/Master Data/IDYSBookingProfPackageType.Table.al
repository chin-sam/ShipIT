table 11147696 "IDYS BookingProf. Package Type"
{
    DataClassification = CustomerContent;
    LookupPageId = "IDYS BookingProf Package Types";
    Caption = 'Booking Profile Package Types';
    fields
    {
        field(1; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;
        }

        field(2; "Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            TableRelation = "IDYS Provider Booking Profile";
            DataClassification = CustomerContent;
        }
        field(3; "Package Type Code"; Code[50])
        {
            Caption = 'Package Type Code';
            DataClassification = CustomerContent;
        }
        field(4; Provider; Enum "IDYS Provider")
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Provider where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Provider';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Actor Id"; Text[30])
        {
            CalcFormula = Lookup("IDYS Provider Carrier"."Actor Id" where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Actor Id';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; ProdConceptID; Integer)
        {
            Caption = 'Product Concept ID';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("IDYS Provider Booking Profile".ProdConceptID where("Entry No." = field("Booking Profile Entry No."), "Carrier Entry No." = field("Carrier Entry No.")));
        }
        field(11; GoodsTypeKey1; Text[50])
        {
            Caption = 'Goods Type Key 1';
            DataClassification = SystemMetadata;
        }
        field(12; GoodsTypeKey2; Text[50])
        {
            Caption = 'Goods Type Key 2';
            DataClassification = SystemMetadata;
        }
        field(13; Description; Text[128])
        {
            Caption = 'Package Type Description';
            DataClassification = SystemMetadata;
        }
        field(14; "Booking Profile Description"; Text[150])
        {
            CalcFormula = Lookup("IDYS Provider Booking Profile".Description where("Entry No." = field("Booking Profile Entry No."),
                                                                                    "Carrier Entry No." = field("Carrier Entry No.")));
            Caption = 'Booking Profile Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Carrier Name"; Text[100])
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Name where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Carrier Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "User Defined"; Boolean)
        {
            Caption = 'User Defined';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; Length; Decimal)
        {
            Caption = 'Length';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(21; Width; Decimal)
        {
            Caption = 'Width';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(22; Height; Decimal)
        {
            Caption = 'Height';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(23; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(24; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BookingProfPackageType: Record "IDYS BookingProf. Package Type";
            begin
                if Default then begin
                    BookingProfPackageType.SetRange("Carrier Entry No.", "Carrier Entry No.");
                    BookingProfPackageType.SetRange("Booking Profile Entry No.", "Booking Profile Entry No.");
                    BookingProfPackageType.SetFilter("Package Type Code", '<>%1', Rec."Package Type Code");
                    BookingProfPackageType.SetRange(Default, true);
                    if BookingProfPackageType.FindFirst() then begin
                        BookingProfPackageType.Validate(Default, false);
                        BookingProfPackageType.Modify();
                    end;
                end;
            end;
        }
        field(25; "Linear UOM"; Code[3])
        {
            Caption = 'Linear UOM';
            DataClassification = CustomerContent;
        }
        field(26; "Mass UOM"; Code[3])
        {
            Caption = 'Mass UOM';
            DataClassification = CustomerContent;
        }
        #region [Sendcloud] 
        field(100; "Special Equipment Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Special Equipment";
            Caption = 'Special Equipment Code';
        }
        #endregion
        #region API
        field(1000; "API Provider"; Enum "IDYS Provider")
        {
            DataClassification = SystemMetadata;
            Caption = 'Provider';
            Description = 'Only used temporary in the IDYSTransportOrderAPI Codeunit';
        }
        #endregion
    }

    keys
    {
        key(Key1; "Carrier Entry No.", "Booking Profile Entry No.", "Package Type Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Provider, "Package Type Code", Description) { }
    }
}