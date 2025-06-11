pageextension 11147650 "IDYS Posted Transfer Shipment" extends "Posted Transfer Shipment"
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

        modify("Shipment Method Code")
        {
            Editable = true;
        }
        modify("Shipping Agent Code")
        {
            Editable = true;
        }
        modify("Shipping Agent Service Code")
        {
            Editable = true;
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
                    ApplicationArea = Location;
                    Promoted = true;
                    PromotedCategory = Process;
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
                    Promoted = true;
                    PromotedCategory = Category4;
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
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = IDYSIsnShiftShip;
                    ToolTip = 'View a list of the selected Service Levels for this document.';
                    RunObject = page "IDYS Source Document Services";
                    RunPageLink = "Table No." = const(5744), "Document No." = field("No.");
                    RunPageMode = View;
                }
            }
        }
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