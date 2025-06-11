codeunit 11147839 "IDYP PrintNode Management"
{
    // For virtual printers spool could be used to retrieve files
    //C:\Windows\System32\spool\PRINTERS\

    var
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";

    procedure GetPrinters()
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYPPrinter: Record "IDYP Printer";
        Printers: JsonArray;
        Printer: JsonToken;
        Computer: JsonObject;
        GetPrintersLbl: Label 'printers', Locked = true;
    begin
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Path := CopyStr(GetPrintersLbl, 1, 250);
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::PrintNode, "IDYM Endpoint Usage"::Default);

        if (TempIDYMRESTParameters."Status Code" <> 200) then begin
            ParseError(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;

        // Handle Response
        Printers := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsArray();
        IDYPPrinter.DeleteAll();
        foreach Printer in Printers do begin
            IDYPPrinter.Init();
            IDYPPrinter."Printer Id" := IDYMJsonHelper.GetIntegerValue(Printer, 'id');
            IDYPPrinter."Printer Name" := CopyStr(IDYMJsonHelper.GetTextValue(Printer, 'name'), 1, MaxStrLen(IDYPPrinter."Printer Name"));
            IDYPPrinter.Default := IDYMJsonHelper.GetBooleanValue(Printer, 'default');
            IDYPPrinter.State := CopyStr(IDYMJsonHelper.GetTextValue(Printer, 'state'), 1, MaxStrLen(IDYPPrinter.State));

            Computer := IDYMJSONHelper.GetObject(Printer, 'computer');
            IDYPPrinter."Computer Hostname" := CopyStr(IDYMJSONHelper.GetTextValue(Computer, 'hostname'), 1, MaxStrLen(IDYPPrinter."Printer Name"));
            IDYPPrinter.Insert();
        end;
    end;

    procedure PrintJob(IDYPPrinter: Record "IDYP Printer"; Request: JsonObject): Boolean
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        PrintJobsLbl: Label 'printjobs', Locked = true;
    begin
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Path := CopyStr(PrintJobsLbl, 1, 250);
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;

        TempIDYMRESTParameters.SetRequestContent(Request);

        IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::PrintNode, "IDYM Endpoint Usage"::Default);
        if (TempIDYMRESTParameters."Status Code" <> 201) then begin
            ParseError(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;

        exit(true);
    end;

    procedure InitPrinting(IDYPPrinter: Record "IDYP Printer"; FileAsBase64: Text; IsPDFFile: Boolean; FileName: Text) Request: JsonObject
    begin
        Request.Add('printerId', IDYPPrinter."Printer Id");
        Request.Add('title', FileName);
        if IsPDFFile then
            Request.Add('contentType', 'pdf_base64')
        else
            Request.Add('contentType', 'raw_base64');
        Request.Add('content', FileAsBase64);
    end;

    local procedure ParseError(ErrorToken: JsonToken; ShowAsNotification: Boolean)
    var
        ErrorNotification: Notification;
        ErrMessage: Text;
        GenericErr: Label 'An error ocurred connecting to PrintNode.';
    begin
        if not GuiAllowed() then
            ShowAsNotification := false;

        if ErrorToken.IsObject() then
            ErrMessage := IDYMJSONHelper.GetTextValue(ErrorToken, 'message')
        else
            ErrMessage := GenericErr;

        if ShowAsNotification and GuiAllowed() then begin
            ErrorNotification.Scope(NotificationScope::LocalScope);
            ErrorNotification.Message(ErrMessage);
            ErrorNotification.Send();
        end else
            Error(ErrMessage);
    end;

    procedure GetUserPrinter(FileExtension: Text): Integer
    var
        UserPrinter: Record "IDYP User Printer";
    begin
        // File Extension Filter
        UserPrinter.SetRange("User ID", UserId());
        if UserPrinter.FindSet() then
            repeat
                if StrPos(LowerCase(UserPrinter."File Extension Filter"), LowerCase(FileExtension)) <> 0 then
                    exit(UserPrinter."Printer Id");
            until UserPrinter.Next() = 0;

        // User Default
        UserPrinter.SetRange("User Default", true);
        if UserPrinter.FindFirst() then
            exit(UserPrinter."Printer Id");
    end;
}