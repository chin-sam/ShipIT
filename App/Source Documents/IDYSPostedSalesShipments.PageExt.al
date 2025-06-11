pageextension 11147646 "IDYS Posted Sales Shipments" extends "Posted Sales Shipments"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("IDYS Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Source Document Table No." = const(110), "Source Document No." = field("No.");
                Visible = not ShowUnpostedTO;
            }
            part("IDYS Unp. Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Source Document Table No." = const(36), "Source Document Type" = const("1"), "Source Document No." = field("Order No.");
                Visible = ShowUnpostedTO;
            }
        }
    }

    actions
    {
        addafter("F&unctions")
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
                    Visible = not ShowUnpostedTO;

                    trigger OnAction()
                    var
                        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentManagement.SalesShipment_CreateTransportOrder(Rec, false);
                    end;
                }
            }
        }
        addfirst("&Shipment")
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
                    PromotedCategory = Category5;
#endif
                    ToolTip = 'View a list of the available Transport Orders for this document.';

                    trigger OnAction()
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        if ShowUnpostedTO then begin
                            Rec.TestField("Order No.");
                            IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Sales Header", "Sales Document Type"::Order.AsInteger(), Rec."Order No.")
                        end else
                            IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Sales Shipment Header", 0, Rec."No.");
                    end;
                }
                action("IDYS Service Levels")
                {
                    Caption = 'Service Levels (Other)';
                    ApplicationArea = All;
                    Image = SetPriorities;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Category5;
#endif
                    Visible = IDYSIsnShiftShip;
                    ToolTip = 'View a list of the selected Service Levels for this document.';
                    RunObject = page "IDYS Source Document Services";
                    RunPageLink = "Table No." = const(110), "Document No." = field("No.");
                    RunPageMode = View;
                }
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        addlast(Category_Process)
        {
            actionref("IDYS Create Transport Order_Promoted"; "IDYS Create Transport Order")
            {
            }
        }
        addlast(Category_Category5)
        {
            actionref("IDYS Transport Orders_Promoted"; "IDYS Transport Orders")
            {
            }
            actionref("IDYS Service Levels_Promoted"; "IDYS Service Levels")
            {
            }
        }
#endif
    }

    trigger OnOpenPage()
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        ShowUnpostedTO := IDYSSetup.Get() and (IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents");
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("IDYS Provider");
        IDYSIsnShiftShip := IDYSProviderMgt.IsProviderEnabled(Rec."IDYS Provider", Enum::"IDYS Provider"::"Delivery Hub");
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSIsnShiftShip: Boolean;
        ShowUnpostedTO: Boolean;
}