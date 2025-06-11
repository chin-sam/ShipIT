page 11147671 "IDYS Transport Order Line Sub."
{
    AutoSplitKey = true;
    Caption = 'Transport Order Line Sub.';
    PageType = ListPart;
    SourceTable = "IDYS Transport Order Line";
    ContextSensitiveHelpPage = '22937633';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Source Table Caption"; Rec."Source Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source table caption.';
                    StyleExpr = SourceTableCaptionStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document no..';
                    StyleExpr = SourceDocumentNoStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Source Document Line No."; Rec."Source Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document line no..';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item no..';
                    StyleExpr = ItemNoStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant code..';
                    StyleExpr = VariantCodeStyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item category code.';
                    StyleExpr = ItemCategoryCodeStyleExpr;
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
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description 2.';
                    StyleExpr = Description2StyleExpr;
                    trigger OnValidate()
                    begin
                        SetStyle();
                    end;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                    Visible = false;
                }
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the base quantity.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transport value';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = SourceDocLine;

                action("Show Document")
                {
                    Caption = 'Show Document';
                    Image = View;
                    ShortCutKey = 'Shift+F7';
                    ApplicationArea = All;
                    ToolTip = 'Shows the document.';

                    trigger OnAction();
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentMgt.ShowSourceDocument(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IDYSTransportOrderHeader.Get(Rec."Transport Order No.");
        SetStyle();
    end;

    local procedure SetStyle()
    var
        IDYSFieldSetup: Record "IDYS Field Setup";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        IDYSSetup.Get();
        if IDYSShipAgentMapping.Get(IDYSTransportOrderHeader."Shipping Agent Code") then begin
            SourceTableCaptionStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Line", Rec.FieldNo("Source Table Caption"), Strlen(Rec."Source Table Caption"));
            SourceDocumentNoStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Line", Rec.FieldNo("Source Document No."), Strlen(Rec."Source Document No."));
            ItemNoStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Line", Rec.FieldNo("Item No."), Strlen(Rec."Item No."));
            VariantCodeStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Line", Rec.FieldNo("Variant Code"), Strlen(Rec."Variant Code"));
            ItemCategoryCodeStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Line", Rec.FieldNo("Item Category Code"), Strlen(Rec."Item Category Code"));
            DescriptionStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Line", Rec.FieldNo(Description), Strlen(Rec.Description));
            Description2StyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Line", Rec.FieldNo("Description 2"), Strlen(Rec."Description 2"));

        end;
    end;

    var

        IDYSSetup: Record "IDYS Setup";
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        SourceTableCaptionStyleExpr: Text;
        SourceDocumentNoStyleExpr: Text;
        ItemNoStyleExpr: Text;
        VariantCodeStyleExpr: Text;
        ItemCategoryCodeStyleExpr: Text;
        DescriptionStyleExpr: Text;
        Description2StyleExpr: Text;
}

