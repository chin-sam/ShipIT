page 11147729 "IDYS Select Booking Profiles"
{
    PageType = List;
    Caption = 'Select Multiple Provider Booking Profiles';
    UsageCategory = None;
    SourceTable = "IDYS Provider Booking Profile";
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;

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

                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                }

                #region [Sendcloud]
                field("Min. Weight"; Rec."Min. Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum parcel weight for this shipping method.';
                    Editable = false;
                    Visible = (IDYSProvider = IDYSProvider::Sendcloud);
                }
                field("Max. Weight"; Rec."Max. Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum parcel weight for this shipping method.';
                    Editable = false;
                    Visible = (IDYSProvider = IDYSProvider::Sendcloud);
                }
                field("Is Return"; Rec."Is Return")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if profile is used for the returns.';
                    Editable = false;
                    Visible = (IDYSProvider = IDYSProvider::Sendcloud);
                }
                #endregion
                field(Selected; Rec.Selected)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if service is included within the mapped shipping agent service.';
                    Caption = 'Include';

                    trigger OnValidate()
                    begin
                        ValidateRecSelected(Rec.Selected);
                    end;
                }
            }
        }
    }

    procedure InitializePage(pShippingAgentCode: Code[10]; pShippingAgentSvcCode: Code[10]; pCarrierEntryNo: Integer)
    var
        IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        ShippingAgentCode := pShippingAgentCode;
        ShippingAgentSvcCode := pShippingAgentSvcCode;

        IDYSShipAgentMapping.Get(ShippingAgentCode);
        IDYSProvider := IDYSShipAgentMapping.Provider;

        IDYSProviderBookingProfile.SetRange("Carrier Entry No.", pCarrierEntryNo);
        if IDYSProviderBookingProfile.FindSet() then
            repeat
                Rec.Init();
                Rec := IDYSProviderBookingProfile;
                Rec.Selected := IsSelected();
                Rec.Insert();
            until IDYSProviderBookingProfile.Next() = 0;
    end;

    local procedure IsSelected(): Boolean
    var
        IDYSvcBookingProfile: Record "IDYS Svc. Booking Profile";
    begin
        IDYSvcBookingProfile.SetRange("Shipping Agent Code", ShippingAgentCode);
        IDYSvcBookingProfile.SetRange("Shipping Agent Service Code", ShippingAgentSvcCode);
        IDYSvcBookingProfile.SetRange("Carrier Entry No.", Rec."Carrier Entry No.");
        IDYSvcBookingProfile.SetRange("Booking Profile Entry No.", Rec."Entry No.");
        exit(not IDYSvcBookingProfile.IsEmpty())
    end;

    local procedure ValidateRecSelected(Select: Boolean)
    var
        IDYSvcBookingProfile: Record "IDYS Svc. Booking Profile";
    begin
        if not Select then begin
            IDYSvcBookingProfile.SetRange("Shipping Agent Code", ShippingAgentCode);
            IDYSvcBookingProfile.SetRange("Shipping Agent Service Code", ShippingAgentSvcCode);
            IDYSvcBookingProfile.SetRange("Carrier Entry No.", Rec."Carrier Entry No.");
            IDYSvcBookingProfile.SetRange("Booking Profile Entry No.", Rec."Entry No.");
            IDYSvcBookingProfile.DeleteAll();
        end else begin
            IDYSvcBookingProfile.Init();
            IDYSvcBookingProfile.Validate("Shipping Agent Code", ShippingAgentCode);
            IDYSvcBookingProfile.Validate("Shipping Agent Service Code", ShippingAgentSvcCode);
            IDYSvcBookingProfile.Validate("Carrier Entry No.", Rec."Carrier Entry No.");
            IDYSvcBookingProfile.Validate("Booking Profile Entry No.", Rec."Entry No.");
            IDYSvcBookingProfile.Insert(true);
        end;
    end;

    var
        ShippingAgentCode: Code[10];
        ShippingAgentSvcCode: Code[10];
        IDYSProvider: Enum "IDYS Provider";
}