page 11147840 "IDYP Printers"
{
    Caption = 'PrintIT Printers';
    PageType = List;
    UsageCategory = None;
    SourceTable = "IDYP Printer";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Computer Hostname"; Rec."Computer Hostname")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Printer Id';
                }
                field("Printer Id"; Rec."Printer Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Printer Id';
                }
                field("Printer Name"; Rec."Printer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Printer Name';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(GetPrinters)
            {
                ApplicationArea = All;
                Caption = 'Get Printers';
                ToolTip = 'Gets the printers from the PrintNode API.';
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Image = Print;

                trigger OnAction()
                var
                    PrintNodeManagement: Codeunit "IDYP PrintNode Management";
                begin
                    PrintNodeManagement.GetPrinters();
                    CurrPage.Update();
                end;
            }
            action("Test Print")
            {
                ApplicationArea = All;
                Caption = 'Test Print';
                ToolTip = 'Initiates PrintNode printing to the selected printer.';
                Image = PrintReport;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                trigger OnAction()
                var
                    Base64Convert: Codeunit "Base64 Convert";
                    FileManagement: Codeunit "File Management";
                    PrintNodeManagement: Codeunit "IDYP PrintNode Management";
                    FileInStream: Instream;
                    FileAsBase64: Text;
                    FileName: Text;
                    DialogTitleLbl: Label 'Select Test Print File';
                begin
                    UploadIntoStream(DialogTitleLbl, '', '', FileName, FileInStream);
                    FileAsBase64 := Base64Convert.ToBase64(FileInStream);
                    PrintNodeManagement.PrintJob(Rec, PrintNodeManagement.InitPrinting(Rec, FileAsBase64, LowerCase(FileManagement.GetExtension(FileName)) = 'pdf', FileName));
                    CurrPage.Update();
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(GetPrinters_Promoted; GetPrinters)
                {
                }
                actionref("Test Print_Promoted"; "Test Print")
                {
                }
            }
        }
#endif
    }
}