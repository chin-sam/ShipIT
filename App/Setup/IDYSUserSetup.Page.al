page 11147651 "IDYS User Setup"
{
    Caption = 'nShift Transsmart User Setup';
    UsageCategory = Lists;
    ApplicationArea = All;
    PageType = List;
    SourceTable = "IDYS User Setup";
    ContextSensitiveHelpPage = '22282322';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user id.';
                }
                field("User Name (External)"; Rec."User Name (External)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user name.';
                }
                field("Password (External)"; Rec."Password (External)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the password.';
                }
                field("Default"; Rec."Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default.';
                }
            }
        }
    }
}