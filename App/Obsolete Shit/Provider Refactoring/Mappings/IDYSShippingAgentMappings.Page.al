page 11147656 "IDYS Shipping Agent Mappings"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Shipping Agent Mappings';
    UsageCategory = None;
    PageType = List;
    SourceTable = "IDYS Shipping Agent Mapping";
    ContextSensitiveHelpPage = '23167055';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent code.';
                }
                field("Shipping Agent Name"; Rec."Shipping Agent Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the shipping agen name.';
                }
                field("Carrier Code (External)"; Rec."Carrier Code (External)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier code (external).';
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
                Image = Line;
                action("Shipping A&gent Service Mappings")
                {
                    Caption = 'Ship. Agent Service Mappings';
                    Image = CheckList;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    RunObject = Page "IDYS Ship. Agent Svc. Mapping";
                    RunPageLink = "Shipping Agent Code" = field("Shipping Agent Code");
                    ApplicationArea = All;
                    ToolTip = 'Opens the shipping agent service mappings page.';
                }
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Shipping A&gent Service Mappings_Promoted"; "Shipping A&gent Service Mappings")
                {
                }
            }
        }
#endif
    }
}