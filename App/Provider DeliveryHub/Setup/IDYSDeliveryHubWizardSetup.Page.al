page 11147714 "IDYS Delivery Hub Wizard Setup"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = Integer;
    SourceTableView = where(Number = const(1));
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'nShift Ship Setup';
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by Delivery Hub Setup page';
    ObsoleteTag = '18.8';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                group(UsernamePassword)
                {
                    Caption = 'nShift Ship Credentials';
                    InstructionalText = 'Please provide your nShift Ship credentials and account code.';

                    field(Actor; IDYSDeliveryHubSetup."Transsmart Account Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Actor';
                        ToolTip = 'Your actor account code.';

                        trigger OnValidate()
                        begin
                            IDYSDeliveryHubSetup.Modify();
                        end;
                    }

                    field(ClientID; ClientID)
                    {
                        ApplicationArea = All;
                        Editable = PageEditable;
                        ToolTip = 'Your nShift Ship integration client id.';
                        Caption = 'Client id';

                        trigger OnValidate()
                        begin
                            ClearEndpointCredentials();
                        end;
                    }
                    field(Secret; Secret)
                    {
                        ExtendedDatatype = Masked;
                        Editable = PageEditable;
                        ApplicationArea = All;
                        ToolTip = 'Your nShift Ship client secret';
                        Caption = 'Client secret';

                        trigger OnValidate()
                        var
                            IDYMEndpointManagement: Codeunit "IDYM Endpoint Management";
                            xSecret: Text;
                        //InvalidCredentialsErr: Label 'The entered Client Id and Secret are not valid'; //is there a quick way to find out if credentials are valid. E.g. retrieve bearer token
                        begin
                            xSecret := Secret;
                            ClearEndpointCredentials();
                            Secret := xSecret;
                            if (Secret <> '') then begin
                                IDYMEndpointManagement.RegisterCredentials("IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::GetToken, AppInfo.Id(), "IDYM Authorization Type"::Anonymous, ClientID, Secret);
                                IDYMEndpointManagement.RegisterEndpoint("IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::Default, "IDYM Authorization Type"::Bearer, AppInfo.Id);
                            end;
                        end;
                    }

                    field(ClientIDData; ClientIDData)
                    {
                        ApplicationArea = All;
                        Editable = PageEditable;
                        ToolTip = 'Your nShift Ship integration client id (data access).';
                        Caption = 'Client id (data access)';

                        trigger OnValidate()
                        begin
                            ClearDataEndpointCredentials();
                        end;
                    }
                    field(SecretData; SecretData)
                    {
                        ExtendedDatatype = Masked;
                        Editable = PageEditable;
                        ApplicationArea = All;
                        ToolTip = 'Your nShift Ship client secret (data access).';
                        Caption = 'Client secret (data access)';

                        trigger OnValidate()
                        var
                            IDYMEndpointManagement: Codeunit "IDYM Endpoint Management";
                            xSecret: Text;
                        //InvalidCredentialsErr: Label 'The entered Client Id and Secret are not valid'; //is there a quick way to find out if credentials are valid. E.g. retrieve bearer token
                        begin
                            xSecret := SecretData;
                            ClearDataEndpointCredentials();
                            SecretData := xSecret;
                            if (SecretData <> '') then begin
                                IDYMEndpointManagement.RegisterCredentials("IDYM Endpoint Service"::DeliveryHubData, "IDYM Endpoint Usage"::GetToken, AppInfo.Id(), "IDYM Authorization Type"::Anonymous, ClientIDData, SecretData);
                                IDYMEndpointManagement.RegisterEndpoint("IDYM Endpoint Service"::DeliveryHubData, "IDYM Endpoint Usage"::Default, "IDYM Authorization Type"::Bearer, AppInfo.Id);
                            end;
                        end;
                    }
                }
                group(AcceptanceOrLive)
                {
                    Caption = 'nShift Ship Environment';
                    InstructionalText = 'Do you want to connect to nShift Ship Acceptance or Production?';
                    field("Transsmart Environment"; IDYSDeliveryHubSetup."Transsmart Environment")
                    {
                        ApplicationArea = All;
                        Caption = 'nShift Ship Environment';
                        ToolTip = 'Specifies is the setup is acceptance or production.';

                        trigger OnValidate()
                        begin
                            IDYSDeliveryHubSetup.Modify();
                        end;
                    }
                }
                group(ConversionGroup)
                {
                    Caption = 'Conversion';
                    field("Conversion Factor (Mass)"; IDYSDeliveryHubSetup."Conversion Factor (Mass)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Conversion Factor (Mass).';

                        trigger OnValidate()
                        begin
                            IDYSDeliveryHubSetup.Modify();
                        end;
                    }

                    field("Rounding Precision (Mass)"; IDYSDeliveryHubSetup."Rounding Precision (Mass)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Rounding Precision (Mass).';

                        trigger OnValidate()
                        begin
                            IDYSDeliveryHubSetup.Modify();
                        end;
                    }
                }
                group(Printing)
                {
                    Caption = 'Printing Setup';

                    field("Label Type"; IDYSUserSetup."Label Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Label Type.';

                        trigger OnValidate()
                        begin
                            if not IsInLookupMode then
                                IDYSUserSetup.Modify();
                        end;
                    }
                    field("Enable Drop Zone Printing"; IDYSUserSetup."Enable Drop Zone Printing")
                    {
                        ApplicationArea = All;
                        Tooltip = 'When enabled, the application will use Drop Zone printing functionality.';

                        trigger OnValidate()
                        begin
                            if not IsInLookupMode then
                                IDYSUserSetup.Modify();
                            DropZoneEnabled := IDYSUserSetup."Enable Drop Zone Printing";
                            CurrPage.Update();
                        end;
                    }
                    field("Ticket Username"; IDYSUserSetup."Ticket Username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Ticket Username.';
                        Editable = DropZoneEnabled;

                        trigger OnValidate()
                        begin
                            if not IsInLookupMode then
                                IDYSUserSetup.Modify();
                        end;
                    }
                    field("Workstation ID"; IDYSUserSetup."Workstation ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Workstation ID.';
                        Editable = DropZoneEnabled;

                        trigger OnValidate()
                        begin
                            if not IsInLookupMode then
                                IDYSUserSetup.Modify();
                        end;
                    }
                    field("Drop Zone Label Printer Key"; IDYSUserSetup."Drop Zone Label Printer Key")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Drop Zone Label Printer Key.';
                        Editable = DropZoneEnabled;

                        trigger OnValidate()
                        begin
                            IDYSUserSetup.Modify();
                        end;
                    }
                }

                part("IDYS B. Prof. Pck. Types Sub."; "IDYS B. Prof. Pck. Types Sub.")
                {
                    Caption = 'Package Types';
                    SubPageLink = Provider = const("Delivery Hub");
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        IDYSDeliveryHubSetup.GetProviderSetup("IDYS Provider"::"Delivery Hub");
        if not IDYSUserSetup.Get(UserId()) then
            IDYSUserSetup.Init();

        IsInLookupMode := CurrPage.LookupMode();
        DropZoneEnabled := IDYSUserSetup."Enable Drop Zone Printing";
        NavApp.GetCurrentModuleInfo(AppInfo);
    end;

    trigger OnAfterGetRecord()
    var
        CanContinue: Boolean;
    begin
        PageEditable := CurrPage.Editable();
        CanContinue := IDYMEndpoint.Get("IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::GetToken);
        if CanContinue then
            CanContinue := IDYMEndpoint.HasApiKeyValue();
        if CanContinue then begin
            ClientID := IDYMEndpoint."API Key Name";
            Secret := '*****';
        end else begin
            Clear(ClientID);
            Clear(Secret);
        end;

        CanContinue := DataIDYMEndpoint.Get("IDYM Endpoint Service"::DeliveryHubData, "IDYM Endpoint Usage"::GetToken);
        if CanContinue then
            CanContinue := DataIDYMEndpoint.HasApiKeyValue();
        if CanContinue then begin
            ClientIDData := DataIDYMEndpoint."API Key Name";
            SecretData := '*****';
        end else begin
            Clear(ClientIDData);
            Clear(SecretData);
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::LookupOK then
            VerifySetup();
    end;

    local procedure ClearEndpointCredentials()
    var
        CanContinue: Boolean;
    begin
        CanContinue := IDYMEndpoint.Get("IDYM Endpoint Service"::DeliveryHub, "IDYM Endpoint Usage"::GetToken);
        if CanContinue then
            CanContinue := IDYMEndpoint.HasApiKeyValue();
        if CanContinue then
            IDYMEndpoint.ResetCredentials();
        Clear(Secret);
    end;

    local procedure ClearDataEndpointCredentials()
    var
        CanContinue: Boolean;
    begin
        CanContinue := DataIDYMEndpoint.Get("IDYM Endpoint Service"::DeliveryHubData, "IDYM Endpoint Usage"::GetToken);
        if CanContinue then
            CanContinue := DataIDYMEndpoint.HasApiKeyValue();
        if CanContinue then
            DataIDYMEndpoint.ResetCredentials();
        Clear(SecretData);
    end;

    local procedure VerifySetup()
    var
        DHCredentialsErr: Label 'The password for nShift Ship has not been specified or is invalid.';
        DHDataCredentialsErr: Label 'The password for nShift Ship Data has not been specified or is invalid.';
    begin
        IDYSDeliveryHubSetup.TestField("Transsmart Account Code");
        IDYMEndpoint.TestField("API Key Name");
        if not IDYMEndpoint.HasApiKeyValue() then
            Error(DHCredentialsErr);
        DataIDYMEndpoint.TestField("API Key Name");
        if not DataIDYMEndpoint.HasApiKeyValue() then
            Error(DHDataCredentialsErr);
        IDYSDeliveryHubSetup.Validate("Transsmart Environment");

        IDYSUserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(IDYSUserSetup."User ID"));
        IDYSUserSetup.Validate(Default, true);
        if not IDYSUserSetup.Insert(true) then
            IDYSUserSetup.Modify(true);
    end;

    protected var
        ClientID: Text[150];
        Secret: Text;
        ClientIDData: Text[150];
        SecretData: Text;
        PageEditable: Boolean;

    var
        IDYSDeliveryHubSetup: Record "IDYS Setup";
        IDYMEndpoint: Record "IDYM Endpoint";
        DataIDYMEndpoint: Record "IDYM Endpoint";
        IDYSUserSetup: Record "IDYS User Setup";
        AppInfo: ModuleInfo;
        DropZoneEnabled: Boolean;
        IsInLookupMode: Boolean;
}