page 11147701 "IDYS Select Providers"
{
    PageType = ListPart;
    SourceTable = "IDYS Provider Setup";
    Editable = false;
    Caption = ' ';
    UsageCategory = None;
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
                    ToolTip = 'Specifies the provider.';
                    trigger OnDrillDown()
                    begin
                        IDYSIProvider := Rec.Provider;
                        Page.RunModal(IDYSIProvider.SetupPage());
                    end;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if provider is enabled.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Line)
            {
                Caption = 'Line';
                action("Setup Card")
                {
                    Caption = 'Setup Card';
                    ToolTip = 'Opens the provider setup card.';
                    Image = Setup;
                    ApplicationArea = All;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        IDYSIProvider := Rec.Provider;
                        Page.RunModal(IDYSIProvider.SetupPage());
                    end;
                }

                action("Update Master Data")
                {
                    Caption = 'Update Master Data';
                    ToolTip = 'Retrieves all configured master data from the selected API.';
                    Image = Refresh;
                    ApplicationArea = All;
                    Scope = Repeater;

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
        }
    }

    trigger OnOpenPage()
    begin
        PopulateData();
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
                IDYSProviderSetup.Insert();
            end;
        end;
    end;

    var
        IDYSIProvider: Interface "IDYS IProvider";
}