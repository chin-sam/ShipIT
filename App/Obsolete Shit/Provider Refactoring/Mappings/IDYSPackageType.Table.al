table 11147644 "IDYS Package Type"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Package Type';
    DataCaptionFields = "Code", Description;
    LookupPageId = "IDYS Package Types";

    fields
    {
        field(1; "Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; Description; Text[128])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(3; "Type"; Text[16])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }

        field(4; Length; Decimal)
        {
            Caption = 'Length';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(5; Width; Decimal)
        {
            Caption = 'Width';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(6; Height; Decimal)
        {
            Caption = 'Height';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(7; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(8; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
        }

        field(9; "Linear UOM"; Code[3])
        {
            Caption = 'Linear UOM';
            DataClassification = CustomerContent;
        }

        field(10; "Mass UOM"; Code[3])
        {
            Caption = 'Mass UOM';
            DataClassification = CustomerContent;
        }
        #region [nShift Ship]
        field(50; GoodsTypeKey1; Text[50])
        {
            Caption = 'Goods Type Key 1';
            DataClassification = SystemMetadata;
        }
        field(51; GoodsTypeKey2; Text[50])
        {
            Caption = 'Goods Type Key 2';
            DataClassification = SystemMetadata;
        }
        #endregion
        #region [Sendcloud] 
        field(100; "Special Equipment Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Special Equipment";
            Caption = 'Special Equipment Code';
        }
        #endregion
    }

    keys
    {
        key(PK; "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Type")
        {
        }
    }

    trigger OnDelete()
    var
        BookingProfPackageType: Record "IDYS BookingProf. Package Type";
    begin
        BookingProfPackageType.SetRange("Package Type Code", Rec.Code);
        BookingProfPackageType.DeleteAll();
    end;
}