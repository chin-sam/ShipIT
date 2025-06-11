page 11147674 "IDYS Transport Order Part"
{
    Caption = 'External Details';
    PageType = CardPart;
    SourceTable = "IDYS Transport Order Header";

    layout
    {
        area(Content)
        {
            field("Status (External)"; Rec."Status (External)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the status.';
            }

            field("Sub Status (External)"; Rec."Sub Status (External)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the status.';
                Visible = false;
            }

            field("Carrier Code (External)"; Rec."Carrier Code (External)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the carrier code.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Restructured with Provider level';
                ObsoleteTag = '19.7';
            }

            field("Booking Profile Code (Ext.)"; Rec."Booking Profile Code (Ext.)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the booking profile code.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Restructured with Provider level';
                ObsoleteTag = '19.7';
            }

            field(Provider; Rec.Provider)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the provider.';
            }

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

            field("Service Level Code (Time)"; Rec."Service Level Code (Time)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the service level code.';
            }

            field("Service Level Code (Other)"; Rec."Service Level Code (Other)")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the service level code.';
            }

            field("Incoterms Code"; Rec."Incoterms Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the incoterms code.';
            }
        }
    }
}