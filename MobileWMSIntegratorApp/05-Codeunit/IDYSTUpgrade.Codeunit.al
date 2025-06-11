codeunit 11147823 "IDYST Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        RenameProviderSpecificPackageTypes();
        RenamePackageTypeCodes();
        AddTaskletConversionFactors();
    end;

    internal procedure AddTaskletConversionFactors()
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.AddTaskletConversionFactorsTag()) then
            exit;

        IDYSSetup.SetFilter("Primary Key", '<>%1', '');
        if IDYSSetup.FindSet(true) then
            repeat
                IDYSSetup."IDYST Conversion Factor (Mass)" := 1;
                IDYSSetup."IDYST Rounding Prec. (Mass)" := 0.01;

                IDYSSetup."IDYST Conv. Factor (Linear)" := 1;
                IDYSSetup."IDYST Rounding Prec. (Linear)" := 0.01;
                IDYSSetup.Modify();
            until IDYSSetup.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.AddTaskletConversionFactorsTag());
    end;

    internal procedure RenamePackageTypeCodes()
    var
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        MOBPackageType: Record "MOB Package Type";
        NewMOBPackageType: Record "MOB Package Type";
        IDYSTShippingProvider: Codeunit "IDYST ShippingProvider";
        NewCode: Code[100];
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.RenamePackageTypeCodeTag()) then
            exit;

        IDYSProviderPackageType.Reset();
        if IDYSProviderPackageType.FindSet() then
            repeat
                MOBPackageType.SetRange("Shipping Provider Id", IDYSTShippingProvider.GetShippingProviderId());
                if MOBPackageType.FindSet(true) then
                    repeat
                        NewCode := CopyStr(Format(MOBPackageType.Code).Replace(IDYSTShippingProvider.GetShippingProviderId(), 'SHPIT'), 1, MaxStrLen(NewCode));
                        if MOBPackageType.Code <> NewCode then begin
                            // Handle new Provider Package Level
                            NewMOBPackageType := MOBPackageType;
                            NewMOBPackageType.Rename(NewCode);
                        end;
                    until MOBPackageType.Next() = 0;
            until IDYSProviderPackageType.Next() = 0;

        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.RenamePackageTypeCodeTag());
    end;

    internal procedure RenameProviderSpecificPackageTypes()
    var
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        MOBPackageType: Record "MOB Package Type";
        NewMOBPackageType: Record "MOB Package Type";
        MobToolBox: Codeunit "MOB Toolbox";
        ShippingProviderCodeunit: Codeunit "IDYST ShippingProvider";
        NewCode: Code[100];
        NewCodeLbl: Label '%1-%2-%3', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(IDYSUpgradeTagDefinitions.RenameProviderSpecificPackageTypesTag()) then
            exit;
        IDYSProviderPackageType.Reset();
        if IDYSProviderPackageType.FindSet() then
            repeat
                MOBPackageType.SetRange("Shipping Provider Id", ShippingProviderCodeunit.GetShippingProviderId());
                MOBPackageType.SetRange("Shipping Provider Package Type", IDYSProviderPackageType.Code);
                if MOBPackageType.FindSet(true) then
                    repeat
                        NewCode := StrSubstNo(NewCodeLbl, MOBPackageType."Shipping Provider Id", MobToolBox.AsInteger(IDYSProviderPackageType.Provider), MOBPackageType."Shipping Provider Package Type");  // Example: SHIPIT365-1-BOX
                        if MOBPackageType.Code <> NewCode then begin
                            // Handle new Provider Package Level
                            NewMOBPackageType := MOBPackageType;
                            NewMOBPackageType.Rename(NewCode);
                        end;
                    until MOBPackageType.Next() = 0;
            until IDYSProviderPackageType.Next() = 0;
        UpgradeTag.SetUpgradeTag(IDYSUpgradeTagDefinitions.RenameProviderSpecificPackageTypesTag());
    end;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        IDYSUpgradeTagDefinitions: Codeunit "IDYS Upgrade Tag Definitions";
}
