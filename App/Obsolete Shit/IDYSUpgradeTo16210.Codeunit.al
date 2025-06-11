codeunit 11147662 "IDYS Upgrade To 16.2.1.0"
{
    Subtype = Upgrade;
    ObsoleteReason = 'Moved to codeunit 11147674';
    ObsoleteState = Pending;

    trigger OnUpgradePerCompany()
    begin
    end;

    procedure GetInstallingVersionNo(): Text
    begin
    end;

    procedure GetCurrentlyInstalledVersionNo(): Text
    begin
    end;
}