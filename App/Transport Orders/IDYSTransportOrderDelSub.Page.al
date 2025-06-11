page 11147659 "IDYS Transport Order Del. Sub."
{
    AutoSplitKey = true;
    Caption = 'Transport Order Delivery Note Subpage';
    PageType = ListPart;
    SourceTable = "IDYS Transport Order Del. Note";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Article Id"; Rec."Article Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the article id.';
                    StyleExpr = ArticleIdStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }

                field("Article Name"; Rec."Article Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the article name.';
                    StyleExpr = ArticleNameStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
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
                field(IsAssigned; Rec.IsAssigned())
                {
                    ApplicationArea = IDYSPackageContent;
                    Caption = 'Assigned';
                    ToolTip = 'Specifies if delivery note line is assigned to a package.';
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        TransportOrderPackage: Record "IDYS Transport Order Package";
                        TransportOrderPckList: Page "IDYS Transport Order Pck. List";
                    begin
                        if TransportOrderPackage.Get(Rec."Transport Order Pkg. Record Id") then begin
                            TransportOrderPackage.SetRecFilter();
                            TransportOrderPckList.SetTableView(TransportOrderPackage);
                            TransportOrderPckList.Editable(false);
                            TransportOrderPckList.RunModal();
                        end;
                    end;
                }

                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit price.';
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                }

                field("Quantity Backorder"; Rec."Quantity Backorder")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity in backorder.';
                }

                field("Quantity Order"; Rec."Quantity Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity in order.';
                }

                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the gross weight.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the net weight.';
                }
                field("Weight UOM"; Rec."Weight UOM")
                {
                    Visible = IsTranssmart and IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies unit of measure for the weight (e.g. KG, LB, OZ).';
                    StyleExpr = WeightUOMStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }

                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the serial no..';
                    StyleExpr = SerialNoStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }

                field("Country of Origin"; Rec."Country of Origin")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country of origin.';
                    StyleExpr = CountryOfOriginStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }

                field("HS Code"; Rec."HS Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the HS code.';
                    StyleExpr = HsCodeStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                #region Transsmart
                field("HS Code Description"; Rec."HS Code Description")
                {
                    Visible = IsTranssmart and IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the HS code description.';
                    StyleExpr = HsCodeDescriptionStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Reason of Export"; Rec."Reason of Export")
                {
                    Visible = IsTranssmart;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Reason of export.';
                    StyleExpr = ReasonOfExportStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Quantity m2"; Rec."Quantity m2")
                {
                    Visible = IsTranssmart and IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Quantity in square meters.';
                }
                field("Item No."; Rec."Item No.")
                {
                    Visible = IsTranssmart and IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item No. for the Item Reference No..';
                    StyleExpr = ItemNoStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Visible = IsTranssmart and IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Variant Code for the Item Reference No.';
                    StyleExpr = VariantCodeStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Item Reference No."; Rec."Item Reference No.")
                {
                    Visible = IsTranssmart and IsBetaFeatureEnabled;
                    Caption = 'Item Reference No. (EAN)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item Reference No., this must be an EAN Code';
                    StyleExpr = ItemReferenceNoStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field(Quality; Rec.Quality)
                {
                    Visible = IsTranssmart and IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quality.';
                    StyleExpr = QualityStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field(Composition; Rec.Composition)
                {
                    Visible = IsTranssmart and IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the composition.';
                    StyleExpr = CompositionStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Assembly Instructions"; Rec."Assembly Instructions")
                {
                    Visible = IsTranssmart and IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the assembly instructions.';
                    StyleExpr = AssemblyInstructionsStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field(Returnable; Rec.Returnable)
                {
                    Visible = IsTranssmart and IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the goods are returnable.';
                }
                #endregion Transsmart
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
                group(Package)
                {
                    Caption = 'Package';
                    action(Assign)
                    {
                        Caption = 'Assign';
                        Image = Apply;
                        ToolTip = 'Assigns one or multiple lines to the selected package.';
                        ApplicationArea = IDYSPackageContent;

                        trigger OnAction();
                        var
                            TransportOrderPackage: Record "IDYS Transport Order Package";
                            Selection: Record "IDYS Transport Order Del. Note";
                            TransportOrderPckList: Page "IDYS Transport Order Pck. List";
                        begin
                            TransportOrderPackage.SetRange("Transport Order No.", Rec."Transport Order No.");
                            TransportOrderPckList.SetTableView(TransportOrderPackage);
                            TransportOrderPckList.LookupMode(true);
                            TransportOrderPckList.Editable(false);
                            if TransportOrderPckList.RunModal() = Action::LookupOK then begin
                                TransportOrderPckList.GetRecord(TransportOrderPackage);
                                CurrPage.SetSelectionFilter(Selection);
                                Selection.ModifyAll("Transport Order Pkg. Record Id", TransportOrderPackage.RecordId);
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
                            Selection: Record "IDYS Transport Order Del. Note";
                            DummyRecId: RecordId;
                        begin
                            CurrPage.SetSelectionFilter(Selection);
                            Selection.ModifyAll("Transport Order Pkg. Record Id", DummyRecId);
                            CurrPage.Update(false);
                        end;
                    }
                }
                action("Divide Content")
                {
                    Caption = 'Divide Content';
                    Image = Split;
                    ToolTip = 'Splits delivery note line by subtracting the entered quantity from the original line.';
                    ApplicationArea = IDYSPackageContent;

                    trigger OnAction();
                    var
                        DecimalDialog: Page "IDYS Decimal Dialog";
                        SplitQuantity: Decimal;
                    begin
                        DecimalDialog.Caption(QtyDialogLbl);
                        DecimalDialog.SetValues(QtyValueCaptionLbl, Rec.Quantity);
                        if DecimalDialog.RunModal() = Action::OK then begin
                            DecimalDialog.GetValues(SplitQuantity);
                            Rec.SplitLine(SplitQuantity);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetStyle();
    end;

    procedure SetProvider(NewProvider: Enum "IDYS Provider")
    var
        Setup: Record "IDYS Setup";
    begin
        Provider := NewProvider;
        IsTranssmart := NewProvider = NewProvider::Transsmart;
        if Setup.Get('') then
            IsBetaFeatureEnabled := Setup."Enable Beta features";
    end;

    local procedure SetStyle()
    var
        IDYSFieldSetup: Record "IDYS Field Setup";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        IDYSSetup: Record "IDYS Setup";
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        IDYSSetup.Get();
        IDYSTransportOrderHeader.Get(Rec."Transport Order No.");
        if IDYSShipAgentMapping.Get(IDYSTransportOrderHeader."Shipping Agent Code") then begin
            ArticleIdStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("Article Id"), Strlen(Rec."Article Id"));
            ArticleNameStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("Article Name"), Strlen(Rec."Article Name"));
            DescriptionStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo(Description), Strlen(Rec.Description));
            WeightUOMStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("Weight UOM"), Strlen(Rec."Weight UOM"));
            SerialNoStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("Serial No."), Strlen(Rec."Serial No."));
            CountryOfOriginStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("Country of Origin"), Strlen(Rec."Country of Origin"));
            HsCodeDescriptionStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("HS Code Description"), Strlen(Rec."HS Code Description"));
            HsCodeStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("HS Code"), Strlen(Rec."HS Code"));
            ReasonOfExportStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("Reason of Export"), Strlen(Rec."Reason of Export"));
            ItemNoStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("Item No."), Strlen(Rec."Item No."));
            VariantCodeStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("Variant Code"), Strlen(Rec."Variant Code"));
            ItemReferenceNoStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("Item Reference No."), Strlen(Rec."Item Reference No."));
            QualityStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo(Quality), Strlen(Rec.Quality));
            CompositionStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo(Composition), Strlen(Rec.Composition));
            AssemblyInstructionsStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Del. Note", Rec.FieldNo("Assembly Instructions"), Strlen(Rec."Assembly Instructions"));

        end;
    end;

    var
        Provider: Enum "IDYS Provider";
        IsTranssmart: Boolean;
        IsBetaFeatureEnabled: Boolean;
        ArticleIdStyleExpr: Text;
        ArticleNameStyleExpr: Text;
        DescriptionStyleExpr: Text;
        WeightUOMStyleExpr: Text;
        SerialNoStyleExpr: Text;
        CountryOfOriginStyleExpr: Text;
        HsCodeStyleExpr: Text;
        HsCodeDescriptionStyleExpr: Text;
        ReasonOfExportStyleExpr: Text;
        ItemNoStyleExpr: Text;
        VariantCodeStyleExpr: Text;
        ItemReferenceNoStyleExpr: Text;
        QualityStyleExpr: Text;
        CompositionStyleExpr: Text;
        AssemblyInstructionsStyleExpr: Text;
        QtyDialogLbl: Label 'Enter quantity to split';
        QtyValueCaptionLbl: Label 'Quantity';
}