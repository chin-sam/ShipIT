page 11147664 "IDYS Language Mappings"
{
    Caption = 'Language Mappings';
    UsageCategory = Lists;
    ApplicationArea = All;
    PageType = List;
    SourceTable = "IDYS Language Mapping";
    ContextSensitiveHelpPage = '22315059';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the language code.';
                }

                field("Language Code (External)"; Rec."Language Code (External)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external language code.';
                }

                field("Language Name"; Rec."Language Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the language name.';
                }
            }
        }
    }
}