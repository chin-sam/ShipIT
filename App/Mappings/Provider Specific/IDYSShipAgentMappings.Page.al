page 11147696 "IDYS Ship. Agent Mappings"
{
    Caption = 'Shipping Agent Mappings';
    UsageCategory = Lists;
    ApplicationArea = All;
    PageType = List;
    SourceTable = "IDYS Ship. Agent Mapping";
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
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                }
                field("Blank Invoice Address"; Rec."Blank Invoice Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Blank the Invoice Address. This setting can only be used with provider nShift Ship.';
                    Enabled = IsnShiftShip;
                }
                field(Insure; Rec.Insure)
                {
                    Visible = IDYSIsTranssmartEnabled and IDYSInsuranceEnabled;
                    Enabled = (CurrentProvider = CurrentProvider::Transsmart);
                    ApplicationArea = All;
                    ToolTip = 'Specifies if insurance is enabled for this carrier.';
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
        area(Processing)
        {
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
                ToolTip = 'You can set the default package per carrier level.';
                Visible = IsEasyPost;
                RunObject = page "IDYS B. Prof. Packages";
                RunPageLink = "Carrier Entry No." = field("Carrier Entry No."), Provider = field(Provider);
            }

            action(SetStyles)
            {
                ApplicationArea = All;
                Caption = 'Set Mandatory Fields Length';
                Image = Setup;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ToolTip = 'Sets Mandatory Fields Length';
                Visible = true;

                trigger OnAction()
                var
                    IDYSFieldSetup: Record "IDYS Field Setup";
                    IDYSFieldSetupList: Page "IDYS Field Setup List";
                begin
                    IDYSFieldSetupList.SetGlobalValues(Rec.RecordId);
                    IDYSFieldSetup.SetRange("Record Identifier", Rec.RecordId);
                    IDYSFieldSetupList.SetTableView(IDYSFieldSetup);
                    IDYSFieldSetupList.RunModal();
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SetDefaultPackage_Promoted; SetDefaultPackage) { }
                actionref(SetStyles_Promoted; SetStyles) { }
                actionref("Shipping A&gent Service Mappings_Promoted"; "Shipping A&gent Service Mappings") { }
            }
        }
#endif
    }


    trigger OnAfterGetRecord()
    begin
        IsnShiftShip := IDYSProviderMgt.IsProviderEnabled(Rec.Provider, "IDYS Provider"::"Delivery Hub");
        IsEasyPost := IDYSProviderMgt.IsProviderEnabled(Rec.Provider, "IDYS Provider"::EasyPost);
        CurrentProvider := Rec.Provider;
    end;

    trigger OnOpenPage()
    begin
        IDYSIsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Transsmart, false);
        IDYSInsuranceEnabled := IDYSProviderMgt.IsInsuranceEnabled("IDYS Provider"::Transsmart);
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IsnShiftShip: Boolean;
        IsEasyPost: Boolean;
        CurrentProvider: Enum "IDYS Provider";
        IDYSIsTranssmartEnabled: Boolean;
        IDYSInsuranceEnabled: Boolean;
}

