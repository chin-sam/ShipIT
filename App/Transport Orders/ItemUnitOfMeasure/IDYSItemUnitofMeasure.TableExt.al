tableextension 11147662 "IDYS Item Unit of Measure" extends "Item Unit of Measure"
{
    fields
    {
        field(11147740; "IDYS Package Type"; Code[50])
        {
            TableRelation = "IDYS Package Type";
            DataClassification = CustomerContent;
            Caption = 'Package Type';
            ObsoleteState = Pending;
            ObsoleteReason = 'Restructured with Provider level';
        }
        field(11147741; "IDYS Provider"; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            ValuesAllowed = Default, Transsmart;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Restructured with Provider level';

            trigger OnValidate()
            begin
                Validate("IDYS Provider Package Type", '');
            end;
        }
        field(11147742; "IDYS Provider Package Type"; Code[50])
        {
            TableRelation = "IDYS Provider Package Type".Code Where(Provider = field("IDYS Provider"));
            DataClassification = CustomerContent;
            Caption = 'Provider Package Type';
            ObsoleteState = Pending;
            ObsoleteReason = 'Restructured with Provider level';
        }
        field(11147743; "IDYS Default Provider Packages"; Boolean)
        {
            Caption = 'Default Provider Packages';
            FieldClass = FlowField;
            CalcFormula = Exist("IDYS Item UOM Package" where("Item No." = field("Item No."), "Code" = field("Code")));
            Editable = false;
        }
    }
}