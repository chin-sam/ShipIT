page 11147683 "IDYS Transport Order Pck. List"
{
    Caption = 'Transport Order Package List';
    PageType = List;
    SourceTable = "IDYS Transport Order Package";
    ContextSensitiveHelpPage = '22937633';
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Package Type Code"; Rec."Package Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type code.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Restructured with Provider level';
                    ObsoleteTag = '19.7';
                    Visible = false;
                }

                field("Provider Package Type Code"; Rec."Provider Package Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type code.';
                }

                field("Package Type"; Rec."Package Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type.';
                }

                field("Package Type Name"; Rec."Package Type Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type name.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with field Description';
                    ObsoleteTag = '25.0';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Quantity replaced with multiplication action on a subpage';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }

                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tracking no..';
                }
                field("License Plate No."; Rec."License Plate No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the License Plate No.';
                }

                field(Length; Rec.Length)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the length.';
                }

                field(Width; Rec.Width)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the width.';
                }

                field(Height; Rec.Height)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the height.';
                }

                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight.';
                }

                field(Volume; Rec.Volume)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the volume.';
                    Visible = false;
                }
                field("Total Volume"; Rec."Total Volume")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total volume.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with Volume';
                    ObsoleteTag = '26.0';
                    Visible = false;
                }
                field("Total Weight"; Rec."Total Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total weight.';
                    Visible = false;
                }

                field("Linear UOM"; Rec."Linear UOM")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the linear UOM.';
                }

                field("Mass UOM"; Rec."Mass UOM")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mass UOM.';
                }
            }
        }
    }
}