page 11147709 "IDYS Sendcloud Wizard Setup"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = Integer;
    SourceTableView = where(Number = const(1));
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Sendcloud Setup';
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by Sendcloud Setup page';
    ObsoleteTag = '18.8';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                group("Sendcloud Credentials")
                {
                    Caption = 'Sendcloud Credentials';
                    field("Public Key"; UserName)
                    {
                        Caption = 'Public Key';
                        ToolTip = 'Your Sendcloud integration secret.';
                        ApplicationArea = All;
                        ShowMandatory = true;

                        trigger OnValidate()
                        var
                            EndpointManagement: Codeunit "IDYM Endpoint Management";
                        begin
                            Clear(Secret);
                            EndpointManagement.ClearCredentials("IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);
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

                            EndPointManagement.RegisterCredentials("IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default, AppInfo.Id(), "IDYM Authorization Type"::Basic, UserName, Secret);
                        end;
                    }
                }

                group("Label")
                {
                    Caption = 'Shipping Label';
                    field("Request Label"; IDYSSendcloudSetup."Request Label")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the default setting for if a label should be created for the parcel directly when sending it to the Sendcloud portal.';

                        trigger OnValidate()
                        begin
                            IDYSSendcloudSetup.Modify();
                            CurrPage.Update();
                        end;
                    }
                    field("Apply Shipping Rules"; IDYSSendcloudSetup."Apply Shipping Rules")
                    {
                        Enabled = ApplyShippingRulesEnabled;
                        ApplicationArea = All;
                        ToolTip = 'Specifies if shipping rules should be applied when requesting a label or announcing a shipment in the sendcloud portal. Shipping rules can be used for specific branding (eg look and feel, trademarks, logo’s etc). Label''s must be requested to be able to use shipping rules.';

                        trigger OnValidate()
                        begin
                            IDYSSendcloudSetup.Modify();
                        end;
                    }
                    field("Label Type"; IDYSSendcloudSetup."Label Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies which label type should be saved to the database as .pdf file.';

                        trigger OnValidate()
                        begin
                            IDYSSendcloudSetup.Modify();
                        end;
                    }
                    field("Apply External Document No."; IDYSSendcloudSetup."Apply External Document No.")
                    {
                        Caption = 'Apply Ext. Doc. No. as order reference.';
                        ApplicationArea = All;
                        ToolTip = 'Indicates that the External Document No. will be sent to Sendcloud as the order reference for the labels and shipments.';

                        trigger OnValidate()
                        begin
                            IDYSSendcloudSetup.Modify();
                        end;
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

                    field("Weight to KG Conversion Factor"; IDYSSendcloudSetup."Weight to KG Conversion Factor")
                    {
                        Caption = 'Weight to KG Conversion Factor';
                        ApplicationArea = ALl;
                        ToolTip = 'Specifies the conversion factor to convert weights as they are registered on items and documents to Kilograms. The conversion is only relevant when the weights are not registered in kilograms. Sendcloud uses weights in kg''s, and therefore the weight conversion is required. To convert grams to kgs use a conversion factor of 0.001 and to convert lbs to kgs use a conversion factor of 0.45359237';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with Conversion factors';
                        ObsoleteTag = '21.0';

                        trigger OnValidate()
                        begin
                            IDYSSendcloudSetup.Modify();
                        end;
                    }
                }

                field("Default Package Type"; IDYSSendcloudSetup."Default Provider Package Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default package type';

                    trigger OnValidate()
                    begin
                        IDYSSendcloudSetup.Modify();
                    end;
                }
            }
        }
    }

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
        ApplyShippingRulesEnabled := IDYSSendcloudSetup."Request Label";
    end;

    trigger OnOpenPage()
    begin
        IDYSSendcloudSetup.GetProviderSetup("IDYS Provider"::Sendcloud);
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
        IDYSSendcloudSetup: Record "IDYS Setup";
        IDYMEndpoint: Record "IDYM Endpoint";
        AppInfo: ModuleInfo;
        UserName: Text[150];
        Secret: Text;
        ItemWeight: Text;
        ItemWeightStyle: Text;
        ApplyShippingRulesEnabled: Boolean;
        EncryptionIsNotActivatedQst: Label 'Data encryption is currently not enabled. We recommend that you encrypt sensitive data. \Do you want to open the Data Encryption Management window?';
}