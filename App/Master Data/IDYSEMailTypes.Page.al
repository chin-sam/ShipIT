page 11147647 "IDYS E-Mail Types"
{
    Caption = 'E-Mail Types';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS E-Mail Type";
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
                    ToolTip = 'Specifies the e-mail type code.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the e-mail type description.';
                }

                field("Is Default"; Rec."Is Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies is the e-mail type is the default e-mail type.';
                }
            }
        }
    }
}