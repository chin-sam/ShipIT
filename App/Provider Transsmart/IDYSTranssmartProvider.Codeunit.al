codeunit 11147695 "IDYS Transsmart Provider" implements "IDYS IProvider"
{
    procedure SetupWizardPage(): Integer
    begin
        exit(0);
    end;

    procedure SetupPage(): Integer
    begin
        exit(Page::"IDYS Transsmart Setup");
    end;

    procedure GetMasterData(ShowNotifications: Boolean): Boolean
    var
        IDYSTranssmartMDataMgt: Codeunit "IDYS Transsmart M. Data Mgt.";
    begin
        exit(IDYSTranssmartMDataMgt.UpdateMasterData(ShowNotifications));
    end;

    procedure OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSTranssmartAPIDocsMgt.OpenInDashboard(TransportOrderHeader);
    end;

    procedure OpenAllInDashboard();
    begin
        IDYSTranssmartAPIDocsMgt.OpenAllInDashboard();
    end;

    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, AllowLogging));
    end;

    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    procedure HandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject): Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.HandleResponseAfterBooking(IDYSTransportOrderHeader, RequestDocument, ResponseDocument))
    end;

    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header") Printed: Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.DoLabel(IDYSTransportOrderHeader));
    end;

    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Response: JsonToken) Printed: Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    begin
        IDYSTranssmartAPIDocsMgt.HandleResponseAfterPrinting(IDYSTransportOrderHeader, Response);
    end;

    procedure IsBookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.IsBookable(IDYSTransportOrderHeader));
    end;

    procedure IsRebookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.IsRebookable(IDYSTransportOrderHeader));
    end;

    procedure DeleteAllowed(): Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.DeleteAllowed());
    end;

    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean): JsonObject
    begin
        exit(IDYSTranssmartAPIDocsMgt.Synchronize(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry));
    end;

    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    begin
        exit(IDYSTranssmartAPIDocsMgt.InitSelectCarrier(TempIDYSTransportOrderHeader, SalesHeader, IDYSProviderCarrierSelect));
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    begin
        exit(IDYSTranssmartAPIDocsMgt.InitSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect));
    end;

    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray);
    begin
        IDYSTranssmartAPIDocsMgt.SelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents);
    end;

    procedure DoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSTranssmartAPIDocsMgt.DoDelete(IDYSTransportOrderHeader);
    end;

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        IDYSTranssmartAPIDocsMgt.ValidateTransportOrder(IDYSTransportOrderHeader);
    end;

    procedure UpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        IDYSTranssmartAPIDocsMgt.UpdateStatus(IDYSTransportOrderHeader);
    end;

    procedure IsEnabled(ThrowError: Boolean) Enabled: Boolean;
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        Enabled := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Transsmart, ThrowError);
    end;

    procedure GetDefaultPackage(CarrierEntryNoFilter: Integer; BookingProfileEntryNoFilter: Integer) PackageTypeCode: Code[50]
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        IDYSSetup.GetProviderSetup("IDYS Provider"::Transsmart);
        exit(IDYSSetup."Default Provider Package Type");
    end;

    procedure GetMeasurementCaptions(var DistanceCaption: Text; var VolumeCaption: Text; var MassCaption: Text)
    begin
        // NOTE: For transsmart you can specify Size / Weight UoM on the package level (API data) and captions becomes irrelevant
        DistanceCaption := '';
        VolumeCaption := '';
        MassCaption := '';
    end;

    procedure VerifySetup(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary)
    begin
        VerifyUserSetupTable(TempSetupVerificationResultBuffer);
        VerifyTranssmartMasterData(TempSetupVerificationResultBuffer);
    end;

    local procedure VerifyUserSetupTable(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary);
    var
        IDYSUserSetup: Record "IDYS User Setup";
        TableTxt: Label 'Table %1', Comment = '%1 = Table Caption.';
        MustHaveValueTxt: Label 'Fields "%1" and "%2" must have a value for at least one user', Comment = '%1 = User Name Caption, %2 = Password Caption.';
    begin
        IDYSVerifySetup.InsertVerificationHeading(TempSetupVerificationResultBuffer, StrSubstNo(TableTxt, IDYSUserSetup.TableCaption()));

        IDYSUserSetup.SetFilter("User Name (External)", '<>%1', '');
        IDYSUserSetup.SetFilter("Password (External)", '<>%1', '');

        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer,
          StrSubstNo(
            MustHaveValueTxt,
            IDYSUserSetup.FieldCaption("User Name (External)"),
            IDYSUserSetup.FieldCaption("Password (External)")),
          not IDYSUserSetup.IsEmpty());
    end;

    local procedure VerifyTranssmartMasterData(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary);
    var
        ProviderCarrier: Record "IDYS Provider Carrier";
        ProviderBookingProfile: Record "IDYS Provider Booking Profile";
        Incoterm: Record "IDYS Incoterm";
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        CostCenter: Record "IDYS Cost Center";
        EMailType: Record "IDYS E-Mail Type";
        MasterDataSynchronizedTxt: Label 'The following master data is retrieved from nShift Transsmart: %1.', Comment = '%1 = Table caption for Master Data';
        TranssmartMasterDataTxt: Label 'nShift Transsmart Master Data Tables';
    begin
        ProviderCarrier.SetRange(Provider, ProviderCarrier.Provider::Transsmart);
        ProviderBookingProfile.SetRange(Provider, ProviderBookingProfile.Provider::Transsmart);
        IDYSProviderPackageType.SetRange(Provider, IDYSProviderPackageType.Provider::Transsmart);

        IDYSVerifySetup.InsertVerificationHeading(TempSetupVerificationResultBuffer, TranssmartMasterDataTxt);
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderCarrier.TableCaption()), not ProviderCarrier.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, ProviderBookingProfile.TableCaption()), not ProviderBookingProfile.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, Incoterm.TableCaption()), not Incoterm.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, IDYSProviderPackageType.TableCaption()), not IDYSProviderPackageType.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, CostCenter.TableCaption()), not CostCenter.IsEmpty());
        IDYSVerifySetup.InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubStNo(MasterDataSynchronizedTxt, EMailType.TableCaption()), not EMailType.IsEmpty());
    end;

    procedure ProviderCarrierSelectLookup(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select")
    var
        IDYSSetup: Record "IDYS Setup";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
    begin
        TempProviderCarrierSelect.TestField(Mapped, true);
        IDYSSetup.Get();

        // Modify transport order based on selected carrier
        ShipAgentSvcMapping.SetRange("Carrier Entry No.", TempProviderCarrierSelect."Carrier Entry No.");
        ShipAgentSvcMapping.SetRange("Booking Profile Entry No.", TempProviderCarrierSelect."Booking Profile Entry No.");
        if ShipAgentSvcMapping.FindFirst() then begin
            if ShipAgentSvcMapping."Shipping Agent Code" <> TransportOrderHeader."Shipping Agent Code" then
                TransportOrderHeader.Validate("Shipping Agent Code", ShipAgentSvcMapping."Shipping Agent Code");
            if ShipAgentSvcMapping."Shipping Agent Service Code" <> TransportOrderHeader."Shipping Agent Service Code" then
                TransportOrderHeader.Validate("Shipping Agent Service Code", ShipAgentSvcMapping."Shipping Agent Service Code");
        end;
        TransportOrderHeader."Preferred Pick-up Date From" := CreateDateTime(TempProviderCarrierSelect."Pickup Date", DT2Time(IDYSSetup."Pick-up From DT"));
        TransportOrderHeader."Preferred Pick-up Date To" := CreateDateTime(TempProviderCarrierSelect."Pickup Date", DT2Time(IDYSSetup."Pick-up To DT"));
        TransportOrderHeader."Preferred Delivery Date From" := CreateDateTime(TempProviderCarrierSelect."Delivery Date", TempProviderCarrierSelect."Delivery Time");
        TransportOrderHeader."Preferred Delivery Date To" := CreateDateTime(TempProviderCarrierSelect."Delivery Date", TempProviderCarrierSelect."Delivery Time");
        TransportOrderHeader."Service Level Code (Time)" := TempProviderCarrierSelect."Service Level Code (Time)";
        TransportOrderHeader."Service Level Code (Other)" := TempProviderCarrierSelect."Service Level Code (Other)";
        TransportOrderHeader.Modify();
    end;

    procedure ProviderCarrierSelectLookup_SalesHeader(var SalesHeader: Record "Sales Header"; var TempProviderCarrierSelect: Record "IDYS Provider Carrier Select")
    var
        IDYSSetup: Record "IDYS Setup";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
    begin
        TempProviderCarrierSelect.TestField(Mapped, true);
        TempProviderCarrierSelect.TestField("Not Available", false);

        // Modify sales order based on selected carrier
        ShipAgentSvcMapping.SetRange("Carrier Entry No.", TempProviderCarrierSelect."Carrier Entry No.");
        ShipAgentSvcMapping.SetRange("Booking Profile Entry No.", TempProviderCarrierSelect."Booking Profile Entry No.");
        if ShipAgentSvcMapping.FindFirst() then begin
            IDYSSetup.Get();
            if ShipAgentSvcMapping."Shipping Agent Code" <> SalesHeader."Shipping Agent Code" then
                SalesHeader.Validate("Shipping Agent Code", ShipAgentSvcMapping."Shipping Agent Code");
            if ShipAgentSvcMapping."Shipping Agent Service Code" <> SalesHeader."Shipping Agent Service Code" then
                SalesHeader.Validate("Shipping Agent Service Code", ShipAgentSvcMapping."Shipping Agent Service Code");
            SalesHeader.Modify();
        end;
    end;

    #region [Obsolete]
    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.CreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, AllowLogging));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.DoLabel(IDYSTransportOrderHeader));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken) Printed: Boolean
    begin
        exit(IDYSTranssmartAPIDocsMgt.TryDoLabel(IDYSTransportOrderHeader, Response));
    end;

    [Obsolete('Removed ErrorCode', '25.0')]
    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes"): JsonObject
    begin
        exit(IDYSTranssmartAPIDocsMgt.Synchronize(IDYSTransportOrderHeader, UpdateHeader, WriteLogEntry));
    end;
    #endregion
    var
        IDYSTranssmartAPIDocsMgt: Codeunit "IDYS Transsmart API Docs. Mgt.";
        IDYSVerifySetup: Codeunit "IDYS Verify Setup";
}