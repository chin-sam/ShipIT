table 11147688 "IDYS Setup Verification Result"
{
    Caption = 'Setup Verification Result';
    LookupPageId = "IDYS Setup Verification Result";

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        field(2; "Line Type"; Option)
        {
            Caption = 'Line Type';
            OptionCaption = 'Heading,Line';
            OptionMembers = Heading,Line;
            DataClassification = CustomerContent;
        }

        field(3; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(4; OK; Boolean)
        {
            Caption = 'OK';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
        }
    }
}