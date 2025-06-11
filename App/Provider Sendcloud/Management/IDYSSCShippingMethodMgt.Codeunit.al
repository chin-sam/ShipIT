codeunit 11147698 "IDYS SC Shipping Method Mgt."
{
    trigger OnRun()
    begin
    end;

    procedure UpdateMasterData(): Boolean
    var
        IDYSSCCountryRegionLine: Record "IDYS SC Country/Region Line";
        Handled: Boolean;
    begin
        if GuiAllowed() then
            if IDYSSCCountryRegionLine.IsEmpty() then
                if not Confirm(InformationQst) then
                    exit(false);

        OnBeforeUpdateShippingMethods(Handled);
        if not Handled then begin
            SyncSenderAddresses();
            SyncShippingMethods(false);
            SyncShippingMethods(true);
        end;
        OnAfterUpdateShippingMethods();

        exit(true);
    end;

    local procedure SyncSenderAddresses();
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        Statuscode: Integer;
        Response: JsonObject;
        ErrorMessage: Text;
        FinishedImportMsg: Label 'Finished synchronizing sender addresses.';
        FinishedImportTok: Label 'f57438e0-ef3f-4a0d-b9f5-afd95d5983ed', Locked = true;
    begin
        if GuiAllowed() then
            ProgressWindowDialog.Open('#1#######');

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
        TempIDYMRESTParameters.Path := '/user/addresses/sender';

        Statuscode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);
        if Statuscode <> 200 then
            IDYMHTTPHelper.ParseError(TempIDYMRESTParameters, Statuscode, ErrorMessage, true)
        else begin
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
            ProcessSenderAddressResponse(Response);
        end;

        if GuiAllowed() then begin
            ProgressWindowDialog.Close();
            IDYSNotificationManagement.SendNotification(FinishedImportTok, FinishedImportMsg);
        end;
    end;

    local procedure ProcessSenderAddressResponse(Response: JsonObject)
    var
        CountryRegion: Record "Country/Region";
        SenderAddresses: JsonArray;
        IDYSSCSenderAddress: JsonToken;
        SyncingMsg: Label 'Syncing %1 of %2 Sender Addresses.', Comment = '%1 = is current record, %2 = total records.';
        i: Integer;
        x: Integer;
        ISOCode: Code[2];
    begin
        if not Response.Contains('sender_addresses') then
            exit;

        SenderAddresses := IDYMJSONHelper.GetArray(Response, 'sender_addresses');

        Clear(i);
        x := SenderAddresses.Count();

        foreach IDYSSCSenderAddress in SenderAddresses do begin
            if GuiAllowed() then begin
                i += 1;
                ProgressWindowDialog.Update(1, StrSubstNo(SyncingMsg, i, x));
            end;

            ISOCode := CopyStr(IDYMJSONHelper.GetTextValue(IDYSSCSenderAddress.AsObject(), 'country'), 1, MaxStrLen(ISOCode));
            if CountryRegion.Get(GetCountryRegionCode(ISOCode)) then
                if not CountryRegion."IDYS Ship-from" then begin
                    CountryRegion.Validate("IDYS Ship-from", true);
                    CountryRegion.Validate("IDYS Used for Returns", true);
                    CountryRegion.Modify();
                end;
        end;
    end;

    [Obsolete('Added Parameters', '21.0')]
    procedure SyncShippingMethods()
    begin
    end;

    procedure SyncShippingMethods(IsReturn: Boolean);
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        CountryRegion: Record "Country/Region";
        IDYSSCCountryRegionLine: Record "IDYS SC Country/Region Line";
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        Statuscode: Integer;
        Response: JsonObject;
        ErrorMessage: Text;
        FinishedImportTok: Label 'bc35506e-c0f2-4425-94e9-84e1dc1455aa', Locked = true;
        FinishedImportMsg: Label 'Finished updating shipping methods and prices.';
        ShippingMethodLbl: Label '/shipping_methods?from_country=%1&to_country=%2&is_return=%3', Locked = true;
        SyncingCountryRegionMsg: Label 'Total records %1 of %2.', Comment = '%1 = is current record, %2 = total records.';
        SyncingRegularMethodsMsg: Label 'Syncing Shipping Methods';
        SyncingReturnsMainMsg: Label 'Syncing Return Shipping Methods';
        SyncingCountriesMsg: Label 'Syncing %1 of %2 countries (%3 -> %4).', Comment = '%1 = is current record, %2 = total records., %3 = country from, %4 = country to';
        CurrentShippingMethods: List of [Guid];
        ShipFromCountry: Code[2];
        ShipToCountry: Code[2];
        i: Integer;
        TotalRecordsCountries: Integer;
        x: Integer;
        TotalRecordsCountryLines: Integer;
        MainTxt: Text;
    begin
        if GuiAllowed() then
            ProgressWindowDialog.Open('#1#############\\#2#############\\#3#############\\#4#############');

        GetCurrentShippingMethods(CurrentShippingMethods, IsReturn);

        MainTxt := SyncingRegularMethodsMsg;
        if IsReturn then begin
            CountryRegion.SetRange("IDYS Used for Returns", IsReturn);
            MainTxt := SyncingReturnsMainMsg;
        end;
        ProgressWindowDialog.Update(1, StrSubstNo(MainTxt));

        CountryRegion.SetRange("IDYS Ship-from", true);
        CountryRegion.SetFilter("ISO Code", '<>%1', '');
        TotalRecordsCountries := CountryRegion.Count();

        if CountryRegion.FindSet() then
            repeat
                if GuiAllowed() then begin
                    i += 1;
                    x := 0;
                    ProgressWindowDialog.Update(2, StrSubstNo(SyncingCountryRegionMsg, i, TotalRecordsCountries));
                end;

                IDYSSCCountryRegionLine.SetRange("Ship-from Country", CountryRegion.Code);
                TotalRecordsCountryLines := IDYSSCCountryRegionLine.Count();

                IDYSSCCountryRegionLine.SetAutoCalcFields("Ship-from ISO Code", "Ship-to ISO Code");
                if IDYSSCCountryRegionLine.FindSet() then
                    repeat
                        // Set Ship-from / Ship-to Countries
                        if IsReturn then begin
                            ShipFromCountry := GetCountryRegionISOCode(IDYSSCCountryRegionLine."Ship-to Country");
                            ShipToCountry := GetCountryRegionISOCode(IDYSSCCountryRegionLine."Ship-from Country");
                        end else begin
                            ShipFromCountry := GetCountryRegionISOCode(IDYSSCCountryRegionLine."Ship-from Country");
                            ShipToCountry := GetCountryRegionISOCode(IDYSSCCountryRegionLine."Ship-to Country");
                        end;

                        if GuiAllowed() then begin
                            x += 1;
                            ProgressWindowDialog.Update(3, StrSubstNo(SyncingCountriesMsg, x, TotalRecordsCountryLines, ShipFromCountry, ShipToCountry));
                        end;

                        TempIDYMRESTParameters.Init();
                        TempIDYMRESTParameters.Accept := 'application/json';
                        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
                        TempIDYMRESTParameters.Path := StrSubstNo(ShippingMethodLbl, ShipFromCountry, ShipToCountry, Bool2Text(IsReturn));

                        Statuscode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);
                        if Statuscode <> 200 then
                            IDYMHTTPHelper.ParseError(TempIDYMRESTParameters, Statuscode, ErrorMessage, true)
                        else begin
                            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
                            ProcessShippingMethodResponse(Response, CurrentShippingMethods, ShipFromCountry, IsReturn);
                        end;
                    until IDYSSCCountryRegionLine.Next() = 0;
            Until CountryRegion.Next() = 0;

        CleanShippingMethods(CurrentShippingMethods);

        if GuiAllowed() then begin
            ProgressWindowDialog.Close();
            IDYSNotificationManagement.SendNotification(FinishedImportTok, FinishedImportMsg);
        end;
    end;

    local procedure GetCurrentShippingMethods(var BookingProfileList: List of [Guid]; IsReturn: Boolean)
    var
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
    begin
        IDYSProviderBookingProfile.SetRange(Provider, "IDYS Provider"::Sendcloud);
        IDYSProviderBookingProfile.SetRange("Is Return", IsReturn);
        if IDYSProviderBookingProfile.FindSet() then
            repeat
                BookingProfileList.Add(IDYSProviderBookingProfile.SystemId);
            until IDYSProviderBookingProfile.Next() = 0;
    end;

    local procedure CleanShippingMethods(var CurrentBookingProfiles: List of [Guid])
    var
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        BookingProfileId: Guid;
    begin
        foreach BookingProfileId in CurrentBookingProfiles do
            if IDYSProviderBookingProfile.GetBySystemId(BookingProfileId) then
                IDYSProviderBookingProfile.Delete(true);
    end;

    local procedure ProcessShippingMethodResponse(Response: JsonObject; var CurrentShippingMethods: List of [Guid]; ShipFromCountryIsoCode: Code[2]; IsReturn: Boolean)
    var
        ShippingMethods: JsonArray;
        ShippingMethod: JsonToken;
        SyncingShippingMethodMsg: Label 'Syncing %1 of %2 shipping methods.', Comment = '%1 = is current record, %2 = total records.';
        i: Integer;
        x: Integer;
    begin
        if not Response.Contains('shipping_methods') then
            exit;

        ShippingMethods := IDYMJSONHelper.GetArray(Response, 'shipping_methods');

        Clear(i);
        x := ShippingMethods.Count();

        foreach ShippingMethod in ShippingMethods do begin
            if GuiAllowed() then begin
                i += 1;
                ProgressWindowDialog.Update(4, StrSubstNo(SyncingShippingMethodMsg, i, x));
            end;
            ProcessShippingMethod(ShippingMethod.AsObject(), CurrentShippingMethods, ShipFromCountryIsoCode, IsReturn);
        end;
    end;

    local procedure ProcessShippingMethod(ShipMeth: JsonObject; var CurrentShippingMethods: List of [Guid]; ShipFromCountryIsoCode: Code[2]; IsReturn: Boolean)
    var
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        Countries: JsonArray;
        Country: JsonToken;
    begin
        IDYSProviderBookingProfile.SetRange(Provider, "IDYS Provider"::Sendcloud);
        IDYSProviderBookingProfile.SetRange(Id, IDYMJSONHelper.GetIntegerValue(ShipMeth, 'id'));
        if not IDYSProviderBookingProfile.FindFirst() then begin
            IDYSProviderBookingProfile.Init();
            IDYSProviderBookingProfile.Id := IDYMJSONHelper.GetIntegerValue(ShipMeth, 'id');
            IDYSProviderBookingProfile."Carrier Entry No." := CreateCarrier(CopyStr(IDYMJSONHelper.GetTextValue(ShipMeth, 'carrier'), 1, MaxStrLen(IDYSProviderBookingProfile."Carrier Name")));
            IDYSProviderBookingProfile."Is Return" := IsReturn;
            IDYSProviderBookingProfile.Insert(true);
        end else
            CurrentShippingMethods.Remove(IDYSProviderBookingProfile.SystemId);

        IDYSProviderBookingProfile.Description := CopyStr(IDYMJSONHelper.GetTextValue(ShipMeth, 'name'), 1, MaxStrLen(IDYSProviderBookingProfile.Description));
        IDYSProviderBookingProfile."Min. Weight" := IDYMJSONHelper.GetDecimalValue(ShipMeth, 'min_weight');
        IDYSProviderBookingProfile."Max. Weight" := IDYMJSONHelper.GetDecimalValue(ShipMeth, 'max_weight');
        IDYSProviderBookingProfile.Modify(true);

        if ShipMeth.Contains('countries') then begin
            Countries := IDYMJSONHelper.GetArray(ShipMeth, 'countries');
            foreach Country in Countries do
                ProcessCountry(Country.AsObject(), IDYSProviderBookingProfile, ShipFromCountryIsoCode, IsReturn);
        end;
    end;

    local procedure ProcessCountry(Country: JsonObject; var IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile"; ShipFromCountryIsoCode: Code[2]; IsReturn: Boolean)
    var
        IDYSSCShippingPrice: Record "IDYS SC Shipping Price";
        ShipToCountryIsoCode: Code[2];
    begin
        // NOTE - Always 1 entry because from -> to rule is specified
        ShipToCountryIsoCode := CopyStr(IDYMJSONHelper.GetCodeValue(Country, 'iso_2'), 1, MaxStrLen(ShipToCountryIsoCode));
        if not IDYSSCShippingPrice.Get(IDYSProviderBookingProfile."Carrier Entry No.", IDYSProviderBookingProfile."Entry No.", ShipFromCountryIsoCode, ShipToCountryIsoCode) then begin
            IDYSSCShippingPrice.Init();
            IDYSSCShippingPrice."Carrier Entry No." := IDYSProviderBookingProfile."Carrier Entry No.";
            IDYSSCShippingPrice."Booking Profile Entry No." := IDYSProviderBookingProfile."Entry No.";
            IDYSSCShippingPrice."Country (from)" := ShipFromCountryIsoCode;
            IDYSSCShippingPrice."Country (to)" := ShipToCountryIsoCode;
            IDYSSCShippingPrice.Insert(true);
        end;

        IDYSSCShippingPrice."Is Return" := IsReturn;
        IDYSSCShippingPrice."Country Name" := CopyStr(IDYMJSONHelper.GetTextValue(Country, 'name'), 1, MaxStrLen(IDYSSCShippingPrice."Country Name"));
        IDYSSCShippingPrice.Price := IDYMJSONHelper.GetDecimalValue(Country, 'price');
        IDYSSCShippingPrice."Last Update" := CurrentDateTime();

        IDYSSCShippingPrice.Modify(true);
    end;

    procedure GetCountryRegionCode(ISO2: Code[2]): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        //NOTE - Exceptions
        // Country/Region: IsoCode = GB -> Code = GB
        case ISO2 of
            'GR':
                if CountryRegion.Get('EL') then
                    exit(CountryRegion.Code);
            else begin
                CountryRegion.SetRange("ISO Code", ISO2);
                if CountryRegion.FindFirst() then
                    exit(CountryRegion."Code");
            end;
        end;
    end;

    procedure GetCountryRegionISOCode(CountryRegionCode: Code[10]): Code[2]
    var
        CountryRegion: Record "Country/Region";
    begin
        // NOTE - exception for Greece
        // Additional information:
        //   https://publications.europa.eu/code/pdf/370000en.htm
        //   'The two-letter ISO code should be used (ISO 3166 alpha-2), except for Greece, for which the abbreviation EL is recommended.'

        if CountryRegion.Get(CountryRegionCode) then begin
            if CountryRegion."ISO Code" = 'EL' then
                exit('GR');
            exit(CountryRegion."ISO Code");
        end;
    end;

    local procedure CreateCarrier(CarrierName: Text[100]): Integer
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
    begin
        IDYSProviderCarrier.SetRange(Provider, IDYSProviderCarrier.Provider::Sendcloud);
        IDYSProviderCarrier.SetRange(Name, CarrierName);
        if not IDYSProviderCarrier.FindFirst() then begin
            IDYSProviderCarrier.Init();
            IDYSProviderCarrier.Validate(Provider, IDYSProviderCarrier.Provider::Sendcloud);
            IDYSProviderCarrier.Name := CarrierName;
            IDYSProviderCarrier.Insert(true);
        end;

        exit(IDYSProviderCarrier."Entry No.");
    end;

    local procedure Bool2Text(Input: Boolean): Text
    begin
        if Input then
            exit('true')
        else
            exit('false');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateShippingMethods(var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateShippingMethods();
    begin
    end;

    var
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        ProgressWindowDialog: Dialog;
        InformationQst: Label 'The synchronization algorithm ensures that sender addresses (Sendcloud portal) are synced with countries on Business Central.\\All existing country/region codes are used as possible ship-to countries. This might result in long waiting times.\\You can delimit ship-to countries on the Sendcloud Setup. Would you like to continue with synchronization?';
}