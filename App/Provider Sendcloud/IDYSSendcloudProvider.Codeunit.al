codeunit 11147702 "IDYS Sendcloud Provider" implements "IDYS IProvider"
{
    procedure SetupWizardPage(): Integer
    begin
        exit(0);
    end;

    procedure SetupPage(): Integer
    begin
        exit(Page::"IDYS Sendcloud Setup");
    end;

    procedure GetMasterData(ShowNotifications: Boolean): Boolean
    var
        IDYSSCShippingMethodMgt: Codeunit "IDYS SC Shipping Method Mgt.";
    begin
        exit(IDYSSCShippingMethodMgt.UpdateMasterData());
    end;

    procedure OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        // No implementation
    end;

    procedure OpenAllInDashboard();
    begin
        // No implementation
    end;

    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.CreateAndBookDocumentWithResponseHandling(IDYSTransportOrderHeader, AllowLogging));
    end;

    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    procedure HandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject): Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.HandleResponseAfterBooking(IDYSTransportOrderHeader, RequestDocument, ResponseDocument))
    end;

    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") Printed: Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.DoLabel(IDYSTransportOrderHeader));
    end;

    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Response: JsonToken) Printed: Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    begin
        IDYSSendcloudAPIDocsMgt.HandleResponseAfterPrinting(IDYSTransportOrderHeader, Response);
    end;

    procedure IsBookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.IsBookable(IDYSTransportOrderHeader));
    end;

    procedure IsRebookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.IsRebookable(IDYSTransportOrderHeader));
    end;

    procedure DeleteAllowed(): Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.DeleteAllowed());
    end;

    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean): JsonObject
    begin
        exit(IDYSSendcloudAPIDocsMgt.GetDocument(IDYSTransportOrderHeader, false, false));
    end;

    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    begin
        exit(IDYSSendcloudAPIDocsMgt.InitSelectCarrier(TempIDYSTransportOrderHeader, SalesHeader, IDYSProviderCarrierSelect));
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    begin
        exit(IDYSSendcloudAPIDocsMgt.InitSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect));
    end;

    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray);
    begin
        IDYSSendcloudAPIDocsMgt.SelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents);
    end;

    procedure DoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSSendcloudAPIDocsMgt.DoDelete(IDYSTransportOrderHeader);
    end;

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSSendcloudAPIDocsMgt.ValidateTransportOrder(IDYSTransportOrderHeader);
    end;

    procedure UpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        IDYSSendcloudAPIDocsMgt.UpdateStatus(IDYSTransportOrderHeader);
    end;

    procedure IsEnabled(ThrowError: Boolean) Enabled: Boolean;
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        Enabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Sendcloud, ThrowError);
    end;

    procedure GetDefaultPackage(CarrierEntryNoFilter: Integer; BookingProfileEntryNoFilter: Integer) PackageTypeCode: Code[50]
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        IDYSSetup.GetProviderSetup("IDYS Provider"::Sendcloud);
        exit(IDYSSetup."Default Provider Package Type");
    end;

    procedure GetMeasurementCaptions(var DistanceCaption: Text; var VolumeCaption: Text; var MassCaption: Text)
    begin
        DistanceCaption := DistanceMeasureLbl;
        VolumeCaption := VolumeMeasureLbl;
        MassCaption := MassMeasureLbl;
    end;

    procedure VerifySetup(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary)
    begin
        VerifySendcloudMasterData(TempSetupVerificationResultBuffer);
    end;

    local procedure VerifySendcloudMasterData(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary);
    var
        ProviderCarrier: Record "IDYS Provider Carrier";
        ProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        IDYSSCShippingPrice: Record "IDYS SC Shipping Price";
        IDYSVerifySetup: Codeunit "IDYS Verify Setup";
        SendcloudMasterDataTxt: Label 'Sendcloud Master Data Tables';
        MasterDataSynchronizedTxt: Label 'The following master data is retrieved from Sendcloud: %1.', Comment = '%1 = Table caption for Master Data';
    begin
        ProviderCarrier.SetRange(Provider, ProviderCarrier.Provider::Sendcloud);
        ProviderBookingProfile.SetRange(Provider, ProviderBookingProfile.Provider::Sendcloud);
        IDYSProviderPackageType.SetRange(Provider, IDYSProviderPackageType.Provider::Sendcloud);

        IDYSVerifySetup.InsertVerificationHeading(TempSetupVerificationResultBuffer, SendcloudMasterDataTxt);
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderCarrier.TableCaption()), not ProviderCarrier.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderBookingProfile.TableCaption()), not ProviderBookingProfile.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, IDYSSCShippingPrice.TableCaption()), not IDYSSCShippingPrice.IsEmpty());
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
                    TransportOrderPackage.Validate("Shipping Method Id", ProvCarrierSelectPck."Shipping Method Id");
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
                    SourceDocumentPackage.Validate("Shipping Method Id", ProvCarrierSelectPck."Shipping Method Id");
                    SourceDocumentPackage.Validate("Shipping Method Description", CopyStr(ProvCarrierSelectPck."Carrier Name" + ' - ' + ProvCarrierSelectPck.Description, 1, MaxStrLen(SourceDocumentPackage."Shipping Method Description")));
                    SourceDocumentPackage.Modify();
                end;
            until ProvCarrierSelectPck.Next() = 0;
    end;

    procedure IDYSTransportOrderHeader_ValidateShippingAgentCode(var Rec: Record "IDYS Transport Order Header"; var xRec: Record "IDYS Transport Order Header"; CurrFieldNo: Integer)
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        ShippingAgent: Record "Shipping Agent";
    begin
        // Reset shipping method
        IDYSSendcloudAPIDocsMgt.ResetTransportOrderShippingMethod(Rec."No.");

        if ShippingAgent.Get(Rec."Shipping Agent Code") and ShippingAgent."IDYS SC Change Label Settings" then begin
            IDYSTransportOrderPackage.Reset();
            IDYSTransportOrderPackage.SetRange("Transport Order No.", Rec."No.");
            IDYSTransportOrderPackage.ModifyAll("Request Label", ShippingAgent."IDYS SC Request Label");
        end;
    end;

    procedure IDYSTransportOrderPackage_OnBeforeInsertEvent(RunTrigger: Boolean; var Rec: Record "IDYS Transport Order Package")
    var
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSSendcloudSetup: Record "IDYS Setup";
    begin
        IDYSSendcloudSetup.GetProviderSetup("IDYS Provider"::Sendcloud);
        Rec."Request Label" := IDYSSendcloudSetup."Request Label";

        // Unstamped letter not applicable with the returns
        if IDYSTransportOrderHeader."Is Return" then
            exit;

        if IDYSSendcloudSetup."Apply Shipping Rules" and (Rec."Shipping Method Id" = 0) then begin
            IDYSProviderBookingProfile.SetRange(Id, 8);
            if IDYSProviderBookingProfile.FindLast() then begin
                IDYSProviderBookingProfile.CalcFields("Carrier Name");
                Rec.Validate("Shipping Method Id", IDYSProviderBookingProfile.Id);
                Rec.Validate("Shipping Method Description", CopyStr(IDYSProviderBookingProfile."Carrier Name" + ' - ' + IDYSProviderBookingProfile.Description, 1, MaxStrLen(Rec."Shipping Method Description")));
            end;
        end;
    end;

    #region [Obsolete]
    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.CreateAndBookDocumentWithResponseHandling(IDYSTransportOrderHeader, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.DoLabel(IDYSTransportOrderHeader));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken) Printed: Boolean
    begin
        exit(IDYSSendcloudAPIDocsMgt.TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes"): JsonObject
    begin
        exit(IDYSSendcloudAPIDocsMgt.GetDocument(IDYSTransportOrderHeader, false, false));
    end;
    #endregion
    var
        IDYSSendcloudAPIDocsMgt: Codeunit "IDYS Sendcloud API Docs. Mgt.";
        DistanceMeasureLbl: Label 'cm';
        VolumeMeasureLbl: Label 'cm3';
        MassMeasureLbl: Label 'kg';

}