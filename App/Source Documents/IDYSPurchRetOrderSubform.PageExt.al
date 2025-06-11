pageextension 11147661 "IDYS Purch. Ret. Order Subform" extends "Purchase Return Order Subform"
{
    layout
    {
        addafter("Return Qty. to Ship")
        {
            field("IDYS Quantity To Send"; Rec."IDYS Quantity To Send")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity to send.';
                Visible = IDYSQtySentVisible;
            }

            field("IDYS Quantity Sent"; Rec."IDYS Quantity Sent")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity that has been sent.';
                Visible = IDYSQtySentVisible;
            }

            field("IDYS Tracking No."; Rec."IDYS Tracking No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the tracking number.';
            }

            field("IDYS Tracking URL"; Rec."IDYS Tracking URL")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the tracking URL.';
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

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.TestField("IDYS Quantity Sent", 0);
    end;

    var
        IDYSQtySentVisible: Boolean;
}