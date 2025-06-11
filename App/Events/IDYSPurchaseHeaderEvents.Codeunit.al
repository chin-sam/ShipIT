codeunit 11147653 "IDYS Purchase Header Events"
{
    //most events have been moved to table extension

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCopyBuyFromVendorFieldsFromVendor', '', true, false)]
    local procedure PurchaseHeader_OnAfterCopyBuyFromVendorFieldsFromVendor(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        if Vendor."IDYS E-Mail Type" <> '' then
            PurchaseHeader.Validate("IDYS E-Mail Type", Vendor."IDYS E-Mail Type");
        PurchaseHeader.Validate("IDYS Cost Center", ''); //clear value: Will be set by Bill-to
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCopyAddressInfoFromOrderAddress', '', true, false)]
    local procedure PurchaseHeader_OnAfterCopyAddressInfoFromOrderAddress(sender: Record "Purchase Header"; var OrderAddress: Record "Order Address")
    begin
        if (sender."IDYS E-Mail Type" = '') and (OrderAddress."IDYS E-Mail Type" <> '') then //Only overwrite Sell-to E-Mail Type when specified on Ship-to
            sender.Validate("IDYS E-Mail Type", OrderAddress."IDYS E-Mail Type");
        sender.Validate("IDYS Cost Center", OrderAddress."IDYS Cost Center");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCopyPayToVendorAddressFieldsFromVendor', '', true, false)]
    local procedure PurchaseHeader_OnAfterCopyPayToVendorAddressFieldsFromVendor(var PurchaseHeader: Record "Purchase Header"; PayToVendor: Record Vendor)
    begin
        if (PurchaseHeader."IDYS Cost Center" = '') and (PayToVendor."IDYS Cost Center" <> '') then //Only overwrite Bill-to Cost Center when not specified on Ship-to
            PurchaseHeader.Validate("IDYS Cost Center", PayToVendor."IDYS Cost Center");
    end;
}