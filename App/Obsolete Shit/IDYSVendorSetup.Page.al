page 11147653 "IDYS Vendor Setup"
{
    Caption = 'ShipIT Vendor Setup';
    UsageCategory = None;
    PageType = List;
    SourceTable = "IDYS Vendor Setup";
    ObsoleteReason = 'Moved vendor specific settings to the vendor table.';
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
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor name.';
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