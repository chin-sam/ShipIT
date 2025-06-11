codeunit 11147723 "IDYS EasyPost Provider" implements "IDYS IProvider"
{
    procedure SetupWizardPage(): Integer
    begin
        exit(0);
    end;

    procedure SetupPage(): Integer
    begin
        exit(Page::"IDYS EasyPost Setup");
    end;

    procedure GetMasterData(ShowNotifications: Boolean): Boolean
    var
        IDYSEasyPostMDataMgt: Codeunit "IDYS EasyPost M. Data Mgt.";
    begin
        exit(IDYSEasyPostMDataMgt.UpdateMasterData(ShowNotifications));
    end;

    procedure OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSEasyPostAPIDocsMgt.OpenInDashboard(TransportOrderHeader);
    end;

    procedure OpenAllInDashboard();
    begin
        IDYSEasyPostAPIDocsMgt.OpenAllInDashboard();
    end;

    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, AllowLogging));
    end;

    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    procedure HandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject): Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.HandleResponseAfterBooking(IDYSTransportOrderHeader, RequestDocument, ResponseDocument))
    end;

    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") Printed: Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.DoLabel(IDYSTransportOrderHeader));
    end;

    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Response: JsonToken) Printed: Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    begin
        IDYSEasyPostAPIDocsMgt.HandleResponseAfterPrinting(IDYSTransportOrderHeader, Response);
    end;

    procedure IsBookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.IsBookable(IDYSTransportOrderHeader));
    end;

    procedure IsRebookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.IsRebookable(IDYSTransportOrderHeader));
    end;

    procedure DeleteAllowed(): Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.DeleteAllowed());
    end;

    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean): JsonObject
    begin
        exit(IDYSEasyPostAPIDocsMgt.GetShipmentAdditionalInformation(IDYSTransportOrderHeader, false, false));
    end;

    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    begin
        exit(IDYSEasyPostAPIDocsMgt.InitSelectCarrier(TempIDYSTransportOrderHeader, SalesHeader, IDYSProviderCarrierSelect));
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    begin
        exit(IDYSEasyPostAPIDocsMgt.InitSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect));
    end;

    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray);
    begin
        IDYSEasyPostAPIDocsMgt.SelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents);
    end;

    procedure DoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        // NOTE - not allowed
    end;

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSEasyPostAPIDocsMgt.ValidateTransportOrder(IDYSTransportOrderHeader);
    end;

    procedure UpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        IDYSEasyPostAPIDocsMgt.UpdateStatus(IDYSTransportOrderHeader);
    end;

    procedure IsEnabled(ThrowError: Boolean) Enabled: Boolean;
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        Enabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::EasyPost, ThrowError);
    end;

    procedure GetDefaultPackage(CarrierEntryNoFilter: Integer; BookingProfileEntryNoFilter: Integer) PackageTypeCode: Code[50]
    var
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
    begin
        // To avoid triggering default package insertion on multiple occasions
        if CarrierEntryNoFilter = 0 then
            exit;

        IDYSBookingProfPackageType.SetRange("Carrier Entry No.", CarrierEntryNoFilter);
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
        VerifyEasyPostMasterData(TempSetupVerificationResultBuffer);
    end;

    local procedure VerifyEasyPostMasterData(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary);
    var
        ProviderCarrier: Record "IDYS Provider Carrier";
        ProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        IDYSEasyPostShippingRate: Record "IDYS EasyPost Shipping Rate";
        IDYSVerifySetup: Codeunit "IDYS Verify Setup";
        EasyPostMasterDataTxt: Label 'EasyPost Master Data Tables';
        MasterDataSynchronizedTxt: Label 'The following master data is retrieved from EasyPost: %1.', Comment = '%1 = Table caption for Master Data';
    begin
        ProviderCarrier.SetRange(Provider, ProviderCarrier.Provider::EasyPost);
        ProviderBookingProfile.SetRange(Provider, ProviderBookingProfile.Provider::EasyPost);
        IDYSProviderPackageType.SetRange(Provider, IDYSProviderPackageType.Provider::EasyPost);

        IDYSVerifySetup.InsertVerificationHeading(TempSetupVerificationResultBuffer, EasyPostMasterDataTxt);
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderCarrier.TableCaption()), not ProviderCarrier.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderBookingProfile.TableCaption()), not ProviderBookingProfile.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, IDYSEasyPostShippingRate.TableCaption()), not IDYSEasyPostShippingRate.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, IDYSProviderPackageType.TableCaption()), not IDYSProviderPackageType.IsEmpty());
    end;

    procedure ProviderCarrierSelectLookup(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select")
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        ProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
    begin
        TempProviderCarrierSelect.CalcFields(Details);
        if TempProviderCarrierSelect.Details then
            if ShipAgentSvcMapping.Get(TempProviderCarrierSelect."Svc. Mapping RecordId") then begin
                TransportOrderHeader.SetSkipPackageValidation(true);
                if ShipAgentSvcMapping."Shipping Agent Code" <> TransportOrderHeader."Shipping Agent Code" then
                    TransportOrderHeader.Validate("Shipping Agent Code", ShipAgentSvcMapping."Shipping Agent Code");
                if ShipAgentSvcMapping."Shipping Agent Service Code" <> TransportOrderHeader."Shipping Agent Service Code" then
                    TransportOrderHeader.Validate("Shipping Agent Service Code", ShipAgentSvcMapping."Shipping Agent Service Code");
                TransportOrderHeader.Modify();
            end;

        ProvCarrierSelectPck.SetRange("Transport Order No.", TempProviderCarrierSelect."Transport Order No.");
        ProvCarrierSelectPck.SetRange("Line No.", TempProviderCarrierSelect."Line No.");
        ProvCarrierSelectPck.SetRange(Include, true);
        if ProvCarrierSelectPck.FindSet() then
            repeat
                TransportOrderPackage.SetRange("Transport Order No.", TransportOrderHeader."No.");
                TransportOrderPackage.SetRange("Parcel Identifier", ProvCarrierSelectPck."Parcel Identifier");
                if TransportOrderPackage.FindLast() then begin
                    TransportOrderPackage.Validate("Shipment Id", ProvCarrierSelectPck."Shipment Id");
                    TransportOrderPackage.Validate("Package Id", ProvCarrierSelectPck."Package Id");
                    TransportOrderPackage.Validate("Rate Id", ProvCarrierSelectPck."Rate Id");
                    TransportOrderPackage.Validate("Shipping Method Description", CopyStr(ProvCarrierSelectPck."Carrier Name" + ' - ' + ProvCarrierSelectPck.Description, 1, MaxStrLen(TransportOrderPackage."Shipping Method Description")));
                    TransportOrderPackage.Modify();
                end;
            until ProvCarrierSelectPck.Next() = 0;
    end;


    procedure ProviderCarrierSelectLookup_SalesHeader(var SalesHeader: Record "Sales Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select")
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        ProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
    begin
        TempProviderCarrierSelect.CalcFields(Details);
        if TempProviderCarrierSelect.Details then
            if ShipAgentSvcMapping.Get(TempProviderCarrierSelect."Svc. Mapping RecordId") then begin
                SalesHeader.IDYSSetSkipPackageValidation(true);
                if ShipAgentSvcMapping."Shipping Agent Code" <> SalesHeader."Shipping Agent Code" then
                    SalesHeader.Validate("Shipping Agent Code", ShipAgentSvcMapping."Shipping Agent Code");
                if ShipAgentSvcMapping."Shipping Agent Service Code" <> SalesHeader."Shipping Agent Service Code" then
                    SalesHeader.Validate("Shipping Agent Service Code", ShipAgentSvcMapping."Shipping Agent Service Code");
                SalesHeader.Modify();
            end;

        ProvCarrierSelectPck.SetRange("Transport Order No.", TempProviderCarrierSelect."Transport Order No.");
        ProvCarrierSelectPck.SetRange("Line No.", TempProviderCarrierSelect."Line No.");
        ProvCarrierSelectPck.SetRange(Include, true);
        if ProvCarrierSelectPck.FindSet() then
            repeat
                SourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
                SourceDocumentPackage.SetRange("Document Type", SalesHeader."Document Type");
                SourceDocumentPackage.SetRange("Document No.", SalesHeader."No.");
                SourceDocumentPackage.SetRange("Parcel Identifier", ProvCarrierSelectPck."Parcel Identifier");
                if SourceDocumentPackage.FindLast() then begin
                    SourceDocumentPackage.Validate("Shipment Id", ProvCarrierSelectPck."Shipment Id");
                    SourceDocumentPackage.Validate("Package Id", ProvCarrierSelectPck."Package Id");
                    SourceDocumentPackage.Validate("Rate Id", ProvCarrierSelectPck."Rate Id");
                    SourceDocumentPackage.Validate("Shipping Method Description", CopyStr(ProvCarrierSelectPck."Carrier Name" + ' - ' + ProvCarrierSelectPck.Description, 1, MaxStrLen(SourceDocumentPackage."Shipping Method Description")));
                    SourceDocumentPackage.Modify();
                end;
            until ProvCarrierSelectPck.Next() = 0;
    end;

    procedure IDYSTransportOrderHeader_ValidateShippingAgentCode(var Rec: Record "IDYS Transport Order Header"; var xRec: Record "IDYS Transport Order Header"; CurrFieldNo: Integer)
    begin
        IDYSEasypostAPIDocsMgt.ResetTransportOrderShippingMethod(Rec);
    end;

    procedure IDYSTransportOrderPackage_OnBeforeInsertEvent(RunTrigger: Boolean; var Rec: Record "IDYS Transport Order Package")
    begin
        IDYSEasyPostSetup.GetProviderSetup("IDYS Provider"::EasyPost);
        Rec."Label Format" := IDYSEasyPostSetup."Default Label Type";
    end;

    #region [Obsolete]
    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.DoLabel(IDYSTransportOrderHeader));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken) Printed: Boolean
    begin
        exit(IDYSEasyPostAPIDocsMgt.TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes"): JsonObject
    begin
        exit(IDYSEasyPostAPIDocsMgt.GetShipmentAdditionalInformation(IDYSTransportOrderHeader, false, false));
    end;

    #endregion
    var
        IDYSEasyPostSetup: Record "IDYS Setup";
        IDYSEasyPostAPIDocsMgt: Codeunit "IDYS EasyPost API Docs. Mgt.";
        DistanceMeasureLbl: Label 'in';
        VolumeMeasureLbl: Label 'in3';
        MassMeasureLbl: Label 'oz';
}