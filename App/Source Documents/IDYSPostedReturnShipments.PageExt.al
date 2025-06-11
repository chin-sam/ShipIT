pageextension 11147662 "IDYS Posted Return Shipments" extends "Posted Return Shipments"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("IDYS Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Source Document Table No." = const(6650), "Source Document No." = field("No.");
                Visible = not ShowUnpostedTO;
            }
            part("IDYS Unp. Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Source Document Table No." = const(38), "Source Document No." = field("No."), "Source Document Type" = const("5");
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
                    Visible = not ShowUnpostedTO;

                    trigger OnAction()
                    var
                        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentManagement.ReturnShipment_CreateTransportOrder(Rec, false);
                    end;
                }
            }
        }
        addfirst("&Return Shpt.")
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

                    trigger OnAction()
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        if ShowUnpostedTO then begin
                            Rec.TestField("Return Order No.");
                            IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Purchase Header", "Purchase Document Type"::"Return Order".AsInteger(), Rec."Return Order No.")
                        end else
                            IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Return Shipment Header", 0, Rec."No.");
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
                    Visible = IDYSIsnShiftShip;
                    ToolTip = 'View a list of the selected Service Levels for this document.';
                    RunObject = page "IDYS Source Document Services";
                    RunPageLink = "Table No." = const(6650), "Document No." = field("No.");
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
        IDYSIsnShiftShip := IDYSProviderMgt.IsProviderEnabled(Enum::"IDYS Provider"::"Delivery Hub", false);
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSIsnShiftShip: Boolean;
        ShowUnpostedTO: Boolean;
}