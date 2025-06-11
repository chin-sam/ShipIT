page 11147725 "IDYS Provider Package Types"
{
    Caption = 'Package Types';
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS Provider Package Type";
    UsageCategory = None;
    ContextSensitiveHelpPage = '22708296';

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
                    Editable = not IsCargoson;
                }

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type code.';
                    Editable = not IsCargoson;
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
                    Visible = IsTranssmart;
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
                    Visible = IsTranssmart;
                }
                #region [Sendcloud]
                field("Special Equipment Code"; Rec."Special Equipment Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the equipment needed for this package type.';
                    Visible = IsSendcloud;
                }
                #endregion [Sendcloud] 
            }
        }
    }

    trigger OnOpenPage()
    var
        IDYSProvider: Enum "IDYS Provider";
    begin
        if Evaluate(IDYSProvider, Rec.GetFilter(Provider)) then begin
            IsSendcloud := (IDYSProvider = IDYSProvider::Sendcloud);
            IsTranssmart := (IDYSProvider = IDYSProvider::Transsmart);
            IsCargoson := (IDYSProvider = IDYSProvider::Cargoson)
        end;
    end;

    [Obsolete('Replaced with code in OnOpenPage() trigger', '25.0')]
    procedure SetVisibilities(IDYSProvider: Enum "IDYS Provider")
    begin
    end;

    var
        IsTranssmart: Boolean;
        IsSendcloud: Boolean;
        IsCargoson: Boolean;
}

