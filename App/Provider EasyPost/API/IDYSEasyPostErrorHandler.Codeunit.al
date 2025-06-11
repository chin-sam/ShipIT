codeunit 11147726 "IDYS EasyPost Error Handler"
{
    procedure Parse(ErrorToken: JsonToken; ShowAsNotification: Boolean)
    var
        ErrorObject: JsonObject;
        ErrorDetailsTkn: JsonToken;
        ErrorArray: JsonArray;
        FieldErrorMessageLbl: Label 'EasyPost error: Field: %1\\Error: %2', comment = '%1 = Field name, %2 = Error message';
        GeneralErrMessage: Text;
        ParseErr: Label 'Invalid error object received from the EasyPost.';
    begin
        if not ErrorToken.IsObject() then
            Error(ParseErr);

        case true of
            ErrorToken.SelectToken('error', ErrorDetailsTkn):
                begin
                    ErrorObject := ErrorDetailsTkn.AsObject();
                    GeneralErrMessage := '';
                    AddErrorText(GeneralErrMessage, IDYMJSONHelper.GetTextValue(ErrorObject, 'code'));
                    AddErrorText(GeneralErrMessage, IDYMJSONHelper.GetTextValue(ErrorObject, 'message'));
                    HandleErrorNotifications(ErrorObject, GeneralErrMessage, FieldErrorMessageLbl, ShowAsNotification);
                end;
            ErrorToken.SelectToken('messages', ErrorDetailsTkn):
                begin
                    if not ErrorDetailsTkn.IsArray() then
                        Error(ParseErr);
                    ErrorArray := ErrorDetailsTkn.AsArray();
                    foreach ErrorDetailsTkn in ErrorArray do begin
                        ErrorObject := ErrorDetailsTkn.AsObject();
                        GeneralErrMessage := '';
                        AddErrorText(GeneralErrMessage, IDYMJSONHelper.GetTextValue(ErrorObject, 'carrier'));
                        AddErrorText(GeneralErrMessage, IDYMJSONHelper.GetTextValue(ErrorObject, 'type'));
                        AddErrorText(GeneralErrMessage, IDYMJSONHelper.GetTextValue(ErrorObject, 'message'));
                        HandleErrorNotifications(ErrorObject, GeneralErrMessage, FieldErrorMessageLbl, ShowAsNotification);
                    end;
                end;
            else
                Error(ParseErr);
        end;
    end;

    local procedure HandleErrorNotifications(ErrorObject: JsonObject; GeneralErrMessage: Text; FieldErrorMessageLbl: Text; ShowAsNotification: Boolean)
    var
        ErrorDetail: JsonToken;
        ErrorDetailsTkn: JsonToken;
        FieldName: Text;
        FieldErrorDescription: Text;
        FieldErrorMessage: Text;
        GeneralErrMessageLbl: Label 'EasyPost error: %1', comment = '%1 = Error message';
    begin
        // General Error Message
        if ShowAsNotification then
            IDYSNotificationManagement.SendNotification(StrSubstNo(GeneralErrMessageLbl, GeneralErrMessage))
        else
            Error(GeneralErrMessageLbl, GeneralErrMessage);

        // Field Errors
        if ErrorObject.Contains('errors') then begin
            ErrorObject.Get('errors', ErrorDetailsTkn);
            if ErrorDetailsTkn.IsArray() then
                foreach ErrorDetail in IDYMJSONHelper.GetArray(ErrorObject, 'errors') do begin
                    Clear(FieldErrorMessage);
                    FieldName := IDYMJSONHelper.GetTextValue(ErrorDetail, 'field');
                    FieldErrorDescription := IDYMJSONHelper.GetTextValue(ErrorDetail, 'message');
                    FieldErrorMessage := StrSubstNo(FieldErrorMessageLbl, FieldName, FieldErrorDescription);
                    if ShowAsNotification then
                        IDYSNotificationManagement.SendNotification(FieldErrorMessage)
                    else
                        Error(FieldErrorMessage);
                end;
        end;
    end;

    local procedure AddErrorText(var GeneralErrMessage: Text; ErrMessage: Text)
    var
        Prefix: Text;
    begin
        Prefix := ': ';
        if GeneralErrMessage = '' then
            Prefix := '';

        if ErrMessage <> '' then
            GeneralErrMessage += Prefix + ErrMessage
        else
            GeneralErrMessage += Prefix + UnknownErr;
    end;

    var
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        UnknownErr: Label 'Unknown error.';

}