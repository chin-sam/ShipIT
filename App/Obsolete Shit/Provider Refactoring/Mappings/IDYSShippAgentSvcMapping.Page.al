page 11147657 "IDYS Shipp. Agent Svc. Mapping"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Shipping Agent Service Mapping';
    DataCaptionFields = "Shipping Agent Code";
    PageType = List;
    SourceTable = "IDYS Shipp. Agent Svc. Mapping";
    UsageCategory = None;
    PopulateAllFields = true;
    ContextSensitiveHelpPage = '23167055';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent code.';
                }
                field("Shipping Agent Name"; Rec."Shipping Agent Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the shipping agent name.';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service code.';
                }
                field("Shipping Agent Service Desc."; Rec."Shipping Agent Service Desc.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Describes the shipping agent service.';
                }
                field("Booking Profile Code (Ext.)"; Rec."Booking Profile Code (Ext.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the booking profile code (external).';
                }
            }
        }
    }
}