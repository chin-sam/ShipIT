codeunit 11147651 "IDYS Sales Header Events"
{
    //most events have been moved to table extension

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopySellToCustomerAddressFieldsFromCustomer', '', true, false)]
    local procedure SalesHeader_OnAfterCopySellToCustomerAddressFieldsFromCustomer(var SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer)
    begin
        if SellToCustomer."IDYS E-Mail Type" <> '' then
            SalesHeader.Validate("IDYS E-Mail Type", SellToCustomer."IDYS E-Mail Type");
        SalesHeader.Validate("IDYS Cost Center", ''); //clear value: Will be set by Bill-to
        if (SalesHeader."IDYS Account No." = '') and (SellToCustomer."IDYS Account No." <> '') then
            SalesHeader.Validate("IDYS Account No.", SellToCustomer."IDYS Account No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr', '', true, false)]
    local procedure SalesHeader_OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr(var SalesHeader: Record "Sales Header"; ShipToAddress: Record "Ship-to Address")
    begin
        if (SalesHeader."IDYS E-Mail Type" = '') and (ShipToAddress."IDYS E-Mail Type" <> '') then //Only overwrite Sell-to E-Mail Type when specified on Ship-to
            SalesHeader.Validate("IDYS E-Mail Type", ShipToAddress."IDYS E-Mail Type");
        SalesHeader.Validate("IDYS Account No.", ShipToAddress."IDYS Account No.");
        SalesHeader.Validate("IDYS Cost Center", ShipToAddress."IDYS Cost Center");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterSetFieldsBilltoCustomer', '', true, false)]
    local procedure SalesHeader_OnAfterSetFieldsBilltoCustomer(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        if (SalesHeader."IDYS Cost Center" = '') and (Customer."IDYS Cost Center" <> '') then //Only overwrite Bill-to Cost Center when not specified on Ship-to
            SalesHeader.Validate("IDYS Cost Center", Customer."IDYS Cost Center");
        // To prevent inconsistencies in the current setup for existing customers:
        // The Account No. (Ship-to) should be populated with the Account No. (Bill-to) when the Account No. (Ship-to) remains empty.            
        if (SalesHeader."IDYS Account No." = '') and (Customer."IDYS Account No." <> '') then
            SalesHeader.Validate("IDYS Account No.", Customer."IDYS Account No.");
        SalesHeader.Validate("IDYS Account No. (Bill-to)", Customer."IDYS Account No.");
    end;
}