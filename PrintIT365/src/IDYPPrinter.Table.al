table 11147840 "IDYP Printer"
{
    Caption = 'PrintIT Printer';
    LookupPageId = "IDYP Printers";

    fields
    {
        field(1; "Printer Id"; Integer)
        {
            Caption = 'Printer Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Printer Name"; Text[50])
        {
            Caption = 'Printer Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Default"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "State"; Text[50])
        {
            Caption = 'Printer State';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "File Filter"; Text[250])
        {
            Caption = 'File Filter';
            DataClassification = CustomerContent;
        }
        field(6; "Computer Hostname"; Text[250])
        {
            Caption = 'Computer Hostname';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Printer Id")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Computer Hostname", "Printer Id", "Printer Name")
        {
        }
    }
}