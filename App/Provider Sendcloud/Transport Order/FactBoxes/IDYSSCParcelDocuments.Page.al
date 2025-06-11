page 11147711 "IDYS SC Parcel Documents"
{
    PageType = ListPart;
    SourceTable = "IDYS SC Parcel Document";
    Caption = 'Package Documents';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the documents file name.';

                    trigger OnDrillDown()
                    var
                        TempBlob: Codeunit "Temp Blob";
                        FileManagement: Codeunit "File Management";
                        OpenLabelQst: Label 'Do you wish to download the shipping label?';
                    begin
                        if GuiAllowed() and Rec."File".HasValue() then
                            if Confirm(OpenLabelQst) then begin
                                Rec.CalcFields(Rec."File");

                                TempBlob.FromRecord(Rec, Rec.FieldNo(Rec."File"));
                                FileManagement.BLOBExport(TempBlob, Rec."File Name", true);
                            end;
                    end;
                }
            }
        }
    }
}
