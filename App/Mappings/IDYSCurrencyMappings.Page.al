page 11147648 "IDYS Currency Mappings"
{
    Caption = 'Currency Mappings';
    UsageCategory = Lists;
    ApplicationArea = All;
    PageType = List;
    SourceTable = "IDYS Currency Mapping";
    ContextSensitiveHelpPage = '22315059';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency code.';
                }

                field("Currency Code (External)"; Rec."Currency Code (External)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external currency code.';
                }

                field("Currency Description"; Rec."Currency Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the currency.';
                }
                field("Currency Value"; Rec."Currency Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the Currency Value';
                }
            }
        }
    }
}