page 11147704 "IDYS Combined Package Types"
{
    Caption = 'Package Types';
    LinksAllowed = false;
    InsertAllowed = false;
    PageType = List;
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
                field("User Defined"; Rec."User Defined")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if package is user defined.';
                }
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the carrier name.';
                }
                field("Package Type Code"; Rec."Package Type Code")
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
        if Evaluate(IDYSProvider, Rec.GetFilter(Provider)) then
            IsEasyPost := (IDYSProvider = IDYSProvider::EasyPost);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.TestField(Provider, Rec.Provider::EasyPost);
        Rec.TestField("User Defined", true);
    end;

    var
        IsEasyPost: Boolean;

}