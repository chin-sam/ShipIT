#if not BC17
permissionset 11147830 "IDYS SC Sendcloud"
{
    Caption = 'Sendcloud';
    Assignable = true;
    IncludedPermissionSets = "IDYS ShipIT 365";

     Permissions = 
        codeunit "IDYS SC Subscribers" = X;
}
#endif