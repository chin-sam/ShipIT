pageextension 11147652 "IDYS Posted Transfer Shipments" extends "Posted Transfer Shipments"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("IDYS Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = Location;
                SubPageLink = "Source Document Table No." = const(5744), "Source Document No." = field("No.");
                Visible = not ShowUnpostedTO;
            }
            part("IDYS Unp. Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Source Document Table No." = const(5740), "Source Document No." = field("Transfer Order No.");
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
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
#endif
                    ApplicationArea = Location;
                    ToolTip = 'Creates a transport order.';
                    Visible = not ShowUnpostedTO;

                    trigger OnAction()
                    var
                        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentManagement.TransferShipment_CreateTransportOrder(Rec, false);
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
                    ApplicationArea = Location;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Category4;
#endif
                    ToolTip = 'View a list of the available Transport Orders for this document.';

                    trigger OnAction()
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        if ShowUnpostedTO then begin
                            Rec.TestField("Transfer Order No.");
                            IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Transfer Header", 0, Rec."Transfer Order No.")
                        end else
                            IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Transfer Shipment Header", 0, Rec."No.");
                    end;
                }
                action("IDYS Service Levels")
                {
                    Caption = 'Service Levels (Other)';
                    ApplicationArea = All;
                    Image = SetPriorities;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Category4;
#endif
                    Visible = IDYSIsnShiftShip;
                    ToolTip = 'View a list of the selected Service Levels for this document.';
                    RunObject = page "IDYS Source Document Services";
                    RunPageLink = "Table No." = const(5744), "Document No." = field("No.");
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
        addlast(Category_Category4)
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