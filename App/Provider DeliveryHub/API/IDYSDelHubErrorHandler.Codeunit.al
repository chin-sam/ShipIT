codeunit 11147718 "IDYS DelHub Error Handler"
{
    procedure Parse(ErrorToken: JsonToken; ShowAsNotification: Boolean)
    var
        ErrorObject: JsonObject;
        ErrorDetailsTkn: JsonToken;
        ErrorDetail: JsonToken;
        GeneralErrMessage: Text;
        ErrorDescription: Text;
        ErrMessage: Text;
        ErrorMsg: Label 'nShift Ship error: %1', comment = '%1 = Error message';
        UnknownErr: Label 'Unknown nShift Ship error. Please try again.';
        ParseErr: Label 'Invalid error object received from nShift Ship.';
    begin
        if not ErrorToken.IsObject() then
            Error(ParseErr);
        ErrorObject := ErrorToken.AsObject();

        GeneralErrMessage := IDYMJSONHelper.GetTextValue(ErrorObject, 'ErrorType');
        ErrMessage := IDYMJSONHelper.GetTextValue(ErrorObject, 'Message');
        if ErrMessage <> '' then
            GeneralErrMessage += ': ' + ErrMessage
        else
            GeneralErrMessage += ': ' + UnknownErr;

        if ErrorObject.Contains('Errors') then begin
            ErrorObject.Get('Errors', ErrorDetailsTkn);
            if ErrorDetailsTkn.IsArray() then
                foreach ErrorDetail in IDYMJSONHelper.GetArray(ErrorObject, 'Errors') do begin
                    Clear(ErrorDescription);

                    ErrorDescription := IDYMJSONHelper.GetTextValue(ErrorDetail, 'message');
                    if ShowAsNotification then
                        IDYSNotificationManagement.SendNotification(StrSubstNo(ErrorMsg, ErrorDescription))
                    else
                        Error(ErrorDescription);
                end;
        end;

        if ShowAsNotification then
            IDYSNotificationManagement.SendNotification(StrSubstNo(ErrorMsg, GeneralErrMessage))
        else
            Error(ErrorMsg, GeneralErrMessage)
    end;

    var
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
}