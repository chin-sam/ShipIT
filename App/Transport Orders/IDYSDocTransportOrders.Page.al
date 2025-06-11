page 11147660 "IDYS Doc. Transport Orders"
{
    Caption = 'Transport Orders';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "IDYS Transport Order Line";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Transport Order No."; Rec."Transport Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transport order no..';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item no..';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant code..';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Describer the transport order.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                    Visible = false;
                }
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the base quantity.';
                }
                field("Order Header Status"; Rec."Order Header Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the transport order.';
                }
            }
        }
    }
}