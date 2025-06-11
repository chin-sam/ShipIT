codeunit 11147644 "IDYS Logging Helper"
{
    procedure WriteLogEntry(TransportOrderNo: Code[20]; Message: Text; Level: Enum "IDYS Logging Level")
    var
        IDYSTransportOrderLogEntry: Record "IDYS Transport Order Log Entry";
        IDYSSetup: record "IDYS Setup";
    begin
        IDYSSetup.Get();
        case IDYSSetup."Logging Level" of
            IDYSSetup."Logging Level"::Warning:
                if Level = Level::Information then
                    exit;

            IDYSSetup."Logging Level"::Error:
                if (Level = Level::Information) or (Level = Level::Warning) then
                    exit;
        end;

        IDYSTransportOrderLogEntry.Init();
        IDYSTransportOrderLogEntry."Transport Order No." := TransportOrderNo;
        IDYSTransportOrderLogEntry.Description := CopyStr(Message, 1, MaxStrLen(IDYSTransportOrderLogEntry.Description));
        IDYSTransportOrderLogEntry."Level" := Level;
        IDYSTransportOrderLogEntry.Insert(true);
    end;

    procedure WriteLogEntry(TransportOrderNo: Code[20]; Message: Text; Level: Enum "IDYS Logging Level"; JSONRequest: JsonObject)
    var
        JSONResponse: JsonObject;
    begin
        WriteLogEntry(TransportOrderNo, Message, Level, JSONRequest, JSONResponse);
    end;

    procedure WriteLogEntry(TransportOrderNo: Code[20]; Message: Text; Level: Enum "IDYS Logging Level"; JSONRequest: JsonObject; JSONResponse: JsonObject)
    var
        IDYSTransportOrderLogEntry: Record "IDYS Transport Order Log Entry";
        TempBlobHelper: Record "IDYS Blob Helper" temporary;
        TempBlobHelper2: Record "IDYS Blob Helper" temporary;
        IDYSSetup: record "IDYS Setup";
        JsonString: Text;
        JsonString2: Text;
    begin
        IDYSSetup.Get();
        if not IDYSSetup."Enable Debug Mode" then
            exit;

        case IDYSSetup."Logging Level" of
            IDYSSetup."Logging Level"::Warning:
                if Level = Level::Information then
                    exit;

            IDYSSetup."Logging Level"::Error:
                if (Level = Level::Information) or (Level = Level::Warning) then
                    exit;
        end;

        IDYSTransportOrderLogEntry.Init();
        IDYSTransportOrderLogEntry."Transport Order No." := TransportOrderNo;
        IDYSTransportOrderLogEntry.Description := CopyStr(Message, 1, MaxStrLen(IDYSTransportOrderLogEntry.Description));
        IDYSTransportOrderLogEntry."Level" := Level;

        if JSONRequest.WriteTo(JsonString) then begin
            TempBlobHelper.Init();
            TempBlobHelper.WriteAsText(JsonString);
            IDYSTransportOrderLogEntry."JSON Request" := TempBlobHelper."Blob";
        end;

        if JSONResponse.WriteTo(JsonString2) then
            if JsonString <> '' then begin
                TempBlobHelper2.Init();
                TempBlobHelper2.WriteAsText(JsonString2);
                IDYSTransportOrderLogEntry."JSON Response" := TempBlobHelper2."Blob";
            end;

        IDYSTransportOrderLogEntry.Insert(true);
    end;

    procedure CleanupLogEntries()
    var
        TransportOrderLogEntry: Record "IDYS Transport Order Log Entry";
        LastDate: Date;
        LastDateTime: DateTime;
    begin
        LastDate := CalcDate('<-7D>', Today);
        LastDateTime := CreateDateTime(LastDate, 0T);

        TransportOrderLogEntry.Reset();
        TransportOrderLogEntry.SetFilter("Date/Time", '..%1', LastDateTime);
        if not TransportOrderLogEntry.IsEmpty then
            TransportOrderLogEntry.DeleteAll();
    end;
}