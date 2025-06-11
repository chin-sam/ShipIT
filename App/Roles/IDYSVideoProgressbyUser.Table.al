table 11147692 "IDYS Video Progress by User"
{
    DataClassification = AccountData;
    Caption = 'Video Progress by User';
    DataPerCompany = false;
    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                LoginMgt: Codeunit "User Management";
            begin
                LoginMgt.DisplayUserInformation("User ID");
            end;

            trigger OnValidate()
            var
                LoginMgt: Codeunit "User Selection";
            begin
                LoginMgt.ValidateUserName("User ID");
            end;
        }
        field(3; Video; Enum "IDYS Embedded Video")
        {
            DataClassification = SystemMetadata;
            Caption = 'Video';
            NotBlank = true;
        }
        field(4; Watched; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Watched';
        }
    }

    keys
    {
        key(PK; "User ID", Video)
        {
            Clustered = true;
        }
    }
}