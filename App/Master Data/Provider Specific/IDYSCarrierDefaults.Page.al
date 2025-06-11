page 11147728 "IDYS Carrier Defaults"
{
    Caption = 'Carrier Defaults';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "IDYS Provider Carrier";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                group(Mass)
                {
                    field("Conversion Factor (Mass)"; Rec."Conversion Factor (Mass)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Conversion Factor (Mass).';
                    }

                    field("Rounding Precision (Mass)"; Rec."Rounding Precision (Mass)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Rounding Precision (Mass).';
                    }
                }
                group(Linear)
                {
                    Visible = false;
                    field("Conversion Factor (Linear)"; Rec."Conversion Factor (Linear)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Conversion Factor (Linear).';
                    }

                    field("Rounding Precision (Linear)"; Rec."Rounding Precision (Linear)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Rounding Precision (Linear).';
                    }
                }
                group(Volume)
                {
                    Visible = false;
                    field("Conversion Factor (Volume)"; Rec."Conversion Factor (Volume)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Conversion Factor (Volume).';
                    }

                    field("Rounding Precision (Volume)"; Rec."Rounding Precision (Volume)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Rounding Precision (Volume).';
                    }
                }
            }
        }
    }
}