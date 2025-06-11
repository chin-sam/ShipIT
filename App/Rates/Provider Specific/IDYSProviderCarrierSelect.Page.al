page 11147700 "IDYS Provider Carrier Select"
{
    Caption = 'Carrier Select';
    Editable = false;
    PageType = List;
    SourceTable = "IDYS Provider Carrier Select";
    UsageCategory = None;
    ContextSensitiveHelpPage = '23199761';
    SourceTableView = sorting("Price as Decimal");

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                FreezeColumn = Price;
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider.';
                }
                field(Price; Rec."Price as Decimal")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price.';
                    Visible = (ViewMode = ViewMode::Default);
                }
                field("Carrier Name"; Rec."Carrier Name")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                    Visible = false;
                }
                field("Calculated Carrier Name"; Rec."Calculated Carrier Name")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                }
                field("Shipping Agent Service Desc."; Rec."Shipping Agent Service Desc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the shipping agent service.';
                    Visible = (ViewMode = ViewMode::MultipleBookingProfiles);
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the carrier.';
                    Visible = (ViewMode = ViewMode::Default);
                }
                field("Pickup Date"; Rec."Pickup Date")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the pickup date.';
                    Visible = (ViewMode = ViewMode::Default);
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delivery date.';
                    Visible = (ViewMode = ViewMode::Default);
                }
                field("Delivery Time"; Rec."Delivery Time")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delivery time.';
                    Visible = (ViewMode = ViewMode::Default) and (not IsCargoson);
                }
                field(Insure; Rec.Insure)
                {
                    Caption = 'Insured';
                    ApplicationArea = All;
                    Visible = IsTranssmart and IsInsuranceEnabled;
                    ToolTip = 'Specifies if insurance is applied.';
                    Editable = false;
                    StyleExpr = RowStyleExpr;
                }
                field("Insurance Amount"; Rec."Insurance Amount")
                {
                    ApplicationArea = All;
                    Visible = IsTranssmart and IsInsuranceEnabled;
                    ToolTip = 'Specifies the insurance amount.';
                    Editable = false;
                    StyleExpr = RowStyleExpr;
                }
                field("Service Level Code (Time)"; Rec."Service Level Code (Time)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service level code (time).';
                    Visible = (ViewMode = ViewMode::Default) and (not IsDeliveryHub) and (not IsCargoson);
                }
                field("Service Level Code (Other)"; Rec."Service Level Code (Other)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service level code (other).';
                    Visible = (ViewMode = ViewMode::Default) and (not IsDeliveryHub) and (not IsCargoson);
                }
                field(Mapped; Rec.Mapped)
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies if everything needed for this record is mapped.';
                    Visible = (ViewMode = ViewMode::Default);
                }
                field("Transit Time (Hours)"; Rec."Transit Time (Hours)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transit time in hours.';
                    Visible = (ViewMode = ViewMode::Default) and (not IsDeliveryHub) and (not IsCargoson);
                }
                field("Transit Time Description"; Rec."Transit Time Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the transit time.';
                    Visible = (ViewMode = ViewMode::Default) and (not IsDeliveryHub) and (not IsCargoson);
                }
                field("Calculated Weight"; Rec."Calculated Weight")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated weight.';
                }
                field("Calculated Weight UOM"; Rec."Calculated Weight UOM")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated weight UOM.';
                }
                field("Insurance Company"; Rec."Insurance Company")
                {
                    ApplicationArea = All;
                    Visible = IsTranssmart and IsInsuranceEnabled;
                    ToolTip = 'Specifies the insurance company.';
                    Editable = false;
                    StyleExpr = RowStyleExpr;
                }
                field("Insurance Charges"; Rec."Insurance Charges")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the insurance charges.';
                    Visible = IsTranssmart and IsInsuranceEnabled;
                    Caption = 'Insurance Charges';

                    trigger OnDrillDown()
                    var
                        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
                        IDYSTranssmartInsCharges: Page "IDYS Transsmart Ins. Charges";
                    begin
                        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", Rec."Transport Order No.");
                        IDYSProvCarrierSelectPck.SetRange("Transsmart Insurance", true);
                        if not IDYSProvCarrierSelectPck.IsEmpty() then begin
                            IDYSTranssmartInsCharges.SetTableView(IDYSProvCarrierSelectPck);
                            IDYSTranssmartInsCharges.RunModal();
                        end;
                    end;
                }
                #region [Cargoson]
                field("Transit Time (Days)"; Rec."Transit Time (Days)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transit time in days.';
                    Visible = IsCargoson;
                }
                field(Surcharges; Rec.Surcharges)
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the surcharges.';
                    Visible = IsCargoson;
                    Caption = 'Surcharges';

                    trigger OnDrillDown()
                    var
                        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
                        IDYSSurcharges: Page "IDYS Transsmart Ins. Charges";
                        SurchargesCaptionLbl: Label 'Surcharges';
                    begin
                        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", Rec."Transport Order No.");
                        IDYSProvCarrierSelectPck.SetRange("Line No.", Rec."Line No.");
                        IDYSProvCarrierSelectPck.SetRange(Surcharges, true);
                        if not IDYSProvCarrierSelectPck.IsEmpty() then begin
                            IDYSSurcharges.Caption(SurchargesCaptionLbl);
                            IDYSSurcharges.SetTableView(IDYSProvCarrierSelectPck);
                            IDYSSurcharges.RunModal();
                        end;
                    end;
                }
                #endregion
                #region [nShift Ship]
                field("Actor Id"; Rec."Actor Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actor id.';
                    Visible = IsDeliveryHub;
                }
                field("Package Type Description"; Rec."Package Type Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type that should be used with this service.';
                    Visible = IsDeliveryHub;
                }
                field(ServiceDetails; Rec.Details)
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Included Services.';
                    Visible = IsDeliveryHub;
                    Caption = 'Included Services';

                    trigger OnDrillDown()
                    var
                        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
                        IDYSProvCarrierSelSvc: Page "IDYS Prov. Carrier Sel. Svc.";
                    begin
                        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", Rec."Transport Order No.");
                        IDYSProvCarrierSelectPck.SetRange(Provider, Rec.Provider);
                        IDYSProvCarrierSelectPck.SetRange("Line No.", Rec."Line No.");

                        IDYSProvCarrierSelSvc.SetTableView(IDYSProvCarrierSelectPck);
                        IDYSProvCarrierSelSvc.RunModal();
                    end;
                }
                #endregion
                #region [Sendcloud]
                field("Max Weight"; Rec."Max Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum weight for the service.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved to details';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }

                field("Calculated Price"; Rec."Calculated Price")
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price.';
                    Visible = (ViewMode = ViewMode::MultipleBookingProfiles);
                }

                field(Details; Rec.Details)
                {
                    StyleExpr = RowStyleExpr;
                    ApplicationArea = All;
                    ToolTip = 'Specifies if everything needed for this record is mapped.';
                    Visible = (ViewMode = ViewMode::MultipleBookingProfiles);

                    trigger OnDrillDown()
                    var
                        IDYSProvCarrierSelectPck: Record "IDYS Prov. Carrier Select Pck.";
                    begin
                        IDYSProvCarrierSelectPck.SetRange("Transport Order No.", Rec."Transport Order No.");
                        IDYSProvCarrierSelectPck.SetRange(Provider, Rec.Provider);
                        IDYSProvCarrierSelectPck.SetRange("Line No.", Rec."Line No.");
                        Page.RunModal(0, IDYSProvCarrierSelectPck);

                        CurrPage.Update();
                    end;
                }
                #endregion
            }
        }
    }

    trigger OnAfterGetRecord();
    begin
        UpdateControls();
    end;

    trigger OnOpenPage()
    var
        IDYSProvider: Enum "IDYS Provider";
    begin
        if Evaluate(IDYSProvider, Rec.GetFilter(Provider)) then begin
            if IDYSProvider in [IDYSProvider::Sendcloud, IDYSProvider::EasyPost] then
                ViewMode := ViewMode::MultipleBookingProfiles;
            IsDeliveryHub := IDYSProvider = IDYSProvider::"Delivery Hub";
            IsTranssmart := IDYSProvider = IDYSProvider::Transsmart;
            IsInsuranceEnabled := IDYSProviderMgt.IsInsuranceEnabled(IDYSProvider);
            IsCargoson := IDYSProvider = IDYSProvider::Cargoson;
        end;
    end;

    local procedure UpdateControls();
    begin
        // Sendcloud displays only valid records for selection
        if ViewMode = ViewMode::MultipleBookingProfiles then begin
            RowStyleExpr := 'Favorable';
            exit;
        end;

        if Rec.Mapped and not Rec."Not Available" then
            RowStyleExpr := 'Favorable'
        else
            RowStyleExpr := 'Unfavorable';
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        RowStyleExpr: Text;
        ViewMode: Option Default,MultipleBookingProfiles;
        IsDeliveryHub: Boolean;
        IsTranssmart: Boolean;
        IsInsuranceEnabled: Boolean;
        IsCargoson: Boolean;
}