codeunit 11147713 "IDYS DelHub M. Data Mgt."
{

    procedure UpdateMasterData(ShowNotifications: Boolean): Boolean
    var
        IDYSAdditionalActor: Record "IDYS Additional Actor";
        IDYSCreateMappings: Codeunit "IDYS Create Mappings";
        IDYSUpgradeTagDefinitions: Codeunit "IDYS Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
        MasterDataUpdatedTok: Label 'dcbbbf9f-0571-4a87-9d44-41ead055b470', Locked = true;
        MasterDataUpdatedMsg: Label 'The nShift Ship master data has been successfully updated.';
    begin
        //.../AvailableServices
        //  ...Get Carriers             -> GetCarriers
        //  ...Get Booking Profiles     -> GetBookingProfiles
        //  ...Get Service Levels Time  -> GetServiceLevelsTime
        //  ...Get Service Levels Other -> GetServiceLevelsOther
        //  ...Get Package Types        -> GetPackageTypes
        //  ...Get Inco Terms           -> GetIncoTerms

        //Use DH Actors
        //  ...Get Cost Centers -> GetCostCenters
        //Will be configurated on Actor level, so if another actor is being used, another e-mailtemplate can be used
        //  ...Get Inco Terms   -> GetIncoTerms

        DataUpgrade := not (UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.GetUpdatenShiftShipMasterDataTag()));

        GetSetup();
        IDYSCreateMappings.MapUnitOfMeasure();

        // Sync Main Actor     
        GetActorMasterData(IDYSDelHubSetup."Transsmart Account Code");

        // Sync Additional Actors
        if IDYSAdditionalActor.FindSet() then
            repeat
                GetActorMasterData(IDYSAdditionalActor."Actor Id");
            until IDYSAdditionalActor.Next() = 0;

        if (GuiAllowed()) and ShowNotifications then
            IDYSNotificationManagement.SendNotification(MasterDataUpdatedTok, MasterDataUpdatedMsg);

        if DataUpgrade then
            UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.GetUpdatenShiftShipMasterDataTag());

        exit(true);
    end;

    local procedure GetActorMasterData(ActorId: Text[30])
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYSDelHubErrorHandler: Codeunit "IDYS DelHub Error Handler";
        Statuscode: Integer;
        Carriers: JsonArray;
        Carrier: JsonToken;
        Response: JsonToken;
        i: Integer;
        x: Integer;
        EndpointTxt: Label '/ShipServer/%1/products?includeCountries=true', Locked = true;
        RequestingDataMsg: Label 'Retrieving data from the nShift Ship API (ActorId - %1)...', Comment = '%1 = ActorId';
        SyncingMsg: Label 'Syncing %1 of %2 carriers.', Comment = '%1 = is current record, %2 = total records';
    begin
        if GuiAllowed() then begin
            ProgressWindowDialog.Open('#1#######');
            ProgressWindowDialog.Update(1, StrSubstNo(RequestingDataMsg, ActorId));
        end;

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
        TempIDYMRESTParameters.Path := StrSubstNo(EndpointTxt, ActorId);
        TempIDYMRESTParameters."Acceptance Environment" := IDYSDelHubSetup."Transsmart Environment" = IDYSDelHubSetup."Transsmart Environment"::Acceptance;

        Statuscode := IDYMHttpHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::Default);
        if Statuscode <> 200 then begin
            IDYSDelHubErrorHandler.Parse(TempIDYMRESTParameters.GetResponseBodyAsJSON(), GuiAllowed());
            Error('');
        end;

        Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        // Store Main Actor Id as empty value
        if ActorId = IDYSDelHubSetup."Transsmart Account Code" then
            ActorId := '';

        GetCurrentMasterData(ActorId);
        Carriers := IDYMJSONHelper.GetArray(Response, 'Carriers');
        x := Carriers.Count();
        foreach Carrier in Carriers do begin
            if GuiAllowed() then begin
                i += 1;
                ProgressWindowDialog.Update(1, StrSubstNo(SyncingMsg, i, x));
            end;
            ProcessData(Carrier, ActorId);
        end;
        CleanMasterData();

        if GuiAllowed() then
            ProgressWindowDialog.Close();
    end;

    local procedure GetMappedCountryCode(CountryCode: Code[10]): Code[10];
    var
        IDYSCountryRegionMapping: Record "IDYS Country/Region Mapping";
    begin
        if IDYSCountryRegionMapping.Get(CountryCode) then
            exit(IDYSCountryRegionMapping."Country/Region Code");

        exit(CountryCode);
    end;


    local procedure ProcessData(Carrier: JsonToken; ActorId: Text[30])
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSDelHubAPIServices: Record "IDYS DelHub API Services";
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
        Product: JsonToken;
        Service: JsonToken;
        GoodsType: JsonToken;
        Subcarrier: JsonToken;
        Countries: Text;
        CountryList: List of [Text];
        Country: Text;
        ServiceCode: Code[50];
        ShipToCountriesList: List of [Text];
        ShipToCountry: Text;
        ShipToCountriesDeniedList: List of [Text];
        ShipToCountryDenied: Text;
    begin
        // Carriers
        IDYSProviderCarrier.SetRange(Provider, IDYSProviderCarrier.Provider::"Delivery Hub");
        IDYSProviderCarrier.SetRange(CarrierConceptID, IDYMJSONHelper.GetIntegerValue(Carrier, 'CarrierConceptID'));
        IDYSProviderCarrier.SetRange("Actor Id", ActorId);
        if not IDYSProviderCarrier.FindFirst() then begin
            IDYSProviderCarrier.Init();
            IDYSProviderCarrier.Validate(Provider, IDYSProviderCarrier.Provider::"Delivery Hub");
            IDYSProviderCarrier.Validate(CarrierConceptID, IDYMJSONHelper.GetIntegerValue(Carrier, 'CarrierConceptID'));
            IDYSProviderCarrier.Validate("Actor Id", ActorId);
            IDYSProviderCarrier.Insert(true);
        end else
            CurrentProviderCarrierList.Remove(IDYSProviderCarrier.SystemId);

        IDYSProviderCarrier.Name := CopyStr(IDYMJSONHelper.GetTextValue(Carrier, 'CarrierFullName'), 1, MaxStrLen(IDYSProviderCarrier.Name));
        IDYSProviderCarrier.Modify(true);

        Countries := IDYMJSONHelper.GetTextValue(Carrier, 'CountryCode');
        Subcarrier := Carrier;
        // Booking Profiles
        foreach Subcarrier in IDYMJSONHelper.GetArray(Carrier, 'Subcarriers') do
            // Booking Profiles
            foreach Product in IDYMJSONHelper.GetArray(Subcarrier, 'Products') do begin

                ShipToCountriesList := IDYMJSONHelper.GetTextValue(Product, 'Countries').Replace(' ', '').Split(',');
                ShipToCountriesDeniedList := IDYMJSONHelper.GetTextValue(Product, 'DenyCountries').Replace(' ', '').Split(',');

                if DataUpgrade then begin
                    IDYSProviderBookingProfile.Reset();
                    IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
                    IDYSProviderBookingProfile.SetRange(ProdConceptID, IDYMJSONHelper.GetIntegerValue(Product, 'ProdConceptID'));
                    if IDYSProviderBookingProfile.FindLast() then begin
                        IDYSProviderBookingProfile.ProdCSID := IDYMJSONHelper.GetIntegerValue(Product, 'ProdCSID');
                        IDYSProviderBookingProfile.Modify(true);
                        CurrentProviderBookingProfileList.Remove(IDYSProviderBookingProfile.SystemId);
                    end;
                end;

                Clear(IDYSProviderBookingProfile);
                IDYSProviderBookingProfile.Reset();
                IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
                IDYSProviderBookingProfile.SetRange(ProdCSID, IDYMJSONHelper.GetIntegerValue(Product, 'ProdCSID'));
                if not IDYSProviderBookingProfile.FindLast() then begin
                    IDYSProviderBookingProfile."Carrier Entry No." := IDYSProviderCarrier."Entry No.";
                    IDYSProviderBookingProfile.ProdCSID := IDYMJSONHelper.GetIntegerValue(Product, 'ProdCSID');
                    IDYSProviderBookingProfile.Insert(true);
                end else
                    CurrentProviderBookingProfileList.Remove(IDYSProviderBookingProfile.SystemId);

                IDYSProviderBookingProfile."Subcarrier Name" := CopyStr(IDYMJSONHelper.GetTextValue(Product, 'SubcarrierName'), 1, MaxStrLen(IDYSProviderBookingProfile."Subcarrier Name"));
                IDYSProviderBookingProfile.Description := CopyStr(IDYMJSONHelper.GetTextValue(Product, 'ProdName'), 1, MaxStrLen(IDYSProviderBookingProfile.Description));
                IDYSProviderBookingProfile.AllowDG := IDYMJSONHelper.GetBooleanValue(Product, 'AllowDG');
                IDYSProviderBookingProfile.AllowCOD := IDYMJSONHelper.GetBooleanValue(Product, 'AllowCOD');
                IDYSProviderBookingProfile.Modify(true);

                // GoodTypes
                foreach GoodsType in IDYMJSONHelper.GetArray(Product, 'GoodsTypes') do
                    if IDYMJSONHelper.GetCodeValue(GoodsType, 'GoodsTypeID') <> '' then begin
                        if not IDYSBookingProfPackageType.Get(IDYSProviderBookingProfile."Carrier Entry No.", IDYSProviderBookingProfile."Entry No.", CopyStr(IDYMJSONHelper.GetCodeValue(GoodsType, 'GoodsTypeID'), 1, MaxStrLen(IDYSBookingProfPackageType."Package Type Code"))) then begin
                            IDYSBookingProfPackageType.Init();
                            IDYSBookingProfPackageType.Validate("Carrier Entry No.", IDYSProviderBookingProfile."Carrier Entry No.");
                            IDYSBookingProfPackageType.Validate("Booking Profile Entry No.", IDYSProviderBookingProfile."Entry No.");
                            IDYSBookingProfPackageType.Validate("Package Type Code", CopyStr(IDYMJSONHelper.GetCodeValue(GoodsType, 'GoodsTypeID'), 1, MaxStrLen(IDYSBookingProfPackageType."Package Type Code")));
                            IDYSBookingProfPackageType.Insert();
                        end else
                            CurrentBookingProfPackageTypeList.Remove(IDYSBookingProfPackageType.SystemId);

                        IDYSBookingProfPackageType.GoodsTypeKey1 := CopyStr(IDYMJSONHelper.GetTextValue(GoodsType, 'GoodsTypeKey1'), 1, MaxStrLen(IDYSBookingProfPackageType.GoodsTypeKey1));
                        IDYSBookingProfPackageType.GoodsTypeKey2 := CopyStr(IDYMJSONHelper.GetTextValue(GoodsType, 'GoodsTypeKey2'), 1, MaxStrLen(IDYSBookingProfPackageType.GoodsTypeKey1));
                        IDYSBookingProfPackageType.Description := CopyStr(IDYMJSONHelper.GetTextValue(GoodsType, 'GoodsTypeKeyword'), 1, MaxStrLen(IDYSBookingProfPackageType.Description));
                        IDYSBookingProfPackageType.Modify(true);
                    end;

                //  Services
                foreach Service in IDYMJSONHelper.GetArray(Product, 'Services') do begin
                    if IDYMJSONHelper.GetCodeValue(Service, 'ServiceCode') <> '' then begin
                        // Create unique service level code 
                        ServiceCode := CopyStr(IDYMJSONHelper.GetCodeValue(Service, 'ServiceCode') + Format(IDYMJSONHelper.GetIntegerValue(Service, 'ServiceID')), 1, MaxStrLen(ServiceCode));

                        IDYSServiceLevelOther.SetRange("Code", ServiceCode);
                        if not IDYSServiceLevelOther.FindFirst() then begin
                            IDYSServiceLevelOther."Code" := CopyStr(ServiceCode, 1, MaxStrLen(IDYSServiceLevelOther."Code"));
                            IDYSServiceLevelOther.Insert()
                        end else
                            CurrentIDYSServiceLevelOtherList.Remove(IDYSServiceLevelOther.SystemId);

                        IDYSServiceLevelOther."Service Code" := CopyStr(IDYMJSONHelper.GetCodeValue(Service, 'ServiceCode'), 1, MaxStrLen(IDYSServiceLevelOther."Service Code"));
                        IDYSServiceLevelOther.Description := CopyStr(IDYMJSONHelper.GetCodeValue(Service, 'ServiceName'), 1, MaxStrLen(IDYSServiceLevelOther.Description));
                        IDYSServiceLevelOther.ServiceID := IDYMJSONHelper.GetIntegerValue(Service, 'ServiceID');
                        IDYSServiceLevelOther.GroupID := IDYMJSONHelper.GetIntegerValue(Service, 'GroupID');
                        IDYSServiceLevelOther."Is Default" := IDYMJSONHelper.GetBooleanValue(Service, 'Default');
                        IDYSServiceLevelOther."Read Only" := IDYMJSONHelper.GetBooleanValue(Service, 'ReadOnly');
                        IDYSServiceLevelOther.Modify();
                    end;

                    // Creating detailed entries                
                    if Countries <> '' then begin
                        // Specific countries
                        Countries := Countries.Replace(' ', '');
                        CountryList := Countries.Split(',');

                        foreach Country in CountryList do begin
                            IDYSDelHubAPIServices.Reset();
                            IDYSDelHubAPIServices.SetRange("Carrier Entry No.", IDYSProviderBookingProfile."Carrier Entry No.");
                            IDYSDelHubAPIServices.SetRange("Booking Profile Entry No.", IDYSProviderBookingProfile."Entry No.");
                            IDYSDelHubAPIServices.SetRange("Service Level Code (Other)", IDYSServiceLevelOther."Code");
                            IDYSDelHubAPIServices.SetRange("Country Code", GetMappedCountryCode(CopyStr(Country, 1, MaxStrLen(IDYSDelHubAPIServices."Country Code"))));
                            if not IDYSDelHubAPIServices.FindLast() then begin
                                IDYSDelHubAPIServices.Init();
                                IDYSDelHubAPIServices.Validate("Carrier Entry No.", IDYSProviderBookingProfile."Carrier Entry No.");
                                IDYSDelHubAPIServices.Validate("Booking Profile Entry No.", IDYSProviderBookingProfile."Entry No.");
                                IDYSDelHubAPIServices."Service Level Code (Other)" := IDYSServiceLevelOther."Code";
                                IDYSDelHubAPIServices."Country Code" := GetMappedCountryCode(CopyStr(Country, 1, MaxStrLen(IDYSDelHubAPIServices."Country Code")));                     // Ship-from
                                IDYSDelHubAPIServices.Insert(true);
                            end else
                                CurrentIDYSDelHubAPIServicesList.Remove(IDYSDelHubAPIServices.SystemId);

                            // Ship-to Countries
                            foreach ShipToCountry in ShipToCountriesList do
                                UpsertDelHubAPISvcCountry(0, IDYSDelHubAPIServices."Entry No.", ShipToCountry);

                            // Ship-to Countries (Denied)
                            foreach ShipToCountryDenied in ShipToCountriesDeniedList do
                                if ShipToCountryDenied <> '' then
                                    UpsertDelHubAPISvcCountry(1, IDYSDelHubAPIServices."Entry No.", ShipToCountryDenied);
                        end;
                    end else begin
                        // All countries
                        IDYSDelHubAPIServices.Reset();
                        IDYSDelHubAPIServices.SetRange("Carrier Entry No.", IDYSProviderBookingProfile."Carrier Entry No.");
                        IDYSDelHubAPIServices.SetRange("Booking Profile Entry No.", IDYSProviderBookingProfile."Entry No.");
                        IDYSDelHubAPIServices.SetRange("Service Level Code (Other)", IDYSServiceLevelOther."Code");
                        if not IDYSDelHubAPIServices.FindLast() then begin
                            IDYSDelHubAPIServices.Init();
                            IDYSDelHubAPIServices.Validate("Carrier Entry No.", IDYSProviderBookingProfile."Carrier Entry No.");
                            IDYSDelHubAPIServices.Validate("Booking Profile Entry No.", IDYSProviderBookingProfile."Entry No.");
                            IDYSDelHubAPIServices."Service Level Code (Other)" := IDYSServiceLevelOther."Code";
                            IDYSDelHubAPIServices.Insert(true);
                        end else
                            CurrentIDYSDelHubAPIServicesList.Remove(IDYSDelHubAPIServices.SystemId);

                        // Ship-to Countries
                        foreach ShipToCountry in ShipToCountriesList do
                            UpsertDelHubAPISvcCountry(0, IDYSDelHubAPIServices."Entry No.", ShipToCountry);

                        // Ship-to Countries (Denied)
                        foreach ShipToCountryDenied in ShipToCountriesDeniedList do
                            if ShipToCountryDenied <> '' then
                                UpsertDelHubAPISvcCountry(1, IDYSDelHubAPIServices."Entry No.", ShipToCountryDenied);
                    end;
                end;
            end;
    end;

    internal procedure UpsertDelHubAPISvcCountry(EntryType: Integer; ServiceEntryNo: Integer; ShipToCountry: Text)
    var
        IDYSDelHubAPISvcCountry: Record "IDYS DelHub API Svc. Country";
    begin
        IDYSDelHubAPISvcCountry.Reset();
        IDYSDelHubAPISvcCountry.SetRange("Service Entry No.", ServiceEntryNo);
        IDYSDelHubAPISvcCountry.SetRange("Entry Type", EntryType);
        IDYSDelHubAPISvcCountry.SetRange("Country Code (API)", ShipToCountry);
        if not IDYSDelHubAPISvcCountry.FindLast() then begin
            IDYSDelHubAPISvcCountry.Init();
            IDYSDelHubAPISvcCountry.Validate("Service Entry No.", ServiceEntryNo);
            IDYSDelHubAPISvcCountry.Validate("Entry Type", EntryType);
            IDYSDelHubAPISvcCountry.Validate("Country Code (API)", CopyStr(ShipToCountry, 1, MaxStrLen(IDYSDelHubAPISvcCountry."Country Code (API)")));
            IDYSDelHubAPISvcCountry.Insert(true);
        end else
            CurrentIDYSDelHubAPISvcCountryList.Remove(IDYSDelHubAPISvcCountry.SystemId);

        IDYSDelHubAPISvcCountry."Country Code (Mapped)" := GetMappedCountryCode(CopyStr(ShipToCountry, 1, MaxStrLen(IDYSDelHubAPISvcCountry."Country Code (Mapped)")));
        IDYSDelHubAPISvcCountry.Modify();
    end;

    local procedure CleanMasterData()
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSDelHubAPIServices: Record "IDYS DelHub API Services";
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
        IDYSDelHubAPISvcCountry: Record "IDYS DelHub API Svc. Country";
        ProviderCarrierId: Guid;
        ProviderBookingProfileId: Guid;
        IDYSDelHubAPIServiceId: Guid;
        IDYSServiceLevelOtherId: Guid;
        BookingProfPackageTypeId: Guid;
        IDYSDelHubAPISvcCountryId: Guid;
    begin
        foreach ProviderCarrierId in CurrentProviderCarrierList do
            if IDYSProviderCarrier.GetBySystemId(ProviderCarrierId) then
                IDYSProviderCarrier.Delete();

        foreach ProviderBookingProfileId in CurrentProviderBookingProfileList do
            if IDYSProviderBookingProfile.GetBySystemId(ProviderBookingProfileId) then
                IDYSProviderBookingProfile.Delete(true);

        foreach IDYSDelHubAPIServiceId in CurrentIDYSDelHubAPIServicesList do
            if IDYSDelHubAPIServices.GetBySystemId(IDYSDelHubAPIServiceId) then
                IDYSDelHubAPIServices.Delete();

        foreach IDYSServiceLevelOtherId in CurrentIDYSServiceLevelOtherList do
            if IDYSServiceLevelOther.GetBySystemId(IDYSServiceLevelOtherId) then
                IDYSServiceLevelOther.Delete();

        foreach BookingProfPackageTypeId in CurrentBookingProfPackageTypeList do
            if IDYSBookingProfPackageType.GetBySystemId(BookingProfPackageTypeId) then
                IDYSBookingProfPackageType.Delete();

        foreach IDYSDelHubAPISvcCountryId in CurrentIDYSDelHubAPISvcCountryList do
            if IDYSDelHubAPISvcCountry.GetBySystemId(IDYSDelHubAPISvcCountryId) then
                IDYSDelHubAPISvcCountry.Delete();
    end;

    local procedure GetCurrentMasterData(ActorId: Text[30])
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSDelHubAPIServices: Record "IDYS DelHub API Services";
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
        IDYSDelHubAPISvcCountry: Record "IDYS DelHub API Svc. Country";
    begin
        IDYSProviderCarrier.SetRange(Provider, IDYSProviderCarrier.Provider::"Delivery Hub");
        IDYSProviderCarrier.SetRange("Actor Id", ActorId);
        if IDYSProviderCarrier.FindSet() then
            repeat
                CurrentProviderCarrierList.Add(IDYSProviderCarrier.SystemId);

                IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
                if IDYSProviderBookingProfile.FindSet() then
                    repeat
                        CurrentProviderBookingProfileList.Add(IDYSProviderBookingProfile.SystemId);
                    until IDYSProviderBookingProfile.Next() = 0;
            until IDYSProviderCarrier.Next() = 0;

        IDYSDelHubAPIServices.SetRange("Actor Id", ActorId);
        if IDYSDelHubAPIServices.FindSet() then
            repeat
                CurrentIDYSDelHubAPIServicesList.Add(IDYSDelHubAPIServices.SystemId);
            until IDYSDelHubAPIServices.Next() = 0;

        IDYSServiceLevelOther.SetFilter(ServiceId, '<>%1', 0);
        if IDYSServiceLevelOther.FindSet() then
            repeat
                CurrentIDYSServiceLevelOtherList.Add(IDYSServiceLevelOther.SystemId);
            until IDYSServiceLevelOther.Next() = 0;

        IDYSBookingProfPackageType.SetRange(Provider, IDYSBookingProfPackageType.Provider::"Delivery Hub");
        IDYSBookingProfPackageType.SetRange("Actor Id", ActorId);
        if IDYSBookingProfPackageType.FindSet() then
            repeat
                CurrentBookingProfPackageTypeList.Add(IDYSBookingProfPackageType.SystemId);
            until IDYSBookingProfPackageType.Next() = 0;

        if IDYSDelHubAPISvcCountry.FindSet() then
            repeat
                CurrentIDYSDelHubAPISvcCountryList.Add(IDYSDelHubAPISvcCountry.SystemId);
            until IDYSDelHubAPISvcCountry.Next() = 0
    end;

    local procedure GetSetup(): Boolean
    begin
        if not SetupLoaded then
            SetupLoaded := IDYSSetup.Get();

        if not ProviderSetupLoaded then begin
            IDYSDelHubSetup.GetProviderSetup("IDYS Provider"::"Delivery Hub");
            ProviderSetupLoaded := true;
        end;

        exit(SetupLoaded);
    end;

    [Obsolete('Added ActorId parameter', '23.0')]
    procedure ProcessData(Carrier: JsonToken)
    begin
    end;

    [Obsolete('Body moved to the UpdateMasterData procedure', '23.0')]
    procedure GetMasterData(var ErrorCode: Enum "IDYS Error Codes"): Boolean
    begin
    end;

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSDelHubSetup: Record "IDYS Setup";
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        IDYMHttpHelper: Codeunit "IDYM Http Helper";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        CurrentProviderCarrierList: List of [Guid];
        CurrentProviderBookingProfileList: List of [Guid];
        CurrentIDYSDelHubAPIServicesList: List of [Guid];
        CurrentIDYSDelHubAPISvcCountryList: List of [Guid];
        CurrentIDYSServiceLevelOtherList: List of [Guid];
        CurrentBookingProfPackageTypeList: List of [Guid];
        SetupLoaded: Boolean;
        DataUpgrade: Boolean;
        ProviderSetupLoaded: Boolean;
        ProgressWindowDialog: Dialog;
}