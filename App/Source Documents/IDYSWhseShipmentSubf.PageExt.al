pageextension 11147665 "IDYS Whse. Shipment Subf." extends "Whse. Shipment Subform"
{
    layout
    {
        addafter("Qty. to Ship")
        {
            field("IDYS Quantity To Send"; Rec."IDYS Quantity To Send")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the quantity to send.';
                Visible = IDYSQtySentVisible;
            }
        }
        addafter("Qty. Shipped")
        {
            field("IDYS Quantity Sent"; Rec."IDYS Quantity Sent")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the quantity that has been sent.';
                Visible = IDYSQtySentVisible;
            }
        }
    }

    trigger OnOpenPage()
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        if IDYSSetup.Get() then
            IDYSQtySentVisible := IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents";
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.IDYSCalculateQtySent();
    end;

    var
        IDYSQtySentVisible: Boolean;
}