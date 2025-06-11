page 11147681 "IDYS Log Entry Card"
{
    Caption = 'Transport Order Log Entry';
    PageType = Card;
    SourceTable = "IDYS Transport Order Log Entry";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Transport Order No."; Rec."Transport Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transport order no.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the logging level.';
                }
                field("Date/Time"; Rec."Date/Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user ID.';
                }
            }

            group("Request")
            {
                Caption = 'Request';
                usercontrol(CodeViewerRequest; "IDYS Code Viewer")
                {
                    ApplicationArea = All;

                    trigger AddinLoaded()
                    begin
                        CurrPage.CodeViewerRequest.LoadData(RequestData);
                    end;
                }
            }

            group("Response")
            {
                Caption = 'Response';
                usercontrol(CodeViewerResponse; "IDYS Code Viewer")
                {
                    ApplicationArea = All;

                    trigger AddinLoaded()
                    begin
                        CurrPage.CodeViewerResponse.LoadData(ResponseData);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        TempBlobHelper: Record "IDYS Blob Helper" temporary;
        TempBlobHelper2: Record "IDYS Blob Helper" temporary;
    begin
        Rec.CalcFields("JSON Request", "JSON Response");

        TempBlobHelper.Init();
        TempBlobHelper."Blob" := Rec."JSON Request";
        RequestData := TempBlobHelper.ReadAsText();

        TempBlobHelper2.Init();
        TempBlobHelper2."Blob" := Rec."JSON Response";
        ResponseData := TempBlobHelper2.ReadAsText();

        CurrPage.CodeViewerRequest.LoadData(RequestData);
        CurrPage.CodeViewerResponse.LoadData(ResponseData);
    end;

    var
        RequestData: Text;
        ResponseData: Text;
}
