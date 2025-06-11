codeunit 11147693 "IDYS API Helper"
{
    procedure ExecuteGet(Path: Text; ExpectArray: Boolean; IDYSSetup: Record "IDYS Setup"; var TempIDYMRESTParameters: Record "IDYM REST Parameters"; API: Enum "IDYS API"): Boolean
    begin
        if IDYSSetup."Unit Test Mode" then
            exit(true);
        LoadSetup();

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Path := CopyStr(Path, 1, 250);
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;

        Execute(TempIDYMRESTParameters, API, "IDYM Endpoint Usage"::Default);
        if TempIDYMRESTParameters."Status Code" <> 200 then
            exit(false);

        exit(true);
    end;

    procedure ExecutePost(Path: Text; ExpectArray: Boolean; var TempIDYMRESTParameters: Record "IDYM REST Parameters"; API: Enum "IDYS API")
    var
        Response: JsonToken;
    begin
        LoadSetup();
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Path := CopyStr(Path, 1, 250);
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;

        if TempIDYMRESTParameters.HasRequestContent() then
            if IDYSSessionVariables.CheckAuthorization() then
                OnBeforeExecutePostRequest(TempIDYMRESTParameters);
        Execute(TempIDYMRESTParameters, API, "IDYM Endpoint Usage"::Default);

        if ExpectArray and (TempIDYMRESTParameters."Status Code" = 200) then begin
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();
            if not Response.IsArray() then
                Error('Unexpected response from the nShift Transsmart API V2. The response was not an array.');
        end;
    end;

    procedure ExecuteDelete(Path: Text; var TempIDYMRESTParameters: Record "IDYM REST Parameters"; API: Enum "IDYS API")
    begin
        LoadSetup();
        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Path := CopyStr(Path, 1, 250);
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::DELETE;
        Execute(TempIDYMRESTParameters, API, "IDYM Endpoint Usage"::Default);
    end;

    local procedure Execute(var TempIDYMRESTParameters: Record "IDYM REST Parameters"; API: Enum "IDYS API"; Usage: Enum "IDYM Endpoint Usage") StatusCode: Integer
    begin
        if API = API::Transsmart then begin
            TempIDYMRESTParameters."Acceptance Environment" := IDYSTranssmartSetup."Transsmart Environment" = IDYSTranssmartSetup."Transsmart Environment"::Acceptance;
            GetUserSetup();
            TempIDYMRESTParameters."Sub Type" := TempIDYMRESTParameters."Sub Type"::Username;
            TempIDYMRESTParameters."Sub No." := IDYSUserSetup."User ID";
            StatusCode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Transsmart, Usage);
        end;
        if API = API::idynFunctions then
            StatusCode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::IdynFunctions, Usage);
    end;

    #Region BearerToken
    procedure Authenticate()
    begin
        GetUserSetup();
        IDYMHTTPHelper.Authenticate("IDYM Endpoint Service"::Transsmart, "IDYM Endpoint Usage"::Default, "IDYM Endpoint Sub Type"::Username, IDYSUserSetup."User ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYM HTTP Helper", 'OnGetSubBearerToken', '', true, false)]
    local procedure OnGetBearerToken(EndpointSubSetting: Record "IDYM Endpoint Sub Setting"; var BearerToken: Text; var ExpiryInMS: Integer)
    var
        Endpoint: Record "IDYM Endpoint";
    begin
        if EndpointSubSetting.Service <> EndpointSubSetting.Service::Transsmart then
            exit;
        Endpoint.Get(EndpointSubSetting.Service, EndpointSubSetting.Usage);
        if Endpoint."Authorization Type" <> Endpoint."Authorization Type"::Bearer then
            exit;
        GetBearerToken(BearerToken, ExpiryInMS);
    end;

    [NonDebuggable]
    local procedure GetBearerToken(var BearerToken: Text; var ExpiryInMS: Integer) StatusCode: Integer
    var
        TempIDYMRestParameters: Record "IDYM REST Parameters" temporary;
    begin
        LoadSetup();
        ExpiryInMS := 3600;
        if GlobalIDYSSetup."Unit Test Mode" then begin
            BearerToken := 'mock.token.forunittesting';
            exit;
        end;
        StatusCode := Execute(TempIDYMRestParameters, "IDYS API"::Transsmart, "IDYM Endpoint Usage"::GetToken);
        ProcessBearerTokenResponse(TempIDYMRestParameters, BearerToken);
    end;

    [NonDebuggable]
    local procedure ProcessBearerTokenResponse(var TempIDYMRestParameters: Record "IDYM REST Parameters" temporary; var BearerToken: Text): Boolean
    var
        Response: JsonToken;
        BearerTokenErr: Label 'Retrieving the Bearer token failed with HTTP Status %1', Comment = '%1 = HTTP Status Code';
    begin
        if TempIDYMRestParameters."Status Code" <> 200 then
            Error(BearerTokenErr, TempIDYMRestParameters."Status Code");
        if TempIDYMRESTParameters.HasResponseContent() then begin
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON();
            BearerToken := IDYMJSONHelper.GetTextValue(Response.AsObject(), 'token');
        end;
        exit(true);
    end;
    #EndRegion

    local procedure LoadSetup()
    begin
        IDYSTranssmartSetup.GetProviderSetup("IDYS Provider"::Transsmart);
        GlobalIDYSSetup.Get();
    end;

    local procedure GetUserSetup()
    var
        DefaultUserNotFoundErr: Label 'No %1 user could be found in %2. Please specify your user specific credentials or assign a %1 user.', Comment = '%1 = default, %2 = User Setup';
    begin
        if not IDYSUserSetup.Get(UserId()) then begin
            IDYSUserSetup.SetRange(Default, true);
            if not IDYSUserSetup.FindFirst() then
                Error(DefaultUserNotFoundErr, IDYSUserSetup.FieldCaption(Default), IDYSUserSetup.TableCaption);
        end;
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYM HTTP Helper", 'OnGetBearerToken', '', true, false)]
    local procedure IDYMHTTPHelper_OnGetBearerToken_IdynAnalytics(Endpoint: Record "IDYM Endpoint"; var BearerToken: Text; var ExpiryInMS: Integer)
    var
        IdynAnalyticsTok: Label 'qVqYeDHZqjqEvxNC5NuOKFiEtxI0P2XAKgULAKz942UX8UP$##X$PzT8csuDA', Locked = true;
    begin
        // This should be moved to the app management with the next iteration
        if Endpoint.Service <> Endpoint.Service::IdynAnalytics then
            exit;
        if Endpoint."Authorization Type" <> Endpoint."Authorization Type"::Bearer then
            exit;
        BearerToken := IdynAnalyticsTok;
    end;

    [NonDebuggable]
    procedure SyncTransportOrders()
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        RequestObject: JsonObject;
        LastSequenceNo: Integer;
        IsHandled: Boolean;
        Usage: Enum "IDYM Endpoint Usage";
        StatusCode: Integer;
        DatasetSize: Integer;
        EndpointTxt: Label '/Analytics', Locked = true;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeSyncTransportOrders(IsHandled);
            if IsHandled then
                exit;
        end;

        LoadSetup();
        if not IDYMAppLicenseKey.Get(GlobalIDYSSetup."License Entry No.") then
            exit;

        // Unsent Count Check
        DatasetSize := GlobalIDYSSetup."Dataset Size";
        if DatasetSize = 0 then
            DatasetSize := 100;

        if not IsSyncRequired(DatasetSize) then
            exit;

        // Build the request document
        BuildAppData(RequestObject);
        BuildSetupData(RequestObject);
        BuildTransportOrderData(RequestObject, DatasetSize, LastSequenceNo);

        // Synchronize
        if LastSequenceNo > GlobalIDYSSetup."Last Used Sequence No." then begin
            TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::POST;
            TempIDYMRESTParameters.Path := EndpointTxt;
            TempIDYMRESTParameters.SetRequestContent(RequestObject);
            StatusCode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::IdynAnalytics, Usage::Default);
            if StatusCode = 200 then
                GlobalIDYSSetup."Last Used Sequence No." := LastSequenceNo;
        end;

        GlobalIDYSSetup."Next Sync Date" := CalcDate('<+1M>', Today());
        GlobalIDYSSetup.Modify();
    end;

    [NonDebuggable]
    local procedure BuildAppData(var RequestObject: JsonObject)
    var
        Company: Record Company;
        EnvironmentInformation: Codeunit "Environment Information";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        IDYMJSONHelper.AddValue(RequestObject, 'appId', DelChr(Format(AppInfo.Id), '<>', '{}'));
        IDYMJSONHelper.AddValue(RequestObject, 'appVersion', Format(AppInfo.AppVersion));
        IDYMJSONHelper.AddValue(RequestObject, 'appLicenseKey', IDYMAppLicenseKey."License Key");
        IDYMJSONHelper.AddValue(RequestObject, 'isProduction', EnvironmentInformation.IsProduction());
        IDYMJSONHelper.AddValue(RequestObject, 'isSandbox', EnvironmentInformation.IsSandbox());
        if Company.Get(CompanyName()) then
            IDYMJSONHelper.AddValue(RequestObject, 'isEvaluationCompany', Company."Evaluation Company");
    end;

    [NonDebuggable]
    local procedure BuildSetupData(var RequestObject: JsonObject)
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSSetup2: Record "IDYS Setup";
        IDYSProviderSetup: Record "IDYS Provider Setup";
        SetupObject: JsonObject;
        ProviderSetupRecord: JsonObject;
        ProviderSetupRecords: JsonArray;
    begin
        if not IDYSSetup.Get() then
            exit;

        // Setup Data
        IDYMJSONHelper.AddValue(SetupObject, 'shippingCostSurchargePct', IDYSSetup."Shipping Cost Surcharge (%)");
        IDYMJSONHelper.AddValue(SetupObject, 'autoAddOneDefaultPackage', IDYSSetup."Auto. Add One Default Package");
        IDYMJSONHelper.AddValue(SetupObject, 'pickUptimeFrom', IDYSSetup."Pick-up Time From");
        IDYMJSONHelper.AddValue(SetupObject, 'pickUpFromDT', IDYSSetup."Pick-up From DT");
        IDYMJSONHelper.AddValue(SetupObject, 'pickUpTimeTo', IDYSSetup."Pick-up Time To");
        IDYMJSONHelper.AddValue(SetupObject, 'pickUpToDT', IDYSSetup."Pick-up To DT");
        IDYMJSONHelper.AddValue(SetupObject, 'deliveryTimeFrom', IDYSSetup."Delivery Time From");
        IDYMJSONHelper.AddValue(SetupObject, 'deliveryFromDT', IDYSSetup."Delivery From DT");
        IDYMJSONHelper.AddValue(SetupObject, 'deliveryTimeTo', IDYSSetup."Delivery Time To");
        IDYMJSONHelper.AddValue(SetupObject, 'deliveryToDT', IDYSSetup."Delivery To DT");
        IDYMJSONHelper.AddValue(SetupObject, 'baseTransportOrdersOn', IDYSSetup."Base Transport Orders on");
        IDYMJSONHelper.AddValue(SetupObject, 'afterPostingSalesOrders', IDYSSetup."After Posting Sales Orders");
        IDYMJSONHelper.AddValue(SetupObject, 'afterPostingPurchRetOrd', IDYSSetup."After Posting Purch. Ret. Ord.");
        IDYMJSONHelper.AddValue(SetupObject, 'afterPostingServiceOrders', IDYSSetup."After Posting Service Orders");
        IDYMJSONHelper.AddValue(SetupObject, 'afterPostingTransferOrders', IDYSSetup."After Posting Transfer Orders");
        IDYMJSONHelper.AddValue(SetupObject, 'basePreferredDateOn', IDYSSetup."Base Preferred Date on");
        IDYMJSONHelper.AddValue(SetupObject, 'alwaysNewTrnsOrder', IDYSSetup."Always New Trns. Order");
        IDYMJSONHelper.AddValue(SetupObject, 'enableDebugMode', IDYSSetup."Enable Debug Mode");
        IDYMJSONHelper.AddValue(SetupObject, 'addressForInvoiceAddress', IDYSSetup."Address for Invoice Address");
        IDYMJSONHelper.AddValue(SetupObject, 'loggingLevel', IDYSSetup."Logging Level".AsInteger());
        IDYMJSONHelper.AddValue(SetupObject, 'defaultShipToCountry', IDYSSetup."default Ship-to Country");
        IDYMJSONHelper.AddValue(SetupObject, 'backgroundBooking', IDYSSetup."Background Booking");
        IDYMJSONHelper.AddValue(SetupObject, 'addDeliveryNotes', IDYSSetup."Add Delivery Notes");
        IDYMJSONHelper.AddValue(SetupObject, 'retentionPeriodDays', IDYSSetup."Retention Period (Days)");
        IDYMJSONHelper.AddValue(SetupObject, 'allowAllItemTypes', IDYSSetup."Allow All Item Types");
        IDYMJSONHelper.AddValue(SetupObject, 'removeAttachmentsOnArch', IDYSSetup."Remove Attachments on Arch.");
        IDYMJSONHelper.AddValue(SetupObject, 'skipSourceDocsUpdAfterTO', IDYSSetup."Skip Source Docs Upd after TO");
        IDYMJSONHelper.AddValue(SetupObject, 'copyShipAgentToWhseDocs', IDYSSetup."Copy Ship. Agent to Whse-Docs");
        IDYMJSONHelper.AddValue(SetupObject, 'noTOCreatedNotification', IDYSSetup."No TO Created Notification");
        IDYMJSONHelper.AddValue(SetupObject, 'linkDelLinesWithPackages', IDYSSetup."Link Del. Lines with Packages");
        IDYMJSONHelper.AddValue(SetupObject, 'skipSourceDocsPackages', IDYSSetup."Skip Source Doc. Packages");
        IDYMJSONHelper.AddValue(SetupObject, 'enableBetaFeatures', IDYSSetup."Enable Beta features");


        // Provider Specific Setup data
        IDYSProviderSetup.SetRange(Enabled, true);
        if IDYSProviderSetup.FindSet() then begin
            repeat
                Clear(ProviderSetupRecord);
                IDYSSetup2.GetProviderSetup(IDYSProviderSetup.Provider);

                case IDYSProviderSetup.Provider of
                    IDYSProviderSetup.Provider::Transsmart:
                        begin
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'primaryKey', IDYSSetup2."Primary Key");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'environment', IDYSSetup2."Transsmart Environment");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'defaultProviderPackageType', IDYSSetup2."Default Provider Package Type");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'defaultEmailType', IDYSSetup2."Default E-Mail Type");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'defaultCostCenter', IDYSSetup2."Default Cost Center");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'enableInsurance', IDYSSetup2."Enable Insurance");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'enableMinShipmentAmount', IDYSSetup2."Enable Min. Shipment Amount");
                        end;
                    IDYSProviderSetup.Provider::"Delivery Hub":
                        begin
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'primaryKey', IDYSSetup2."Primary Key");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'environment', IDYSSetup2."Transsmart Environment");
                        end;
                    IDYSProviderSetup.Provider::Sendcloud:
                        begin
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'primaryKey', IDYSSetup2."Primary Key");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'autSelectApplShipMethod', IDYSSetup2."Aut. Select Appl. Ship. Method");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'enablePrintITPrinting', IDYSSetup2."Enable PrintIT Printing");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'labelType', IDYSSetup2."Label Type".AsInteger());
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'requestLabel', IDYSSetup2."Request Label");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'applyShippingRules', IDYSSetup2."Apply Shipping Rules");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'applyExternalDocumentNo', IDYSSetup2."Apply External Document No.");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'defaultProviderPackageType', IDYSSetup2."Default Provider Package Type");
                        end;
                    IDYSProviderSetup.Provider::EasyPost:
                        begin
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'primaryKey', IDYSSetup2."Primary Key");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'autSelectApplShipMethod', IDYSSetup2."Aut. Select Appl. Ship. Method");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'enablePrintITPrinting', IDYSSetup2."Enable PrintIT Printing");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'defaultLabelType', IDYSSetup2."Default Label Type".AsInteger());
                        end;
                    IDYSProviderSetup.Provider::Cargoson:
                        begin
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'primaryKey', IDYSSetup2."Primary Key");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'environment', IDYSSetup2."Transsmart Environment");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'defaultProviderPackageType', IDYSSetup2."Default Provider Package Type");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'enablePrintITPrinting', IDYSSetup2."Enable PrintIT Printing");
                            IDYMJSONHelper.AddValue(ProviderSetupRecord, 'labelFormat', IDYSSetup2."Label Format".AsInteger());
                        end;
                end;
                IDYMJSONHelper.Add(ProviderSetupRecords, ProviderSetupRecord);
            until IDYSProviderSetup.Next() = 0;
            IDYMJSONHelper.Add(SetupObject, 'enabledProviders', ProviderSetupRecords);
        end;

        IDYMJSONHelper.Add(RequestObject, 'setup', SetupObject);
    end;

    [NonDebuggable]
    local procedure BuildTransportOrderData(var RequestObject: JsonObject; DatasetSize: Integer; var LastSequenceNo: Integer)
    var
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        MassCaption: Text;
        DistanceCaption: Text;
        VolumeCaption: Text;
        TransportOrder: JsonObject;
        TransportOrders: JsonArray;
        TransportOrderPackage: JsonObject;
        TransportOrderPackages: JsonArray;
        PackageWeight: Decimal;
        TotalWeight: Decimal;
        SyncFromSequenceNo: Integer;
    begin
        // App specific data
        IDYSTransportOrderHeader.SetCurrentKey("Sequence No.");
        SyncFromSequenceNo := GlobalIDYSSetup."Last Used Sequence No." + 1;
        IDYSTransportOrderHeader.SetFilter("Sequence No.", '%1..%2', SyncFromSequenceNo, SyncFromSequenceNo + DatasetSize);
        IDYSTransportOrderHeader.SetLoadFields("Sequence No.", Provider, "No. (Pick-up)", "Name (Pick-up)", "Preferred Pick-up Date", "Country/Region Code (Pick-up)", "City (Pick-up)", "Post Code (Pick-up)",
                                                 "Preferred Delivery Date", "Country/Region Code (Ship-to)", "City (Ship-to)", "Post Code (Ship-to)", "Shipment Method Code", "Shipmt. Value", "Shipmt. Cost", Description, Status);
        IDYSTransportOrderHeader.SetAutoCalcFields("Carrier Name", "Booking Profile Description", "Total Count of Packages", "Total Volume", "Calculated Shipment Value");
        if IDYSTransportOrderHeader.FindSet() then
            repeat
                Clear(TransportOrderPackages);
                Clear(TotalWeight);
                IDYSProviderMgt.GetMeasurementCaptions(IDYSTransportOrderHeader.Provider, DistanceCaption, VolumeCaption, MassCaption);

                IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
                IDYSTransportOrderPackage.SetLoadFields("Provider Package Type Code", Description, Length, Width, Height, Volume, Status, "Actual Weight");
                if IDYSTransportOrderPackage.FindSet() then
                    repeat
                        Clear(TransportOrderPackage);
                        PackageWeight := IDYSTransportOrderPackage.GetPackageWeight();
                        TotalWeight += PackageWeight;
                        IDYMJSONHelper.AddValue(TransportOrderPackage, 'packageType', IDYSTransportOrderPackage."Provider Package Type Code");
                        IDYMJSONHelper.AddValue(TransportOrderPackage, 'packageTypeDescription', IDYSTransportOrderPackage.Description);
                        IDYMJSONHelper.AddValue(TransportOrderPackage, 'length', IDYSTransportOrderPackage.Length);
                        IDYMJSONHelper.AddValue(TransportOrderPackage, 'width', IDYSTransportOrderPackage.Width);
                        IDYMJSONHelper.AddValue(TransportOrderPackage, 'height', IDYSTransportOrderPackage.Height);
                        IDYMJSONHelper.AddValue(TransportOrderPackage, 'grossWeight', PackageWeight);
                        IDYMJSONHelper.AddValue(TransportOrderPackage, 'weightUOM', MassCaption);
                        IDYMJSONHelper.AddValue(TransportOrderPackage, 'volume', IDYSTransportOrderPackage.Volume);
                        IDYMJSONHelper.AddValue(TransportOrderPackage, 'volumeUOM', VolumeCaption);
                        IDYMJSONHelper.AddValue(TransportOrderPackage, 'status', IDYSTransportOrderPackage.Status);
                        IDYMJSONHelper.Add(TransportOrderPackages, TransportOrderPackage);
                    until IDYSTransportOrderPackage.Next() = 0;

                TotalWeight += IDYSTransportOrderHeader.GetCalculatedWeightForUnassignedLines();

                Clear(TransportOrder);
                IDYMJSONHelper.AddValue(TransportOrder, 'provider', "IDYS Provider".Names().Get("IDYS Provider".Ordinals().IndexOf(IDYSTransportOrderHeader.Provider.AsInteger())));
                IDYMJSONHelper.AddValue(TransportOrder, 'no', IDYSTransportOrderHeader."No.");
                IDYMJSONHelper.AddValue(TransportOrder, 'carrierName', IDYSTransportOrderHeader."Carrier Name");
                IDYMJSONHelper.AddValue(TransportOrder, 'carrierService', IDYSTransportOrderHeader."Booking Profile Description");
                IDYMJSONHelper.AddValue(TransportOrder, 'pickUpCode', IDYSTransportOrderHeader."No. (Pick-up)");
                IDYMJSONHelper.AddValue(TransportOrder, 'pickUpName', IDYSTransportOrderHeader."Name (Pick-up)");
                IDYMJSONHelper.AddValue(TransportOrder, 'pickUpDate', IDYSTransportOrderHeader."Preferred Pick-up Date");
                IDYMJSONHelper.AddValue(TransportOrder, 'pickUpCountry', IDYSTransportOrderHeader."Country/Region Code (Pick-up)");
                IDYMJSONHelper.AddValue(TransportOrder, 'pickUpCity', IDYSTransportOrderHeader."City (Pick-up)");
                IDYMJSONHelper.AddValue(TransportOrder, 'pickUpPostCode', IDYSTransportOrderHeader."Post Code (Pick-up)");
                IDYMJSONHelper.AddValue(TransportOrder, 'deliveryDate', IDYSTransportOrderHeader."Preferred Delivery Date");
                IDYMJSONHelper.AddValue(TransportOrder, 'shipToCountry', IDYSTransportOrderHeader."Country/Region Code (Ship-to)");
                IDYMJSONHelper.AddValue(TransportOrder, 'shipToCity', IDYSTransportOrderHeader."City (Ship-to)");
                IDYMJSONHelper.AddValue(TransportOrder, 'shipToPostCode', IDYSTransportOrderHeader."Post Code (Ship-to)");
                IDYMJSONHelper.AddValue(TransportOrder, 'shipmentMethod', IDYSTransportOrderHeader."Shipment Method Code");
                IDYMJSONHelper.AddValue(TransportOrder, 'noOfPackages', IDYSTransportOrderHeader."Total Count of Packages");
                IDYMJSONHelper.AddValue(TransportOrder, 'totalVolume', IDYSTransportOrderHeader."Total Volume");
                IDYMJSONHelper.AddValue(TransportOrder, 'totalWeight', TotalWeight);
                IDYMJSONHelper.AddValue(TransportOrder, 'shipmentValue', IDYSTransportOrderHeader."Calculated Shipment Value");
                IDYMJSONHelper.AddValue(TransportOrder, 'shipmentValueActual', IDYSTransportOrderHeader."Shipmt. Value");
                IDYMJSONHelper.AddValue(TransportOrder, 'shipmentCost', IDYSTransportOrderHeader."Shipmt. Cost");
                IDYMJSONHelper.AddValue(TransportOrder, 'description', IDYSTransportOrderHeader.Description);
                IDYMJSONHelper.AddValue(TransportOrder, 'status', IDYSTransportOrderHeader.Status);
                // Add packages to the order
                IDYMJSONHelper.Add(TransportOrder, 'packages', TransportOrderPackages);
                IDYMJSONHelper.Add(TransportOrders, TransportOrder);
            until IDYSTransportOrderHeader.Next() = 0;

        LastSequenceNo := IDYSTransportOrderHeader."Sequence No.";
        IDYMJSONHelper.Add(RequestObject, 'orders', TransportOrders);
    end;

    [NonDebuggable]
    local procedure IsSyncRequired(DataSetSize: Integer): Boolean
    var
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        // Next Sync Date Check
        if Today() >= GlobalIDYSSetup."Next Sync Date" then
            exit(true);

        IDYSTransportOrderHeader.SetCurrentKey("Sequence No.");
        IDYSTransportOrderHeader.SetFilter("Sequence No.", '%1..', GlobalIDYSSetup."Last Used Sequence No." + 1);
        if IDYSTransportOrderHeader.Count() >= DatasetSize then
            exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExecutePostRequest(var TempIDYMRESTParameters: Record "IDYM REST Parameters")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSyncTransportOrders(var IsHandled: Boolean)
    begin
    end;

    #region [Obsolete]
    [Obsolete('Removed ErrorCode', '25.0')]
    procedure ExecuteGet(Path: Text; ExpectArray: Boolean; IDYSSetup: Record "IDYS Setup"; var TempIDYMRESTParameters: Record "IDYM REST Parameters"; var ErrorCode: Enum "IDYS Error Codes"; API: Enum "IDYS API"): Boolean
    begin
        exit(ExecuteGet(Path, ExpectArray, IDYSSetup, TempIDYMRESTParameters, API));
    end;

    [Obsolete('Authorization is now associated with the license key', '23.0')]
    [NonDebuggable]
    local procedure CheckAuthorization(Authorization: Guid)
    begin
    end;

    [Obsolete('Authorization is now associated with the license key', '23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeExecutePostSetAuthorization(var AuthorizationGuid: Guid)
    begin
    end;

    [Obsolete('Replaced with OnBeforeExecutePostRequest()', '23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeExecutePost(var TempIDYMRESTParameters: Record "IDYM REST Parameters"; var RequestJsonArray: JsonArray)
    begin
    end;
    #endregion

    var
        GlobalIDYSSetup: Record "IDYS Setup";
        IDYSTranssmartSetup: Record "IDYS Setup";
        IDYSUserSetup: Record "IDYS User Setup";
        IDYMAppLicenseKey: Record "IDYM App License Key";
        IDYMHTTPHelper: Codeunit "IDYM HTTP Helper";
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
}