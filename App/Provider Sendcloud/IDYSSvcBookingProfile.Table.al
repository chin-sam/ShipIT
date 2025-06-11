table 11147702 "IDYS Svc. Booking Profile"
{
    DataClassification = CustomerContent;
    Caption = 'Shipping Agent Svc. Code Booking Profile';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            DataClassification = SystemMetadata;
        }

        field(2; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            NotBlank = true;
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
        }

        field(4; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = CustomerContent;
        }

        field(5; "Carrier Entry No."; Integer)
        {
            Caption = 'Carrier Entry No.';
            TableRelation = "IDYS Provider Carrier";
            DataClassification = CustomerContent;
        }
        field(6; "Booking Profile Entry No."; Integer)
        {
            Caption = 'Booking Profile Entry No.';
            TableRelation = "IDYS Provider Booking Profile";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key1; "Carrier Entry No.", "Booking Profile Entry No.")
        {
        }
    }

    trigger OnInsert()
    var
        IDYSvcBookingProfile: Record "IDYS Svc. Booking Profile";
    begin
        if IDYSvcBookingProfile.FindLast() then
            "Entry No." := IDYSvcBookingProfile."Entry No." + 1
        else
            "Entry No." := 1;
    end;
}