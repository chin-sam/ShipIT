codeunit 11147675 "IDYS Upgrade Functions"
{
#pragma warning disable AL0432
    Access = Internal;

    trigger OnRun()
    var
        ModInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModInfo);

        if ModInfo.DataVersion < Version.Create(18, 5, 10000, 0) then
            InitTransportOrderDocumentDate();

        if ModInfo.DataVersion < Version.Create(18, 5, 10000, 0) then begin
            MoveCustomerSetupToCustomer();
            MoveShiptoAddressSetupToShiptoAddress();
            MoveVendorSetupToVendor();
            MoveOrderAddressSetupToShiptoAddress();
        end;
        PopulateExternalCountryCodeInvoiceOnTransportOrder();
        PopulateQtyBaseOnTransportOrderLines();
        PopulateAfterPostSalesReturnOrder();
        RemoveEmptyJobQueueEntries();
        MigrateLicenseKeyAndCredentials();
        PopulatePickUpAndDeliveryDT();
        MigrateToProviderLevel();
        AddConversionFactor();
        MigrateItemUOMToProviderLevel();
        MigrateSalesOrderPackages();
        MigrateSurchargeDetails();
        EnableSendcloud();
        MigrateItemUOMPackages();
        AddDefaultServices();
        MigrateProviderSetup();
        MigrateDelHubDenyCountriesData();
        MigratePackageLabelData();
        UpdateDeliveryHubEndpoints();
        ResetVideos();
        MigrateShipmentLabelData();
        InitializeSkipSourceDocsUpdafterTO();
        InitializeTransportOrderSync();
        //MigratePurchHeaderAccNoBillTo();
        UpdateEasyPostDefaultLabelType();
        UpdateTransportOrderLines();
        UpdateAddressTypeSourceData();
        UpdateDeliveryNoteQuantityUOM();
    end;

    internal procedure UpdateDeliveryNoteQuantityUOM()
    var
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        TransportOrderLine: Record "IDYS Transport Order Line";
        Item: Record Item;
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.GetUpdateDeliveryNoteQuantityUOMTag()) then
            exit;

        if TransportOrderDelNote.FindSet(true) then
            repeat
                TransportOrderLine.SetRange("Transport Order No.", TransportOrderDelNote."Transport Order No.");
                TransportOrderLine.SetRange("Line No.", TransportOrderDelNote."Transport Order Line No.");
                TransportOrderLine.SetFilter("Item No.", '<>%1', '');
                if TransportOrderLine.FindLast() then begin
                    Item.SetRange("No.", TransportOrderLine."Item No.");
                    Item.SetFilter("Base Unit of Measure", '<>%1', '');
                    if Item.FindLast() then begin
                        TransportOrderDelNote.Validate("Quantity UOM", Item."Base Unit of Measure");
                        TransportOrderDelNote.Modify();
                    end;
                end;
            until TransportOrderDelNote.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.GetUpdateDeliveryNoteQuantityUOMTag());
    end;

    internal procedure UpdateAddressTypeSourceData()
    var
        IDYSTransportWorksheetLine: Record "IDYS Transport Worksheet Line";
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.GetUpdateAddressTypeSourceDataTag()) then
            exit;

        if IDYSTransportWorksheetLine.FindSet(true) then
            repeat
                // Pick-up
                case IDYSTransportWorksheetLine."Type (Pick-up)" of
                    IDYSTransportWorksheetLine."Type (Pick-up)"::Company:
                        IDYSTransportWorksheetLine."Source Type (Pick-up)" := IDYSTransportWorksheetLine."Source Type (Pick-up)"::Company;
                    IDYSTransportWorksheetLine."Type (Pick-up)"::Customer:
                        IDYSTransportWorksheetLine."Source Type (Pick-up)" := IDYSTransportWorksheetLine."Source Type (Pick-up)"::Customer;
                    IDYSTransportWorksheetLine."Type (Pick-up)"::Location:
                        IDYSTransportWorksheetLine."Source Type (Pick-up)" := IDYSTransportWorksheetLine."Source Type (Pick-up)"::Location;
                    IDYSTransportWorksheetLine."Type (Pick-up)"::Vendor:
                        IDYSTransportWorksheetLine."Source Type (Pick-up)" := IDYSTransportWorksheetLine."Source Type (Pick-up)"::Vendor;
                end;

                // Ship-to
                case IDYSTransportWorksheetLine."Type (Ship-to)" of
                    IDYSTransportWorksheetLine."Type (Ship-to)"::Company:
                        IDYSTransportWorksheetLine."Source Type (Ship-to)" := IDYSTransportWorksheetLine."Source Type (Ship-to)"::Company;
                    IDYSTransportWorksheetLine."Type (Ship-to)"::Customer:
                        IDYSTransportWorksheetLine."Source Type (Ship-to)" := IDYSTransportWorksheetLine."Source Type (Ship-to)"::Customer;
                    IDYSTransportWorksheetLine."Type (Ship-to)"::Location:
                        IDYSTransportWorksheetLine."Source Type (Ship-to)" := IDYSTransportWorksheetLine."Source Type (Ship-to)"::Location;
                    IDYSTransportWorksheetLine."Type (Ship-to)"::Vendor:
                        IDYSTransportWorksheetLine."Source Type (Ship-to)" := IDYSTransportWorksheetLine."Source Type (Ship-to)"::Vendor;
                end;

                // Invoice
                case IDYSTransportWorksheetLine."Type (Invoice)" of
                    IDYSTransportWorksheetLine."Type (Invoice)"::Company:
                        IDYSTransportWorksheetLine."Source Type (Invoice)" := IDYSTransportWorksheetLine."Source Type (Invoice)"::Company;
                    IDYSTransportWorksheetLine."Type (Invoice)"::Customer:
                        IDYSTransportWorksheetLine."Source Type (Invoice)" := IDYSTransportWorksheetLine."Source Type (Invoice)"::Customer;
                end;
                IDYSTransportWorksheetLine.Modify();
            until IDYSTransportWorksheetLine.Next() = 0;

        if IDYSTransportOrderHeader.FindSet(true) then
            repeat
                // Pick-up
                case IDYSTransportOrderHeader."Type (Pick-up)" of
                    IDYSTransportOrderHeader."Type (Pick-up)"::Company:
                        IDYSTransportOrderHeader."Source Type (Pick-up)" := IDYSTransportOrderHeader."Source Type (Pick-up)"::Company;
                    IDYSTransportOrderHeader."Type (Pick-up)"::Customer:
                        IDYSTransportOrderHeader."Source Type (Pick-up)" := IDYSTransportOrderHeader."Source Type (Pick-up)"::Customer;
                    IDYSTransportOrderHeader."Type (Pick-up)"::Location:
                        IDYSTransportOrderHeader."Source Type (Pick-up)" := IDYSTransportOrderHeader."Source Type (Pick-up)"::Location;
                    IDYSTransportOrderHeader."Type (Pick-up)"::Vendor:
                        IDYSTransportOrderHeader."Source Type (Pick-up)" := IDYSTransportOrderHeader."Source Type (Pick-up)"::Vendor;
                end;

                // Ship-to
                case IDYSTransportOrderHeader."Type (Ship-to)" of
                    IDYSTransportOrderHeader."Type (Ship-to)"::Company:
                        IDYSTransportOrderHeader."Source Type (Ship-to)" := IDYSTransportOrderHeader."Source Type (Ship-to)"::Company;
                    IDYSTransportOrderHeader."Type (Ship-to)"::Customer:
                        IDYSTransportOrderHeader."Source Type (Ship-to)" := IDYSTransportOrderHeader."Source Type (Ship-to)"::Customer;
                    IDYSTransportOrderHeader."Type (Ship-to)"::Location:
                        IDYSTransportOrderHeader."Source Type (Ship-to)" := IDYSTransportOrderHeader."Source Type (Ship-to)"::Location;
                    IDYSTransportOrderHeader."Type (Ship-to)"::Vendor:
                        IDYSTransportOrderHeader."Source Type (Ship-to)" := IDYSTransportOrderHeader."Source Type (Ship-to)"::Vendor;
                end;

                // Invoice
                case IDYSTransportOrderHeader."Type (Invoice)" of
                    IDYSTransportOrderHeader."Type (Invoice)"::Company:
                        IDYSTransportOrderHeader."Source Type (Invoice)" := IDYSTransportOrderHeader."Source Type (Invoice)"::Company;
                    IDYSTransportOrderHeader."Type (Invoice)"::Customer:
                        IDYSTransportOrderHeader."Source Type (Invoice)" := IDYSTransportOrderHeader."Source Type (Invoice)"::Customer;
                end;
                IDYSTransportOrderHeader.Modify();
            until IDYSTransportOrderHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.GetUpdateAddressTypeSourceDataTag());
    end;

    internal procedure UpdateTransportOrderLines()
    var
        IDYSTransportOrderLine: Record "IDYS Transport Order Line";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        ServiceShipmentLine: Record "Service Shipment Line";
        TransferLine: Record "Transfer Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.UpdateTransportOrderLinesTag()) then
            exit;

        if IDYSTransportOrderLine.FindSet(true) then
            repeat
                case IDYSTransportOrderLine."Source Document Table No." of
                    Database::"Sales Header":
                        if SalesLine.Get(IDYSTransportOrderLine."Source Document Type", IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.") then
                            if SalesLine."Item Category Code" <> '' then begin
                                IDYSTransportOrderLine."Item Category Code" := SalesLine."Item Category Code";
                                IDYSTransportOrderLine.Modify();
                            end;
                    Database::"Purchase Header":
                        if PurchaseLine.Get(IDYSTransportOrderLine."Source Document Type", IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.") then
                            if PurchaseLine."Item Category Code" <> '' then begin
                                IDYSTransportOrderLine."Item Category Code" := PurchaseLine."Item Category Code";
                                IDYSTransportOrderLine.Modify();
                            end;
                    Database::"Service Header":
                        if ServiceLine.Get(IDYSTransportOrderLine."Source Document Type", IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.") then
                            if ServiceLine."Item Category Code" <> '' then begin
                                IDYSTransportOrderLine."Item Category Code" := ServiceLine."Item Category Code";
                                IDYSTransportOrderLine.Modify();
                            end;
                    Database::"Sales Shipment Header":
                        if SalesShipmentLine.Get(IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.") then
                            if SalesShipmentLine."Item Category Code" <> '' then begin
                                IDYSTransportOrderLine."Item Category Code" := SalesShipmentLine."Item Category Code";
                                IDYSTransportOrderLine.Modify();
                            end;
                    Database::"Return Shipment Header":
                        if ReturnShipmentLine.Get(IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.") then
                            if ReturnShipmentLine."Item Category Code" <> '' then begin
                                IDYSTransportOrderLine."Item Category Code" := ReturnShipmentLine."Item Category Code";
                                IDYSTransportOrderLine.Modify();
                            end;
                    Database::"Service Shipment Header":
                        if ServiceShipmentLine.Get(IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.") then
                            if ServiceShipmentLine."Item Category Code" <> '' then begin
                                IDYSTransportOrderLine."Item Category Code" := ServiceShipmentLine."Item Category Code";
                                IDYSTransportOrderLine.Modify();
                            end;
                    Database::"Transfer Header":
                        if TransferLine.Get(IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.") then
                            if TransferLine."Item Category Code" <> '' then begin
                                IDYSTransportOrderLine."Item Category Code" := TransferLine."Item Category Code";
                                IDYSTransportOrderLine.Modify();
                            end;
                    Database::"Transfer Shipment Header":
                        if TransferShipmentLine.Get(IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.") then
                            if TransferShipmentLine."Item Category Code" <> '' then begin
                                IDYSTransportOrderLine."Item Category Code" := TransferShipmentLine."Item Category Code";
                                IDYSTransportOrderLine.Modify();
                            end;
                    Database::"Transfer Receipt Header":
                        if TransferReceiptLine.Get(IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No.") then
                            if TransferReceiptLine."Item Category Code" <> '' then begin
                                IDYSTransportOrderLine."Item Category Code" := TransferReceiptLine."Item Category Code";
                                IDYSTransportOrderLine.Modify();
                            end;
                end;
            until IDYSTransportOrderLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.UpdateTransportOrderLinesTag());
    end;

    internal procedure UpdateEasyPostDefaultLabelType()
    var
        IDYSProviderSetup: Record "IDYS Setup";
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.UpdateEasyPostDefaultLabelTypeTag()) then
            exit;

        if IDYSProviderSetup.Get("IDYS Provider"::EasyPost) then begin
            IDYSProviderSetup."Default Label Type" := IDYSProviderSetup."Default Label Type"::PNG;
            IDYSProviderSetup.Modify();
        end;

        IDYSTransportOrderHeader.SetRange(Provider, IDYSTransportOrderHeader.Provider::EasyPost);
        if IDYSTransportOrderHeader.FindSet() then
            repeat
                IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
                IDYSTransportOrderPackage.ModifyAll("Label Format", IDYSTransportOrderPackage."Label Format"::PNG)
            until IDYSTransportOrderHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.UpdateEasyPostDefaultLabelTypeTag());
    end;

    internal procedure MigratePurchHeaderAccNoBillTo()
    // var
    //     PurchaseHeader: Record "Purchase Header";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.MigratePurchHeaderAccNoBillToTag()) then
            exit;

        // PurchaseHeader.SetFilter("IDYS Account No. (Bill-to)", '<>%1', '');
        // if PurchaseHeader.FindSet(true) then
        //     repeat
        //         PurchaseHeader."IDYS Acc. No. (Bill-to)" := PurchaseHeader."IDYS Account No. (Bill-to)";
        //         PurchaseHeader."IDYS Account No. (Bill-to)" := '';
        //         PurchaseHeader.Modify(false);
        //     until PurchaseHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.MigratePurchHeaderAccNoBillToTag());
    end;

    internal procedure InitializeTransportOrderSync()
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        IDYMEndpointManagement: Codeunit "IDYM Endpoint Management";
        SequenceNo: Integer;
        AppInfo: ModuleInfo;
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.InitializeTransportOrderSyncTag()) then
            exit;

        // OptionMembers = ,,,New,,,Uploaded,,,,,,Booked,,,"Label Printed",,,Recalled,,,,,,Archived,Done,Error,"On Hold";
        TransportOrderHeader.SetFilter(Status, '%1|%2|%3|%4', TransportOrderHeader.Status::Recalled,
                                                                TransportOrderHeader.Status::Archived,
                                                                TransportOrderHeader.Status::Done,
                                                                TransportOrderHeader.Status::Error);
        if TransportOrderHeader.FindSet(true) then
            repeat
                SequenceNo += 1;
                TransportOrderHeader."Sequence No." := SequenceNo;
                TransportOrderHeader.Modify();
            until TransportOrderHeader.Next() = 0;

        NavApp.GetCurrentModuleInfo(AppInfo);
        IDYMEndpointManagement.RegisterEndpoint("IDYM Endpoint Service"::IdynAnalytics, "IDYM Endpoint Usage"::Default, "IDYM Authorization Type"::Bearer, AppInfo.Id);

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.InitializeTransportOrderSyncTag());
    end;

    internal procedure MigrateShipmentLabelData()
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        TempBlob: Codeunit "Temp Blob";
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        SourceRecordRef: RecordRef;
        FileOutStream: OutStream;
        FileInStream: InStream;
        FileName: Text;
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.MigrateShipmentLabelData()) then
            exit;

        TransportOrderHeader.SetAutoCalcFields("Shipment Label Data");
        if TransportOrderHeader.FindSet(true) then
            repeat
                if TransportOrderHeader."Shipment Label Data".HasValue() then begin
                    TransportOrderHeader."Shipment Label Data".CreateInStream(FileInStream);

                    SourceRecordRef.GetTable(TransportOrderHeader);

                    Clear(TempBlob);
                    TempBlob.CreateOutStream(FileOutStream);
                    CopyStream(FileOutStream, FileInStream);
                    IDYSTransportOrderMgt.SaveDocumentAttachmentFromRecRef(SourceRecordRef, TempBlob, FileName, 'zip', false);

                    Clear(TransportOrderHeader."Shipment Label Data");
                    TransportOrderHeader.Modify();
                end;
            until TransportOrderHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.MigrateShipmentLabelData());
    end;

    internal procedure ResetVideos()
    var
        VideoProgressbyUser: Record "IDYS Video Progress by User";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.ResetVideosTag()) then
            exit;
        if not VideoProgressbyUser.IsEmpty() then
            VideoProgressbyUser.DeleteAll();
        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.ResetVideosTag());
    end;

    internal procedure InitializeSkipSourceDocsUpdafterTO()
    var
        Setup: Record "IDYS Setup";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.SkipSourceDocsUpdafterTO()) then
            exit;
        if Setup.Get() then
            if Setup."Base Transport Orders on" = Setup."Base Transport Orders on"::"Posted documents" then begin
                Setup.Validate("Skip Source Docs Upd after TO", true);
                Setup.Modify();
            end;
        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.SkipSourceDocsUpdafterTO());
    end;

    internal procedure UpdateDeliveryHubEndpoints()
    var
        IDYMEndpoint: Record "IDYM Endpoint";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.UpdateDeliveryHubEndpointsTag()) then
            exit;

        if IDYMEndpoint.Get("IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::Default) then begin
            IDYMEndpoint.Validate(Service);
            IDYMEndpoint.Modify();
        end;

        if IDYMEndpoint.Get("IDYM Endpoint Service"::DeliveryHubData, "IDYM Endpoint Usage"::Default) then begin
            IDYMEndpoint.Validate(Service);
            IDYMEndpoint.Modify();
        end;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.UpdateDeliveryHubEndpointsTag());
    end;

    internal procedure MigratePackageLabelData()
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
        FileOutStream: OutStream;
        FileInStream: InStream;
        FilenameLbl: Label '%1.pdf', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.MigratePackageLabelDataTag()) then
            exit;

        TransportOrderPackage.SetAutoCalcFields("Package Label Data");
        if TransportOrderPackage.FindSet(true) then
            repeat
                if TransportOrderPackage."Package Label Data".HasValue() then begin
                    TransportOrderPackage."Package Label Data".CreateInStream(FileInStream);

                    IDYSSCParcelDocument.Init();
                    IDYSSCParcelDocument."Parcel Identifier" := TransportOrderPackage."Parcel Identifier";
                    IDYSSCParcelDocument."Transport Order No." := TransportOrderPackage."Transport Order No.";
                    IDYSSCParcelDocument."File Name" := StrSubstNo(FilenameLbl, TransportOrderPackage."Parcel Identifier");
                    IDYSSCParcelDocument."File".CreateOutStream(FileOutStream);
                    CopyStream(FileOutStream, FileInStream);
                    IDYSSCParcelDocument.Insert(true);

                    Clear(TransportOrderPackage."Package Label Data");
                    TransportOrderPackage.Modify();
                end;
            until TransportOrderPackage.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.MigratePackageLabelDataTag());
    end;

    internal procedure MigrateDelHubDenyCountriesData()
    var
        DelHubAPIServices: Record "IDYS DelHub API Services";
        ShipToCountryList: List of [Text];
        ShipToCountry: Text;
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.MigrateDelHubDenyCountriesDataTag()) then
            exit;

        if DelHubAPIServices.FindSet(true) then
            repeat
                ShipToCountryList := DelHubAPIServices."Ship-to Countries".Split(',');
                foreach ShipToCountry in ShipToCountryList do
                    UpsertDelHubAPISvcCountry(0, DelHubAPIServices."Entry No.", ShipToCountry);

                ShipToCountryList := DelHubAPIServices."Ship-to Countries (Denied)".Split(',');
                foreach ShipToCountry in ShipToCountryList do
                    if ShipToCountry <> '' then
                        UpsertDelHubAPISvcCountry(1, DelHubAPIServices."Entry No.", ShipToCountry);

                DelHubAPIServices."Ship-to Countries" := '';
                DelHubAPIServices."Ship-to Countries (Denied)" := '';
                DelHubAPIServices.Modify();
            until DelHubAPIServices.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.MigrateDelHubDenyCountriesDataTag());
    end;

    local procedure UpsertDelHubAPISvcCountry(EntryType: Integer; ServiceEntryNo: Integer; ShipToCountry: Text)
    var
        IDYSDelHubAPISvcCountry: Record "IDYS DelHub API Svc. Country";
    begin
        IDYSDelHubAPISvcCountry.Reset();
        IDYSDelHubAPISvcCountry.SetRange("Service Entry No.", ServiceEntryNo);
        IDYSDelHubAPISvcCountry.SetRange("Entry Type", EntryType);
        IDYSDelHubAPISvcCountry.SetRange("Country Code (Mapped)", ShipToCountry);
        if not IDYSDelHubAPISvcCountry.FindLast() then begin
            IDYSDelHubAPISvcCountry.Init();
            IDYSDelHubAPISvcCountry.Validate("Service Entry No.", ServiceEntryNo);
            IDYSDelHubAPISvcCountry.Validate("Entry Type", EntryType);
            IDYSDelHubAPISvcCountry.Validate("Country Code (Mapped)", CopyStr(ShipToCountry, 1, MaxStrLen(IDYSDelHubAPISvcCountry."Country Code (Mapped)")));
            IDYSDelHubAPISvcCountry.Validate("Country Code (API)", CopyStr(ShipToCountry, 1, MaxStrLen(IDYSDelHubAPISvcCountry."Country Code (API)")));
            IDYSDelHubAPISvcCountry.Insert(true);
        end;
    end;

    internal procedure MigrateProviderSetup()
    var
        CurrentProviderSetup: Record "IDYS Setup";
        OldProviderSetup: Record "IDYS Setup";
        CurrentSetupCode: Code[10];
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.MigrateProviderSetupTag()) then
            exit;

        if OldProviderSetup.Get('NSHIFT TRA') then begin
            CurrentProviderSetup.GetProviderSetup("IDYS Provider"::Transsmart);
            CurrentSetupCode := CurrentProviderSetup."Primary Key";
            CurrentProviderSetup.Delete();
            CurrentProviderSetup.Init();
            CurrentProviderSetup := OldProviderSetup;
            CurrentProviderSetup."Primary Key" := CurrentSetupCode;
            CurrentProviderSetup.Insert();

            OldProviderSetup.Delete();
        end;

        if OldProviderSetup.Get('NSHIFT SHI') then begin
            CurrentProviderSetup.GetProviderSetup("IDYS Provider"::"Delivery Hub");
            CurrentSetupCode := CurrentProviderSetup."Primary Key";
            CurrentProviderSetup.Delete();
            CurrentProviderSetup.Init();
            CurrentProviderSetup := OldProviderSetup;
            CurrentProviderSetup."Primary Key" := CurrentSetupCode;
            CurrentProviderSetup.Insert();

            OldProviderSetup.Delete();
        end;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.MigrateProviderSetupTag());
    end;

    internal procedure AddDefaultServices()
    var
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.AddDefaultServicesTag()) then
            exit;

        IDYSShipAgentSvcMapping.SetRange(Provider, IDYSShipAgentSvcMapping.Provider::"Delivery Hub");
        if IDYSShipAgentSvcMapping.FindSet() then
            repeat
                IDYSShipAgentSvcMapping.SetDefaultServices();
            until IDYSShipAgentSvcMapping.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.AddDefaultServicesTag());
    end;

    internal procedure MigrateItemUOMPackages()
    var
        IDYSItemUOMPackage: Record "IDYS Item UOM Package";
        IDYSItemUOMProfilePackage: Record "IDYS Item UOM Profile Package";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.MigrateItemUOMPackagesTag()) then
            exit;

        IDYSItemUOMPackage.SetRange("IDYS Provider", "IDYS Provider"::"Delivery Hub");
        IDYSItemUOMPackage.SetRange("Profile Packages", true);
        if IDYSItemUOMPackage.FindSet() then
            repeat
                IDYSItemUOMProfilePackage.SetRange("Item No.", IDYSItemUOMPackage."Item No.");
                IDYSItemUOMProfilePackage.SetRange(Code, IDYSItemUOMPackage.Code);
                IDYSItemUOMProfilePackage.SetRange("Item UOM Package Entry No.", IDYSItemUOMPackage."Entry No.");
                if IDYSItemUOMProfilePackage.FindSet(true) then
                    repeat
                        IDYSItemUOMProfilePackage."Shipping Agent Code (Mapped)" := IDYSItemUOMProfilePackage."Shipping Agent Code";
                        IDYSItemUOMProfilePackage."Ship. Agent Svc. Code (Mapped)" := IDYSItemUOMProfilePackage."Shipping Agent Service Code";
                        IDYSItemUOMProfilePackage.Modify();
                    until IDYSItemUOMProfilePackage.Next() = 0;
            until IDYSItemUOMPackage.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.MigrateItemUOMPackagesTag());
    end;

    internal procedure EnableSendcloud()
    var
        IDYSProviderSetup: Record "IDYS Provider Setup";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.EnableSendcloudTag()) then
            exit;

        if IDYSProviderSetup.Get("IDYS Provider"::Sendcloud) then begin
            IDYSProviderSetup.Hidden := false;
            IDYSProviderSetup.Modify();
        end;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.EnableSendcloudTag());
    end;

    local procedure CustInvDiscRecExists(InvDiscCode: Code[20]): Boolean
    var
        CustInvoiceDisc: Record "Cust. Invoice Disc.";
    begin
        CustInvoiceDisc.SetRange(Code, InvDiscCode);
        exit(not CustInvoiceDisc.IsEmpty());
    end;

    internal procedure MigrateSurchargeDetails()
    var
        IDYSSetup: Record "IDYS Setup";
        Customer: Record Customer;
        CustInvoiceDisc: Record "Cust. Invoice Disc.";
        NewEntryCreated: Boolean;
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.AddMigrateSurchargeDetailsTag()) then
            exit;

        NewEntryCreated := false;
        if not IDYSSetup.Get() then
            IDYSSetup.Init();

        if IDYSSetup."Add Freight Line" then begin
            // Create default Cust. Inv. Discount entry
            Customer.Reset();
            Customer.SetRange("IDYS Surcharge Fixed Amount", 0);
            Customer.SetRange("IDYS Surcharge %", 0);
            if Customer.FindSet() then
                repeat
                    // Ensure that we have newly created entry
                    if not CustInvDiscRecExists(Customer."Invoice Disc. Code") then begin
                        CustInvoiceDisc.Code := Customer."No.";
                        CustInvoiceDisc."IDYS Add Calc. Freight Costs" := true;
                        CustInvoiceDisc."IDYS Surcharge %" := IDYSSetup."Shipping Cost Surcharge (%)";
                        CustInvoiceDisc.Insert();
                        NewEntryCreated := true;
                    end;
                until (Customer.Next() = 0) or NewEntryCreated;

            // Overwrite only if Cust. Inv. Disc. is empty
            if Customer.FindSet(true) and NewEntryCreated then
                repeat
                    if not CustInvDiscRecExists(Customer."Invoice Disc. Code") then begin
                        Customer."Invoice Disc. Code" := CustInvoiceDisc.Code;
                        Customer.Modify();
                    end;
                until Customer.Next() = 0;
        end;

        // Migrate to Cust. Invoice Discount
        Customer.Reset();
        if Customer.FindSet() then
            repeat
                if (Customer."IDYS Surcharge Fixed Amount" <> 0) or (Customer."IDYS Surcharge %" <> 0) then
                    if not CustInvDiscRecExists(Customer."Invoice Disc. Code") then begin
                        CustInvoiceDisc.Code := Customer."No.";
                        CustInvoiceDisc."IDYS Add Calc. Freight Costs" := true;
                        CustInvoiceDisc."Service Charge" := Customer."IDYS Surcharge Fixed Amount";
                        CustInvoiceDisc."IDYS Surcharge %" := Customer."IDYS Surcharge %";
                        CustInvoiceDisc.Insert();
                    end;
            until Customer.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.AddMigrateSurchargeDetailsTag());
    end;

    internal procedure MigrateSalesOrderPackages()
    var
        SalesOrderPackage: Record "IDYS Sales Order Package";
        SourceDocumentPackage: Record "IDYS Source Document Package";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.SalesOrderPackagesTag()) then
            exit;

        if SalesOrderPackage.FindSet() then
            repeat
                SourceDocumentPackage."Table No." := Database::"Sales Header";
                SourceDocumentPackage."Document Type" := SourceDocumentPackage."Document Type"::"1";
                SourceDocumentPackage.TransferFields(SalesOrderPackage);
                SourceDocumentPackage.Insert(true);
            until SalesOrderPackage.Next() = 0;
        SalesOrderPackage.DeleteAll();
        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.SalesOrderPackagesTag());
    end;

    internal procedure MigrateItemUOMToProviderLevel()
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        IDYSItemUOMPackage: Record "IDYS Item UOM Package";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.AddItemUOMProviderLevelTag()) then
            exit;

        ItemUnitOfMeasure.SetFilter("IDYS Provider Package Type", '<>%1', '');
        if ItemUnitOfMeasure.FindSet() then
            repeat
                IDYSItemUOMPackage."Item No." := ItemUnitOfMeasure."Item No.";
                IDYSItemUOMPackage.Code := ItemUnitOfMeasure."Code";
                IDYSItemUOMPackage."IDYS Provider" := ItemUnitOfMeasure."IDYS Provider";
                IDYSItemUOMPackage."Provider Package Type Code" := ItemUnitOfMeasure."IDYS Provider Package Type";

                IDYSItemUOMPackage.Insert(true);
            until ItemUnitOfMeasure.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.AddItemUOMProviderLevelTag());
    end;

    internal procedure InitTransportOrderDocumentDate()
    var
        Setup: Record "IDYS Setup";
        TransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        if Setup.IsEmpty() then
            exit;

        TransportOrderHeader.SetRange("Document Date", 0D);
        if TransportOrderHeader.FindSet(true) then
            repeat
                if TransportOrderHeader."Preferred Pick-up Date" <> 0D then
                    TransportOrderHeader.Validate("Document Date", TransportOrderHeader."Preferred Pick-up Date")
                else
                    TransportOrderHeader.Validate("Document Date", Today());
                TransportOrderHeader.Modify();
            until TransportOrderHeader.Next() = 0;
    end;

    internal procedure AddConversionFactor();
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.AddConversionFactorTag()) then
            exit;

        if IDYSSetup.FindSet(true) then
            repeat
                if IDYSSetup."Conversion Factor (Mass)" = 0 then begin
                    IDYSSetup."Conversion Factor (Mass)" := 1;
                    IDYSSetup."Rounding Precision (Mass)" := 0.01;
                end;
                if IDYSSetup."Conversion Factor (Linear)" = 0 then begin
                    IDYSSetup."Conversion Factor (Linear)" := 1;
                    IDYSSetup."Rounding Precision (Linear)" := 0.01;
                end;
                if IDYSSetup."Conversion Factor (Volume)" = 0 then begin
                    IDYSSetup."Conversion Factor (Volume)" := 1;
                    IDYSSetup."Rounding Precision (Volume)" := 0.01;
                end;
                IDYSSetup.Modify(true);
            until IDYSSetup.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.AddConversionFactorTag());
    end;

    internal procedure MigrateToProviderLevel();
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        ServiceHeader: Record "Service Header";
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        IDYSCarrier: Record "IDYS Carrier";
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSBookingProfile: Record "IDYS Booking Profile";
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSShippAgentSvcMapping: Record "IDYS Shipp. Agent Svc. Mapping";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        IDYSShippingAgentMapping: Record "IDYS Shipping Agent Mapping";
        IDYSCarrierSelect: Record "IDYS Carrier Select";
        IDYSPackageType: Record "IDYS Package Type";
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        IDYSSalesOrderPackage: Record "IDYS Sales Order Package";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        IDYSTransportWorksheetLine: Record "IDYS Transport Worksheet Line";
        CanContinue: Boolean;
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.AddMigrateToProviderLevelTag()) then
            exit;

        if IDYSCarrier.FindSet() then
            repeat
                IDYSProviderCarrier.SetRange("Transsmart Carrier Code", IDYSCarrier.Code);
                if IDYSProviderCarrier.IsEmpty() then begin
                    Clear(IDYSProviderCarrier);
                    IDYSProviderCarrier.Provider := IDYSProviderCarrier.Provider::Transsmart;
                    IDYSProviderCarrier.Name := IDYSCarrier.Name;
                    IDYSProviderCarrier."Location Select" := IDYSCarrier."Location Select";
                    IDYSProviderCarrier."Needs Manifesting" := IDYSCarrier."Needs Manifesting";
                    IDYSProviderCarrier."Transsmart Carrier Code" := IDYSCarrier.Code;
                    IDYSProviderCarrier.Insert(true);
                end;
            until IDYSCarrier.Next() = 0;

        if IDYSBookingProfile.FindSet() then
            repeat
                IDYSProviderCarrier.SetRange(Provider, IDYSProviderCarrier.Provider::Transsmart);
                IDYSProviderCarrier.SetRange("Transsmart Carrier Code", IDYSBookingProfile."Carrier Code (External)");
                if IDYSProviderCarrier.FindLast() then begin
                    IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
                    IDYSProviderBookingProfile.SetRange("Transsmart Booking Prof. Code", IDYSBookingProfile.Code);
                    if IDYSProviderBookingProfile.IsEmpty() then begin
                        Clear(IDYSProviderBookingProfile);
                        IDYSProviderBookingProfile."Carrier Entry No." := IDYSProviderCarrier."Entry No.";
                        IDYSProviderBookingProfile."Transsmart Booking Prof. Code" := IDYSBookingProfile.Code;
                        IDYSProviderBookingProfile."Service Level Code (Other)" := IDYSBookingProfile."Service Level Code (Other)";
                        IDYSProviderBookingProfile."Service Level Code (Time)" := IDYSBookingProfile."Service Level Code (Time)";
                        IDYSProviderBookingProfile.Description := IDYSBookingProfile.Description;
                        IDYSProviderBookingProfile.Insert(true);
                    end;
                end;
            until IDYSBookingProfile.Next() = 0;

        if IDYSShippingAgentMapping.FindSet() then
            repeat
                IDYSProviderCarrier.SetRange("Transsmart Carrier Code", IDYSShippingAgentMapping."Carrier Code (External)");
                if IDYSProviderCarrier.FindLast() then begin
                    IDYSShipAgentMapping."Shipping Agent Code" := IDYSShippingAgentMapping."Shipping Agent Code";
                    IDYSShipAgentMapping."Carrier Entry No." := IDYSProviderCarrier."Entry No.";
                    IDYSShipAgentMapping.Provider := IDYSShipAgentMapping.Provider::Transsmart;
                    IDYSShipAgentMapping."Carrier Name" := IDYSProviderCarrier.Name;
                    if not IDYSShipAgentMapping.Insert() then
                        IDYSShipAgentMapping.Modify();
                end;
            until IDYSShippingAgentMapping.Next() = 0;

        if IDYSShippAgentSvcMapping.FindSet() then
            repeat
                IDYSProviderCarrier.SetRange("Transsmart Carrier Code", IDYSShippAgentSvcMapping."Carrier Code (External)");
                if IDYSProviderCarrier.FindLast() then begin
                    IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
                    IDYSProviderBookingProfile.SetRange("Transsmart Booking Prof. Code", IDYSShippAgentSvcMapping."Booking Profile Code (Ext.)");
                    if IDYSProviderBookingProfile.FindLast() then begin
                        IDYSShipAgentSvcMapping."Shipping Agent Code" := IDYSShippAgentSvcMapping."Shipping Agent Code";
                        IDYSShipAgentSvcMapping."Shipping Agent Service Code" := IDYSShippAgentSvcMapping."Shipping Agent Service Code";

                        IDYSShipAgentSvcMapping."Carrier Entry No." := IDYSProviderCarrier."Entry No.";
                        IDYSShipAgentSvcMapping."Booking Profile Entry No." := IDYSProviderBookingProfile."Entry No.";
                        IDYSShipAgentSvcMapping."Booking Profile Description" := IDYSProviderBookingProfile.Description;
                        if not IDYSShipAgentSvcMapping.Insert() then
                            IDYSShipAgentSvcMapping.Modify();
                    end;
                end;
            until IDYSShippAgentSvcMapping.Next() = 0;

        if IDYSTransportOrderHeader.FindSet(true) then
            repeat
                IDYSTransportOrderHeader.Provider := IDYSTransportOrderHeader.Provider::Transsmart;
                IDYSProviderCarrier.SetRange("Transsmart Carrier Code", IDYSTransportOrderHeader."Carrier Code (External)");
                if IDYSProviderCarrier.FindLast() then begin
                    IDYSProviderBookingProfile.SetRange("Carrier Entry No.", IDYSProviderCarrier."Entry No.");
                    IDYSProviderBookingProfile.SetRange("Transsmart Booking Prof. Code", IDYSTransportOrderHeader."Booking Profile Code (Ext.)");
                    if IDYSProviderBookingProfile.FindLast() then begin
                        IDYSTransportOrderHeader."Carrier Entry No." := IDYSProviderCarrier."Entry No.";
                        IDYSTransportOrderHeader."Booking Profile Entry No." := IDYSProviderBookingProfile."Entry No.";
                    end;
                end;
                IDYSTransportOrderHeader.Modify();
            until IDYSTransportOrderHeader.Next() = 0;

        SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order");
        if SalesHeader.FindSet(true) then
            repeat
                SalesHeader."IDYS Provider" := SalesHeader."IDYS Provider"::Transsmart;
                if SalesHeader."Shipping Agent Code" <> '' then
                    if IDYSShipAgentMapping.Get(SalesHeader."Shipping Agent Code") then begin
                        SalesHeader."IDYS Carrier Entry No." := IDYSShipAgentMapping."Carrier Entry No.";
                        if IDYSShipAgentSvcMapping.Get(SalesHeader."Shipping Agent Code", SalesHeader."Shipping Agent Service Code") then
                            SalesHeader."IDYS Booking Profile Entry No." := IDYSShipAgentSvcMapping."Booking Profile Entry No.";
                    end;
                SalesHeader.Modify();
            until SalesHeader.Next() = 0;

        PurchaseHeader.SetFilter("Document Type", '%1|%2', PurchaseHeader."Document Type"::"Return Order", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetFilter("IDYS Shipping Agent Code", '<>%1', '');
        if PurchaseHeader.FindSet(true) then
            repeat
                if IDYSShipAgentMapping.Get(PurchaseHeader."IDYS Shipping Agent Code") then begin
                    PurchaseHeader."IDYS Carrier Entry No." := IDYSShipAgentMapping."Carrier Entry No.";
                    if IDYSShipAgentSvcMapping.Get(PurchaseHeader."IDYS Shipping Agent Code", PurchaseHeader."IDYS Shipping Agent Srv Code") then
                        PurchaseHeader."IDYS Booking Profile Entry No." := IDYSShipAgentSvcMapping."Booking Profile Entry No.";
                    PurchaseHeader.Modify();
                end;
            until PurchaseHeader.Next() = 0;

        TransferHeader.SetFilter("Shipping Agent Code", '<>%1', '');
        if TransferHeader.FindSet(true) then
            repeat
                if IDYSShipAgentMapping.Get(TransferHeader."Shipping Agent Code") then begin
                    TransferHeader."IDYS Carrier Entry No." := IDYSShipAgentMapping."Carrier Entry No.";
                    if IDYSShipAgentSvcMapping.Get(TransferHeader."Shipping Agent Code", TransferHeader."Shipping Agent Service Code") then
                        TransferHeader."IDYS Booking Profile Entry No." := IDYSShipAgentSvcMapping."Booking Profile Entry No.";
                    TransferHeader.Modify();
                end;
            until TransferHeader.Next() = 0;

        ServiceHeader.SetRange("Document Type", ServiceHeader."Document Type"::Order);
        ServiceHeader.SetFilter("Shipping Agent Code", '<>%1', '');
        if ServiceHeader.FindSet(true) then
            repeat
                if IDYSShipAgentMapping.Get(ServiceHeader."Shipping Agent Code") then begin
                    ServiceHeader."IDYS Carrier Entry No." := IDYSShipAgentMapping."Carrier Entry No.";
                    if IDYSShipAgentSvcMapping.Get(ServiceHeader."Shipping Agent Code", ServiceHeader."Shipping Agent Service Code") then
                        ServiceHeader."IDYS Booking Profile Entry No." := IDYSShipAgentSvcMapping."Booking Profile Entry No.";
                    ServiceHeader.Modify();
                end;
            until ServiceHeader.Next() = 0;

        if IDYSPackageType.FindSet() then begin
            IDYSProviderPackageType.SetRange(Provider, IDYSProviderPackageType.Provider::Transsmart);
            CanContinue := IDYSProviderPackageType.IsEmpty();
            IDYSProviderPackageType.SetRange(Provider);
            if CanContinue then
                repeat
                    IDYSProviderPackageType.TransferFields(IDYSPackageType);
                    IDYSProviderPackageType.Provider := IDYSProviderPackageType.Provider::Transsmart;
                    IDYSProviderPackageType.Insert();
                until IDYSPackageType.Next() = 0;
        end;

        if IDYSTransportOrderPackage.FindSet(true) then
            repeat
                IDYSTransportOrderPackage."Provider Package Type Code" := IDYSTransportOrderPackage."Package Type Code";
                IDYSTransportOrderPackage.Modify();
            until IDYSTransportOrderPackage.Next() = 0;

        if IDYSSalesOrderPackage.FindSet(true) then
            repeat
                IDYSSalesOrderPackage."Provider Package Type Code" := IDYSSalesOrderPackage."Package Type Code";
                IDYSSalesOrderPackage.Modify();
            until IDYSSalesOrderPackage.Next() = 0;

        ItemUnitOfMeasure.SetFilter("IDYS Package Type", '<>%1', '');
        if ItemUnitOfMeasure.FindSet(true) then
            repeat
                ItemUnitOfMeasure."IDYS Provider" := ItemUnitOfMeasure."IDYS Provider"::Transsmart;
                ItemUnitOfMeasure."IDYS Provider Package Type" := ItemUnitOfMeasure."IDYS Package Type";
                ItemUnitOfMeasure.Modify();
            until ItemUnitOfMeasure.Next() = 0;

        IDYSTransportWorksheetLine.SetFilter("Package Type", '<>%1', '');
        if IDYSTransportWorksheetLine.FindSet(true) then
            repeat
                IDYSTransportWorksheetLine."Provider Package Type" := IDYSTransportWorksheetLine."Package Type";
                IDYSTransportWorksheetLine.Modify();
            until IDYSTransportWorksheetLine.Next() = 0;

        IDYSCarrier.DeleteAll();
        IDYSCarrierSelect.DeleteAll();
        IDYSBookingProfile.DeleteAll();
        IDYSShippingAgentMapping.DeleteAll();
        IDYSShippAgentSvcMapping.DeleteAll();
        EnableTranssmart();

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.AddMigrateToProviderLevelTag());
    end;

    local procedure EnableTranssmart()
    var
        IDYSTranssmartSetup: Record "IDYS Setup";
        IDYSSetup: Record "IDYS Setup";
        IDYSProviderSetup: Record "IDYS Provider Setup";
        ProviderValue: Enum "IDYS Provider";
        Providers: List of [Integer];
        i: Integer;
    begin
        // Populate data
        Providers := "IDYS Provider".Ordinals();
        foreach i in Providers do begin
            ProviderValue := "IDYS Provider".FromInteger(i);
            if not IDYSProviderSetup.Get(ProviderValue) then begin
                IDYSProviderSetup.Provider := ProviderValue;
                IDYSProviderSetup.Insert();
            end;
        end;

        // Enable Transsmart
        IDYSProviderSetup.Get(ProviderValue::Transsmart);
        IDYSProviderSetup.Enabled := true;
        IDYSProviderSetup.Modify();

        // Upsert Transsmart Setup
        if IDYSSetup.Get() then begin
            IDYSTranssmartSetup.GetProviderSetup("IDYS Provider"::Transsmart);
            IDYSTranssmartSetup."Transsmart Account Code" := IDYSSetup."Transsmart Account Code";
            IDYSTranssmartSetup."Transsmart Environment" := IDYSSetup."Transsmart Environment";
            IDYSTranssmartSetup."Default E-Mail Type" := IDYSSetup."Default E-Mail Type";
            IDYSTranssmartSetup."Default Cost Center" := IDYSSetup."Default Cost Center";
            IDYSTranssmartSetup."Default Provider Package Type" := IDYSSetup."Default Package Type";
            IDYSTranssmartSetup.Modify();
        end
    end;

    internal procedure MigrateLicenseKeyAndCredentials();
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSUserSetup: Record "IDYS User Setup";
        IDYMAppHub: Codeunit "IDYM Apphub";
        IDYMEndpointManagement: Codeunit "IDYM Endpoint Management";
        AppInfo: ModuleInfo;
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.AddMigrateLicenseKeyAndCredentialsEnumTag()) then
            exit;
        if not IDYSSetup.Get() then
            exit;
        NavApp.GetCurrentModuleInfo(AppInfo);
        if IDYSSetup."License Key" <> '' then begin
            IDYSSetup."License Entry No." := IDYMAppHub.GetLicenseAppEntryNo(AppInfo.Id(), IDYSSetup."License Key");
            Clear(IDYSSetup."License Key");
            Clear(IDYSSetup."License Grace Period Start");
            IDYSSetup.Modify();
        end;
        IDYMEndpointManagement.RegisterEndpoint("IDYM Endpoint Service"::Transsmart, "IDYM Endpoint Usage"::Default, "IDYM Authorization Type"::Bearer, AppInfo.Id);
        if IDYSUserSetup.FindSet() then
            repeat
                IDYMEndpointManagement.RegisterCredentials("IDYM Endpoint Service"::Transsmart, "IDYM Endpoint Usage"::GetToken, AppInfo.Id(), "IDYM Authorization Type"::Basic, "IDYM Endpoint Sub Type"::Username, IDYSUserSetup."User ID", IDYSUserSetup."User Name (External)", IDYSUserSetup."Password (External)");
                IDYMEndpointManagement.RegisterEndpoint("IDYM Endpoint Service"::Transsmart, "IDYM Endpoint Usage"::Default, "IDYM Authorization Type"::Bearer, AppInfo.Id, "IDYM Endpoint Sub Type"::Username, IDYSUserSetup."User ID");
            until IDYSUserSetup.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.AddMigrateLicenseKeyAndCredentialsEnumTag());
    end;

    internal procedure MoveCustomerSetupToCustomer()
    var
        CustomerSetup: Record "IDYS Customer Setup";
        Customer: Record Customer;
    begin
        if CustomerSetup.FindSet() then
            repeat
                if Customer.Get(CustomerSetup."Customer No.") then begin
                    Customer."IDYS Account No." := CustomerSetup."Account No.";
                    Customer."IDYS Cost Center" := CustomerSetup."Cost Center";
                    Customer."IDYS E-Mail Type" := CustomerSetup."E-Mail Type";
                    Customer.Modify();
                end;
            until CustomerSetup.Next() = 0;

        CustomerSetup.DeleteAll(true);
    end;

    internal procedure MoveShiptoAddressSetupToShiptoAddress()
    var
        ShiptoAddressSetup: Record "IDYS Ship-to Address Setup";
        ShiptoAddress: Record "Ship-to Address";
    begin
        if ShiptoAddressSetup.FindSet() then
            repeat
                if ShiptoAddress.Get(ShiptoAddressSetup."Customer No.", ShiptoAddressSetup."Ship-to Address Code") then begin
                    ShiptoAddress."IDYS Account No." := ShiptoAddressSetup."Account No.";
                    ShiptoAddress."IDYS Cost Center" := ShiptoAddressSetup."Cost Center";
                    ShiptoAddress."IDYS E-Mail Type" := ShiptoAddressSetup."E-Mail Type";
                    ShiptoAddress.Modify();
                end;
            until ShiptoAddressSetup.Next() = 0;

        ShiptoAddressSetup.DeleteAll(true);
    end;

    internal procedure MoveOrderAddressSetupToShiptoAddress()
    var
        OrderAddressSetup: Record "IDYS Order Address Setup";
        OrderAddress: Record "Order Address";
    begin
        if OrderAddressSetup.FindSet() then
            repeat
                if OrderAddress.Get(OrderAddressSetup."Vendor No.", OrderAddressSetup."Order Address Code") then begin
                    OrderAddress."IDYS Cost Center" := OrderAddressSetup."Cost Center";
                    OrderAddress."IDYS E-Mail Type" := OrderAddressSetup."E-Mail Type";
                    OrderAddress.Modify();
                end;
            until OrderAddressSetup.Next() = 0;

        OrderAddressSetup.DeleteAll(true);
    end;

    internal procedure MoveVendorSetupToVendor()
    var
        VendorSetup: Record "IDYS Vendor Setup";
        Vendor: Record Vendor;
    begin
        if VendorSetup.FindSet() then
            repeat
                if Vendor.Get(VendorSetup."Vendor No.") then begin
                    Vendor."IDYS Cost Center" := VendorSetup."Cost Center";
                    Vendor."IDYS E-Mail Type" := VendorSetup."E-Mail Type";
                    Vendor.Modify();
                end;
            until VendorSetup.Next() = 0;

        VendorSetup.DeleteAll(true);
    end;

    internal procedure PopulateExternalCountryCodeInvoiceOnTransportOrder()
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSTransportOrderHdrMgt: Codeunit "IDYS Transport Order Hdr. Mgt.";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.NewCountryInvoiceUpgradeTag()) then
            exit;

        TransportOrderHeader.SetLoadFields("Country/Region Code (Invoice)", "Cntry/Rgn. Code (Invoice) (TS)");
        TransportOrderHeader.SetFilter("Country/Region Code (Invoice)", '<>%1', '');
        if TransportOrderHeader.FindSet(true) then
            repeat
                TransportOrderHeader."Cntry/Rgn. Code (Invoice) (TS)" := IDYSTransportOrderHdrMgt.GetExternalCountryCode(TransportOrderHeader."Country/Region Code (Invoice)");
                TransportOrderHeader.Modify();
            until TransportOrderHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.NewCountryInvoiceUpgradeTag());
    end;

    internal procedure PopulateQtyBaseOnTransportOrderLines()
    var
        TransportOrderLine: Record "IDYS Transport Order Line";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.AddTransportOrderPackageLineQtyBaseTag()) then
            exit;
        TransportOrderLine.SetLoadFields("Qty. (Base)", Quantity);
        if TransportOrderLine.FindSet(true) then
            repeat
                TransportOrderLine."Qty. (Base)" := TransportOrderLine.Quantity;
                TransportOrderLine.Modify();
            until TransportOrderLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.AddTransportOrderPackageLineQtyBaseTag());
    end;

    internal procedure PopulateAfterPostSalesReturnOrder()
    var
        JobQueueEntry: Record "Job Queue Entry";
        IDYSSetup: Record "IDYS Setup";
        ParameterString: Text[250];
        Cntr: Integer;
        TransportOrderStatusLbl: Label 'UpdateTransportOrderStatus', Locked = true;
        CleanUpLogEntriesLbl: Label 'CleanupLogEntries', Locked = true;
        CleanUpTransportOrdersLbl: Label 'CleanupTransportOrders', Locked = true;
        TransportOrderStatusDescriptionLbl: Label 'ShipIT 365 update transport order status';
        CleanUpLogEntriesDescriptionLbl: Label 'ShipIT 365 log entry cleanup';
        CleanUpTransportOrdersDescriptionLbl: Label 'ShipIT 365 transport orders cleanup';
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.AddAfterPostForSalesReturnReceiptTag()) then
            exit;
        if IDYSSetup.Get() then begin
            IDYSSetup."After Post Sales Return Orders" := IDYSSetup."After Posting Sales Orders";
            IDYSSetup.Modify(true);
        end;
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"IDYS Scheduled Tasks Handler");
        for Cntr := 0 to 2 do begin
            case Cntr of
                0:
                    ParameterString := TransportOrderStatusLbl;
                1:
                    ParameterString := CleanUpLogEntriesLbl;
                2:
                    ParameterString := CleanUpTransportOrdersLbl;
            end;
            JobQueueEntry.SetRange("Parameter String", ParameterString);
            if JobQueueEntry.FindFirst() then begin
                case Cntr of
                    0:
                        JobQueueEntry.Description := TransportOrderStatusDescriptionLbl;
                    1:
                        JobQueueEntry.Description := CleanUpLogEntriesDescriptionLbl;
                    2:
                        JobQueueEntry.Description := CleanUpTransportOrdersDescriptionLbl;
                end;
                if JobQueueEntry.Modify() then;
            end;
        end;
        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.AddAfterPostForSalesReturnReceiptTag());
    end;

    internal procedure RemoveEmptyJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        IDYSScheduledTasksHandler: codeunit "IDYS Scheduled Tasks Handler";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.RemoveJobQueueEntriesTag()) then
            exit;
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"IDYS Scheduled Tasks Handler");
        JobQueueEntry.SetRange("Parameter String", '');
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll();
        JobQueueEntry.Reset();
        IDYSScheduledTasksHandler.InstallLogEntriesCleanupJobQueueEntry();
        IDYSScheduledTasksHandler.InstallStatusUpdateJobQueueEntry();
        IDYSScheduledTasksHandler.InstallTransportOrderCleanupJobQueueEntry();
        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.RemoveJobQueueEntriesTag());
    end;

    local procedure PopulatePickUpAndDeliveryDT()
    var
        Setup: Record "IDYS Setup";
        ShippingAgentCalendar: Record "IDYS Shipping Agent Calendar";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.PickUpAndDeliveryDTTag()) then
            exit;
        if Setup.Get() then begin
            if Setup."Pick-up From DT" <> 0DT then
                Setup.Validate("Pick-up From DT", CreateDateTime(WorkDate(), Setup."Pick-up Time From"));
            if Setup."Pick-up To DT" <> 0DT then
                Setup.Validate("Pick-up To DT", CreateDateTime(WorkDate(), Setup."Pick-up Time To"));
            if Setup."Delivery From DT" <> 0DT then
                Setup.Validate("Delivery From DT", CreateDateTime(WorkDate(), Setup."Delivery Time From"));
            if Setup."Delivery To DT" <> 0DT then
                Setup.Validate("Delivery To DT", CreateDateTime(WorkDate(), Setup."Delivery Time To"));
            Setup.Modify();
        end;
        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.PickUpAndDeliveryDTTag());
        if ShippingAgentCalendar.FindSet(true) then
            repeat
                ShippingAgentCalendar.Validate("Pick-up Time From");
                ShippingAgentCalendar.Validate("Pick-up Time To");
                ShippingAgentCalendar.Validate("Delivery Time From");
                ShippingAgentCalendar.Validate("Delivery Time To");
                ShippingAgentCalendar.Modify(true);
            until ShippingAgentCalendar.Next() = 0;
    end;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        IDYSUpgradeTagDefinitions: Codeunit "IDYS Upgrade Tag Definitions";
#pragma warning restore AL0432
}