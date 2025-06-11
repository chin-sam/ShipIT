pageextension 11147678 "IDYS Item Units of Measure" extends "Item Units of Measure"
{
    layout
    {
        addafter(Weight)
        {
            field("IDYS Package Type"; Rec."IDYS Package Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Package Type. Packages with this package type will be added to the transport order when items are handled in this unit of measure.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Restructured with Provider level';
                ObsoleteTag = '19.7';
                Visible = false;
            }

            field("IDYS Provider"; Rec."IDYS Provider")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Provider for which the Package Type is listed.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Restructured with Provider level';
                ObsoleteTag = '21.0';
                Visible = false;
            }

            field("IDYS Provider Package Type"; Rec."IDYS Provider Package Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Package Type of the provider. Packages with this package type will be added to the transport order when items are handled in this unit of measure.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Restructured with Provider level';
                ObsoleteTag = '21.0';
                Visible = false;
            }

            field("IDYS Default Provider Packages"; Rec."IDYS Default Provider Packages")
            {
                ApplicationArea = All;
                ToolTip = 'Opens list of the Default Provider Packages';

                trigger OnDrillDown()
                var
                    IDYSItemUOMPackage: Record "IDYS Item UOM Package";
                begin
                    CurrPage.SaveRecord();
                    IDYSItemUOMPackage.SetRange("Item No.", Rec."Item No.");
                    IDYSItemUOMPackage.SetRange(Code, Rec.Code);

                    Page.RunModal(Page::"IDYS Item UOM Package Lines", IDYSItemUOMPackage);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}