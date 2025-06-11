page 11147675 "IDYS Transport Order Lines"
{
    Caption = 'Transport Order Lines';
    Editable = false;
    PageType = List;
    SourceTable = "IDYS Transport Order Line";
    UsageCategory = Lists;
    ApplicationArea = All;
    ContextSensitiveHelpPage = '22937633';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Transport Order No."; Rec."Transport Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transport order no.';
                }

                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line no..';
                }

                field("Source Document Type"; Rec."Source Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document type.';
                }

                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document no..';
                }

                field("Source Document Line No."; Rec."Source Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document line no..';
                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item no..';
                }

                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant code..';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }

                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description 2.';
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quanity.';
                    Visible = false;
                }

                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the base quantity.';
                }

                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transport value';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = SourceDocLine;
                action("Show Document")
                {
                    Caption = 'Show Document';
                    Image = View;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    ShortCutKey = 'Shift+F7';
                    ApplicationArea = All;
                    ToolTip = 'Shows the document.';

                    trigger OnAction();
                    var
                        TransportOrderHeader: Record "IDYS Transport Order Header";
                    begin
                        Rec.TestField("Transport Order No.");
                        TransportOrderHeader.Get(Rec."Transport Order No.");
                        Page.Run(Page::"IDYS Transport Order Card", TransportOrderHeader);
                    end;
                }
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Show Document_Promoted"; "Show Document")
                {
                }
            }
        }
#endif
    }
}