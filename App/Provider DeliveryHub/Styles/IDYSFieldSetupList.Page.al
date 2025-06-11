page 11147717 "IDYS Field Setup List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "IDYS Field Setup";
    Caption = 'Field Setup List';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Table No.';
                    LookupPageId = "All Objects with Caption";
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Table Caption';
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Field No.';
                    trigger OnValidate()
                    begin
                        if Fld.Get(Rec."Table No.", Rec."Field No.") then begin
                            if Rec.Mandatory and (Fld.Type = Fld.Type::Boolean) then
                                Rec.FieldError(Mandatory, BooleanFieldTypeErr);
                            if (Rec."Max. Allowed Field Length" > 0) and (not (Fld.Type in [Fld.Type::Code, Fld.Type::Text])) then
                                Rec.FieldError("Max. Allowed Field Length", NotStringFieldTypeErr);
                        end;
                    end;
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Field Caption';
                }
                field("Max. Allowed Field Length"; Rec."Max. Allowed Field Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Max. Allowed Field Length';
                    trigger OnValidate()
                    begin
                        if Fld.Get(Rec."Table No.", Rec."Field No.") then
                            if not (Fld.Type in [Fld.Type::Code, Fld.Type::Text]) then
                                Rec.FieldError("Max. Allowed Field Length", NotStringFieldTypeErr);
                    end;
                }
                field("Style Expression"; Rec."Style Expression")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Style Expression when the field''s length is higher than the maximum allowed.';
                }
                field("Truncate Field Length"; Rec."Truncate Field Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates that the field''s value will be automatically truncated by Max. Allowed Field Length.';
                    Enabled = Rec."Max. Allowed Field Length" > 0;
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the field is Mandatory. Boolean fields can''t be Mandatory.';
                    trigger OnValidate()
                    begin
                        if Fld.Get(Rec."Table No.", Rec."Field No.") then
                            if Fld.Type = Fld.Type::Boolean then
                                Rec.FieldError(Mandatory, BooleanFieldTypeErr);
                    end;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Record Identifier" := NewRecordId;
    end;

    procedure SetGlobalValues(RecId: RecordId)
    begin
        NewRecordId := RecId;
    end;

    [Obsolete('Removed TableNo', '26.0')]
    procedure SetGlobalValues(RecId: RecordId; TableNo: Integer)
    begin
        SetGlobalValues(RecId);
    end;

    var
        Fld: Record Field;
        NewRecordId: RecordId;
        NotStringFieldTypeErr: Label 'is applicable only for the text and code type fields';
        BooleanFieldTypeErr: Label 'isn''t applicable for the boolean type fields';

}