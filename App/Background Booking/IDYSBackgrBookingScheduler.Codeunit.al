codeunit 11147664 "IDYS Backgr. Booking Scheduler"
{
    trigger OnRun()
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        TransportOrderHeader.SetRange("Booking Method", TransportOrderHeader."Booking Method"::Background);
        TransportOrderHeader.SetRange(Status, TransportOrderHeader.Status::New);
        if TransportOrderHeader.FindSet() then
            repeat
                ScheduleBooking(TransportOrderHeader);
            until TransportOrderHeader.Next() = 0;
    end;

    procedure ScheduleBooking(TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        TaskScheduler.CreateTask(Codeunit::"IDYS Background Booking", Codeunit::"IDYS Background Error Handler", true, CompanyName(), CurrentDateTime(), TransportOrderHeader.RecordId());
    end;
}