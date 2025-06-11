codeunit 11147674 "IDYS Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        Setup: Record "IDYS Setup";
    begin
        if Setup.IsEmpty() then
            exit;

        UpgradeFunctions.Run();
    end;

    var
        UpgradeFunctions: Codeunit "IDYS Upgrade Functions";
}