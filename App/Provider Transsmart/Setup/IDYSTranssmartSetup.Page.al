page 11147721 "IDYS Transsmart Setup"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "IDYS Setup";
    SourceTableView = where(Provider = const(Transsmart));
    InsertAllowed = false;
    ContextSensitiveHelpPage = '22282322';
    Caption = 'nShift Transsmart Setup';

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
                    Visible = not DemoMode;
                }
                field(TranssmartAccountMasked; Rec."Transsmart Account Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Your nShift Transsmart account code.';
                    Visible = DemoMode;
                    ExtendedDatatype = Masked;
                }
                field("Transsmart Environment"; Rec."Transsmart Environment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies is the setup is acceptance or production.';
                    Editable = not DemoMode;
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
                        IsTranssmartEnabled := IDYSProviderSetup.Enabled;
                    end;
                }
                field(Enabled; IDYSProviderSetup.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if provider is enabled.';
                    Editable = not DemoMode;

                    trigger OnValidate()
                    begin
                        if IDYSProviderSetup.Enabled then begin
                            Rec.TestField("Transsmart Account Code");
                            IDYSUserSetup.TestField("User Name (External)");
                            IDYSUserSetup.TestField("Password (External)");
                        end;
                        IDYSProviderSetup.Validate(Enabled);
                        IDYSProviderSetup.Modify();
                        IsTranssmartEnabled := IDYSProviderSetup.Enabled;
                    end;
                }
            }
            group(Defaults)
            {
                Caption = 'Defaults';
                field("Default Package Type"; Rec."Default Provider Package Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default package type.';
                }
                field("Default E-Mail Type"; Rec."Default E-Mail Type")
                {
                    ToolTip = 'Indicates which e-mail type will be used from the carrier to the receiver of the packages.';
                    ApplicationArea = All;
                }
                field("Default Cost Center"; Rec."Default Cost Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default cost center.';
                }
                group(Insurance)
                {
                    Visible = InsuranceEnabled;
                    Caption = 'Insurance';
                    field("Enable Insurance"; Rec."Enable Insurance")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if the insurance is enabled.';
                    }
                    field("Enable Min. Shipment Amount"; Rec."Enable Min. Shipment Amount")
                    {
#if BC17
#pragma warning disable AL0604
                        Enabled = "Enable Insurance";
#pragma warning restore AL0604
#else
                        Enabled = Rec."Enable Insurance";
#endif                         
                        ApplicationArea = All;
                        ToolTip = 'Specifies if the insurance is applied if it meets the minimum shipment amount requirement.';
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
            action(ShipmentMethodMappings)
            {
                RunObject = page "IDYS Shipment Method Mappings";
                ApplicationArea = All;
                Caption = 'Shipment Method Mappings';
                Image = CalculateShipment;
                ToolTip = 'Opens the shipping method mappings list page.';
                Enabled = IsTranssmartEnabled;
            }
            action("Incoterms")
            {
                RunObject = page "IDYS Incoterms";
                ApplicationArea = All;
                Caption = 'Incoterms';
                Image = Inventory;
                ToolTip = 'Opens the incoterms list page.';
                Enabled = IsTranssmartEnabled;
            }
            action("Cost Centers")
            {
                RunObject = page "IDYS Cost Centers";
                ApplicationArea = All;
                Caption = 'Cost Centers';
                Image = Inventory;
                ToolTip = 'Opens the cost center list page.';
                Enabled = IsTranssmartEnabled;
            }
            action("E-Mail Types")
            {
                RunObject = page "IDYS E-Mail Types";
                ApplicationArea = All;
                Caption = 'E-Mail Types';
                Image = Email;
                ToolTip = 'Opens the e-mail types list page.';
                Enabled = IsTranssmartEnabled;
            }
            action("Carriers")
            {
                RunObject = page "IDYS Provider Carriers";
                RunPageLink = Provider = field(Provider);
                ApplicationArea = All;
                Caption = 'Carriers';
                Image = Inventory;
                ToolTip = 'Opens the carriers list page.';
                Enabled = IsTranssmartEnabled;
            }
            action("User Setup")
            {
                ApplicationArea = All;
                Caption = 'User Setup';
                Image = CalculateShipment;
                ToolTip = 'Opens the user setup page.';
                RunObject = Page "IDYS User Setup";
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
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
                Enabled = IsTranssmartEnabled;

                trigger OnAction()
                var
                    IDYSProviderPackageType: Record "IDYS Provider Package Type";
                    IDYSProviderPackageTypes: Page "IDYS Provider Package Types";
                begin
                    IDYSProviderPackageType.SetRange(Provider, IDYSProviderPackageType.Provider::Transsmart);
                    IDYSProviderPackageTypes.Editable(false);
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
                Enabled = IsTranssmartEnabled;

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
        Rec.GetProviderSetup("IDYS Provider"::Transsmart);
        IDYSProviderSetup.Get("IDYS Provider"::Transsmart);
        if Setup.Get() then begin
            DemoMode := Setup."Demo Mode";
            InsuranceEnabled := Setup."Insurance Enabled";
        end;
        if not IDYSUserSetup.Get(UserId()) then begin
            IDYSUserSetup.SetRange(Default, True);
            if not IDYSUserSetup.FindFirst() then begin
                IDYSUserSetup.Init();
                IDYSUserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(IDYSUserSetup."User ID"));
            end;
        end;
        IsTranssmartEnabled := IDYSProviderSetup.Enabled;
    end;

    var
        IDYSUserSetup: Record "IDYS User Setup";
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IDYSIProvider: Interface "IDYS IProvider";
        IsTranssmartEnabled: Boolean;
        InsuranceEnabled: Boolean;
        DemoMode: Boolean;
}