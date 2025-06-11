page 11147839 "IDYP Setup"
{
    Caption = 'PrintIT Setup';
    UsageCategory = None;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "IDYP Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    Caption = 'API Key';
                    ToolTip = 'Specifies the API key.';
                    trigger OnValidate()
                    var
                        EndpointManagement: Codeunit "IDYM Endpoint Management";
                    begin
                        if Rec."API Key" <> '' then
                            EndPointManagement.RegisterCredentials("IDYM Endpoint Service"::PrintNode, "IDYM Endpoint Usage"::Default, AppInfo.Id(), "IDYM Authorization Type"::Basic, Rec."API Key", '')
                        else
                            EndpointManagement.ClearCredentials("IDYM Endpoint Service"::PrintNode, "IDYM Endpoint Usage"::Default);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Printers)
            {
                Caption = 'Printers';
                ApplicationArea = All;
                Image = Print;
                ToolTip = 'Opens the list of PrintNode printers.';
                RunObject = Page "IDYP Printers";
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
            }
            action("User Printers")
            {
                Caption = 'User Printers';
                ApplicationArea = All;
                Image = Print;
                ToolTip = 'Opens the list of user printers.';
                RunObject = Page "IDYP User Printers";
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Printers_Promoted; Printers)
                {
                }
                actionref("User Printers_Promoted"; "User Printers")
                {
                }
            }
        }
#endif
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert(true);
    end;

    var
        AppInfo: ModuleInfo;
}