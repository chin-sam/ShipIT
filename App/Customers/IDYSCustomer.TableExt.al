tableextension 11147658 "IDYS Customer" extends Customer
{
    fields
    {
        field(11147740; "IDYS E-Mail Type"; Code[127])
        {
            Caption = 'E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            DataClassification = CustomerContent;
        }
        field(11147741; "IDYS Cost Center"; Code[127])
        {
            Caption = 'Cost Center';
            TableRelation = "IDYS Cost Center";
            DataClassification = CustomerContent;
        }
        field(11147742; "IDYS Account No."; Code[32])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
        field(11147743; "IDYS Surcharge %"; Decimal)
        {
            Caption = 'Shipping Surcharge (Percentage)';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved to Cust. Inv. Discount';
            ObsoleteTag = '21.0';
        }
        field(11147744; "IDYS Surcharge Fixed Amount"; Decimal)
        {
            Caption = 'Shipping Surcharge (Fixed Amount)';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved to Cust. Inv. Discount';
            ObsoleteTag = '21.0';
        }
    }
}
