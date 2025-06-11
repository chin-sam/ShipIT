page 11147649 "IDYS Country/Region Mappings"
{
    Caption = 'Country/Region Mappings';
    UsageCategory = Lists;
    ApplicationArea = All;
    PageType = List;
    SourceTable = "IDYS Country/Region Mapping";
    ContextSensitiveHelpPage = '22315059';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country/region code.';
                }

                field("Country/Region Code (External)"; Rec."Country/Region Code (External)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external country/region code.';
                }
            }
        }
    }
}