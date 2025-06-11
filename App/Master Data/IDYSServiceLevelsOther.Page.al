page 11147643 "IDYS Service Levels (Other)"
{
    Caption = 'Service Levels (Other)';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS Service Level (Other)";
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
                    ToolTip = 'Specifies the service level (other) code.';
                }
                field("Service Code"; Rec."Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Service Level Code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the service level (other).';
                }
            }
        }
    }
}