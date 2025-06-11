page 11147652 "IDYS Customer Setup"
{
    Caption = 'ShipIT Customer Setup';
    UsageCategory = None;
    PageType = List;
    SourceTable = "IDYS Customer Setup";
    ObsoleteReason = 'Moved customer specific settings to the customer table.';
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
                    ToolTip = 'Specifies the customer no..';
                }

                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
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
                    ToolTip = 'Specifies the account no..';
                }
            }
        }
    }
}