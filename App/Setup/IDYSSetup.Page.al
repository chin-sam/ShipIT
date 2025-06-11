page 11147639 "IDYS Setup"
{
    Caption = 'ShipIT Setup';
    UsageCategory = Lists;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "IDYS Setup";
    ContextSensitiveHelpPage = '23167043';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Base Transport Orders on"; Rec."Base Transport Orders on")
                {
                    ToolTip = 'Identifies the type of documents (posted or unposted) that form the basis for your transport orders.';
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                Group(AfterPosting)
                {
                    Caption = 'After Posting Settings';
                    ShowCaption = false;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with action in AfterPostingBeta group';
                    ObsoleteTag = '25.0';

                    field("After Posting Sales Orders"; Rec."After Posting Sales Orders")
                    {
                        ApplicationArea = All;
                        Editable = AutoCreateEnabled;
                        ToolTip = 'Specifies what happens after posting the sales order.';
                        OptionCaption = 'Do nothing,Auto-Create Transport Order(s)';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with action in AfterPostingBeta group';
                        ObsoleteTag = '25.0';
                    }
                    field("After Post Sales Return Orders"; Rec."After Post Sales Return Orders")
                    {
                        ApplicationArea = All;
                        Editable = AutoCreateEnabled;
                        ToolTip = 'Specifies what happens after posting the sales return order.';
                        OptionCaption = 'Do nothing,Auto-Create Transport Order(s)';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Removed due to wrongfully implemented flow';
                        ObsoleteTag = '21.0';
                        Visible = false;
                    }
                    field("After Posting Purch. Ret. Ord."; Rec."After Posting Purch. Ret. Ord.")
                    {
                        ApplicationArea = All;
                        Editable = AutoCreateEnabled;
                        ToolTip = 'Specifies what happens after posting the purchase return order.';
                        OptionCaption = 'Do nothing,Auto-Create Transport Order(s)';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with action in AfterPostingBeta group';
                        ObsoleteTag = '25.0';
                        Visible = false;
                    }
                    field("After Posting Service Orders"; Rec."After Posting Service Orders")
                    {
                        ApplicationArea = Service;
                        Editable = AutoCreateEnabled;
                        ToolTip = 'Specifies what happens after posting the service order.';
                        OptionCaption = 'Do nothing,Auto-Create Transport Order(s)';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with action in AfterPostingBeta group';
                        ObsoleteTag = '25.0';
                        Visible = false;
                    }
                    field("After Posting Transfer Orders"; Rec."After Posting Transfer Orders")
                    {
                        ApplicationArea = Location;
                        Editable = AutoCreateEnabled;
                        ToolTip = 'Specifies what happens after posting the transfer order.';
                        OptionCaption = 'Do nothing,Auto-Create Transport Order(s)';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with action in AfterPostingBeta group';
                        ObsoleteTag = '25.0';
                        Visible = false;
                    }
                }
                group(AfterPostingBeta)
                {
                    Caption = 'After Posting Settings';
                    ShowCaption = false;
                    field("After Posting Sales Orders Beta"; Rec."After Posting Sales Orders")
                    {
                        ApplicationArea = All;
                        Editable = AutoCreateEnabled;
                        ToolTip = 'Specifies what happens after posting the sales order. Beta features are included in the available options.';
                    }
                    field("After Post Sales Return Orders Beta"; Rec."After Post Sales Return Orders")
                    {
                        ApplicationArea = All;
                        Editable = AutoCreateEnabled;
                        ToolTip = 'Specifies what happens after posting the sales return order. Beta features are included in the available options.';
                        StyleExpr = AutoCreateEnabled;
                        Style = Attention;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Removed due to wrongfully implemented flow';
                        ObsoleteTag = '21.0';
                        Visible = false;
                    }
                    field("After Posting Purch. Ret. Ord. Beta"; Rec."After Posting Purch. Ret. Ord.")
                    {
                        ApplicationArea = All;
                        Editable = AutoCreateEnabled;
                        ToolTip = 'Specifies what happens after posting the purchase return order. Beta features are included in the available options.';
                    }
                    field("After Posting Service Orders Beta"; Rec."After Posting Service Orders")
                    {
                        ApplicationArea = Service;
                        Editable = AutoCreateEnabled;
                        ToolTip = 'Specifies what happens after posting the service order. Beta features are included in the available options.';
                    }
                    field("After Posting Transfer Orders Beta"; Rec."After Posting Transfer Orders")
                    {
                        ApplicationArea = Location;
                        Editable = AutoCreateEnabled;
                        ToolTip = 'Specifies what happens after posting the transfer order. Beta features are included in the available options.';
                    }
                }
                field("Base Preferred Date on"; Rec."Base Preferred Date on")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies how the Preferred Shipment Date will be determined on a Transport Order. Either the planned shipment date is used or the posting date of the source document. For Sales Return Orders or Sales Return Receipts this setting is ignored and the shipment date is always applied, because the posting of these documents occurs after transportation.';
                }
                field("Always New Trns. Order"; Rec."Always New Trns. Order")
                {
                    ToolTip = 'If enabled, documents will never be combined into the same transport order but will be linked to a new transport order separately.';
                    ApplicationArea = All;
                }
                field("No TO Created Notification"; Rec."No TO Created Notification")
                {
                    ToolTip = 'If enabled, the system will not give a confirmation or notification to open the created or updated transport order(s).';
                    ApplicationArea = All;
                }
                field("Address for Invoice Address"; Rec."Address for Invoice Address")
                {
                    ToolTip = 'Indicates which customer address will be used for the invoice address block on a transport order.';
                    ApplicationArea = All;
                }
                field("Background Booking"; Rec."Background Booking")
                {
                    ToolTip = 'If enabled, transport orders will be booked and printed through the task scheduler. This can be useful for limited license users.';
                    ApplicationArea = All;
                }
                field("Skip Source Docs Upd after TO"; Rec."Skip Source Docs Upd after TO")
                {
                    Tooltip = 'Skip updating Source Documents after booking a Transport Order. The Source Documents will only be updated when synchronizing a transport order.';
                    ApplicationArea = All;
                }
                field("Auto. Add One Default Package"; Rec."Auto. Add One Default Package")
                {
                    ToolTip = 'If enabled, one default package will be added to every transport order.';
                    ApplicationArea = All;
                }
                field("Skip Source Doc. Packages"; Rec."Skip Source Doc. Packages")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates that packages registered on sales documents should not be copied to the transport orders.';
                }
                field("Add Delivery Notes"; Rec."Add Delivery Notes")
                {
                    ToolTip = 'If enabled, the application will automatically add delivery notes for source lines.';
                    ApplicationArea = All;
                }
                field("Link Del. Lines with Packages"; Rec."Link Del. Lines with Packages")
                {
                    ToolTip = 'If enabled, the application will automatically link delivery lines with packages to determine the package content. This functionality can only be activated when your license allows it.';
                    ApplicationArea = All;
#if BC17
#pragma warning disable AL0604
                    Enabled = "Allow Link Del. Lines with Pck";
#pragma warning restore AL0604
#else
                    Enabled = Rec."Allow Link Del. Lines with Pck";
#endif                    

                    trigger OnValidate()
                    var
                        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
                    begin
                        Rec.Modify();
                        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
                        CurrPage.Update();
                    end;
                }
                field("Allow All Item Types"; Rec."Allow All Item Types")
                {
                    ToolTip = 'If enabled, the application will allow adding all items types to transport orders.';
                    ApplicationArea = All;
                }
                field("Copy Ship. Agent to Whse-Docs"; Rec."Copy Ship. Agent to Whse-Docs")
                {
                    ToolTip = 'If enabled, the application will populate the Shipping Agent Code, the Shipping Agent Service Code and the Shipment Method Code on the warehouse shipment when the values are the same for all source documents..';
                    ApplicationArea = All;
                }
                field("Map Service Provider"; Rec."Map Service Provider")
                {
                    ToolTip = 'Specifies the map service that is going to be used for route display.';
                    ApplicationArea = All;
                }
                field("Bing API Key"; Rec."Bing API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'If specified, the application will show the map factbox on the Transport Order page.';

                    trigger OnAssistEdit()
                    var
                        HelpBingUrlLbl: Label 'https://docs.microsoft.com/en-us/bingmaps/getting-started/bing-maps-dev-center-help/creating-a-bing-maps-account', Locked = true;
                        HelpAzureMapsUrlLbl: Label 'https://learn.microsoft.com/en-us/azure/azure-maps/quick-demo-map-app#create-an-azure-maps-account', Locked = true;
                    begin
                        case Rec."Map Service Provider" of
                            Rec."Map Service Provider"::"Bing Maps":
                                System.Hyperlink(HelpBingUrlLbl);
                            Rec."Map Service Provider"::"Azure Maps":
                                System.Hyperlink(HelpAzureMapsUrlLbl);
                        end;
                    end;
                }
                field("Enable Beta features"; Rec."Enable Beta features")
                {
                    ApplicationArea = All;
                    ToolTip = 'When enabled, the application will show additional features that are part of the ShipIT Beta program. Beta features are pre-released features that in it''s current shape have limitations in the supported usage scenarios or they are new features that have not been fully tested. Because of the nature of Beta features, we give limited support on them. Support tickets may be raised with suggestions and general feedback, but issues will only be solved in newer versions of the product and not on a per customer basis.';

                    trigger OnValidate()
                    var
                        EnableBetaFeaturesQst: Label 'Are you sure you want to enable Beta features? Beta features are pre-released features that in it''s current shape have limitations in the supported usage scenarios or they are new features that have not been fully tested. Because of the nature of Beta features, we give limited support on them. Support tickets may be raised with suggestions and general feedback, but issues will only be solved in newer versions of the product and not on a per customer basis.';
                    begin
                        if Rec."Enable Beta features" then
                            if not Confirm(EnableBetaFeaturesQst, false) then
                                error('');

                        CurrPage.Update();
                    end;
                }
                group("Transsmart Account")
                {
                    Caption = 'nShift Transsmart Account';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Restructured with Provider level';
                    ObsoleteTag = '19.7';
                    Visible = false;

                    field("Transsmart Environment"; Rec."Transsmart Environment")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the nShift transsmart environment.';
                    }
                    field("Transsmart Account Code"; Rec."Transsmart Account Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the nShift transsmart account code.';
                    }
                }
            }

            group(LicenseKey)
            {
                Caption = 'License Key';
                InstructionalText = 'Please provide your license key to be able to start using ShipIT. If you have just installed ShipIT through Microsoft AppSource, please check your e-mail for a trial key. No license or trial key? Please contact your implementation partner. No partner? Contact sales@idyn.nl';

                group(LicenseFields)
                {
                    ShowCaption = false;
                    field(LicenseKeyMasked; LicenseKey)
                    {
                        ApplicationArea = All;
                        Caption = 'License Key';
                        ToolTip = 'Specifies the license key.';
                        ExtendedDatatype = Masked;
                        Visible = DemoMode;

                        trigger OnValidate()
                        begin
                            LicenseCheck.OnValidateLicenseKey(Rec, LicenseKeyStatus, LicenseKeyStatusStyle, LicenseKey);
                            CurrPage.Update();
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
                            LicenseCheck.OnValidateLicenseKey(Rec, LicenseKeyStatus, LicenseKeyStatusStyle, LicenseKey);
                            CurrPage.Update();
                        end;
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
            group(Defaults)
            {
                Caption = 'Default settings';
                field("Pick-up Time From"; Rec."Pick-up Time From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies from what time pick-up can take place.';
                }
                field("Pick-up Time To"; Rec."Pick-up Time To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies till what time pick-up can take place.';
                }
                field("Delivery Time From"; Rec."Delivery Time From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies from what time delivery can take place.';
                }
                field("Delivery Time To"; Rec."Delivery Time To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies till what time delivery can take place.';
                }

                field("default Ship-to Country"; Rec."default Ship-to Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default ship-to country/region code.';
                }
                field("Default E-Mail Type"; Rec."Default E-Mail Type")
                {
                    ToolTip = 'Indicates which e-mail type will be used from the carrier to the receiver of the packages.';
                    ApplicationArea = All;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Restructured with Provider level';
                    ObsoleteTag = '19.7';
                    Visible = false;
                }
                field("Default Cost Center"; Rec."Default Cost Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default cost center.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Restructured with Provider level';
                    ObsoleteTag = '19.7';
                    Visible = false;
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
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Restructured with Provider level';
                    ObsoleteTag = '19.7';
                }
            }
            group("Shipping Costs")
            {
                Caption = 'Shipping Costs';
                field("Add Freight Line"; Rec."Add Freight Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a new sales line containing shipping costs should be added automatically after selecting a carrier.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with Cust. Inv. Discount';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }

                field("Shipping Cost Surcharge (%)"; Rec."Shipping Cost Surcharge (%)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a surcharge to the shipping cost is added and if so, what percentage.';
                }
            }
            group(Logging)
            {
                Caption = 'Logging';
                field("Enable Debug Mode"; Rec."Enable Debug Mode")
                {
                    ToolTip = 'If enabled, the application will log debug messages to a log entry table. These log entries contain the JSON request and response.';
                    ApplicationArea = All;
                }
                field("Logging Level"; Rec."Logging Level")
                {
                    ToolTip = 'Indicates which type of messages will be logged.';
                    ApplicationArea = All;
                }
                field("Demo Mode"; Rec."Demo Mode")
                {
                    ToolTip = 'When enabled some settings are locked and the license key is masked.';
                    ApplicationArea = All;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        DemoMode := Rec."Demo Mode";
                    end;
                }
            }
            group(Archive)
            {
                Caption = 'Archive';
                field("Retention Period (Days)"; Rec."Retention Period (Days)")
                {
                    ToolTip = 'Specifies the retention period of archived, completed and recalled transport orders.';
                    ApplicationArea = All;
                }
                field("Remove Attachments on Arch."; Rec."Remove Attachments on Arch.")
                {
                    ToolTip = 'Specifies if the attachments are removed when archiving.';
                    ApplicationArea = All;
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Transport Order Nos."; Rec."Transport Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transport order number series that will be used.';
                }
            }
        }
        area(FactBoxes)
        {
            part("IDYS Video Factbox"; "IDYS Collateral Factbox")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(External)
            {
                Caption = 'nShift Transsmart';
                ObsoleteState = Pending;
                ObsoleteReason = 'Moved actions outside this group';
                ObsoleteTag = '18.8';
            }
            action("Update Master Data")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Restructured with Provider level';
                ObsoleteTag = '19.7';
                Visible = false;
                Caption = 'Update Master Data';
                ToolTip = 'Retrieves all configured nShift Transsmart data from the nShift Transsmart API.';
                Image = Refresh;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ApplicationArea = All;

                trigger OnAction();
                var
                    IDYSTranssmartMDataMgt: Codeunit "IDYS Transsmart M. Data Mgt.";
                    IDYSCreateMappings: Codeunit "IDYS Create Mappings";
                begin
                    IDYSTranssmartMDataMgt.UpdateMasterData(true);
                    Rec.TestField("Default Ship-to Country");
                    IDYSCreateMappings.CreateMappings();
                end;
            }

            action("Verify Setup")
            {
                Caption = 'Verify Setup';
                ToolTip = 'Shows a list of things that need to be configured before using the app.';
                Image = CreateInventoryPickup;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ApplicationArea = All;
                RunObject = Codeunit "IDYS Verify Setup";
            }

            action("Update Combinability IDs")
            {
                Caption = 'Update Combinability ID''s';
                ToolTip = 'Updates the combinability ids on all transport orders and transport order worksheet lines.';
                Image = Refresh;
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif

                trigger OnAction();
                var
                    IDYSCombinabilityMgt: Codeunit "IDYS Combinability Mgt.";
                    IDYSNotificationManagement: Codeunit "IDYS Notification Management";
                    CombinabilityIDsUpdateTok: Label '661702a7-6cc4-483f-8911-3a568cc2562f', Locked = true;
                    CombinabilityIDsUpdatedMsg: Label 'Combinability ID''s were updated.';
                begin
                    // need to consider provider at this level
                    IDYSCombinabilityMgt.UpdateCombinabilityID();
                    IDYSNotificationManagement.SendNotification(CombinabilityIDsUpdateTok, CombinabilityIDsUpdatedMsg);
                end;
            }

            action("Transport Order Cleanup")
            {
                Caption = 'Transport Order Cleanup';
                ToolTip = 'Runs the transport order cleanup.';
                Image = DeleteRow;
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif

                trigger OnAction();
                var
                    TransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
                begin
                    TransportOrderMgt.Cleanup();
                end;
            }
            group(Upgrade)
            {
                Caption = 'Upgrade';
                action("Data Upgrade")
                {
                    Caption = 'Data Upgrade';
                    ApplicationArea = All;
                    Image = Versions;
                    ToolTip = 'Runs the ShipIT 365 data upgrade.';

                    trigger OnAction()
                    var
                        Upgrade: Codeunit "IDYS Upgrade Functions";
                    begin
                        Upgrade.Run();
                    end;
                }
            }
        }
        area(Navigation)
        {
            action(Providers)
            {
                Caption = 'Providers';
                ApplicationArea = All;
                Image = TransferOrder;
                ToolTip = 'Opens the list of providers that can be used for the communication with the carriers.';
                RunObject = Page "IDYS Providers";
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
            }
            action("Data Version")
            {
                Caption = 'Data Version';
                ApplicationArea = All;
                Image = ShowChart;
                ToolTip = 'Shows the current ShipIT 365 data version.';

                trigger OnAction()
                var
                    ModInfo: ModuleInfo;
                    CurrentDataVersionMsg: Label 'Current ShipIT 365 data version: %1', Comment = '%1=The data version';
                begin
                    if NavApp.GetCurrentModuleInfo(ModInfo) then
                        Message(StrSubstNo(CurrentDataVersionMsg, ModInfo.DataVersion));
                end;
            }

        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Verify Setup_Promoted"; "Verify Setup")
                {
                }
                actionref("Update Combinability IDs_Promoted"; "Update Combinability IDs")
                {
                }
                actionref("Transport Order Cleanup_Promoted"; "Transport Order Cleanup")
                {
                }
                actionref(Providers_Promoted; Providers)
                {
                }
            }
        }
#endif
    }

    trigger OnOpenPage();
    var
        IDYMAppLicenseKey: Record "IDYM App License Key";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        CloudInstall: Boolean;
        ErrorMessage: Text;
        ErrorCode: Integer;
    begin
        if not Rec.Get('') then begin
            Rec.InitSetup();
            Rec.Insert(true);
        end;

        CloudInstall := EnvironmentInformation.IsSaaS() and (AzureADTenant.GetAadTenantId() <> '');
        if CloudInstall then
            IDYMAppHub.RegisterTenant(ErrorMessage, ErrorCode);
        NavApp.GetCurrentModuleInfo(AppInfo);
        if Rec."License Entry No." <> 0 then begin
            IDYMAppLicenseKey.Get(Rec."License Entry No.");
            LicenseKey := IDYMAppLicenseKey."License Key";
            LicenseCheck.GetLicenseStatus(Rec."License Entry No.", LicenseKeyStatus, LicenseKeyStatusStyle);
        end;
        DemoMode := Rec."Demo Mode";
        IDYMAppHub.NewAppVersionNotification(AppInfo.Id, false);
        NotificationManagement.SendInstructionNotification();
        AutoCreateEnabled := true;
    end;

    var
        IDYMAppHub: Codeunit "IDYM Apphub";
        LicenseCheck: Codeunit "IDYS License Check";
        NotificationManagement: Codeunit "IDYS Notification Management";
        AppInfo: ModuleInfo;
        AutoCreateEnabled: Boolean;
        DemoMode: Boolean;
        LicenseKey: Text[50];
        LicenseKeyStatus: Text;
        LicenseKeyStatusStyle: Text;
}