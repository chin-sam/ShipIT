page 11147726 "IDYS Delivery Hub User Setup"
{
    Caption = 'nShift Ship User Setup';
    UsageCategory = Lists;
    ApplicationArea = All;
    PageType = List;
    SourceTable = "IDYS User Setup";
    ContextSensitiveHelpPage = '96370738';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user id.';
                }
                field("Label Type"; Rec."Label Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Label Type.';
                }
                field("Enable Drop Zone Printing"; Rec."Enable Drop Zone Printing")
                {
                    ApplicationArea = All;
                    Tooltip = 'When enabled, the application will use Drop Zone printing functionality.';


                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Ticket Username"; Rec."Ticket Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Ticket Username.';
                    Editable = IsEnableDropZonePrinting;
                }
                field("Workstation ID"; Rec."Workstation ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Workstation ID.';
                    Editable = IsEnableDropZonePrinting;
                }
                field("Drop Zone Label Printer Key"; Rec."Drop Zone Label Printer Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Drop Zone Label Printer Key.';
                    Editable = IsEnableDropZonePrinting;
                }
                field("Default"; Rec."Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsEnableDropZonePrinting := Rec."Enable Drop Zone Printing"
    end;

    var
        IsEnableDropZonePrinting: Boolean;
}