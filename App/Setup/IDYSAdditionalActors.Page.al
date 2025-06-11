page 11147698 "IDYS Additional Actors"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "IDYS Additional Actor";
    Caption = 'Additional Actors';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Actor Id"; Rec."Actor Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Additional Actor Id';
                }

            }
        }
    }
}