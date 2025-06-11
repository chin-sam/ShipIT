codeunit 11147714 "IDYS DelHub Provider" implements "IDYS IProvider"
{
    procedure SetupWizardPage(): Integer
    begin
        exit(0);
    end;

    procedure SetupPage(): Integer
    begin
        exit(Page::"IDYS Delivery Hub Setup");
    end;

    procedure GetMasterData(ShowNotifications: Boolean): Boolean
    var
        IDYSDelHubMDataMgt: Codeunit "IDYS DelHub M. Data Mgt.";
    begin
        exit(IDYSDelHubMDataMgt.UpdateMasterData(ShowNotifications));
    end;

    procedure OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    var
    begin
        IDYSDelHubAPIDocsMgt.OpenInDashboard(TransportOrderHeader);
    end;

    procedure OpenAllInDashboard();
    var
    begin
        IDYSDelHubAPIDocsMgt.OpenAllInDashboard();
    end;

    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, AllowLogging));
    end;

    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    procedure HandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject): Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.HandleResponseAfterBooking(IDYSTransportOrderHeader, RequestDocument, ResponseDocument))
    end;

    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") Printed: Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.DoLabel(IDYSTransportOrderHeader));
    end;

    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Response: JsonToken) Printed: Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    begin
        IDYSDelHubAPIDocsMgt.HandleResponseAfterPrinting(IDYSTransportOrderHeader, Response);
    end;

    procedure IsBookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.IsBookable(IDYSTransportOrderHeader));
    end;

    procedure IsRebookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.IsRebookable(IDYSTransportOrderHeader));
    end;

    procedure DeleteAllowed(): Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.DeleteAllowed());
    end;

    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean): JsonObject
    begin
        exit(IDYSDelHubAPIDocsMgt.GetShipmentAdditionalInformation(IDYSTransportOrderHeader, false, true));
    end;

    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    begin
        exit(IDYSDelHubAPIDocsMgt.InitCarrierSelection(TempIDYSTransportOrderHeader, SalesHeader, IDYSProviderCarrierSelect));
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    begin
        exit(IDYSDelHubAPIDocsMgt.InitSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect));
    end;

    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray);
    begin
        IDYSDelHubAPIDocsMgt.SelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents);
    end;

    procedure DoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSDelHubAPIDocsMgt.DoDelete(IDYSTransportOrderHeader);
    end;

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSDelHubAPIDocsMgt.ValidateTransportOrder(IDYSTransportOrderHeader);
    end;

    procedure UpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        IDYSDelHubAPIDocsMgt.UpdateStatus(IDYSTransportOrderHeader);
    end;

    procedure IsEnabled(ThrowError: Boolean) Enabled: Boolean;
    begin
        Enabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::"Delivery Hub", ThrowError);
    end;

    procedure GetDefaultPackage(CarrierEntryNoFilter: Integer; BookingProfileEntryNoFilter: Integer) PackageTypeCode: Code[50]
    var
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
    begin
        // to avoid triggering default package insertion on multiple occasions
        if (CarrierEntryNoFilter = 0) or (BookingProfileEntryNoFilter = 0) then
            exit;

        IDYSBookingProfPackageType.SetRange("Carrier Entry No.", CarrierEntryNoFilter);
        IDYSBookingProfPackageType.SetRange("Booking Profile Entry No.", BookingProfileEntryNoFilter);
        IDYSBookingProfPackageType.SetRange(Default, true);
        if IDYSBookingProfPackageType.FindLast() then
            exit(IDYSBookingProfPackageType."Package Type Code");
    end;

    procedure GetMeasurementCaptions(var DistanceCaption: Text; var VolumeCaption: Text; var MassCaption: Text)
    begin
        DistanceCaption := DistanceMeasureLbl;
        VolumeCaption := VolumeMeasureLbl;
        MassCaption := MassMeasureLbl;
    end;

    procedure VerifySetup(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary)
    begin
        VerifyDeliveryHubMasterData(TempSetupVerificationResultBuffer);
    end;

    local procedure VerifyDeliveryHubMasterData(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary);
    var
        ProviderCarrier: Record "IDYS Provider Carrier";
        ProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSUnitOfMeasureMapping: Record "IDYS Unit of Measure Mapping";
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
        IDYSDelHubAPIServices: Record "IDYS DelHub API Services";
        IDYSVerifySetup: Codeunit "IDYS Verify Setup";
        DelHubMasterDataTxt: Label 'nShift Ship Master Data Tables';
        MasterDataSynchronizedTxt: Label 'The following master data is retrieved from nShift Ship: %1.', Comment = '%1 = Table caption for Master Data';
    begin
        ProviderCarrier.SetRange(Provider, ProviderCarrier.Provider::Transsmart);
        ProviderBookingProfile.SetRange(Provider, ProviderBookingProfile.Provider::Transsmart);
        IDYSServiceLevelOther.SetFilter(ServiceID, '<>%1', 0);

        IDYSVerifySetup.InsertVerificationHeading(TempSetupVerificationResultBuffer, DelHubMasterDataTxt);
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderCarrier.TableCaption()), not ProviderCarrier.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderBookingProfile.TableCaption()), not ProviderBookingProfile.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, IDYSBookingProfPackageType.TableCaption()), not IDYSBookingProfPackageType.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, IDYSUnitOfMeasureMapping.TableCaption()), not IDYSUnitOfMeasureMapping.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, IDYSServiceLevelOther.TableCaption()), not IDYSServiceLevelOther.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, IDYSDelHubAPIServices.TableCaption()), not IDYSDelHubAPIServices.IsEmpty());
    end;

    procedure ProviderCarrierSelectLookup(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select")
    var
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
        IDYSSetup: Record "IDYS Setup";
        IDYSDelHubProvider: Codeunit "IDYS DelHub Provider";
        PackageTypeCode: Code[50];
    begin
        IDYSSetup.Get();

        if not TempProviderCarrierSelect.Mapped then
            Error(CarrierSelectMappedErr, true);

        if not ShipAgentSvcMapping.Get(TempProviderCarrierSelect."Svc. Mapping RecordId") then
            exit;

        TransportOrderHeader.SetSkipPackageValidation(true);
        if ShipAgentSvcMapping."Shipping Agent Code" <> TransportOrderHeader."Shipping Agent Code" then
            TransportOrderHeader.Validate("Shipping Agent Code", ShipAgentSvcMapping."Shipping Agent Code");
        if ShipAgentSvcMapping."Shipping Agent Service Code" <> TransportOrderHeader."Shipping Agent Service Code" then
            TransportOrderHeader.Validate("Shipping Agent Service Code", ShipAgentSvcMapping."Shipping Agent Service Code");

        if TempProviderCarrierSelect."Pickup Date" <> 0D then
            TransportOrderHeader."Preferred Pick-up Date From" := CreateDateTime(TempProviderCarrierSelect."Pickup Date", DT2Time(IDYSSetup."Pick-up From DT"));
        if TempProviderCarrierSelect."Pickup Date" <> 0D then
            TransportOrderHeader."Preferred Pick-up Date To" := CreateDateTime(TempProviderCarrierSelect."Pickup Date", DT2Time(IDYSSetup."Pick-up To DT"));
        if TempProviderCarrierSelect."Delivery Date" <> 0D then
            TransportOrderHeader."Preferred Delivery Date From" := CreateDateTime(TempProviderCarrierSelect."Delivery Date", TempProviderCarrierSelect."Delivery Time");
        if TempProviderCarrierSelect."Delivery Date" <> 0D then
            TransportOrderHeader."Preferred Delivery Date To" := CreateDateTime(TempProviderCarrierSelect."Delivery Date", TempProviderCarrierSelect."Delivery Time");
        // TransportOrderHeader."Service Level Code (Time)" := TempProviderCarrierSelect."Service Level Code (Time)";
        // TransportOrderHeader."Service Level Code (Other)" := TempProviderCarrierSelect."Service Level Code (Other)";
        TransportOrderHeader.Modify();

        // Update services
        ClearSourceDocumentServices(Database::"IDYS Transport Order Header", "IDYS Source Document Type"::"0", TransportOrderHeader."No.");

        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", TempProviderCarrierSelect."Transport Order No.");
        IDYSProvCarrierSelectPck.SetRange("Line No.", TempProviderCarrierSelect."Line No.");
        IDYSProvCarrierSelectPck.SetRange(Include, true);
        if IDYSProvCarrierSelectPck.FindSet() then
            repeat
                UpdateSourceDocumentServices(Database::"IDYS Transport Order Header", "IDYS Source Document Type"::"0", TransportOrderHeader."No.", IDYSProvCarrierSelectPck."Service Level Code (Other)", TransportOrderHeader."Carrier Entry No.", TransportOrderHeader."Booking Profile Entry No.");
            until IDYSProvCarrierSelectPck.Next() = 0;

        // Update packages
        PackageTypeCode := TempProviderCarrierSelect."Package Type Code";
        if PackageTypeCode = '' then
            PackageTypeCode := IDYSDelHubProvider.GetDefaultPackage(TransportOrderHeader."Carrier Entry No.", IDYSProviderMgt.GetBookingProfileEntryNo(TransportOrderHeader."Carrier Entry No.", TransportOrderHeader."Booking Profile Entry No."));

        IDYSTransportOrderPackage.SetRange("Transport Order No.", TransportOrderHeader."No.");
        if IDYSTransportOrderPackage.FindSet(true) then
            repeat
                IDYSBookingProfPackageType.SetRange("Carrier Entry No.", TransportOrderHeader."Carrier Entry No.");
                IDYSBookingProfPackageType.SetRange("Booking Profile Entry No.", IDYSProviderMgt.GetBookingProfileEntryNo(TransportOrderHeader."Carrier Entry No.", TransportOrderHeader."Booking Profile Entry No."));
                IDYSBookingProfPackageType.SetRange("Package Type Code", PackageTypeCode);
                if not IDYSBookingProfPackageType.FindFirst() then
                    IDYSBookingProfPackageType.Init();

                IDYSTransportOrderPackage."Provider Package Type Code" := PackageTypeCode;
                IDYSTransportOrderPackage."Package Type" := CopyStr(IDYSBookingProfPackageType.Description, 1, MaxStrLen(IDYSTransportOrderPackage."Package Type"));
                IDYSTransportOrderPackage."Package Type Description" := Copystr(IDYSBookingProfPackageType.Description, 1, MaxStrLen(IDYSTransportOrderPackage."Package Type Description"));

                IDYSTransportOrderPackage."Book. Prof. Package Type Code" := PackageTypeCode;
                IDYSTransportOrderPackage.Modify(true);
            until IDYSTransportOrderPackage.Next() = 0;
    end;

    procedure ProviderCarrierSelectLookup_SalesHeader(var SalesHeader: Record "Sales Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select")
    var
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
        BookingProfPackageType: Record "IDYS BookingProf. Package Type";
        IDYSDelHubProvider: Codeunit "IDYS DelHub Provider";
        PackageTypeCode: Code[50];
    begin
        if not TempProviderCarrierSelect.Mapped then
            Error(CarrierSelectMappedErr, true);

        if not ShipAgentSvcMapping.Get(TempProviderCarrierSelect."Svc. Mapping RecordId") then
            exit;

        // Modify sales order based on selected carrier
        SalesHeader.IDYSSetSkipPackageValidation(true);
        if ShipAgentSvcMapping."Shipping Agent Code" <> SalesHeader."Shipping Agent Code" then
            SalesHeader.Validate("Shipping Agent Code", ShipAgentSvcMapping."Shipping Agent Code");
        if ShipAgentSvcMapping."Shipping Agent Service Code" <> SalesHeader."Shipping Agent Service Code" then
            SalesHeader.Validate("Shipping Agent Service Code", ShipAgentSvcMapping."Shipping Agent Service Code");
        SalesHeader.Modify();

        // Update services
        ClearSourceDocumentServices(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.");

        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", TempProviderCarrierSelect."Transport Order No.");
        IDYSProvCarrierSelectPck.SetRange("Line No.", TempProviderCarrierSelect."Line No.");
        IDYSProvCarrierSelectPck.SetRange(Include, true);
        if IDYSProvCarrierSelectPck.FindSet() then
            repeat
                UpdateSourceDocumentServices(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", IDYSProvCarrierSelectPck."Service Level Code (Other)", SalesHeader."IDYS Carrier Entry No.", SalesHeader."IDYS Booking Profile Entry No.");
            until IDYSProvCarrierSelectPck.Next() = 0;

        // Update packages
        PackageTypeCode := TempProviderCarrierSelect."Package Type Code";
        if PackageTypeCode = '' then
            PackageTypeCode := IDYSDelHubProvider.GetDefaultPackage(SalesHeader."IDYS Carrier Entry No.", IDYSProviderMgt.GetBookingProfileEntryNo(SalesHeader."IDYS Carrier Entry No.", SalesHeader."IDYS Booking Profile Entry No."));

        IDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        IDYSSourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
        IDYSSourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
        if IDYSSourceDocumentPackage.FindSet(true) then
            repeat
                BookingProfPackageType.SetRange("Carrier Entry No.", SalesHeader."IDYS Carrier Entry No.");
                BookingProfPackageType.SetRange("Booking Profile Entry No.", IDYSProviderMgt.GetBookingProfileEntryNo(SalesHeader."IDYS Carrier Entry No.", SalesHeader."IDYS Booking Profile Entry No."));
                BookingProfPackageType.SetRange("Package Type Code", PackageTypeCode);
                if not BookingProfPackageType.FindFirst() then
                    BookingProfPackageType.Init();

                IDYSSourceDocumentPackage."Provider Package Type Code" := PackageTypeCode;
                IDYSSourceDocumentPackage."Package Type" := CopyStr(BookingProfPackageType.Description, 1, MaxStrLen(IDYSSourceDocumentPackage."Package Type"));
                IDYSSourceDocumentPackage."Package Type Description" := Copystr(BookingProfPackageType.Description, 1, MaxStrLen(IDYSSourceDocumentPackage."Package Type Description"));

                IDYSSourceDocumentPackage."Book. Prof. Package Type Code" := PackageTypeCode;
                IDYSSourceDocumentPackage.Modify(true);
            until IDYSSourceDocumentPackage.Next() = 0;
    end;


    procedure UpdateSourceDocumentServices(SourceTable: Integer; DocumentType: Enum "IDYS Source Document Type"; DocumentNo: Code[20]; ServiceLevelCodeOther: Text[50]; CarrierEntryNo: Integer; BookingProfileEntryNo: Integer)
    var
        IDYSSourceDocumentService: Record "IDYS Source Document Service";
        IDYSServiceLevelOther: Record "IDYS Service Level (Other)";
        IDYSDelHubAPIServices: Record "IDYS DelHub API Services";
    begin
        // Clear group selection
        IDYSServiceLevelOther.Get(ServiceLevelCodeOther);
        if IDYSServiceLevelOther.GroupId <> 0 then begin
            IDYSDelHubAPIServices.SetRange("Carrier Entry No.", CarrierEntryNo);
            IDYSDelHubAPIServices.SetRange("Booking Profile Entry No.", BookingProfileEntryNo);
            IDYSDelHubAPIServices.SetRange(GroupId, IDYSServiceLevelOther.GroupId);
            if IDYSDelHubAPIServices.FindSet() then
                repeat
                    if IDYSSourceDocumentService.Get(SourceTable, DocumentType, DocumentNo, IDYSDelHubAPIServices."Service Level Code (Other)") then
                        IDYSSourceDocumentService.Delete(true);
                until IDYSDelHubAPIServices.Next() = 0;
        end;

        if not IDYSSourceDocumentService.Get(SourceTable, DocumentType, DocumentNo, ServiceLevelCodeOther) then begin
            IDYSSourceDocumentService.Init();
            IDYSSourceDocumentService.Validate("Table No.", SourceTable);
            IDYSSourceDocumentService.Validate("Document Type", DocumentType);
            IDYSSourceDocumentService.Validate("Document No.", DocumentNo);
            IDYSSourceDocumentService.Validate("Service Level Code (Other)", ServiceLevelCodeOther);
            IDYSSourceDocumentService.Insert(true);
        end;
    end;

    procedure ClearSourceDocumentServices(SourceTable: Integer; DocumentType: Enum "IDYS Source Document Type"; DocumentNo: Code[20])
    var
        IDYSSourceDocumentService: Record "IDYS Source Document Service";
    begin
        IDYSSourceDocumentService.Init();
        IDYSSourceDocumentService.SetRange("Table No.", SourceTable);
        IDYSSourceDocumentService.SetRange("Document Type", DocumentType);
        IDYSSourceDocumentService.SetRange("Document No.", DocumentNo);
        IDYSSourceDocumentService.SetRange("System Created Entry", true);
        if not IDYSSourceDocumentService.IsEmpty() then
            IDYSSourceDocumentService.DeleteAll()
    end;

    #region [Obsolete]
    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.DoLabel(IDYSTransportOrderHeader));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken) Printed: Boolean
    begin
        exit(IDYSDelHubAPIDocsMgt.TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes"): JsonObject
    begin
        exit(IDYSDelHubAPIDocsMgt.GetShipmentAdditionalInformation(IDYSTransportOrderHeader, false, true));
    end;
    #endregion

    var
        IDYSDelHubAPIDocsMgt: Codeunit "IDYS DelHub API Docs. Mgt.";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        DistanceMeasureLbl: Label 'mm';
        VolumeMeasureLbl: Label 'mm3';
        MassMeasureLbl: Label 'g';
        CarrierSelectMappedErr: Label 'Mapped must be equal to ''%1'' in Carrier Select.', comment = '%1 - Value';

}