#if not BC17
permissionset 11147828 "IDYS EP Easypost"
{
    Caption = 'Easypost';
    Assignable = true;

     Permissions = 
        codeunit "IDYS EP Subscribers" = X;
}
#endif