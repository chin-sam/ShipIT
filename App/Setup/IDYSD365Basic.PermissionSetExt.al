#if not BC17
permissionsetextension 11147639 "IDYS D365 Basic" extends "D365 BASIC"
{
    Permissions =
        tabledata "IDYS Setup" = R,
        tabledata "IDYS Provider Setup" = Rmid,
        tabledata "IDYS Provider Package Type" = rmid,
        tabledata "IDYS BookingProf. Package Type" = rmid,
        page "IDYS Setup" = X,
        page "IDYS Providers" = X;
}
#endif