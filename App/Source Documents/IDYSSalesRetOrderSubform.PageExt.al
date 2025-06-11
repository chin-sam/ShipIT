pageextension 11147659 "IDYS Sales Ret. Order Subform" extends "Sales Return Order Subform"
{
    layout
    {
        addafter("Return Qty. to Receive")
        {
            field("IDYS Quantity To Send"; Rec."IDYS Quantity To Send")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity to send.';
            }

            field("IDYS Quantity Sent"; Rec."IDYS Quantity Sent")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity that has been sent.';
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

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.TestField("IDYS Quantity Sent", 0);
    end;
}