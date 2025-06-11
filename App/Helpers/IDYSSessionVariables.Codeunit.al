codeunit 11147650 "IDYS Session Variables"
{
    SingleInstance = true;

    procedure SetupIsCompleted(): Boolean
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        if not SetupIsCompletedInstantiated then begin
            SetupIsCompletedValue := IDYSSetup.Get();
            SetupIsCompletedInstantiated := true;
        end;

        exit(SetupIsCompletedValue);
    end;

    [NonDebuggable]
    internal procedure CheckAuthorization() Return: Boolean
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSLicenseCheck: Codeunit "IDYS License Check";
        Authorization: Guid;
        ErrorCode: Integer;
        ErrorMessage: Text;
    begin
        OnSetAuthorization(Authorization);
        if not IsNullGuid(Authorization) then begin
            CheckInternalAuthorization(Authorization);
            OnBeforeAuthorizeToCustomizeAPI(Return);
            exit(Return);
        end;

        // Check license property every 4 hours
        if (LastTimeChecked < CurrentDateTime() - (4 * 60 * 60 * 1000)) then begin
            LastTimeChecked := CurrentDateTime();

            IDYSSetup.Get();
            IsAuthorized := IDYSLicenseCheck.CheckLicenseProperty(IDYSSetup."License Entry No.", 'applicationarea', 'IDYS_CustomizeAPI', false, ErrorMessage, ErrorCode);
        end;

        // Designed to be used with Event Recorder
        // Used to identify whether the customized API calls could be part of the potential issue
        if IsAuthorized then
            OnAuthorizeToCustomizeAPI();
        exit(IsAuthorized);
    end;

    [NonDebuggable]
    local procedure CheckInternalAuthorization(Authorization: Guid)
    var
        UnAuthorizedErr: Label 'Changing the content of the API communication requires an authorization from IDYN. Please contact idyn support for clearance.';
    begin
        if Authorization <> '28cb22e9-3276-4114-a2b4-998c67cf892b' then
            Error(UnAuthorizedErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetAuthorization(var Authorization: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAuthorizeToCustomizeAPI(var Return: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAuthorizeToCustomizeAPI()
    begin
    end;

    var
        SetupIsCompletedInstantiated: Boolean;
        SetupIsCompletedValue: Boolean;
        IsAuthorized: Boolean;
        LastTimeChecked: DateTime;
}