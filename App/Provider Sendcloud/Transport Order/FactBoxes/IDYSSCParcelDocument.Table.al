table 11147693 "IDYS SC Parcel Document"
{
    DataClassification = CustomerContent;
    Caption = 'Package Document';

    fields
    {
        field(1; "Transport Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Transport Order No.';
        }
        field(2; "Parcel Identifier"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Parcel Identifier';
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(4; "File Name"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'File Name';
        }
        field(5; "File"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'File';
        }
    }

    keys
    {
        key(PK; "Transport Order No.", "Parcel Identifier", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        IDYSSCParcelDocument: Record "IDYS SC Parcel Document";
    begin
        IDYSSCParcelDocument.SetRange("Transport Order No.", Rec."Transport Order No.");
        IDYSSCParcelDocument.SetRange("Parcel Identifier", Rec."Parcel Identifier");
        IDYSSCParcelDocument.SetCurrentKey("Line No.");
        IDYSSCParcelDocument.SetAscending("Line No.", true);
        if IDYSSCParcelDocument.FindLast() then
            "Line No." := IDYSSCParcelDocument."Line No." + 10000
        else
            "Line No." := 10000;
    end;
}