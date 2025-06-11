page 11147712 "IDYS SC Parcel Errors"
{
    PageType = ListPart;
    SourceTable = "IDYS SC Parcel Error";
    Caption = 'Errors';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Parcel Identifier"; Rec."Parcel Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the parcel for which the error occured.';
                    Style = Unfavorable;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message that occured when processing the parcel request.';
                    Style = Unfavorable;
                }
            }
        }
    }
}
