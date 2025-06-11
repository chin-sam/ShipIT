pageextension 11147677 "IDYS Posted Return Receipts" extends "Posted Return Receipts"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("IDYS Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Source Document Table No." = const(36), "Source Document No." = field("Return Order No."), "Source Document Type" = const("5");
                Visible = ShowUnpostedTO;
            }
        }
    }

    actions
    {
        addbefore("&Navigate")
        {
            group("IDYS ShipIT Actions")
            {
                Caption = 'ShipIT';
                Image = SalesShipment;

                action("IDYS Create Transport Order")
                {
                    Caption = 'Create Transport Order';
                    Image = NewDocument;
                    ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
#endif
                    ToolTip = 'Creates a transport order.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Removed due to wrongfully implemented flow';
                    ObsoleteTag = '21.0';
                    Visible = false;

                    trigger OnAction()
                    begin
                        ;
                    end;
                }
            }
        }
        addfirst("&Return Rcpt.")
        {
            group("IDYS ShipIT Navigate")
            {
                Caption = 'ShipIT';
                Image = SalesShipment;

                action("IDYS Transport Orders")
                {
                    Caption = 'Transport Orders';
                    Image = Documents;
                    ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
#endif
                    ToolTip = 'View a list of the available Transport Orders for this document.';
                    Visible = ShowUnpostedTO;

                    trigger OnAction()
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Sales Header", "Sales Document Type"::"Return Order".AsInteger(), Rec."Return Order No.");
                    end;
                }
                action("IDYS Service Levels")
                {
                    Caption = 'Service Levels (Other)';
                    ApplicationArea = All;
                    Image = SetPriorities;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
#endif                    
                    ToolTip = 'View a list of the selected Service Levels for this document.';
                    RunObject = page "IDYS Source Document Services";
                    RunPageLink = "Table No." = const(6660), "Document No." = field("No.");
                    RunPageMode = View;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Removed due to wrongfully implemented flow';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
#pragma warning disable AL0432
        addlast(Category_Process)
        {
            actionref("IDYS Create Transport Order_Promoted"; "IDYS Create Transport Order")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Removed due to wrongfully implemented flow';
                ObsoleteTag = '21.0';
                Visible = false;
            }
            actionref("IDYS Transport Orders_Promoted"; "IDYS Transport Orders")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Removed due to wrongfully implemented flow';
                ObsoleteTag = '21.0';
                Visible = false;
            }
            actionref("IDYS Service Levels_Promoted"; "IDYS Service Levels")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Removed due to wrongfully implemented flow';
                ObsoleteTag = '21.0';
                Visible = false;
            }
        }
#pragma warning restore
#endif
    }
    trigger OnOpenPage()
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        ShowUnpostedTO := IDYSSetup.Get() and (IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents");
    end;

    var
        ShowUnpostedTO: Boolean;
}