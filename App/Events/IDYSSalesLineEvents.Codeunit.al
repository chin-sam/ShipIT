codeunit 11147652 "IDYS Sales Line Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterSetDefaultQuantity', '', true, false)]
    local procedure SalesLine_OnAfterSetDefaultQuantity(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line")
    var
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;
        case SalesLine."Document Type" of
            SalesLine."Document Type"::Quote, SalesLine."Document Type"::Order:
                if SalesLine."Qty. to Ship (Base)" <> SalesLine."IDYS Quantity To Send" then
                    SalesLine.IDYSCalcAndUpdateQtyToSendToCarrier();
            SalesLine."Document Type"::"Return Order":
                if SalesLine."Return Qty. to Receive (Base)" <> SalesLine."IDYS Quantity To Send" then
                    SalesLine.IDYSCalcAndUpdateQtyToSendToCarrier();
        end;
    end;
}