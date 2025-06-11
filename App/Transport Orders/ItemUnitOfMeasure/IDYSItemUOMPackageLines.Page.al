page 11147735 "IDYS Item UOM Package Lines"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "IDYS Item UOM Package";
    Caption = 'Default Package Lines';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("IDYS Provider"; Rec."IDYS Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Provider for which the Package Type is listed.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Provider Package Type Code"; Rec."Provider Package Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Package Type of the provider. Packages with this package type will be added to the transport order when items are handled in this unit of measure.';
                    Editable = not (IsnShiftShip or IsEasyPost);
                }
                field("Profile Packages"; Rec."Profile Packages")
                {
                    ApplicationArea = All;
                    ToolTip = 'Opens list of the Default Provider Profile Packages.';

                    trigger OnDrillDown()
                    var
                        IDYSItemUOMProfilePackage: Record "IDYS Item UOM Profile Package";
                    begin
                        if not (IsnShiftShip or IsEasyPost) then
                            exit;

                        CurrPage.SaveRecord();
                        IDYSItemUOMProfilePackage.SetRange("Item No.", Rec."Item No.");
                        IDYSItemUOMProfilePackage.SetRange(Code, Rec.Code);
                        IDYSItemUOMProfilePackage.SetRange("Item UOM Package Entry No.", Rec."Entry No.");
                        IDYSItemUOMProfilePackage.SetRange("Provider Filter", Rec."IDYS Provider");

                        Page.RunModal(Page::"IDYS Item UOM Prof. Pck. Lines", IDYSItemUOMProfilePackage);
                        CurrPage.Update(false);
                    end;
                }

            }
        }
    }

    trigger OnAfterGetRecord()
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        IsnShiftShip := IDYSProviderMgt.IsProviderEnabled(Rec."IDYS Provider", Enum::"IDYS Provider"::"Delivery Hub");
        IsEasyPost := IDYSProviderMgt.IsProviderEnabled(Rec."IDYS Provider", Enum::"IDYS Provider"::EasyPost);
    end;

    var
        IsnShiftShip: Boolean;
        IsEasyPost: Boolean;
}