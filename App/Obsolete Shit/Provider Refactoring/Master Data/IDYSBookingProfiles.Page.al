page 11147641 "IDYS Booking Profiles"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Booking Profiles';
    DataCaptionFields = "Carrier Code (External)";
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS Booking Profile";
    UsageCategory = None;
    ContextSensitiveHelpPage = '22282322';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code.';
                    ApplicationArea = All;
                }

                field("Description"; Rec."Description")
                {
                    ToolTip = 'Specifies the description.';
                    ApplicationArea = All;
                }

                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                }

                field("Service Level Code (Time)"; Rec."Service Level Code (Time)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service level code (time).';
                }

                field("Service Level Code (Other)"; Rec."Service Level Code (Other)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service level code (other).';
                }

                field(Mapped; Rec.Mapped)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the record is mapped.';
                }
            }
        }
    }
}