page 11147655 "IDYS Order Address Setup"
{
    Caption = 'ShipIT Order Address Setup';
    UsageCategory = None;
    PageType = List;
    SourceTable = "IDYS Order Address Setup";
    ObsoleteReason = 'Moved ship-to address specific settings to the ship-to address table.';
    ObsoleteState = Pending;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor no..';
                }

                field("Order Address Code"; Rec."Order Address Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order address code.';
                }

                field("E-Mail Type"; Rec."E-Mail Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the e-mail type.';
                }

                field("Cost Center"; Rec."Cost Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost center.';
                }
            }
        }
    }
}