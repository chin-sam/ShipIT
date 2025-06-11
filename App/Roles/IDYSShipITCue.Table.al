table 11147687 "IDYS ShipIT Cue"
{
    Caption = 'ShipIT Cue';
    LookupPageId = "IDYS ShipIT Cue";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }

        field(2; "Transport Orders - New"; Integer)
        {
            CalcFormula = Count("IDYS Transport Order Header" where(Status = const(New)));
            Caption = 'Transport Orders - New';
            Editable = false;
            FieldClass = FlowField;
        }

        field(3; "Transport Orders - Uploaded"; Integer)
        {
            CalcFormula = Count("IDYS Transport Order Header" where(Status = const(Uploaded)));
            Caption = 'Transport Orders - Uploaded';
            Editable = false;
            FieldClass = FlowField;
        }

        field(4; "Transport Orders - Booked"; Integer)
        {
            CalcFormula = Count("IDYS Transport Order Header" where(Status = const(Booked)));
            Caption = 'Transport Orders - Booked';
            Editable = false;
            FieldClass = FlowField;
        }

        field(5; "Tpt. Orders - Label Printed"; Integer)
        {
            CalcFormula = Count("IDYS Transport Order Header" where(Status = const("Label Printed")));
            Caption = 'Tpt. Orders - Label Printed';
            Editable = false;
            FieldClass = FlowField;
        }

        field(6; "Transport Orders - Recalled"; Integer)
        {
            CalcFormula = Count("IDYS Transport Order Header" where(Status = const(Recalled)));
            Caption = 'Transport Orders - Recalled';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Transport Orders - Error"; Integer)
        {
            CalcFormula = Count("IDYS Transport Order Header" where(Status = const(Error)));
            Caption = 'Transport Orders - Error';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Transport Orders - Done"; Integer)
        {
            CalcFormula = Count("IDYS Transport Order Header" where(Status = const(Done)));
            Caption = 'Transport Orders - Done';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Transport Orders - On Hold"; Integer)
        {
            CalcFormula = Count("IDYS Transport Order Header" where(Status = const("On Hold")));
            Caption = 'Transport Orders - On Hold';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
        }
    }
}