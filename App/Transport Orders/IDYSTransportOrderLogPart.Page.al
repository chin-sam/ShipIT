page 11147673 "IDYS Transport Order Log Part"
{
    Caption = 'Transport Order Log Part';
    Editable = false;
    PageType = ListPart;
    SourceTable = "IDYS Transport Order Log Entry";
    SourceTableView = sorting("Transport Order No.", "Entry No.")
                      order(Descending);

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Date/Time"; Rec."Date/Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date/time.';
                }

                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user id.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }
            }
        }
    }
}