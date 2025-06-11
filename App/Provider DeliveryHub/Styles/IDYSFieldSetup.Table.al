table 11147697 "IDYS Field Setup"
{
    Caption = 'Field Setup';
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }

        field(2; "Record Identifier"; RecordId)
        {
            Caption = 'Record Identifier';
            DataClassification = CustomerContent;
        }

        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table),
            "Object ID" = filter(11147669 | 11147670 | 11147672 | 11147660));
            DataClassification = CustomerContent;
        }

        field(11; "Table Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table No.")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            trigger OnLookup()
            var
                Fld: Record Field;
                FieldsLookup: Page "Fields Lookup";
            begin
                Fld.FilterGroup(10);
                Fld.SetRange(TableNo, "Table No.");
                Fld.SetRange(Enabled, true);
                Fld.SetFilter(ObsoleteState, '<>%1', Fld.ObsoleteState::Removed);
                Fld.FilterGroup(0);

                FieldsLookup.SetTableView(Fld);
                FieldsLookup.LookupMode := true;
                FieldsLookup.Editable := false;
                if FieldsLookup.RunModal() = Action::LookupOK then begin
                    FieldsLookup.GetRecord(Fld);
                    "Field No." := Fld."No.";
                end;
            end;
        }
        field(13; "Field Caption"; Text[250])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Table No."),
                                                              "No." = FIELD("Field No.")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Max. Allowed Field Length"; Integer)
        {
            Caption = 'Max. Allowed Field Length';
            DataClassification = CustomerContent;
        }
        field(15; "Style Expression"; Enum "IDYS Style Expression")
        {
            Caption = 'Style Expression';
            DataClassification = CustomerContent;
        }
        field(16; "Truncate Field Length"; Boolean)
        {
            Caption = 'Truncate Field Length';
            DataClassification = CustomerContent;
        }
        field(17; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(Key2; "Record Identifier", "Table No.", "Field No.")
        {
        }
    }

    trigger OnInsert()
    var
        IDYSFieldSetup: Record "IDYS Field Setup";
    begin
        if IDYSFieldSetup.FindLast() then
            "Entry No." := IDYSFieldSetup."Entry No." + 1
        else
            "Entry No." := 1;
    end;

    local procedure GetFieldSetup(RecId: RecordId; TableNo: Integer; FieldNo: Integer): Boolean;
    begin
        Clear(Rec);
        SetRange("Record Identifier", RecId);
        SetRange("Table No.", TableNo);
        SetRange("Field No.", FieldNo);
        if FindLast() then
            exit(true);
    end;

    procedure FindFieldSetup(RecId: RecordId; TableNo: Integer; FieldNo: Integer): Boolean;
    begin
        exit(GetFieldSetup(RecId, TableNo, FieldNo));
    end;

    procedure GetStyleExpr(RecId: RecordId; TableNo: Integer; FieldNo: Integer; CurrFieldLength: Integer): Text;
    begin
        if GetFieldSetup(RecId, TableNo, FieldNo) then
            if CurrFieldLength > "Max. Allowed Field Length" then
                exit(Format("Style Expression"));
    end;
}