codeunit 11147676 "IDYS Action Handlers"
{
    Access = Internal;

    internal procedure OpenTransportOrderCard(OpenTransportOrderCardNotification: Notification)
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        TransportOrderCard: Page "IDYS Transport Order Card";
        TransportOrder: Text;
    begin
        TransportOrder := OpenTransportOrderCardNotification.GetData('TransportOrderNo');
        TransportOrderHeader.Get(TransportOrder);
        TransportOrderCard.SetRecord(TransportOrderHeader);
        TransportOrderCard.Run();
    end;
}
