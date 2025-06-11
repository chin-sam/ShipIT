page 11147685 "IDYS Transsmart Wizard Setup"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "IDYS Setup";
    SourceTableView = where(Provider = const(Transsmart));
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'nShift Transsmart Setup';
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by nShift Transsmart Setup page';
    ObsoleteTag = '18.8';

    layout
    {
        area(Content)
        {
            group(Integration)
            {
                Caption = 'nShift Transsmart Credentials';
                field("Transsmart Account"; Rec."Transsmart Account Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Your nShift Transsmart account code.';
                }
                field("Transsmart Environment"; Rec."Transsmart Environment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies is the setup is acceptance or production.';
                }
                field("Transsmart User Name"; IDYSUserSetup."User Name (External)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Your nShift Transsmart user name.';
                    Caption = 'User Name';

                    trigger OnValidate()
                    begin
                        IDYSUserSetup.Validate("Password (External)", '');
                    end;
                }
                field("Transsmart Password"; IDYSUserSetup."Password (External)")
                {
                    ExtendedDatatype = Masked;
                    ApplicationArea = All;
                    ToolTip = 'Your nShift Transsmart password.';
                    Caption = 'Password';

                    trigger OnValidate()
                    begin
                        IDYSUserSetup.TestField("User Name (External)");
                        IDYSUserSetup.Validate(IDYSUserSetup."Password (External)");
                        IDYSUserSetup.Validate(Default, true);
                        if not IDYSUserSetup.Insert() then
                            IDYSUserSetup.Modify();
                        if IDYSUserSetup."Password (External)" <> '' then begin
                            IDYSProviderSetup.Validate(Enabled, true);
                            IDYSProviderSetup.Modify();
                        end else begin
                            IDYSProviderSetup.Validate(Enabled, false);
                            IDYSProviderSetup.Modify();
                        end;
                    end;
                }
                field(Enabled; IDYSProviderSetup.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if provider is enabled.';

                    trigger OnValidate()
                    begin
                        if IDYSProviderSetup.Enabled then begin
                            Rec.TestField("Transsmart Account Code");
                            IDYSUserSetup.TestField("User Name (External)");
                            IDYSUserSetup.TestField("Password (External)");
                        end;
                        IDYSProviderSetup.Validate(Enabled);
                        IDYSProviderSetup.Modify();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetProviderSetup("IDYS Provider"::Transsmart);
        IDYSProviderSetup.Get("IDYS Provider"::Transsmart);
        if not IDYSUserSetup.Get(UserId()) then begin
            IDYSUserSetup.SetRange(Default, True);
            if not IDYSUserSetup.FindFirst() then begin
                IDYSUserSetup.Init();
                IDYSUserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(IDYSUserSetup."User ID"));
            end;
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::LookupOK then
            VerifySetup();
    end;

    local procedure VerifySetup()
    begin
        Rec.TestField("Transsmart Account Code");
        IDYSUserSetup.TestField("User Name (External)");
        IDYSUserSetup.TestField("Password (External)");
        IDYSUserSetup.Validate(IDYSUserSetup."Password (External)");
        IDYSUserSetup.Validate(Default, true);
        if not IDYSUserSetup.Insert(true) then
            IDYSUserSetup.Modify(true);
    end;

    var
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IDYSUserSetup: Record "IDYS User Setup";
}