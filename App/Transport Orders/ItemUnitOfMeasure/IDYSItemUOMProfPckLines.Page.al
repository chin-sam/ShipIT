page 11147736 "IDYS Item UOM Prof. Pck. Lines"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "IDYS Item UOM Profile Package";
    Caption = 'Default Profile Package Lines';


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Shipping Agent Code (Mapped)"; Rec."Shipping Agent Code (Mapped)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent code.';
                }
                field("Ship. Agent Svc. Code (Mapped)"; Rec."Ship. Agent Svc. Code (Mapped)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service code.';
                    Visible = not IsEasyPost;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent code.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Changed Table Relation';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service code.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Changed Table Relation';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }
                field("Provider Package Type Code"; Rec."Provider Package Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Profile Package Type of the provider. Packages with this package type will be added to the transport order when items are handled in this unit of measure and used with this Profile.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        IDYSProvider: Enum "IDYS Provider";
    begin
        if Evaluate(IDYSProvider, Rec.GetFilter("Provider Filter")) then
            IsEasyPost := (IDYSProvider = IDYSProvider::EasyPost);
    end;

    var
        IsEasyPost: Boolean;
}