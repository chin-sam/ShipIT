codeunit 11147639 "IDYS Transsmart API Data Setup"
{
    procedure GetCarriers(): Boolean
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonToken;
        Carriers: JsonArray;
        CarrierRoot: JsonToken;
        Carrier: JsonObject;
        EndpointTxt: Label '/v2/accounts/%1/listsettings/carriers', Locked = true;
    begin
        GetSetup();
        if not IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code"), true, IDYSSetup, TempIDYMRESTParameters, API::Transsmart) then begin
            SetErrorMessageFromResponse(TempIDYMRESTParameters."Status Code", TempIDYMRESTParameters.GetResponseBodyAsString());
            exit(false);
        end;

        if IDYSSetup."Unit Test Mode" then
            Response.ReadFrom(MockGetCarriersResponseTxt)
        else
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();
        Carriers := Response.AsArray();
        GetCurrentProviderCarriers();
        foreach CarrierRoot in Carriers do begin
            Carrier.ReadFrom(IDYMJSONHelper.GetTextValue(CarrierRoot, 'value'));

            Clear(IDYSProviderCarrier);
            IDYSProviderCarrier.SetRange("Transsmart Carrier Code", IDYMJSONHelper.GetCodeValue(Carrier, 'code'));
            if not IDYSProviderCarrier.FindLast() then begin
                IDYSProviderCarrier.Init();
                IDYSProviderCarrier.Validate(Provider, IDYSProviderCarrier.Provider::Transsmart);
                IDYSProviderCarrier.Validate("Transsmart Carrier Code", IDYMJSONHelper.GetCodeValue(Carrier, 'code'));
                IDYSProviderCarrier.Insert(true);
            end else
                CurrentProviderCarrierList.Remove(IDYSProviderCarrier.SystemId);

            IDYSProviderCarrier.Validate(Name, IDYMJSONHelper.GetTextValue(Carrier, 'name'));
            IDYSProviderCarrier.Validate("Location Select", IDYMJSONHelper.GetBooleanValue(Carrier, 'locationSelect'));
            IDYSProviderCarrier.Validate("Needs Manifesting", IDYMJSONHelper.GetBooleanValue(Carrier, 'needsManifesting'));
            IDYSProviderCarrier.Modify(true);
        end;

        CleanProviderCarriers();
        exit(true);
    end;

    local procedure GetCurrentProviderCarriers()
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
    begin
        IDYSProviderCarrier.SetRange(Provider, IDYSProviderCarrier.Provider::Transsmart);
        if IDYSProviderCarrier.FindSet() then
            repeat
                CurrentProviderCarrierList.Add(IDYSProviderCarrier.SystemId);
            until IDYSProviderCarrier.Next() = 0;
    end;

    local procedure CleanProviderCarriers()
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        ProviderCarrierId: Guid;
    begin
        foreach ProviderCarrierId in CurrentProviderCarrierList do
            if IDYSProviderCarrier.GetBySystemId(ProviderCarrierId) then
                IDYSProviderCarrier.Delete();
    end;

    procedure GetBookingProfiles(): Boolean
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSServiceLevelTime: Record "IDYS Service Level (Time)";
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonToken;
        BookingProfiles: JsonArray;
        BookingProfileRoot: JsonToken;
        BookingProfile: JsonToken;
        EndpointTxt: Label '/v2/accounts/%1/listsettings/bookingProfiles', Locked = true;
    begin
        GetSetup();
        if not IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code"), true, IDYSSetup, TempIDYMRESTParameters, API::Transsmart) then begin
            SetErrorMessageFromResponse(TempIDYMRESTParameters."Status Code", TempIDYMRESTParameters.GetResponseBodyAsString());
            exit(false);
        end;

        if IDYSSetup."Unit Test Mode" then
            Response.ReadFrom(MockGetBookingProfilesTxt)
        else
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        BookingProfiles := Response.AsArray();
        GetCurrentProviderBookingProfiles();
        foreach BookingProfileRoot in BookingProfiles do begin
            BookingProfile.ReadFrom(IDYMJSONHelper.GetTextValue(BookingProfileRoot, 'value'));

            IDYSProviderCarrier.SetRange("Transsmart Carrier Code", IDYMJSONHelper.GetCodeValue(BookingProfile, 'carrier'));
            IDYSProviderCarrier.FindLast();

            Clear(IDYSProviderBookingProfile);
            IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
            IDYSProviderBookingProfile.SetRange("Transsmart Booking Prof. Code", CopyStr(IDYMJSONHelper.GetCodeValue(BookingProfile, 'code'), 1, MaxStrLen(IDYSProviderBookingProfile."Transsmart Booking Prof. Code")));
            if not IDYSProviderBookingProfile.FindLast() then begin
                IDYSProviderBookingProfile.Init();
                IDYSProviderBookingProfile."Carrier Entry No." := IDYSProviderCarrier."Entry No.";
                IDYSProviderBookingProfile."Transsmart Booking Prof. Code" := CopyStr(IDYMJSONHelper.GetCodeValue(BookingProfile, 'code'), 1, MaxStrLen(IDYSProviderBookingProfile."Transsmart Booking Prof. Code"));
                IDYSProviderBookingProfile.Insert(true);
            end else
                CurrentProviderBookingProfileList.Remove(IDYSProviderBookingProfile.SystemId);

            IDYSProviderBookingProfile.Description := CopyStr(IDYMJSONHelper.GetTextValue(BookingProfile, 'description'), 1, MaxStrLen(IDYSProviderBookingProfile.Description));

            Clear(IDYSServiceLevelTime);
            if IDYMJSONHelper.GetCodeValue(BookingProfile, 'serviceLevelTime') <> '' then begin
                IDYSServiceLevelTime.SetRange("Code", IDYMJSONHelper.GetCodeValue(BookingProfile, 'serviceLevelTime'));
                if IDYSServiceLevelTime.FindFirst() then;
            end;
            IDYSProviderBookingProfile."Service Level Code (Time)" := IDYSServiceLevelTime."Code";

            Clear(IDYSServiceLevelOther);
            if IDYMJSONHelper.GetCodeValue(BookingProfile, 'serviceLevelOther') <> '' then begin
                IDYSServiceLevelOther.SetRange("Code", IDYMJSONHelper.GetCodeValue(BookingProfile, 'serviceLevelOther'));
                if IDYSServiceLevelOther.FindFirst() then;
            end;
            IDYSProviderBookingProfile."Service Level Code (Other)" := IDYSServiceLevelOther."Code";
            IDYSProviderBookingProfile.Modify(true);
        end;
        CleanProviderBookingProfiles();
        exit(true);
    end;

    local procedure GetCurrentProviderBookingProfiles()
    var
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
    begin
        IDYSProviderBookingProfile.SetRange(Provider, IDYSProviderBookingProfile.Provider::Transsmart);
        if IDYSProviderBookingProfile.FindSet() then
            repeat
                CurrentProviderBookingProfileList.Add(IDYSProviderBookingProfile.SystemId);
            until IDYSProviderBookingProfile.Next() = 0;
    end;

    local procedure CleanProviderBookingProfiles()
    var
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        ProviderBookingProfileId: Guid;
    begin
        foreach ProviderBookingProfileId in CurrentProviderBookingProfileList do
            if IDYSProviderBookingProfile.GetBySystemId(ProviderBookingProfileId) then
                IDYSProviderBookingProfile.Delete(true);
    end;

    procedure GetCostCenters(): Boolean
    var
        IDYSCostCenter: Record "IDYS Cost Center";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonToken;
        CostCenters: JsonArray;
        CostCenterRoot: JsonToken;
        CostCenter: JsonToken;
        EndpointTxt: Label '/v2/accounts/%1/listsettings/costCenters', Locked = true;
    begin
        GetSetup();
        if not IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code"), true, IDYSSetup, TempIDYMRESTParameters, API::Transsmart) then begin
            SetErrorMessageFromResponse(TempIDYMRESTParameters."Status Code", TempIDYMRESTParameters.GetResponseBodyAsString());
            exit(false);
        end;

        if IDYSSetup."Unit Test Mode" then
            Response.ReadFrom(MockGetCostCentersResponseTxt)
        else
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        CostCenters := Response.AsArray();
        GetCurrentCostCenters();
        foreach CostCenterRoot in CostCenters do begin
            CostCenter.ReadFrom(IDYMJSONHelper.GetTextValue(CostCenterRoot, 'value'));

            if not IDYSCostCenter.Get(CopyStr(IDYMJSONHelper.GetCodeValue(CostCenter, 'code'), 1, MaxStrLen(IDYSCostCenter."Code"))) then begin
                IDYSCostCenter."Code" := CopyStr(IDYMJSONHelper.GetCodeValue(CostCenter, 'code'), 1, MaxStrLen(IDYSCostCenter."Code"));
                IDYSCostCenter.Insert(true);
            end else
                CurrentIDYSCostCenterList.Remove(IDYSCostCenter.SystemId);

            IDYSCostCenter.Name := CopyStr(IDYMJSONHelper.GetTextValue(CostCenter, 'description'), 1, MaxStrLen(IDYSCostCenter.Name));
            IDYSCostCenter."Is Default" := IDYMJSONHelper.GetBooleanValue(CostCenter, 'isDefault');
            IDYSCostCenter.Modify();
        end;

        CleanCostCenters();
        exit(true);
    end;

    local procedure GetCurrentCostCenters()
    var
        IDYSCostCenter: Record "IDYS Cost Center";
    begin
        if IDYSCostCenter.FindSet() then
            repeat
                CurrentIDYSCostCenterList.Add(IDYSCostCenter.SystemId);
            until IDYSCostCenter.Next() = 0;
    end;

    local procedure CleanCostCenters()
    var
        IDYSCostCenter: Record "IDYS Cost Center";
        IDYSCostCenterId: Guid;
    begin
        foreach IDYSCostCenterId in CurrentIDYSCostCenterList do
            if IDYSCostCenter.GetBySystemId(IDYSCostCenterId) then
                IDYSCostCenter.Delete(true);
    end;

    procedure GetEMailTypes(): Boolean
    var
        IDYSEMailType: Record "IDYS E-Mail Type";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonToken;
        EMailTypes: JsonArray;
        EMailTypeRoot: JsonToken;
        EMailType: JsonToken;
        EndpointTxt: Label '/v2/accounts/%1/listsettings/mailTypes', Locked = true;
    begin
        GetSetup();
        if not IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code"), true, IDYSSetup, TempIDYMRESTParameters, API::Transsmart) then begin
            SetErrorMessageFromResponse(TempIDYMRESTParameters."Status Code", TempIDYMRESTParameters.GetResponseBodyAsString());
            exit(false);
        end;

        if IDYSSetup."Unit Test Mode" then
            Response.ReadFrom(MockGetEMailTypesResponseTxt)
        else
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        EMailTypes := Response.AsArray();
        GetCurrentEmailTypes();
        foreach EMailTypeRoot in EMailTypes do begin
            EMailType.ReadFrom(IDYMJSONHelper.GetTextValue(EMailTypeRoot, 'value'));

            if not IDYSEMailType.Get(CopyStr(IDYMJSONHelper.GetCodeValue(EMailType, 'code'), 1, MaxStrLen(IDYSEMailType."Code"))) then begin
                IDYSEMailType."Code" := CopyStr(IDYMJSONHelper.GetCodeValue(EMailType, 'code'), 1, MaxStrLen(IDYSEMailType."Code"));
                IDYSEMailType.Insert(true);
            end else
                CurrentIDYSEMailTypeList.Remove(IDYSEMailType.SystemId);

            IDYSEMailType.Description := CopyStr(IDYMJSONHelper.GetTextValue(EMailType, 'description'), 1, MaxStrLen(IDYSEMailType.Description));
            IDYSEMailType."Is Default" := IDYMJSONHelper.GetBooleanValue(EMailType, 'isDefault');
            IDYSEMailType.Modify();
        end;

        CleanEmailTypes();
        exit(true);
    end;

    local procedure GetCurrentEmailTypes()
    var
        IDYSEMailType: Record "IDYS E-Mail Type";
    begin
        if IDYSEMailType.FindSet() then
            repeat
                CurrentIDYSEMailTypeList.Add(IDYSEMailType.SystemId);
            until IDYSEMailType.Next() = 0;
    end;

    local procedure CleanEmailTypes()
    var
        IDYSEMailType: Record "IDYS E-Mail Type";
        IDYSEMailTypeId: Guid;
    begin
        foreach IDYSEMailTypeId in CurrentIDYSEMailTypeList do
            if IDYSEMailType.GetBySystemId(IDYSEMailTypeId) then
                IDYSEMailType.Delete(true);
    end;

    procedure GetServiceLevelsTime(): Boolean
    var
        IDYSServiceLevelTime: Record "IDYS Service Level (Time)";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonToken;
        ServiceLevelTimes: JsonArray;
        ServiceLevelTimeRoot: JsonToken;
        ServiceLevelTime: JsonToken;
        EndpointTxt: Label '/v2/accounts/%1/listsettings/serviceLevelTimes', Locked = true;
    begin
        GetSetup();
        if not IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code"), true, IDYSSetup, TempIDYMRESTParameters, API::Transsmart) then begin
            SetErrorMessageFromResponse(TempIDYMRESTParameters."Status Code", TempIDYMRESTParameters.GetResponseBodyAsString());
            exit(false);
        end;

        if IDYSSetup."Unit Test Mode" then
            Response.ReadFrom(MockGetServiceLevelsTimesTxt)
        else
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        ServiceLevelTimes := Response.AsArray();
        GetCurrentServiceLevelsTime();
        foreach ServiceLevelTimeRoot in ServiceLevelTimes do begin
            ServiceLevelTime.ReadFrom(IDYMJSONHelper.GetTextValue(ServiceLevelTimeRoot, 'value'));

            if not IDYSServiceLevelTime.Get(CopyStr(IDYMJSONHelper.GetCodeValue(ServiceLevelTime, 'code'), 1, MaxStrLen(IDYSServiceLevelTime."Code"))) then begin
                IDYSServiceLevelTime."Code" := CopyStr(IDYMJSONHelper.GetCodeValue(ServiceLevelTime, 'code'), 1, MaxStrLen(IDYSServiceLevelTime."Code"));
                IDYSServiceLevelTime.Insert(true);
            end else
                CurrentServiceLevelsTimeList.Remove(IDYSServiceLevelTime.SystemId);

            IDYSServiceLevelTime.Description := CopyStr(IDYMJSONHelper.GetTextValue(ServiceLevelTime, 'description'), 1, MaxStrLen(IDYSServiceLevelTime.Description));
            IDYSServiceLevelTime."Is Default" := IDYMJSONHelper.GetBooleanValue(ServiceLevelTime, 'isDefault');
            IDYSServiceLevelTime.Modify();
        end;

        CleanServiceLevelsTime();
        exit(true);
    end;

    local procedure GetCurrentServiceLevelsTime()
    var
        IDYSServiceLevelTime: Record "IDYS Service Level (Time)";
    begin
        if IDYSServiceLevelTime.FindSet() then
            repeat
                CurrentServiceLevelsTimeList.Add(IDYSServiceLevelTime.SystemId);
            until IDYSServiceLevelTime.Next() = 0;
    end;

    local procedure CleanServiceLevelsTime()
    var
        IDYSServiceLevelTime: Record "IDYS Service Level (Time)";
        IDYSServiceLevelTimeId: Guid;
    begin
        foreach IDYSServiceLevelTimeId in CurrentServiceLevelsTimeList do
            if IDYSServiceLevelTime.GetBySystemId(IDYSServiceLevelTimeId) then
                IDYSServiceLevelTime.Delete(true);
    end;

    procedure GetServiceLevelsOther(): Boolean
    var
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonToken;
        ServiceLevelOthers: JsonArray;
        ServiceLevelOtherRoot: JsonToken;
        ServiceLevelOther: JsonToken;
        EndpointTxt: Label '/v2/accounts/%1/listsettings/serviceLevelOthers', Locked = true;
    begin
        GetSetup();
        if not IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code"), true, IDYSSetup, TempIDYMRESTParameters, API::Transsmart) then begin
            SetErrorMessageFromResponse(TempIDYMRESTParameters."Status Code", TempIDYMRESTParameters.GetResponseBodyAsString());
            exit(false);
        end;

        if IDYSSetup."Unit Test Mode" then
            Response.ReadFrom(MockGetServiceLevelsOthersTxt)
        else
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        ServiceLevelOthers := Response.AsArray();
        GetCurrentServiceLevelsOther();
        foreach ServiceLevelOtherRoot in ServiceLevelOthers do begin
            ServiceLevelOther.ReadFrom(IDYMJSONHelper.GetTextValue(ServiceLevelOtherRoot, 'value'));

            if not IDYSServiceLevelOther.Get(CopyStr(IDYMJSONHelper.GetCodeValue(ServiceLevelOther, 'code'), 1, MaxStrLen(IDYSServiceLevelOther."Code"))) then begin
                IDYSServiceLevelOther."Code" := CopyStr(IDYMJSONHelper.GetCodeValue(ServiceLevelOther, 'code'), 1, MaxStrLen(IDYSServiceLevelOther."Code"));
                IDYSServiceLevelOther.Insert(true);

            end else
                CurrentIDYSServiceLevelOtherList.Remove(IDYSServiceLevelOther.SystemId);

            IDYSServiceLevelOther.Description := CopyStr(IDYMJSONHelper.GetTextValue(ServiceLevelOther, 'description'), 1, MaxStrLen(IDYSServiceLevelOther.Description));
            IDYSServiceLevelOther."Is Default" := IDYMJSONHelper.GetBooleanValue(ServiceLevelOther, 'isDefault');
            IDYSServiceLevelOther.Modify();
        end;

        CleanServiceLevelsOther();
        exit(true);
    end;

    local procedure GetCurrentServiceLevelsOther()
    var
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
    begin
        IDYSServiceLevelOther.SetRange(ServiceId, 0);
        if IDYSServiceLevelOther.FindSet() then
            repeat
                CurrentIDYSServiceLevelOtherList.Add(IDYSServiceLevelOther.SystemId);
            until IDYSServiceLevelOther.Next() = 0;
    end;

    local procedure CleanServiceLevelsOther()
    var
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
        IDYSServiceLevelOtherId: Guid;
    begin
        foreach IDYSServiceLevelOtherId in CurrentIDYSServiceLevelOtherList do
            if IDYSServiceLevelOther.GetBySystemId(IDYSServiceLevelOtherId) then
                IDYSServiceLevelOther.Delete();
    end;

    procedure GetPackageTypes(): Boolean
    var
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonToken;
        PackageTypes: JsonArray;
        PackageTypeRoot: JsonToken;
        PackageType: JsonToken;
        EndpointTxt: Label '/v2/accounts/%1/listsettings/packages', Locked = true;
    begin
        GetSetup();
        if not IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code"), true, IDYSSetup, TempIDYMRESTParameters, API::Transsmart) then begin
            SetErrorMessageFromResponse(TempIDYMRESTParameters."Status Code", TempIDYMRESTParameters.GetResponseBodyAsString());
            exit(false);
        end;

        if IDYSSetup."Unit Test Mode" then
            Response.ReadFrom(MockGetPackageTypesTxt)
        else
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        PackageTypes := Response.AsArray();
        GetCurrentProviderPackageTypes();
        foreach PackageTypeRoot in PackageTypes do begin
            PackageType.ReadFrom(IDYMJSONHelper.GetTextValue(PackageTypeRoot, 'value'));

            IDYSProviderPackageType.SetRange(Provider, IDYSProviderPackageType.Provider::Transsmart);
            IDYSProviderPackageType.SetRange(Code, CopyStr(IDYMJSONHelper.GetCodeValue(PackageType, 'code'), 1, MaxStrLen(IDYSProviderPackageType."Code")));
            if not IDYSProviderPackageType.FindLast() then begin
                IDYSProviderPackageType."Code" := CopyStr(IDYMJSONHelper.GetCodeValue(PackageType, 'code'), 1, MaxStrLen(IDYSProviderPackageType."Code"));
                IDYSProviderPackageType.Provider := IDYSProviderPackageType.Provider::Transsmart;
                IDYSProviderPackageType.Insert(true);
            end else
                CurrentIDYSProviderPackageTypeList.Remove(IDYSProviderPackageType.SystemId);

            IDYSProviderPackageType.Description := CopyStr(IDYMJSONHelper.GetTextValue(PackageType, 'description'), 1, MaxStrLen(IDYSProviderPackageType.Description));
            IDYSProviderPackageType."Type" := CopyStr(IDYMJSONHelper.GetTextValue(PackageType, 'type'), 1, MaxStrLen(IDYSProviderPackageType."Type"));
            IDYSProviderPackageType.Length := IDYMJSONHelper.GetDecimalValue(PackageType, 'length');
            IDYSProviderPackageType.Width := IDYMJSONHelper.GetDecimalValue(PackageType, 'width');
            IDYSProviderPackageType.Height := IDYMJSONHelper.GetDecimalValue(PackageType, 'height');
            IDYSProviderPackageType.Weight := IDYMJSONHelper.GetDecimalValue(PackageType, 'weight');
            IDYSProviderPackageType."Linear UOM" := CopyStr(IDYMJSONHelper.GetTextValue(PackageType, 'linearUom'), 1, MaxStrLen(IDYSProviderPackageType."Linear UOM"));
            IDYSProviderPackageType."Mass UOM" := CopyStr(IDYMJSONHelper.GetTextValue(PackageType, 'massUom'), 1, MaxStrLen(IDYSProviderPackageType."Mass UOM"));
            IDYSProviderPackageType.Modify();
        end;

        CleanProviderPackageTypes();
        exit(true);
    end;

    local procedure GetCurrentProviderPackageTypes()
    var
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
    begin
        IDYSProviderPackageType.SetRange(Provider, IDYSProviderPackageType.Provider::Transsmart);
        if IDYSProviderPackageType.FindSet() then
            repeat
                CurrentIDYSProviderPackageTypeList.Add(IDYSProviderPackageType.SystemId);
            until IDYSProviderPackageType.Next() = 0;
    end;

    local procedure CleanProviderPackageTypes()
    var
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        IDYSProviderPackageTypeId: Guid;
    begin
        foreach IDYSProviderPackageTypeId in CurrentIDYSProviderPackageTypeList do
            if IDYSProviderPackageType.GetBySystemId(IDYSProviderPackageTypeId) then
                IDYSProviderPackageType.Delete();
    end;

    procedure GetIncoTerms(): Boolean
    var
        IDYSIncoterm: Record "IDYS Incoterm";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        Response: JsonToken;
        Incoterms: JsonArray;
        IncotermRoot: JsonToken;
        Incoterm: JsonToken;
        EndpointTxt: Label '/v2/accounts/%1/listsettings/incoterms', Locked = true;
    begin
        // The same incoterm table without provider level is used in Transsmart and EasyPost
        GetSetup();
        if not IDYSAPIHelper.ExecuteGet(StrSubstNo(EndpointTxt, IDYSTranssmartSetup."Transsmart Account Code"), true, IDYSSetup, TempIDYMRESTParameters, API::Transsmart) then begin
            SetErrorMessageFromResponse(TempIDYMRESTParameters."Status Code", TempIDYMRESTParameters.GetResponseBodyAsString());
            exit(false);
        end;
        if IDYSSetup."Unit Test Mode" then
            Response.ReadFrom(MockGetIncoTermsTxt)
        else
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();

        Incoterms := Response.AsArray();
        foreach IncotermRoot in Incoterms do begin
            Incoterm.ReadFrom(IDYMJSONHelper.GetTextValue(IncotermRoot, 'value'));

            if not IDYSIncoterm.Get(CopyStr(IDYMJSONHelper.GetCodeValue(Incoterm, 'code'), 1, MaxStrLen(IDYSIncoterm."Code"))) then begin
                IDYSIncoterm."Code" := CopyStr(IDYMJSONHelper.GetCodeValue(Incoterm, 'code'), 1, MaxStrLen(IDYSIncoterm."Code"));
                IDYSIncoterm.Insert(true);
            end;

            IDYSIncoterm.Description := CopyStr(IDYMJSONHelper.GetTextValue(Incoterm, 'description'), 1, MaxStrLen(IDYSIncoterm.Description));
            IDYSIncoterm.Default := IDYMJSONHelper.GetBooleanValue(Incoterm, 'isDefault');
            IDYSIncoterm.Modify();
        end;

        exit(true);
    end;

    local procedure GetSetup(): Boolean
    begin
        if not SetupLoaded then
            SetupLoaded := IDYSSetup.Get();

        if not ProviderSetupLoaded then begin
            IDYSTranssmartSetup.GetProviderSetup("IDYS Provider"::Transsmart);
            ProviderSetupLoaded := true;
        end;
        Clear(ErrorMessage);
        exit(SetupLoaded);
    end;

    procedure GetErrorMessage(): Text
    begin
        exit(ErrorMessage);
    end;

    procedure SetErrorMessageFromResponse(ResponseStatusCode: Integer; ResponseBodyString: Text): Text
    var
        ErrorCodeTxt: Label 'Error - %1. %2', Comment = '%1 - represents response status code; %2 - represents response message';
        CredentialsErrorCodeTxt: Label 'Credentials are incorrect.';
        TranssmartErrorCodeTxt: Label 'The Account Code is not correct or you do not have access to this account.';
    begin
        case ResponseStatusCode of
            401:
                ErrorMessage := CredentialsErrorCodeTxt;
            403:
                ErrorMessage := TranssmartErrorCodeTxt;
            else
                ErrorMessage := StrSubstNo(ErrorCodeTxt, ResponseStatusCode, ResponseBodyString);
        end;
    end;

    #region [Obsolete]
    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetCarriers(var ErrorCode: Enum "IDYS Error Codes"): Boolean
    begin
        exit(GetCarriers());
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetBookingProfiles(var ErrorCode: Enum "IDYS Error Codes"): Boolean
    begin
        exit(GetBookingProfiles());
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetCostCenters(var ErrorCode: Enum "IDYS Error Codes"): Boolean
    begin
        exit(GetCostCenters());
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetEMailTypes(var ErrorCode: Enum "IDYS Error Codes"): Boolean
    begin
        exit(GetEMailTypes());
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetServiceLevelsTime(var ErrorCode: Enum "IDYS Error Codes"): Boolean
    begin
        exit(GetServiceLevelsTime());
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetServiceLevelsOther(var ErrorCode: Enum "IDYS Error Codes"): Boolean
    begin
        exit(GetServiceLevelsOther());
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetPackageTypes(var ErrorCode: Enum "IDYS Error Codes"): Boolean
    begin
        exit(GetPackageTypes());
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetIncoTerms(var ErrorCode: Enum "IDYS Error Codes"): Boolean
    begin
        exit(GetIncoTerms());
    end;
    #endregion
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSTranssmartSetup: Record "IDYS Setup";
        IDYMJSONHelper: Codeunit "IDYM Json Helper";
        IDYSAPIHelper: Codeunit "IDYS API Helper";
        CurrentProviderCarrierList: List of [Guid];
        CurrentProviderBookingProfileList: List of [Guid];
        CurrentIDYSCostCenterList: List of [Guid];
        CurrentIDYSEMailTypeList: List of [Guid];
        CurrentServiceLevelsTimeList: List of [Guid];
        CurrentIDYSServiceLevelOtherList: List of [Guid];
        CurrentIDYSProviderPackageTypeList: List of [Guid];
        SetupLoaded: Boolean;
        ProviderSetupLoaded: Boolean;
        MockGetCarriersResponseTxt: Label '[{"value":"{\"code\":\"EEX\",\"name\":\"DHL Europlus\",\"locationSelect\":true,\"needsManifesting\":true}","nr":1},{"value":"{\"code\":\"UPS\",\"name\":\"United Parcel Service\",\"locationSelect\":true,\"needsManifesting\":false}","nr":2}]', Locked = true;
        MockGetBookingProfilesTxt: Label '[{"value":"{\"code\":\"EEX1\",\"description\":\"EEX Europlus\",\"carrier\":\"EEX\",\"serviceLevelTime\":\"EUROPLUS\",\"serviceLevelOther\":\"\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":1},{"value":"{\"code\":\"EEX2\",\"description\":\"EEX Expresser\",\"carrier\":\"EEX\",\"serviceLevelTime\":\"EXPRESSER\",\"serviceLevelOther\":\"\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":2},{"value":"{\"code\":\"EEX3\",\"description\":\"EEX Expresser COD\",\"carrier\":\"EEX\",\"serviceLevelTime\":\"EXPRESSER\",\"serviceLevelOther\":\"COD\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":3},{"value":"{\"code\":\"EEX4\",\"description\":\"EEX Expresser SAT\",\"carrier\":\"EEX\",\"serviceLevelTime\":\"EXPRESSER\",\"serviceLevelOther\":\"SAT\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":4},{"value":"{\"code\":\"EEX5\",\"description\":\"EEX Europlus COD\",\"carrier\":\"EEX\",\"serviceLevelTime\":\"EUROPLUS\",\"serviceLevelOther\":\"COD\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":5},{"value":"{\"code\":\"EEX6\",\"description\":\"EEX Europlus SAT\",\"carrier\":\"EEX\",\"serviceLevelTime\":\"EUROPLUS\",\"serviceLevelOther\":\"SAT\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":6},{"value":"{\"code\":\"UPS1\",\"description\":\"UPS standard\",\"carrier\":\"UPS\",\"serviceLevelTime\":\"STANDARD\",\"serviceLevelOther\":\"SAT\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":7},{"value":"{\"code\":\"UPS2\",\"description\":\"UPS saver\",\"carrier\":\"UPS\",\"serviceLevelTime\":\"SAVER\",\"serviceLevelOther\":\"SAT\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":8},{"value":"{\"code\":\"UPS3\",\"description\":\"UPS expresser\",\"carrier\":\"UPS\",\"serviceLevelTime\":\"EXPRESS\",\"serviceLevelOther\":\"SAT\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":9},{"value":"{\"code\":\"UPS4\",\"description\":\"UPS expedited\",\"carrier\":\"UPS\",\"serviceLevelTime\":\"EXPEDITED\",\"serviceLevelOther\":\"SAT\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":10},{"value":"{\"code\":\"UPS5\",\"description\":\"UPS expedited- Electronic Retur Label\",\"carrier\":\"UPS\",\"serviceLevelTime\":\"EXPEDITED\",\"serviceLevelOther\":\"ERL\",\"incoterms\":\"\",\"costCenter\":\"\",\"mailType\":\"\"}","nr":11}]', Locked = true;
        MockGetServiceLevelsTimesTxt: Label '[{"value":"{\"code\":\"EUROPLUS\",\"description\":\"Europlus\",\"isDefault\":true}","nr":1},{"value":"{\"code\":\"EXPRESSER\",\"description\":\"EXPRESSER\",\"isDefault\":false}","nr":2},{"value":"{\"code\":\"STANDARD\",\"description\":\"\",\"isDefault\":false}","nr":3},{"value":"{\"code\":\"SAVER\",\"description\":\"\",\"isDefault\":false}","nr":4},{"value":"{\"code\":\"EXPRESS\",\"description\":\"\",\"isDefault\":false}","nr":5},{"value":"{\"code\":\"EXPEDITED\",\"description\":\"\",\"isDefault\":false}","nr":6}]', Locked = true;
        MockGetServiceLevelsOthersTxt: Label '[{"value":"{\"code\":\"SAT\",\"description\":\"Zaterdag levering\",\"isDefault\":false}","nr":1},{"value":"{\"code\":\"COD\",\"description\":\"Rembours zending\",\"isDefault\":false}","nr":2},{"value":"{\"code\":\"ERL\",\"description\":\"Electronisch retour Label ( mail naar verzender)\",\"isDefault\":false}","nr":3},{"value":"{\"code\":\"PRL\",\"description\":\"Print Retour Label\",\"isDefault\":false}","nr":4}]', Locked = true;
        MockGetCostCentersResponseTxt: Label '[{"value":"{\"code\":\"DEFAULT\",\"description\":\"Default Cost Center\",\"isDefault\":false}","nr":1}]', Locked = true;
        MockGetEMailTypesResponseTxt: Label '[{"value":"{\"code\":\"1\",\"description\":\"Default mail\",\"isDefault\":true}","nr":-1}]', Locked = true;
        MockGetPackageTypesTxt: Label '[{"value":"{\"code\":\"EUROPALLET\",\"description\":\"Europallet\",\"isDefault\":false,\"type\":\"EUROPALLET\",\"linearUom\":\"CM\",\"massUom\":\"KG\",\"length\":\"120\",\"width\":\"120\",\"height\":\"120\",\"weight\":\"20\"}","nr":1},{"value":"{\"code\":\"BOX\",\"description\":\"Box\",\"isDefault\":false,\"type\":\"BOX\",\"linearUom\":\"CM\",\"massUom\":\"KG\",\"length\":\"30\",\"width\":\"30\",\"height\":\"30\",\"weight\":1}","nr":2}]', Locked = true;
        MockGetIncoTermsTxt: Label '[{"value":"{\"code\":\"EXW\",\"description\":\"Ex Works\",\"isDefault\":false}","nr":-1},{"value":"{\"code\":\"FCA\",\"description\":\"Free Carrier\",\"isDefault\":false}","nr":-1},{"value":"{\"code\":\"CPT\",\"description\":\"Carriage Paid To\",\"isDefault\":false}","nr":-1},{"value":"{\"code\":\"CIP\",\"description\":\"Carriage and Insurance Paid To\",\"isDefault\":false}","nr":-1},{"value":"{\"code\":\"DAT\",\"description\":\"Delivered At Terminal\",\"isDefault\":false}","nr":-1},{"value":"{\"code\":\"DAP\",\"description\":\"Delivered At Place\",\"isDefault\":true}","nr":-1},{"value":"{\"code\":\"DDP\",\"description\":\"Delivered Duty Paid\",\"isDefault\":false}","nr":-1},{"value":"{\"code\":\"FAS\",\"description\":\"Free Alongside Ship\",\"isDefault\":false}","nr":-1},{"value":"{\"code\":\"FOB\",\"description\":\"Free On Board\",\"isDefault\":false}","nr":-1},{"value":"{\"code\":\"CFR\",\"description\":\"Cost and Freight\",\"isDefault\":false}","nr":-1},{"value":"{\"code\":\"CIF\",\"description\":\"Cost, Insurance and Freight\",\"isDefault\":false}","nr":-1}]', Locked = true;
        API: Enum "IDYS API";
        ErrorMessage: Text;
}