codeunit 11147657 "IDYS Service Line Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterInitQtyToShip', '', true, false)]
    local procedure ServiceLine_OnAfterInitQtyToShip(var ServiceLine: Record "Service Line")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;
        if (ServiceLine.Type <> ServiceLine.Type::" ") and (ServiceLine."Document Type" <> ServiceLine."Document Type"::"Credit Memo") then
            ServiceLine.IDYSInitQtyToSendToCarrier();
    end;

    var
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
}