page 11147699 "IDYS Ship. Agent Svc. Mapping"
{
    Caption = 'Shipping Agent Service Mapping';
    DataCaptionFields = "Shipping Agent Code";
    PageType = List;
    SourceTable = "IDYS Ship. Agent Svc. Mapping";
    UsageCategory = None;
    PopulateAllFields = true;
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
                    Editable = false;
                    Visible = false;
                }
                field("Shipping Agent Name"; Rec."Shipping Agent Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the shipping agent name.';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service code.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Shipping Agent Service Desc."; Rec."Shipping Agent Service Desc.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Describes the shipping agent service.';
                }
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider.';
                }
                field("Booking Profile Description"; Rec."Booking Profile Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the booking profile description.';
                    Visible = (ViewMode = ViewMode::Default);
                }
                field(Insure; Rec.Insure)
                {
                    Visible = InsuranceVisible;
                    ApplicationArea = All;
                    ToolTip = 'Specifies if insurance is enabled for this service.';
                }
                field(IDYSOpenServices; IDYSOpenService)
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Booking Profiles';
                    ToolTip = 'Runs page with the possibility to select multiple profiles associated with specific carrier.';
                    Visible = (ViewMode = ViewMode::MultipleBookingProfiles);

                    trigger OnDrillDown()
                    var
                        SelectBookingProfiles: Page "IDYS Select Booking Profiles";
                    begin
                        SelectBookingProfiles.InitializePage(Rec."Shipping Agent Code", Rec."Shipping Agent Service Code", Rec."Carrier Entry No.");
                        SelectBookingProfiles.RunModal();
                        SetOpenService();
                    end;
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default booking profile.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Restructured with Sendcloud specific functionality.';
                    ObsoleteTag = '24.0';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(SetDefaultServices)
            {
                ApplicationArea = All;
                Caption = 'Set Default Services';
                Image = Default;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ToolTip = 'You can set the default services per booking profile level.';
                Visible = IsnShiftShip;

                trigger OnAction()
                var
                    SelectServiceLvlOther: Page "IDYS Select Service Lvl Other";
                    PageCaptionLbl: Label '%1 - %2', Locked = true;
                begin
                    // Initiate default services
                    SelectServiceLvlOther.SetParameters(StrSubstno(PageCaptionLbl, Rec."Shipping Agent Code", Rec."Shipping Agent Service Code"), Rec);
                    SelectServiceLvlOther.InitializePage(Rec."Carrier Entry No.", Rec."Booking Profile Entry No.");
                    SelectServiceLvlOther.RunModal();
                    CurrPage.Update();
                end;
            }

            action(RestoreDefaultServices)
            {
                ApplicationArea = All;
                Caption = 'Restore Default Services';
                Image = Restore;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ToolTip = 'You can restore the default services per booking profile level.';
                Visible = IsnShiftShip;

                trigger OnAction()
                begin
                    Rec.SetDefaultServices();
                    CurrPage.Update();
                end;
            }

            action(SetDefaultPackage)
            {
                ApplicationArea = All;
                Caption = 'Set Default Package';
                Image = UntrackedQuantity;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ToolTip = 'You can set the default package per booking profile level.';
                Visible = IsnShiftShip;
                RunObject = page "IDYS B. Prof. Packages";
                RunPageLink = "Carrier Entry No." = field("Carrier Entry No."), "Booking Profile Entry No." = field("Booking Profile Entry No.");
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SetDefaultServices_Promoted; SetDefaultServices)
                {
                }
                actionref(SetDefaultService_Promoted; SetDefaultServices)
                {
                    ObsoleteState = Pending;
                    Visible = false;
                    ObsoleteReason = 'Wrong action name';
                }
                actionref(RestoreDefaultServices_Promoted; RestoreDefaultServices)
                {
                }
                actionref(SetDefaultPackage_Promoted; SetDefaultPackage)
                {
                }
            }
        }
#endif
    }

    trigger OnAfterGetRecord()
    begin
        SetOpenService();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IDYSOpenService := IDYSOpenServicesLbl;
    end;

    local procedure SetOpenService()
    var
        IDYSvcBookingProfile: Record "IDYS Svc. Booking Profile";
    begin
        IDYSvcBookingProfile.SetRange("Shipping Agent Code", Rec."Shipping Agent Code");
        IDYSvcBookingProfile.SetRange("Shipping Agent Service Code", Rec."Shipping Agent Service Code");
        if IDYSvcBookingProfile.Count > 0 then
            IDYSOpenService := StrSubstNo(IDYSChangeServicesLbl, IDYSvcBookingProfile.Count)
        else
            IDYSOpenService := IDYSOpenServicesLbl;
    end;

    trigger OnOpenPage()
    var
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        if Rec.GetFilter("Shipping Agent Code") <> '' then
            if IDYSShipAgentMapping.Get(Rec.GetFilter("Shipping Agent Code")) then begin
                if IDYSShipAgentMapping.Provider in [IDYSShipAgentMapping.Provider::Sendcloud, IDYSShipAgentMapping.Provider::EasyPost] then
                    ViewMode := ViewMode::MultipleBookingProfiles;
                IsnShiftShip := (IDYSShipAgentMapping.Provider = IDYSShipAgentMapping.Provider::"Delivery Hub");
                InsuranceVisible := IDYSShipAgentMapping.Insure;
            end;
    end;

    var
        ViewMode: Option Default,MultipleBookingProfiles;
        IsnShiftShip: Boolean;
        InsuranceVisible: Boolean;
        IDYSOpenService: Text;
        IDYSOpenServicesLbl: Label 'Click here to select the booking profiles for this service.';
        IDYSChangeServicesLbl: Label '%1 booking profile(s) selected. Click here to view or change the profiles.', Comment = '%1 = No. of booking profiles selected';
}