pageextension 11147655 "IDYS Pst. Service Shpt. Lines" extends "Posted Service Shipment Lines"
{
    layout
    {
        addafter(Quantity)
        {
            field("IDYS Quantity To Send"; Rec."IDYS Quantity To Send")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies the quantiy to send.';
                Visible = IDYSQtySentVisible;
            }

            field("IDYS Quantity Sent"; Rec."IDYS Quantity Sent")
            {
                ApplicationArea = Service;
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
            IDYSQtySentVisible := IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Posted documents";
    end;

    var
        IDYSQtySentVisible: Boolean;
}