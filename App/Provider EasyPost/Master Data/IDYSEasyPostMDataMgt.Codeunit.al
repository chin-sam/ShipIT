codeunit 11147725 "IDYS EasyPost M. Data Mgt."
{
    procedure UpdateMasterData(ShowNotifications: Boolean) Completed: Boolean
    var
        IDYSCreateMappings: Codeunit "IDYS Create Mappings";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        MasterDataUpdatedTok: Label '3e40c986-d758-43ea-b91c-ec691ed719a8', Locked = true;
        MasterDataUpdatedMsg: Label 'The EasyPost master data has been successfully updated.';
    begin
        GetSetup();

        IDYSCreateMappings.MapUnitOfMeasure();
        if not GetMasterData() then
            exit;

        if (GuiAllowed()) and ShowNotifications then
            IDYSNotificationManagement.SendNotification(MasterDataUpdatedTok, MasterDataUpdatedMsg);
    end;

    local procedure GetMasterData(): Boolean
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Statuscode: Integer;
        Carriers: JsonArray;
        Carrier: JsonToken;
        EndpointTxt: Label '/carrier_accounts', Locked = true;
        SyncingMsg: Label 'Syncing %1 of %2 carriers.', Comment = '%1 = is current record, %2 = total records';
        RequestingDataMsg: Label 'Retrieving data from the EasyPost API...';
        i: Integer;
        x: Integer;
    begin
        // There is no test mode (only production) available for this method
        if GuiAllowed() then begin
            ProgressWindowDialog.Open('#1#######');
            ProgressWindowDialog.Update(1, RequestingDataMsg);
        end;

        GetSetup();
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt);

        Statuscode := IDYMHttpHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::EasyPost, "IDYM Endpoint Usage"::Default);
        if not (Statuscode In [200, 201]) then begin
            IDYSEasyPostErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;

        GetCurrentMasterData();

        Carriers := TempIDYMRESTParameters.GetResponseBodyAsJSONArray();
        x := Carriers.Count();
        foreach Carrier in Carriers do begin
            if GuiAllowed() then begin
                i += 1;
                ProgressWindowDialog.Update(1, StrSubstNo(SyncingMsg, i, x));
            end;
            ProcessData(Carrier);
        end;
        ProcessIncoterms();
        CleanMasterData();

        if GuiAllowed() then
            ProgressWindowDialog.Close();

        exit(true);
    end;

    local procedure ProcessData(Carrier: JsonToken)
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
        Packages: List of [Text];
        Package: Text;
        BookingProfiles: List of [Text];
        BookingProfile: Text;
    begin
        // Carriers
        IDYSProviderCarrier.SetRange(Provider, IDYSProviderCarrier.Provider::EasyPost);
        IDYSProviderCarrier.SetRange("Carrier Id", IDYMJSONHelper.GetTextValue(Carrier, 'id'));
        if not IDYSProviderCarrier.FindFirst() then begin
            IDYSProviderCarrier.Init();
            IDYSProviderCarrier.Validate(Provider, IDYSProviderCarrier.Provider::EasyPost);
            IDYSProviderCarrier.Validate("Carrier Id", IDYMJSONHelper.GetTextValue(Carrier, 'id'));
            IDYSProviderCarrier.Insert(true);
        end else
            CurrentProviderCarrierList.Remove(IDYSProviderCarrier.SystemId);

        IDYSProviderCarrier.Name := CopyStr(IDYMJSONHelper.GetTextValue(Carrier, 'description'), 1, MaxStrLen(IDYSProviderCarrier.Name));
        IDYSProviderCarrier.Modify(true);

        // Booking Profiles
        GetBookingProfiles(IDYMJSONHelper.GetTextValue(Carrier, 'readable'), BookingProfiles);
        foreach BookingProfile in BookingProfiles do begin
            Clear(IDYSProviderBookingProfile);
            IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
            IDYSProviderBookingProfile.SetRange(Description, CopyStr(BookingProfile, 1, MaxStrLen(IDYSProviderBookingProfile.Description)));
            if not IDYSProviderBookingProfile.FindLast() then begin
                IDYSProviderBookingProfile."Carrier Entry No." := IDYSProviderCarrier."Entry No.";
                IDYSProviderBookingProfile.Description := CopyStr(BookingProfile, 1, MaxStrLen(IDYSProviderBookingProfile.Description));
                IDYSProviderBookingProfile.Insert(true);
            end else
                CurrentProviderBookingProfileList.Remove(IDYSProviderBookingProfile.SystemId);
        end;

        // Predefined packages (not bound to profile)
        GetPackages(IDYMJSONHelper.GetTextValue(Carrier, 'readable'), Packages);
        foreach Package in Packages do
            if not IDYSBookingProfPackageType.Get(IDYSProviderBookingProfile."Carrier Entry No.", 0, CopyStr(Package, 1, MaxStrLen(IDYSBookingProfPackageType."Package Type Code"))) then begin
                IDYSBookingProfPackageType.Init();
                IDYSBookingProfPackageType.Validate("Carrier Entry No.", IDYSProviderBookingProfile."Carrier Entry No.");
                IDYSBookingProfPackageType.Validate("Package Type Code", CopyStr(Package, 1, MaxStrLen(IDYSBookingProfPackageType."Package Type Code")));
                IDYSBookingProfPackageType.Insert();
            end else
                CurrentBookingProfPackageTypeList.Remove(IDYSBookingProfPackageType.SystemId);
    end;

    local procedure CleanMasterData()
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
        ProviderCarrierId: Guid;
        ProviderBookingProfileId: Guid;
        BookingProfPackageTypeId: Guid;
    begin
        foreach ProviderCarrierId in CurrentProviderCarrierList do
            if IDYSProviderCarrier.GetBySystemId(ProviderCarrierId) then
                IDYSProviderCarrier.Delete();

        foreach ProviderBookingProfileId in CurrentProviderBookingProfileList do
            if IDYSProviderBookingProfile.GetBySystemId(ProviderBookingProfileId) then
                IDYSProviderBookingProfile.Delete(true);

        foreach BookingProfPackageTypeId in CurrentBookingProfPackageTypeList do
            if IDYSBookingProfPackageType.GetBySystemId(BookingProfPackageTypeId) then
                IDYSBookingProfPackageType.Delete();
    end;

    local procedure GetCurrentMasterData()
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
    begin
        IDYSProviderCarrier.SetRange(Provider, IDYSProviderCarrier.Provider::EasyPost);
        if IDYSProviderCarrier.FindSet() then
            repeat
                CurrentProviderCarrierList.Add(IDYSProviderCarrier.SystemId);

                IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
                if IDYSProviderBookingProfile.FindSet() then
                    repeat
                        CurrentProviderBookingProfileList.Add(IDYSProviderBookingProfile.SystemId);
                    until IDYSProviderBookingProfile.Next() = 0;
            until IDYSProviderCarrier.Next() = 0;

        IDYSBookingProfPackageType.SetRange(Provider, IDYSBookingProfPackageType.Provider::EasyPost);
        if IDYSBookingProfPackageType.FindSet() then
            repeat
                CurrentBookingProfPackageTypeList.Add(IDYSBookingProfPackageType.SystemId);
            until IDYSBookingProfPackageType.Next() = 0;
    end;

    local procedure GetSetup(): Boolean
    begin
        if not SetupLoaded then
            SetupLoaded := IDYSSetup.Get();

        if not ProviderSetupLoaded then begin
            IDYSEasyPostSetup.GetProviderSetup("IDYS Provider"::EasyPost);
            ProviderSetupLoaded := true;
        end;

        exit(SetupLoaded);
    end;

    local procedure GetBookingProfiles(CarrierType: Text; var ReturnList: List of [Text])
    begin
        // API Documentation: https://www.easypost.com/docs/api#service-levels
        // Last updated - 2023-02-21

        #region [CodeToGetServiceLevelFromThePortal]
        // // Get all the HTML elements containing the carrier and service data
        // var carrierDataElements = document.querySelectorAll('[class^="tab-pane carrier-"]');

        // // Create an object to hold the carrier and service information
        // var carrierData = {};

        // // Loop through each carrier tab in the HTML
        // for (var i = 0; i < carrierDataElements.length; i++) {

        //   // Get the carrier name from the class of the carrier tab
        //   var carrierName = carrierDataElements[i].querySelector('img').getAttribute('alt').toLowerCase();

        //   // Get an array of service names from the list items in the carrier tab
        //   var serviceNames = [];
        //   var serviceElements = carrierDataElements[i].querySelectorAll('li');
        //   for (var j = 0; j < serviceElements.length; j++) {
        //     serviceNames.push("ReturnList.Add('" + serviceElements[j].textContent + "');");
        //   }

        //   // Construct the string for the carrier and service information
        //   var carrierDataString = "begin " + serviceNames.join(' ') + " end;";

        //   // Add the carrier and service information to the object
        //   carrierData[carrierName] = carrierDataString;

        // }

        // // Print the carrier and service information to the console
        // console.log(carrierData);
        #endregion

        case LowerCase(CarrierType) of
            'upsdap':
                begin
                    ReturnList.Add('Ground');
                    ReturnList.Add('UPSStandard');
                    ReturnList.Add('UPSSaver');
                    ReturnList.Add('Express');
                    ReturnList.Add('ExpressPlus');
                    ReturnList.Add('Expedited');
                    ReturnList.Add('NextDayAir');
                    ReturnList.Add('NextDayAirSaver');
                    ReturnList.Add('NextDayAirEarlyAM');
                    ReturnList.Add('2ndDayAir');
                    ReturnList.Add('2ndDayAirAM');
                    ReturnList.Add('3DaySelect');
                end;
            'lso':
                begin
                    ReturnList.Add('GroundEarly');
                    ReturnList.Add('GroundBasic');
                    ReturnList.Add('PriorityBasic');
                    ReturnList.Add('PriorityEarly');
                    ReturnList.Add('PrioritySaturday');
                    ReturnList.Add('Priority2ndDay');
                    ReturnList.Add('SameDay');
                end;
            'dhl express':
                begin
                    ReturnList.Add('BreakBulkEconomy');
                    ReturnList.Add('BreakBulkExpress');
                    ReturnList.Add('DomesticEconomySelect');
                    ReturnList.Add('DomesticExpress');
                    ReturnList.Add('DomesticExpress1030');
                    ReturnList.Add('DomesticExpress1200');
                    ReturnList.Add('EconomySelect');
                    ReturnList.Add('EconomySelectNonDoc');
                    ReturnList.Add('EuroPack');
                    ReturnList.Add('EuropackNonDoc');
                    ReturnList.Add('Express1030');
                    ReturnList.Add('Express1030NonDoc');
                    ReturnList.Add('Express1200NonDoc');
                    ReturnList.Add('Express1200');
                    ReturnList.Add('Express900');
                    ReturnList.Add('Express900NonDoc');
                    ReturnList.Add('ExpressEasy');
                    ReturnList.Add('ExpressEasyNonDoc');
                    ReturnList.Add('ExpressEnvelope');
                    ReturnList.Add('ExpressWorldwide');
                    ReturnList.Add('ExpressWorldwideB2C');
                    ReturnList.Add('ExpressWorldwideB2CNonDoc');
                    ReturnList.Add('ExpressWorldwideECX');
                    ReturnList.Add('ExpressWorldwideNonDoc');
                    ReturnList.Add('FreightWorldwide');
                    ReturnList.Add('GlobalmailBusiness');
                    ReturnList.Add('JetLine');
                    ReturnList.Add('JumboBox');
                    ReturnList.Add('LogisticsServices');
                    ReturnList.Add('SameDay');
                    ReturnList.Add('SecureLine');
                    ReturnList.Add('SprintLine');
                end;
            'usps':
                begin
                    ReturnList.Add('First');
                    ReturnList.Add('Priority');
                    ReturnList.Add('Express');
                    ReturnList.Add('ParcelSelect');
                    ReturnList.Add('LibraryMail');
                    ReturnList.Add('MediaMail');
                    ReturnList.Add('FirstClassMailInternational');
                    ReturnList.Add('FirstClassPackageInternationalService');
                    ReturnList.Add('PriorityMailInternational');
                    ReturnList.Add('ExpressMailInternational');
                end;
            // Unknown services (can't guarantee that the Readable from the .../carrier_accounts will match)
            'amazonmws':
                begin
                    ReturnList.Add('UPS Rates');
                    ReturnList.Add('USPS Rates');
                    ReturnList.Add('FedEx Rates');
                    ReturnList.Add('UPS Labels');
                    ReturnList.Add('USPS Labels');
                    ReturnList.Add('FedEx Labels');
                    ReturnList.Add('UPS Tracking');
                    ReturnList.Add('USPS Tracking');
                    ReturnList.Add('FedEx Tracking');
                end;
            'apc':
                begin
                    ReturnList.Add('parcelConnectBookService');
                    ReturnList.Add('parcelConnectExpeditedDDP');
                    ReturnList.Add('parcelConnectExpeditedDDU');
                    ReturnList.Add('parcelConnectPriorityDDP');
                    ReturnList.Add('parcelConnectPriorityDDPDelcon');
                    ReturnList.Add('parcelConnectPriorityDDU');
                    ReturnList.Add('parcelConnectPriorityDDUDelcon');
                    ReturnList.Add('parcelConnectPriorityDDUPQW');
                    ReturnList.Add('parcelConnectStandardDDU');
                    ReturnList.Add('parcelConnectStandardDDUPQW');
                    ReturnList.Add('parcelConnectPacketDDU');
                end;
            'asendia usa':
                begin
                    ReturnList.Add('ADS');
                    ReturnList.Add('AirFreightInbound');
                    ReturnList.Add('AirFreightOutbound');
                    ReturnList.Add('AsendiaDomesticBoundPrinterMatterExpedited');
                    ReturnList.Add('AsendiaDomesticBoundPrinterMatterGround');
                    ReturnList.Add('AsendiaDomesticFlatsExpedited');
                    ReturnList.Add('AsendiaDomesticFlatsGround');
                    ReturnList.Add('AsendiaDomesticParcelGroundOver1lb');
                    ReturnList.Add('AsendiaDomesticParcelGroundUnder1lb');
                    ReturnList.Add('AsendiaDomesticParcelMAXOver1lb');
                    ReturnList.Add('AsendiaDomesticParcelMAXUnder1lb');
                    ReturnList.Add('AsendiaDomesticParcelOver1lbExpedited');
                    ReturnList.Add('AsendiaDomesticParcelUnder1lbExpedited');
                    ReturnList.Add('AsendiaDomesticPromoParcelExpedited');
                    ReturnList.Add('AsendiaDomesticPromoParcelGround');
                    ReturnList.Add('BulkFreight');
                    ReturnList.Add('BusinessMailCanadaLettermail');
                    ReturnList.Add('BusinessMailCanadaLettermailMachineable');
                    ReturnList.Add('BusinessMailEconomy');
                    ReturnList.Add('BusinessMailEconomyLPWholesale');
                    ReturnList.Add('BusinessMailEconomySPWholesale');
                    ReturnList.Add('BusinessMailIPA');
                    ReturnList.Add('BusinessMailISAL');
                    ReturnList.Add('BusinessMailPriority');
                    ReturnList.Add('BusinessMailPriorityLPWholesale');
                    ReturnList.Add('BusinessMailPrioritySPWholesale');
                    ReturnList.Add('MarketingMailCanadaPersonalizedLCP');
                    ReturnList.Add('MarketingMailCanadaPersonalizedMachineable');
                    ReturnList.Add('MarketingMailCanadaPersonalizedNDG');
                    ReturnList.Add('MarketingMailEconomy');
                    ReturnList.Add('MarketingMailIPA');
                    ReturnList.Add('MarketingMailISAL');
                    ReturnList.Add('MarketingMailPriority');
                    ReturnList.Add('PublicationsCanadaLCP');
                    ReturnList.Add('PublicationsCanadaNDG');
                    ReturnList.Add('PublicationsEconomy');
                    ReturnList.Add('PublicationsIPA');
                    ReturnList.Add('PublicationsISAL');
                    ReturnList.Add('PublicationsPriority');
                    ReturnList.Add('ePAQElite');
                    ReturnList.Add('ePAQEliteCustom');
                    ReturnList.Add('ePAQEliteDAP');
                    ReturnList.Add('ePAQEliteDDP');
                    ReturnList.Add('ePAQEliteDDPOversized');
                    ReturnList.Add('ePAQEliteDPD');
                    ReturnList.Add('ePAQEliteDirectAccessCanadaDDP');
                    ReturnList.Add('ePAQEliteOversized');
                    ReturnList.Add('ePAQPlus');
                    ReturnList.Add('ePAQPlusCustom');
                    ReturnList.Add('ePAQPlusCustomsPrepaid');
                    ReturnList.Add('ePAQPlusDAP');
                    ReturnList.Add('ePAQPlusDDP');
                    ReturnList.Add('ePAQPlusEconomy');
                    ReturnList.Add('ePAQPlusWholesale');
                    ReturnList.Add('ePAQPlusePacket');
                    ReturnList.Add('ePAQPlusePacketCanadaCustomsPrePaid');
                    ReturnList.Add('ePAQPlusePacketCanadaDDP');
                    ReturnList.Add('ePAQReturnsDomestic');
                    ReturnList.Add('ePAQReturnsInternational');
                    ReturnList.Add('ePAQSelect');
                    ReturnList.Add('ePAQSelectCustom');
                    ReturnList.Add('ePAQSelectCustomsPrepaidByShopper');
                    ReturnList.Add('ePAQSelectDAP');
                    ReturnList.Add('ePAQSelectDDP');
                    ReturnList.Add('ePAQSelectDDPDirectAccess');
                    ReturnList.Add('ePAQSelectDirectAccess');
                    ReturnList.Add('ePAQSelectDirectAccessCanadaDDP');
                    ReturnList.Add('ePAQSelectEconomy');
                    ReturnList.Add('ePAQSelectOversized');
                    ReturnList.Add('ePAQSelectOversizedDDP');
                    ReturnList.Add('ePAQSelectPMEI');
                    ReturnList.Add('ePAQSelectPMEICanadaCustomsPrePaid');
                    ReturnList.Add('ePAQSelectPMEIPCPostage');
                    ReturnList.Add('ePAQSelectPMI');
                    ReturnList.Add('ePAQSelectPMICanadaCustomsPrepaid');
                    ReturnList.Add('ePAQSelectPMICanadaDDP');
                    ReturnList.Add('ePAQSelectPMINonPresort');
                    ReturnList.Add('ePAQSelectPMIPCPostage');
                    ReturnList.Add('ePAQStandard');
                    ReturnList.Add('ePAQStandardCustom');
                    ReturnList.Add('ePAQStandardEconomy');
                    ReturnList.Add('ePAQStandardIPA');
                    ReturnList.Add('ePAQStandardISAL');
                    ReturnList.Add('ePaqSelectPMEINonPresort');
                end;
            'australia post':
                begin
                    ReturnList.Add('ExpressPost');
                    ReturnList.Add('ExpressPostSignature');
                    ReturnList.Add('ParcelPost');
                    ReturnList.Add('ParcelPostSignature');
                    ReturnList.Add('ParcelPostExtra');
                    ReturnList.Add('ParcelPostWinePlusSignature');
                end;
            'axlehirev3':
                ReturnList.Add('AxleHireDelivery');
            'better trucks':
                ReturnList.Add('NEXT_DAY');
            'canada post':
                begin
                    ReturnList.Add('RegularParcel');
                    ReturnList.Add('ExpeditedParcel');
                    ReturnList.Add('Xpresspost');
                    ReturnList.Add('XpresspostCertified');
                    ReturnList.Add('Priority');
                    ReturnList.Add('LibraryBooks');
                    ReturnList.Add('ExpeditedParcelUSA');
                    ReturnList.Add('PriorityWorldwideEnvelopeUSA');
                    ReturnList.Add('PriorityWorldwidePakUSA');
                    ReturnList.Add('PriorityWorldwideParcelUSA');
                    ReturnList.Add('SmallPacketUSAAir');
                    ReturnList.Add('TrackedPacketUSA');
                    ReturnList.Add('TrackedPacketUSALVM');
                    ReturnList.Add('XpresspostUSA');
                    ReturnList.Add('XpresspostInternational');
                    ReturnList.Add('InternationalParcelAir');
                    ReturnList.Add('InternationalParcelSurface');
                    ReturnList.Add('PriorityWorldwideEnvelopeIntl');
                    ReturnList.Add('PriorityWorldwidePakIntl');
                    ReturnList.Add('PriorityWorldwideParcelIntl');
                    ReturnList.Add('SmallPacketInternationalAir');
                    ReturnList.Add('SmallPacketInternationalSurface');
                    ReturnList.Add('TrackedPacketInternational');
                end;
            'canpar':
                begin
                    ReturnList.Add('Ground');
                    ReturnList.Add('SelectLetter');
                    ReturnList.Add('SelectPak');
                    ReturnList.Add('Select');
                    ReturnList.Add('OvernightLetter');
                    ReturnList.Add('OvernightPak');
                    ReturnList.Add('Overnight');
                    ReturnList.Add('SelectUSA');
                    ReturnList.Add('USAPak');
                    ReturnList.Add('USALetter');
                    ReturnList.Add('USA');
                    ReturnList.Add('International');
                end;
            'cdl last mile solutions':
                begin
                    ReturnList.Add('DISTRIBUTION');
                    ReturnList.Add('Same Day');
                end;
            'chronopost':
                ;
            'cloudsort':
                ;
            'courier express':
                ReturnList.Add('BASIC_PARCEL');
            'couriersplease':
                begin
                    ReturnList.Add('DomesticPrioritySignature');
                    ReturnList.Add('DomesticPriority');
                    ReturnList.Add('DomesticOffPeakSignature');
                    ReturnList.Add('DomesticOffPeak');
                    ReturnList.Add('GoldDomesticSignature');
                    ReturnList.Add('GoldDomestic');
                    ReturnList.Add('AustralianCityExpressSignature');
                    ReturnList.Add('AustralianCityExpress');
                    ReturnList.Add('DomesticSaverSignature');
                    ReturnList.Add('DomesticSaver');
                    ReturnList.Add('RoadExpress');
                    ReturnList.Add('5KgSatchel');
                    ReturnList.Add('3KgSatchel');
                    ReturnList.Add('1KgSatchel');
                    ReturnList.Add('5KgSatchelATL');
                    ReturnList.Add('3KgSatchelATL');
                    ReturnList.Add('1KgSatchelATL');
                    ReturnList.Add('500GramSatchel');
                    ReturnList.Add('500GramSatchelATL');
                    ReturnList.Add('25KgParcel');
                    ReturnList.Add('10KgParcel');
                    ReturnList.Add('5KgParcel');
                    ReturnList.Add('3KgParcel');
                    ReturnList.Add('1KgParcel');
                    ReturnList.Add('500GramParcel');
                    ReturnList.Add('500GramParcelATL');
                    ReturnList.Add('ExpressInternationalPriority');
                    ReturnList.Add('InternationalSaver');
                    ReturnList.Add('InternationalExpressImport');
                    ReturnList.Add('InternationalExpress');
                end;
            'dai post':
                begin
                    ReturnList.Add('DomesticTracked');
                    ReturnList.Add('InternationalEconomy');
                    ReturnList.Add('InternationalStandard');
                    ReturnList.Add('InternationalExpress');
                end;
            'deliverit':
                begin
                    ReturnList.Add('Afternoon');
                    ReturnList.Add('Early-It');
                    ReturnList.Add('Economy');
                    ReturnList.Add('Noon-It');
                    ReturnList.Add('Saturday');
                end;
            'deutsche post':
                ReturnList.Add('PacketPlus');
            'deutsche post uk':
                begin
                    ReturnList.Add('PriorityPacketPlus');
                    ReturnList.Add('PriorityPacket');
                    ReturnList.Add('PriorityPacketTracked');
                    ReturnList.Add('BusinessMailRegistered');
                    ReturnList.Add('StandardPacket');
                    ReturnList.Add('BusinessMailStandard');
                end;
            'dhl ecommerce asia':
                begin
                    ReturnList.Add('Packet');
                    ReturnList.Add('PacketPlus');
                    ReturnList.Add('ParcelDirect');
                    ReturnList.Add('ParcelDirectExpedited');
                end;
            'dhl ecommerce solutions':
                begin
                    ReturnList.Add('DHLParcelExpedited');
                    ReturnList.Add('DHLParcelExpeditedMax');
                    ReturnList.Add('DHLParcelGround');
                    ReturnList.Add('DHLBPMExpedited');
                    ReturnList.Add('DHLBPMGround');
                    ReturnList.Add('DHLParcelInternationalDirect');
                    ReturnList.Add('DHLParcelInternationalStandard');
                    ReturnList.Add('DHLPacketInternational');
                    ReturnList.Add('DHLParcelInternationalDirectPriority');
                    ReturnList.Add('DHLParcelInternationalDirectStandard');
                end;

            'dhl paket':
                begin
                    ReturnList.Add('Paket');
                    ReturnList.Add('PaketConnect');
                    ReturnList.Add('ReturnOnline');
                    ReturnList.Add('ReturnIntl');
                end;
            'dhl smartmail':
                ;
            'dpd':
                begin
                    ReturnList.Add('DPDCLASSIC');
                    ReturnList.Add('DPD8:30');
                    ReturnList.Add('DPD10:00');
                    ReturnList.Add('DPD12:00');
                    ReturnList.Add('DPD18:00');
                    ReturnList.Add('DPDEXPRESS');
                    ReturnList.Add('DPDPARCELLETTER');
                    ReturnList.Add('DPDPARCELLETTERPLUS');
                    ReturnList.Add('DPDINTERNATIONALMAIL');
                end;
            'dpd uk':
                begin
                    ReturnList.Add('AirExpressInternationalAir');
                    ReturnList.Add('AirClassicInternationalAir');
                    ReturnList.Add('ParcelSunday');
                    ReturnList.Add('FreightParcelSunday');
                    ReturnList.Add('PalletSunday');
                    ReturnList.Add('PalletDpdClassic');
                    ReturnList.Add('ExpresspakDpdClassic');
                    ReturnList.Add('ExpresspakSunday');
                    ReturnList.Add('ParcelDpdClassic');
                    ReturnList.Add('ParcelDpdTwoDay');
                    ReturnList.Add('ParcelDpdNextDay');
                    ReturnList.Add('ParcelDpd12');
                    ReturnList.Add('ParcelDpd10');
                    ReturnList.Add('ParcelReturnToShop');
                    ReturnList.Add('ParcelSaturday');
                    ReturnList.Add('ParcelSaturday12');
                    ReturnList.Add('ParcelSaturday10');
                    ReturnList.Add('ParcelSunday12');
                    ReturnList.Add('FreightParcelDpdClassic');
                    ReturnList.Add('FreightParcelSunday12');
                    ReturnList.Add('ExpresspakDpdNextDay');
                    ReturnList.Add('ExpresspakDpd12');
                    ReturnList.Add('ExpresspakDpd10');
                    ReturnList.Add('ExpresspakSaturday');
                    ReturnList.Add('ExpresspakSaturday12');
                    ReturnList.Add('ExpresspakSaturday10');
                    ReturnList.Add('ExpresspakSunday12');
                    ReturnList.Add('PalletSunday12');
                    ReturnList.Add('PalletDpdTwoDay');
                    ReturnList.Add('PalletDpdNextDay');
                    ReturnList.Add('PalletDpd12');
                    ReturnList.Add('PalletDpd10');
                    ReturnList.Add('PalletSaturday');
                    ReturnList.Add('PalletSaturday12');
                    ReturnList.Add('PalletSaturday10');
                    ReturnList.Add('FreightParcelDpdTwoDay');
                    ReturnList.Add('FreightParcelDpdNextDay');
                    ReturnList.Add('FreightParcelDpd12');
                    ReturnList.Add('FreightParcelDpd10');
                    ReturnList.Add('FreightParcelSaturday');
                    ReturnList.Add('FreightParcelSaturday12');
                    ReturnList.Add('FreightParcelSaturday10');
                end;
            'epost global':
                begin
                    ReturnList.Add('CourierServiceDDP');
                    ReturnList.Add('CourierServiceDDU');
                    ReturnList.Add('DomesticEconomyParcel');
                    ReturnList.Add('DomesticParcelBPM');
                    ReturnList.Add('DomesticPriorityParcel');
                    ReturnList.Add('DomesticPriorityParcelBPM');
                    ReturnList.Add('EMIService');
                    ReturnList.Add('EconomyParcelService');
                    ReturnList.Add('IPAService');
                    ReturnList.Add('ISALService');
                    ReturnList.Add('PMIService');
                    ReturnList.Add('PriorityParcelDDP');
                    ReturnList.Add('PriorityParcelDDU');
                    ReturnList.Add('PriorityParcelDeliveryConfirmationDDP');
                    ReturnList.Add('PriorityParcelDeliveryConfirmationDDU');
                    ReturnList.Add('ePacketService');
                end;
            'estafeta':
                begin
                    ReturnList.Add('NextDayBy930');
                    ReturnList.Add('NextDayBy1130');
                    ReturnList.Add('NextDay');
                    ReturnList.Add('Ground');
                    ReturnList.Add('TwoDay');
                    ReturnList.Add('LTL');
                end;
            'evri':
                begin
                    ReturnList.Add('Courier2Home');
                    ReturnList.Add('Courier2HomeNextDay');
                    ReturnList.Add('Shop2Home');
                    ReturnList.Add('Shop2HomeNextDay');
                    ReturnList.Add('Shop2Shop');
                    ReturnList.Add('Shop2ShopNextDay');
                end;
            'fastway':
                begin
                    ReturnList.Add('Parcel');
                    ReturnList.Add('Satchel');
                end;
            'fedex':
                begin
                    ReturnList.Add('FEDEX_GROUND');
                    ReturnList.Add('FEDEX_2_DAY');
                    ReturnList.Add('FEDEX_2_DAY_AM');
                    ReturnList.Add('FEDEX_EXPRESS_SAVER');
                    ReturnList.Add('STANDARD_OVERNIGHT');
                    ReturnList.Add('FIRST_OVERNIGHT');
                    ReturnList.Add('PRIORITY_OVERNIGHT');
                    ReturnList.Add('INTERNATIONAL_ECONOMY');
                    ReturnList.Add('INTERNATIONAL_FIRST');
                    ReturnList.Add('INTERNATIONAL_PRIORITY');
                    ReturnList.Add('FEDEX_INTERNATIONAL_CONNECT_PLUS');
                    ReturnList.Add('GROUND_HOME_DELIVERY');
                    ReturnList.Add('FEDEX_NEXT_DAY_EARLY_MORNING');
                    ReturnList.Add('FEDEX_NEXT_DAY_MID_MORNING');
                    ReturnList.Add('FEDEX_NEXT_DAY_AFTERNOON');
                    ReturnList.Add('FEDEX_NEXT_DAY_END_OF_DAY');
                    ReturnList.Add('FEDEX_DISTANCE_DEFERRED');
                    ReturnList.Add('FEDEX_NEXT_DAY_FREIGHT');
                    ReturnList.Add('EUROPE_FIRST_INTERNATIONAL_PRIORITY');
                    ReturnList.Add('FEDEX_FIRST_FREIGHT');
                    ReturnList.Add('FEDEX_1_DAY_FREIGHT');
                    ReturnList.Add('FEDEX_2_DAY_FREIGHT');
                    ReturnList.Add('FEDEX_3_DAY_FREIGHT');
                end;
            'fedex cross border':
                begin
                    ReturnList.Add('CBEC');
                    ReturnList.Add('CBECL');
                    ReturnList.Add('CBECP');
                end;
            'fedex mailview':
                ;
            'fedex smartpost':
                ReturnList.Add('SMART_POST');
            'firstmile':
                begin
                    ReturnList.Add('XParcelGround');
                    ReturnList.Add('XParcelExpedited');
                    ReturnList.Add('XParcelExpeditedPlus');
                    ReturnList.Add('XParcelPriority');
                    ReturnList.Add('XParcelReturns');
                end;
            'gso':
                begin
                    ReturnList.Add('EarlyPriorityOvernight');
                    ReturnList.Add('PriorityOvernight');
                    ReturnList.Add('CaliforniaParcelService');
                    ReturnList.Add('SaturdayDeliveryService');
                    ReturnList.Add('EarlySaturdayService');
                    ReturnList.Add('Ground');
                    ReturnList.Add('Overnight');
                end;
            'hailify':
                ReturnList.Add('Xpress');
            'interlink express':
                begin
                    ReturnList.Add('InterlinkAirClassicInternationalAir');
                    ReturnList.Add('InterlinkAirExpressInternationalAir');
                    ReturnList.Add('InterlinkExpresspak1By10:30');
                    ReturnList.Add('InterlinkExpresspak1By12');
                    ReturnList.Add('InterlinkExpresspak1NextDay');
                    ReturnList.Add('InterlinkExpresspak1Saturday');
                    ReturnList.Add('InterlinkExpresspak1SaturdayBy10:30');
                    ReturnList.Add('InterlinkExpresspak1SaturdayBy12');
                    ReturnList.Add('InterlinkExpresspak1Sunday');
                    ReturnList.Add('InterlinkExpresspak1SundayBy12');
                    ReturnList.Add('InterlinkExpresspak5By10');
                    ReturnList.Add('InterlinkExpresspak5By10:30');
                    ReturnList.Add('InterlinkExpresspak5By12');
                    ReturnList.Add('InterlinkExpresspak5NextDay');
                    ReturnList.Add('InterlinkExpresspak5Saturday');
                    ReturnList.Add('InterlinkExpresspak5SaturdayBy10');
                    ReturnList.Add('InterlinkExpresspak5SaturdayBy10:30');
                    ReturnList.Add('InterlinkExpresspak5SaturdayBy12');
                    ReturnList.Add('InterlinkExpresspak5Sunday');
                    ReturnList.Add('InterlinkExpresspak5SundayBy12');
                    ReturnList.Add('InterlinkFreightBy10');
                    ReturnList.Add('InterlinkFreightBy12');
                    ReturnList.Add('InterlinkFreightNextDay');
                    ReturnList.Add('InterlinkFreightSaturday');
                    ReturnList.Add('InterlinkFreightSaturdayBy10');
                    ReturnList.Add('InterlinkFreightSaturdayBy12');
                    ReturnList.Add('InterlinkFreightSunday');
                    ReturnList.Add('InterlinkFreightSundayBy12');
                    ReturnList.Add('InterlinkParcelBy10');
                    ReturnList.Add('InterlinkParcelBy10:30');
                    ReturnList.Add('InterlinkParcelBy12');
                    ReturnList.Add('InterlinkParcelDpdEuropeByRoad');
                    ReturnList.Add('InterlinkParcelNextDay');
                    ReturnList.Add('InterlinkParcelReturn');
                    ReturnList.Add('InterlinkParcelReturnToShop');
                    ReturnList.Add('InterlinkParcelSaturday');
                    ReturnList.Add('InterlinkParcelSaturdayBy10');
                    ReturnList.Add('InterlinkParcelSaturdayBy10:30');
                    ReturnList.Add('InterlinkParcelSaturdayBy12');
                    ReturnList.Add('InterlinkParcelShipToShop');
                    ReturnList.Add('InterlinkParcelSunday');
                    ReturnList.Add('InterlinkParcelSundayBy12');
                    ReturnList.Add('InterlinkParcelTwoDay');
                    ReturnList.Add('InterlinkPickupParcelDpdEuropeByRoad');
                end;
            'jp post':
                ;
            'kuroneko yamato':
                ;
            'la poste':
                ;
            'lasership':
                begin
                    ReturnList.Add('SameDay');
                    ReturnList.Add('NextDay');
                    ReturnList.Add('Weekend');
                end;
            'loomis express':
                begin
                    ReturnList.Add('LoomisGround');
                    ReturnList.Add('LoomisExpress1800');
                    ReturnList.Add('LoomisExpress1200');
                    ReturnList.Add('LoomisExpress900');
                end;
            'maergo':
                ReturnList.Add('Standard');
            'newgistics':
                begin
                    ReturnList.Add('ParcelSelect');
                    ReturnList.Add('ParcelSelectLightweight');
                    ReturnList.Add('Ground');
                    ReturnList.Add('Express');
                    ReturnList.Add('FirstClassMail');
                    ReturnList.Add('PriorityMail');
                    ReturnList.Add('BoundPrintedMatter');
                end;
            'ontrac':
                begin
                    ReturnList.Add('Sunrise');
                    ReturnList.Add('Gold');
                    ReturnList.Add('OnTracGround');
                    ReturnList.Add('SameDay');
                    ReturnList.Add('PalletizedFreight');
                end;
            'optima':
                ReturnList.Add('NxtDay');
            'osm worldwide':
                begin
                    ReturnList.Add('First');
                    ReturnList.Add('Expedited');
                    ReturnList.Add('ParcelSelectLightweight');
                    ReturnList.Add('Priority');
                    ReturnList.Add('BPM');
                    ReturnList.Add('ParcelSelect');
                    ReturnList.Add('MediaMail');
                    ReturnList.Add('MarketingParcel');
                    ReturnList.Add('MarketingParcelTracked');
                end;
            'parcelforce':
                begin
                    ReturnList.Add('Express9');
                    ReturnList.Add('Express9Secure');
                    ReturnList.Add('Express9CourierPack');
                    ReturnList.Add('Express10');
                    ReturnList.Add('Express10Secure');
                    ReturnList.Add('Express10Exchange');
                    ReturnList.Add('Express10SecureExchange');
                    ReturnList.Add('Express10CourierPack');
                    ReturnList.Add('ExpressAM');
                    ReturnList.Add('ExpressAMSecure');
                    ReturnList.Add('ExpressAMExchange');
                    ReturnList.Add('ExpressAMSecureExchange');
                    ReturnList.Add('ExpressAMCourierPack');
                    ReturnList.Add('ExpressPM');
                    ReturnList.Add('ExpressPMSecure');
                    ReturnList.Add('Express24');
                    ReturnList.Add('Express24Large');
                    ReturnList.Add('Express24Secure');
                    ReturnList.Add('Express24Exchange');
                    ReturnList.Add('Express24SecureExchange');
                    ReturnList.Add('Express24CourierPack');
                    ReturnList.Add('Express48');
                    ReturnList.Add('Express48Large');
                    ReturnList.Add('ParcelRiderPlus');
                    ReturnList.Add('GlobalBulkDirect');
                    ReturnList.Add('GlobalExpress');
                    ReturnList.Add('GlobalExpressEnvelopeDelivery');
                    ReturnList.Add('GlobalExpressPackDelivery');
                    ReturnList.Add('GlobalValue');
                    ReturnList.Add('GlobalPriority');
                    ReturnList.Add('GlobalPriorityReturns');
                    ReturnList.Add('EuroPriorityHome');
                    ReturnList.Add('EuroPriorityBusiness');
                    ReturnList.Add('IrelandExpress');
                end;
            'parcll':
                begin
                    ReturnList.Add('ECOWE (Economy West)');
                    ReturnList.Add('ECOCE (Economy Central)');
                    ReturnList.Add('ECONE (Economy Northeast)');
                    ReturnList.Add('ECOEA (Economy East)');
                    ReturnList.Add('ECOSO (Economy South)');
                    ReturnList.Add('EXPWE (Expedited West)');
                    ReturnList.Add('EXPBNE (Expedited Northeast)');
                    ReturnList.Add('REGWE (Regional West)');
                    ReturnList.Add('REGCE (Regional Central)');
                    ReturnList.Add('REGNE (Regional Northeast)');
                    ReturnList.Add('REGEA (Regional East)');
                    ReturnList.Add('REGSO (Regional South)');
                    ReturnList.Add('CAECOWE (US to CA Economy)');
                    ReturnList.Add('CAECOCE (US to CA Economy)');
                    ReturnList.Add('CAECONE (US to CA Economy)');
                    ReturnList.Add('EUECOWE (US to Europe Economy)');
                end;
            'passport':
                ;
            'postnl':
                ;
            'purolator':
                begin
                    ReturnList.Add('PurolatorExpress');
                    ReturnList.Add('PurolatorExpress12PM');
                    ReturnList.Add('PurolatorExpressPack12PM');
                    ReturnList.Add('PurolatorExpressBox12PM');
                    ReturnList.Add('PurolatorExpressEnvelope12PM');
                    ReturnList.Add('PurolatorExpress1030AM');
                    ReturnList.Add('PurolatorExpress9AM');
                    ReturnList.Add('PurolatorExpressBox');
                    ReturnList.Add('PurolatorExpressBox1030AM');
                    ReturnList.Add('PurolatorExpressBox9AM');
                    ReturnList.Add('PurolatorExpressBoxEvening');
                    ReturnList.Add('PurolatorExpressBoxInternational');
                    ReturnList.Add('PurolatorExpressBoxInternational1030AM');
                    ReturnList.Add('PurolatorExpressBoxInternational1200');
                    ReturnList.Add('PurolatorExpressBoxInternational9AM');
                    ReturnList.Add('PurolatorExpressBoxUS');
                    ReturnList.Add('PurolatorExpressBoxUS1030AM');
                    ReturnList.Add('PurolatorExpressBoxUS1200');
                    ReturnList.Add('PurolatorExpressBoxUS9AM');
                    ReturnList.Add('PurolatorExpressEnvelope');
                    ReturnList.Add('PurolatorExpressEnvelope1030AM');
                    ReturnList.Add('PurolatorExpressEnvelope9AM');
                    ReturnList.Add('PurolatorExpressEnvelopeEvening');
                    ReturnList.Add('PurolatorExpressEnvelopeInternational');
                    ReturnList.Add('PurolatorExpressEnvelopeInternational1030AM');
                    ReturnList.Add('PurolatorExpressEnvelopeInternational1200');
                    ReturnList.Add('PurolatorExpressEnvelopeInternational9AM');
                    ReturnList.Add('PurolatorExpressEnvelopeUS');
                    ReturnList.Add('PurolatorExpressEnvelopeUS1030AM');
                    ReturnList.Add('PurolatorExpressEnvelopeUS1200');
                    ReturnList.Add('PurolatorExpressEnvelopeUS9AM');
                    ReturnList.Add('PurolatorExpressEvening');
                    ReturnList.Add('PurolatorExpressInternational');
                    ReturnList.Add('PurolatorExpressInternational1030AM');
                    ReturnList.Add('PurolatorExpressInternational1200');
                    ReturnList.Add('PurolatorExpressInternational9AM');
                    ReturnList.Add('PurolatorExpressPack');
                    ReturnList.Add('PurolatorExpressPack1030AM');
                    ReturnList.Add('PurolatorExpressPack9AM');
                    ReturnList.Add('PurolatorExpressPackEvening');
                    ReturnList.Add('PurolatorExpressPackInternational');
                    ReturnList.Add('PurolatorExpressPackInternational1030AM');
                    ReturnList.Add('PurolatorExpressPackInternational1200');
                    ReturnList.Add('PurolatorExpressPackInternational9AM');
                    ReturnList.Add('PurolatorExpressPackUS');
                    ReturnList.Add('PurolatorExpressPackUS1030AM');
                    ReturnList.Add('PurolatorExpressPackUS1200');
                    ReturnList.Add('PurolatorExpressPackUS9AM');
                    ReturnList.Add('PurolatorExpressUS');
                    ReturnList.Add('PurolatorExpressUS1030AM');
                    ReturnList.Add('PurolatorExpressUS1200');
                    ReturnList.Add('PurolatorExpressUS9AM');
                    ReturnList.Add('PurolatorGround');
                    ReturnList.Add('PurolatorGround1030AM');
                    ReturnList.Add('PurolatorGround9AM');
                    ReturnList.Add('PurolatorGroundDistribution');
                    ReturnList.Add('PurolatorGroundEvening');
                    ReturnList.Add('PurolatorGroundRegional');
                    ReturnList.Add('PurolatorGroundUS');
                end;
            'royal mail':
                begin
                    ReturnList.Add('InternationalSigned');
                    ReturnList.Add('InternationalStandard');
                    ReturnList.Add('InternationalTracked');
                    ReturnList.Add('InternationalTrackedAndSigned');
                    ReturnList.Add('1stClass');
                    ReturnList.Add('1stClassSignedFor');
                    ReturnList.Add('2ndClass');
                    ReturnList.Add('2ndClassSignedFor');
                    ReturnList.Add('RoyalMail24');
                    ReturnList.Add('RoyalMail24SignedFor');
                    ReturnList.Add('RoyalMail48');
                    ReturnList.Add('RoyalMail48SignedFor');
                    ReturnList.Add('SpecialDeliveryGuaranteed1pm');
                    ReturnList.Add('SpecialDeliveryGuaranteed9am');
                    ReturnList.Add('StandardLetter1stClass');
                    ReturnList.Add('StandardLetter1stClassSignedFor');
                    ReturnList.Add('StandardLetter2ndClass');
                    ReturnList.Add('StandardLetter2ndClassSignedFor');
                    ReturnList.Add('Tracked24');
                    ReturnList.Add('Tracked24HighVolume');
                    ReturnList.Add('Tracked24HighVolumeSignature');
                    ReturnList.Add('Tracked24Signature');
                    ReturnList.Add('Tracked48');
                    ReturnList.Add('Tracked48HighVolume');
                    ReturnList.Add('Tracked48HighVolumeSignature');
                    ReturnList.Add('Tracked48Signature');
                end;
            'seko omniparcel':
                begin
                    ReturnList.Add('Ecommerce Standard Tracked');
                    ReturnList.Add('Ecommerce Express Tracked');
                    ReturnList.Add('Domestic Express');
                    ReturnList.Add('Domestic Standard');
                end;
            'sendle':
                begin
                    ReturnList.Add('Standard');
                    ReturnList.Add('Express');
                end;
            'sf express':
                begin
                    ReturnList.Add('International Standard Express - Doc');
                    ReturnList.Add('International Standard Express - Parcel');
                    ReturnList.Add('International Economy Express - Pilot');
                    ReturnList.Add('International Economy Express - Doc');
                end;
            'smartkargo':
                ReturnList.Add('EPR');
            'sonic':
                begin
                    ReturnList.Add('NEXTDAY');
                    ReturnList.Add('SAMEDAY');
                end;
            'spee-dee':
                ReturnList.Add('SpeeDeeDelivery');
            'swyft':
                begin
                    ReturnList.Add('NEXTDAY');
                    ReturnList.Add('SAMEDAY');
                end;
            'tforce logistics':
                begin
                    ReturnList.Add('NextDay');
                    ReturnList.Add('Return');
                end;
            'toll':
                begin
                    ReturnList.Add('IPEC Direct');
                    ReturnList.Add('IPEC Fashion');
                    ReturnList.Add('IPEC Local');
                    ReturnList.Add('IPEC Priority');
                    ReturnList.Add('IPEC Road Express');
                    ReturnList.Add('IPEC Sensitive');
                    ReturnList.Add('IPEC VicEXP');
                end;
            'uds':
                ReturnList.Add('DeliveryService');
            'ups i-parcel':
                ;
            'ups mail innovations':
                begin
                    ReturnList.Add('First');
                    ReturnList.Add('Priority');
                    ReturnList.Add('ExpeditedMailInnovations');
                    ReturnList.Add('PriorityMailInnovations');
                    ReturnList.Add('EconomyMailInnovations');
                end;

            'veho':
                begin
                    ReturnList.Add('nextDay');
                    ReturnList.Add('sameDay');
                end;
            'yanwen':
                ;
        end;
    end;

    local procedure GetPackages(CarrierType: Text; var ReturnList: List of [Text])
    begin
        // API Documentation: https://www.easypost.com/docs/api#predefined-packages
        // Last updated - 2023-02-21

        #region [CodeToGetPredefinedPackagesFromThePortal]
        // // Get all the HTML elements containing the carrier and service data
        // var packageDataElements = document.querySelectorAll('[class^="tab-pane predefined-"]');

        // // Create an object to hold the carrier and service information
        // var packageData = {};

        // // Loop through each carrier tab in the HTML
        // for (var i = 0; i < packageDataElements.length; i++) {

        //   // Get the carrier name from the class of the carrier tab
        //   var carrierName = packageDataElements[i].querySelector('img').getAttribute('alt').toLowerCase();

        //   // Get an array of service names from the list items in the carrier tab
        //   var serviceNames = [];
        //   var serviceElements = packageDataElements[i].querySelectorAll('li');
        //   for (var j = 0; j < serviceElements.length; j++) {
        // 	serviceNames.push("ReturnList.Add('" + serviceElements[j].textContent + "');");
        //   }

        //   // Construct the string for the carrier and service information
        //   var packageDataString = "begin " + serviceNames.join(' ') + " end;";

        //   // Add the carrier and service information to the object
        //   packageData[carrierName] = packageDataString;

        // }

        // // Print the carrier and service information to the console
        // console.log(packageData);
        #endregion

        case LowerCase(CarrierType) of
            'amazonmws':
                ;
            'apc':
                ;
            'asendia usa':
                ;
            'australia post':
                ;
            'axlehirev3':
                ;
            'better trucks':
                ;
            'canada post':
                ;
            'canpar':
                ;
            'cdl last mile solutions':
                ;
            'chronopost':
                ;
            'cloudsort':
                ;
            'courier express':
                ;
            'couriersplease':
                ;
            'dai post':
                ;
            'deliverit':
                ;
            'deutsche post':
                ;
            'deutsche post uk':
                ;
            'dhl ecommerce asia':
                ;
            'dhl ecommerce solutions':
                ;
            'dhl express':
                begin
                    ReturnList.Add('JumboDocument');
                    ReturnList.Add('JumboParcel');
                    ReturnList.Add('Document');
                    ReturnList.Add('DHLFlyer');
                    ReturnList.Add('Domestic');
                    ReturnList.Add('ExpressDocument');
                    ReturnList.Add('DHLExpressEnvelope');
                    ReturnList.Add('JumboBox');
                    ReturnList.Add('JumboJuniorDocument');
                    ReturnList.Add('JuniorJumboBox');
                    ReturnList.Add('JumboJuniorParcel');
                    ReturnList.Add('OtherDHLPackaging');
                    ReturnList.Add('Parcel');
                    ReturnList.Add('YourPackaging');
                end;
            'dhl paket':
                ;
            'dhl smartmail':
                ;
            'dpd':
                ;
            'dpd uk':
                begin
                    ReturnList.Add('Parcel');
                    ReturnList.Add('Pallet');
                    ReturnList.Add('ExpressPak');
                    ReturnList.Add('FreightParcel');
                    ReturnList.Add('Freight');
                end;
            'epost global':
                ;
            'estafeta':
                begin
                    ReturnList.Add('ENVELOPE');
                    ReturnList.Add('PARCEL');
                end;
            'evri':
                ;
            'fastway':
                begin
                    ReturnList.Add('Parcel');
                    ReturnList.Add('A2 (Satchel)');
                    ReturnList.Add('A3 (Satchel)');
                    ReturnList.Add('A4 (Satchel, not available in Australia)');
                    ReturnList.Add('A5 (Satchel, not available in South Africa)');
                    ReturnList.Add('BOXSML');
                    ReturnList.Add('BOXMED');
                    ReturnList.Add('BOXLRG');
                end;
            'fedex':
                begin
                    ReturnList.Add('FedExEnvelope');
                    ReturnList.Add('FedExBox');
                    ReturnList.Add('FedExPak');
                    ReturnList.Add('FedExTube');
                    ReturnList.Add('FedEx10kgBox');
                    ReturnList.Add('FedEx25kgBox');
                    ReturnList.Add('FedExSmallBox');
                    ReturnList.Add('FedExMediumBox');
                    ReturnList.Add('FedExLargeBox');
                    ReturnList.Add('FedExExtraLargeBox');
                end;
            'fedex cross border':
                ;
            'fedex mailview':
                ;
            'fedex smartpost':
                ;
            'firstmile':
                ;
            'gso':
                ;
            'hailify':
                ;
            'interlink express':
                begin
                    ReturnList.Add('Parcel');
                    ReturnList.Add('Pallet');
                    ReturnList.Add('ExpressPak');
                    ReturnList.Add('FreightParcel');
                    ReturnList.Add('Freight');
                end;
            'jp post':
                ;
            'kuroneko yamato':
                ;
            'la poste':
                ;
            'lasership':
                begin
                    ReturnList.Add('Envelope');
                    ReturnList.Add('Custom');
                end;
            'loomis express':
                ;
            'lso':
                ;
            'maergo':
                ;
            'newgistics':
                ;
            'ontrac':
                ReturnList.Add('Letter');
            'optima':
                ;
            'osm worldwide':
                ;
            'parcelforce':
                ;
            'parcll':
                ;
            'passport':
                ;
            'postnl':
                ;
            'purolator':
                begin
                    ReturnList.Add('CustomerPackaging');
                    ReturnList.Add('ExpressPack');
                    ReturnList.Add('ExpressBox');
                    ReturnList.Add('ExpressEnvelope');
                end;
            'royal mail':
                begin
                    ReturnList.Add('Letter');
                    ReturnList.Add('LargeLetter');
                    ReturnList.Add('SmallParcel');
                    ReturnList.Add('MediumParcel');
                    ReturnList.Add('Parcel (for use with RoyalMail24 or RoyalMail48)');
                end;
            'seko omniparcel':
                begin
                    ReturnList.Add('Bag');
                    ReturnList.Add('Box');
                    ReturnList.Add('Carton');
                    ReturnList.Add('Container');
                    ReturnList.Add('Crate');
                    ReturnList.Add('Envelope');
                    ReturnList.Add('Pail');
                    ReturnList.Add('Pallet');
                    ReturnList.Add('Satchel');
                    ReturnList.Add('Tub');
                end;
            'sendle':
                ;
            'sf express':
                ;
            'smartkargo':
                ;
            'sonic':
                ;
            'spee-dee':
                ;
            'swyft':
                ;
            'tforce logistics':
                ;
            'toll':
                ;
            'uds':
                ;
            'upsdap':
                begin
                    ReturnList.Add('UPSLetter');
                    ReturnList.Add('UPSExpressBox');
                    ReturnList.Add('UPS25kgBox');
                    ReturnList.Add('UPS10kgBox');
                    ReturnList.Add('Tube');
                    ReturnList.Add('Pak');
                    ReturnList.Add('SmallExpressBox');
                    ReturnList.Add('MediumExpressBox');
                    ReturnList.Add('LargeExpressBox');
                end;
            'ups i-parcel':
                ;
            'ups mail innovations':
                ;
            'usps':
                begin
                    ReturnList.Add('Card');
                    ReturnList.Add('Letter');
                    ReturnList.Add('Flat');
                    ReturnList.Add('FlatRateEnvelope');
                    ReturnList.Add('FlatRateLegalEnvelope');
                    ReturnList.Add('FlatRatePaddedEnvelope');
                    ReturnList.Add('FlatRateGiftCardEnvelope');
                    ReturnList.Add('FlatRateWindowEnvelope');
                    ReturnList.Add('FlatRateCardboardEnvelope');
                    ReturnList.Add('SmallFlatRateEnvelope');
                    ReturnList.Add('Parcel');
                    ReturnList.Add('SoftPack');
                    ReturnList.Add('SmallFlatRateBox');
                    ReturnList.Add('MediumFlatRateBox');
                    ReturnList.Add('LargeFlatRateBox');
                    ReturnList.Add('LargeFlatRateBoxAPOFPO');
                    ReturnList.Add('FlatTubTrayBox');
                    ReturnList.Add('EMMTrayBox');
                    ReturnList.Add('FullTrayBox');
                    ReturnList.Add('HalfTrayBox');
                    ReturnList.Add('PMODSack');
                end;
            'veho':
                ;
            'yanwen':
                ;
        end;
    end;

    local procedure ProcessIncoterms()
    var
        IDYSIncoterm: Record "IDYS Incoterm";
        Incoterm: Text;
        Incoterms: List of [Text];
    begin
        // The same incoterm table without provider level is used in Transsmart and EasyPost
        GetIncoterms(Incoterms);
        foreach Incoterm in Incoterms do
            if not IDYSIncoterm.Get(CopyStr(Incoterm, 1, MaxStrLen(IDYSIncoterm."Code"))) then begin
                IDYSIncoterm."Code" := CopyStr(Incoterm, 1, MaxStrLen(IDYSIncoterm."Code"));
                IDYSIncoterm.Insert(true);
            end;
    end;

    local procedure GetIncoterms(var ReturnList: List of [Text])
    begin
        // incoterm	
        //      string	
        // Incoterm negotiated for shipment. Supported values are "EXW", "FCA", "CPT", "CIP", "DAT", "DAP", "DDP", "FAS", "FOB", "CFR", and "CIF".
        // Setting this value to anything other than "DDP" will pass the cost and responsibility of duties on to the recipient of the package(s),
        // as specified by Incoterms rules
        ReturnList.Add('EXW');
        ReturnList.Add('FCA');
        ReturnList.Add('CPT');
        ReturnList.Add('CIP');
        ReturnList.Add('DAT');
        ReturnList.Add('DAP');
        ReturnList.Add('DDP');
        ReturnList.Add('FAS');
        ReturnList.Add('FOB');
        ReturnList.Add('CFR');
        ReturnList.Add('CIF');
    end;

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSEasyPostSetup: Record "IDYS Setup";
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        IDYMHttpHelper: Codeunit "IDYM Http Helper";
        IDYSEasyPostErrorHandler: Codeunit "IDYS EasyPost Error Handler";
        CurrentProviderCarrierList: List of [Guid];
        CurrentProviderBookingProfileList: List of [Guid];
        CurrentBookingProfPackageTypeList: List of [Guid];
        SetupLoaded: Boolean;
        ProviderSetupLoaded: Boolean;
        ProgressWindowDialog: Dialog;
}