pageextension 11147671 "IDYS Posted Return Rcpt Subf." extends "Posted Return Receipt Subform"
{
    //NOTE - Obsolete - Removed due to wrongfully implemented flow
    layout
    {
        addafter(Quantity)
        {
            field("IDYS Quantity To Send"; Rec."IDYS Quantity To Send")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity to send.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Removed due to wrongfully implemented flow';
                ObsoleteTag = '21.0';
                Visible = false;
            }

            field("IDYS Quantity Sent"; Rec."IDYS Quantity Sent")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity that has been sent.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Removed due to wrongfully implemented flow';
                ObsoleteTag = '21.0';
                Visible = false;
            }

            field("IDYS Tracking No."; Rec."IDYS Tracking No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the tracking number.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Removed due to wrongfully implemented flow';
                ObsoleteTag = '21.0';
                Visible = false;
            }

            field("IDYS Tracking URL"; Rec."IDYS Tracking URL")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the tracking URL.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Removed due to wrongfully implemented flow';
                ObsoleteTag = '21.0';
                Visible = false;
            }
        }
    }
}