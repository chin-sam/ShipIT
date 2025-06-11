tableextension 11147823 "IDYST Packing Station" extends "MOB Packing Station"
{
    fields
    {
        field(11147820; "IDYST User Name (External)"; Text[80])
        {
            Caption = 'User Name (External)';
            DataClassification = CustomerContent;
        }
        field(11147821; "IDYST Password (External)"; Text[80])
        {
            Caption = 'Password (External)';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(11147822; "IDYST Ticket Username"; Text[50])
        {
            Caption = 'Ticket Username';
            DataClassification = CustomerContent;
        }
        field(11147823; "IDYST Workstation ID"; Text[50])
        {
            Caption = 'Workstation ID';
            DataClassification = CustomerContent;
        }
        field(11147824; "IDYST DZ Label Printer Key"; Text[50])
        {
            Caption = 'Drop Zone Label Printer Key';
            DataClassification = CustomerContent;
        }
    }
}
