page 11147658 "IDYS Transport Order Reports"
{
    PageType = List;
    SourceTable = "IDYS Transport Order Report";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(ReportID; Rec.ReportID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the resport id.';
                }

                field(ReportName; Rec.ReportName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the report name.';
                }
            }
        }
    }
}