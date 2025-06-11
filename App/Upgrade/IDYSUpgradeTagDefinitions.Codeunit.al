codeunit 11147684 "IDYS Upgrade Tag Definitions"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(NewCountryInvoiceUpgradeTag());
        PerCompanyUpgradeTags.Add(AddTransportOrderPackageLineQtyBaseTag());
        PerCompanyUpgradeTags.Add(AddAfterPostForSalesReturnReceiptTag());
        PerCompanyUpgradeTags.Add(RemoveJobQueueEntriesTag());
        PerCompanyUpgradeTags.Add(AddMigrateLicenseKeyAndCredentialsEnumTag());
        PerCompanyUpgradeTags.Add(PickUpAndDeliveryDTTag());
        PerCompanyUpgradeTags.Add(AddMigrateToProviderLevelTag());
        PerCompanyUpgradeTags.Add(AddConversionFactorTag());
        PerCompanyUpgradeTags.Add(AddItemUOMProviderLevelTag());
        PerCompanyUpgradeTags.Add(SalesOrderPackagesTag());
        PerCompanyUpgradeTags.Add(AddMigrateSurchargeDetailsTag());
        PerCompanyUpgradeTags.Add(EnableSendcloudTag());
        PerCompanyUpgradeTags.Add(MigrateItemUOMPackagesTag());
        PerCompanyUpgradeTags.Add(AddDefaultServicesTag());
        PerCompanyUpgradeTags.Add(MigrateProviderSetupTag());
        PerCompanyUpgradeTags.Add(MigrateDelHubDenyCountriesDataTag());
        PerCompanyUpgradeTags.Add(MigratePackageLabelDataTag());
        PerCompanyUpgradeTags.Add(RenameProviderSpecificPackageTypesTag());
        PerCompanyUpgradeTags.Add(UpdateDeliveryHubEndpointsTag());
        PerCompanyUpgradeTags.Add(ResetVideosTag());
        PerCompanyUpgradeTags.Add(MigrateShipmentLabelData());
        PerCompanyUpgradeTags.Add(SkipSourceDocsUpdafterTO());
        PerCompanyUpgradeTags.Add(InitializeTransportOrderSyncTag());
        PerCompanyUpgradeTags.Add(RenamePackageTypeCodeTag());
        PerCompanyUpgradeTags.Add(AddTaskletConversionFactorsTag());
        PerCompanyUpgradeTags.Add(MigratePurchHeaderAccNoBillToTag());
        PerCompanyUpgradeTags.Add(UpdateEasyPostDefaultLabelTypeTag());
        PerCompanyUpgradeTags.Add(UpdateTransportOrderLinesTag());
        PerCompanyUpgradeTags.Add(GetUpdatenShiftShipMasterDataTag());
        PerCompanyUpgradeTags.Add(GetUpdateAddressTypeSourceDataTag());
        PerCompanyUpgradeTags.Add(GetUpdateDeliveryNoteQuantityUOMTag());
    end;

    procedure UpdateDeliveryHubEndpointsTag(): Code[250]
    begin
        exit('IDYS-1107-UpdateDeliveryHubEndpointsTag-20231113');
    end;

    procedure MigrateShipmentLabelData(): Code[250]
    begin
        exit('IDYS-1300-MigrateShipmentLabelData-20240306');
    end;

    procedure MigratePackageLabelDataTag(): Code[250]
    begin
        exit('IDYS-881-MigratePackageLabelData-20231009');
    end;

    procedure MigrateDelHubDenyCountriesDataTag(): Code[250]
    begin
        exit('IDYS-1058-MigrateDelHubDenyCountries-20231010');
    end;

    procedure MigrateProviderSetupTag(): Code[250]
    begin
        exit('IDYS-939-MigrateProviderSetup-20230808');
    end;

    procedure AddDefaultServicesTag(): Code[250]
    begin
        exit('IDYS-636-DefaultServiceLevels-20230417');
    end;

    procedure NewCountryInvoiceUpgradeTag(): Code[250]
    begin
        exit('IDYS-94-NewCountryInvoiceFields-20210908');
    end;

    procedure AddTransportOrderPackageLineQtyBaseTag(): Code[250]
    begin
        exit('IDYS-174-NewQtyBaseOnTransportOrderLine-20211115')
    end;

    procedure AddAfterPostForSalesReturnReceiptTag(): Code[250]
    begin
        exit('IDYS-210-NewAfterPostSalesReturnReceipt-20211123')
    end;

    procedure RemoveJobQueueEntriesTag(): Code[250]
    begin
        exit('IDYS-224-RemoveJobQueueEntriesWithoutParam-20211217');
    end;

    procedure AddMigrateLicenseKeyAndCredentialsEnumTag(): Code[250]
    begin
        exit('IDYS-071-MigrateLicenseKeyAndCredentials-20220630');
    end;

    procedure PickUpAndDeliveryDTTag(): Code[250]
    begin
        exit('IDYS-308-PickUpAndDeliveryDT-20221025');
    end;

    procedure AddMigrateToProviderLevelTag(): Code[250]
    begin
        exit('IDYS-264-MigrateToProviderLevel-20221202');
    end;

    procedure AddConversionFactorTag(): Code[250]
    begin
        exit('IDYS-390-ConversionFactor-20221214');
    end;

    procedure AddItemUOMProviderLevelTag(): Code[250]
    begin
        exit('IDYS-475-ItemUOMProviderLevel-20230117');
    end;

    procedure SalesOrderPackagesTag(): Code[250]
    begin
        exit('IDYS-477-MigrateSalesOrderPackages-20230120');
    end;

    procedure AddMigrateSurchargeDetailsTag(): Code[250]
    begin
        exit('IDYS-469-MigrateSurchargeDetails-20230126');
    end;

    procedure EnableSendcloudTag(): Code[250]
    begin
        exit('IDYS-EnableSendcloud-20230129');
    end;

    procedure MigrateItemUOMPackagesTag(): Code[250]
    begin
        exit('IDYS-693-MigrateItemUOMPackagesTag-20230406');
    end;

    procedure RenameProviderSpecificPackageTypesTag(): Code[250]
    begin
        exit('IDYS-788-RenameProviderSpecificPackageTypes-20231108');
    end;

    procedure ResetVideosTag(): Code[250]
    begin
        exit('IDYS-1115-ResetVideoTracking-20231114');
    end;

    procedure SkipSourceDocsUpdafterTO(): Code[250]
    begin
        exit('IDYS-1436-SkipSourceDocsUpdafterTO-20240517');
    end;

    procedure InitializeTransportOrderSyncTag(): Code[250]
    begin
        exit('IDYS-1407-EnableTOSync-20240613');
    end;

    procedure RenamePackageTypeCodeTag(): Code[250]
    begin
        exit('IDYS-1443-RenamePackageTypeCode-20240703');
    end;

    procedure AddTaskletConversionFactorsTag(): Code[250]
    begin
        exit('IDYS-908-AddTaskletConversionFactor-20240705');
    end;

    procedure MigratePurchHeaderAccNoBillToTag(): Code[250]
    begin
        exit('IDYS-1557-MigratePurchHeaderAccNoBillTo-20240725');
    end;

    procedure UpdateEasyPostDefaultLabelTypeTag(): Code[250]
    begin
        exit('IDYS-1257-UpdateEasyPostDefaultLabelType-20240806');
    end;

    procedure UpdateTransportOrderLinesTag(): Code[250]
    begin
        exit('IDYS-1339-UpdateTransportOrderLines-20240802');
    end;

    procedure GetUpdatenShiftShipMasterDataTag(): Code[250]
    begin
        exit('IDYS-1482-UpdatenShiftShipMasterData-20240911');
    end;

    procedure GetUpdateAddressTypeSourceDataTag(): Code[250]
    begin
        exit('IDYS-1451-UpdateAddressTypeSourceData-20241015');
    end;

    procedure GetUpdateDeliveryNoteQuantityUOMTag(): Code[250]
    begin
        exit('IDYS-1768-UpdateDeliveryNoteQuantityUOM-20250303');
    end;
}