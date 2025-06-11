page 11147682 "IDYS Tpt. Ord. Del. Note List"
{
    Caption = 'Transport Order Delivery Note List';
    PageType = List;
    SourceTable = "IDYS Transport Order Del. Note";
    UsageCategory = None;

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
                }

                field("Article Name"; Rec."Article Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the article name.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
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
                }

                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the net weight.';
                }

                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the serial no..';
                }

                field("Country of Origin"; Rec."Country of Origin")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country of origin.';
                }

                field("HS Code"; Rec."HS Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the HS code.';
                }
                #region Transsmart
                field("HS Code Description"; Rec."HS Code Description")
                {
                    Visible = IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the HS code description.';
                }
                field("Reason of Export"; Rec."Reason of Export")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Reason of export.';
                }
                field("Quantity m2"; Rec."Quantity m2")
                {
                    Visible = IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Quantity in square meters.';
                }
                field("Item No."; Rec."Item No.")
                {
                    Visible = IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item No. for the Item Reference No..';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Visible = IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Variant Code for the Item Reference No.';
                }
                field("Item Reference No."; Rec."Item Reference No.")
                {
                    Visible = IsBetaFeatureEnabled;
                    Caption = 'Item Reference No. (EAN)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item Reference No., this must be an EAN Code';
                }
                field(Quality; Rec.Quality)
                {
                    Visible = IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quality.';
                }
                field(Composition; Rec.Composition)
                {
                    Visible = IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the composition.';
                }
                field("Assembly Instructions"; Rec."Assembly Instructions")
                {
                    Visible = IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the assembly instructions.';
                }
                field(Returnable; Rec.Returnable)
                {
                    Visible = IsBetaFeatureEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the goods are returnable.';
                }
                #endregion Transsmart
            }
        }
    }

    trigger OnOpenPage()
    var
        Setup: Record "IDYS Setup";
    begin
        if Setup.Get('') then
            IsBetaFeatureEnabled := Setup."Enable Beta features";
    end;

    var
        IsBetaFeatureEnabled: Boolean;
}