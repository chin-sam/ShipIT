page 11147730 "IDYS Prov. Carrier Select Pck."
{
    Caption = 'Package Details';
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = List;
    SourceTable = "IDYS Prov. Carrier Select Pck.";
    UsageCategory = None;
    ContextSensitiveHelpPage = '23199761';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                FreezeColumn = Price;
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider.';
                    Editable = false;
                }

                field(Include; Rec.Include)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which booking profile is going to be used at the package level';
                }

                field(Price; Rec."Price as Decimal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price.';
                    Editable = false;
                }

                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                    Editable = false;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the carrier.';
                    Editable = false;
                }

                field("Parcel Identifier"; Rec."Parcel Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Parcel Identifier.';
                    Editable = false;
                }

                field("Min. Weight"; Rec."Min. Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum weight for the service.';
                    Editable = false;
                    Visible = IsSendcloud;
                }
                field("Max Weight"; Rec."Max Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum weight for the service.';
                    Editable = false;
                    Visible = IsSendcloud;
                }

                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package weight.';
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        IDYSProvider: Enum "IDYS Provider";
    begin
        if Evaluate(IDYSProvider, Rec.GetFilter(Provider)) then
            IsSendcloud := (IDYSProvider = IDYSProvider::Sendcloud);
    end;

    var
        IsSendcloud: Boolean;
}

