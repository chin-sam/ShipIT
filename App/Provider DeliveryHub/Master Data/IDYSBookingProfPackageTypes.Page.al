page 11147716 "IDYS BookingProf Package Types"
{
    Caption = 'Package Types';
    DeleteAllowed = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS BookingProf. Package Type";
    UsageCategory = Lists;
    ApplicationArea = All;
    ContextSensitiveHelpPage = '96567323';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider for package type.';
                }
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                }

                field("Booking Profile Description"; Rec."Booking Profile Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the booking profile description.';
                }
                field("Code"; Rec."Package Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type code.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type description.';
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

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(Provider, "Actor Id");
    end;
}

