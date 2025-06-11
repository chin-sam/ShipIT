page 11147723 "IDYS Sendcloud Setup"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "IDYS Setup";
    SourceTableView = where(Provider = const(Sendcloud));
    InsertAllowed = false;
    Caption = 'Sendcloud Setup';
    ContextSensitiveHelpPage = '23232586';

    layout
    {
        area(Content)
        {
            group(Integration)
            {
                Caption = 'Integration';
                group("Sendcloud Credentials")
                {
                    Caption = 'Sendcloud Credentials';
                    field("Public Key"; UserName)
                    {
                        Caption = 'Public Key';
                        ToolTip = 'Your Sendcloud integration public key.';
                        ApplicationArea = All;
                        ShowMandatory = true;

                        trigger OnValidate()
                        var
                            EndpointManagement: Codeunit "IDYM Endpoint Management";
                        begin
                            Clear(Secret);
                            EndpointManagement.ClearCredentials("IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);
                            if (UserName = '') and IDYSProviderSetup.Enabled then begin
                                IDYSProviderSetup.Validate(Enabled, false);
                                IDYSProviderSetup.Modify();
                                IsSendCloudEnabled := false;
                            end;
                        end;
                    }
                    field(Secret; Secret)
                    {
                        Caption = 'Secret';
                        ApplicationArea = All;
                        ToolTip = 'Your Sendcloud integration secret.';
                        ExtendedDatatype = Masked;

                        trigger OnValidate()
                        var
                            EndpointManagement: Codeunit "IDYM Endpoint Management";
                        begin
                            if (Secret <> '') and (not EncryptionEnabled()) then
                                if Confirm(EncryptionIsNotActivatedQst) then
                                    Page.RunModal(Page::"Data Encryption Management");
                            if Secret <> '' then begin
                                EndPointManagement.RegisterCredentials("IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default, AppInfo.Id(), "IDYM Authorization Type"::Basic, UserName, Secret);
                                IDYSProviderSetup.Validate(Enabled, true);
                                IDYSProviderSetup.Modify();
                                IsSendCloudEnabled := true;
                            end else begin
                                EndpointManagement.ClearCredentials("IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);
                                if IDYSProviderSetup.Enabled then begin
                                    IDYSProviderSetup.Validate(Enabled, false);
                                    IDYSProviderSetup.Modify();
                                    IsSendCloudEnabled := false;
                                end;
                            end;
                        end;
                    }
                    field(Enabled; IDYSProviderSetup.Enabled)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if provider is enabled.';
                        Editable = not DemoMode;

                        trigger OnValidate()
                        var
                            CredentialsNotCompleteErr: Label 'All Sendcloud client fields must be filled in before the provider can be enabled.';
                        begin
                            if IDYSProviderSetup.Enabled then
                                if (Username = '') or (Secret = '') then
                                    Error(CredentialsNotCompleteErr);

                            IDYSProviderSetup.Validate(Enabled);
                            IDYSProviderSetup.Modify();
                            IsSendCloudEnabled := IDYSProviderSetup.Enabled;
                        end;
                    }
                }
            }
            group(Defaults)
            {
                Caption = 'Defaults';
                group(General)
                {
                    field("Automatically Select Applicable Ship. Method"; Rec."Aut. Select Appl. Ship. Method")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if the shipment method is automatically selected when the order is booked automatically.';
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
                group("Label")
                {
                    Caption = 'Shipping Label';
                    field("Request Label"; Rec."Request Label")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the default setting for if a label should be created for the parcel directly when sending it to the Sendcloud portal.';

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    field("Apply Shipping Rules"; Rec."Apply Shipping Rules")
                    {
                        Enabled = ApplyShippingRulesEnabled;
                        ApplicationArea = All;
                        ToolTip = 'Specifies if shipping rules should be applied when requesting a label or announcing a shipment in the sendcloud portal. Shipping rules can be used for specific branding (eg look and feel, trademarks, logo’s etc). Label''s must be requested to be able to use shipping rules.';
                    }
                    field("Label Type"; Rec."Label Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies which label type should be saved to the database as .pdf file.';
                    }
                    field("Apply External Document No."; Rec."Apply External Document No.")
                    {
                        Caption = 'Apply Ext. Doc. No. as order reference.';
                        ApplicationArea = All;
                        ToolTip = 'Indicates that the External Document No. will be sent to Sendcloud as the order reference for the labels and shipments.';
                    }
                }
                group("Weight")
                {
                    Caption = 'Item Weight';
                    InstructionalText = 'In order to easily select the correct shipping service and calculate shipping costs, the weight fields should have a value in all your sales items.';


                    field(ItemWeight; ItemWeight)
                    {
                        Caption = 'Item Weight';
                        ShowCaption = false;
                        ApplicationArea = All;
                        ToolTip = 'Indicates weight fields are filled for all sales items.';
                        StyleExpr = ItemWeightStyle;
                        Editable = false;
                        DrillDown = true;

                        trigger OnDrillDown()
                        var
                            Item: Record Item;
                            Items: Page "Item List";
                        begin
                            Item.SetFilter("Gross Weight", '=0');
                            Items.SetTableView(Item);
                            Items.RunModal();
                            CurrPage.Update(true);
                        end;
                    }

                    field("Weight to KG Conversion Factor"; Rec."Weight to KG Conversion Factor")
                    {
                        Caption = 'Weight to KG Conversion Factor';
                        ApplicationArea = ALl;
                        ToolTip = 'Specifies the conversion factor to convert weights as they are registered on items and documents to Kilograms. The conversion is only relevant when the weights are not registered in kilograms. Sendcloud uses weights in kg''s, and therefore the weight conversion is required. To convert grams to kgs use a conversion factor of 0.001 and to convert lbs to kgs use a conversion factor of 0.45359237';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with Conversion factors';
                        ObsoleteTag = '21.0';
                        Visible = false;
                    }
                }
                field("Default Package Type"; Rec."Default Provider Package Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default package type';
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
            action("Carriers")
            {
                RunObject = page "IDYS Provider Carriers";
                RunPageLink = Provider = field(Provider);
                ApplicationArea = All;
                Caption = 'Carriers';
                Image = Inventory;
                ToolTip = 'Opens the carriers list page.';
                Enabled = IsSendCloudEnabled;
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
                Enabled = IsSendCloudEnabled;

                trigger OnAction()
                var
                    IDYSProviderPackageType: Record "IDYS Provider Package Type";
                    IDYSProviderPackageTypes: Page "IDYS Provider Package Types";
                begin
                    IDYSProviderPackageType.SetRange(Provider, IDYSProviderPackageType.Provider::Sendcloud);
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
                Enabled = IsSendCloudEnabled;

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

            action("Ship-from / Ship-to Countries")
            {
                Caption = 'Ship-from / Ship-to Countries';
                ToolTip = 'Setup Ship-from / Ship-to Countries for which booking profiles and rates will be synchronized.';
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Image = ShipAddress;
                ApplicationArea = All;
                Enabled = IsSendCloudEnabled;
                RunObject = Page "Countries/Regions";
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
                actionref("Ship-from / Ship-to Countries_Promoted"; "Ship-from / Ship-to Countries")
                {
                }
                actionref("Package Types_Promoted"; "Package Types")
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
        Rec.GetProviderSetup("IDYS Provider"::Sendcloud);
        if Setup.Get() then;
        DemoMode := Setup."Demo Mode";
        IDYSProviderSetup.Get("IDYS Provider"::Sendcloud);
        IsSendCloudEnabled := IDYSProviderSetup.Enabled;

        if not IDYPSetup.Get() then begin
            IDYPSetup.Init();
            IDYPSetup.Insert(true);
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        if IDYMEndpoint.Get("IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default) and IDYMEndpoint.HasApiKeyValue() then begin
            UserName := IDYMEndpoint."API Key Name";
            Secret := '*****';
        end else begin
            Clear(Secret);
            Clear(UserName);
        end;

        CheckItemWeight();
        ApplyShippingRulesEnabled := Rec."Request Label";
    end;

    local procedure CheckItemWeight()
    var
        Item: Record Item;
        WeightsAvailableLbl: Label 'All Items have their "gross weight" field filled.';
        WeightsNotAvailableLbl: Label '%1 Items are missing "gross weight" information.', Comment = '%1 Item count.';
    begin
        Item.SetFilter("Gross Weight", '=0');
        if Item.IsEmpty() then begin
            ItemWeight := WeightsAvailableLbl;
            ItemWeightStyle := 'Favorable';
        end else begin
            ItemWeight := StrSubstNo(WeightsNotAvailableLbl, Item.Count());
            ItemWeightStyle := 'Subordinate';
        end;
    end;

    var
        IDYMEndpoint: Record "IDYM Endpoint";
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IDYPSetup: Record "IDYP Setup";
        IDYSIProvider: Interface "IDYS IProvider";
        AppInfo: ModuleInfo;
        UserName: Text[150];
        Secret: Text;
        ItemWeight: Text;
        ItemWeightStyle: Text;
        DemoMode: Boolean;
        ApplyShippingRulesEnabled: Boolean;
        EncryptionIsNotActivatedQst: Label 'Data encryption is currently not enabled. We recommend that you encrypt sensitive data. \Do you want to open the Data Encryption Management window?';
        IsSendCloudEnabled: Boolean;
}