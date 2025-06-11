table 11147659 "IDYS Transport Order Report"
{
    Caption = 'Transport Order Report';
    LookupPageID = "IDYS Transport Order Reports";

    fields
    {
        field(1; "Transport Order No."; Code[20])
        {
            Caption = 'Transport Order No.';
            TableRelation = "IDYS Transport Order Header";
            DataClassification = CustomerContent;
        }

        field(2; ReportID; Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            DataClassification = CustomerContent;
        }

        field(3; ReportName; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Report),
                                                                           "Object ID" = field(ReportID)));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Transport Order No.", ReportID)
        {
        }
    }
}