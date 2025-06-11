codeunit 11147706 "IDYS Cargoson Provider" implements "IDYS IProvider"
{
    procedure SetupWizardPage(): Integer
    begin
        exit(0);
    end;

    procedure SetupPage(): Integer
    begin
        exit(Page::"IDYS Cargoson Setup");
    end;

    procedure GetMasterData(ShowNotifications: Boolean): Boolean
    var
        IDYSCargosonMDataMgt: Codeunit "IDYS Cargoson M. Data Mgt.";
    begin
        exit(IDYSCargosonMDataMgt.UpdateMasterData(ShowNotifications));
    end;

    procedure OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSCargosonAPIDocsMgt.OpenInDashboard(TransportOrderHeader);
    end;

    procedure OpenAllInDashboard();
    begin
        IDYSCargosonAPIDocsMgt.OpenAllInDashboard();
    end;

    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.CreateAndBookDocumentWithResponseHandling(IDYSTransportOrderHeader, AllowLogging));
    end;

    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    procedure HandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject): Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.HandleResponseAfterBooking(IDYSTransportOrderHeader, RequestDocument, ResponseDocument))
    end;

    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") Printed: Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.DoLabel(IDYSTransportOrderHeader));
    end;

    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Response: JsonToken) Printed: Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    begin
        IDYSCargosonAPIDocsMgt.HandleResponseAfterPrinting(IDYSTransportOrderHeader, Response);
    end;

    procedure IsBookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.IsBookable(IDYSTransportOrderHeader));
    end;

    procedure IsRebookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.IsRebookable(IDYSTransportOrderHeader));
    end;

    procedure DeleteAllowed(): Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.DeleteAllowed());
    end;

    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean): JsonObject
    begin
        exit(IDYSCargosonAPIDocsMgt.Synchronize(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry));
    end;

    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    begin
        exit(IDYSCargosonAPIDocsMgt.InitSelectCarrier(TempIDYSTransportOrderHeader, SalesHeader, IDYSProviderCarrierSelect));
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    begin
        exit(IDYSCargosonAPIDocsMgt.InitSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect));
    end;

    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray);
    begin
        IDYSCargosonAPIDocsMgt.SelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents);
    end;

    procedure DoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSCargosonAPIDocsMgt.DoDelete(IDYSTransportOrderHeader);
    end;

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSCargosonAPIDocsMgt.ValidateTransportOrder(IDYSTransportOrderHeader);
    end;

    procedure UpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        IDYSCargosonAPIDocsMgt.UpdateStatus(IDYSTransportOrderHeader);
    end;

    procedure IsEnabled(ThrowError: Boolean) Enabled: Boolean;
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        Enabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Cargoson, ThrowError);
    end;

    procedure GetDefaultPackage(CarrierEntryNoFilter: Integer; BookingProfileEntryNoFilter: Integer) PackageTypeCode: Code[50]
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        IDYSSetup.GetProviderSetup("IDYS Provider"::Cargoson);
        exit(IDYSSetup."Default Provider Package Type");
    end;

    procedure GetMeasurementCaptions(var DistanceCaption: Text; var VolumeCaption: Text; var MassCaption: Text)
    begin
        DistanceCaption := DistanceMeasureLbl;
        VolumeCaption := VolumeMeasureLbl;
        MassCaption := MassMeasureLbl;
    end;
    #region [Obsolete]
    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.CreateAndBookDocumentWithResponseHandling(IDYSTransportOrderHeader, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.DoLabel(IDYSTransportOrderHeader));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken) Printed: Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSCargosonAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes"): JsonObject
    begin
        exit(IDYSCargosonAPIDocsMgt.Synchronize(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry));
    end;
    #endregion

    procedure VerifySetup(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary)
    begin
        VerifyCargosonMasterData(TempSetupVerificationResultBuffer);
    end;

    local procedure VerifyCargosonMasterData(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary);
    var
        ProviderCarrier: Record "IDYS Provider Carrier";
        ProviderBookingProfile: Record "IDYS Provider Booking Profile";
        ProviderPackageType: Record "IDYS Provider Package Type";
        Incoterm: Record "IDYS Incoterm";
        IDYSVerifySetup: Codeunit "IDYS Verify Setup";
        CargosonMasterDataTxt: Label 'Cargoson Master Data Tables';
        MasterDataSynchronizedTxt: Label 'The following master data is retrieved from Cargoson: %1.', Comment = '%1 = Table caption for Master Data';
    begin
        ProviderCarrier.SetRange(Provider, ProviderCarrier.Provider::Cargoson);
        ProviderBookingProfile.SetRange(Provider, ProviderBookingProfile.Provider::Cargoson);
        ProviderPackageType.SetRange(Provider, ProviderPackageType.Provider::Cargoson);

        IDYSVerifySetup.InsertVerificationHeading(TempSetupVerificationResultBuffer, CargosonMasterDataTxt);
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderCarrier.TableCaption()), not ProviderCarrier.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderBookingProfile.TableCaption()), not ProviderBookingProfile.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderPackageType.TableCaption()), not ProviderPackageType.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, Incoterm.TableCaption()), not Incoterm.IsEmpty());
    end;

    procedure ProviderCarrierSelectLookup(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select")
    var
        IDYSSetup: Record "IDYS Setup";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        ModifyHeader: Boolean;
    begin
        TempProviderCarrierSelect.TestField(Mapped, true);
        IDYSSetup.Get();

        // Modify transport order based on selected carrier
        ShipAgentSvcMapping.SetRange("Carrier Entry No.", TempProviderCarrierSelect."Carrier Entry No.");
        ShipAgentSvcMapping.SetRange("Booking Profile Entry No.", TempProviderCarrierSelect."Booking Profile Entry No.");
        if ShipAgentSvcMapping.FindFirst() then begin
            if ShipAgentSvcMapping."Shipping Agent Code" <> TransportOrderHeader."Shipping Agent Code" then begin
                TransportOrderHeader.Validate("Shipping Agent Code", ShipAgentSvcMapping."Shipping Agent Code");
                ModifyHeader := true;
            end;
            if ShipAgentSvcMapping."Shipping Agent Service Code" <> TransportOrderHeader."Shipping Agent Service Code" then begin
                TransportOrderHeader.Validate("Shipping Agent Service Code", ShipAgentSvcMapping."Shipping Agent Service Code");
                ModifyHeader := true;
            end;
            if ModifyHeader then
                TransportOrderHeader.Modify();
        end;
    end;

    procedure ProviderCarrierSelectLookup_SalesHeader(var SalesHeader: Record "Sales Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select")
    var
        IDYSSetup: Record "IDYS Setup";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        ModifyHeader: Boolean;
    begin
        TempProviderCarrierSelect.TestField(Mapped, true);

        // Modify sales order based on selected carrier
        ShipAgentSvcMapping.SetRange("Carrier Entry No.", TempProviderCarrierSelect."Carrier Entry No.");
        ShipAgentSvcMapping.SetRange("Booking Profile Entry No.", TempProviderCarrierSelect."Booking Profile Entry No.");
        if ShipAgentSvcMapping.FindFirst() then begin
            IDYSSetup.Get();
            if ShipAgentSvcMapping."Shipping Agent Code" <> SalesHeader."Shipping Agent Code" then begin
                SalesHeader.Validate("Shipping Agent Code", ShipAgentSvcMapping."Shipping Agent Code");
                ModifyHeader := true;
            end;
            if ShipAgentSvcMapping."Shipping Agent Service Code" <> SalesHeader."Shipping Agent Service Code" then begin
                SalesHeader.Validate("Shipping Agent Service Code", ShipAgentSvcMapping."Shipping Agent Service Code");
                ModifyHeader := true;
            end;
            if ModifyHeader then
                SalesHeader.Modify();
        end;
    end;

    var
        IDYSCargosonAPIDocsMgt: Codeunit "IDYS Cargoson API Docs. Mgt.";
        DistanceMeasureLbl: Label 'cm';
        VolumeMeasureLbl: Label 'cm3';
        MassMeasureLbl: Label 'kg';
}