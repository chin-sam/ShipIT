codeunit 11147682 "IDYS Token Store"
{
    SingleInstance = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by App Management app';
    //ObsoleteTag = '19.7';'

    procedure ResetToken()
    begin
        TokenCreatedOn := 0DT;
        BearerToken := '';
    end;

    procedure GetToken(): Text
    var
        TempIDYSRESTParameters: Record "IDYS REST Parameters" temporary;
        IDYSSetup: Record "IDYS Setup";
        IDYSUserSetup: Record "IDYS User Setup";
        IDYSHttpHelper: Codeunit "IDYS Http Helper";
        IDYMJSONHelper: Codeunit "IDYM Json Helper";
        Response: JsonToken;
        BaseURI: Enum "IDYS API";
    begin
        if (TokenCreatedOn = 0DT) or (TokenRefreshTime < CurrentDateTime()) or (BearerToken = '') then begin
            TokenRefreshTime := CurrentDateTime() + 3600000;

            IDYSSetup.Get();
            if not IDYSSetup."Unit Test Mode" then begin
                TempIDYSRESTParameters.Init();
                TempIDYSRESTParameters.Path := '/login';
                TempIDYSRESTParameters.RestMethod := TempIDYSRESTParameters.RestMethod::GET;
                if IDYSUserSetup.Get(UserId()) then begin
                    TempIDYSRESTParameters.Username := IDYSUserSetup."User Name (External)";
                    TempIDYSRESTParameters.Password := IDYSUserSetup."Password (External)";
                end else begin
                    IDYSUserSetup.Reset();
                    IDYSUserSetup.SetRange(Default, true);
                    if IDYSUserSetup.FindFirst() then begin
                        TempIDYSRESTParameters.Username := IDYSUserSetup."User Name (External)";
                        TempIDYSRESTParameters.Password := IDYSUserSetup."Password (External)";
                    end;
                end;

                IDYSHttpHelper.Execute(TempIDYSRESTParameters, IDYSSetup, BaseURI::Transsmart);
                if TempIDYSRESTParameters.HasResponseContent() then begin
                    Response := TempIDYSRESTParameters.GetResponseBodyAsJSON();
                    BearerToken := IDYMJSONHelper.GetTextValue(Response.AsObject(), 'token');
                end;
            end else
                BearerToken := 'mock.token.forunittesting';

            TokenCreatedOn := CurrentDateTime();
        end;

        exit(BearerToken);
    end;

    var
        BearerToken: Text;
        TokenCreatedOn: DateTime;
        TokenRefreshTime: DateTime;
}