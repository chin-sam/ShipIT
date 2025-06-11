codeunit 11147656 "IDYS Service Header Events"
{
    //moved to table extension

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyCustomerFields', '', true, false)]
    local procedure ServiceHeader_OnAfterCopyCustomerFields(var ServiceHeader: Record "Service Header"; Customer: Record Customer)
    begin
        ServiceHeader.Validate("IDYS E-Mail Type", Customer."IDYS E-Mail Type");
        ServiceHeader.Validate("IDYS Cost Center", ''); //clear value: Will be set by Bill-to
        if (ServiceHeader."IDYS Account No." = '') and (Customer."IDYS Account No." <> '') then
            ServiceHeader.Validate("IDYS Account No.", Customer."IDYS Account No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr', '', true, false)]
    local procedure ServiceHeader_OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr(var ServiceHeader: Record "Service Header"; ShipToAddress: Record "Ship-to Address")
    begin
        if (ServiceHeader."IDYS E-Mail Type" = '') and (ShipToAddress."IDYS E-Mail Type" <> '') then //Only overwrite Sell-to E-Mail Type when specified on Ship-to
            ServiceHeader.Validate("IDYS E-Mail Type", ShipToAddress."IDYS E-Mail Type");
        ServiceHeader.Validate("IDYS Account No.", ShipToAddress."IDYS Account No.");
        ServiceHeader.Validate("IDYS Cost Center", ShipToAddress."IDYS Cost Center");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyBillToCustomerFields', '', true, false)]
    local procedure ServiceHeader_OnAfterCopyBillToCustomerFields(var ServiceHeader: Record "Service Header"; Customer: Record Customer)
    begin
        if (ServiceHeader."IDYS Cost Center" = '') and (Customer."IDYS Cost Center" <> '') then //Only overwrite Bill-to Cost Center when not specified on Ship-to
            ServiceHeader.Validate("IDYS Cost Center", Customer."IDYS Cost Center");
        // To prevent inconsistencies in the current setup for existing customers:
        // The Account No. (Ship-to) should be populated with the Account No. (Bill-to) when the Account No. (Ship-to) remains empty.            
        if (ServiceHeader."IDYS Account No." = '') and (Customer."IDYS Account No." <> '') then
            ServiceHeader.Validate("IDYS Account No.", Customer."IDYS Account No.");
        ServiceHeader.Validate("IDYS Account No. (Bill-to)", Customer."IDYS Account No.");

    end;
}