table 11147682 "IDYS SC Sender Address"
{
    DataClassification = CustomerContent;
    Caption = 'Sender Address';
    LookupPageId = "IDYS SC Sender Address List";
    DrillDownPageId = "IDYS SC Sender Address List";
    ObsoleteState = Pending;
    ObsoleteReason = 'Sender Address removed';
    ObsoleteTag = '21.0';

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Id';
        }
        field(2; "Company Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Company Name';
        }
        field(3; "Contact Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Contact Name';
        }
        field(4; Email; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Email';
        }
        field(5; Telephone; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Telephone';
        }
        field(6; Street; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Street';
        }
        field(7; "House Number"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'House No.';
        }
        field(8; "Postal Box"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Postal Box';
        }
        field(9; "Postal Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Postal Code';
        }
        field(10; City; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'City';
        }
        field(11; Country; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Country';
        }
        field(12; "VAT Number"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'VAT No.';
        }
        field(13; "EORI Number"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'EORI No.';
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Key2; Country) { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Id, "Company Name")
        {
        }
    }
}