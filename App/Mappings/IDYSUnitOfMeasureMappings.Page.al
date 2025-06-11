page 11147727 "IDYS Unit of Measure Mappings"
{
    Caption = 'Unit of Measure Mappings';
    UsageCategory = Lists;
    ApplicationArea = All;
    PageType = List;
    SourceTable = "IDYS Unit of Measure Mapping";
    ContextSensitiveHelpPage = '22315059';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure code.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the unit of measure description.';
                }

                field("Unit of Measure (External)"; Rec."Unit of Measure (External)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external unit of measure code.';
                }
            }
        }
    }
}