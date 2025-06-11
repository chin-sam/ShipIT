#if not BC17
permissionsetextension 11147640 "IDYS D365 Basic ISV" extends "D365 BASIC ISV"
{
    Permissions =
        tabledata "IDYS Setup" = R,
        tabledata "IDYS Provider Setup" = R,
        page "IDYS Setup" = X,
        page "IDYS Providers" = X;
}
#endif