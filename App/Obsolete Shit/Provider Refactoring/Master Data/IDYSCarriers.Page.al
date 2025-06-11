page 11147640 "IDYS Carriers"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'External Carriers';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
#if BC17 or BC18 or BC19 or BC20
    PromotedActionCategories = 'New,Process,Report,Line,External';
#endif      
    SourceTable = "IDYS Carrier";
    UsageCategory = None;
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
                    ToolTip = 'Specifies the carrier code.';
                }
                field(Name; Rec.Name)
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                }
                field(Mapped; Rec.Mapped)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the carries is mapped.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("Booking Profiles")
                {
                    Caption = 'Booking Profiles';
                    Image = CheckRulesSyntax;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    RunObject = Page "IDYS Booking Profiles";
                    RunPageLink = "Carrier Code (External)" = field("Code");
                    RunPageView = sorting("Carrier Code (External)");
                    ApplicationArea = All;
                    ToolTip = 'Opens the booking profiles page.';
                }
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
            }
            group(Category_Category4)
            {
                Caption = 'Line', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref("Booking Profiles_Promoted"; "Booking Profiles")
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'External', Comment = 'Generated from the PromotedActionCategories property index 4.';
            }
        }
#endif
    }
}