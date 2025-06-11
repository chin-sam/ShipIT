codeunit 11147678 "IDYS Initialize"
{
    Access = Internal;

    internal procedure InitQtyOnExistingOrders()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Order");
        if SalesHeader.FindSet() then
            repeat
                SalesLine.setrange("Document No.", SalesHeader."No.");
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                SalesLine.SetRange("IDYS Quantity To Send", 0);
                if SalesLine.FindSet() then
                    repeat
                        if Item.get(SalesLine."No.") then begin
                            SalesLine."IDYS Quantity To Send" := SalesLine."Qty. to Ship (Base)";
                            SalesLine.Modify();
                        end;
                    until SalesLine.Next() = 0;
            until SalesHeader.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, false)]
    local procedure CompanyInitialize_OnCompanyInitialize()
    var
        IDYSShipITInstall: Codeunit "IDYS ShipIT Install";
    begin
        IDYSShipITInstall.RegisterEndPoints();
    end;
}
