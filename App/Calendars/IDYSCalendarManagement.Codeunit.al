codeunit 11147663 "IDYS Calendar Management"
{
    procedure CalculatePickupFromDateTime(TransportOrderHeader: Record "IDYS Transport Order Header"): DateTime
    var
        ShippingAgentCalendar: Record "IDYS Shipping Agent Calendar";
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
        CalendarManagement: Codeunit "Calendar Management";
        DaysToAdd: Integer;
    begin
        LoadSetup();

        //Without shipping agent
        if (TransportOrderHeader."Shipping Agent Service Code" = '') or (TransportOrderHeader."Shipping Agent Code" = '') then
            exit(CreateDateTime(TransportOrderHeader."Preferred Pick-up Date", DT2Time(Setup."Pick-up From DT")));

        //Without active calendar
        if not ShippingAgentCalendar.Get(TransportOrderHeader."Shipping Agent Code", TransportOrderHeader."Shipping Agent Service Code") then
            exit(CreateDateTime(TransportOrderHeader."Preferred Pick-up Date", DT2Time(Setup."Pick-up From DT")));

        //With active calendar, without calendar code
        if ShippingAgentCalendar."Pick-up Base Calendar Code" = '' then
            exit(CreateDateTime(TransportOrderHeader."Preferred Pick-up Date", GetPickupFromWithMapping(ShippingAgentCalendar)));

        //With active calendar and calendar code
        TempCustomizedCalendarChange.Init();
        TempCustomizedCalendarChange."Date" := TransportOrderHeader."Preferred Pick-up Date";
        TempCustomizedCalendarChange."Base Calendar Code" := ShippingAgentCalendar."Pick-up Base Calendar Code";
        CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);
        if not TempCustomizedCalendarChange.Nonworking then begin
            if TransportOrderHeader."Preferred Pick-up Date" > TODAY then
                exit(CreateDateTime(TransportOrderHeader."Preferred Pick-up Date", GetPickupFromWithMapping(ShippingAgentCalendar)));

            if ShippingAgentCalendar."Delivery To DT" = 0DT then begin
                if Time < DT2Time(Setup."Pick-up To DT") then
                    exit(CreateDateTime(TransportOrderHeader."Preferred Pick-up Date", GetPickupFromWithMapping(ShippingAgentCalendar)))
            end else
                if Time < DT2Time(ShippingAgentCalendar."Pick-up To DT") then
                    exit(CreateDateTime(TransportOrderHeader."Preferred Pick-up Date", GetPickupFromWithMapping(ShippingAgentCalendar)));
        end;

        while true do begin
            DaysToAdd += 1;

            Clear(TempCustomizedCalendarChange);
            TempCustomizedCalendarChange.Init();
            TempCustomizedCalendarChange."Date" := TransportOrderHeader."Preferred Pick-up Date" + DaysToAdd;
            TempCustomizedCalendarChange."Base Calendar Code" := ShippingAgentCalendar."Pick-up Base Calendar Code";
            CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);

            if not TempCustomizedCalendarChange.Nonworking then
                exit(CreateDateTime(TransportOrderHeader."Preferred Pick-up Date" + DaysToAdd, GetPickupFromWithMapping(ShippingAgentCalendar)));
        end;
    end;

    local procedure GetPickupFromWithMapping(ShippingAgentCalendar: Record "IDYS Shipping Agent Calendar"): Time
    begin
        if ShippingAgentCalendar."Pick-up From DT" = 0DT then
            exit(DT2Time(Setup."Pick-up From DT"))
        else
            exit(DT2Time(ShippingAgentCalendar."Pick-up From DT"));
    end;

    procedure CalculatePickupToDateTime(TransportOrderHeader: Record "IDYS Transport Order Header"): DateTime
    var
        ShippingAgentCalendar: Record "IDYS Shipping Agent Calendar";
    begin
        LoadSetup();

        //Without shipping agent
        if (TransportOrderHeader."Shipping Agent Service Code" = '') or (TransportOrderHeader."Shipping Agent Code" = '') then
            exit(CreateDateTime(DT2Date(TransportOrderHeader."Preferred Pick-up Date From"), DT2Time(Setup."Pick-up To DT")));

        //Without active calendar
        if NOT ShippingAgentCalendar.Get(TransportOrderHeader."Shipping Agent Code", TransportOrderHeader."Shipping Agent Service Code") then
            exit(CreateDateTime(DT2Date(TransportOrderHeader."Preferred Pick-up Date From"), DT2Time(Setup."Pick-up To DT")));

        //With active calendar, without calendar code
        exit(CreateDateTime(DT2Date(TransportOrderHeader."Preferred Pick-up Date From"), GetPickupToWithMapping(ShippingAgentCalendar)));
    end;

    local procedure GetPickupToWithMapping(ShippingAgentCalendar: Record "IDYS Shipping Agent Calendar"): Time
    begin
        if ShippingAgentCalendar."Pick-up To DT" = 0DT then
            exit(DT2Time(Setup."Pick-up To DT"))
        else
            exit(DT2Time(ShippingAgentCalendar."Pick-up To DT"));
    end;

    procedure CalculateDeliveryFromDateTime(TransportOrderHeader: Record "IDYS Transport Order Header"): DateTime
    var
        ShippingAgentCalendar: Record "IDYS Shipping Agent Calendar";
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
        ShippingAgentServices: Record "Shipping Agent Services";
        CalendarManagement: Codeunit "Calendar Management";
        DaysToAdd: Integer;
        BaseDeliveryDate: Date;
    begin
        LoadSetup();

        //Without shipping agent
        if (TransportOrderHeader."Shipping Agent Service Code" = '') or (TransportOrderHeader."Shipping Agent Code" = '') then
            exit(CreateDateTime(DT2Date(TransportOrderHeader."Preferred Pick-up Date From") + 1, DT2Time(Setup."Delivery From DT")));

        ShippingAgentServices.Get(TransportOrderHeader."Shipping Agent Code", TransportOrderHeader."Shipping Agent Service Code");
        BaseDeliveryDate := CalcDate(ShippingAgentServices."Shipping Time", DT2Date(TransportOrderHeader."Preferred Pick-up Date From"));

        //Without active calendar
        if NOT ShippingAgentCalendar.Get(TransportOrderHeader."Shipping Agent Code", TransportOrderHeader."Shipping Agent Service Code") then
            exit(CreateDateTime(BaseDeliveryDate, DT2Time(Setup."Delivery From DT")));

        //With active calendar, without calendar code
        if ShippingAgentCalendar."Pick-up Base Calendar Code" = '' then
            exit(CreateDateTime(BaseDeliveryDate, GetDeliveryFromWithMapping(ShippingAgentCalendar)));

        //With active calendar and calendar code
        TempCustomizedCalendarChange.Init();
        TempCustomizedCalendarChange."Date" := BaseDeliveryDate;
        TempCustomizedCalendarChange."Base Calendar Code" := ShippingAgentCalendar."Delivery Base Calendar Code";
        CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);
        if not TempCustomizedCalendarChange.Nonworking then
            exit(CreateDateTime(BaseDeliveryDate, GetDeliveryFromWithMapping(ShippingAgentCalendar)));

        while true do begin
            DaysToAdd += 1;

            Clear(TempCustomizedCalendarChange);
            TempCustomizedCalendarChange.Init();
            TempCustomizedCalendarChange."Date" := BaseDeliveryDate + DaysToAdd;
            TempCustomizedCalendarChange."Base Calendar Code" := ShippingAgentCalendar."Delivery Base Calendar Code";
            CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);

            if not TempCustomizedCalendarChange.Nonworking then
                exit(CreateDateTime(BaseDeliveryDate + DaysToAdd, GetDeliveryFromWithMapping(ShippingAgentCalendar)));
        end;
    end;

    local procedure GetDeliveryFromWithMapping(ShippingAgentCalendar: Record "IDYS Shipping Agent Calendar"): Time
    begin
        if ShippingAgentCalendar."Delivery From DT" = 0DT then
            exit(DT2Time(Setup."Delivery From DT"))
        else
            exit(DT2Time(ShippingAgentCalendar."Delivery From DT"));
    end;

    procedure CalculateDeliveryToDateTime(TransportOrderHeader: Record "IDYS Transport Order Header"): DateTime
    var
        ShippingAgentCalendar: Record "IDYS Shipping Agent Calendar";
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
        ShippingAgentServices: Record "Shipping Agent Services";
        CalendarManagement: Codeunit "Calendar Management";
        DaysToAdd: Integer;
        BaseDeliveryDate: Date;
    begin
        LoadSetup();

        //Without shipping agent
        if (TransportOrderHeader."Shipping Agent Service Code" = '') or (TransportOrderHeader."Shipping Agent Code" = '') then
            exit(CreateDateTime(DT2Date(TransportOrderHeader."Preferred Pick-up Date From") + 1, DT2Time(Setup."Delivery To DT")));

        ShippingAgentServices.Get(TransportOrderHeader."Shipping Agent Code", TransportOrderHeader."Shipping Agent Service Code");
        BaseDeliveryDate := CalcDate(ShippingAgentServices."Shipping Time", DT2Date(TransportOrderHeader."Preferred Pick-up Date From"));

        //Without active calendar
        if not ShippingAgentCalendar.Get(TransportOrderHeader."Shipping Agent Code", TransportOrderHeader."Shipping Agent Service Code") then
            exit(CreateDateTime(BaseDeliveryDate, DT2Time(Setup."Delivery To DT")));

        //With active calendar, without calendar code
        if ShippingAgentCalendar."Pick-up Base Calendar Code" = '' then
            exit(CreateDateTime(BaseDeliveryDate, GetDeliveryToWithMapping(ShippingAgentCalendar)));

        //With active calendar and calendar code
        TempCustomizedCalendarChange.Init();
        TempCustomizedCalendarChange."Date" := BaseDeliveryDate;
        TempCustomizedCalendarChange."Base Calendar Code" := ShippingAgentCalendar."Delivery Base Calendar Code";
        CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);
        if not TempCustomizedCalendarChange.Nonworking then
            exit(CreateDateTime(BaseDeliveryDate, GetDeliveryToWithMapping(ShippingAgentCalendar)));

        while true do begin
            DaysToAdd += 1;

            Clear(TempCustomizedCalendarChange);
            TempCustomizedCalendarChange.Init();
            TempCustomizedCalendarChange."Date" := BaseDeliveryDate + DaysToAdd;
            TempCustomizedCalendarChange."Base Calendar Code" := ShippingAgentCalendar."Delivery Base Calendar Code";
            CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);

            if not TempCustomizedCalendarChange.Nonworking then
                exit(CreateDateTime(BaseDeliveryDate + DaysToAdd, GetDeliveryToWithMapping(ShippingAgentCalendar)));
        end;
    end;

    local procedure GetDeliveryToWithMapping(ShippingAgentCalendar: Record "IDYS Shipping Agent Calendar"): Time
    begin
        if ShippingAgentCalendar."Delivery To DT" = 0DT then
            exit(DT2Time(Setup."Delivery To DT"))
        else
            exit(DT2Time(ShippingAgentCalendar."Delivery To DT"));
    end;

    local procedure LoadSetup()
    begin
        if SetupLoaded then
            exit;

        Setup.Get();
        SetupLoaded := true;
    end;

    var
        Setup: Record "IDYS Setup";
        SetupLoaded: Boolean;
}
