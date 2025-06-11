codeunit 11147820 "IDYST Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany() // Includes code for company-related operations. Runs once for each company in the database.
    begin
        FreshInstall();
    end;

    local procedure FreshInstall();
    var
        MOBPackageType: Record "MOB Package Type";
        IDYSTShippingProvider: Codeunit "IDYST ShippingProvider";
    begin
        SetDefaultConversionValues();
        IDYSTShippingProvider.SynchronizePackageTypes(MOBPackageType);
    end;

    internal procedure SetDefaultConversionValues()
    var
        IDYSSetup: Record "IDYS Setup";
        DoModify: Boolean;
    begin
        IDYSSetup.SetFilter("Primary Key", '<>%1', '');
        if IDYSSetup.FindSet(true) then
            repeat
                DoModify := false;

                if IDYSSetup."IDYST Conversion Factor (Mass)" = 0 then begin
                    IDYSSetup."IDYST Conversion Factor (Mass)" := 1;
                    DoModify := true;
                end;

                if IDYSSetup."IDYST Rounding Prec. (Mass)" = 0 then begin
                    IDYSSetup."IDYST Rounding Prec. (Mass)" := 0.01;
                    DoModify := true;
                end;

                if IDYSSetup."IDYST Conv. Factor (Linear)" = 0 then begin
                    IDYSSetup."IDYST Conv. Factor (Linear)" := 1;
                    DoModify := true;
                end;

                if IDYSSetup."IDYST Rounding Prec. (Linear)" = 0 then begin
                    IDYSSetup."IDYST Rounding Prec. (Linear)" := 0.01;
                    DoModify := true;
                end;

                if DoModify then
                    IDYSSetup.Modify();
            until IDYSSetup.Next() = 0;
    end;
}
