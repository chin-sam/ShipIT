codeunit 11147821 "IDYST SessionData"
{
    SingleInstance = true;

    var
        TempIDYSTransportOrderRegister: Record "IDYS Transport Order Register" temporary;
        WhseShipmentNo: Code[20];
        ShippingAgentCode: Code[10];
        ErrorMessage: Text;

    [Obsolete('Transport Orders are directly posted when they are created', '22.10')]
    internal procedure SetRegister(var IDYSTransportOrderRegister: Record "IDYS Transport Order Register")
    begin
        TempIDYSTransportOrderRegister.Reset();
        TempIDYSTransportOrderRegister.DeleteAll();

        IDYSTransportOrderRegister.SetRange("Table No.", IDYSTransportOrderRegister."Table No.");
        IDYSTransportOrderRegister.SetRange("Document No.", IDYSTransportOrderRegister."Document No.");
        if IDYSTransportOrderRegister.FindSet() then
            repeat
                TempIDYSTransportOrderRegister := IDYSTransportOrderRegister;
                TempIDYSTransportOrderRegister.Insert();
            until IDYSTransportOrderRegister.Next() = 0;
    end;

    [Obsolete('Transport Orders are directly posted when they are created', '22.10')]
    internal procedure GetRegister(var NewTempIDYSTransportOrderRegister: Record "IDYS Transport Order Register")
    begin
        TempIDYSTransportOrderRegister.Reset();
        if TempIDYSTransportOrderRegister.FindSet() then
            repeat
                NewTempIDYSTransportOrderRegister.Insert();
            until TempIDYSTransportOrderRegister.Next() = 0;
    end;

    [Obsolete('Transport Orders are directly posted when they are created', '22.10')]
    internal procedure GetDictionary(var NewTransportOrderNos: Dictionary of [Code[20], Code[20]])
    begin
        Clear(NewTransportOrderNos);

        TempIDYSTransportOrderRegister.Reset();
        TempIDYSTransportOrderRegister.SetCurrentKey("Transport Order No.");
        if TempIDYSTransportOrderRegister.FindSet() then
            repeat
                TempIDYSTransportOrderRegister.SetRange("Transport Order No.", TempIDYSTransportOrderRegister."Transport Order No.");
                NewTransportOrderNos.Add(TempIDYSTransportOrderRegister."Transport Order No.", TempIDYSTransportOrderRegister."Transport Order No.");
            until TempIDYSTransportOrderRegister.Next() = 0;
    end;

    internal procedure SetWhseShipmentNo(NewWhseShipmentNo: Code[20]; NewShippingAgentCode: Code[10])
    begin
        WhseShipmentNo := NewWhseShipmentNo;
        ShippingAgentCode := NewShippingAgentCode;
    end;

    internal procedure GetWhseShipmentNo(): Code[20]
    begin
        exit(WhseShipmentNo);
    end;

    internal procedure GetShippingAgentCode(): Code[10]
    begin
        exit(ShippingAgentCode);
    end;

    internal procedure SetErrorMessage(NewErrorMessage: Text)
    begin
        ErrorMessage := NewErrorMessage;
    end;

    internal procedure GetErrorMessage(): Text
    begin
        exit(ErrorMessage);
    end;
}