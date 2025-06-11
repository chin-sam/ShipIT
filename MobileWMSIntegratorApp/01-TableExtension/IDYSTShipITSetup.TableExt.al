tableextension 11147824 "IDYST ShipIT Setup" extends "IDYS Setup"
{
    fields
    {
        field(11147820; "IDYST Source Unit (Mass)"; Text[20])
        {
            Caption = 'Source Unit (Mass)';
            FieldClass = FlowField;
            CalcFormula = lookup("MOB Setup"."Weight Unit" where("Primary Key" = const('')));
        }
        field(11147821; "IDYST Conversion Factor (Mass)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Conversion Factor (Mass)';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
        }
        field(11147822; "IDYST Rounding Prec. (Mass)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision (Mass)';
            AutoFormatType = 1;
            InitValue = 0.01;
        }
        field(11147823; "IDYST Source Unit (Linear)"; Text[20])
        {
            Caption = 'Source Unit (Linear)';
            FieldClass = FlowField;
            CalcFormula = lookup("MOB Setup"."Dimensions Unit" where("Primary Key" = const('')));
        }
        field(11147824; "IDYST Conv. Factor (Linear)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Conversion Factor (Linear)';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
        }
        field(11147825; "IDYST Rounding Prec. (Linear)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision (Linear)';
            AutoFormatType = 1;
            InitValue = 0.01;
        }
    }
}