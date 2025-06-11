codeunit 11147704 "IDYS Cargoson Error Handler"
{
    procedure Parse(var TempIDYMRESTParameters: Record "IDYM REST Parameters"; ShowAsNotification: Boolean)
    var
        ErrorToken: JsonToken;
        ErrorArray: JsonArray;
        ErrorMessage: Text;
        ErrorMsg: Label 'Cargoson Error: %1', comment = '%1 = Error message';
        GenericAPIErr: Label 'Generic API Error (%1).', Comment = '%1 = status code';
        ParseErr: Label 'Invalid error object received from Cargoson.';
    begin
        ErrorToken := TempIDYMRESTParameters.GetResponseBodyAsJSON();
        if not ErrorToken.IsObject() then
            Error(GenericAPIErr, TempIDYMRESTParameters."Status Code");

        case true of
            ErrorToken.SelectToken('errors', ErrorToken):
                begin
                    if not ErrorToken.IsArray() then
                        Error(ParseErr);

                    ErrorArray := ErrorToken.AsArray();
                    foreach ErrorToken in ErrorArray do
                        if ShowAsNotification then begin
                            ErrorMessage := StrSubstNo(ErrorMsg, ErrorToken.AsValue().AsText());
                            IDYSNotificationManagement.SendNotification(ErrorMessage);
                        end else
                            Error(ErrorMsg, ErrorMessage);
                end;
            else
                Error(ParseErr);
        end;
    end;

    var
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
}