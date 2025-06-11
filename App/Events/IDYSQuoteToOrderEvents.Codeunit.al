codeunit 11147666 "IDYS Quote To Order Events"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnAfterInsertSalesOrderLine', '', true, false)]
    local procedure SalesQuotetoOrder_OnAfterInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line")
    var
        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        IDYSDocumentMgt.SetSalesLineQtyToSend(SalesOrderLine, SalesOrderLine."Qty. to Ship (Base)");
    end;

    [Obsolete('SalesHeaderFieldsRemainPopulatedOnOrder', '18.5')]
    procedure FillHeaderFields(var SalesQuoteHdr: Record "Sales Header"; var SalesOrderHdr: Record "Sales Header")
    begin
    end;

    var
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
}