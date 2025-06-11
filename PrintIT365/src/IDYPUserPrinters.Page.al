page 11147841 "IDYP User Printers"
{
    Caption = 'PrintIT User Printers';
    UsageCategory = None;
    PageType = List;
    SourceTable = "IDYP User Printer";
    DataCaptionFields = "Printer Id", "Printer Name";

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
                field("Printer Id"; Rec."Printer Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the printer id.';
                }
                field("Printer Name"; Rec."Printer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the printer name.';
                }
                field("File Extension Filter"; Rec."File Extension Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the file extension filter.';
                }
                field("User Default"; Rec."User Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user default.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Printer Name");
    end;
}