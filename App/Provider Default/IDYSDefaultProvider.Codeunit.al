codeunit 11147694 "IDYS Default Provider" implements "IDYS IProvider"
{
    procedure SetupWizardPage(): Integer
    begin
        LoadSetup();
        exit(IDYSSetup."Setup Wizard Page Id");
    end;

    procedure SetupPage(): Integer
    begin
        LoadSetup();
        exit(IDYSSetup."Setup Page Id");
    end;

    procedure GetMasterData(ShowNotification: Boolean): Boolean
    var
        Result: Boolean;
    begin
        OnGetMasterData(ShowNotification, Result);
        exit(Result);
    end;

    procedure OpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        OnOpenInDashboard(TransportOrderHeader);
    end;

    procedure OpenAllInDashboard();
    begin
        OnOpenAllInDashboard();
    end;

    procedure CreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    var
        Result: Boolean;
    begin
        OnCreateAndBookDocumentWithResponseHandling(IDYSTransportOrderHeader, ErrorCode, AllowLogging, Result);
        exit(Result);
    end;

    procedure CreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean): Boolean
    var
        Result: Boolean;
    begin
        OnCreateAndBookDocument(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, ErrorCode, AllowLogging, Result);
        exit(Result);
    end;

    procedure HandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject): Boolean
    var
        Result: Boolean;
    begin
        OnHandleResponseAfterBooking(IDYSTransportOrderHeader, RequestDocument, ResponseDocument, Result);
        exit(Result);
    end;

    procedure PrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes") Printed: Boolean
    var
        Result: Boolean;
    begin
        OnPrintLabelWithResponseHandling(IDYSTransportOrderHeader, ErrorCode, Result);
        exit(Result);
    end;

    procedure PrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken) Printed: Boolean
    var
        Result: Boolean;
    begin
        OnPrintLabel(IDYSTransportOrderHeader, ErrorCode, Response, Result);
        exit(Result);
    end;

    procedure HandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    begin
        OnHandleResponseAfterPrinting(IDYSTransportOrderHeader, Response);
    end;

    procedure IsBookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    var
        Result: Boolean;
    begin
        OnIsBookable(IDYSTransportOrderHeader, Result);
        exit(Result);
    end;

    procedure IsRebookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    var
        Result: Boolean;
    begin
        OnIsRebookable(IDYSTransportOrderHeader, Result);
        exit(Result);
    end;

    procedure DeleteAllowed(): Boolean
    var
        Result: Boolean;
    begin
        OnDeleteAllowed(Result);
        exit(Result);
    end;

    procedure CreateDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Documents: JsonArray; var Document: JsonObject): Boolean;
    var
        Result: Boolean;
    begin
        OnCreateDocument(Result);
        exit(Result);
    end;

    procedure GetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes"): JsonObject
    var
        Result: JsonObject;
    begin
        OnGetDocument(IDYSTransportOrderHeader, false, false, ErrorCode, Result);
        exit(Result);
    end;

    procedure InitSelectCarrier(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    var
        Result: JsonArray;
    begin
        OnInitSelectCarrierFromSalesHeader(TempIDYSTransportOrderHeader, SalesHeader, IDYSProviderCarrierSelect, Result);
        exit(Result);
    end;

    procedure InitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary): JsonArray;
    var
        Result: JsonArray;
    begin
        OnInitSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Result);
        exit(Result);
    end;

    procedure SelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray);
    begin
        OnSelectCarrier(IDYSTransportOrderHeader, IDYSProviderCarrierSelect, Documents);
    end;

    procedure DoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        OnDoDelete(IDYSTransportOrderHeader);
    end;

    procedure ValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        OnValidateTransportOrder(IDYSTransportOrderHeader);
    end;

    procedure UpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        OnUpdateStatus(IDYSTransportOrderHeader);
    end;

    procedure IsEnabled(ThrowError: Boolean): Boolean
    var
        ProviderSetup: Record "IDYS Provider Setup";
        ProvideIsNotEnabledErr: Label 'Provider (%1) is not enabled.', comment = '%1 = provider';
    begin
        if not ProviderSetup.Get("IDYS Provider"::Default) or not ProviderSetup.Enabled then
            if ThrowError then
                Error(ProvideIsNotEnabledErr, "IDYS Provider"::Default);
        exit(ProviderSetup.Enabled);
    end;

    procedure GetDefaultPackage(CarrierEntryNoFilter: Integer; BookingProfileEntryNoFilter: Integer) PackageTypeCode: Code[50]
    begin
        OnGetDefaultPackage(CarrierEntryNoFilter, BookingProfileEntryNoFilter, PackageTypeCode);
    end;

    procedure GetMeasurementCaptions(var DistanceCaption: Text; var VolumeCaption: Text; var MassCaption: Text)
    begin
        OnGetMeasurementCaptions(DistanceCaption, VolumeCaption, MassCaption)
    end;

    local procedure LoadSetup()
    begin
        if not SetupLoaded then begin
            SetupLoaded := true;
            if not IDYSSetup.Get() then
                IDYSSetup.Init();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetMasterData(ShowNotification: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenInDashboard(TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenAllInDashboard()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateAndBookDocumentWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateAndBookDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var RequestDocument: JsonObject; var ResponseDocument: JsonObject; ErrorCode: enum "IDYS Error Codes"; AllowLogging: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleResponseAfterBooking(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; RequestDocument: JsonObject; ResponseDocument: JsonObject; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPrintLabelWithResponseHandling(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: enum "IDYS Error Codes"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPrintLabel(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ErrorCode: Enum "IDYS Error Codes"; var Response: JsonToken; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleResponseAfterPrinting(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Response: JsonToken)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsBookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsRebookable(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteAllowed(var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateDocument(var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDocument(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; UpdateHeader: Boolean; WriteLogEntry: Boolean; ErrorCode: enum "IDYS Error Codes"; var Result: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitSelectCarrierFromSalesHeader(var TempIDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var SalesHeader: Record "Sales Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; var Result: JsonArray)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; var Result: JsonArray)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSelectCarrier(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IDYSProviderCarrierSelect: Record "IDYS Provider Carrier Select" temporary; Documents: JsonArray)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDoDelete(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateTransportOrder(IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateStatus(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDefaultPackage(CarrierEntryNoFilter: Integer; BookingProfileEntryNoFilter: Integer; var PackageTypeCode: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetMeasurementCaptions(var DistanceCaption: Text; var VolumeCaption: Text; var MassCaption: Text)
    begin
    end;

    var
        IDYSSetup: Record "IDYS Setup";
        SetupLoaded: Boolean;
}