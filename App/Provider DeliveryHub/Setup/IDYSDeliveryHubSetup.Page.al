page 11147724 "IDYS Delivery Hub Setup"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "IDYS Setup";
    SourceTableView = where(Provider = const("Delivery Hub"));
    InsertAllowed = false;
    Caption = 'nShift Ship Setup';
    ContextSensitiveHelpPage = '23035979';

    layout
    {
        area(Content)
        {
            group(Integration)
            {
                Caption = 'Integration';
                group(UsernamePassword)
                {
                    Caption = 'nShift Ship Credentials';
                    field(Actor; Rec."Transsmart Account Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Main Actor';
                        ToolTip = 'Your main actor account code.';
                        Visible = not DemoMode;
                    }
                    field(ActorMasked; Rec."Transsmart Account Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Main Actor';
                        ToolTip = 'Your main actor account code.';
                        Visible = DemoMode;
                        ExtendedDatatype = Masked;
                    }

                    field(ClientID; ClientID)
                    {
                        ApplicationArea = All;
                        Editable = PageEditable;
                        ToolTip = 'Your nShift Ship integration client id.';
                        Caption = 'Client Id';

                        trigger OnValidate()
                        begin
                            ClearEndpointCredentials();
                            if (ClientID = '') and IDYSProviderSetup.Enabled then begin
                                IDYSProviderSetup.Validate(Enabled, false);
                                IDYSProviderSetup.Modify();
                                IsDelHubEnabled := false;
                            end;
                        end;
                    }
                    field(Secret; Secret)
                    {
                        ExtendedDatatype = Masked;
                        Editable = PageEditable;
                        ApplicationArea = All;
                        ToolTip = 'Your nShift Ship client secret';
                        Caption = 'Client Secret';

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
                                if (ClientID <> '') and (ClientIDData <> '') and (SecretData <> '') then begin
                                    IDYSProviderSetup.Validate(Enabled, true);
                                    IDYSProviderSetup.Modify();
                                    IsDelHubEnabled := true;
                                end;
                            end else
                                if IDYSProviderSetup.Enabled then begin
                                    IDYSProviderSetup.Validate(Enabled, false);
                                    IDYSProviderSetup.Modify();
                                    IsDelHubEnabled := false;
                                end;
                        end;
                    }

                    field(ClientIDData; ClientIDData)
                    {
                        ApplicationArea = All;
                        Editable = PageEditable;
                        ToolTip = 'Your nShift Ship integration client id (data access).';
                        Caption = 'Client Id (Data Access)';

                        trigger OnValidate()
                        begin
                            ClearDataEndpointCredentials();
                            if (ClientIDData = '') and IDYSProviderSetup.Enabled then begin
                                IDYSProviderSetup.Validate(Enabled, false);
                                IDYSProviderSetup.Modify();
                                IsDelHubEnabled := false;
                            end;
                        end;
                    }
                    field(SecretData; SecretData)
                    {
                        ExtendedDatatype = Masked;
                        Editable = PageEditable;
                        ApplicationArea = All;
                        ToolTip = 'Your nShift Ship client secret (data access).';
                        Caption = 'Client Secret (Data Access)';

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
                                if (ClientID <> '') and (Secret <> '') and (ClientIDData <> '') then begin
                                    IDYSProviderSetup.Validate(Enabled, true);
                                    IDYSProviderSetup.Modify();
                                    IsDelHubEnabled := true;
                                end;
                            end else
                                if IDYSProviderSetup.Enabled then begin
                                    IDYSProviderSetup.Validate(Enabled, false);
                                    IDYSProviderSetup.Modify();
                                    IsDelHubEnabled := false;
                                end;
                        end;
                    }
                    field(Enabled; IDYSProviderSetup.Enabled)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if provider is enabled.';
                        Enabled = SecretData <> '';
                        Editable = not DemoMode;

                        trigger OnValidate()
                        var
                            CredentialsNotCompleteErr: Label 'All nShift Ship client fields must be filled in before the provider can be enabled.';
                        begin
                            if IDYSProviderSetup.Enabled then
                                if (ClientID = '') or (Secret = '') or (ClientIDData = '') or (SecretData = '') then
                                    Error(CredentialsNotCompleteErr);

                            IDYSProviderSetup.Validate(Enabled);
                            IDYSProviderSetup.Modify();
                            IsDelHubEnabled := IDYSProviderSetup.Enabled;
                        end;
                    }
                }
                group(AcceptanceOrLive)
                {
                    Caption = 'nShift Ship Environment';
                    InstructionalText = 'Do you want to connect to nShift Ship Acceptance or Production?';
                    Editable = not DemoMode;
                    field("Transsmart Environment"; Rec."Transsmart Environment")
                    {
                        ApplicationArea = All;
                        Caption = 'nShift Ship Environment';
                        ToolTip = 'Specifies is the setup is acceptance or production.';
                    }
                }
            }
            group(Defaults)
            {
                Caption = 'Defaults';
                group("Packages & Services")
                {
                    Caption = 'Packages & Services';
                    InstructionalText = 'To optimize the configuration of default packages and services, access the Shipping Agent Mappings and use actions to navigate. Alternatively, all packages can also be accessed from this setup for greater convenience and flexibility.';

                    field(ShippingMappingInformation; ShippingMappingInformation)
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        ToolTip = 'Indicates shipping agent mapping information.';
                        Editable = false;
                        StyleExpr = ShippingMappingInformationStyleExpr;
                        DrillDown = true;

                        trigger OnDrillDown()
                        var
                            IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
                            IDYSShipAgentMappings: Page "IDYS Ship. Agent Mappings";
                        begin
                            IDYSShipAgentMapping.SetRange(Provider, "IDYS Provider"::"Delivery Hub");
                            IDYSShipAgentMappings.SetTableView(IDYSShipAgentMapping);
                            IDYSShipAgentMappings.RunModal();
                            CurrPage.Update(true);
                        end;
                    }
                }

                group(ConversionGroup)
                {
                    Caption = 'Conversion';
                    group(Mass)
                    {
                        field("Conversion Factor (Mass)"; Rec."Conversion Factor (Mass)")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the Conversion Factor (Mass).';
                        }

                        field("Rounding Precision (Mass)"; Rec."Rounding Precision (Mass)")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the Rounding Precision (Mass).';
                        }
                    }
                    group(Linear)
                    {
                        Visible = false;
                        field("Conversion Factor (Linear)"; Rec."Conversion Factor (Linear)")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the Conversion Factor (Linear).';
                        }

                        field("Rounding Precision (Linear)"; Rec."Rounding Precision (Linear)")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the Rounding Precision (Linear).';
                        }
                    }
                    group(Volume)
                    {
                        Visible = false;
                        field("Conversion Factor (Volume)"; Rec."Conversion Factor (Volume)")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the Conversion Factor (Volume).';
                        }

                        field("Rounding Precision (Volume)"; Rec."Rounding Precision (Volume)")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the Rounding Precision (Volume).';
                        }
                    }
                }
            }
            part("IDYS B. Prof. Pck. Types Sub."; "IDYS B. Prof. Pck. Types Sub.")
            {
                Caption = 'Package Types';
                SubPageLink = Provider = const("Delivery Hub");
                ApplicationArea = All;
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Moved to Shipping Agent Mapping';
                ObsoleteTag = '21.0';
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Unit of Measure Mappings")
            {
                RunObject = page "IDYS Unit Of Measure Mappings";
                ApplicationArea = All;
                Caption = 'Unit Of Measure Mappings';
                Image = CalculateShipment;
                ToolTip = 'Opens the unit of measure mappings list page.';
                Enabled = IsDelHubEnabled;
            }

            action("Carriers")
            {
                RunObject = page "IDYS Provider Carriers";
                RunPageLink = Provider = field(Provider);
                RunPageView = sorting(Provider, CarrierConceptID);
                ApplicationArea = All;
                Caption = 'Carriers';
                Image = Inventory;
                ToolTip = 'Opens the carriers list page.';
                Enabled = IsDelHubEnabled;
            }
            action("B. Prof. Packages")
            {
                RunObject = page "IDYS B. Prof. Packages";
                RunPageLink = Provider = field(Provider);
                ApplicationArea = All;
                Caption = 'Packages';
                Image = Inventory;
                ToolTip = 'Opens the packages list page.';
                Enabled = IsDelHubEnabled;
            }
            action("User Setup")
            {
                ApplicationArea = All;
                Caption = 'User Setup';
                Image = CalculateShipment;
                ToolTip = 'Opens the user setup page.';
                RunObject = page "IDYS Delivery Hub User Setup";
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Enabled = IsDelHubEnabled;
            }
            action("Additional Actors")
            {
                ApplicationArea = All;
                Caption = 'Additional Actors';
                Image = SetupList;
                ToolTip = 'Opens the additional actors list page.';
                RunObject = page "IDYS Additional Actors";
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Enabled = IsDelHubEnabled;
            }
        }
        area(Processing)
        {
            action("Update Master Data")
            {
                Caption = 'Update Master Data';
                ToolTip = 'Retrieves all configured master data from the selected API.';
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Image = Refresh;
                ApplicationArea = All;
                Enabled = IsDelHubEnabled;

                trigger OnAction();
                var
                    IDYSCreateMappings: Codeunit "IDYS Create Mappings";
                begin
                    IDYSProviderSetup.TestField(Enabled);
                    IDYSCreateMappings.CreateMappings();

                    IDYSIProvider := Rec.Provider;
                    IDYSIProvider.GetMasterData(true);
                end;

            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Update Master Data_Promoted"; "Update Master Data")
                {
                }
                actionref("User Setup_Promoted"; "User Setup")
                {
                }
                actionref("Additional Actors_Promoted"; "Additional Actors")
                {
                }
            }
        }
#endif
    }

    trigger OnOpenPage()
    var
        Setup: Record "IDYS Setup";
    begin
        Rec.GetProviderSetup("IDYS Provider"::"Delivery Hub");
        IDYSProviderSetup.Get("IDYS Provider"::"Delivery Hub");
        if Setup.Get() then
            DemoMode := Setup."Demo Mode";
        if not IDYSUserSetup.Get(UserId()) then
            IDYSUserSetup.Init();
        IsDelHubEnabled := IDYSProviderSetup.Enabled;
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

        CheckShippingMappingInformation();
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

    local procedure CheckShippingMappingInformation()
    var
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        MissingInformationLbl: Label 'Missing Shipping Agent Mapping(s).';
        ShippingInformationLbl: Label 'Mapped Carriers - %1 out of %2.', Comment = '%1 = Shipping agent mapping count, %2 = Total carrier count.';
    begin
        IDYSProviderCarrier.SetRange(Provider, "IDYS Provider"::"Delivery Hub");
        IDYSShipAgentMapping.SetRange(Provider, "IDYS Provider"::"Delivery Hub");
        if IDYSShipAgentMapping.IsEmpty() then begin
            ShippingMappingInformation := MissingInformationLbl;
            ShippingMappingInformationStyleExpr := 'Unfavorable';
        end else begin
            ShippingMappingInformation := StrSubstNo(ShippingInformationLbl, IDYSShipAgentMapping.Count(), IDYSProviderCarrier.Count());
            ShippingMappingInformationStyleExpr := 'Strong';
        end;
    end;


    protected var
        ClientID: Text[150];
        Secret: Text;
        ClientIDData: Text[150];
        SecretData: Text;
        PageEditable: Boolean;

    var
        IDYMEndpoint: Record "IDYM Endpoint";
        DataIDYMEndpoint: Record "IDYM Endpoint";
        IDYSUserSetup: Record "IDYS User Setup";
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IDYSIProvider: Interface "IDYS IProvider";
        AppInfo: ModuleInfo;
        DemoMode: Boolean;
        IsDelHubEnabled: Boolean;
        ShippingMappingInformation: Text;
        ShippingMappingInformationStyleExpr: Text;
}