table 11147839 "IDYP Setup"
{
    Caption = 'PrintIT Setup';
    LookupPageId = "IDYP Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "API Key"; Text[100])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}