codeunit 11147679 "IDYS Transport Order Hdr. Mgt."
{
    procedure GetExternalCountryCode(CountryCode: Code[10]): Code[10];
    var
        CountryRegionMapping: Record "IDYS Country/Region Mapping";
    begin
        if CountryCode = '' then
            exit('');

        if not CountryRegionMapping.Get(CountryCode) then
            Error(ThereIsNoErr, CountryRegionMapping.TableCaption(), CountryRegionMapping.FieldCaption("Country/Region Code"), CountryCode);

        CountryRegionMapping.TestField("Country/Region Code (External)");
        exit(CountryRegionMapping."Country/Region Code (External)");
    end;

    procedure GetExternalCurrencyCode(CurrencyCode: Code[10]): Code[10];
    var
        CurrencyMapping: Record "IDYS Currency Mapping";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not CurrencyMapping.Get(CurrencyCode) then
            if CurrencyCode = '' then begin //LCY Currency doesn't have to exist as a currency and therefore also not as a mapping
                GeneralLedgerSetup.Get();
                if not CurrencyMapping.Get(GeneralLedgerSetup."LCY Code") then
                    exit(GeneralLedgerSetup."LCY Code");
            end else
                Error(ThereIsNoErr, CurrencyMapping.TableCaption(), CurrencyMapping.FieldCaption("Currency Code"), CurrencyCode);
        CurrencyMapping.TestField("Currency Code (External)");
        exit(CurrencyMapping."Currency Code (External)");
    end;

    procedure GetCurrencyCode(ExternalCurrencyCode: Code[10]): Code[10];
    var
        CurrencyMapping: Record "IDYS Currency Mapping";
    begin
        CurrencyMapping.SetRange("Currency Code (External)", ExternalCurrencyCode);
        if not CurrencyMapping.FindLast() then
            Error(ThereIsNoErr, CurrencyMapping.TableCaption(), CurrencyMapping.FieldCaption("Currency Code (External)"), ExternalCurrencyCode);
        exit(CurrencyMapping."Currency Code");
    end;

    procedure SplitAddress(Address: Text; var Street: Text; var HouseNo: Text)
    var
        CharPosition: Integer;
        SecondCharPosition: Integer;
        Digit: Integer;
    begin
        if Address = '' then
            exit;
        if CopyStr(Address, StrLen(Address), 1) in [' ', ','] then
            Address := CopyStr(Address, 1, StrLen(Address) - 1);
        Street := '';
        HouseNo := '';
        if (not Address.Contains('1')) and
           (not Address.Contains('2')) and
           (not Address.Contains('3')) and
           (not Address.Contains('4')) and
           (not Address.Contains('5')) and
           (not Address.Contains('6')) and
           (not Address.Contains('7')) and
           (not Address.Contains('8')) and
           (not Address.Contains('9')) and
           (not Address.Contains('0'))
        then begin
            Street := Address;
            exit;
        end;

        //search first digit in the address (this is most likely the HouseNo)
        CharPosition := 1;
        while not Evaluate(Digit, CopyStr(Address, CharPosition, 1))
        do
            CharPosition += 1;

        if CharPosition = 1 then begin
            //when the address starts with a digit then it can be a HouseNo but it can also be part of the streetname:
            //10 Downing Street OR
            //11th street, 1e dwarsstraat)

            //find the sequence of digits at the beginning of the address
            SecondCharPosition := 1;
            while Evaluate(Digit, CopyStr(Address, SecondCharPosition, 1))
            do
                SecondCharPosition += 1;

            if SecondCharPosition > StrLen(Address) then begin
                HouseNo := Address;
                Street := '';
                exit;
            end;

            if CopyStr(Address, SecondCharPosition, 1) in [' ', ','] then begin
                //when the next character after the digits is a space then it's a HouseNo
                HouseNo := CopyStr(Address, 1, SecondCharPosition - 1);
                Street := CopyStr(Address, SecondCharPosition + 1, StrLen(Address) - SecondCharPosition);
                exit;
            end else begin
                //otherwise its part of the Street
                //search for a second sequence of digits for the HouseNo
                CharPosition := SecondCharPosition;
                while (not Evaluate(Digit, CopyStr(Address, CharPosition, 1))) and (CharPosition <= StrLen(Address))
                do
                    CharPosition += 1;
            end;
        end;
        if CharPosition <= StrLen(Address) then
            HouseNo := CopyStr(Address, CharPosition, StrLen(Address) - CharPosition + 1);
        if CharPosition <> 1 then
            Street := CopyStr(Address, 1, CharPosition - 1);
        if Street <> '' then
            if CopyStr(Street, StrLen(Street), 1) in [' ', ','] then
                Street := CopyStr(Street, 1, StrLen(Street) - 1);
    end;

    procedure UpdateCurrencies(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    begin
        // Updates the NAV currency fields based on the Transsmart currency fields.
        // Typically called directly after deserializing a transport order.

        IDYSTransportOrderHeader."Shipment Value Curr Code" := GetNavCurrencyCode(IDYSTransportOrderHeader."Shipmt. Value Curr Code (TS)");
        IDYSTransportOrderHeader."Shipment Cost Curr Code" := GetNavCurrencyCode(IDYSTransportOrderHeader."Shipmt. Cost Curr Code (TS)");
        IDYSTransportOrderHeader."Spot Price Curr Code" := GetNavCurrencyCode(IDYSTransportOrderHeader."Spot Price Curr Code (TS)");
    end;

    procedure UpdateDeliveryDate(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IDYSCalendarManagement: Codeunit "IDYS Calendar Management";
    begin
        if IDYSTransportOrderHeader."Preferred Delivery Date" = 0D then begin
            IDYSTransportOrderHeader.Validate("Preferred Delivery Date From", 0DT);
            IDYSTransportOrderHeader.Validate("Preferred Delivery Date To", 0DT);
            exit;
        end;
        IDYSTransportOrderHeader.Validate("Preferred Delivery Date From", IDYSCalendarManagement.CalculateDeliveryFromDateTime(IDYSTransportOrderHeader));
        IDYSTransportOrderHeader.Validate("Preferred Delivery Date To", IDYSCalendarManagement.CalculateDeliveryToDateTime(IDYSTransportOrderHeader));
    end;

    procedure UpdatePickupDate(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        IDYSCalendarManagement: Codeunit "IDYS Calendar Management";
    begin
        if IDYSTransportOrderHeader."Preferred Pick-up Date" = 0D then begin
            IDYSTransportOrderHeader.Validate("Preferred Pick-up Date From", 0DT);
            IDYSTransportOrderHeader.Validate("Preferred Pick-up Date To", 0DT);
            exit;
        end;
        IDYSTransportOrderHeader.Validate("Preferred Pick-up Date From", IDYSCalendarManagement.CalculatePickupFromDateTime(IDYSTransportOrderHeader));
        IDYSTransportOrderHeader.Validate("Preferred Pick-up Date To", IDYSCalendarManagement.CalculatePickupToDateTime(IDYSTransportOrderHeader));

        if (IDYSTransportOrderHeader."Preferred Pick-up Date" <> 0D) and (IDYSTransportOrderHeader."Shipping Agent Service Code" <> '') then begin
            ShippingAgentServices.Get(IDYSTransportOrderHeader."Shipping Agent Code", IDYSTransportOrderHeader."Shipping Agent Service Code");
            IDYSTransportOrderHeader.Validate("Preferred Delivery Date", CalcDate(ShippingAgentServices."Shipping Time", IDYSTransportOrderHeader."Preferred Pick-up Date"));
        end else
            IDYSTransportOrderHeader.Validate("Preferred Delivery Date", CalcDate('<+1D>', IDYSTransportOrderHeader."Preferred Pick-up Date"));
    end;

    procedure UpdatePickupAddress(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        ShipToAddress: Record "Ship-to Address";
        OrderAddress: Record "Order Address";
        Location: Record Location;
        CompanyInformation: Record "Company Information";
    begin
        ClearAddressFields(IDYSTransportOrderHeader, "IDYS Address Type"::"Pick-up");
        case IDYSTransportOrderHeader."Source Type (Pick-up)" of
            IDYSTransportOrderHeader."Source Type (Pick-up)"::Customer:
                if IDYSTransportOrderHeader."Code (Pick-up)" <> '' then begin
                    ShipToAddress.Get(IDYSTransportOrderHeader."No. (Pick-up)", IDYSTransportOrderHeader."Code (Pick-up)");
                    TransferAddressFieldsFromShipToAddress(IDYSTransportOrderHeader, ShipToAddress, "IDYS Address Type"::"Pick-up");
                end else
                    if IDYSTransportOrderHeader."No. (Pick-up)" <> '' then begin
                        Customer.Get(IDYSTransportOrderHeader."No. (Pick-up)");
                        TransferAddressFieldsFromCustomer(IDYSTransportOrderHeader, Customer, "IDYS Address Type"::"Pick-up");
                    end;
            IDYSTransportOrderHeader."Source Type (Pick-up)"::Vendor:
                if IDYSTransportOrderHeader."Code (Pick-up)" <> '' then begin
                    OrderAddress.Get(IDYSTransportOrderHeader."No. (Pick-up)", IDYSTransportOrderHeader."Code (Pick-up)");
                    TransferAddressFieldsFromOrderAddress(IDYSTransportOrderHeader, OrderAddress, "IDYS Address Type"::"Pick-up");
                end else
                    if IDYSTransportOrderHeader."No. (Pick-up)" <> '' then begin
                        Vendor.Get(IDYSTransportOrderHeader."No. (Pick-up)");
                        TransferAddressFieldsFromVendor(IDYSTransportOrderHeader, Vendor, "IDYS Address Type"::"Pick-up");
                    end;
            IDYSTransportOrderHeader."Source Type (Pick-up)"::Location:
                if IDYSTransportOrderHeader."No. (Pick-up)" <> '' then begin
                    Location.Get(IDYSTransportOrderHeader."No. (Pick-up)");
                    TransferAddressFieldsFromLocation(IDYSTransportOrderHeader, Location, "IDYS Address Type"::"Pick-up");
                end;
            IDYSTransportOrderHeader."Source Type (Pick-up)"::Company:
                begin
                    CompanyInformation.Get();
                    TransferAddressFieldsFromCompanyInfo(IDYSTransportOrderHeader, CompanyInformation, "IDYS Address Type"::"Pick-up");
                end;
        end;
    end;

    procedure UpdateShipToAddress(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        ShipToAddress: Record "Ship-to Address";
        OrderAddress: Record "Order Address";
        Location: Record Location;
        CompanyInformation: Record "Company Information";
    begin
        ClearAddressFields(IDYSTransportOrderHeader, "IDYS Address Type"::"Ship-to");
        case IDYSTransportOrderHeader."Source Type (Ship-to)" of
            IDYSTransportOrderHeader."Source Type (Ship-to)"::Customer:
                if IDYSTransportOrderHeader."Code (Ship-to)" <> '' then begin
                    ShipToAddress.Get(IDYSTransportOrderHeader."No. (Ship-to)", IDYSTransportOrderHeader."Code (Ship-to)");
                    TransferAddressFieldsFromShipToAddress(IDYSTransportOrderHeader, ShipToAddress, "IDYS Address Type"::"Ship-to");
                end else
                    if IDYSTransportOrderHeader."No. (Ship-to)" <> '' then begin
                        Customer.Get(IDYSTransportOrderHeader."No. (Ship-to)");
                        TransferAddressFieldsFromCustomer(IDYSTransportOrderHeader, Customer, "IDYS Address Type"::"Ship-to");
                    end;
            IDYSTransportOrderHeader."Source Type (Ship-to)"::Vendor:
                if IDYSTransportOrderHeader."Code (Ship-to)" <> '' then begin
                    OrderAddress.Get(IDYSTransportOrderHeader."No. (Ship-to)", IDYSTransportOrderHeader."Code (Ship-to)");
                    TransferAddressFieldsFromOrderAddress(IDYSTransportOrderHeader, OrderAddress, "IDYS Address Type"::"Ship-to");
                end else
                    if IDYSTransportOrderHeader."No. (Ship-to)" <> '' then begin
                        Vendor.Get(IDYSTransportOrderHeader."No. (Ship-to)");
                        TransferAddressFieldsFromVendor(IDYSTransportOrderHeader, Vendor, "IDYS Address Type"::"Ship-to");
                    end;
            IDYSTransportOrderHeader."Source Type (Ship-to)"::Location:
                if IDYSTransportOrderHeader."No. (Ship-to)" <> '' then begin
                    Location.Get(IDYSTransportOrderHeader."No. (Ship-to)");
                    TransferAddressFieldsFromLocation(IDYSTransportOrderHeader, Location, "IDYS Address Type"::"Ship-to");
                end;
            IDYSTransportOrderHeader."Source Type (Ship-to)"::Company:
                begin
                    CompanyInformation.Get();
                    TransferAddressFieldsFromCompanyInfo(IDYSTransportOrderHeader, CompanyInformation, "IDYS Address Type"::"Ship-to");
                end;
        end;
    end;

    procedure UpdateInvoiceAddress(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header");
    var
        Customer: Record Customer;
        CompanyInformation: Record "Company Information";
    begin
        ClearAddressFields(IDYSTransportOrderHeader, "IDYS Address Type"::Invoice);
        case IDYSTransportOrderHeader."Source Type (Invoice)" of
            IDYSTransportOrderHeader."Source Type (Invoice)"::Customer:
                begin
                    if not Customer.Get(IDYSTransportOrderHeader."No. (Invoice)") then
                        Customer.Init();
                    TransferAddressFieldsFromCustomer(IDYSTransportOrderHeader, Customer, "IDYS Address Type"::Invoice);
                end;
            IDYSTransportOrderHeader."Source Type (Invoice)"::Company:
                begin
                    CompanyInformation.Get();
                    TransferAddressFieldsFromCompanyInfo(IDYSTransportOrderHeader, CompanyInformation, "IDYS Address Type"::Invoice);
                    exit;
                end;
        end;
    end;

    local procedure ClearAddressFields(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; IDYSAddressType: Enum "IDYS Address Type")
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Pick-up)", '');
                    IDYSTransportOrderHeader.Validate("Address (Pick-up)", '');
                    IDYSTransportOrderHeader.Validate("Address 2 (Pick-up)", '');
                    IDYSTransportOrderHeader."Post Code (Pick-up)" := '';
                    IDYSTransportOrderHeader."City (Pick-up)" := '';
                    IDYSTransportOrderHeader."County (Pick-up)" := '';
                    IDYSTransportOrderHeader."Country/Region Code (Pick-up)" := '';
                    IDYSTransportOrderHeader."Cntry/Rgn. Code (Pick-up) (TS)" := '';
                    IDYSTransportOrderHeader.Validate("Contact (Pick-up)", '');
                    IDYSTransportOrderHeader.Validate("Phone No. (Pick-up)", '');
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Pick-up)", '');
                    IDYSTransportOrderHeader.Validate("Fax No. (Pick-up)", '');
                    IDYSTransportOrderHeader.Validate("E-Mail (Pick-up)", '');
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Pick-up)", '');
                    IDYSTransportOrderHeader.Validate("Account No. (Pick-up)", '');
                end;
            IDYSAddressType::"Ship-to":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Ship-to)", '');
                    IDYSTransportOrderHeader.Validate("Address (Ship-to)", '');
                    IDYSTransportOrderHeader.Validate("Address 2 (Ship-to)", '');
                    IDYSTransportOrderHeader."Post Code (Ship-to)" := '';
                    IDYSTransportOrderHeader."City (Ship-to)" := '';
                    IDYSTransportOrderHeader."County (Ship-to)" := '';
                    IDYSTransportOrderHeader."Country/Region Code (Ship-to)" := '';
                    IDYSTransportOrderHeader."Cntry/Rgn. Code (Ship-to) (TS)" := '';
                    IDYSTransportOrderHeader.Validate("Contact (Ship-to)", '');
                    IDYSTransportOrderHeader.Validate("Phone No. (Ship-to)", '');
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Ship-to)", '');
                    IDYSTransportOrderHeader.Validate("Fax No. (Ship-to)", '');
                    IDYSTransportOrderHeader.Validate("E-Mail (Ship-to)", '');
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Ship-to)", '');
                    IDYSTransportOrderHeader.Validate("E-Mail Type", '');
                    IDYSTransportOrderHeader.Validate("Cost Center", '');
                    IDYSTransportOrderHeader.Validate("Account No.", '');  // Ship-to
                    IDYSTransportOrderHeader.Validate("Recipient PO Box No.", '');
                end;
            IDYSAddressType::Invoice:
                begin
                    IDYSTransportOrderHeader.Validate("Name (Invoice)", '');
                    IDYSTransportOrderHeader.Validate("Address (Invoice)", '');
                    IDYSTransportOrderHeader.Validate("Address 2 (Invoice)", '');
                    IDYSTransportOrderHeader."Post Code (Invoice)" := '';
                    IDYSTransportOrderHeader."City (Invoice)" := '';
                    IDYSTransportOrderHeader."County (Invoice)" := '';
                    IDYSTransportOrderHeader."Country/Region Code (Invoice)" := '';
                    IDYSTransportOrderHeader."Cntry/Rgn. Code (Invoice) (TS)" := '';
                    IDYSTransportOrderHeader.Validate("Contact (Invoice)", '');
                    IDYSTransportOrderHeader.Validate("Phone No. (Invoice)", '');
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Invoice)", '');
                    IDYSTransportOrderHeader.Validate("Fax No. (Invoice)", '');
                    IDYSTransportOrderHeader.Validate("E-Mail (Invoice)", '');
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Invoice)", '');
                    IDYSTransportOrderHeader.Validate("Account No. (Invoice)", '');
                end;
        end;
        OnAfterClearAddressFields(IDYSTransportOrderHeader, IDYSAddressType);
    end;

    local procedure GetNavCurrencyCode(ExternalCurrencyCode: Code[10]): Code[10];
    var
        CurrencyMapping: Record "IDYS Currency Mapping";
    begin
        if ExternalCurrencyCode = '' then
            exit('');

        CurrencyMapping.SetCurrentKey("Currency Code (External)");
        CurrencyMapping.SetRange("Currency Code (External)", ExternalCurrencyCode);

        if not CurrencyMapping.FindFirst() then
            Error(
              ThereIsNoErr,
              CurrencyMapping.TableCaption(),
              CurrencyMapping.FieldCaption("Currency Code (External)"),
              ExternalCurrencyCode);

        exit(CurrencyMapping."Currency Code");
    end;

    local procedure TransferAddressFieldsFromCompanyInfo(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; CompanyInformation: Record "Company Information"; IDYSAddressType: Enum "IDYS Address Type")
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Pick-up)", CompanyInformation.Name);
                    IDYSTransportOrderHeader.Validate("Address (Pick-up)", CompanyInformation.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Pick-up)", CompanyInformation."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Pick-up)", CompanyInformation."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Pick-up)", CompanyInformation.City);
                    IDYSTransportOrderHeader.Validate("County (Pick-up)", CompanyInformation.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Pick-up)", CompanyInformation."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Pick-up)", CompanyInformation."Contact Person");
                    IDYSTransportOrderHeader.Validate("Phone No. (Pick-up)", CompanyInformation."Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Pick-up)", CompanyInformation."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Pick-up)", CompanyInformation."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Pick-up)", CompanyInformation."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Account No. (Pick-up)", CompanyInformation."IDYS Account No.");
#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Pick-up)", CompanyInformation."EORI Number");
#endif
                end;
            IDYSAddressType::"Ship-to":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Ship-to)", CompanyInformation.Name);
                    IDYSTransportOrderHeader.Validate("Address (Ship-to)", CompanyInformation.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Ship-to)", CompanyInformation."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Ship-to)", CompanyInformation."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Ship-to)", CompanyInformation.City);
                    IDYSTransportOrderHeader.Validate("County (Ship-to)", CompanyInformation.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Ship-to)", CompanyInformation."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Ship-to)", CompanyInformation."Contact Person");
                    IDYSTransportOrderHeader.Validate("Phone No. (Ship-to)", CompanyInformation."Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Ship-to)", CompanyInformation."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Ship-to)", CompanyInformation."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Ship-to)", CompanyInformation."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Account No.", CompanyInformation."IDYS Account No.");

#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Ship-to)", CompanyInformation."EORI Number");
#endif
                end;
            IDYSAddressType::Invoice:
                begin
                    IDYSTransportOrderHeader.Validate("Name (Invoice)", CompanyInformation.Name);
                    IDYSTransportOrderHeader.Validate("Address (Invoice)", CompanyInformation.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Invoice)", CompanyInformation."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Invoice)", CompanyInformation."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Invoice)", CompanyInformation.City);
                    IDYSTransportOrderHeader.Validate("County (Invoice)", CompanyInformation.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Invoice)", CompanyInformation."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Invoice)", CompanyInformation."Contact Person");
                    IDYSTransportOrderHeader.Validate("Phone No. (Invoice)", CompanyInformation."Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Invoice)", CompanyInformation."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Invoice)", CompanyInformation."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Invoice)", CompanyInformation."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Account No. (Invoice)", CompanyInformation."IDYS Account No.");
#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Invoice)", CompanyInformation."EORI Number");
#endif
                end;
        end;
        OnAfterTransferAddressFieldsFromCompanyInfo(IDYSTransportOrderHeader, CompanyInformation, IDYSAddressType);
    end;

    local procedure TransferAddressFieldsFromCustomer(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Customer: Record Customer; IDYSAddressType: Enum "IDYS Address Type")
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Pick-up)", Customer.Name);
                    IDYSTransportOrderHeader.Validate("Address (Pick-up)", Customer.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Pick-up)", Customer."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Pick-up)", Customer."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Pick-up)", Customer.City);
                    IDYSTransportOrderHeader.Validate("County (Pick-up)", Customer.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Pick-up)", Customer."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Pick-up)", Customer.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Pick-up)", Customer."Phone No.");
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Pick-up)", Customer."Mobile Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Pick-up)", Customer."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Pick-up)", Customer."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Pick-up)", Customer."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Account No. (Pick-up)", Customer."IDYS Account No.");
#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Pick-up)", Customer."EORI Number");
#endif
                end;
            IDYSAddressType::"Ship-to":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Ship-to)", Customer.Name);
                    IDYSTransportOrderHeader.Validate("Address (Ship-to)", Customer.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Ship-to)", Customer."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Ship-to)", Customer."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Ship-to)", Customer.City);
                    IDYSTransportOrderHeader.Validate("County (Ship-to)", Customer.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Ship-to)", Customer."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Ship-to)", Customer.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Ship-to)", Customer."Phone No.");
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Ship-to)", Customer."Mobile Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Ship-to)", Customer."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Ship-to)", Customer."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Ship-to)", Customer."VAT Registration No.");

#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Ship-to)", Customer."EORI Number");
#endif
                    IDYSTransportOrderHeader.Validate("E-Mail Type", Customer."IDYS E-Mail Type");
                    IDYSTransportOrderHeader.Validate("Cost Center", Customer."IDYS Cost Center");
                    IDYSTransportOrderHeader.Validate("Account No.", Customer."IDYS Account No.");
                end;
            IDYSAddressType::Invoice:
                begin
                    IDYSTransportOrderHeader.Validate("Name (Invoice)", Customer.Name);
                    IDYSTransportOrderHeader.Validate("Address (Invoice)", Customer.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Invoice)", Customer."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Invoice)", Customer."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Invoice)", Customer.City);
                    IDYSTransportOrderHeader.Validate("County (Invoice)", Customer.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Invoice)", Customer."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Invoice)", Customer.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Invoice)", Customer."Phone No.");
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Invoice)", Customer."Mobile Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Invoice)", Customer."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Invoice)", Customer."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Invoice)", Customer."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Account No. (Invoice)", Customer."IDYS Account No.");
                end;
        end;
        OnAfterTransferAddressFieldsFromCustomer(IDYSTransportOrderHeader, Customer, IDYSAddressType);
    end;

    local procedure TransferAddressFieldsFromLocation(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Location: Record Location; IDYSAddressType: Enum "IDYS Address Type")
    var
        CompanyInformation: Record "Company Information";
        IDYSProviderSetup: Record "IDYS Provider Setup";
        IDYSTranssmartSetup: Record "IDYS Setup";
    begin
        CompanyInformation.Get();
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Pick-up)", Location.Name);
                    IDYSTransportOrderHeader.Validate("Address (Pick-up)", Location.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Pick-up)", Location."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Pick-up)", Location."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Pick-up)", Location.City);
                    IDYSTransportOrderHeader.Validate("County (Pick-up)", Location.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Pick-up)", Location."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Pick-up)", Location.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Pick-up)", Location."Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Pick-up)", Location."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Pick-up)", Location."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Pick-up)", CompanyInformation."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Cost Center", Location."IDYS Cost Center");
                    IDYSTransportOrderHeader.Validate("E-Mail Type", Location."IDYS E-Mail Type");
                    IDYSTransportOrderHeader.Validate("Account No. (Pick-up)", Location."IDYS Account No.");
                    if IDYSProviderSetup.Get("IDYS Provider"::Transsmart) and IDYSProviderSetup.Enabled then begin
                        IDYSTranssmartSetup.GetProviderSetup("IDYS Provider"::Transsmart);
                        if (IDYSTransportOrderHeader."Cost Center" = '') and (IDYSTranssmartSetup."Default Cost Center" <> '') then
                            IDYSTransportOrderHeader.Validate("Cost Center", IDYSTranssmartSetup."Default Cost Center");
                        if (IDYSTransportOrderHeader."E-Mail Type" = '') and (IDYSTranssmartSetup."Default E-Mail Type" <> '') then
                            IDYSTransportOrderHeader.Validate("E-Mail Type", IDYSTranssmartSetup."Default E-Mail Type");
                    end;
#if not BC17EORI
                    if Location."IDYS EORI Number" <> '' then
                        IDYSTransportOrderHeader.Validate("EORI Number (Pick-up)", Location."IDYS EORI Number")
                    else
                        IDYSTransportOrderHeader.Validate("EORI Number (Pick-up)", CompanyInformation."EORI Number");
#endif
                end;
            IDYSAddressType::"Ship-to":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Ship-to)", Location.Name);
                    IDYSTransportOrderHeader.Validate("Address (Ship-to)", Location.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Ship-to)", Location."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Ship-to)", Location."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Ship-to)", Location.City);
                    IDYSTransportOrderHeader.Validate("County (Ship-to)", Location.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Ship-to)", Location."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Ship-to)", Location.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Ship-to)", Location."Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Ship-to)", Location."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Ship-to)", Location."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Ship-to)", CompanyInformation."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Account No.", Location."IDYS Account No.");
#if not BC17EORI
                    if Location."IDYS EORI Number" <> '' then
                        IDYSTransportOrderHeader.Validate("EORI Number (Ship-to)", Location."IDYS EORI Number")
                    else
                        IDYSTransportOrderHeader.Validate("EORI Number (Ship-to)", CompanyInformation."EORI Number");
#endif
                end;
        end;
        OnAfterTransferAddressFieldsFromLocation(IDYSTransportOrderHeader, Location, IDYSAddressType);
    end;

    local procedure TransferAddressFieldsFromOrderAddress(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; OrderAddress: Record "Order Address"; IDYSAddressType: Enum "IDYS Address Type")
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(OrderAddress."Vendor No.");
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Pick-up)", OrderAddress.Name);
                    IDYSTransportOrderHeader.Validate("Address (Pick-up)", OrderAddress.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Pick-up)", OrderAddress."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Pick-up)", OrderAddress."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Pick-up)", OrderAddress.City);
                    IDYSTransportOrderHeader.Validate("County (Pick-up)", OrderAddress.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Pick-up)", OrderAddress."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Pick-up)", OrderAddress.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Pick-up)", OrderAddress."Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Pick-up)", OrderAddress."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Pick-up)", OrderAddress."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Pick-up)", Vendor."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Pick-up)", Vendor."Mobile Phone No.");
#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Pick-up)", Vendor."EORI Number");
#endif
                end;
            IDYSAddressType::"Ship-to":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Ship-to)", OrderAddress.Name);
                    IDYSTransportOrderHeader.Validate("Address (Ship-to)", OrderAddress.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Ship-to)", OrderAddress."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Ship-to)", OrderAddress."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Ship-to)", OrderAddress.City);
                    IDYSTransportOrderHeader.Validate("County (Ship-to)", OrderAddress.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Ship-to)", OrderAddress."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Ship-to)", OrderAddress.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Ship-to)", OrderAddress."Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Ship-to)", OrderAddress."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Ship-to)", OrderAddress."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Ship-to)", Vendor."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Ship-to)", Vendor."Mobile Phone No.");
#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Ship-to)", Vendor."EORI Number");
#endif

                    if OrderAddress."IDYS E-Mail Type" = '' then
                        IDYSTransportOrderHeader.Validate("E-Mail Type", Vendor."IDYS E-Mail Type")
                    else
                        IDYSTransportOrderHeader.Validate("E-Mail Type", OrderAddress."IDYS E-Mail Type");

                    if OrderAddress."IDYS Cost Center" = '' then
                        IDYSTransportOrderHeader.Validate("Cost Center", Vendor."IDYS Cost Center")
                    else
                        IDYSTransportOrderHeader.Validate("Cost Center", OrderAddress."IDYS Cost Center");
                end;
        end;
        OnAfterTransferAddressFieldsFromOrderAddress(IDYSTransportOrderHeader, OrderAddress, IDYSAddressType);
    end;

    local procedure TransferAddressFieldsFromShipToAddress(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ShipToAddress: Record "Ship-to Address"; IDYSAddressType: Enum "IDYS Address Type")
    var
        Customer: Record Customer;
    begin
        Customer.Get(ShipToAddress."Customer No.");
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Pick-up)", ShipToAddress.Name);
                    IDYSTransportOrderHeader.Validate("Address (Pick-up)", ShipToAddress.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Pick-up)", ShipToAddress."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Pick-up)", ShipToAddress."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Pick-up)", ShipToAddress.City);
                    IDYSTransportOrderHeader.Validate("County (Pick-up)", ShipToAddress.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Pick-up)", ShipToAddress."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Pick-up)", ShipToAddress.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Pick-up)", ShipToAddress."Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Pick-up)", ShipToAddress."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Pick-up)", ShipToAddress."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Pick-up)", Customer."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Pick-up)", Customer."Mobile Phone No.");
#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Pick-up)", Customer."EORI Number");
#endif
                end;
            IDYSAddressType::"Ship-to":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Ship-to)", ShipToAddress.Name);
                    IDYSTransportOrderHeader.Validate("Address (Ship-to)", ShipToAddress.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Ship-to)", ShipToAddress."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Ship-to)", ShipToAddress."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Ship-to)", ShipToAddress.City);
                    IDYSTransportOrderHeader.Validate("County (Ship-to)", ShipToAddress.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Ship-to)", ShipToAddress."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Ship-to)", ShipToAddress.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Ship-to)", ShipToAddress."Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Ship-to)", ShipToAddress."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Ship-to)", ShipToAddress."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Ship-to)", Customer."VAT Registration No.");
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Ship-to)", Customer."Mobile Phone No.");
#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Ship-to)", Customer."EORI Number");
#endif

                    if ShiptoAddress."IDYS Account No." = '' then
                        IDYSTransportOrderHeader.Validate("Account No.", Customer."IDYS Account No.")
                    else
                        IDYSTransportOrderHeader.Validate("Account No.", ShiptoAddress."IDYS Account No.");

                    if ShiptoAddress."IDYS E-Mail Type" = '' then
                        IDYSTransportOrderHeader.Validate("E-Mail Type", Customer."IDYS E-Mail Type")
                    else
                        IDYSTransportOrderHeader.Validate("E-Mail Type", ShiptoAddress."IDYS E-Mail Type");

                    if ShiptoAddress."IDYS Cost Center" = '' then
                        IDYSTransportOrderHeader.Validate("Cost Center", Customer."IDYS Cost Center")
                    else
                        IDYSTransportOrderHeader.Validate("Cost Center", ShiptoAddress."IDYS Cost Center");
                end;
        end;
        OnAfterTransferAddressFieldsFromShipToAddress(IDYSTransportOrderHeader, ShiptoAddress, IDYSAddressType);
    end;

    local procedure TransferAddressFieldsFromVendor(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Vendor: Record Vendor; IDYSAddressType: Enum "IDYS Address Type")
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Pick-up)", Vendor.Name);
                    IDYSTransportOrderHeader.Validate("Address (Pick-up)", Vendor.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Pick-up)", Vendor."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Pick-up)", Vendor."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Pick-up)", Vendor.City);
                    IDYSTransportOrderHeader.Validate("County (Pick-up)", Vendor.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Pick-up)", Vendor."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Pick-up)", Vendor.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Pick-up)", Vendor."Phone No.");
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Pick-up)", Vendor."Mobile Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Pick-up)", Vendor."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Pick-up)", Vendor."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Pick-up)", Vendor."VAT Registration No.");

#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Pick-up)", Vendor."EORI Number");
#endif
                end;
            IDYSAddressType::"Ship-to":
                begin
                    IDYSTransportOrderHeader.Validate("Name (Ship-to)", Vendor.Name);
                    IDYSTransportOrderHeader.Validate("Address (Ship-to)", Vendor.Address);
                    IDYSTransportOrderHeader.Validate("Address 2 (Ship-to)", Vendor."Address 2");
                    IDYSTransportOrderHeader.Validate("Post Code (Ship-to)", Vendor."Post Code");
                    IDYSTransportOrderHeader.Validate("City (Ship-to)", Vendor.City);
                    IDYSTransportOrderHeader.Validate("County (Ship-to)", Vendor.County);
                    IDYSTransportOrderHeader.Validate("Country/Region Code (Ship-to)", Vendor."Country/Region Code");
                    IDYSTransportOrderHeader.Validate("Contact (Ship-to)", Vendor.Contact);
                    IDYSTransportOrderHeader.Validate("Phone No. (Ship-to)", Vendor."Phone No.");
                    IDYSTransportOrderHeader.Validate("Mobile Phone No. (Ship-to)", Vendor."Mobile Phone No.");
                    IDYSTransportOrderHeader.Validate("Fax No. (Ship-to)", Vendor."Fax No.");
                    IDYSTransportOrderHeader.Validate("E-Mail (Ship-to)", Vendor."E-Mail");
                    IDYSTransportOrderHeader.Validate("VAT Registration No. (Ship-to)", Vendor."VAT Registration No.");

#if not BC17EORI
                    IDYSTransportOrderHeader.Validate("EORI Number (Ship-to)", Vendor."EORI Number");
#endif
                    IDYSTransportOrderHeader.Validate("E-Mail Type", Vendor."IDYS E-Mail Type");
                    IDYSTransportOrderHeader.Validate("Cost Center", Vendor."IDYS Cost Center");
                end;
        end;
        OnAfterTransferAddressFieldsFromVendor(IDYSTransportOrderHeader, Vendor, IDYSAddressType);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterClearAddressFields(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; IDYSAddressType: Enum "IDYS Address Type");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferAddressFieldsFromCompanyInfo(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; CompanyInformation: Record "Company Information"; IDYSAddressType: Enum "IDYS Address Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferAddressFieldsFromCustomer(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Customer: Record Customer; IDYSAddressType: Enum "IDYS Address Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferAddressFieldsFromLocation(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Location: Record Location; IDYSAddressType: Enum "IDYS Address Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferAddressFieldsFromOrderAddress(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; OrderAddress: Record "Order Address"; IDYSAddressType: Enum "IDYS Address Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferAddressFieldsFromShipToAddress(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; ShipToAddress: Record "Ship-to Address"; IDYSAddressType: Enum "IDYS Address Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferAddressFieldsFromVendor(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; Vendor: Record Vendor; IDYSAddressType: Enum "IDYS Address Type")
    begin
    end;

    var
        ThereIsNoErr: Label 'There is no %1 with %2 "%3".', Comment = '%1 = Table Caption, %2 = Mapping Field Caption, %3 = Code.';
}