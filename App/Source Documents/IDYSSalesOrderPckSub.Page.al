page 11147692 "IDYS Sales Order Pck. Sub."
{
    Caption = 'Sales Order Packages';
    PageType = ListPart;
    SourceTable = "IDYS Source Document Package";
    SourceTableView = where("Document Type" = const("1"));

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Package Type Code"; Rec."Package Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type code.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Restructured with Provider level';
                    ObsoleteTag = '19.7';
                }
                field("Provider Package Type Code"; Rec."Provider Package Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type code.';

#if BC17 or BC18
                    trigger OnAssistEdit()
#else
                    trigger OnDrillDown()
#endif
                    var
                        SalesHeader: Record "Sales Header";
                        ProviderPackageType: Record "IDYS Provider Package Type";
                        BookingProfPackageType: Record "IDYS BookingProf. Package Type";
                        ProviderPackageTypes: Page "IDYS Provider Package Types";
                        BookingProfPackageTypes: Page "IDYS BookingProf Package Types";
                        UpdateTotals: Boolean;
                        IsHandled: Boolean;
                    begin
                        OnBeforeDrillDown_ProviderPackageTypeCode(Rec, UpdateTotals, IsHandled);
                        if IsHandled then
                            exit;

                        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
                            exit;

                        case SalesHeader."IDYS Provider" of
                            SalesHeader."IDYS Provider"::Default,
                            SalesHeader."IDYS Provider"::Sendcloud,
                            SalesHeader."IDYS Provider"::Transsmart,
                            SalesHeader."IDYS Provider"::Cargoson:
                                begin
                                    ProviderPackageType.SetRange(Provider, SalesHeader."IDYS Provider");
                                    ProviderPackageTypes.SetTableView(ProviderPackageType);
                                    ProviderPackageTypes.LookupMode(true);
                                    if ProviderPackageTypes.Runmodal() = Action::LookupOK then begin
                                        ProviderPackageTypes.GetRecord(ProviderPackageType);
                                        Rec.SetRange("Provider Filter", SalesHeader."IDYS Provider");
                                        Rec.Validate("Provider Package Type Code", ProviderPackageType.Code);
                                        UpdateTotals := true;
                                    end;
                                end;
                            SalesHeader."IDYS Provider"::"Delivery Hub",
                            SalesHeader."IDYS Provider"::EasyPost:
                                begin
                                    BookingProfPackageType.SetRange("Carrier Entry No.", SalesHeader."IDYS Carrier Entry No.");
                                    BookingProfPackageType.SetRange("Booking Profile Entry No.", IDYSProviderMgt.GetBookingProfileEntryNo(SalesHeader."IDYS Carrier Entry No.", SalesHeader."IDYS Booking Profile Entry No."));
                                    BookingProfPackageTypes.SetTableView(BookingProfPackageType);
                                    BookingProfPackageTypes.Editable := false;
                                    BookingProfPackageTypes.LookupMode(true);
                                    if BookingProfPackageTypes.Runmodal() = Action::LookupOK then begin
                                        BookingProfPackageTypes.GetRecord(BookingProfPackageType);
                                        Rec.SetRange("Carrier Entry No. Filter", SalesHeader."IDYS Carrier Entry No.");
                                        Rec.SetRange("Booking P. Entry No. Filter", IDYSProviderMgt.GetBookingProfileEntryNo(SalesHeader."IDYS Carrier Entry No.", SalesHeader."IDYS Booking Profile Entry No."));

                                        Rec.Validate("Book. Prof. Package Type Code", BookingProfPackageType."Package Type Code");
                                        UpdateTotals := true;
                                    end;
                                end;
                        end;

                        if UpdateTotals then begin
                            Rec.UpdateTotalVolume();
                            Rec.UpdateTotalWeight();
                            CurrPage.Update();
                        end
                    end;
                }

                field("Package Type"; Rec."Package Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type.';
                }

                field("Package Type Name"; Rec."Package Type Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type name.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with field Description';
                    ObsoleteTag = '25.0';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Quantity replaced with multiplication action on a subpage';
                    ObsoleteTag = '21.0';
                }

                field(Length; Rec.Length)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the length.';
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption(Length), DistanceCaption);
                }

                field(Width; Rec.Width)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the width.';
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption(Width), DistanceCaption);
                }

                field(Height; Rec.Height)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the height.';
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption(Height), DistanceCaption);
                }

                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight.';
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption(Weight), MassCaption);
                }

                field(Volume; Rec.Volume)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the volume.';
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption(Volume), VolumeCaption);
                    Visible = not IsEasyPost;
                }

                field("Total Volume"; Rec."Total Volume")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total volume.';
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption("Total Volume"), VolumeCaption);
                    Visible = false;
                }

                field("Total Weight"; Rec."Total Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total weight.';
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption("Total Weight"), MassCaption);
                }

                field("Linear UOM"; Rec."Linear UOM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the linear UOM.';
                    Visible = IsTranssmart;
                    Editable = false;
                }

                field("Mass UOM"; Rec."Mass UOM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mass UOM.';
                    Visible = IsTranssmart;
                    Editable = false;
                }
                field("Parcel Identifier"; Rec."Parcel Identifier")
                {
                    Visible = IsSendcloud or IsEasyPost;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package identifier.';
                    Style = Strong;
                    Editable = false;
                }

                field("Shipping Method Description"; Rec."Shipping Method Description")
                {
                    Visible = IsSendcloud or IsEasyPost;
                    ApplicationArea = All;
                    Caption = 'Service';
                    ToolTip = 'Specifies the selected shipping agent service for this parcel.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreatePackagesForUOM)
            {
                Caption = 'Create Packages for items sold in packs.';
                ApplicationArea = All;
                ToolTip = 'Create packages for items on the sales order that are sold in boxes or packages and for which a package type has been selected in the item unit of measure.';
                Image = CreateSKU;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
                begin
                    SalesHeader.Get(Rec."Document Type", Rec."Document No.");
                    IDYSProviderMgt.CreateDefaultSourceDocumentPackages(SalesHeader);
                    CurrPage.Update();
                end;
            }
            group(Line)
            {
                action("Additional Package")
                {
                    Caption = 'Add Additional Packages';
                    Image = PickWorksheet;
                    ToolTip = 'Add additional packages for the entered quantity.';
                    ApplicationArea = All;

                    trigger OnAction();
                    var
                        DecimalDialog: Page "IDYS Decimal Dialog";
                        Multiplier: Decimal;
                        MultiplierDialogLbl: Label 'Enter the number of packages you want to create';
                        MultiplierValueCaptionLbl: Label 'Additional packages to create:';
                    begin
                        DecimalDialog.Caption(MultiplierDialogLbl);
                        DecimalDialog.SetValues(MultiplierValueCaptionLbl, 1);
                        if DecimalDialog.RunModal() = Action::OK then begin
                            DecimalDialog.GetValues(Multiplier);
                            Rec.MultiplyPackageByQuantity(Multiplier);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    procedure SetProvider(NewProvider: Enum "IDYS Provider")
    begin
        Provider := NewProvider;
        IsTranssmart := NewProvider = NewProvider::Transsmart;
        IsSendcloud := NewProvider = NewProvider::Sendcloud;
        IsEasyPost := NewProvider = NewProvider::EasyPost;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IDYSProviderMgt.GetMeasurementCaptions(Provider, DistanceCaption, VolumeCaption, MassCaption);
    end;

    [Obsolete('Replaced with SetProvider()', '24.0')]
    procedure SetVisibilityForSalesOrder(NewIsSendCloud: Boolean; NewIsDeliveryHub: Boolean; NewIsTranssmart: Boolean; NewIsEasyPost: Boolean)
    begin
    end;

    [Obsolete('New parameter added', '21.0')]
    procedure SetVisibilityForSalesOrder(NewIsSendCloud: Boolean; NewIsDeliveryHub: Boolean; NewIsTranssmart: Boolean)
    begin
    end;


    [IntegrationEvent(true, false)]
    local procedure OnBeforeDrillDown_ProviderPackageTypeCode(var Rec: Record "IDYS Source Document Package"; var UpdateTotals: Boolean; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('Replaced with OnBeforeCreateDefaultSourceDocumentPackages() in IDYSProviderMgt.Codeunit.al', '25.0')]
    [IntegrationEvent(true, false)]
    local procedure OnBeforeCreatePackagesForUOM(var Rec: Record "IDYS Source Document Package"; var IsHandled: Boolean)
    begin
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        Provider: Enum "IDYS Provider";
        IsSendcloud: Boolean;
        IsTranssmart: Boolean;
        IsEasyPost: Boolean;
        MassCaption: Text;
        DistanceCaption: Text;
        VolumeCaption: Text;
}