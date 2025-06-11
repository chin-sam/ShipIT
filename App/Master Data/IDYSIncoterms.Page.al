page 11147645 "IDYS Incoterms"
{
    Caption = 'Incoterms';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS Incoterm";
    UsageCategory = Lists;
    ApplicationArea = All;
    ContextSensitiveHelpPage = '22282322';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the incoterms code.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the incoterms description.';
                }

                field(Mapped; Rec.Mapped)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the incoterms are mapped.';
                }

                field(Default; Rec.Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the incoterm is the default incoterm.';
                }
            }
        }
    }
}