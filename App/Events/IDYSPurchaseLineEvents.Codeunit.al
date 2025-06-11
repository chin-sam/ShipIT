codeunit 11147654 "IDYS Purchase Line Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterSetDefaultQuantity', '', true, false)]
    local procedure PurchaseLine_OnAfterSetDefaultQuantity(var PurchLine: Record "Purchase Line"; var xPurchLine: Record "Purchase Line")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;
        case PurchLine."Document Type" of
            PurchLine."Document Type"::"Return Order":
                if PurchLine."Return Qty. to Ship (Base)" <> PurchLine."IDYS Quantity To Send" then
                    PurchLine.IDYSCalcAndUpdateQtyToSendToCarrier();
            PurchLine."Document Type"::Order:
                if PurchLine."Qty. to Receive (Base)" <> PurchLine."IDYS Quantity To Send" then
                    PurchLine.IDYSCalcAndUpdateQtyToSendToCarrier();
        end;
    end;

    var
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
}