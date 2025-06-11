codeunit 11147672 "IDYS Background Error Handler"
{
    TableNo = "IDYS Transport Order Header";

    trigger OnRun()
    begin
        Rec.Validate("Shipment Error", CopyStr(GetLastErrorText(), 1, MaxStrLen(Rec."Shipment Error")));
        Rec.Validate(Status, Rec.Status::Error);
        Rec.Modify(false);
    end;
}
