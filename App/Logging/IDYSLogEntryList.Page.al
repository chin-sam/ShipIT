page 11147677 "IDYS Log Entry List"
{
    ApplicationArea = All;
    Caption = 'Transport Order Log';
    PageType = List;
    SourceTable = "IDYS Transport Order Log Entry";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = Administration;
    CardPageId = "IDYS Log Entry Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the log entry no.';
                }
                field("Transport Order No."; Rec."Transport Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transport order no.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the logging level.';
                }
                field("Date/Time"; Rec."Date/Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user ID.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClearLog)
            {
                ApplicationArea = All;
                Caption = 'Delete All Entries';
                Image = ClearLog;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ToolTip = 'Deletes all log entries.';

                trigger OnAction()
                var
                    Log: Record "IDYS Transport Order Log Entry";
                begin
                    Log.DeleteAll();
                    CurrPage.Update();
                end;
            }
        }

#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ClearLog_Promoted; ClearLog)
                {
                }
            }
        }
#endif
    }

}
