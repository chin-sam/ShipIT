codeunit 11147705 "IDYS Cargoson M. Data Mgt."
{
    procedure UpdateMasterData(ShowNotifications: Boolean) Completed: Boolean
    var
        IDYSCreateMappings: Codeunit "IDYS Create Mappings";
        MasterDataUpdatedMsg: Label 'The Cargoson master data has been successfully updated.';
        MasterDataUpdatedTok: Label 'd162c2cb-1ada-4662-8f84-178eab81af39', Locked = true;
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
        Response: JsonObject;
        Services: JsonArray;
        Service: JsonToken;
        EndpointTxt: Label 'services/list', Locked = true;
        SyncingMsg: Label 'Syncing %1 of %2 services.', Comment = '%1 = is current record, %2 = total records';
        RequestingDataMsg: Label 'Retrieving data from the Cargoson API...';
        i: Integer;
        x: Integer;
    begin
        if GuiAllowed() then begin
            ProgressWindowDialog.Open('#1#######');
            ProgressWindowDialog.Update(1, RequestingDataMsg);
        end;

        GetSetup();
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters."Acceptance Environment" := IDYSCargosonSetup."Transsmart Environment" = IDYSCargosonSetup."Transsmart Environment"::Acceptance;
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt);

        Statuscode := IDYMHttpHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Cargoson, "IDYM Endpoint Usage"::Default);
        if not (Statuscode In [200, 201]) then begin
            IDYSCargosonErrorHandler.Parse(TempIDYMRESTParameters, GuiAllowed());
            Error('');
        end;

        GetCurrentMasterData();
        Response := TempIDYMRESTParameters.GetResponseBodyAsJSONObject();
        if Response.Contains('services') then begin
            Services := IDYMJSONHelper.GetArray(Response, 'services');
            x := Services.Count();
            foreach Service in Services do begin
                if GuiAllowed() then begin
                    i += 1;
                    ProgressWindowDialog.Update(1, StrSubstNo(SyncingMsg, i, x));
                end;
                ProcessService(Service);
            end;
            ProcessPackages();
            ProcessIncoterms();
            CleanMasterData();

            if GuiAllowed() then
                ProgressWindowDialog.Close();

            exit(true);
        end;
    end;

    local procedure ProcessPackages()
    var
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        Packages: List of [Text];
        Package: Text;
    begin
        GetPackages(Packages);
        foreach Package in Packages do begin
            Clear(IDYSProviderPackageType);
            if not IDYSProviderPackageType.Get(IDYSProviderPackageType.Provider::Cargoson, CopyStr(Package, 1, MaxStrLen(IDYSProviderPackageType.Code))) then begin
                IDYSProviderPackageType.Provider := IDYSProviderPackageType.Provider::Cargoson;
                IDYSProviderPackageType."Code" := CopyStr(Package, 1, MaxStrLen(IDYSProviderPackageType.Code));
                IDYSProviderPackageType.Description := CopyStr(IDYSProviderPackageType."Code", 1, MaxStrLen(IDYSProviderPackageType.Description));
                IDYSProviderPackageType.Insert(true);
            end;
        end;
    end;

    local procedure ProcessService(Service: JsonToken)
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        Index: Integer;
    begin
        // Carriers
        Clear(IDYSProviderBookingProfile);
        IDYSProviderCarrier.SetRange(Provider, IDYSProviderCarrier.Provider::Cargoson);
        IDYSProviderCarrier.SetRange(CarrierId, IDYMJSONHelper.GetIntegerValue(Service, 'carrier_id'));
        if not IDYSProviderCarrier.FindFirst() then begin
            IDYSProviderCarrier.Init();
            IDYSProviderCarrier.Validate(Provider, IDYSProviderCarrier.Provider::Cargoson);
            IDYSProviderCarrier.Validate(CarrierId, IDYMJSONHelper.GetIntegerValue(Service, 'carrier_id'));
            IDYSProviderCarrier.Insert(true);
        end else
            CurrentProviderCarrierList.Remove(IDYSProviderCarrier.SystemId);

        IDYSProviderCarrier.Name := CopyStr(IDYMJSONHelper.GetTextValue(Service, 'carrier_name'), 1, MaxStrLen(IDYSProviderCarrier.Name));
        IDYSProviderCarrier.Modify(true);

        // Booking Profiles
        IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
        IDYSProviderBookingProfile.SetRange(ServiceId, IDYMJSONHelper.GetIntegerValue(Service, 'service_id'));
        if not IDYSProviderBookingProfile.FindLast() then begin
            IDYSProviderBookingProfile."Carrier Entry No." := IDYSProviderCarrier."Entry No.";
            IDYSProviderBookingProfile.ServiceId := IDYMJSONHelper.GetIntegerValue(Service, 'service_id');
            IDYSProviderBookingProfile.Insert(true);
        end else
            CurrentProviderBookingProfileList.Remove(IDYSProviderBookingProfile.SystemId);

        IDYSProviderBookingProfile.Description := CopyStr(IDYMJSONHelper.GetTextValue(Service, 'service_name'), 1, MaxStrLen(IDYSProviderBookingProfile.Description));

        Index := "IDYS Cargoson Service Type".Names().IndexOf(IDYMJSONHelper.GetTextValue(Service, 'service_type'));
        IDYSProviderBookingProfile.ServiceType := "IDYS Cargoson Service Type".FromInteger("IDYS Cargoson Service Type".Ordinals().Get(Index));
        IDYSProviderBookingProfile.Modify(true);
    end;

    local procedure CleanMasterData()
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        ProviderCarrierId: Guid;
        ProviderBookingProfileId: Guid;
    begin
        foreach ProviderCarrierId in CurrentProviderCarrierList do
            if IDYSProviderCarrier.GetBySystemId(ProviderCarrierId) then
                IDYSProviderCarrier.Delete();

        foreach ProviderBookingProfileId in CurrentProviderBookingProfileList do
            if IDYSProviderBookingProfile.GetBySystemId(ProviderBookingProfileId) then
                IDYSProviderBookingProfile.Delete(true);
    end;

    local procedure GetCurrentMasterData()
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
    begin
        IDYSProviderCarrier.SetRange(Provider, IDYSProviderCarrier.Provider::Cargoson);
        if IDYSProviderCarrier.FindSet() then
            repeat
                CurrentProviderCarrierList.Add(IDYSProviderCarrier.SystemId);

                IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
                if IDYSProviderBookingProfile.FindSet() then
                    repeat
                        CurrentProviderBookingProfileList.Add(IDYSProviderBookingProfile.SystemId);
                    until IDYSProviderBookingProfile.Next() = 0;
            until IDYSProviderCarrier.Next() = 0;
    end;

    local procedure GetSetup(): Boolean
    begin
        if not SetupLoaded then
            SetupLoaded := IDYSSetup.Get();

        if not ProviderSetupLoaded then begin
            IDYSCargosonSetup.GetProviderSetup("IDYS Provider"::Cargoson);
            ProviderSetupLoaded := true;
        end;

        exit(SetupLoaded);
    end;

    local procedure ProcessIncoterms()
    var
        IDYSIncoterm: Record "IDYS Incoterm";
        Incoterm: Text;
        Incoterms: List of [Text];
    begin
        GetIncoterms(Incoterms);
        foreach Incoterm in Incoterms do
            if not IDYSIncoterm.Get(CopyStr(Incoterm, 1, MaxStrLen(IDYSIncoterm."Code"))) then begin
                IDYSIncoterm."Code" := CopyStr(Incoterm, 1, MaxStrLen(IDYSIncoterm."Code"));
                IDYSIncoterm.Insert(true);
            end;
    end;

    local procedure GetIncoterms(var ReturnList: List of [Text])
    begin
        ReturnList.Add('EXW');
        ReturnList.Add('FCA');
        ReturnList.Add('CPT');
        ReturnList.Add('CIP');
        ReturnList.Add('DAT');
        ReturnList.Add('DPU');
        ReturnList.Add('DAP');
        ReturnList.Add('DDP');
        ReturnList.Add('FAS');
        ReturnList.Add('FOB');
        ReturnList.Add('CFR');
        ReturnList.Add('CIF');
    end;

    local procedure GetPackages(var ReturnList: List of [Text])
    begin
        // EUR, CTN, FIN, HPL, QPL, LOAD, PLD, PXL, PLL, TBE, CLL, RLL, 20DC, 40DC, 40HC
        ReturnList.Add('EUR');
        ReturnList.Add('CTN');
        ReturnList.Add('FIN');
        ReturnList.Add('HPL');
        ReturnList.Add('QPL');
        ReturnList.Add('LOAD');
        ReturnList.Add('PLD');
        ReturnList.Add('PXL');
        ReturnList.Add('PLL');
        ReturnList.Add('TBE');
        ReturnList.Add('CLL');
        ReturnList.Add('RLL');
        ReturnList.Add('20DC');
        ReturnList.Add('40DC');
        ReturnList.Add('40HC');
    end;

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSCargosonSetup: Record "IDYS Setup";
        IDYMJSONHelper: Codeunit "IDYM Json Helper";
        IDYMHttpHelper: Codeunit "IDYM Http Helper";
        IDYSCargosonErrorHandler: Codeunit "IDYS Cargoson Error Handler";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        CurrentProviderCarrierList: List of [Guid];
        CurrentProviderBookingProfileList: List of [Guid];
        SetupLoaded: Boolean;
        ProviderSetupLoaded: Boolean;
        ProgressWindowDialog: Dialog;
}