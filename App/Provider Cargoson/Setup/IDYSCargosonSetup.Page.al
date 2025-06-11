page 11147706 "IDYS Cargoson Setup"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "IDYS Setup";
    SourceTableView = where(Provider = const(Cargoson));
    InsertAllowed = false;
    Caption = 'Cargoson Setup';
    ContextSensitiveHelpPage = '22380623';

    layout
    {
        area(Content)
        {
            group(Integration)
            {
                Caption = 'Integration';
                group(Authentication)
                {
                    Caption = 'Cargoson Credentials';
                    InstructionalText = 'Environment type is determined by the API key value.';

                    field(APIKey; APIKey)
                    {
                        ApplicationArea = All;
                        Editable = PageEditable;
                        ToolTip = 'Your Cargoson API Key.';
                        Caption = 'API Key';
                        Visible = not DemoMode;

                        trigger OnValidate()
                        begin
                            OnValidateAPIKey();
                        end;
                    }
                    field(APIKeyMasked; APIKey)
                    {
                        ApplicationArea = All;
                        Editable = PageEditable;
                        ToolTip = 'Your Cargoson API Key.';
                        Caption = 'API Key';
                        ExtendedDatatype = Masked;
                        Visible = DemoMode;

                        trigger OnValidate()
                        begin
                            OnValidateAPIKey();
                        end;
                    }
                    field(Enabled; IDYSProviderSetup.Enabled)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if provider is enabled.';
                        Enabled = APIKey <> '';
                        Editable = not DemoMode;

                        trigger OnValidate()
                        var
                            CredentialsNotCompleteErr: Label 'Cargoson API key must be filled in before the provider can be enabled.';
                        begin
                            if IDYSProviderSetup.Enabled then
                                if APIKey = '' then
                                    Error(CredentialsNotCompleteErr);

                            IDYSProviderSetup.Validate(Enabled);
                            IDYSProviderSetup.Modify();
                            IsCargosonEnabled := IDYSProviderSetup.Enabled;
                        end;
                    }
                }
                group(AcceptanceOrLive)
                {
                    Caption = 'Cargoson';
                    InstructionalText = 'Do you want to connect to Cargoson Acceptance or Production?';
                    Editable = not DemoMode;
                    field("Transsmart Environment"; Rec."Transsmart Environment")
                    {
                        ApplicationArea = All;
                        Caption = 'Cargoson Environment';
                        ToolTip = 'Specifies is the setup is acceptance or production.';
                    }
                }
            }
            group(Defaults)
            {
                Caption = 'Defaults';
                group(General)
                {
                    group(Packages)
                    {
                        ShowCaption = false;

                        field("Default Package Type"; Rec."Default Provider Package Type")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the default package type.';
                        }
                        field("Label Format"; Rec."Label Format")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the default label format.';
                        }
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
                                IDYSShipAgentMapping.SetRange(Provider, "IDYS Provider"::Cargoson);
                                IDYSShipAgentMappings.SetTableView(IDYSShipAgentMapping);
                                IDYSShipAgentMappings.RunModal();
                                CurrPage.Update(true);
                            end;
                        }
                    }
                    group(PrintIT)
                    {
                        field("PrintNode API Key"; IDYPSetup."API Key")
                        {
                            ApplicationArea = All;
                            Caption = 'PrintNode API Key';
                            ToolTip = 'Specifies the PrintNode API Key';

                            trigger OnValidate()
                            var
                                EndpointManagement: Codeunit "IDYM Endpoint Management";
                            begin
                                if IDYPSetup."API Key" <> '' then
                                    EndPointManagement.RegisterCredentials("IDYM Endpoint Service"::PrintNode, "IDYM Endpoint Usage"::Default, AppInfo.Id(), "IDYM Authorization Type"::Basic, IDYPSetup."API Key", '')
                                else
                                    EndpointManagement.ClearCredentials("IDYM Endpoint Service"::PrintNode, "IDYM Endpoint Usage"::Default);
                                IDYPSetup.Modify();
                                CurrPage.Update();
                            end;
                        }
                        field("Enable PrintIT Printing"; Rec."Enable PrintIT Printing")
                        {
                            ToolTip = 'If enabled, the application will use PrintIT solution.';
                            ApplicationArea = All;
                        }
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
        }
    }

    actions
    {
        area(Navigation)
        {
            group("PrintIT Actions")
            {
                Caption = 'PrintIT';
                action(Printers)
                {
                    Caption = 'Printers';
                    ApplicationArea = All;
                    Image = Print;
                    ToolTip = 'Opens the list of PrintNode printers.';
                    RunObject = Page "IDYP Printers";
                }
                action("User Printers")
                {
                    Caption = 'User Printers';
                    ApplicationArea = All;
                    Image = Print;
                    ToolTip = 'Opens the list of user printers.';
                    RunObject = Page "IDYP User Printers";
                }
            }
            action(ShipmentMethodMappings)
            {
                RunObject = page "IDYS Shipment Method Mappings";
                ApplicationArea = All;
                Caption = 'Shipment Method Mappings';
                Image = CalculateShipment;
                ToolTip = 'Opens the shipping method mappings list page.';
                Enabled = IsCargosonEnabled;
            }
            action("Incoterms")
            {
                RunObject = page "IDYS Incoterms";
                ApplicationArea = All;
                Caption = 'Incoterms';
                Image = Inventory;
                ToolTip = 'Opens the incoterms list page.';
                Enabled = IsCargosonEnabled;
            }
            action("Carriers")
            {
                RunObject = page "IDYS Provider Carriers";
                RunPageLink = Provider = field(Provider);
                ApplicationArea = All;
                Caption = 'Carriers';
                Image = Inventory;
                ToolTip = 'Opens the carriers list page.';
                Enabled = IsCargosonEnabled;
            }
            action("Package Types")
            {
                ApplicationArea = All;
                Caption = 'Package Types';
                Image = Inventory;
                ToolTip = 'Opens the package types list page.';
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Enabled = IsCargosonEnabled;

                trigger OnAction()
                var
                    IDYSProviderPackageType: Record "IDYS Provider Package Type";
                    IDYSProviderPackageTypes: Page "IDYS Provider Package Types";
                begin
                    IDYSProviderPackageType.SetRange(Provider, IDYSProviderPackageType.Provider::Cargoson);
                    IDYSProviderPackageTypes.Editable(true);
                    IDYSProviderPackageTypes.SetTableView(IDYSProviderPackageType);
                    IDYSProviderPackageTypes.Run();
                end;
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
                Enabled = IsCargosonEnabled;

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
                actionref("Update Master Data_Promoted"; "Update Master Data") { }
                actionref("Package Types_Promoted"; "Package Types") { }
            }
        }
#endif
    }

    trigger OnOpenPage()
    var
        Setup: Record "IDYS Setup";
    begin
        Rec.GetProviderSetup("IDYS Provider"::Cargoson);
        IDYSProviderSetup.Get("IDYS Provider"::Cargoson);
        if Setup.Get() then;
        DemoMode := Setup."Demo Mode";
        IsCargosonEnabled := IDYSProviderSetup.Enabled;
        NavApp.GetCurrentModuleInfo(AppInfo);

        if not IDYPSetup.Get() then begin
            IDYPSetup.Init();
            IDYPSetup.Insert(true);
        end;
    end;

    trigger OnAfterGetRecord()
    var
        CanContinue: Boolean;
    begin
        PageEditable := CurrPage.Editable();
        CanContinue := IDYMEndpoint.Get("IDYM Endpoint Service"::Cargoson, "IDYM Endpoint Usage"::Default);
        if CanContinue then
            CanContinue := IDYMEndpoint.HasApiKeyValue();
        if CanContinue then
            APIKey := IDYMEndpoint.GetApiKeyValue();
        CheckShippingMappingInformation();
    end;

    local procedure ClearEndpointCredentials()
    var
        IDYMEndpointManagement: Codeunit "IDYM Endpoint Management";
        CanContinue: Boolean;
    begin
        CanContinue := IDYMEndpoint.Get("IDYM Endpoint Service"::Cargoson, "IDYM Endpoint Usage"::Default);
        if CanContinue then
            CanContinue := IDYMEndpoint.HasApiKeyValue();
        if CanContinue then
            IDYMEndpointManagement.ClearCredentials("IDYM Endpoint Service"::Cargoson, "IDYM Endpoint Usage"::Default);
    end;

    local procedure CheckShippingMappingInformation()
    var
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
        MissingInformationLbl: Label 'Missing Shipping Agent Mapping(s).';
        ShippingInformationLbl: Label 'Mapped Carriers - %1 out of %2.', Comment = '%1 = Shipping agent mapping count, %2 = Total carrier count.';
    begin
        IDYSProviderCarrier.SetRange(Provider, "IDYS Provider"::Cargoson);
        IDYSShipAgentMapping.SetRange(Provider, "IDYS Provider"::Cargoson);
        if IDYSShipAgentMapping.IsEmpty() then begin
            ShippingMappingInformation := MissingInformationLbl;
            ShippingMappingInformationStyleExpr := 'Unfavorable';
        end else begin
            ShippingMappingInformation := StrSubstNo(ShippingInformationLbl, IDYSShipAgentMapping.Count(), IDYSProviderCarrier.Count());
            ShippingMappingInformationStyleExpr := 'Strong';
        end;
    end;

    local procedure OnValidateAPIKey()
    var
        IDYMEndpointManagement: Codeunit "IDYM Endpoint Management";
    begin
        ClearEndpointCredentials();
        if APIKey <> '' then begin
            IDYMEndpointManagement.RegisterCredentials("IDYM Endpoint Service"::Cargoson, "IDYM Endpoint Usage"::Default, AppInfo.Id(), "IDYM Authorization Type"::ApiKey, 'Authorization', APIKey, true);
            IDYSProviderSetup.Validate(Enabled, true);
            IDYSProviderSetup.Modify();
            IsCargosonEnabled := true;
        end else begin
            IDYSProviderSetup.Validate(Enabled, false);
            IDYSProviderSetup.Modify();
            IsCargosonEnabled := false;
        end;
    end;

    protected var
        APIKey: Text;
        PageEditable: Boolean;

    var
        IDYMEndpoint: Record "IDYM Endpoint";
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IDYPSetup: Record "IDYP Setup";
        IDYSIProvider: Interface "IDYS IProvider";
        AppInfo: ModuleInfo;
        DemoMode: Boolean;
        IsCargosonEnabled: Boolean;
        ShippingMappingInformation: Text;
        ShippingMappingInformationStyleExpr: Text;
}