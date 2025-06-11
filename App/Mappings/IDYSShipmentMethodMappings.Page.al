page 11147650 "IDYS Shipment Method Mappings"
{
    Caption = 'Shipment Method Mappings';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "IDYS Shipment Method Mapping";
    ContextSensitiveHelpPage = '96305169';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipment method code.';
                }
                field("Incoterms Code"; Rec."Incoterms Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the incoterms code.';
                }
            }
        }
    }
}