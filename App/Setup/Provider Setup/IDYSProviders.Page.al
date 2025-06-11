page 11147722 "IDYS Providers"
{
    PageType = List;
    SourceTable = "IDYS Provider Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'ShipIT Providers';
    UsageCategory = Administration;
    ContextSensitiveHelpPage = '21921802';
    ApplicationArea = All;
    SourceTableView = where(Hidden = const(false));

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the provider.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if provider is enabled.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;

                action("Setup Card")
                {
                    Caption = 'Setup Card';
                    ToolTip = 'Opens the provider setup card.';
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    Image = Setup;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        IDYSIProvider := Rec.Provider;
                        Page.Run(IDYSIProvider.SetupPage());
                    end;
                }

                action("Carriers")
                {
                    RunObject = page "IDYS Provider Carriers";
                    RunPageLink = Provider = field(Provider);
                    ApplicationArea = All;
                    Caption = 'Carriers';
                    Image = Inventory;
                    ToolTip = 'Opens the carriers list page.';
                    Enabled = IsProviderEnabled;
                }

                action("User Setup")
                {
                    ApplicationArea = All;
                    Caption = 'User Setup';
                    Image = CalculateShipment;
                    ToolTip = 'Opens the user setup page.';
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    Enabled = IsProviderEnabled;
                    Visible = UserSetupVisible;

                    trigger OnAction()
                    begin
                        IDYSProviderMgt.RunUserSetupPage(Rec.Provider);
                    end;
                }
                action("Package Types")
                {
                    ApplicationArea = All;
                    Caption = 'Package Types';
                    Image = Inventory;
                    ToolTip = 'Opens the package types list page.';
                    Visible = PackageTypeVisible;
                    Enabled = IsProviderEnabled;

                    trigger OnAction()
                    var
                        IDYSProviderPackageType: Record "IDYS Provider Package Type";
                        IDYSProviderPackageTypes: Page "IDYS Provider Package Types";
                    begin
                        IDYSProviderPackageType.SetRange(Provider, Rec.Provider);
                        IDYSProviderPackageTypes.Editable(false);
                        IDYSProviderPackageTypes.SetTableView(IDYSProviderPackageType);
                        IDYSProviderPackageTypes.Run();
                    end;
                }
                action("BookingProf Package Types")
                {
                    ApplicationArea = All;
                    Caption = 'Package Types';
                    Image = Inventory;
                    ToolTip = 'Opens the package types list page.';
                    Visible = BookingProfPackageTypeVisible;
                    Enabled = IsProviderEnabled;

                    trigger OnAction()
                    var
                        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
                        IDYSBookingProfPackageTypes: Page "IDYS BookingProf Package Types";
                    begin
                        IDYSBookingProfPackageType.SetRange(Provider, Rec.Provider);
                        IDYSBookingProfPackageTypes.Editable(false);
                        IDYSBookingProfPackageTypes.SetTableView(IDYSBookingProfPackageType);
                        IDYSBookingProfPackageTypes.Run();
                    end;
                }
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
                Enabled = IsProviderEnabled;

                trigger OnAction();
                var
                    IDYSCreateMappings: Codeunit "IDYS Create Mappings";
                begin
                    Rec.TestField(Enabled);
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
                actionref("Setup Card_Promoted"; "Setup Card")
                {
                }
                actionref("User Setup_Promoted"; "User Setup")
                {
                }
            }
        }
#endif
    }

    trigger OnOpenPage()
    begin
        PopulateData();
    end;

    trigger OnAfterGetRecord()
    begin
        IsProviderEnabled := Rec.Enabled;
        UserSetupVisible := Rec.Provider in [Rec.Provider::Transsmart, Rec.Provider::"Delivery Hub"];
        PackageTypeVisible := Rec.Provider in [Rec.Provider::Transsmart, Rec.Provider::Sendcloud, Rec.Provider::Cargoson];
        BookingProfPackageTypeVisible := Rec.Provider in [Rec.Provider::"Delivery Hub", Rec.Provider::EasyPost];
    end;

    local procedure PopulateData()
    var
        IDYSProviderSetup: Record "IDYS Provider Setup";
        ProviderValue: Enum "IDYS Provider";
        Providers: List of [Integer];
        i: Integer;
    begin
        Providers := "IDYS Provider".Ordinals();
        foreach i in Providers do begin
            ProviderValue := "IDYS Provider".FromInteger(i);
            if not IDYSProviderSetup.Get(ProviderValue) then begin
                IDYSProviderSetup.Provider := ProviderValue;
                IDYSProviderSetup.Hidden := IDYSProviderSetup.Provider in [IDYSProviderSetup.Provider::Default, IDYSProviderSetup.Provider::Cargoson];
                IDYSProviderSetup.Insert();
            end;
        end;
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSIProvider: Interface "IDYS IProvider";
        UserSetupVisible: Boolean;
        PackageTypeVisible: Boolean;
        BookingProfPackageTypeVisible: Boolean;
        IsProviderEnabled: Boolean;
}