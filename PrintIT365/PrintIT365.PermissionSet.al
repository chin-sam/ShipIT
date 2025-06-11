
#if not BC17
permissionset 11147839 "IDYP PrintIT 365"
{
    Assignable = true;
    Permissions = tabledata "IDYP Printer" = RIMD,
        tabledata "IDYP Setup" = RIMD,
        tabledata "IDYP User Printer" = RIMD,
        table "IDYP Printer" = X,
        table "IDYP Setup" = X,
        table "IDYP User Printer" = X,
        codeunit "IDYP PrintNode Management" = X,
        page "IDYP Printers" = X,
        page "IDYP Setup" = X,
        page "IDYP User Printers" = X;
}
#endif