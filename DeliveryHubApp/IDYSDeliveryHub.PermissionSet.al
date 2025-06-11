#if not BC17
permissionset 11147833 "IDYS Delivery Hub"
{
    Caption = 'nShift Ship';
    Assignable = true;
    IncludedPermissionSets = "IDYS ShipIT 365";

    Permissions = 
        codeunit "IDYS Delivery Hub Subscribers" = X;
}
#endif