codeunit 11147661 "IDYS Scheduled Tasks Handler"
{
    Permissions = tabledata "Job Queue Entry" = rimd;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        LoggingHelper: Codeunit "IDYS Logging Helper";
        TransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
    begin
        case UpperCase(Rec."Parameter String") of
            UpperCase(TransportOrderStatusLbl):
                UpdateTransportOrderStatus();
            UpperCase(CleanUpLogEntriesLbl):
                LoggingHelper.CleanupLogEntries();
            UpperCase(CleanUpTransportOrdersLbl):
                TransportOrderMgt.Cleanup();
        end;
    end;

    local procedure UpdateTransportOrderStatus()
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        TransportOrderHeader2: Record "IDYS Transport Order Header";
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        Cntr: Integer;
    begin
        TransportOrderHeader.Reset();
        TransportOrderHeader.SetCurrentKey("Last Status Update", Status);
        TransportOrderHeader.SetRange(TransportOrderHeader.Status, TransportOrderHeader.Status::Uploaded, TransportOrderHeader.Status::"Label Printed");
        if TransportOrderHeader.FindSet() then
            repeat
                Cntr += 1;
                TransportOrderHeader2 := TransportOrderHeader;
                IDYSTransportOrderMgt.Synchronize(TransportOrderHeader2);
                Commit();
            until (Cntr = 145) or (TransportOrderHeader.Next() = 0);

        IDYSAPIHelper.SyncTransportOrders();
    end;

    procedure InstallStatusUpdateJobQueueEntry()
    begin
        CreateJobQueueEntry(TransportOrderStatusLbl, TransportOrderStatusDescriptionLbl);
    end;

    procedure InstallLogEntriesCleanupJobQueueEntry()
    begin
        CreateJobQueueEntry(CleanUpLogEntriesLbl, CleanUpLogEntriesDescriptionLbl);
    end;

    procedure InstallTransportOrderCleanupJobQueueEntry()
    begin
        CreateJobQueueEntry(CleanUpTransportOrdersLbl, CleanUpTransportOrdersDescriptionLbl);
    end;

    local procedure CreateJobQueueEntry(ParameterString: Text[250]; Description: Text[250])
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "Job Queue Management";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"IDYS Scheduled Tasks Handler");
        JobQueueEntry.SetRange("Parameter String", ParameterString);
        if JobQueueEntry.IsEmpty() then begin
            JobQueueEntry.Init();
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
            JobQueueEntry."Object ID to Run" := Codeunit::"IDYS Scheduled Tasks Handler";
            JobQueueEntry."No. of Minutes between Runs" := 5;
            JobQueueEntry."Maximum No. of Attempts to Run" := 10;
            JobQueueEntry."Rerun Delay (sec.)" := 60;
            JobQueueManagement.CreateJobQueueEntry(JobQueueEntry);
            JobQueueEntry."Parameter String" := ParameterString;
            JobQueueEntry.Description := Description;
            JobQueueEntry.Modify();

            JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
        end;
    end;

    var
        IDYSAPIHelper: Codeunit "IDYS API Helper";
        TransportOrderStatusLbl: Label 'UpdateTransportOrderStatus', Locked = true;
        CleanUpLogEntriesLbl: Label 'CleanupLogEntries', Locked = true;
        CleanUpTransportOrdersLbl: Label 'CleanupTransportOrders', Locked = true;
        TransportOrderStatusDescriptionLbl: Label 'ShipIT 365 update transport order status';
        CleanUpLogEntriesDescriptionLbl: Label 'ShipIT 365 log entry cleanup';
        CleanUpTransportOrdersDescriptionLbl: Label 'ShipIT 365 transport orders cleanup';
}