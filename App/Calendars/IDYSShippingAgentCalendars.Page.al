page 11147665 "IDYS Shipping Agent Calendars"
{

    ApplicationArea = All;
    Caption = 'Shipping Agent Calendars';
    PageType = List;
    SourceTable = "IDYS Shipping Agent Calendar";
    ContextSensitiveHelpPage = '96501775';
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shipping Agent Code.';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shipping Agent Service Code.';
                }
                field("Pick-up Time From"; Rec."Pick-up Time From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Pick-up Time From.';
                }
                field("Pick-up Time To"; Rec."Pick-up Time To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Pick-up Time To.';
                }
                field("Pick-up Base Calendar Code"; Rec."Pick-up Base Calendar Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Pick-up Base Calendar Code.';
                }
                field("Delivery Time From"; Rec."Delivery Time From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Delivery Time From.';
                }
                field("Delivery Time To"; Rec."Delivery Time To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Delivery Time To.';
                }
                field("Delivery Base Calendar Code"; Rec."Delivery Base Calendar Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Delivery Base Calendar Code.';
                }
            }
        }
    }
}