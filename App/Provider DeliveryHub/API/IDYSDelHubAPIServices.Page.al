page 11147715 "IDYS DelHub API Services"
{
    Caption = 'Available services';
    Editable = false;
    PageType = List;
    SourceTable = "IDYS DelHub API Services";
    UsageCategory = Lists;
    ContextSensitiveHelpPage = '96567323';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                }

                field("Booking Profile Description"; Rec."Booking Profile Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the booking profile description.';
                }

                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country code.';
                }

                field("Service Level Code (Other)"; Rec."Service Level Code (Other)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service level code (other).';
                    Visible = false;
                }
                field("Service Level Code"; Rec."Service Level Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Service Level Code.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Is Default", "Actor Id");
    end;
}