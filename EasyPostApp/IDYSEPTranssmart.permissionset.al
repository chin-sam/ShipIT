#if not BC17
permissionset 11147827 "IDYS EP Transsmart"
{
    Caption = 'Easypost';
    Assignable = true;
    IncludedPermissionSets = "IDYS ShipIT 365";
    ObsoleteReason = 'Wrong Name';
    ObsoleteState = Pending;
    ObsoleteTag = '22.10';

     Permissions = 
        codeunit "IDYS EP Subscribers" = X;
}
#endif