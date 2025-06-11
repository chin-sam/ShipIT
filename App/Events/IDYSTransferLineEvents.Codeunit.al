codeunit 11147655 "IDYS Transfer Line Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterValidateEvent', 'Quantity', true, false)]
    local procedure TransferLine_OnAfterValidateEvent_Quantity(var Rec: Record "Transfer Line")
    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if Rec.Quantity > 0 then
            if Rec."Quantity (Base)" < IDYSDocumentMgt.GetTransferLineQtySent(Rec) then
                Rec.FieldError("Quantity (Base)", StrSubstNo(CannotBeLessErr,
                                               Rec."Quantity (Base)",
                                               Rec.FieldCaption("IDYS Quantity Sent"),
                                               IDYSDocumentMgt.GetTransferLineQtySent(Rec)));
        if (Rec."Item No." <> '') or (Rec.Quantity > 0) then //LS Retail exception Quantity validated as 0 but Item No. is not populated
            Rec.IDYSCalcAndUpdateQtyToSendToCarrier();
    end;

    var
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        CannotBeLessErr: Label '%1 cannot be less than %2 %3.', Comment = '%1 = Quantity, %2 = Quantity Sent Caption, %3 = Quantity Sent.';
}