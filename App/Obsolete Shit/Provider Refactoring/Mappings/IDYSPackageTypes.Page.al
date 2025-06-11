page 11147644 "IDYS Package Types"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Package Types';
    DeleteAllowed = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS Package Type";
    UsageCategory = None;
    ContextSensitiveHelpPage = '22282322';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type code.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type description.';
                }

                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type.';
                }

                field(Default; Rec.Default)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies if the package type is the default package type.';
                }

                field(Length; Rec.Length)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the length of the package type.';
                }

                field(Width; Rec.Width)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the width of the package type.';
                }

                field(Height; Rec.Height)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the height of the package type.';
                }

                field("Linear UOM"; Rec."Linear UOM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the linear UOM of the package type.';
                }

                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight of the package type.';
                }

                field("Mass UOM"; Rec."Mass UOM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mass UOM of the package type.';
                }
                #region [Sendcloud]
                field("Special Equipment Code"; Rec."Special Equipment Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the equipment needed for this package type.';
                }
                #endregion [Sendcloud] 
            }
        }
    }
}

