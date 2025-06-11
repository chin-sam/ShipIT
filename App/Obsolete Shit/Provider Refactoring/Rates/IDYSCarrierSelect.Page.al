page 11147689 "IDYS Carrier Select"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Carrier Select';
    Editable = false;
    PageType = List;
    SourceTable = "IDYS Carrier Select";
    UsageCategory = None;
    ContextSensitiveHelpPage = '23199761';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                FreezeColumn = Price;
                field("Carrier Code"; Rec."Carrier Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier code.';
                }

                field(Price; Rec."Price as Decimal")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price.';
                }

                field("Carrier Name"; Rec."Carrier Name")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the carrier.';
                }

                field("Pickup Date"; Rec."Pickup Date")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the pickup date.';
                }

                field("Delivery Date"; Rec."Delivery Date")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delivery date.';
                }

                field("Delivery Time"; Rec."Delivery Time")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delivery time.';
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
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies if everything needed for this record is mapped.';
                }

                field("Transit Time (Hours)"; Rec."Transit Time (Hours)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transit time in hours.';
                }

                field("Transit Time Description"; Rec."Transit Time Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the transit time.';
                }

                field("Calculated Weight"; Rec."Calculated Weight")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated weight.';
                }

                field("Calculated Weight UOM"; Rec."Calculated Weight UOM")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated weight UOM.';
                }
            }
        }
    }

    trigger OnAfterGetRecord();
    begin
        UpdateControls();
    end;

    var
        RowStyleExpr: Text;

    local procedure UpdateControls();
    begin
        if Rec.Mapped and not Rec."Not Available" then
            RowStyleExpr := 'Favorable'
        else
            RowStyleExpr := 'Unfavorable';
    end;
}

