page 11147676 "IDYS Arch Transport Order List"
{
    Caption = 'Archived Transport Orders';
    CardPageID = "IDYS Transport Order Card";
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;
    PageType = List;
#if BC17 or BC18 or BC19 or BC20
    PromotedActionCategories = 'New,Process,Report,Transport Order';
#endif
    SourceTable = "IDYS Transport Order Header";
    SourceTableView = where(Status = const(Archived));
    ContextSensitiveHelpPage = '22937633';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no..';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status.';
                }

                field("Archived On"; Rec."Archived On")
                {
                    ToolTip = 'Specifies the status.';
                    ApplicationArea = All;
                }

                field("Archived By"; Rec."Archived By")
                {
                    ToolTip = 'Specifies the user that has archived the transport order.';
                    ApplicationArea = All;
                }

                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent code.';
                }

                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service code.';
                }

                field("Type (Pick-up)"; Rec."Source Type (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type.';
                }

                field("No. (Pick-up)"; Rec."No. (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no..';
                }

                field("Name (Pick-up)"; Rec."Name (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name.';
                }

                field("City (Pick-up)"; Rec."City (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city.';
                }

                field("Type (Ship-to)"; Rec."Source Type (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type.';
                }

                field("No. (Ship-to)"; Rec."No. (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no..';
                }

                field("Code (Ship-to)"; Rec."Code (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code.';
                }

                field("Name (Ship-to)"; Rec."Name (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name.';
                }

                field("City (Ship-to)"; Rec."City (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Reports)
            {
                Caption = 'Reports';
                ToolTip = 'Link this transport order to one or more reports.';
                RunObject = Page "IDYS Transport Order Reports";
                Image = Link;
                ApplicationArea = All;
            }
            action("Open in Dashboard")
            {
                Caption = 'Open in Dashboard';
                Image = DocInBrowser;
                ToolTip = 'Open this transport order in the provider''s portal.';
                ApplicationArea = All;

                trigger OnAction();
                begin
                    LoadSetup();
                    IDYSIProvider := Rec.Provider;
                    IDYSIProvider.OpenInDashboard(Rec);
                end;
            }
            action("Overview Dashboard")
            {
                Caption = 'Overview Dashboard';
                Image = DocInBrowser;
                ToolTip = 'Open all transport orders in the provider''s portal.';
                ApplicationArea = All;

                trigger OnAction();
                begin
                    LoadSetup();
                    IDYSIProvider := Rec.Provider;
                    IDYSIProvider.OpenAllInDashboard();
                end;
            }
            action(Trace)
            {
                Caption = 'Trace';
                Image = Track;
                ToolTip = 'Trace this shipment on the shipping agent''s website.';
                ApplicationArea = All;

                trigger OnAction();
                begin
                    IDYSTransportOrderMgt.Trace(Rec);
                end;
            }
        }

        area(Processing)
        {
            action(Unarchive)
            {
                Caption = 'Restore';
                Image = Restore;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
#endif
                ToolTip = 'Move this order back to the transport order list.';
                ApplicationArea = All;

                trigger OnAction();
                var
                    TransportOrderHeader: Record "IDYS Transport Order Header";
                begin
                    CurrPage.SaveRecord();

                    CurrPage.SetSelectionFilter(TransportOrderHeader);
                    if TransportOrderHeader.FindSet() then
                        repeat
                            IDYSTransportOrderMgt.Unarchive(TransportOrderHeader);
                        until TransportOrderHeader.Next() = 0;

                    CurrPage.Update(false);
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref(Unarchive_Promoted; Unarchive)
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
            }
            group(Category_Category4)
            {
                Caption = 'Transport Order', Comment = 'Generated from the PromotedActionCategories property index 3.';
            }
        }
#endif
    }

    trigger OnOpenPage()
    begin
        LoadSetup();
    end;

    local procedure LoadSetup()
    begin
        if not SetupLoaded then begin
            SetupLoaded := true;
            if not IDYSSetup.Get() then
                IDYSSetup.Init();
        end;
    end;

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        IDYSIProvider: Interface "IDYS IProvider";
        SetupLoaded: Boolean;
}