page 11147646 "IDYS Cost Centers"
{
    Caption = 'Cost Centers';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS Cost Center";
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
                    ToolTip = 'Specifies the cost center code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost center name.';
                }
            }
        }
    }
}