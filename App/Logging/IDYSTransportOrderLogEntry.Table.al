table 11147671 "IDYS Transport Order Log Entry"
{
    Caption = 'Transport Order Log Entry';
    LookupPageId = "IDYS Log Entry List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }

        field(2; "Transport Order No."; Code[20])
        {
            Caption = 'Transport Order No.';
            TableRelation = "IDYS Transport Order Header";
            DataClassification = CustomerContent;
        }

        field(3; "Date/Time"; DateTime)
        {
            Caption = 'Date/Time';
            DataClassification = CustomerContent;
        }

        field(4; "User ID"; Text[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                LoginMgt: Codeunit "User Management";
            begin
                LoginMgt.DisplayUserInformation("User ID");
            end;
        }

        field(5; Description; Text[150])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(6; "Level"; Enum "IDYS Logging Level")
        {
            DataClassification = SystemMetadata;
        }
        field(7; "JSON Request"; Blob)
        {
            Caption = 'Request';
            DataClassification = CustomerContent;
        }
        field(8; "JSON Response"; Blob)
        {
            Caption = 'Response';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {

        }

        key("Transport Order No."; "Transport Order No.")
        {
            MaintainSqlIndex = true;
            SqlIndex = "Transport Order No.";
        }
    }

    trigger OnInsert()
    begin
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
        "Date/Time" := CurrentDateTime();
    end;
}