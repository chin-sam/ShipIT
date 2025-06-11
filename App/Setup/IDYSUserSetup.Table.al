table 11147651 "IDYS User Setup"
{
    Caption = 'User Setup';
    LookupPageId = "IDYS User Setup";

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                User: Record User;
                UserLookup: Page "User Lookup";
            begin
                if "User ID" <> '' then begin
                    User.SetRange("User Name", "User ID");
                    if User.FindFirst() then begin
                        User.SetRange("User Name");
                        UserLookup.SetRecord(User);
                    end;
                end;
                UserLookup.LookupMode(true);
                if UserLookup.RunModal() = Action::LookupOK then begin
                    UserLookup.GetRecord(User);
                    Validate("User ID", User."User Name");
                end;
            end;
        }

        field(2; "User Name (External)"; Text[80])
        {
            Caption = 'User Name (External)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Password (External)", '');
            end;
        }

        field(3; "Password (External)"; Text[80])
        {
            Caption = 'Password (External)';
            ExtendedDatatype = Masked;
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                IDYMEndpointManagement: Codeunit "IDYM Endpoint Management";
                AppInfo: ModuleInfo;
            begin
                if "Password (External)" <> '' then begin
                    TestField("User Name (External)");
                    NavApp.GetCurrentModuleInfo(AppInfo);
                    IDYMEndpointManagement.RegisterCredentials("IDYM Endpoint Service"::Transsmart, "IDYM Endpoint Usage"::GetToken, AppInfo.Id(), "IDYM Authorization Type"::Basic, "IDYM Endpoint Sub Type"::Username, "User ID", "User Name (External)", "Password (External)");
                    IDYMEndpointManagement.RegisterEndpoint("IDYM Endpoint Service"::Transsmart, "IDYM Endpoint Usage"::Default, "IDYM Authorization Type"::Bearer, AppInfo.Id, "IDYM Endpoint Sub Type"::Username, "User ID");
                end;
            end;
        }

        field(4; "Default"; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                UserSetup: Record "IDYS User Setup";
            begin
                UserSetup.SetFilter("User ID", '<>%1', "User ID");
                UserSetup.SetRange(Default, true);
                UserSetup.ModifyAll(Default, false);
            end;
        }

        #region [nShift Ship - printing]
        field(50; "Label Type"; Enum "IDYS DelHub Label Type")
        {
            Caption = 'Label Type';
            DataClassification = CustomerContent;
        }
        field(51; "Ticket Username"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket Username';
        }
        field(52; "Workstation ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Workstation ID';
        }
        field(53; "Drop Zone Label Printer Key"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Drop Zone Label Printer Key';
        }

        field(54; "Enable Drop Zone Printing"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Drop Zone Printing';
        }
        #endregion
    }

    keys
    {
        key(PK; "User ID")
        {
        }
    }
}