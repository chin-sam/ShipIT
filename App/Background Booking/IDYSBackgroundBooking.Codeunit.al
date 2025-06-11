codeunit 11147671 "IDYS Background Booking"
{
    TableNo = "IDYS Transport Order Header";

    trigger OnRun()
    var
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
    begin
        Rec."Shipment Error" := '';
        Rec.Modify(false);

        IDYSTransportOrderMgt.Book(Rec);
        IDYSTransportOrderMgt.Print(Rec);
    end;
}
