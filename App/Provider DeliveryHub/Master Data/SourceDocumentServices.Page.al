page 11147719 "IDYS Source Document Services"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "IDYS Source Document Service";
    DataCaptionExpression = ThisPageCaption;
    Caption = 'Source Document Service Levels (Other)';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the document type.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the Document No..';
                }
                field("Service Level Code (Other)"; Rec."Service Level Code (Other)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Service level (Other).';
                    Visible = false;
                }

                field("Service Level Code"; Rec."Service Level Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Service Level Code.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        SalesOrder: Page "Sales Order";
        SalesReturnOrder: Page "Sales Return Order";
        PurchaseReturnOrder: Page "Purchase Return Order";
        PurchaseOrder: Page "Purchase Order";
        TransferOrder: Page "Transfer Order";
        ServiceOrder: Page "Service Order";
        PostedSalesShipment: Page "Posted Sales Shipment";
        PostedTransferShipment: Page "Posted Transfer Shipment";
        PostedTransferReceipt: Page "Posted Transfer Receipt";
        PostedReturnShipment: Page "Posted Return Shipment";
        PostedServiceShipment: Page "Posted Service Shipment";
        SourceType: Text;
        TransportOrderLbl: Label 'Transport Order';
    begin
        case Rec."Table No." of
            Database::"Sales Header":
                case Rec."Document Type" of
                    Rec."Document Type"::"1":
                        SourceType := SalesOrder.Caption();
                    Rec."Document Type"::"5":
                        SourceType := SalesReturnOrder.Caption();
                end;
            Database::"Purchase Header":
                case Rec."Document Type" of
                    Rec."Document Type"::"1":
                        SourceType := PurchaseOrder.Caption();
                    Rec."Document Type"::"5":
                        SourceType := PurchaseReturnOrder.Caption();
                end;
            Database::"Sales Shipment Header":
                SourceType := PostedSalesShipment.Caption();
            Database::"Transfer Header":
                SourceType := TransferOrder.Caption();
            Database::"Transfer Shipment Header":
                SourceType := PostedTransferShipment.Caption();
            Database::"Transfer Receipt Header":
                SourceType := PostedTransferReceipt.Caption();
            Database::"Service Header":
                case Rec."Document Type" of
                    Rec."Document Type"::"1":
                        SourceType := ServiceOrder.Caption();
                end;
            Database::"Service Shipment Header":
                SourceType := PostedServiceShipment.Caption();
            Database::"Return Shipment Header":
                SourceType := PostedReturnShipment.Caption();
            Database::"IDYS Transport Order Header":
                SourceType := TransportOrderLbl;
        end;

        ThisPageCaption := SourceType + ' ' + Rec."Document No.";
    end;

    var
        ThisPageCaption: Text;
}