page 11147672 "IDYS Transport Order Pck. Sub."
{
    Caption = 'Transport Order Package Subpage';
    PageType = ListPart;
    SourceTable = "IDYS Transport Order Package";
    ContextSensitiveHelpPage = '22937633';

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
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Restructured with Provider level';
                    ObsoleteTag = '19.7';
                    Visible = false;
                }

                field("Provider Package Type Code"; Rec."Provider Package Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type code.';
                    StyleExpr = ProviderPackageTypeCodeStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;

#if BC17 or BC18
                    trigger OnAssistEdit()
#else
                    trigger OnDrillDown()
#endif  
                    var
                        TransportOrderHeader: Record "IDYS Transport Order Header";
                        ProviderPackageType: Record "IDYS Provider Package Type";
                        BookingProfPackageType: Record "IDYS BookingProf. Package Type";
                        ProviderPackageTypes: Page "IDYS Provider Package Types";
                        BookingProfPackageTypes: Page "IDYS BookingProf Package Types";
                        UpdateTotals: Boolean;
                    begin
                        TransportOrderHeader.Get(Rec."Transport Order No.");
                        TransportOrderHeader.TestField(Provider);
                        case TransportOrderHeader.Provider of
                            TransportOrderHeader.Provider::Default,
                            TransportOrderHeader.Provider::Sendcloud,
                            TransportOrderHeader.Provider::Transsmart,
                            TransportOrderHeader.Provider::Cargoson:
                                begin
                                    ProviderPackageType.SetRange(Provider, TransportOrderHeader.Provider);
                                    ProviderPackageTypes.SetTableView(ProviderPackageType);
                                    ProviderPackageTypes.LookupMode(true);
                                    if ProviderPackageTypes.Runmodal() = Action::LookupOK then begin
                                        ProviderPackageTypes.GetRecord(ProviderPackageType);
                                        Rec.Validate("Provider Package Type Code", ProviderPackageType.Code);
                                        UpdateTotals := true;
                                    end;
                                end;
                            TransportOrderHeader.Provider::"Delivery Hub",
                            TransportOrderHeader.Provider::EasyPost:
                                begin
                                    BookingProfPackageType.SetRange("Carrier Entry No.", TransportOrderHeader."Carrier Entry No.");
                                    BookingProfPackageType.SetRange("Booking Profile Entry No.", IDYSProviderMgt.GetBookingProfileEntryNo(TransportOrderHeader."Carrier Entry No.", TransportOrderHeader."Booking Profile Entry No."));
                                    BookingProfPackageTypes.SetTableView(BookingProfPackageType);
                                    BookingProfPackageTypes.Editable := false;
                                    BookingProfPackageTypes.LookupMode(true);
                                    if BookingProfPackageTypes.Runmodal() = Action::LookupOK then begin
                                        BookingProfPackageTypes.GetRecord(BookingProfPackageType);
                                        Rec.SetRange("Carrier Entry No. Filter", TransportOrderHeader."Carrier Entry No.");
                                        Rec.SetRange("Booking P. Entry No. Filter", IDYSProviderMgt.GetBookingProfileEntryNo(TransportOrderHeader."Carrier Entry No.", TransportOrderHeader."Booking Profile Entry No."));

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
                    StyleExpr = PackageTypeStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
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
                    StyleExpr = DescriptionStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }

                field(AssignedLines; Rec.AssignedLines())
                {
                    ApplicationArea = IDYSPackageContent;
                    Caption = 'Assigned Lines';
                    ToolTip = 'Specifies the assigned line count (package content).';
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown();
                    var
                        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
                        TprOrdDelNoteList: Page "IDYS Tpt. Ord. Del. Note List";
                    begin
                        TransportOrderDelNote.SetRange("Transport Order No.", Rec."Transport Order No.");
                        TransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", Rec.RecordId);
                        if not TransportOrderDelNote.IsEmpty() then begin
                            TprOrdDelNoteList.SetTableView(TransportOrderDelNote);
                            TprOrdDelNoteList.Editable(false);
                            TprOrdDelNoteList.RunModal();
                        end;
                    end;
                }

                field(CalculatedWeight; Rec.GetCalculatedWeight())
                {
                    ApplicationArea = IDYSPackageContent;
                    Caption = 'Calculated Weight';
                    ToolTip = 'Specifies the total gross weight of the asiggned delivery note lines.';
                    Editable = false;
                    DrillDown = true;
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(CalculatedWeightLbl, MassCaption);

                    trigger OnDrillDown();
                    var
                        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
                        TprOrdDelNoteList: Page "IDYS Tpt. Ord. Del. Note List";
                    begin
                        TransportOrderDelNote.SetRange("Transport Order No.", Rec."Transport Order No.");
                        TransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", Rec.RecordId());
                        if not TransportOrderDelNote.IsEmpty() then begin
                            TprOrdDelNoteList.SetTableView(TransportOrderDelNote);
                            TprOrdDelNoteList.Editable(false);
                            TprOrdDelNoteList.RunModal();
                        end;
                    end;
                }
                field("Actual Weight"; Rec."Actual Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actual (measured) weight of the parcel. When you omit this value, the calculated weight will be used.';
                    BlankZero = true;
                    Visible = IsSendcloud or IsEasyPost or (IsTranssmart and LinkDelLinesWithPackages);
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption("Actual Weight"), MassCaption);

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Quantity replaced with multiplication action on a subpage';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }

                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tracking no.';
                    Visible = not IsCargoson;
                    StyleExpr = TrackingNoStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }

                field("Tracking Url"; Rec."Tracking Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tracking Url';
                    Visible = not IsCargoson;
                    StyleExpr = TrackingUrlStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Actual Delivery Date"; Rec."Actual Delivery Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actual delivery date.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the package.';
                    Visible = not IsCargoson;
                    StyleExpr = StatusStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Sub Status (External)"; Rec."Sub Status (External)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the detailed status of the package, provided by the carrier.';
                    Visible = not IsCargoson;
                    StyleExpr = SubStatusExternalStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }

                field("License Plate No."; Rec."License Plate No.")
                {
                    Visible = not (IsSendcloud or IsEasyPost or IsCargoson);
                    ApplicationArea = All;
                    ToolTip = 'Specifies the License Plate No.';
                    StyleExpr = LicensePlateNoStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
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
                    Visible = not IsEasyPost;
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption(Volume), VolumeCaption);
                }
                field("Total Volume"; Rec."Total Volume")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total volume.';
                    Visible = false;
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption("Total Volume"), VolumeCaption);
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with Volume';
                    ObsoleteTag = '26.0';
                }
                field("Total Weight"; Rec."Total Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total weight.';
                    Visible = false;
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption("Total Weight"), MassCaption);
                }

                field("Linear UOM"; Rec."Linear UOM")
                {
                    Visible = IsTranssmart;
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the linear UOM.';
                    StyleExpr = LinearUOMStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }

                field("Mass UOM"; Rec."Mass UOM")
                {
                    Visible = IsTranssmart;
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mass UOM.';
                    StyleExpr = MassUOMStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                #region [Sendcloud & EasyPost]
                field("Label Format"; Rec."Label Format")
                {
                    Visible = IsEasyPost;
                    ApplicationArea = All;
                    ValuesAllowed = 1, 4, 5, 8;  // ZPL, PNG, PDF, EPL2
                    ToolTip = 'Specifies the default label format.';
                }
                field("Parcel Identifier"; Rec."Parcel Identifier")
                {
                    Visible = (IsSendcloud or IsEasyPost);
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package identifier.';
                    Style = Strong;
                    Editable = false;
                    StyleExpr = ParcelIdentifierStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Request Label"; Rec."Request Label")
                {
                    Visible = IsSendcloud;
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a label should be created for this parcel.';
                }
                field("Shipping Method Description"; Rec."Shipping Method Description")
                {
                    Visible = (IsSendcloud or IsEasyPost);
                    ApplicationArea = All;
                    Caption = 'Service';
                    ToolTip = 'Specifies the selected shipping agent service for this parcel.';
                    Editable = false;
                    StyleExpr = ShippingMethodDesriptionStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Insured Value"; Rec."Insured Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount of Sendcloud insurance to add for this parcel. (must be a multiple of €100 and maxes out at €2500 or €5000 depending on the carrier.)';
                    BlankZero = true;
                    Visible = IsSendcloud;
                }
                field("Total Insured Value"; Rec."Total Insured Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of insurance for this parcel (carriers insurance + Sendcloud insurance). (must be a multiple of €100 and maxes out at €2500 or €5000 depending on the carrier.)';
                    BlankZero = true;
                    Visible = IsSendcloud;
                }
                #endregion
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Package No.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Duplicate';
                    ObsoleteTag = '21.0';
                    Visible = false;
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
                ToolTip = 'Create packages for items on the source lines that are sold in boxes or packages and for which a package type has been selected in the item unit of measure.';
                Image = CreateSKU;

                trigger OnAction()
                var
                    IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
                    IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
                begin
                    IDYSTransportOrderHeader.Get(Rec."Transport Order No.");
                    IDYSProviderMgt.CreateDefaultTransportOrderPackages(IDYSTransportOrderHeader);
                    CurrPage.Update();
                end;
            }

            group(Line)
            {
                Caption = 'Line';
                action(Print)
                {
                    Caption = 'Print';
                    Image = Print;
                    ToolTip = 'Print labels and/or documents for this transport order package.';
                    ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    Visible = PrintVisible and PrintingEnabled;

                    trigger OnAction();
                    begin
                        CurrPage.SaveRecord();
                        IDYSTransportOrderMgt.Print(Rec);
                        CurrPage.Update(false);
                        if IsTranssmart then
                            Rec.OpenShippingLabel(false);
                    end;
                }
                action(Assign)
                {
                    Caption = 'Assign';
                    Image = Apply;
                    ToolTip = 'Assigns one or multiple lines to the selected package.';
                    ApplicationArea = IDYSPackageContent;

                    trigger OnAction();
                    var
                        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
                        TprOrdDelNoteList: Page "IDYS Tpt. Ord. Del. Note List";
                        DummyRecId: RecordId;
                    begin
                        TransportOrderDelNote.SetRange("Transport Order No.", Rec."Transport Order No.");
                        TransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", DummyRecId);
                        TprOrdDelNoteList.SetTableView(TransportOrderDelNote);
                        TprOrdDelNoteList.LookupMode(true);
                        TprOrdDelNoteList.Editable(false);
                        if TprOrdDelNoteList.RunModal() = Action::LookupOK then begin
                            TprOrdDelNoteList.SetSelectionFilter(TransportOrderDelNote);
                            TransportOrderDelNote.ModifyAll("Transport Order Pkg. Record Id", Rec.RecordId);
                        end;

                        CurrPage.Update(false);
                    end;
                }
                action(Unassign)
                {
                    Caption = 'Unassign';
                    Image = Apply;
                    ToolTip = 'Unassigns one or multiple lines from the selected package.';
                    ApplicationArea = IDYSPackageContent;

                    trigger OnAction()
                    var
                        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
                        TprOrdDelNoteList: Page "IDYS Tpt. Ord. Del. Note List";
                        DummyRecId: RecordId;
                    begin
                        TransportOrderDelNote.SetRange("Transport Order No.", Rec."Transport Order No.");
                        TransportOrderDelNote.SetRange("Transport Order Pkg. Record Id", Rec.RecordId);
                        TprOrdDelNoteList.SetTableView(TransportOrderDelNote);
                        TprOrdDelNoteList.LookupMode(true);
                        TprOrdDelNoteList.Editable(false);
                        if TprOrdDelNoteList.RunModal() = Action::LookupOK then begin
                            TprOrdDelNoteList.SetSelectionFilter(TransportOrderDelNote);
                            TransportOrderDelNote.ModifyAll("Transport Order Pkg. Record Id", DummyRecId);
                        end;

                        CurrPage.Update(false);
                    end;
                }
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
                            MultiplyPackageByQuantity(Multiplier);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnAfterGetCurrRecord()
    var
        IDYSProviderSetup: Record "IDYS Setup";
    begin
        if IDYSTransportOrderHeader.Get(Rec."Transport Order No.") then
            IDYSProviderMgt.GetMeasurementCaptions(IDYSTransportOrderHeader.Provider, DistanceCaption, VolumeCaption, MassCaption);

        IDYSProviderSetup.GetProviderSetup(IDYSTransportOrderHeader.Provider);
        if IDYSTransportOrderHeader.Provider in [IDYSTransportOrderHeader.Provider::EasyPost, IDYSTransportOrderHeader.Provider::Sendcloud] then
            PrintingEnabled := IDYSProviderSetup."Enable PrintIT Printing"
        else
            PrintingEnabled := true;
        PrintVisible := IDYSTransportOrderHeader.Status in [IDYSTransportOrderHeader.Status::Booked, IDYSTransportOrderHeader.Status::"Label Printed"];
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyle();
    end;

    procedure SetProvider(NewProvider: Enum "IDYS Provider")
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        Provider := NewProvider;
        IsTranssmart := NewProvider = NewProvider::Transsmart;
        IsSendcloud := NewProvider = NewProvider::Sendcloud;
        IsEasyPost := NewProvider = NewProvider::EasyPost;
        IsCargoson := NewProvider = NewProvider::Cargoson;

        IDYSSetup.Get();
        LinkDelLinesWithPackages := IDYSSetup."Link Del. Lines with Packages";
    end;

    local procedure MultiplyPackageByQuantity(Qty: Decimal)
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        QtyInteger: Integer;
        i: Integer;
        ConvertErr: label 'Quantity must be an integer.';
    begin
        if Qty mod 1 <> 0 then
            Error(ConvertErr);
        QtyInteger := Qty;

        for i := 1 to QtyInteger do begin
            Clear(TransportOrderPackage);
            TransportOrderPackage.Init();
            TransportOrderPackage."Line No." := 0;
            TransportOrderPackage.CopyFromTransportOrderPackage(Rec);
            TransportOrderPackage.Validate("System Created Entry", true);
            TransportOrderPackage.Insert(true);
        end;
    end;

    local procedure SetStyle()
    var
        IDYSFieldSetup: Record "IDYS Field Setup";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        IDYSSetup: Record "IDYS Setup";
    begin
        IDYSSetup.Get();
        if IDYSShipAgentMapping.Get(IDYSTransportOrderHeader."Shipping Agent Code") then begin
            DescriptionStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo(Description), Strlen(Rec.Description));
            LicensePlateNoStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo("License Plate No."), Strlen(Rec."License Plate No."));
            LinearUOMStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo("Linear UOM"), Strlen(Rec."Linear UOM"));
            MassUOMStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo("Mass UOM"), Strlen(Rec."Mass UOM"));
            PackageTypeStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo("Package Type"), Strlen(Rec."Package Type"));
            ParcelIdentifierStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo("Parcel Identifier"), Strlen(Rec."Parcel Identifier"));
            ProviderPackageTypeCodeStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo("Provider Package Type Code"), Strlen(Rec."Provider Package Type Code"));
            ShippingMethodDesriptionStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo("Shipping Method Description"), Strlen(Rec."Shipping Method Description"));
            StatusStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo(Status), Strlen(Rec.Status));
            SubStatusExternalStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo("Sub Status (External)"), Strlen(Rec."Sub Status (External)"));
            TrackingNoStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo("Tracking No."), Strlen(Rec."Tracking No."));
            TrackingUrlStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Package", Rec.FieldNo("Tracking Url"), Strlen(Rec."Tracking Url"));

        end;
    end;


    [Obsolete('New parameter added', '21.0')]
    procedure SetVisibilityForTransportOrder(NewIsSendCloud: Boolean; NewIsDeliveryHub: Boolean; NewIsTranssmart: Boolean)
    begin
    end;

    [Obsolete('Replaced with SetProvider()', '25.0')]
    procedure SetVisibilityForTransportOrder(NewIsSendCloud: Boolean; NewIsDeliveryHub: Boolean; NewIsTranssmart: Boolean; NewIsEasyPost: Boolean)
    begin
    end;

    var
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        Provider: Enum "IDYS Provider";
        IsSendcloud: Boolean;
        IsTranssmart: Boolean;
        IsEasyPost: Boolean;
        IsCargoson: Boolean;
        PrintingEnabled: Boolean;
        PrintVisible: Boolean;
        LinkDelLinesWithPackages: Boolean;
        ProviderPackageTypeCodeStyleExpr: Text;
        PackageTypeStyleExpr: Text;
        DescriptionStyleExpr: Text;
        TrackingNoStyleExpr: Text;
        TrackingUrlStyleExpr: Text;
        StatusStyleExpr: Text;
        SubStatusExternalStyleExpr: Text;
        LicensePlateNoStyleExpr: Text;
        LinearUOMStyleExpr: Text;
        MassUOMStyleExpr: Text;
        ParcelIdentifierStyleExpr: Text;
        ShippingMethodDesriptionStyleExpr: Text;
        MassCaption: Text;
        DistanceCaption: Text;
        VolumeCaption: Text;
        CalculatedWeightLbl: label 'Calculated Weight';
}