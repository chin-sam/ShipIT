page 11147642 "IDYS Service Levels (Time)"
{
    Caption = 'Service Levels (Time)';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS Service Level (Time)";
    UsageCategory = Lists;
    ApplicationArea = All;
    ContextSensitiveHelpPage = '22904924';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service level (time) code.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the service level (time).';
                }
            }
        }
    }
}