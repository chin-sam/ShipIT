page 11147654 "IDYS Ship-to Address Setup"
{
    Caption = 'ShipIT Ship-to Address Setup';
    UsageCategory = None;
    PageType = List;
    SourceTable = "IDYS Ship-to Address Setup";
    ObsoleteReason = 'Moved ship-to address specific settings to the ship-to address table.';
    ObsoleteState = Pending;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer no.';
                }

                field("Ship-to Address Code"; Rec."Ship-to Address Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ship-to address code.';
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
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the account no.';
                }
            }
        }
    }
}