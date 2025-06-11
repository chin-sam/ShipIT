table 11147841 "IDYP User Printer"
{
    Caption = 'PrintIT User Printer';
    LookupPageId = "IDYP User Printers";

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                User: Record User;
                UserLookup: Page "User Lookup";
            begin
                if "User ID" <> '' then begin
                    User.SetRange("User Name", "User ID");
                    if User.FindFirst() then begin
                        User.SetRange("User Name");
                        UserLookup.SetRecord(User);
                    end;
                end;
                UserLookup.LookupMode(true);
                if UserLookup.RunModal() = Action::LookupOK then begin
                    UserLookup.GetRecord(User);
                    Validate("User ID", User."User Name");
                end;
            end;
        }

        field(2; "Printer Id"; Integer)
        {
            Caption = 'Printer Id';
            DataClassification = CustomerContent;
            TableRelation = "IDYP Printer";
        }
        field(3; "Printer Name"; Text[50])
        {
            Caption = 'Printer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("IDYP Printer"."Printer Name" where("Printer Id" = field("Printer Id")));
            Editable = false;
        }
        field(10; "User Default"; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                UserPrinter: Record "IDYP User Printer";
            begin
                if "User Default" then begin
                    UserPrinter.SetFilter("User ID", "User ID");
                    UserPrinter.SetRange("User Default", true);
                    UserPrinter.ModifyAll("User Default", false);
                end;
            end;
        }
        field(11; "File Extension Filter"; Text[250])
        {
            Caption = 'File Extension Filter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "User ID", "Printer Id")
        {
        }
    }
}