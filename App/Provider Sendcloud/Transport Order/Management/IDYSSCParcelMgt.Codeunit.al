codeunit 11147707 "IDYS SC Parcel Mgt."
{
    Permissions = TableData "Sales Shipment Line" = imd, TableData "Sales Shipment Header" = imd;

    procedure CreatePackageRequestContent(TransportOrderHeader: Record "IDYS Transport Order Header") RequestObject: JsonObject
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        Parcels: JsonArray;
        Parcel: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeCreatePackageRequestContent(TransportOrderHeader, RequestObject, IsHandled);
            if IsHandled then
                exit(RequestObject);
        end;


        TransportOrderPackage.SetRange("Transport Order No.", TransportOrderHeader."No.");
        TransportOrderPackage.SetRange("On Hold", false);
        if TransportOrderPackage.FindSet() then
            repeat
                Clear(Parcel);
                Parcel := CreateBaseParcel(TransportOrderHeader, TransportOrderPackage);
                AddParcelInformation(Parcel, TransportOrderHeader, TransportOrderPackage);
                Parcels.Add(Parcel);
            until TransportOrderPackage.Next() = 0;

        RequestObject.Add('parcels', Parcels);

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterCreatePackageRequestContent(TransportOrderHeader, RequestObject);

        exit(RequestObject);
    end;

    procedure CreateRequestContent_Update(TransportOrderHeader: Record "IDYS Transport Order Header"; TransportOrderPackage: Record "IDYS Transport Order Package"): JsonObject
    var
        Parcel: JsonObject;
        RequestObject: JsonObject;
    begin
        Clear(Parcel);
        Parcel := CreateBaseParcel(TransportOrderHeader, TransportOrderPackage);

        IDYMJSONHelper.AddVariantValue(Parcel, 'id', TransportOrderPackage."Sendcloud Parcel Id.");
        AddParcelInformation(Parcel, TransportOrderHeader, TransportOrderPackage);

        RequestObject.Add('parcel', Parcel);

        exit(RequestObject);
    end;

    local procedure CreateBaseParcel(TransportOrderHeader: Record "IDYS Transport Order Header"; TransportOrderPackage: Record "IDYS Transport Order Package") Parcel_Base: JsonObject
    var
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeCreateBaseParcel(TransportOrderHeader, TransportOrderPackage, Parcel_Base, IsHandled);
            if IsHandled then
                exit(Parcel_Base);
        end;

        Clear(Parcel_Base);
        IDYSSendcloudSetup.GetProviderSetup("IDYS Provider"::Sendcloud);
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'name', CopyStr(TransportOrderHeader."Name (Ship-to)", 1, 32));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'company_name', CopyStr(TransportOrderHeader."Name (Ship-to)", 1, 32));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'address', CopyStr(TransportOrderHeader."Address (Ship-to)", 1, 35));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'address_2', CopyStr(TransportOrderHeader."Address 2 (Ship-to)", 1, 35));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'house_number', TransportOrderHeader."House No. (Ship-to)");
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'city', CopyStr(TransportOrderHeader."City (Ship-to)", 1, 20));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'postal_code', TransportOrderHeader."Post Code (Ship-to)");
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'to_post_number', TransportOrderHeader."Recipient PO Box No.");
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'country', IDYSSCShippingMethodMgt.GetCountryRegionISOCode(TransportOrderHeader."Country/Region Code (Ship-to)"));

        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'is_return', TransportOrderHeader."Is Return");

        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'from_name', CopyStr(TransportOrderHeader."Name (Pick-up)", 1, 32));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'from_address_1', CopyStr(TransportOrderHeader."Street (Pick-up)", 1, 35));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'from_house_number', TransportOrderHeader."House No. (Pick-up)");
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'from_city', CopyStr(TransportOrderHeader."City (Pick-up)", 1, 20));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'from_postal_code', TransportOrderHeader."Post Code (Pick-up)");
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'from_country', IDYSSCShippingMethodMgt.GetCountryRegionISOCode(TransportOrderHeader."Country/Region Code (Pick-up)"));
        if TransportOrderHeader."Mobile Phone No. (Pick-up)" <> '' then
            IDYMJSONHelper.AddVariantValue(Parcel_Base, 'from_telephone', CopyStr(TransportOrderHeader."Mobile Phone No. (Pick-up)", 1, 14))
        else
            IDYMJSONHelper.AddVariantValue(Parcel_Base, 'from_telephone', CopyStr(TransportOrderHeader."Phone No. (Pick-up)", 1, 14));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'from_email', TransportOrderHeader."E-Mail (Pick-up)");

        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'country_state', TransportOrderHeader."County (Ship-to)");
        if TransportOrderHeader."Mobile Phone No. (Ship-to)" <> '' then
            IDYMJSONHelper.AddVariantValue(Parcel_Base, 'telephone', CopyStr(TransportOrderHeader."Mobile Phone No. (Ship-to)", 1, 14))
        else
            IDYMJSONHelper.AddVariantValue(Parcel_Base, 'telephone', CopyStr(TransportOrderHeader."Phone No. (Ship-to)", 1, 14));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'email', CopyStr(TransportOrderHeader."E-Mail (Ship-to)", 1, 50));
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'customs_invoice_nr', TransportOrderHeader."Customs Invoice No.");
        IDYMJSONHelper.AddVariantValue(Parcel_Base, 'customs_shipment_type', TransportOrderHeader."Customs Shipment Type");

        if IDYSSendcloudSetup."Apply External Document No." and (TransportOrderHeader."External Document No." <> '') then
            if TransportOrderPackage."Additional Reference" <> '' then
                IDYMJSONHelper.AddVariantValue(Parcel_Base, 'order_number', TransportOrderHeader."External Document No." + ' ' + TransportOrderPackage."Additional Reference")
            else
                IDYMJSONHelper.AddVariantValue(Parcel_Base, 'order_number', TransportOrderHeader."External Document No.")
        else
            if TransportOrderPackage."Additional Reference" <> '' then
                IDYMJSONHelper.AddVariantValue(Parcel_Base, 'order_number', TransportOrderHeader."Source Document No." + ' ' + TransportOrderPackage."Additional Reference")
            else
                IDYMJSONHelper.AddVariantValue(Parcel_Base, 'order_number', TransportOrderHeader."Source Document No.");

        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterCreateBaseParcel(TransportOrderHeader, TransportOrderPackage, Parcel_Base);
        exit(Parcel_Base);
    end;

    local procedure AddParcelInformation(var Parcel: JsonObject; var TransportOrderHeader: Record "IDYS Transport Order Header"; TransportOrderPackage: Record "IDYS Transport Order Package")
    var
        ProviderCarrier: Record "IDYS Provider Carrier";
        IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        Parcel_Items: JsonArray;
        Parcel_Item: JsonObject;
        Shipment: JsonObject;
        PackageWeight: Decimal;
        IsHandled: Boolean;
    begin
        IDYSSendcloudSetup.GetProviderSetup("IDYS Provider"::Sendcloud);

        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeAddParcelInformation(Parcel, TransportOrderHeader, TransportOrderPackage, IsHandled);
            if IsHandled then
                exit;
        end;
        IDYMJSONHelper.AddVariantValue(Parcel, 'request_label', TransportOrderPackage."Request Label");
        IDYMJSONHelper.AddVariantValue(Parcel, 'external_reference', TransportOrderPackage."Parcel Identifier");

        if TransportOrderPackage."Request Label" and IDYSSendcloudSetup."Apply Shipping Rules" then
            IDYMJSONHelper.AddVariantValue(Parcel, 'apply_shipping_rules', IDYSSendcloudSetup."Apply Shipping Rules");
        if TransportOrderPackage."Insured Value" <> 0 then
            IDYMJSONHelper.AddVariantValue(Parcel, 'insured_value', TransportOrderPackage."Insured Value");
        if TransportOrderPackage."Total Insured Value" <> 0 then
            IDYMJSONHelper.AddVariantValue(Parcel, 'total_insured_value', TransportOrderPackage."Total Insured Value");

        Clear(Shipment);
        IDYMJSONHelper.AddVariantValue(Shipment, 'id', TransportOrderPackage."Shipping Method Id");
        Parcel.Add('shipment', Shipment);

        IDYSTransportOrderDelNote.SetRange("Transport Order No.", TransportOrderHeader."No.");
        IDYSTransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", TransportOrderPackage.RecordId);
        if IDYSTransportOrderDelNote.FindSet() then
            repeat
                Clear(Parcel_Item);
                IDYMJSONHelper.AddVariantValue(Parcel_Item, 'description', IDYSTransportOrderDelNote.Description);
                IDYMJSONHelper.AddVariantValue(Parcel_Item, 'quantity', IDYSTransportOrderDelNote.Quantity);
                IDYMJSONHelper.AddVariantValue(Parcel_Item, 'weight', Round(IDYSProviderMgt.GetConversionFactor("IDYS Conversion Type"::Mass, TransportOrderHeader."Carrier Entry No.") * IDYSTransportOrderDelNote."Gross Weight", IDYSProviderMgt.GetRoundingPrecision("IDYS Conversion Type"::Mass, TransportOrderHeader."Carrier Entry No.")));
                IDYMJSONHelper.AddVariantValue(Parcel_Item, 'value', Round(IDYSTransportOrderDelNote.Price, 0.01));
                IDYMJSONHelper.AddVariantValue(Parcel_Item, 'hs_code', IDYSTransportOrderDelNote."HS Code");
                IDYMJSONHelper.AddVariantValue(Parcel_Item, 'origin_country', IDYSTransportOrderDelNote."Country of Origin");
                IDYMJSONHelper.AddVariantValue(Parcel_Item, 'product_id', IDYSTransportOrderDelNote."Article Id");

                if IDYSSessionVariables.CheckAuthorization() then
                    OnAddParcelInformationOnBeforeAddParcelItem(Parcel, TransportOrderHeader, TransportOrderPackage, IDYSTransportOrderDelNote, Parcel_Item);
                Parcel_Items.Add(Parcel_Item);
            until IDYSTransportOrderDelNote.Next() = 0;
        Parcel.Add('parcel_items', Parcel_Items);
        if ProviderCarrier.Get(TransportOrderHeader."Carrier Entry No.") then begin
            PackageWeight := TransportOrderPackage.GetPackageWeight();
            if ProviderCarrier."Use Volume Weight" and (PackageWeight < TransportOrderPackage.Volume) then begin
                TransportOrderPackage.TestField(Volume);
                IDYMJSONHelper.AddVariantValue(Parcel, 'weight', Round(TransportOrderPackage.Volume, 0.001))
            end else
                IDYMJSONHelper.AddVariantValue(Parcel, 'weight', Round(PackageWeight, 0.001));
        end;
        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterAddParcelInformation(Parcel, TransportOrderHeader, TransportOrderPackage);
    end;

    procedure CheckFailedParcels(Response: JsonObject; TransportOrderNo: Code[20]): Boolean
    var
        FailedParcelsTkn: JsonToken;
        FailedParcels: JsonArray;
        FailedParcel: JsonToken;
    begin
        if Response.Contains('failed_parcels') then begin
            if not Response.Get('failed_parcels', FailedParcelsTkn) then
                exit(true);

            if FailedParcelsTkn.IsArray() then begin
                FailedParcels := IDYMJSONHelper.GetArray(Response, 'failed_parcels');

                foreach FailedParcel in FailedParcels do
                    ProcessFailedParcelResponse(FailedParcel.AsObject(), TransportOrderNo);
                exit(true);
            end;
        end;

        exit(false);
    end;

    procedure ContainsSuccessfullyProcessedParcel(Response: JsonObject): Boolean
    var
        ParcelsTkn: JsonToken;
        Parcels: JsonArray;
        Parcel: JsonToken;
    begin
        if not Response.Contains('parcels') then
            exit(false);

        if not Response.Get('parcels', ParcelsTkn) then
            exit(false);

        if ParcelsTkn.IsArray() then begin
            Parcels := IDYMJSONHelper.GetArray(Response, 'parcels');

            foreach Parcel in Parcels do
                if IDYMJSONHelper.GetTextValue(Parcel, 'tracking_number') <> '' then
                    exit(true);
        end;
    end;

    procedure ProcessResponse(Response: JsonObject; TransportOrderNo: Code[20]): Boolean
    var
        ParcelsTkn: JsonToken;
        Parcels: JsonArray;
        Parcel: JsonToken;
    begin
        if not Response.Contains('parcels') then
            exit(false);

        if not Response.Get('parcels', ParcelsTkn) then
            exit(false);

        if ParcelsTkn.IsArray() then begin
            Parcels := IDYMJSONHelper.GetArray(Response, 'parcels');

            foreach Parcel in Parcels do
                ProcessParcelResponse(Parcel.AsObject(), TransportOrderNo);
        end;

        exit(true);
    end;

    procedure ProcessResponse(Response: JsonObject; TransportOrderNo: Code[20]; "Parcel Identifier": Code[30])
    var
        IDYSSCParcelError: Record "IDYS SC Parcel Error";
        Parcels: JsonArray;
        ParcelsTkn: JsonToken;
        Parcel: JsonToken;
        Error: JsonObject;
        ErrorTkn: JsonToken;
        MessageTkn: JsonToken;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeProcessResponse(Response, TransportOrderNo, "Parcel Identifier", IsHandled);
            if IsHandled then
                exit;
        end;

        if not Response.Contains('parcels') then
            exit;

        if not Response.Get('parcels', ParcelsTkn) then
            exit;

        if ParcelsTkn.IsArray() then begin
            Parcels := IDYMJSONHelper.GetArray(Response, 'parcels');

            foreach Parcel in Parcels do
                ProcessParcelResponse(Parcel.AsObject(), TransportOrderNo);
        end;

        if Response.Contains('error') then begin
            ErrorTkn := IDYMJSONHelper.GetToken(Response, 'error');
            if ErrorTkn.IsObject() then begin
                Error := ErrorTkn.AsObject();
                IDYSSCParcelError.Init();
                IDYSSCParcelError."Transport Order No." := TransportOrderNo;
                IDYSSCParcelError."Parcel Identifier" := "Parcel Identifier";
                IDYSSCParcelError."Error Message" := CopyStr(IDYMJSONHelper.GetTextValue(Error, 'message'), 1, MaxStrLen(IDYSSCParcelError."Error Message"));
                IDYSSCParcelError.Insert(true);
            end;
        end;

        if Response.Contains('message') then begin
            MessageTkn := IDYMJSONHelper.GetToken(Response, 'message');
            if MessageTkn.IsValue() then begin
                IDYSSCParcelError.Init();
                IDYSSCParcelError."Transport Order No." := TransportOrderNo;
                IDYSSCParcelError."Parcel Identifier" := "Parcel Identifier";
                IDYSSCParcelError."Error Message" := CopyStr(IDYMJSONHelper.GetTextValue(Response, 'message'), 1, MaxStrLen(IDYSSCParcelError."Error Message"));
                IDYSSCParcelError.Insert(true);
            end;
        end;
    end;

    procedure ProcessResponse_status(Response: JsonObject; TransportOrderNo: Code[20]; SendcloudParcelId: Integer)
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        ParcelTkn: JsonToken;
        ParcelObj: JsonObject;
        StatusTkn: JsonToken;
        Status: JsonObject;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeProcessResponse_status(Response, TransportOrderNo, SendcloudParcelId, IsHandled);
            if IsHandled then
                exit;
        end;

        TransportOrderPackage.SetRange("Transport Order No.", TransportOrderNo);
        TransportOrderPackage.SetRange("Sendcloud Parcel Id.", SendcloudParcelId);
        if TransportOrderPackage.FindFirst() then begin
            if not Response.Contains('parcel') then
                exit;
            ParcelTkn := IDYMJSONHelper.GetToken(Response, 'parcel');
            if ParcelTkn.IsObject() then begin
                ParcelObj := ParcelTkn.AsObject();
                if not ParcelObj.Contains('status') then
                    exit;
                StatusTkn := IDYMJSONHelper.GetToken(ParcelObj, 'status');
                if StatusTkn.IsObject() then begin
                    Status := StatusTkn.AsObject();
                    TransportOrderPackage.Validate(Status, CopyStr(IDYMJSONHelper.GetTextValue(Status, 'message'), 1, MaxStrLen(TransportOrderPackage.Status)));
                    TransportOrderPackage.Modify(true);
                end;
            end;
        end;
    end;

    local procedure ProcessParcelResponse(Response: JsonObject; TransportOrderNo: Code[20])
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        TransportOrderHeader: Record "IDYS Transport Order Header";
        ParcelIdentifier: Code[30];
        Status: JsonObject;
        StatusTkn: JsonToken;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeProcessParcelResponse(Response, TransportOrderNo, IsHandled);
            if IsHandled then
                exit;
        end;

        ParcelIdentifier := CopyStr(IDYMJSONHelper.GetCodeValue(Response, 'external_reference'), 1, MaxStrLen(ParcelIdentifier));

        TransportOrderHeader.Get(TransportOrderNo);
        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Parcel Identifier", ParcelIdentifier);
        TransportOrderPackage.SetRange("Transport Order No.", TransportOrderNo);
        if TransportOrderPackage.FindFirst() then begin
            if Response.Contains('status') then begin
                StatusTkn := IDYMJSONHelper.GetToken(Response, 'status');
                if StatusTkn.IsObject() then begin
                    Status := StatusTkn.AsObject();
                    TransportOrderPackage.Validate(Status, CopyStr(IDYMJSONHelper.GetTextValue(Status, 'message'), 1, MaxStrLen(TransportOrderPackage.Status)));
                end;
            end;
            TransportOrderPackage."Sendcloud Parcel Id." := IDYMJSONHelper.GetIntegerValue(Response, 'id');
            TransportOrderPackage.Created := CopyStr(IDYMJSONHelper.GetTextValue(Response, 'date_created'), 1, MaxStrLen(TransportOrderPackage.Created));
            TransportOrderPackage."Tracking No." := CopyStr(IDYMJSONHelper.GetTextValue(Response, 'tracking_number'), 1, MaxStrLen(TransportOrderPackage."Tracking No."));
            TransportOrderPackage."Tracking URL" := CopyStr(IDYMJSONHelper.GetTextValue(Response, 'tracking_url'), 1, MaxStrLen(TransportOrderPackage."Tracking URL"));

            if Response.Contains('label') and (TransportOrderPackage."Request Label") then
                GetPDFLabel(TransportOrderHeader, TransportOrderPackage, IDYMJSONHelper.GetObject(Response, 'label'));

            TransportOrderPackage.Modify(true);
        end;
    end;

    local procedure ProcessFailedParcelResponse(Response: JsonObject; TransportOrderNo: Code[20])
    var
        IDYSSCParcelError: Record "IDYS SC Parcel Error";
        TransportOrderPackage: Record "IDYS Transport Order Package";
        Parcel: JsonObject;
        Error: JsonObject;
        FieldError: JsonObject;
        ErrorKeys: List of [Text];
        FieldErrorKeys: List of [Text];
        ErrorKey: Text;
        FieldErrorKey: Text;
        FieldErrorMessage: Text;
        ErrorValues: JsonArray;
        FieldErrorMessageValues: JsonArray;
        FieldErrorValues: JsonArray;
        ErrorValuesTkn: JsonToken;
        ErrorValueTkn: JsonToken;
        FieldErrorValuesTkn: JsonToken;
        FieldErrorValueTkn: JsonToken;
        FieldErrorMessageValueTkn: JsonToken;
        ErrorTkn: JsonToken;
        ParcelTkn: JsonToken;
        ErrorString: Text;
        FieldErr: Label 'Field %1 failed with the following error: %2', Comment = '%1 = Fieldname, %2 = Errormessage';
    begin
        if Response.Contains('parcel') then
            ParcelTkn := IDYMJSONHelper.GetToken(Response, 'parcel')
        else
            exit;

        if not ParcelTkn.IsObject() then
            exit;

        Parcel := ParcelTkn.AsObject();

        if Response.Contains('errors') then
            ErrorTkn := IDYMJSONHelper.GetToken(Response, 'errors')
        else
            exit;

        if ErrorTkn.IsObject() then begin
            Error := ErrorTkn.AsObject();
            ErrorKeys := Error.Keys;
            foreach ErrorKey in ErrorKeys do begin
                ErrorValuesTkn := IDYMJSONHelper.GetToken(Error, ErrorKey);
                if ErrorValuesTkn.IsArray() then begin
                    ErrorValues := ErrorValuesTkn.AsArray();
                    foreach ErrorValueTkn in ErrorValues do
                        if ErrorValueTkn.IsObject then begin
                            FieldError := ErrorValueTkn.AsObject();
                            FieldErrorKeys := FieldError.Keys;
                            foreach FieldErrorKey in FieldErrorKeys do begin
                                FieldErrorValuesTkn := IDYMJSONHelper.GetToken(FieldError, FieldErrorKey);
                                if FieldErrorValuesTkn.IsArray() then begin
                                    FieldErrorValues := FieldErrorValuesTkn.AsArray();
                                    foreach FieldErrorValueTkn in FieldErrorValues do begin
                                        IDYSSCParcelError.Init();
                                        IDYSSCParcelError."Entry No." := 0;
                                        IDYSSCParcelError."Transport Order No." := TransportOrderNo;
                                        IDYSSCParcelError."Parcel Identifier" := CopyStr(IDYMJSONHelper.GetCodeValue(Parcel, 'external_reference'), 1, MaxStrLen(IDYSSCParcelError."Parcel Identifier"));
                                        if FieldErrorValuesTkn.IsArray() then begin
                                            Clear(FieldErrorMessage);
                                            FieldErrorMessageValues := FieldErrorValuesTkn.AsArray();
                                            foreach FieldErrorMessageValueTkn in FieldErrorMessageValues do
                                                if FieldErrorMessageValueTkn.IsValue() then
                                                    if FieldErrorMessage = '' then
                                                        FieldErrorMessage := FieldErrorMessageValueTkn.AsValue().AsText()
                                                    else
                                                        FieldErrorMessage += ', ' + FieldErrorMessageValueTkn.AsValue().AsText();
                                            IDYSSCParcelError."Error Message" := CopyStr(StrSubstNo(FieldErr, FieldErrorKey, FieldErrorMessage), 1, MaxStrLen(IDYSSCParcelError."Error Message"));
                                        end;
                                        IDYSSCParcelError.Insert(true);
                                    end;
                                end else begin
                                    IDYSSCParcelError.Init();
                                    IDYSSCParcelError."Entry No." := 0;
                                    IDYSSCParcelError."Transport Order No." := TransportOrderNo;
                                    IDYSSCParcelError."Parcel Identifier" := CopyStr(IDYMJSONHelper.GetCodeValue(Parcel, 'external_reference'), 1, MaxStrLen(IDYSSCParcelError."Parcel Identifier"));
                                    if FieldErrorValuesTkn.IsValue() then
                                        IDYSSCParcelError."Error Message" := CopyStr(StrSubstNo(FieldErr, FieldErrorKey, FieldErrorValuesTkn.AsValue().AsText()), 1, MaxStrLen(IDYSSCParcelError."Error Message"));
                                    IDYSSCParcelError.Insert(true);
                                end;
                            end;
                        end else begin
                            IDYSSCParcelError.Init();
                            IDYSSCParcelError."Entry No." := 0;
                            IDYSSCParcelError."Transport Order No." := TransportOrderNo;
                            IDYSSCParcelError."Parcel Identifier" := CopyStr(IDYMJSONHelper.GetCodeValue(Parcel, 'external_reference'), 1, MaxStrLen(IDYSSCParcelError."Parcel Identifier"));
                            if ErrorValueTkn.IsValue() then
                                IDYSSCParcelError."Error Message" := CopyStr(ErrorKey + ': ' + ErrorValueTkn.AsValue().AsText(), 1, MaxStrLen(IDYSSCParcelError."Error Message"));
                            IDYSSCParcelError.Insert(true);
                        end;
                end else begin
                    IDYSSCParcelError.Init();
                    IDYSSCParcelError."Entry No." := 0;
                    IDYSSCParcelError."Transport Order No." := TransportOrderNo;
                    IDYSSCParcelError."Parcel Identifier" := CopyStr(IDYMJSONHelper.GetCodeValue(Parcel, 'external_reference'), 1, MaxStrLen(IDYSSCParcelError."Parcel Identifier"));
                    ErrorValuesTkn.WriteTo(ErrorString);
                    IDYSSCParcelError."Error Message" := CopyStr(ErrorString, 1, MaxStrLen(IDYSSCParcelError."Error Message"));
                    IDYSSCParcelError.Insert(true);
                end;
            end;
        end else begin
            IDYSSCParcelError.Init();
            IDYSSCParcelError."Entry No." := 0;
            IDYSSCParcelError."Transport Order No." := TransportOrderNo;
            IDYSSCParcelError."Parcel Identifier" := CopyStr(IDYMJSONHelper.GetCodeValue(Parcel, 'external_reference'), 1, MaxStrLen(IDYSSCParcelError."Parcel Identifier"));
            ErrorTkn.WriteTo(ErrorString);
            IDYSSCParcelError."Error Message" := CopyStr(ErrorString, 1, MaxStrLen(IDYSSCParcelError."Error Message"));
            IDYSSCParcelError.Insert(true);
        end;

        TransportOrderPackage.Reset();
        TransportOrderPackage.SetRange("Parcel Identifier", IDYMJSONHelper.GetCodeValue(Parcel, 'external_reference'));
        TransportOrderPackage.SetRange("Transport Order No.", TransportOrderNo);
        if TransportOrderPackage.FindFirst() then begin
            TransportOrderPackage.Validate(Status, 'Error');
            TransportOrderPackage.Modify(true);
        end;
    end;

    local procedure GetPDFLabel(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportOrderPackage: Record "IDYS Transport Order Package"; Response: JsonObject)
    var
        ShippingAgent: Record "Shipping Agent";
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        Statuscode: Integer;
        HttpContent: HttpContent;
        NormalPrinter: JsonArray;
        NormalPrinterTkn: JsonToken;
        NormalPrinterVal: JsonValue;
        ContentInStream: InStream;
        ContentOutStream: OutStream;
        PDFFileNameLbl: Label 'label-%1.pdf', Locked = true;
        LabelType: Enum "IDYS SC Label Type";
        PathTxt: Text;
        IsHandled: Boolean;
    begin
        if IDYSSessionVariables.CheckAuthorization() then begin
            OnBeforeGetPDFLabel(TransportOrderHeader, TransportOrderPackage, Response, IsHandled);
            if IsHandled then
                exit;
        end;

        if Response.Keys.Count() = 0 then begin
            MissingLabelNotification();
            exit;
        end;

        IDYSSendcloudSetup.GetProviderSetup("IDYS Provider"::Sendcloud);
        LabelType := IDYSSendcloudSetup."Label Type";
        if ShippingAgent.Get(TransportOrderHeader."Shipping Agent Code") and ShippingAgent."IDYS SC Change Label Settings" then
            LabelType := ShippingAgent."IDYS SC Label Type";

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;

        if LabelType = LabelType::"Label Printer" then begin
            if IDYMJSONHelper.GetTextValue(Response, 'label_printer') = '' then begin
                MissingLabelNotification();
                exit;
            end;
            PathTxt := CopyStr(IDYMJSONHelper.GetTextValue(Response, 'label_printer'), StrPos(IDYMJSONHelper.GetTextValue(Response, 'label_printer'), '/labels/label_printer'));
        end else begin
            NormalPrinter := IDYMJSONHelper.GetArray(Response, 'normal_printer');
            if NormalPrinter.Count() = 0 then begin
                MissingLabelNotification();
                exit;
            end;

            case LabelType of
                LabelType::"Bottom Left":
                    NormalPrinter.Get(0, NormalPrinterTkn);
                LabelType::"Top Left":
                    NormalPrinter.Get(1, NormalPrinterTkn);
                LabelType::"Bottom Right":
                    NormalPrinter.Get(2, NormalPrinterTkn);
                LabelType::"Top Right":
                    NormalPrinter.Get(3, NormalPrinterTkn);
            end;
            if NormalPrinterTkn.IsValue() then begin
                NormalPrinterVal := NormalPrinterTkn.AsValue();
                PathTxt := CopyStr(NormalPrinterVal.AsText(), StrPos(NormalPrinterVal.AsText(), '/labels/normal_printer'));
            end;
        end;
        TempIDYMRESTParameters.Path := CopyStr(PathTxt, 1, MaxStrLen(TempIDYMRESTParameters.Path));
        StatusCode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);
        if StatusCode = 200 then begin
            IDYSSCParcelDocument.Init();
            IDYSSCParcelDocument."Parcel Identifier" := TransportOrderPackage."Parcel Identifier";
            IDYSSCParcelDocument."Transport Order No." := TransportOrderPackage."Transport Order No.";
            IDYSSCParcelDocument."File Name" := StrSubstNo(PDFFileNameLbl, TransportOrderPackage."Parcel Identifier");
            IDYSSCParcelDocument."File".CreateInStream(ContentInStream);

            TempIDYMRESTParameters.GetResponseContent(HttpContent);
            HttpContent.ReadAs(ContentInStream);

            IDYSSCParcelDocument."File".CreateOutStream(ContentOutStream);
            CopyStream(ContentOutStream, ContentInStream);
            if IDYSSessionVariables.CheckAuthorization() then
                OnGetPDFLabelOnBeforeInsertParcelDocument(TransportOrderHeader, TransportOrderPackage, Response, IDYSSCParcelDocument);
            IDYSSCParcelDocument.Insert(true);
        end;
        if IDYSSessionVariables.CheckAuthorization() then
            OnAfterGetPDFLabel(TransportOrderHeader, TransportOrderPackage, Response);
    end;

    local procedure MissingLabelNotification()
    var
        NoPrintableLabelTok: Label '2cdff13f-6bf7-45f5-9064-7084895dfefa', Locked = true;
        NoPrintableLabelErr: Label 'A printable label was requested, but it''s not provided by the carrier. More information can be found on the portal.';
    begin
        IDYSNotificationManagment.SendNotification(NoPrintableLabelTok, NoPrintableLabelErr);
    end;

    procedure CleanErrors(TransportOrderNo: Code[20])
    var
        IDYSSCParcelError: Record "IDYS SC Parcel Error";
    begin
        IDYSSCParcelError.SetRange("Transport Order No.", TransportOrderNo);
        IDYSSCParcelError.DeleteAll();
    end;

    [Obsolete('Authorization is now associated with the license key', '23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnSetAuthorization(var Authorization: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateBaseParcel(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportOrderPackage: Record "IDYS Transport Order Package"; var Parcel_Base: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateBaseParcel(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportOrderPackage: Record "IDYS Transport Order Package"; var Parcel_Base: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePackageRequestContent(TransportOrderHeader: Record "IDYS Transport Order Header"; var RequestObject: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePackageRequestContent(TransportOrderHeader: Record "IDYS Transport Order Header"; var RequestObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddParcelInformation(var Parcel: JsonObject; var TransportOrderHeader: Record "IDYS Transport Order Header"; TransportOrderPackage: Record "IDYS Transport Order Package"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddParcelInformationOnBeforeAddParcelItem(var Parcel: JsonObject; var TransportOrderHeader: Record "IDYS Transport Order Header"; TransportOrderPackage: Record "IDYS Transport Order Package"; IDYSTransportOrderDelNote: Record "IDYS Transport Order Del. Note"; var Parcel_Item: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddParcelInformation(var Parcel: JsonObject; var TransportOrderHeader: Record "IDYS Transport Order Header"; TransportOrderPackage: Record "IDYS Transport Order Package")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessResponse(Response: JsonObject; TransportOrderNo: Code[20]; ParcelIdentifier: Code[30]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessResponse_status(Response: JsonObject; TransportOrderNo: Code[20]; SendcloudParcelId: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessParcelResponse(Response: JsonObject; TransportOrderNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPDFLabel(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportOrderPackage: Record "IDYS Transport Order Package"; Response: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPDFLabel(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportOrderPackage: Record "IDYS Transport Order Package"; Response: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPDFLabelOnBeforeInsertParcelDocument(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportOrderPackage: Record "IDYS Transport Order Package"; Response: JsonObject; var IDYSSCParcelDocument: Record "IDYS SC Parcel Document")
    begin
    end;

    var
        IDYSSendcloudSetup: Record "IDYS Setup";
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        IDYSSCShippingMethodMgt: Codeunit "IDYS SC Shipping Method Mgt.";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        IDYSNotificationManagment: Codeunit "IDYS Notification Management";
}