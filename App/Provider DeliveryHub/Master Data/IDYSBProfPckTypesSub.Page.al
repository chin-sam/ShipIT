page 11147720 "IDYS B. Prof. Pck. Types Sub."
{
    Caption = 'Package Types';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "IDYS BookingProf. Package Type";
    UsageCategory = None;
    DataCaptionFields = Provider;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the provider for package type.';
                }
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the carrier name.';
                }

                field("Booking Profile Description"; Rec."Booking Profile Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the booking profile description.';
                    Visible = not IsEasyPost;
                }
                field("Code"; Rec."Package Type Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the package type code.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the package type description.';
                    Visible = not IsEasyPost;
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

                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight of the package type.';
                }

                field(Default; Rec.Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the package type is the default package type.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(Provider);
    end;

    trigger OnOpenPage()
    var
        IDYSProvider: Enum "IDYS Provider";
    begin
        Rec.FilterGroup(4);
        if Evaluate(IDYSProvider, Rec.GetFilter(Provider)) then
            IsEasyPost := (IDYSProvider = IDYSProvider::EasyPost);
        Rec.FilterGroup(0);
    end;

    var
        IsEasyPost: Boolean;
}

