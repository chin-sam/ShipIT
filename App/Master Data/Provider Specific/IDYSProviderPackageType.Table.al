table 11147699 "IDYS Provider Package Type"
{
    Caption = 'Package Type';
    DataCaptionFields = Provider, "Code", Description;
    LookupPageId = "IDYS Provider Package Types";

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
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(5; Width; Decimal)
        {
            Caption = 'Width';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(6; Height; Decimal)
        {
            Caption = 'Height';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(7; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
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

        #region [Sendcloud] 
        field(100; "Special Equipment Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Special Equipment";
            Caption = 'Special Equipment Code';
        }
        #endregion

        field(1000; Provider; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Provider, "Code") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Provider, "Code", Description, "Type")
        {
        }
    }

    trigger OnInsert()
    var
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
    begin
        if Provider = Provider::EasyPost then begin
            IDYSBookingProfPackageType.SetRange(Provider, Provider);
            IDYSBookingProfPackageType.SetRange("Package Type Code", Code);
            if not IDYSBookingProfPackageType.IsEmpty() then
                Error(PredefinedPackageFoundErr);
        end;
    end;

    var
        PredefinedPackageFoundErr: Label 'Predefined package type found. Please use different package type code.';
}