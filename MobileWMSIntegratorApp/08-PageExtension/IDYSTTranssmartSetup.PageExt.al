pageextension 11147817 "IDYST Transsmart Setup" extends "IDYS Transsmart Setup"
{
    layout
    {
        addlast(Defaults)
        {
            group(Tasklet)
            {
                group("IDYST Mass")
                {
                    Caption = 'Mass';
                    field("IDYST Source Unit (Mass)"; Rec."IDYST Source Unit (Mass)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Source Unit (Mass) that is used in the Tasklet.';
                    }
                    field("IDYST Conversion Factor (Mass)"; Rec."IDYST Conversion Factor (Mass)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Conversion Factor (Mass) for Tasklet.';
                    }
                    field("IDYST Rounding Prec. (Mass)"; Rec."IDYST Rounding Prec. (Mass)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Rounding Precision (Mass) for Tasklet.';
                    }
                }
                group("IDYST Linear")
                {
                    Caption = 'Linear';
                    field("IDYST Source Unit (Linear)"; Rec."IDYST Source Unit (Linear)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Source Unit (Linear) that is used in the Tasklet.';
                    }
                    field("IDYST Conv. Factor (Linear)"; Rec."IDYST Conv. Factor (Linear)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Conversion Factor (Linear) for Tasklet.';
                    }
                    field("IDYST Rounding Prec. (Linear)"; Rec."IDYST Rounding Prec. (Linear)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Rounding Precision (Linear) for Tasklet.';
                    }
                }
            }
        }
    }
}