page 11147703 "IDYS Transsmart Ins. Charges"
{
    Caption = 'Insurance Charges';
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "IDYS Prov. Carrier Select Pck.";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Charge Name"; Rec."Charge Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the charge name.';
                    Editable = false;
                }
                field("Charge Amount"; Rec."Charge Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the charge amount.';
                    Editable = false;
                }
            }
        }
    }
}