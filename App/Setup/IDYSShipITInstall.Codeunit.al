codeunit 11147660 "IDYS ShipIT Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InstallStatusUpdateJobQueueEntry();
        InstallLogEntriesCleanupJobQueueEntry();
        InstallTransportOrderCleanupJobQueueEntry();
        RegisterEndPoints();
    end;

    local procedure InstallStatusUpdateJobQueueEntry()
    var
        ScheduledTasksHandler: Codeunit "IDYS Scheduled Tasks Handler";
    begin
        ScheduledTasksHandler.InstallStatusUpdateJobQueueEntry();
    end;

    local procedure InstallLogEntriesCleanupJobQueueEntry()
    var
        ScheduledTasksHandler: Codeunit "IDYS Scheduled Tasks Handler";
    begin
        ScheduledTasksHandler.InstallLogEntriesCleanupJobQueueEntry();
    end;

    local procedure InstallTransportOrderCleanupJobQueueEntry()
    var
        ScheduledTasksHandler: Codeunit "IDYS Scheduled Tasks Handler";
    begin
        ScheduledTasksHandler.InstallTransportOrderCleanupJobQueueEntry();
    end;

    procedure RegisterEndPoints()
    var
        IDYMEndpointManagement: Codeunit "IDYM Endpoint Management";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        IDYMEndpointManagement.RegisterEndpoint("IDYM Endpoint Service"::Transsmart, "IDYM Endpoint Usage"::Default, "IDYM Authorization Type"::Bearer, AppInfo.Id);
        IDYMEndpointManagement.RegisterEndpoint("IDYM Endpoint Service"::IdynAnalytics, "IDYM Endpoint Usage"::Default, "IDYM Authorization Type"::Bearer, AppInfo.Id);
    end;
}