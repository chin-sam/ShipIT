page 11147697 "IDYS Provider Booking Profiles"
{
    Caption = 'Booking Profiles';
    DataCaptionFields = Provider, "Carrier Name";
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS Provider Booking Profile";
    UsageCategory = Lists;
    ApplicationArea = All;
    ContextSensitiveHelpPage = '95911950';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider.';
                }

                field("Description"; Rec."Description")
                {
                    ToolTip = 'Specifies the description.';
                    ApplicationArea = All;
                }
                #region [Cargoson]
                field(ServiceType; Rec.ServiceType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service type.';
                    Editable = false;
                    Visible = IsCargoson;
                }
                #endregion
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                }

                field("Service Level Code (Time)"; Rec."Service Level Code (Time)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service level code (time).';
                    Visible = IsTranssmart;
                }

                field("Service Level Code (Other)"; Rec."Service Level Code (Other)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service level code (other).';
                    Visible = IsTranssmart;
                }

                field(Mapped; Rec.Mapped)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the record is mapped.';
                }

                #region [Sendcloud]
                field("Min. Weight"; Rec."Min. Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum parcel weight for this shipping method.';
                    Editable = false;
                    Visible = IsSendcloud;
                }
                field("Max. Weight"; Rec."Max. Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum parcel weight for this shipping method.';
                    Editable = false;
                    Visible = IsSendcloud;
                }
                #endregion
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Actor Id");
    end;

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

    var
        IsSendcloud: Boolean;
        IsTranssmart: Boolean;
        IsCargoson: Boolean;
}