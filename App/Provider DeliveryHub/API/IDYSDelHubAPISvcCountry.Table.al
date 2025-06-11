table 11147666 "IDYS DelHub API Svc. Country"
{
    Caption = 'nShift Ship API Service Country';

    fields
    {
        field(1; "Service Entry No."; Integer)
        {
            Caption = 'Service Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(2; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            Editable = false;
            OptionMembers = "Ship-to","Ship-to (Denied)";
            OptionCaption = 'Ship-to,Ship-to (Denied)';
            DataClassification = CustomerContent;
        }

        field(3; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(20; "Country Code (API)"; Text[50])
        {
            Caption = 'Country Code (API)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "Country Code (Mapped)"; Code[10])
        {
            Caption = 'Country Code (Mapped)';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Service Entry No.", "Entry Type", "Entry No.")
        {
        }
    }

    trigger OnInsert()
    var
        IDYSDelHubAPISvcCountry: Record "IDYS DelHub API Svc. Country";
    begin
        IDYSDelHubAPISvcCountry.SetRange("Service Entry No.", "Service Entry No.");
        IDYSDelHubAPISvcCountry.SetRange("Entry Type", "Entry Type");
        if IDYSDelHubAPISvcCountry.FindLast() then
            "Entry No." := IDYSDelHubAPISvcCountry."Entry No." + 1
        else
            "Entry No." := 1;
    end;
}