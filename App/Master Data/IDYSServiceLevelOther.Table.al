table 11147643 "IDYS Service Level (Other)"
{
    Caption = 'Service Level (Other)';
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "IDYS Service Levels (Other)";
    LookupPageID = "IDYS Service Levels (Other)";

    fields
    {
        field(1; "Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; Description; Text[128])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(3; "Is Default"; Boolean)
        {
            Caption = 'Is Default';
            DataClassification = CustomerContent;
        }
        #region [nShift Ship]
        field(4; "Service Code"; Code[50])
        {
            Caption = 'Service Code';
            DataClassification = CustomerContent;
        }
        field(10; ServiceID; Integer)
        {
            Caption = 'ServiceID';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(11; GroupId; Integer)
        {
            Caption = 'Group Id';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(12; "Read Only"; Boolean)
        {
            Caption = 'Readonly';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        #endregion
    }

    keys
    {
        key(PK; "Code")
        {
        }
        key(Key1; ServiceID) { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }
}