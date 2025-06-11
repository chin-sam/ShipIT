codeunit 11147683 "IDYS Transsmart Error Handler"
{
    procedure Parse(ErrorToken: JsonToken; ShowAsNotification: Boolean)
    var
        ErrorNotification: Notification;
        ValidationErrorNotification: Notification;
        ErrorObject: JsonObject;
        ErrorDetails: JsonArray;
        ErrorDetailsTkn: JsonToken;
        ErrorDetail: JsonToken;
        ValidationErrors: JsonArray;
        ValidationError: JsonToken;
        GeneralDescription: Text;
        ErrorTitle: Text;
        ErrorDescription: Text;
        FullErrorDescription: Text;
        ValidationErrorObject: Text;
        ValidationErrorField: Text;
        ValidationErrorRejectedValue: Text;
        ValidationErrorMessage: Text;
        HasValidationErrors: Boolean;
        ErrorMsg: Label 'nShift Transsmart error: %1 %2', Locked = true;
        ValidationErrorMsg: Label 'nShift Transsmart validation error. Field: %1. Message: %2.', Locked = true;
        ValidationEmptyErrorMsg: Label 'nShift Transsmart validation error. %1 %2.', Locked = true;
        InvalidObjectErr: Label 'Invalid error object received from nShift Transsmart.', Locked = true;
        GetHelpLbl: Label 'Get Help';
        DetailsExists: Boolean;
    begin
        if not ErrorToken.IsObject() then
            Error(InvalidObjectErr);
        ErrorObject := ErrorToken.AsObject();

        GeneralDescription := IDYMJSONHelper.GetTextValue(ErrorObject, 'description');
        FullErrorDescription := IDYMJSONHelper.GetTextValue(ErrorObject, 'message');
        if FullErrorDescription = '' then
            FullErrorDescription := GeneralDescription;

        if ErrorObject.Contains('details') then begin
            DetailsExists := true;
            ErrorObject.Get('details', ErrorDetailsTkn);
            if ErrorDetailsTkn.IsArray() then begin
                ErrorDetails := IDYMJSONHelper.GetArray(ErrorObject, 'details');
                foreach ErrorDetail in ErrorDetails do begin
                    Clear(ErrorDescription);
                    Clear(ErrorTitle);

                    ErrorDescription := IDYMJSONHelper.GetTextValue(ErrorDetail, 'errorDescription');
                    ErrorTitle := IDYMJSONHelper.GetTextValue(ErrorDetail, 'errorTitle');

                    if ErrorDetail.AsObject().Contains('validationErrors') then begin
                        HasValidationErrors := true;
                        ValidationErrors := IDYMJSONHelper.GetArray(ErrorDetail, 'validationErrors');
                        foreach ValidationError in ValidationErrors do begin
                            ValidationErrorObject := IDYMJSONHelper.GetTextValue(ValidationError, 'object');
                            ValidationErrorField := IDYMJSONHelper.GetTextValue(ValidationError, 'field');
                            ValidationErrorRejectedValue := IDYMJSONHelper.GetTextValue(ValidationError, 'rejectedValue');
                            ValidationErrorMessage := IDYMJSONHelper.GetTextValue(ValidationError, 'message');

                            if ShowAsNotification then begin
                                Clear(ValidationErrorNotification);

                                if ValidationErrorMessage = 'may not be empty' then
                                    ValidationErrorNotification.Message(StrSubstNo(ValidationEmptyErrorMsg, UpperCase(CopyStr(ValidationErrorField, 1, 1)) + CopyStr(ValidationErrorField, 2, StrLen(ValidationErrorField) - 1), ValidationErrorMessage))
                                else
                                    ValidationErrorNotification.Message(StrSubstNo(ValidationErrorMsg, UpperCase(CopyStr(ValidationErrorField, 1, 1)) + CopyStr(ValidationErrorField, 2, StrLen(ValidationErrorField) - 1), ValidationErrorMessage));
                                ValidationErrorNotification.Send();
                            end else
                                ErrorDescription := ErrorDescription + '. ' + ValidationErrorField + ' ' + ValidationErrorMessage;
                        end;

                        if not ShowAsNotification then
                            Error(ErrorDescription);
                    end;

                    if HasValidationErrors then
                        exit;

                    if ShowAsNotification then begin
                        Clear(ErrorNotification);
                        ErrorNotification.SetData('ErrorDescription', ErrorDescription);
                        ErrorNotification.AddAction(GetHelpLbl, Codeunit::"IDYS Transsmart Error Handler", 'GetHelp');
                        ErrorNotification.Message(StrSubstNo(ErrorMsg, ErrorTitle, ErrorDescription));
                        ErrorNotification.Send();
                    end else
                        Error(ErrorDescription);
                end;
            end;
        end;

        if not ShowAsNotification then
            Error('Transsmart error: %1', GeneralDescription)
        else begin
            if GeneralDescription = '' then
                GeneralDescription := 'Unknown Transsmart error. Please try again.';

            Clear(ErrorNotification);
            if not DetailsExists then begin
                ErrorNotification.SetData('ErrorDescription', GeneralDescription);
                ErrorNotification.AddAction(GetHelpLbl, Codeunit::"IDYS Transsmart Error Handler", 'GetHelp');
                ErrorNotification.Message(StrSubstNo(ErrorMsg, FullErrorDescription, GeneralDescription));
            end else
                ErrorNotification.Message(GeneralDescription);
            ErrorNotification.Send();
        end;
    end;

    procedure GetHelp(ErrorNotification: Notification)
    var
        ErrorDescription: Text;
        TransSmartPortalSearchUrlLbl: Label 'https://transsmart.freshdesk.com/en/support/search/?term=%1', Locked = true, Comment = '%1 = search text';
    begin
        ErrorDescription := ErrorNotification.GetData('ErrorDescription');
        System.Hyperlink(StrSubstNo(TransSmartPortalSearchUrlLbl, ErrorDescription));
    end;

    var
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
}