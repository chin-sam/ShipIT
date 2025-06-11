#if not BC17
permissionset 11147836 "IDYS TS Transsmart"
{
    Caption = 'Transsmart';
    Assignable = true;
    IncludedPermissionSets = "IDYS ShipIT 365";

     Permissions = 
        codeunit "IDYS TS Subscribers" = X;
}
#endif