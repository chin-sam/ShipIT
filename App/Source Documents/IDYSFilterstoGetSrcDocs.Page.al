page 11147667 "IDYS Filters to Get Src. Docs."
{
    Caption = 'Source Document Filter Templates';
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "IDYS Transport Source Filter";
    CardPageId = "IDYS Source Doc. Filter Card";
    UsageCategory = Lists;
    ApplicationArea = All;
    ContextSensitiveHelpPage = '22904863';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document filter template code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the source document filter template.';
                }
                field("Shipping Agent Code Filter"; Rec."Shipping Agent Code Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent code filter.';
                }
                field("Shipping Agent Service Filter"; Rec."Shipping Agent Service Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service filter.';
                }
                field("Shipment Method Code Filter"; Rec."Shipment Method Code Filter")
                {
                    ApplicationArea = All;
                    Visible = IDYSIsTranssmartEnabled or IDYSIsCargosonEnabled;
                    ToolTip = 'Specifies the shipping method filter.';
                }
                field("Item No. Filter"; Rec."Item No. Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the item no. filter.';
                }
                field("Variant Code Filter"; Rec."Variant Code Filter")
                {
                    ApplicationArea = Planning;
                    Visible = false;
                    ToolTip = 'Specifies the variant code filter.';
                }
                field("Unit of Measure Filter"; Rec."Unit of Measure Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the unit of measure filter.';
                }
                field("E-Mail Type Filter"; Rec."E-Mail Type Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the e-mail type filter.';
                }
                field("Cost Center Filter"; Rec."Cost Center Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the cost center filter.';
                }
                field("Location Code Filter"; Rec."Location Code Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the location code filter.';
                }
                field("Sell-to Customer No. Filter"; Rec."Sell-to Customer No. Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the sell-to customer no. filter.';
                }
                field("Buy-from Vendor No. Filter"; Rec."Buy-from Vendor No. Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the buy-from vendor no. filter.';
                }
                field("Customer No. Filter"; Rec."Customer No. Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the customer no. filter.';
                }
                field("From Posting Date Calculation"; Rec."From Posting Date Calculation")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the from posting date filter.';
                }
                field("To Posting Date Calculation"; Rec."To Posting Date Calculation")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the to posting date filter.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MakeWorksheetLines)
            {
                Caption = 'Make Worksheet Lines';
                Image = Start;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ApplicationArea = All;
                ToolTip = 'Creates worksheet lines.';

                trigger OnAction();
                var
                    RunSourceDocFilter: Codeunit "IDYS Run Source Doc. Filter";
                    NoCreated: Integer;
                    WorksheetLinesMadeMsg: Label '%1 Worksheet Lines were made with filter ''%2''.', Comment = '%1 = Integer value i, %2 = Filter description.';
                    WorksheetLinesMadeTok: Label '206f9a00-bc6e-4bf2-9d1b-99215709f7a4', Locked = true;
                begin
                    NoCreated := RunSourceDocFilter.Execute(Rec);

                    IDYSNotificationManagement.SendNotification(WorksheetLinesMadeTok, StrSubstNo(WorksheetLinesMadeMsg, NoCreated, Rec.Description));
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(MakeWorksheetLines_Promoted; MakeWorksheetLines) { }
            }
        }
#endif
    }

    trigger OnOpenPage()
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        IDYSIsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Transsmart, false);
        IDYSIsCargosonEnabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Cargoson, false);
    end;

    var
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        IDYSIsTranssmartEnabled: Boolean;
        IDYSIsCargosonEnabled: Boolean;
}

