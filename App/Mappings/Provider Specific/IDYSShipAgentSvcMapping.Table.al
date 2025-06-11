table 11147678 "IDYS Ship. Agent Svc. Mapping"
{
    Caption = 'Shipping Agent Service Mapping';
    DrillDownPageID = "IDYS Ship. Agent Svc. Mapping";
    LookupPageID = "IDYS Ship. Agent Svc. Mapping";

    fields
    {
        field(1; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            NotBlank = true;
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ShippingAgentMapping: Record "IDYS Ship. Agent Mapping";
            begin
                if not ShippingAgentMapping.Get("Shipping Agent Code") then
                    ShippingAgentMapping.Init();

                "Carrier Entry No." := ShippingAgentMapping."Carrier Entry No.";
            end;
        }

        field(2; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = CustomerContent;
        }

        field(3; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;
        }

        field(4; "Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            TableRelation = "IDYS Provider Booking Profile"."Entry No." where("Carrier Entry No." = field("Carrier Entry No."));
            DataClassification = CustomerContent;
        }

        field(5; "Shipping Agent Name"; Text[50])
        {
            CalcFormula = Lookup("Shipping Agent".Name where(Code = field("Shipping Agent Code")));
            Caption = 'Shipping Agent Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(6; "Shipping Agent Service Desc."; Text[100])
        {
            CalcFormula = Lookup("Shipping Agent Services".Description where("Shipping Agent Code" = field("Shipping Agent Code"),
                                                                              Code = field("Shipping Agent Service Code")));
            Caption = 'Shipping Agent Service Desc.';
            Editable = false;
            FieldClass = FlowField;
        }

        field(7; Provider; Enum "IDYS Provider")
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Provider where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Provider';
            Editable = false;
            FieldClass = FlowField;
        }

        field(8; "Booking Profile Description"; Text[150])
        {
            Caption = 'Booking Profile Description';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
                IDYSProviderBookingProfiles: Page "IDYS Provider Booking Profiles";
            begin
                CalcFields(Provider);

                IDYSProviderBookingProfile.SetRange("Carrier Entry No.", "Carrier Entry No.");
                IDYSProviderBookingProfile.SetRange(Provider, Provider);
                IDYSProviderBookingProfiles.SetTableView(IDYSProviderBookingProfile);
                IDYSProviderBookingProfiles.LookupMode(true);
                if IDYSProviderBookingProfiles.RunModal() = Action::LookupOK then begin
                    IDYSProviderBookingProfiles.GetRecord(IDYSProviderBookingProfile);
                    "Booking Profile Entry No." := IDYSProviderBookingProfile."Entry No.";
                    "Booking Profile Description" := IDYSProviderBookingProfile.Description;
                    SetDefaultServices();
                end;
            end;

            trigger OnValidate()
            var
                IDYSProviderBookingProfile: Record "IDYS Provider Booking Profile";
            begin
                if "Booking Profile Description" <> '' then begin
                    CalcFields(Provider);

                    IDYSProviderBookingProfile.SetRange("Carrier Entry No.", "Carrier Entry No.");
                    IDYSProviderBookingProfile.SetRange(Provider, Provider);
                    IDYSProviderBookingProfile.SetRange(Description, "Booking Profile Description");
                    if IDYSProviderBookingProfile.Count > 1 then
                        Error(MultipleProfilesFoundErr);
                    IDYSProviderBookingProfile.FindLast();
                    "Booking Profile Entry No." := IDYSProviderBookingProfile."Entry No.";
                    "Booking Profile Description" := IDYSProviderBookingProfile.Description;
                    SetDefaultServices();
                end else begin
                    ClearDefaultServices();
                    "Booking Profile Entry No." := 0
                end;
            end;
        }
        field(9; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Restructured with Sendcloud specific functionality.';
            ObsoleteTag = '24.0';
        }
        field(10; "Carrier Name"; Text[100])
        {
            CalcFormula = Lookup("IDYS Provider Carrier".Name where("Entry No." = field("Carrier Entry No.")));
            Caption = 'Name';
            Editable = false;
            FieldClass = FlowField;
        }
        #region [Transsmart]
        field(150; Insure; Boolean)
        {
            Caption = 'Insure';
            DataClassification = CustomerContent;
        }
        #endregion
    }

    keys
    {
        key(PK; "Shipping Agent Code", "Shipping Agent Service Code") { }
        key(key1; "Carrier Entry No.", "Booking Profile Entry No.") { }
    }

    trigger OnDelete()
    var
        IDYSSvcBookingProfile: Record "IDYS Svc. Booking Profile";
    begin
        IDYSSvcBookingProfile.SetRange("Shipping Agent Code", "Shipping Agent Code");
        IDYSSvcBookingProfile.SetRange("Shipping Agent Service Code", "Shipping Agent Service Code");
        IDYSSvcBookingProfile.DeleteAll();
    end;

    procedure SetDefaultServices()
    var
        IDYSDelHubAPIServices: Record "IDYS DelHub API Services";
        IDYSDelHubAPIDefService: Record "IDYS DelHub API Def. Service";
    begin
        ClearDefaultServices();

        IDYSDelHubAPIServices.SetRange("Carrier Entry No.", "Carrier Entry No.");
        IDYSDelHubAPIServices.SetRange("Booking Profile Entry No.", "Booking Profile Entry No.");
        IDYSDelHubAPIServices.SetAutoCalcFields("Is Default");
        if IDYSDelHubAPIServices.FindSet() then
            repeat
                IDYSDelHubAPIDefService.Init();
                IDYSDelHubAPIDefService.Validate("Shipping Agent Code", "Shipping Agent Code");
                IDYSDelHubAPIDefService.Validate("Shipping Agent Service Code", "Shipping Agent Service Code");
                IDYSDelHubAPIDefService.Validate("DelHub API Service Entry No.", IDYSDelHubAPIServices."Entry No.");
                IDYSDelHubAPIDefService.Validate("User Default", IDYSDelHubAPIServices."Is Default");
                IDYSDelHubAPIDefService.Insert(true);
            until IDYSDelHubAPIServices.Next() = 0;
    end;

    procedure ClearDefaultServices()
    var
        IDYSDelHubAPIDefService: Record "IDYS DelHub API Def. Service";
    begin
        IDYSDelHubAPIDefService.SetRange("Shipping Agent Code", "Shipping Agent Code");
        IDYSDelHubAPIDefService.SetRange("Shipping Agent Service Code", "Shipping Agent Service Code");
        IDYSDelHubAPIDefService.DeleteAll();
    end;

    var
        MultipleProfilesFoundErr: Label 'Multiple profiles found by the description field. Please use the assist edit button to select a booking profile.';
}