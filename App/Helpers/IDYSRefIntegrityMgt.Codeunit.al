codeunit 11147640 "IDYS Ref. Integrity Mgt."
{
    procedure DeleteCurrencyMappings(CurrencyCode: Code[10]);
    var
        CurrencyMapping: Record "IDYS Currency Mapping";
    begin
        CurrencyMapping.SetRange("Currency Code", CurrencyCode);
        CurrencyMapping.DeleteAll();
    end;

    procedure DeleteCountryRegionMappings(CountryRegionCode: Code[10]);
    var
        CountryRegionMapping: Record "IDYS Country/Region Mapping";
    begin
        if CountryRegionMapping.Get(CountryRegionCode) then
            CountryRegionMapping.Delete(true);
    end;

    procedure DeleteShipmentMethodMappings(ShipmentMethodCode: Code[10]);
    var
        ShipmentMethodMapping: Record "IDYS Shipment Method Mapping";
    begin
        ShipmentMethodMapping.SetRange("Shipment Method Code", ShipmentMethodCode);
        ShipmentMethodMapping.DeleteAll();
    end;

    [Obsolete('IDYS Customer Setup fields have been moved to the Customer table.')]
    procedure DeleteCustomerSetup(CustomerNo: Code[20]);
    begin
    end;

    [Obsolete('IDYS Vendor Setup fields have been moved to the Vendor table.')]
    procedure DeleteVendorSetup(VendorNo: Code[20]);
    begin
    end;

    [Obsolete('IDYS Ship-to Address Setup fields have been moved to the Ship-to Address table.')]
    procedure DeleteShipToAddressSetup(CustomerNo: Code[20]; ShipToAddressCode: Code[10]);
    begin
    end;

    [Obsolete('IDYS Order Address Setup fields have been moved to the Order Address table.')]
    procedure DeleteOrderAddressSetup(VendorNo: Code[20]; OrderAddressCode: Code[10]);
    begin
    end;

    procedure DeleteShippingAgentMappings(ShippingAgentCode: Code[10]);
    var
        ShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        ShipAgentMapping.SetRange("Shipping Agent Code", ShippingAgentCode);
        ShipAgentMapping.DeleteAll();
        DeleteShippingAgentSvcMappings(ShippingAgentCode, '');
    end;

    procedure DeleteShippingAgentSvcMappings(ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10]);
    var
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
    begin
        ShipAgentSvcMapping.SetRange("Shipping Agent Code", ShippingAgentCode);

        if ShippingAgentServiceCode <> '' then
            ShipAgentSvcMapping.SetRange("Shipping Agent Service Code", ShippingAgentServiceCode);

        ShipAgentSvcMapping.DeleteAll();
        DeleteSvcBookingProfile(ShippingAgentCode, ShippingAgentServiceCode);
    end;

    procedure DeleteSvcBookingProfile(ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10])
    var
        IDYSSvcBookingProfile: Record "IDYS Svc. Booking Profile";
    begin
        IDYSSvcBookingProfile.SetRange("Shipping Agent Code", ShippingAgentCode);
        if ShippingAgentServiceCode <> '' then
            IDYSSvcBookingProfile.SetRange("Shipping Agent Service Code", ShippingAgentServiceCode);
        IDYSSvcBookingProfile.DeleteAll();
    end;

    procedure DeleteShippingAgentMappings(CarrierEntryNo: Integer);
    var
        ShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        ShipAgentMapping.SetCurrentKey("Carrier Entry No.");
        ShipAgentMapping.SetRange("Carrier Entry No.", CarrierEntryNo);
        if not ShipAgentMapping.IsEmpty() then
            ShipAgentMapping.DeleteAll();
        DeleteShippingAgentSvcMappings(CarrierEntryNo, 0);
    end;

    procedure DeleteShippingAgentSvcMappings(CarrierEntryNo: Integer; BookingProfileEntryNo: Integer);
    var
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
    begin
        ShipAgentSvcMapping.SetCurrentKey("Carrier Entry No.", "Booking Profile Entry No.");
        ShipAgentSvcMapping.SetRange("Carrier Entry No.", CarrierEntryNo);
        if BookingProfileEntryNo <> 0 then
            ShipAgentSvcMapping.SetRange("Booking Profile Entry No.", BookingProfileEntryNo);
        if not ShipAgentSvcMapping.IsEmpty() then
            ShipAgentSvcMapping.DeleteAll();
        DeleteSCShippingPrice(CarrierEntryNo, BookingProfileEntryNo);
        DeleteSvcBookingProfile(CarrierEntryNo, BookingProfileEntryNo);
    end;

    procedure DeleteSCShippingPrice(CarrierEntryNo: Integer; BookingProfileEntryNo: Integer)
    var
        IDYSSCShippingPrice: Record "IDYS SC Shipping Price";
    begin
        IDYSSCShippingPrice.SetRange("Carrier Entry No.", CarrierEntryNo);
        if BookingProfileEntryNo <> 0 then
            IDYSSCShippingPrice.SetRange("Booking Profile Entry No.", BookingProfileEntryNo);
        IDYSSCShippingPrice.DeleteAll();
    end;

    procedure DeleteSvcBookingProfile(CarrierEntryNo: Integer; BookingProfileEntryNo: Integer)
    var
        IDYSSvcBookingProfile: Record "IDYS Svc. Booking Profile";
    begin
        IDYSSvcBookingProfile.SetCurrentKey("Carrier Entry No.", "Booking Profile Entry No.");
        IDYSSvcBookingProfile.SetRange("Carrier Entry No.", CarrierEntryNo);
        if BookingProfileEntryNo <> 0 then
            IDYSSvcBookingProfile.SetRange("Booking Profile Entry No.", BookingProfileEntryNo);
        IDYSSvcBookingProfile.DeleteAll();
    end;
}