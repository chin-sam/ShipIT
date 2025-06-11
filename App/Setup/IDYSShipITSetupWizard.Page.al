page 11147691 "IDYS ShipIT Setup Wizard"
{
    Caption = 'ShipIT Setup Wizard';
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "IDYS Setup";
    Editable = true;

    ContextSensitiveHelpPage = '96534553';

    layout
    {
        area(Content)
        {
            group(Step1)
            {
                Visible = CurrentStep = 1;

                usercontrol(SetupWizardAddin2; "IDYS Setup Wizard 02 Addin")
                {
                    ApplicationArea = All;

                    trigger AddinLoaded()
                    begin
                        CurrPage.SetupWizardAddin2.Initialize();
                    end;
                }
                group("Welcome to ShipIT 365 Setup")
                {
                    Caption = 'Welcome to the ShipIT 365';
                    group(LicenseKey)
                    {
                        Caption = 'License Key';
                        InstructionalText = 'If you''ve already received a license key, please proceed to next step. If you haven''t received your license key yet or need assistance, please choose one of the options below.';

                        field("Request Trial"; RequestTrial)
                        {
                            Caption = 'Request Trial Key';
                            ApplicationArea = All;
                            Editable = LicenseKey = '';
                            ToolTip = 'Specifies if a trial key should be requested from the apphub service.';

                            trigger OnValidate()
                            begin
                                ValidateUseTrialKey();
                            end;
                        }
                        field(LicenseKeyMasked; LicenseKey)
                        {
                            ApplicationArea = All;
                            Caption = 'License Key';
                            ToolTip = 'Specifies the license key.';
                            ExtendedDatatype = Masked;
                            Visible = DemoMode;

                            trigger OnValidate()
                            begin
                                ValidateLicenseKey();
                            end;
                        }
                        field("License Key"; LicenseKey)
                        {
                            ApplicationArea = All;
                            Caption = 'License Key';
                            ToolTip = 'Specifies the license key.';
                            Visible = not DemoMode;

                            trigger OnValidate()
                            begin
                                ValidateLicenseKey();
                            end;
                        }
                        field(LicenseKeyStatus; LicenseKeyStatus)
                        {
                            Caption = 'Status';
                            ApplicationArea = All;
                            Editable = false;
                            StyleExpr = LicenseKeyStatusStyle;
                            ToolTip = 'Specifies if the license key is valid.';
                            ObsoleteReason = 'Replaced with LicenseKeyStatusField';
                            ObsoleteState = Pending;
                            Visible = false;
                        }
                        field(LicenseKeyStatusField; LicenseKeyStatus)
                        {
                            Caption = 'Status';
                            ApplicationArea = All;
                            Editable = false;
                            StyleExpr = LicenseKeyStatusStyle;
                            ToolTip = 'Specifies if the license key is valid.';
                        }
                    }
                }
            }
            group(Step2)
            {
                Visible = CurrentStep = 2;

                group(TransportOrderNoSeries)
                {
                    Caption = 'Transport order no. series';
                    InstructionalText = 'Select the no. series you would like to use for Transport orders. If no number series was initially set, the system''s default value will be applied.';

                    field("Transport Order Nos."; Rec."Transport Order Nos.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies which no. series are used for transport orders.';
                    }
                }

                group(DefaultCountry)
                {
                    Caption = 'Default Ship-to Country/Region Code';
                    InstructionalText = 'Please provide the default Ship-to country/region. In case the country field on an order is empty, the default will be used.';

                    field("default Ship-to Country"; Rec."default Ship-to Country")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the default ship-to country/region code.';
                    }
                }
            }
            group(Step3)
            {
                Visible = CurrentStep = 3;

                group(UsernamePassword)
                {
                    Caption = 'nShift Transsmart Credentials';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with IDYS Select Providers subpage';
                    ObsoleteTag = '18.8';
                    Visible = false;
                    field("Transsmart User Name"; IDYSUserSetup."User Name (External)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Your nShift Transsmart user name.';
                        Caption = 'nShift Transsmart User Name';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with IDYS Select Providers subpage';
                        ObsoleteTag = '18.8';
                        Visible = false;
                    }
                    field("Transsmart Password"; IDYSUserSetup."Password (External)")
                    {
                        ExtendedDatatype = Masked;
                        ApplicationArea = All;
                        ToolTip = 'Your nShift Transsmart password.';
                        Caption = 'nShift Transsmart Password';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with IDYS Select Providers subpage';
                        ObsoleteTag = '18.8';
                        Visible = false;
                    }
                    field("Transsmart Account"; Rec."Transsmart Account Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Your nShift Transsmart account code.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with IDYS Select Providers subpage';
                        ObsoleteTag = '18.8';
                        Visible = false;
                    }
                }

                group(AcceptanceOrLive)
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with IDYS Select Providers subpage';
                    ObsoleteTag = '18.8';
                    Visible = false;
                    Caption = 'nShift Transsmart Environment';
                    InstructionalText = 'Do you want to connect to nShift Transsmart Acceptance or Production?';
                    field("Transsmart Environment"; Rec."Transsmart Environment")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies is the setup is acceptance or production.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with IDYS Select Providers subpage';
                        ObsoleteTag = '18.8';
                        Visible = false;
                    }
                }
                group(Providers)
                {
                    ShowCaption = false;
                    InstructionalText = 'Please create an account with one of the providers from the list below. Then click on the provider name, which will redirect you to a separate page where you can fill in your account settings and additional data that is required to enable the provider.';
                    part("IDYS Select Providers"; "IDYS Select Providers")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
            group(Step4)
            {
                Visible = CurrentStep = 4;

                group(DefaultSettings)
                {
                    Caption = 'Default Settings';
                    InstructionalText = '';

                    field("Default Cost Center"; Rec."Default Cost Center")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the default cost center.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Restructured with Provider level';
                        ObsoleteTag = '19.7';
                        Visible = false;
                    }
                    field("Default E-Mail Type"; Rec."Default E-Mail Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the default e-mail type.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Restructured with Provider level';
                        ObsoleteTag = '19.7';
                        Visible = false;
                    }
                    field("Auto. Add One Default Package"; Rec."Auto. Add One Default Package")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if a default package line should always be added to a new transport order.';
                    }
                    field("Default Package Type"; Rec."Default Package Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the default package type. This field is mandatory when the system is setup to automatically add a default Package.';
#if BC17
#pragma warning disable AL0604
                        Enabled = "Auto. Add One Default Package";
                        ShowMandatory = "Auto. Add One Default Package";
#pragma warning restore AL0604
#else
                        Enabled = Rec."Auto. Add One Default Package";
                        ShowMandatory = Rec."Auto. Add One Default Package";
#endif
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Restructured with Provider level';
                        ObsoleteTag = '19.7';
                        Visible = false;
                    }
                    field("Bing API Key"; Rec."Bing API Key")
                    {
                        ApplicationArea = All;
                        ToolTip = 'If specified, the application will show the Bing Map factbox on the Transport Order page.';

                        trigger OnAssistEdit()
                        var
                            HelpBingUrlLbl: Label 'https://docs.microsoft.com/en-us/bingmaps/getting-started/bing-maps-dev-center-help/creating-a-bing-maps-account', Locked = true;
                        begin
                            System.Hyperlink(HelpBingUrlLbl);
                        end;
                    }
                }
                grid(DeliveryAndPickup)
                {
                    GridLayout = Columns;
                    group(Delivery)
                    {
                        Caption = 'Delivery';
                        field("Delivery Time From"; Rec."Delivery Time From")
                        {
                            Caption = 'From';
                            ApplicationArea = All;
                            ToolTip = 'Specifies from what time delivery can take place.';
                        }
                        field("Delivery Time To"; Rec."Delivery Time To")
                        {
                            Caption = 'To';
                            ApplicationArea = All;
                            ToolTip = 'Specifies till what time delivery can take place.';
                        }
                    }
                    group(PickUp)
                    {
                        Caption = 'Pick Up';

                        field("Pick-up Time From"; Rec."Pick-up Time From")
                        {
                            Caption = 'From';
                            ApplicationArea = All;
                            ToolTip = 'Specifies from what time pick-up can take place.';
                        }
                        field("Pick-up Time To"; Rec."Pick-up Time To")
                        {
                            Caption = 'To';
                            ApplicationArea = All;
                            ToolTip = 'Specifies till what time pick-up can take place.';
                        }
                    }
                }
            }
            group(Step5)
            {
                Visible = CurrentStep = 5;

                group(Finished)
                {
                    ShowCaption = false;

                    usercontrol(Addin; "IDYS Setup Finished Addin")
                    {
                        ApplicationArea = All;

                        trigger AddinLoaded()
                        begin
                            CurrPage.Addin.InitializeAddin(SetupFinishedTxt);
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Contact Us")
            {
                Caption = 'Contact Us';
                ApplicationArea = All;
                Image = Info;
                InFooterBar = true;
                ToolTip = 'Contact Us';

                trigger OnAction();
                begin
                    page.Run(page::"IDYS Contact Card");
                end;
            }
            action("Our Manual")
            {
                Caption = 'Online Manual';
                ApplicationArea = All;
                Image = Info;
                InFooterBar = true;
                ToolTip = 'Online Manual';

                trigger OnAction();
                begin
                    Hyperlink('https://idyn.atlassian.net/wiki/spaces/S365M/pages/22151185/Introduction');
                end;
            }
            action(Back)
            {
                Caption = 'Back';
                ApplicationArea = All;
                InFooterBar = true;
                Enabled = BackAllowed;
                Image = PreviousRecord;
                ToolTip = 'Go one step back.';

                trigger OnAction()
                begin
                    TakeStep(-1);
                end;
            }
            action(Next)
            {
                Caption = 'Next';
                ApplicationArea = All;
                InFooterBar = true;
                Image = NextRecord;
                Enabled = NextAllowed;
                ToolTip = 'Go to the next step.';

                trigger OnAction()
                var
                    IDYSProviderSetup: Record "IDYS Provider Setup";
                    CreateMappings: Codeunit "IDYS Create Mappings";
                    Step: Integer;
                    ErrorCode: Integer;
                    ErrorMessage: Text;
                begin
                    if Rec."License Entry No." = 0 then
                        exit;
                    Step := 1;
                    case CurrentStep of
                        1:
                            begin
                                if not IDYSLicenseCheck.CheckLicense(Rec."License Entry No.", ErrorMessage, ErrorCode) then
                                    exit;

                                if Rec."Transport Order Nos." = '' then begin
                                    Rec."Transport Order Nos." := IDYSTransportOrderMgt.GetDefaultTransportOrderNoSeries();
                                    Rec.Modify();
                                end;
                            end;
                        2:
                            CreateMappings.CreateMappings();
                        3:
                            begin
                                IDYSProviderSetup.SetRange(Enabled, true);
                                if IDYSProviderSetup.IsEmpty() then
                                    Error(ProviderNotSelectedErr);
                            end;
                    // 4:
                    //     if Rec."Auto. Add One Default Package" then
                    //         Rec.TestField("Default Package Type");
                    end;
                    TakeStep(Step);
                end;
            }
            action(Finish)
            {
                Caption = 'Finish';
                ApplicationArea = All;
                InFooterBar = true;
                Enabled = FinishAllowed;
                Image = Approve;
                ToolTip = 'Finish the setup.';

                trigger OnAction()
                var
                    Initialize: Codeunit "IDYS Initialize";
                begin
                    Initialize.InitQtyOnExistingOrders();
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        Rec.SetRange("Primary Key", '');
        if Rec.IsEmpty() then begin
            Rec.InitSetup();
            Rec.Insert(true);
        end;
    end;

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        ErrorMessage: Text;
        ErrorCode: Integer;
    begin
        CloudInstall := EnvironmentInformation.IsSaaS() and (AzureADTenant.GetAadTenantId() <> '');
        if CloudInstall then
            IDYMAppHub.RegisterTenant(ErrorMessage, ErrorCode);
        DemoMode := Rec."Demo Mode";
        NavApp.GetCurrentModuleInfo(AppInfo);
        IDYMAppHub.NewAppVersionNotification(AppInfo.Id(), false);
        CurrentStep := 1;
        SetControls();
    end;

    trigger OnAfterGetRecord()
    begin
        CheckLicenseStatus();
    end;

    local procedure SetControls()
    begin
        BackAllowed := CurrentStep > 1;
        NextAllowed := CurrentStep < 5;
        FinishAllowed := CurrentStep = 5;
    end;

    local procedure TakeStep(Step: Integer)
    begin
        CurrentStep += Step;
        SetControls();
    end;

    local procedure ValidateUseTrialKey()
    var
        ErrorCode: Integer;
        ErrorMessage: Text;
    begin
        if not RequestTrial then
            exit;
        if IDYMAppHub.GetTrialLicenseKey(AppInfo.Id(), LicenseKey, false, ErrorCode, ErrorMessage) then
            ValidateLicenseKey()
        else
            if IDYMAppHub.NewTrialLicenseKey(AppInfo.Id(), LicenseKey, true, ErrorCode, ErrorMessage) then
                ValidateLicenseKey()
            else
                Clear(RequestTrial);
    end;

    local procedure ValidateLicenseKey()
    begin
        // SetLicenseKey();
        // CheckLicenseStatus();
        if LicenseKey = '' then
            Clear(RequestTrial);
        IDYSLicenseCheck.OnValidateLicenseKey(Rec, LicenseKeyStatus, LicenseKeyStatusStyle, LicenseKey);
        CurrPage.Update();
    end;

    local procedure CheckLicenseStatus(): Boolean
    var
        IDYMAppLicenseKey: Record "IDYM App License Key";
    begin
        if not GetLicenseKey(IDYMAppLicenseKey) then
            exit(false);
        // IDYMApphub.GetLicenseStatus(AppId, LicenseKey, LicenseKeyStatus, LicenseKeyStatusStyle);
        IDYSLicenseCheck.GetLicenseStatus(IDYMAppLicenseKey."Entry No.", LicenseKeyStatus, LicenseKeyStatusStyle);
    end;

    local procedure GetLicenseKey(var IDYMAppLicenseKey: Record "IDYM App License Key"): Boolean
    begin
        if Rec."License Entry No." = 0 then
            exit(false);
        if not IDYMAppLicenseKey.Get(Rec."License Entry No.") then
            exit(false);
        LicenseKey := IDYMAppLicenseKey."License Key";
        exit(LicenseKey <> '');
    end;

    var
        IDYSUserSetup: Record "IDYS User Setup";
        IDYMAppHub: Codeunit "IDYM Apphub";
        IDYSLicenseCheck: Codeunit "IDYS License Check";
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        AppInfo: ModuleInfo;
        CurrentStep: Integer;
        BackAllowed: Boolean;
        DemoMode: Boolean;
        NextAllowed: Boolean;
        FinishAllowed: Boolean;
        CloudInstall: Boolean;
        RequestTrial: Boolean;
        LicenseKey: Text[50];
        LicenseKeyStatus: Text;
        LicenseKeyStatusStyle: Text;
        SetupFinishedTxt: Label '<div id="container"><p><b>You have completed the initial ShipIT Setup.</b></p><p>Please do not forget to:</p><p> + Update/populate additional fields in the ShipIT Setup and add additional nShift Transsmart users in the ShipIT User Setup, if applicable.</p><p> + Map shipping agents, and the services per shipping agent.</p><p> + Map shipping methods.</p><p><b>Happy shipping!</b></p></div>';
        ProviderNotSelectedErr: Label 'Please enable at least one provider.';
}