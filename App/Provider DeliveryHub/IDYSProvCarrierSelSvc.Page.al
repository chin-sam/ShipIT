page 11147745 "IDYS Prov. Carrier Sel. Svc."
{
    Caption = 'Services';
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = List;
    SourceTable = "IDYS Prov. Carrier Select Pck.";
    UsageCategory = None;
    ContextSensitiveHelpPage = '23199761';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Include; Rec.Include)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which booking profile is going to be used at the package level';
                    Editable = false;
                }
                field("Service Level Code"; Rec."Service Level Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Service Level Code.';
                    Editable = false;
                }

                field("Service Level Code Description"; Rec."Service Level Code Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Service Level Code Description.';
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Service Level Code", "Service Level Code Description");
    end;
}

