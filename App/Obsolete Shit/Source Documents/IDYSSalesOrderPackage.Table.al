table 11147690 "IDYS Sales Order Package"
{
    Caption = 'Sales Order Package';
    ObsoleteState = Pending;
    ObsoleteReason = 'Added Document Type level';
    ObsoleteTag = '21.0';

    fields
    {
        field(1; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            NotBlank = true;
            TableRelation = "Sales Header"."No.";
            DataClassification = CustomerContent;
            ValidateTableRelation = false;
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        field(3; "Parcel Identifier"; Code[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Parcel Identifier';
        }

        field(10; "External ID"; Integer)
        {
            BlankZero = true;
            Caption = 'External ID';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(14; "Provider Filter"; Enum "IDYS Provider")
        {
            Caption = 'Provider Filter';
            FieldClass = FlowFilter;
        }
        field(15; "Provider Package Type Code"; Code[50])
        {
            Caption = 'Package Type Code';
            TableRelation = "IDYS Provider Package Type".Code;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(16; "Book. Prof. Package Type Code"; Code[50])
        {
            Caption = 'Package Type Code';
            TableRelation = "IDYS BookingProf. Package Type"."Package Type Code" where("Carrier Entry No." = field("Carrier Entry No. Filter"), "Booking Profile Entry No." = field("Booking P. Entry No. Filter"));
            DataClassification = CustomerContent;
        }

        field(20; "Package Type Code"; Code[50])
        {
            Caption = 'Package Type Code';
            TableRelation = "IDYS Package Type";
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Restructured with Provider level';
        }

        field(21; "Package Type"; Text[50])
        {
            Caption = 'Package Type';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(22; "Package Type Description"; Text[128])
        {
            Caption = 'Package Type Description';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(30; Description; Text[128])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(40; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 0;
            MinValue = 0;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Quantity replaced with multiplication action on a subpage';
            ObsoleteTag = '21.0';

            trigger OnValidate();
            begin
                UpdateTotalVolume();
                UpdateTotalWeight();
            end;
        }

        field(50; Length; Decimal)
        {
            Caption = 'Length';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateVolume();
            end;
        }

        field(60; Width; Decimal)
        {
            Caption = 'Width';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateVolume();
            end;
        }

        field(70; Height; Decimal)
        {
            Caption = 'Height';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateVolume();
            end;
        }

        field(80; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdateTotalWeight();
            end;
        }

        field(100; Volume; Decimal)
        {
            Caption = 'Volume';
            DecimalPlaces = 0 : 2;
            Editable = false;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(110; "Total Volume"; Decimal)
        {
            Caption = 'Total Volume';
            DecimalPlaces = 0 : 2;
            Editable = false;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(120; "Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
            DecimalPlaces = 0 : 2;
            Editable = false;
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(140; "Tracking No."; Code[50])
        {
            Caption = 'Tracking No.';
            DataClassification = CustomerContent;
        }

        field(150; "Linear UOM"; Code[3])
        {
            Caption = 'Linear UOM';
            DataClassification = CustomerContent;
        }

        field(151; "Mass UOM"; Code[3])
        {
            Caption = 'Mass UOM';
            DataClassification = CustomerContent;
        }
        // field(160; Direction; Option)
        // {
        //     Caption = 'Direction';
        //     Editable = false;
        //     OptionCaption = 'Outgoing,Incoming';
        //     OptionMembers = Outgoing,Incoming;
        //     DataClassification = CustomerContent;
        // }
        field(211; "Booking P. Entry No. Filter"; Integer)
        {
            FieldClass = FlowFilter;
            TableRelation = "IDYS Provider Booking Profile"."Entry No.";
            Caption = 'Booking Profile Entry No.';
        }
        field(212; "Carrier Entry No. Filter"; Integer)
        {
            FieldClass = FlowFilter;
            TableRelation = "IDYS Provider Booking Profile"."Carrier Entry No.";
            Caption = 'Carrier Entry No. Filter';
        }

        #region [Sendcloud]
        field(255; "Shipping Method Description"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Shipping Method';
        }
        field(261; "Shipping Method Id"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Shipping Method Id';
        }
        #endregion

        field(500; "System Created Entry"; Boolean)
        {
            Caption = 'System Created Entry';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Sales Order No.", "Line No.")
        {
            SumIndexFields = "Total Volume", "Total Weight";
        }
    }

    trigger OnInsert();
    var
        SalesOrderPackage: Record "IDYS Sales Order Package";
        MinValue: Code[20];
        MaxValue: Code[20];
    begin
        if "Line No." = 0 then begin
            if "Sales Order No." = '' then
                if GetFilter("Sales Order No.") <> '' then
                    if TryGetSalesOrderNoRange(MinValue, MaxValue) then
                        if MinValue = MaxValue then
                            Validate("Sales Order No.", MinValue);
            SalesOrderPackage.SetRange("Sales Order No.", "Sales Order No.");
            if SalesOrderPackage.FindLast() then begin
                "Line No." := SalesOrderPackage."Line No." + 1;
                "Parcel Identifier" := IncStr(SalesOrderPackage."Parcel Identifier")
            end else begin
                "Line No." := 1;
                "Parcel Identifier" := Format("Sales Order No.") + '-' + Format("Line No.") + '-' + Format(1);
            end;
        end;
        UpdateVolume();
        UpdateTotalWeight();
    end;

    procedure UpdateVolume();
    begin
        Volume := Length * Width * Height;
        UpdateTotalVolume();
    end;

    procedure UpdateTotalVolume();
    begin
        "Total Volume" := Volume;
    end;

    procedure UpdateTotalWeight();
    begin
        "Total Weight" := Weight;
    end;

    [TryFunction]
    local procedure TryGetSalesOrderNoRange(var MinValue: Code[20]; var MaxValue: Code[20])
    begin
        MinValue := GetRangeMin("Sales Order No.");
        MaxValue := GetRangeMax("Sales Order No.");
    end;

    [Obsolete('Sales Order Package table replaced', '21.0')]
    procedure CopyFromSalesOrderPackage(SalesOrderPackage: Record "IDYS Sales Order Package")
    begin
    end;
}

