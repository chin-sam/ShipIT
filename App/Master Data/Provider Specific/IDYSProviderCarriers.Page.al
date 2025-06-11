page 11147686 "IDYS Provider Carriers"
{
    Caption = 'Carriers';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
#if BC17 or BC18 or BC19 or BC20
    PromotedActionCategories = 'New,Process,Report,Line,Provider';
#endif
    SourceTable = "IDYS Provider Carrier";
    UsageCategory = Lists;
    ApplicationArea = All;
    ContextSensitiveHelpPage = '96337932';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider.';
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
                #region [nShift]
                field("Actor Id"; Rec."Actor Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actor id.';
                    Editable = false;
                    Visible = IsnShiftShip;
                }
                #endregion
                #region [Sendcloud]
                field("Shipping Methods"; Rec."Shipping Methods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of shipping methods.';
                    Editable = false;
                }
                field("Use Volume Weight"; Rec."Use Volume Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this carrier expects the volume weight to be used in case volume weight is higher than actual weight.';
                    Visible = IsSendcloud;
                }
                field("Volume Weight Convers. Factor"; Rec."Volume Weight Convers. Factor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the conversion factor that the carrier applies when determining the weight based on volume. The formula = (length * width * height) / conversion factor';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with Conversion factors';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }
                #endregion
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
                action(Defaults)
                {
                    Caption = 'Defaults';
                    Image = DefaultDimension;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    RunObject = Page "IDYS Carrier Defaults";
                    RunPageLink = "Entry No." = field("Entry No.");
                    RunPageView = sorting("Entry No.");
                    ApplicationArea = All;
                    ToolTip = 'Opens the carrier defaults page.';
                }
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
                    RunObject = Page "IDYS Provider Booking Profiles";
                    RunPageLink = "Carrier Entry No." = field("Entry No."), Provider = field(Provider);
                    RunPageView = sorting("Carrier Entry No.");
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

                actionref(Defaults_Promoted; Defaults) { }
                actionref("Booking Profiles_Promoted"; "Booking Profiles") { }
            }
            group(Category_Category5)
            {
                Caption = 'Provider', Comment = 'Generated from the PromotedActionCategories property index 4.';
            }
        }
#endif
    }

    trigger OnOpenPage()
    var
        IDYSProvider: Enum "IDYS Provider";
    begin
        if Evaluate(IDYSProvider, Rec.GetFilter(Provider)) then begin
            IsSendcloud := (IDYSProvider = IDYSProvider::Sendcloud);
            IsnShiftShip := (IDYSProvider = IDYSProvider::"Delivery Hub");
        end;
    end;

    var
        IsSendcloud: Boolean;
        IsnShiftShip: Boolean;
}