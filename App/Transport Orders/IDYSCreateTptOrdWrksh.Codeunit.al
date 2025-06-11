codeunit 11147646 "IDYS Create Tpt. Ord. (Wrksh.)"
{
    TableNo = "IDYS Transport Worksheet Line";

    trigger OnRun()
    var
        IsHandled: Boolean;
    begin
        OnBeforeOnRun(Rec, IsHandled);
        if IsHandled then
            exit;

        Rec.SetCurrentKey(Include, "Combinability ID");
        Rec.SetRange(Include, true);

        if not Rec.FindSet() then
            exit;

        repeat
            Rec.TestSourceDocTypeAllowed();

            Rec.SetRange("Combinability ID", Rec."Combinability ID");

            if not AddLinesToExistingOrder(Rec) then
                AddLinesToNewOrder(Rec);

            Rec.FindLast();
            Rec.SetRange("Combinability ID");
        until Rec.Next() = 0;

        OnBeforeDeleteRec(Rec, SkipOpenTransportOrder, IsHandled);
        if IsHandled then
            exit;

        Rec.DeleteAll(true);
        if not SkipOpenTransportOrder then
            ShowTransportOrder()
        else
            StoreCreatedAndUpdatedLists(Rec."Source Document Table No.", Rec."Source Document No.");

        OnAfterOnRun(Rec, SkipOpenTransportOrder);
    end;

    procedure CreateTempTransOrderHeader(var TempTransportWorksheetLine: Record "IDYS Transport Worksheet Line" temporary; var TempTransportOrderHeader: Record "IDYS Transport Order Header" temporary)
    var
        CompanyInformation: Record "Company Information";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        SalesLine: Record "Sales Line";
        IDYSTranssmartAPIDocsMgt: Codeunit "IDYS Transsmart API Docs. Mgt.";
        IDYSProvider: Enum "IDYS Provider";
        AmountPerItemCategory: Dictionary of [Code[20], Decimal];
        IsHandled: Boolean;
        CurrencyCode: Code[10];
        LineAmountLCY: Decimal;
        ItemCategoryAmountLCY: Decimal;
        TotalAmountLCY: Decimal;
    begin
        OnBeforeCreateTempTransportOrderHeader(TempTransportWorksheetLine, TempTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        IDYSProvider := TempTransportOrderHeader.Provider;

        IDYSSetup.Get();
        IDYSSetup.TestField("Pick-up Time From");
        IDYSSetup.TestField("Pick-up Time To");
        IDYSSetup.TestField("Delivery Time From");
        IDYSSetup.TestField("Delivery Time To");

        CompanyInformation.Get();

        TempTransportOrderHeader.Init();
        TempTransportOrderHeader.Validate(Description, TempTransportWorksheetLine."Source Document Description");
        TempTransportOrderHeader.Validate("Shipping Agent Code", TempTransportWorksheetLine."Shipping Agent Code");
        TempTransportOrderHeader.Validate("Shipping Agent Service Code", TempTransportWorksheetLine."Shipping Agent Service Code");
        TempTransportOrderHeader.Validate("Shipment Method Code", TempTransportWorksheetLine."Shipment Method Code");
        TempTransportOrderHeader.Validate("Service Type Enum", TempTransportOrderHeader."Service Type Enum"::"NON-DOCS");
#if not BC17EORI
        TempTransportOrderHeader.Validate("EORI Number (Pick-up)", CompanyInformation."EORI Number");
#endif
        TempTransportOrderHeader.Validate(Book, TempTransportWorksheetLine.Book);
        TempTransportOrderHeader.Validate(Print, TempTransportWorksheetLine.Print);
        TempTransportOrderHeader.Validate("Source Type (Pick-up)", TempTransportWorksheetLine."Source Type (Pick-up)");
        TempTransportOrderHeader.Validate("No. (Pick-up)", TempTransportWorksheetLine."No. (Pick-up)");
        TempTransportOrderHeader.Validate("Code (Pick-up)", TempTransportWorksheetLine."Code (Pick-up)");
        TempTransportOrderHeader.Validate("Name (Pick-up)", TempTransportWorksheetLine."Name (Pick-up)");
        TempTransportOrderHeader.Validate("Address (Pick-up)", TempTransportWorksheetLine."Address (Pick-up)");
        TempTransportOrderHeader.Validate("Address 2 (Pick-up)", TempTransportWorksheetLine."Address 2 (Pick-up)");
        TempTransportOrderHeader.Validate("City (Pick-up)", TempTransportWorksheetLine."City (Pick-up)");
        TempTransportOrderHeader.Validate("Post Code (Pick-up)", TempTransportWorksheetLine."Post Code (Pick-up)");
        TempTransportOrderHeader.Validate("County (Pick-up)", TempTransportWorksheetLine."County (Pick-up)");
        TempTransportOrderHeader.Validate("Country/Region Code (Pick-up)", TempTransportWorksheetLine."Country/Region Code (Pick-up)");
        TempTransportOrderHeader.Validate("Contact (Pick-up)", TempTransportWorksheetLine."Contact (Pick-up)");
        TempTransportOrderHeader.Validate("Phone No. (Pick-up)", TempTransportWorksheetLine."Phone No. (Pick-up)");
        TempTransportOrderHeader.Validate("Mobile Phone No. (Pick-up)", TempTransportWorksheetLine."Mobile Phone No. (Pick-up)");
        TempTransportOrderHeader.Validate("Fax No. (Pick-up)", TempTransportWorksheetLine."Fax No. (Pick-up)");
        TempTransportOrderHeader.Validate("E-Mail (Pick-up)", TempTransportWorksheetLine."E-Mail (Pick-up)");
        TempTransportOrderHeader.Validate("VAT Registration No. (Pick-up)", TempTransportWorksheetLine."VAT Registration No. (Pick-up)");
        TempTransportOrderHeader.Validate("EORI Number (Pick-up)", TempTransportWorksheetLine."EORI Number (Pick-up)");

        TempTransportOrderHeader.Validate("Source Type (Ship-to)", TempTransportWorksheetLine."Source Type (Ship-to)");
        TempTransportOrderHeader.Validate("No. (Ship-to)", TempTransportWorksheetLine."No. (Ship-to)");
        TempTransportOrderHeader.Validate("Code (Ship-to)", TempTransportWorksheetLine."Code (Ship-to)");
        TempTransportOrderHeader.Validate("Name (Ship-to)", TempTransportWorksheetLine."Name (Ship-to)");
        TempTransportOrderHeader.Validate("Address (Ship-to)", TempTransportWorksheetLine."Address (Ship-to)");
        TempTransportOrderHeader.Validate("Address 2 (Ship-to)", TempTransportWorksheetLine."Address 2 (Ship-to)");
        TempTransportOrderHeader.Validate("City (Ship-to)", TempTransportWorksheetLine."City (Ship-to)");
        TempTransportOrderHeader.Validate("Post Code (Ship-to)", TempTransportWorksheetLine."Post Code (Ship-to)");
        TempTransportOrderHeader.Validate("County (Ship-to)", TempTransportWorksheetLine."County (Ship-to)");
        TempTransportOrderHeader.Validate("Country/Region Code (Ship-to)", TempTransportWorksheetLine."Country/Region Code (Ship-to)");
        TempTransportOrderHeader.Validate("Contact (Ship-to)", TempTransportWorksheetLine."Contact (Ship-to)");
        TempTransportOrderHeader.Validate("Phone No. (Ship-to)", TempTransportWorksheetLine."Phone No. (Ship-to)");
        TempTransportOrderHeader.Validate("Mobile Phone No. (Ship-to)", TempTransportWorksheetLine."Mobile Phone No. (Ship-to)");
        TempTransportOrderHeader.Validate("Fax No. (Ship-to)", TempTransportWorksheetLine."Fax No. (Ship-to)");
        TempTransportOrderHeader.Validate("E-Mail (Ship-to)", TempTransportWorksheetLine."E-Mail (Ship-to)");
        TempTransportOrderHeader.Validate("VAT Registration No. (Ship-to)", TempTransportWorksheetLine."VAT Registration No. (Ship-to)");
        TempTransportOrderHeader.Validate("EORI Number (Ship-to)", TempTransportWorksheetLine."EORI Number (Ship-to)");

        TempTransportOrderHeader.Validate("Source Type (Invoice)", TempTransportWorksheetLine."Source Type (Invoice)");
        TempTransportOrderHeader.Validate("No. (Invoice)", TempTransportWorksheetLine."No. (Invoice)");
        TempTransportOrderHeader.Validate("Name (Invoice)", TempTransportWorksheetLine."Name (Invoice)");
        TempTransportOrderHeader.Validate("Address (Invoice)", TempTransportWorksheetLine."Address (Invoice)");
        TempTransportOrderHeader.Validate("Address 2 (Invoice)", TempTransportWorksheetLine."Address 2 (Invoice)");
        TempTransportOrderHeader.Validate("City (Invoice)", TempTransportWorksheetLine."City (Invoice)");
        TempTransportOrderHeader.Validate("Post Code (Invoice)", TempTransportWorksheetLine."Post Code (Invoice)");
        TempTransportOrderHeader.Validate("County (Invoice)", TempTransportWorksheetLine."County (Invoice)");
        TempTransportOrderHeader.Validate("Country/Region Code (Invoice)", TempTransportWorksheetLine."Country/Region Code (Invoice)");
        TempTransportOrderHeader.Validate("Contact (Invoice)", TempTransportWorksheetLine."Contact (Invoice)");
        TempTransportOrderHeader.Validate("Phone No. (Invoice)", TempTransportWorksheetLine."Phone No. (Invoice)");
        TempTransportOrderHeader.Validate("Mobile Phone No. (Invoice)", TempTransportWorksheetLine."Mobile Phone No. (Invoice)");
        TempTransportOrderHeader.Validate("Fax No. (Invoice)", TempTransportWorksheetLine."Fax No. (Invoice)");
        TempTransportOrderHeader.Validate("E-Mail (Invoice)", TempTransportWorksheetLine."E-Mail (Invoice)");
        TempTransportOrderHeader.Validate("VAT Registration No. (Invoice)", TempTransportWorksheetLine."VAT Registration No. (Invoice)");
        TempTransportOrderHeader.Validate("EORI Number (Invoice)", TempTransportWorksheetLine."EORI Number (Invoice)");

        TempTransportOrderHeader.Validate("Invoice (Ref)", TempTransportWorksheetLine."Invoice (Ref)");
        TempTransportOrderHeader.Validate("Customer Order (Ref)", TempTransportWorksheetLine."Customer Order (Ref)");
        TempTransportOrderHeader.Validate("Order No. (Ref)", TempTransportWorksheetLine."Order No. (Ref)");
        TempTransportOrderHeader.Validate("Delivery Note (Ref)", TempTransportWorksheetLine."Delivery Note (Ref)");
        TempTransportOrderHeader.Validate("Delivery Id (Ref)", TempTransportWorksheetLine."Delivery Id (Ref)");
        TempTransportOrderHeader.Validate("Other (Ref)", TempTransportWorksheetLine."Other (Ref)");
        TempTransportOrderHeader.Validate("Service Point (Ref)", TempTransportWorksheetLine."Service Point (Ref)");
        TempTransportOrderHeader.Validate("Project (Ref)", TempTransportWorksheetLine."Project (Ref)");
        TempTransportOrderHeader.Validate("Your Reference (Ref)", TempTransportWorksheetLine."Your Reference (Ref)");
        TempTransportOrderHeader.Validate("Engineer (Ref)", TempTransportWorksheetLine."Engineer (Ref)");
        TempTransportOrderHeader.Validate("Customer (Ref)", TempTransportWorksheetLine."Customer (Ref)");
        TempTransportOrderHeader.Validate("Agent (Ref)", TempTransportWorksheetLine."Agent (Ref)");
        TempTransportOrderHeader.Validate("Driver ID (Ref)", TempTransportWorksheetLine."Driver ID (Ref)");
        TempTransportOrderHeader.Validate("Route ID (Ref)", TempTransportWorksheetLine."Route ID (Ref)");

        if TempTransportWorksheetLine."Preferred Shipment Date" < Today then
            TempTransportOrderHeader.Validate("Preferred Pick-up Date", Today())
        else
            TempTransportOrderHeader.Validate("Preferred Pick-up Date", TempTransportWorksheetLine."Preferred Shipment Date");
        if TempTransportWorksheetLine."Preferred Delivery Date" < Today then
            TempTransportOrderHeader.Validate("Preferred Delivery Date", Today())
        else
            TempTransportOrderHeader.Validate("Preferred Delivery Date", TempTransportWorksheetLine."Preferred Delivery Date");

        TempTransportOrderHeader.Validate("E-Mail Type", TempTransportWorksheetLine."E-Mail Type");
        TempTransportOrderHeader.Validate("Cost Center", TempTransportWorksheetLine."Cost Center");
        TempTransportOrderHeader.Validate("Account No.", TempTransportWorksheetLine."Account No."); // Ship-to
        TempTransportOrderHeader.Validate("Account No. (Invoice)", TempTransportWorksheetLine."Account No. (Invoice)");
        TempTransportOrderHeader.Validate("Account No. (Pick-up)", TempTransportWorksheetLine."Account No. (Pick-up)");
        TempTransportOrderHeader.Validate("Combinability ID", TempTransportWorksheetLine."Combinability ID");
        TempTransportOrderHeader.Validate("Is Return", TempTransportWorksheetLine."Is Return");

        // Insurance
        IDYSProviderSetup.GetProviderSetup(IDYSProvider);
        case IDYSProvider of
            IDYSProvider::Transsmart:
                begin
                    if TempTransportWorksheetLine.FindSet() then
                        repeat
                            Clear(LineAmountLCY);
                            Clear(ItemCategoryAmountLCY);

                            if TempTransportWorksheetLine.Quantity <> 0 then
                                case TempTransportWorksheetLine."Source Document Table No." of
                                    Database::"Sales Header":
                                        if SalesLine.Get(TempTransportWorksheetLine."Source Document Type", TempTransportWorksheetLine."Source Document No.", TempTransportWorksheetLine."Source Document Line No.") then begin
                                            if not AmountPerItemCategory.Get(SalesLine."Item Category Code", ItemCategoryAmountLCY) then
                                                AmountPerItemCategory.Add(SalesLine."Item Category Code", ItemCategoryAmountLCY);

                                            CurrencyCode := SalesLine."Currency Code";
                                            LineAmountLCY := CurrencyExchangeRate.ExchangeAmount(SalesLine.GetLineAmountToHandle(TempTransportWorksheetLine.Quantity), CurrencyCode, '', WorkDate());
                                            ItemCategoryAmountLCY += LineAmountLCY;
                                            AmountPerItemCategory.Set(SalesLine."Item Category Code", ItemCategoryAmountLCY);
                                        end;
                                end;
                            TotalAmountLCY += LineAmountLCY;
                        until TempTransportWorksheetLine.Next() = 0;

                    // Last retrieved Currency Code (assumption is no deviation on lines)
                    TempTransportOrderHeader.Validate("Shipment Value Curr Code", CurrencyCode);
                    TempTransportOrderHeader.Validate("Shipmt. Value", TotalAmountLCY);

                    // Decide if this transport order should be insured based on the shipment value
                    if IDYSProviderSetup."Enable Min. Shipment Amount" then
                        TempTransportOrderHeader.Validate(Insure, IDYSTranssmartAPIDocsMgt.IsInsuranceApplicable(TempTransportWorksheetLine, TempTransportOrderHeader, AmountPerItemCategory));
                    TempTransportOrderHeader.Validate("Do Not Insure", TempTransportWorksheetLine."Do Not Insure");
                end;
        end;

        TempTransportOrderHeader.Insert(true);

        OnAfterCreateTempTransportOrderHeader(TempTransportWorksheetLine, TempTransportOrderHeader);
    end;

    procedure ConvertRegisterIntoListAndShowTransportOrder(PostedTableNo: Integer; PostedDocNo: Code[20])
    var
        TransportOrderRegister: Record "IDYS Transport Order Register";
    begin
        TransportOrderRegister.SetRange("Table No.", PostedTableNo);
        TransportOrderRegister.SetRange("Document No.", PostedDocNo);
        if TransportOrderRegister.IsEmpty() then
            exit;
        ConvertRegisterIntoListAndShowTransportOrder(TransportOrderRegister);
    end;

    procedure ConvertRegisterIntoListAndShowTransportOrder(BatchId: Guid)
    var
        TransportOrderRegister: Record "IDYS Transport Order Register";
    begin
        TransportOrderRegister.SetCurrentKey("Batch Posting ID");
        TransportOrderRegister.SetRange("Batch Posting ID", BatchId);
        if TransportOrderRegister.IsEmpty() then
            exit;
        ConvertRegisterIntoListAndShowTransportOrder(TransportOrderRegister);
    end;

    procedure UpdateBatchIDOnRegister(PostedTableNo: Integer; PostedDocNo: Code[20]; SourceDocRecordID: RecordId; BatchID: Guid)
    var
        TransportOrderRegister: Record "IDYS Transport Order Register";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateBatchIDOnRegister(PostedTableNo, PostedDocNo, SourceDocRecordID, BatchID, IsHandled);
        if IsHandled then
            exit;

        TransportOrderRegister.SetRange("Table No.", PostedTableNo);
        TransportOrderRegister.SetRange("Document No.", PostedDocNo);
        if TransportOrderRegister.FindSet(true) then
            repeat
                TransportOrderRegister.Validate("Batch Posting ID", BatchID);
                TransportOrderRegister.Validate("Source Document Record Id", SourceDocRecordID);
                TransportOrderRegister.Modify(true);
            until TransportOrderRegister.Next() = 0;

        OnAfterUpdateBatchIDOnRegister(PostedTableNo, PostedDocNo, SourceDocRecordID, BatchID);
    end;

    procedure ToggleSkipOpenTransportOrder(NewSkipOpenTransportOrder: Boolean)
    begin
        SkipOpenTransportOrder := NewSkipOpenTransportOrder;
    end;

    procedure SetWhseShipmentNo(NewWhseShipmentNo: Code[20])
    begin
        WhseShipmemtNo := NewWhseShipmentNo;
    end;

    local procedure AddLinesToExistingOrder(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line") ReturnValue: Boolean;
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        TransportOrderLine: Record "IDYS Transport Order Line";
        SourceDocumentService: Record "IDYS Source Document Service";
        IsHandled: Boolean;
    begin
        OnBeforeAddLinesToExistingOrder(TransportWorksheetLine, ReturnValue, IsHandled);
        if IsHandled then
            exit(ReturnValue);

        LoadSetup();
        if IDYSSetup."Always New Trns. Order" then
            exit(false);

        // Skip combinability when services are included
        SourceDocumentService.SetRange("Table No.", Database::"IDYS Transport Worksheet Line");
        SourceDocumentService.SetRange("Document Type", TransportWorksheetLine."Source Document Type");
        SourceDocumentService.SetRange("Document No.", TransportWorksheetLine."Source Document No.");
        if not SourceDocumentService.IsEmpty() then
            exit(false);

        TransportOrderHeader.SetRange(Status, TransportOrderHeader.Status::New);
        TransportOrderHeader.SetRange("Combinability ID", TransportWorksheetLine."Combinability ID");
        if TransportWorksheetLine."Do Not Insure" then
            TransportOrderHeader.SetRange(Insure, false);
        if TransportOrderHeader.FindFirst() then begin
            TransportOrderLine.SetRange("Transport Order No.", TransportOrderHeader."No.");
            if not TransportOrderLine.FindLast() then;

            if not IDYSSetup."Skip Source Doc. Packages" then
                AddPackagesFromSourceDocument(TransportOrderHeader, TransportWorksheetLine);

            CreateTransportOrderLines(TransportOrderHeader, TransportOrderLine."Line No.", TransportWorksheetLine);

            if not UpdatedOrders.Contains(TransportOrderHeader."No.") then
                UpdatedOrders.Add(TransportOrderHeader."No.");

            OnAfterAddLinesToExistingTransportOrder(TransportOrderHeader, TransportWorksheetLine);
            exit(true);
        end;

        OnAfterAddLinesToExistingOrder(TransportWorksheetLine, ReturnValue);
    end;

    local procedure AddPackagesFromSourceDocument(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforeAddPackagesFromSourceDocument(TransportOrderHeader, TransportWorksheetLine, IDYSSetup, IsHandled);
        if IsHandled then
            exit;

        if (TransportWorksheetLine."Source Document Table No." = Database::"Sales Header") then
            AddPackageLinesFromSourceDocument(TransportWorksheetLine, TransportOrderHeader);
    end;

    local procedure AddLinesToNewOrder(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line");
    var
        CompanyInformation: Record "Company Information";
        TransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSSourceDocumentService: Record "IDYS Source Document Service";
        IsHandled: Boolean;
    begin
        OnBeforeAddLinesToNewOrder(TransportWorksheetLine, IsHandled);
        if IsHandled then
            exit;
        LoadSetup();

        IDYSSetup.TestField("Pick-up Time From");
        IDYSSetup.TestField("Pick-up Time To");
        IDYSSetup.TestField("Delivery Time From");
        IDYSSetup.TestField("Delivery Time To");

        CompanyInformation.Get();

        TransportOrderHeader.Init();
        TransportOrderHeader.SetSuppressDefaultPackageInsert(true);
        TransportOrderHeader.Validate(Description, TransportWorksheetLine."Source Document Description");
        TransportOrderHeader.Validate("Shipping Agent Code", TransportWorksheetLine."Shipping Agent Code");
        TransportOrderHeader.Validate("Shipping Agent Service Code", TransportWorksheetLine."Shipping Agent Service Code");
        TransportOrderHeader.Validate("Shipment Method Code", TransportWorksheetLine."Shipment Method Code");
        TransportOrderHeader.Validate("Service Type Enum", TransportOrderHeader."Service Type Enum"::"NON-DOCS");

#if not BC17EORI
        TransportOrderHeader.Validate("EORI Number (Pick-up)", CompanyInformation."EORI Number");
#endif
        TransportOrderHeader.Validate(Book, TransportWorksheetLine.Book);
        TransportOrderHeader.Validate(Print, TransportWorksheetLine.Print);
        TransportOrderHeader.Validate("Source Type (Pick-up)", TransportWorksheetLine."Source Type (Pick-up)");
        TransportOrderHeader.Validate("No. (Pick-up)", TransportWorksheetLine."No. (Pick-up)");
        TransportOrderHeader.Validate("Code (Pick-up)", TransportWorksheetLine."Code (Pick-up)");
        TransportOrderHeader.Validate("Name (Pick-up)", TransportWorksheetLine."Name (Pick-up)");
        TransportOrderHeader.Validate("Address (Pick-up)", TransportWorksheetLine."Address (Pick-up)");
        TransportOrderHeader.Validate("Address 2 (Pick-up)", TransportWorksheetLine."Address 2 (Pick-up)");
        TransportOrderHeader.Validate("City (Pick-up)", TransportWorksheetLine."City (Pick-up)");
        TransportOrderHeader.Validate("Post Code (Pick-up)", TransportWorksheetLine."Post Code (Pick-up)");
        TransportOrderHeader.Validate("County (Pick-up)", TransportWorksheetLine."County (Pick-up)");
        TransportOrderHeader.Validate("Country/Region Code (Pick-up)", TransportWorksheetLine."Country/Region Code (Pick-up)");
        TransportOrderHeader.Validate("Contact (Pick-up)", TransportWorksheetLine."Contact (Pick-up)");
        TransportOrderHeader.Validate("Phone No. (Pick-up)", TransportWorksheetLine."Phone No. (Pick-up)");
        TransportOrderHeader.Validate("Mobile Phone No. (Pick-up)", TransportWorksheetLine."Mobile Phone No. (Pick-up)");
        TransportOrderHeader.Validate("Fax No. (Pick-up)", TransportWorksheetLine."Fax No. (Pick-up)");
        TransportOrderHeader.Validate("E-Mail (Pick-up)", TransportWorksheetLine."E-Mail (Pick-up)");
        TransportOrderHeader.Validate("VAT Registration No. (Pick-up)", TransportWorksheetLine."VAT Registration No. (Pick-up)");
        TransportOrderHeader.Validate("EORI Number (Pick-up)", TransportWorksheetLine."EORI Number (Pick-up)");

        TransportOrderHeader.Validate("Source Type (Ship-to)", TransportWorksheetLine."Source Type (Ship-to)");
        TransportOrderHeader.Validate("No. (Ship-to)", TransportWorksheetLine."No. (Ship-to)");
        TransportOrderHeader.Validate("Code (Ship-to)", TransportWorksheetLine."Code (Ship-to)");
        TransportOrderHeader.Validate("Name (Ship-to)", TransportWorksheetLine."Name (Ship-to)");
        TransportOrderHeader.Validate("Address (Ship-to)", TransportWorksheetLine."Address (Ship-to)");
        TransportOrderHeader.Validate("Address 2 (Ship-to)", TransportWorksheetLine."Address 2 (Ship-to)");
        TransportOrderHeader.Validate("City (Ship-to)", TransportWorksheetLine."City (Ship-to)");
        TransportOrderHeader.Validate("Post Code (Ship-to)", TransportWorksheetLine."Post Code (Ship-to)");
        TransportOrderHeader.Validate("County (Ship-to)", TransportWorksheetLine."County (Ship-to)");
        TransportOrderHeader.Validate("Country/Region Code (Ship-to)", TransportWorksheetLine."Country/Region Code (Ship-to)");
        TransportOrderHeader.Validate("Contact (Ship-to)", TransportWorksheetLine."Contact (Ship-to)");
        TransportOrderHeader.Validate("Phone No. (Ship-to)", TransportWorksheetLine."Phone No. (Ship-to)");
        TransportOrderHeader.Validate("Mobile Phone No. (Ship-to)", TransportWorksheetLine."Mobile Phone No. (Ship-to)");
        TransportOrderHeader.Validate("Fax No. (Ship-to)", TransportWorksheetLine."Fax No. (Ship-to)");
        TransportOrderHeader.Validate("E-Mail (Ship-to)", TransportWorksheetLine."E-Mail (Ship-to)");
        TransportOrderHeader.Validate("VAT Registration No. (Ship-to)", TransportWorksheetLine."VAT Registration No. (Ship-to)");
        TransportOrderHeader.Validate("EORI Number (Ship-to)", TransportWorksheetLine."EORI Number (Ship-to)");

        TransportOrderHeader.Validate("Source Type (Invoice)", TransportWorksheetLine."Source Type (Invoice)");
        TransportOrderHeader.Validate("No. (Invoice)", TransportWorksheetLine."No. (Invoice)");
        TransportOrderHeader.Validate("Name (Invoice)", TransportWorksheetLine."Name (Invoice)");
        TransportOrderHeader.Validate("Address (Invoice)", TransportWorksheetLine."Address (Invoice)");
        TransportOrderHeader.Validate("Address 2 (Invoice)", TransportWorksheetLine."Address 2 (Invoice)");
        TransportOrderHeader.Validate("City (Invoice)", TransportWorksheetLine."City (Invoice)");
        TransportOrderHeader.Validate("Post Code (Invoice)", TransportWorksheetLine."Post Code (Invoice)");
        TransportOrderHeader.Validate("County (Invoice)", TransportWorksheetLine."County (Invoice)");
        TransportOrderHeader.Validate("Country/Region Code (Invoice)", TransportWorksheetLine."Country/Region Code (Invoice)");
        TransportOrderHeader.Validate("Contact (Invoice)", TransportWorksheetLine."Contact (Invoice)");
        TransportOrderHeader.Validate("Phone No. (Invoice)", TransportWorksheetLine."Phone No. (Invoice)");
        TransportOrderHeader.Validate("Mobile Phone No. (Invoice)", TransportWorksheetLine."Mobile Phone No. (Invoice)");
        TransportOrderHeader.Validate("Fax No. (Invoice)", TransportWorksheetLine."Fax No. (Invoice)");
        TransportOrderHeader.Validate("E-Mail (Invoice)", TransportWorksheetLine."E-Mail (Invoice)");
        TransportOrderHeader.Validate("VAT Registration No. (Invoice)", TransportWorksheetLine."VAT Registration No. (Invoice)");
        TransportOrderHeader.Validate("EORI Number (Invoice)", TransportWorksheetLine."EORI Number (Invoice)");

        TransportOrderHeader.Validate("Invoice (Ref)", TransportWorksheetLine."Invoice (Ref)");
        TransportOrderHeader.Validate("Customer Order (Ref)", TransportWorksheetLine."Customer Order (Ref)");
        TransportOrderHeader.Validate("Order No. (Ref)", TransportWorksheetLine."Order No. (Ref)");
        TransportOrderHeader.Validate("Delivery Note (Ref)", TransportWorksheetLine."Delivery Note (Ref)");
        TransportOrderHeader.Validate("Delivery Id (Ref)", TransportWorksheetLine."Delivery Id (Ref)");
        TransportOrderHeader.Validate("Other (Ref)", TransportWorksheetLine."Other (Ref)");
        TransportOrderHeader.Validate("Service Point (Ref)", TransportWorksheetLine."Service Point (Ref)");
        TransportOrderHeader.Validate("Project (Ref)", TransportWorksheetLine."Project (Ref)");
        TransportOrderHeader.Validate("Your Reference (Ref)", TransportWorksheetLine."Your Reference (Ref)");
        TransportOrderHeader.Validate("Engineer (Ref)", TransportWorksheetLine."Engineer (Ref)");
        TransportOrderHeader.Validate("Customer (Ref)", TransportWorksheetLine."Customer (Ref)");
        TransportOrderHeader.Validate("Agent (Ref)", TransportWorksheetLine."Agent (Ref)");
        TransportOrderHeader.Validate("Driver ID (Ref)", TransportWorksheetLine."Driver ID (Ref)");
        TransportOrderHeader.Validate("Route ID (Ref)", TransportWorksheetLine."Route ID (Ref)");

        if TransportWorksheetLine."Preferred Shipment Date" < Today then
            TransportOrderHeader.Validate("Preferred Pick-up Date", Today())
        else
            TransportOrderHeader.Validate("Preferred Pick-up Date", TransportWorksheetLine."Preferred Shipment Date");
        if TransportWorksheetLine."Preferred Delivery Date" < Today then
            TransportOrderHeader.Validate("Preferred Delivery Date", Today())
        else
            TransportOrderHeader.Validate("Preferred Delivery Date", TransportWorksheetLine."Preferred Delivery Date");

        TransportOrderHeader.Validate("E-Mail Type", TransportWorksheetLine."E-Mail Type");
        TransportOrderHeader.Validate("Cost Center", TransportWorksheetLine."Cost Center");
        TransportOrderHeader.Validate("Account No.", TransportWorksheetLine."Account No."); // Ship-to
        TransportOrderHeader.Validate("Account No. (Invoice)", TransportWorksheetLine."Account No. (Invoice)");
        TransportOrderHeader.Validate("Account No. (Pick-up)", TransportWorksheetLine."Account No. (Pick-up)");
        //even when data changes on transport order (e.g. dates) they can still be combined:
        TransportOrderHeader.Validate("Combinability ID", TransportWorksheetLine."Combinability ID");
        TransportOrderHeader.Validate("Source Document No.", TransportWorksheetLine."Source Document No.");
        TransportOrderHeader.Validate("External Document No.", TransportWorksheetLine."External Document No.");
        TransportOrderHeader.Validate("Is Return", TransportWorksheetLine."Is Return");

        IDYSPublisher.OnBeforeInsertTransportOrder(TransportOrderHeader, TransportWorksheetLine);

        TransportOrderHeader.Insert(true);

        IDYSIProvider := TransportOrderHeader.Provider;
        if TransportOrderHeader.Provider = TransportOrderHeader.Provider::"Delivery Hub" then
            IDYSSourceDocumentService.CopyServiceLevels(Database::"IDYS Transport Worksheet Line", TransportWorksheetLine."Source Document Type", TransportWorksheetLine."Source Document No.", Database::"IDYS Transport Order Header", "IDYS Source Document Type"::"0", TransportOrderHeader."No.");

        CreateTransportOrderLines(TransportOrderHeader, 0, TransportWorksheetLine);

        if not IDYSSetup."Skip Source Doc. Packages" then
            AddPackagesFromSourceDocument(TransportOrderHeader, TransportWorksheetLine);

        if IsEmptyTransportOrderPackage(TransportOrderHeader) then
            IDYSProviderMgt.CreateDefaultTransportOrderPackages(TransportOrderHeader);

        // NOTE: Currently, we are moving packages from the "Sales Header" for unposted documents / creating a default one. Source documents do not have links between the packages and document lines.
        AssignPackageContent(TransportOrderHeader);

        IDYSPublisher.OnTransportOrderCreated(TransportOrderHeader, TransportWorksheetLine);

        if TransportOrderHeader.Book then begin
            IDYSProviderSetup.GetProviderSetup(TransportOrderHeader.Provider);
            if IDYSProviderSetup."Aut. Select Appl. Ship. Method" then
                IDYSProviderMgt.SetShippingMethod(TransportOrderHeader);
            IDYSIProvider.ValidateTransportOrder(TransportOrderHeader);
        end;

        if not CreatedOrders.Contains(TransportOrderHeader."No.") then
            CreatedOrders.Add(TransportOrderHeader."No.");

        OnAfterAddLinesToNewOrder(TransportWorksheetLine);
        OnAfterAddLinesToNewTransportOrder(TransportOrderHeader, TransportWorksheetLine);
    end;

    local procedure IsEmptyTransportOrderPackage(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Boolean
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        exit(TransportOrderPackage.IsEmpty());
    end;

    local procedure AssignPackageContent(IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        IsHandled: Boolean;
    begin
        OnBeforeAssignPackageContent(IDYSTransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        LoadSetup();
        if not IDYSSetup."Link Del. Lines with Packages" then
            exit;

        TransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if TransportOrderPackage.IsEmpty() then
            AddDefaultPackageLine(IDYSTransportOrderHeader);
        if not TransportOrderPackage.FindFirst() then
            exit;

        TransportOrderDelNote.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        if TransportOrderDelNote.FindSet(true) then
            repeat
                TransportOrderDelNote."Transport Order Pkg. Record Id" := TransportOrderPackage.RecordId;
                TransportOrderDelNote.Modify();
            until TransportOrderDelNote.Next() = 0;

        OnAfterAssignPackageContent(IDYSTransportOrderHeader);
    end;

    local procedure AddDefaultPackageLine(TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        IProvider: Interface "IDYS IProvider";
        PackageTypeCode: Code[50];
        EmptyPackageTypeCodeErr: Label 'Default Package Type for the provider (%1) must be specified.', comment = '%1 - provider';
    begin
        LoadSetup();
        if not IDYSSetup."Auto. Add One Default Package" then
            exit;

        IProvider := TransportOrderHeader.Provider;
        PackageTypeCode := IProvider.GetDefaultPackage(TransportOrderHeader."Carrier Entry No.", TransportOrderHeader."Booking Profile Entry No.");
        if PackageTypeCode = '' then
            Error(EmptyPackageTypeCodeErr, TransportOrderHeader.Provider);
        IDYSProviderMgt.InsertTransportOrderPackage(TransportOrderHeader, PackageTypeCode, 1);
    end;

    local procedure ConvertRegisterIntoListAndShowTransportOrder(var TransportOrderRegister: Record "IDYS Transport Order Register")
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        TransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        IsHandled: Boolean;
        Booked: Boolean;
        Printed: Boolean;
    begin
        Clear(CreatedOrders);
        Clear(UpdatedOrders);
        Clear(BookedOrders);
        Clear(BookedWithErrorsOrders);
        OnBeforeConvertRegisterIntoListAndShowTransportOrder(TransportOrderRegister, IsHandled);
        if IsHandled then
            exit;

        LoadSetup();

        TransportOrderRegister.SetRange(Created, true);
        if TransportOrderRegister.FindSet() then
            repeat
                if TransportOrderHeader.Get(TransportOrderRegister."Transport Order No.") and
                    TransportOrderHeader.Book
                then begin
                    TransportOrderMgt.TryBookAndPrint(TransportOrderHeader, Booked, Printed);

                    if (Booked and not TransportOrderHeader.Print) or
                       (Booked and Printed)
                    then begin
                        if not BookedOrders.Contains(TransportOrderHeader."No.") then
                            BookedOrders.Add(TransportOrderHeader."No.")
                    end else
                        if not BookedWithErrorsOrders.Contains(TransportOrderHeader."No.") then
                            BookedWithErrorsOrders.Add(TransportOrderHeader."No.");
                    //Commit();
                end else
                    if not CreatedOrders.Contains(TransportOrderRegister."Transport Order No.") then
                        CreatedOrders.Add(TransportOrderRegister."Transport Order No.");
            until TransportOrderRegister.Next() = 0;
        TransportOrderRegister.SetRange(Created, false);
        if TransportOrderRegister.FindSet() then
            repeat
                if not UpdatedOrders.Contains(TransportOrderRegister."Transport Order No.") then
                    UpdatedOrders.Add(TransportOrderRegister."Transport Order No.");
            until TransportOrderRegister.Next() = 0;
        TransportOrderRegister.SetRange(Created);
        OnBeforeDeleteRegisterAndShowTransportOrder(TransportOrderRegister, IsHandled);
        if not IsHandled then begin
            TransportOrderRegister.DeleteAll();
            ShowTransportOrder();
        end;
    end;

    local procedure CreateTransportOrderLines(var TransportOrderHeader: Record "IDYS Transport Order Header"; NextLineNo: Integer; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    var
        TransportOrderLine: Record "IDYS Transport Order Line";
        CurrencyCode: Code[10];
        ShipmentValue: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeCreateTransportOrderLines(TransportOrderHeader, NextLineNo, TransportWorksheetLine, IsHandled);
        if IsHandled then
            exit;

        if TransportWorksheetLine.FindSet() then
            repeat
                if TransportWorksheetLine.Quantity <> 0 then begin
                    NextLineNo += 10000;

                    TransportOrderLine.Validate("Transport Order No.", TransportOrderHeader."No.");
                    TransportOrderLine.Validate("Line No.", NextLineNo);
                    TransportOrderLine.Validate("Source Document Type", TransportWorksheetLine."Source Document Type");
                    TransportOrderLine.Validate("Source Document No.", TransportWorksheetLine."Source Document No.");
                    TransportOrderLine.Validate("Source Document Table No.", TransportWorksheetLine."Source Document Table No.");
                    TransportOrderLine.Validate("Source Document Line No.", TransportWorksheetLine."Source Document Line No.");
                    TransportOrderLine.Validate(Quantity, TransportWorksheetLine.Quantity);
                    TransportOrderLine.Validate("Unit of Measure Code", TransportWorksheetLine."Unit of Measure Code");
                    IDYSPublisher.OnBeforeInsertTransportOrderLine(TransportOrderLine, TransportWorksheetLine);
                    TransportOrderLine.Insert(true);
                    IDYSPublisher.OnAfterInsertTransportOrderLine(TransportOrderLine, TransportWorksheetLine);
                    CurrencyCode := CalculateTransportValueAndPopulateDelNote(TransportOrderLine);
                    ShipmentValue += TransportOrderLine.Amount;
                    TransportOrderLine.Modify(true);
                end;
            until TransportWorksheetLine.Next() = 0;
        OnAfterCalculateTotalShipmentValue(TransportOrderHeader, ShipmentValue);
        TransportOrderHeader.Validate("Shipment Value Curr Code", CurrencyCode); //last retrieved Currency Code (assunption is no deviation on lines)
        TransportOrderHeader.UpdateTotals();
        TransportOrderHeader.Modify();
    end;

    procedure AddPackageLinesFromSourceDocument(TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; TransportOrderHeader: Record "IDYS Transport Order Header")
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
        TransportOrderPackage: Record "IDYS Transport Order Package";
        IsHandled: Boolean;
    begin
        OnBeforeAddPackageLinesFromSalesOrder(TransportWorksheetLine, TransportOrderHeader, IsHandled);
        if IsHandled then
            exit;

        SourceDocumentPackage.SetRange("Table No.", TransportWorksheetLine."Source Document Table No.");
        SourceDocumentPackage.SetRange("Document Type", TransportWorksheetLine."Source Document Type");
        SourceDocumentPackage.SetRange("Document No.", TransportWorksheetLine."Source Document No.");
        if SourceDocumentPackage.FindSet() then
            repeat
                Clear(TransportOrderPackage);
                TransportOrderPackage.Init();
                TransportOrderPackage.TransferFields(SourceDocumentPackage, false);
                TransportOrderPackage.Validate("Transport Order No.", TransportOrderHeader."No.");
                TransportOrderPackage.Insert(true);
            until SourceDocumentPackage.Next() = 0;

        OnAfterAddPackageLinesFromSalesOrder(TransportWorksheetLine, TransportOrderHeader);
    end;

    procedure PopulateDeliveryNote(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; TransportOrderLine: Record "IDYS Transport Order Line"; CurrencyCode: Code[10]; Quantity: Decimal; OrderQuantity: Decimal; GrossWeight: Decimal; NetWeight: Decimal; IsItem: Boolean)
    begin
        OverrideQuantity := Quantity;
        PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, CurrencyCode, OrderQuantity, GrossWeight, NetWeight, IsItem);
    end;

    procedure PopulateDeliveryNote(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; TransportOrderLine: Record "IDYS Transport Order Line"; CurrencyCode: Code[10]; OrderQuantity: Decimal; GrossWeight: Decimal; NetWeight: Decimal; IsItem: Boolean)
    var
        Item: Record Item;
        Currency: Record Currency;
        SecondTransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        ArticleIdFormatLbl: Label '%1 %2', Locked = true;
        IsHandled: Boolean;
    begin
        OnBeforePopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, CurrencyCode, OrderQuantity, GrossWeight, NetWeight, IsItem, OverrideQuantity, IsHandled);
        if IsHandled then
            exit;

        if TransportOrderLine."Qty. (Base)" = 0 then
            exit;
        TransportOrderDelNote.Init();
        TransportOrderDelNote.Validate("Transport Order No.", TransportOrderLine."Transport Order No.");
        TransportOrderDelNote.Validate("Transport Order Line No.", TransportOrderLine."Line No.");
        if not SecondTransportOrderDelNote.Get(TransportOrderLine."Transport Order No.", TransportOrderLine."Line No.") then
            TransportOrderDelNote.Validate("Line No.", TransportOrderLine."Line No.")
        else
            TransportOrderDelNote."Line No." := 0;
        if TransportOrderLine."Variant Code" <> '' then
            TransportOrderDelNote.Validate("Article Id", StrSubstNo(ArticleIdFormatLbl, TransportOrderLine."Item No.", TransportOrderLine."Variant Code"))
        else
            TransportOrderDelNote.Validate("Article Id", TransportOrderLine."Item No.");
        TransportOrderDelNote.Validate("Article Name", CopyStr(TransportOrderLine.Description, 1, MaxStrLen(TransportOrderDelNote."Article Name")));
        TransportOrderDelNote.Validate(Description, CopyStr(TransportOrderLine.Description, 1, MaxStrLen(TransportOrderDelNote.Description)));
        TransportOrderDelNote.Validate(Currency, CurrencyCode);
        if OverrideQuantity <> 0 then
            TransportOrderDelNote.Validate(Quantity, OverrideQuantity)
        else
            TransportOrderDelNote.Validate(Quantity, TransportOrderLine."Qty. (Base)");
        TransportOrderDelNote.Validate("Quantity Order", OrderQuantity);
        if CurrencyCode <> '' then begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end else
            Currency.InitRoundingPrecision();
        TransportOrderDelNote.Validate(Price, Round(TransportOrderLine.Amount / TransportOrderLine."Qty. (Base)", Currency."Amount Rounding Precision"));
        TransportOrderDelNote.Validate("Gross Weight", GrossWeight);
        TransportOrderDelNote.Validate("Net Weight", NetWeight);

        if IsItem then
            if Item.Get(TransportOrderLine."Item No.") then begin
                TransportOrderDelNote.Validate("Country of Origin", Item."Country/Region of Origin Code");
                TransportOrderDelNote.Validate("HS Code", Item."Tariff No.");
                TransportOrderDelNote.Validate("Quantity UOM", Item."Base Unit of Measure");
            end;

        OnAfterPopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, CurrencyCode, OrderQuantity, GrossWeight, NetWeight, IsItem, OverrideQuantity);
    end;

    local procedure ShowTransportOrder();
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        TransportOrderNo: Code[20];
        TransportOrderCreatedMsg: Label 'Transport order %1 was created.', Comment = '%1=The order no';
        TransportOrderUpdatedMsg: Label 'Transport order %1 was updated.', Comment = '%1=The order no';
        TransportOrderBookedMsg: Label 'Transport order %1 was created and booked successfully.', Comment = '%1=The order no';
        TransportOrderBookedWithErrorsMsg: Label 'Transport order %1 was booked, but errors occured in the communication with nShift Transsmart.', Comment = '%1=The order no';
        TransportOrderCreatedQst: Label 'Transport order %1 was created.\Do you wish to open the transport order?', Comment = '%1=The order no';
        TransportOrderUpdatedQst: Label 'Transport order %1 was updated.\Do you wish to open the transport order?', Comment = '%1=The order no';
        TransportOrderBookedQst: Label 'Transport order %1 was created and has been booked.\Do you wish to open the transport order?', Comment = '%1=The order no';
        TransportOrderBookedWithErrorQst: Label 'Transport order %1 was booked, but errors occured.\Do you wish to open the transport order to inspect the error?', Comment = '%1=The order no';
        CreatedUpdateMsg: Label '%1 transport orders were created/updated.', Comment = '%1 = Created and/or updated transport orders count.';
        MessageText: Text;
    begin
        LoadSetup();
        if IDYSSetup."No TO Created Notification" then
            exit;

        if GuiAllowed() then begin
            MessageText := StrSubstNo(CreatedUpdateMsg, CreatedOrders.Count() + UpdatedOrders.Count() + BookedOrders.Count() + BookedWithErrorsOrders.Count());

            if CreatedOrders.Count() + UpdatedOrders.Count() + BookedOrders.Count() + BookedWithErrorsOrders.Count() = 1 then begin
                Commit();
                foreach TransportOrderNo in CreatedOrders do begin
                    OpenTransportOrderCard(StrSubstNo(TransportOrderCreatedQst, TransportOrderNo), TransportOrderNo);
                    exit;
                end;

                foreach TransportOrderNo in UpdatedOrders do begin
                    OpenTransportOrderCard(StrSubstNo(TransportOrderUpdatedQst, TransportOrderNo), TransportOrderNo);
                    exit;
                end;

                foreach TransportOrderNo in BookedOrders do begin
                    OpenTransportOrderCard(StrSubstNo(TransportOrderBookedQst, TransportOrderNo), TransportOrderNo);
                    exit;
                end;

                foreach TransportOrderNo in BookedWithErrorsOrders do begin
                    OpenTransportOrderCard(StrSubstNo(TransportOrderBookedWithErrorQst, TransportOrderNo), TransportOrderNo);
                    exit;
                end;
            end;

            exit;
        end;

        if CreatedOrders.Count() + UpdatedOrders.Count() + BookedOrders.Count() + BookedWithErrorsOrders.Count() > 10 then begin
            IDYSNotificationManagement.SendNotification(MessageText);
            exit;
        end;

        foreach TransportOrderNo in CreatedOrders do
            if TransportOrderHeader.Get(TransportOrderNo) then
                SendTransportOrderNotification(StrSubstNo(TransportOrderCreatedMsg, TransportOrderNo), TransportOrderNo);

        foreach TransportOrderNo in UpdatedOrders do
            if TransportOrderHeader.Get(TransportOrderNo) then
                SendTransportOrderNotification(StrSubstNo(TransportOrderUpdatedMsg, TransportOrderNo), TransportOrderNo);

        foreach TransportOrderNo in BookedOrders do
            if TransportOrderHeader.Get(TransportOrderNo) then
                SendTransportOrderNotification(StrSubstNo(TransportOrderBookedMsg, TransportOrderNo), TransportOrderNo);

        foreach TransportOrderNo in BookedWithErrorsOrders do
            if TransportOrderHeader.Get(TransportOrderNo) then
                SendTransportOrderNotification(StrSubstNo(TransportOrderBookedWithErrorsMsg, TransportOrderNo), TransportOrderNo);
    end;

    local procedure OpenTransportOrderCard(ConfirmQst: Text; TransportOrderNo: Code[20])
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        TransportOrderCard: Page "IDYS Transport Order Card";
    begin
        if Confirm(StrSubstNo(ConfirmQst, TransportOrderNo)) then begin
            TransportOrderHeader.Get(TransportOrderNo);
            TransportOrderCard.SetRecord(TransportOrderHeader);
            TransportOrderCard.Run();
        end;
    end;

    local procedure SendTransportOrderNotification(Message: Text; TransportOrderNo: Code[20])
    var
        Notification: Notification;
        OpenTransportOrderMsg: Label 'Click here to open.';
    begin
        Notification.Message(Message);
        Notification.Scope := NotificationScope::LocalScope;
        Notification.SetData('TransportOrderNo', TransportOrderNo);
        Notification.AddAction(OpenTransportOrderMsg, Codeunit::"IDYS Action Handlers", 'OpenTransportOrderCard');
        Notification.Send();
    end;

    local procedure CalculateTransportValueAndPopulateDelNote(var TransportOrderLine: Record "IDYS Transport Order Line") CurrencyCode: Code[10]
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        TransferLine: Record "Transfer Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferReceiptLine: Record "Transfer Receipt Line";
        ServiceShipmentLine: Record "Service Shipment Line";
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
        IsHandled: Boolean;
    begin
        OnBeforeCalculateTransportValueAndPopulateDelNote(TransportOrderLine, CurrencyCode, IsHandled);
        if IsHandled then
            exit(CurrencyCode);

        LoadSetup();
        TransportOrderDelNote.SetPostponeTotals(true);
        case TransportOrderLine."Source Document Table No." of
            Database::"Sales Header":
                if SalesLine.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    CurrencyCode := SalesLine."Currency Code";
                    TransportOrderLine.Validate("Currency Code", CurrencyCode);
                    TransportOrderLine.Validate(Amount, SalesLine.GetLineAmountToHandle(TransportOrderLine.Quantity));
                    if IDYSSetup."Add Delivery Notes" then begin
                        PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, SalesLine."Currency Code", SalesLine."Quantity (Base)", SalesLine."Gross Weight" / SalesLine."Qty. per Unit of Measure", SalesLine."Net Weight" / SalesLine."Qty. per Unit of Measure", SalesLine.Type = SalesLine.Type::Item);
                        IDYSPublisher.OnBeforeCreateTransportOrderDelNoteForSalesLine(TransportOrderDelNote, SalesLine);
                        TransportOrderDelNote.Insert(true);
                        IDYSPublisher.OnAfterCreateTransportOrderDelNoteForSalesLine(TransportOrderDelNote, SalesLine);
                    end;
                    if TransportOrderLine."Amount" = 0 then
                        TransportOrderLine.Validate(Amount, RoundAmountToCurrency(TransportOrderLine."Item No.", SalesLine."Currency Code", SalesLine."Unit Cost (LCY)", TransportOrderLine."Qty. (Base)"));
                end;
            Database::"Purchase Header":
                if PurchaseLine.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    CurrencyCode := PurchaseLine."Currency Code";
                    TransportOrderLine.Validate("Currency Code", CurrencyCode);
                    TransportOrderLine.Validate(Amount, PurchaseLine.GetLineAmountToHandle(TransportOrderLine.Quantity));
                    if IDYSSetup."Add Delivery Notes" then begin
                        PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, PurchaseLine."Currency Code", PurchaseLine."Quantity (Base)", PurchaseLine."Gross Weight" / PurchaseLine."Qty. per Unit of Measure", PurchaseLine."Net Weight" / PurchaseLine."Qty. per Unit of Measure", PurchaseLine.Type = PurchaseLine.Type::Item);
                        IDYSPublisher.OnBeforeCreateTransportOrderDelNoteForPurchaseLine(TransportOrderDelNote, PurchaseLine);
                        TransportOrderDelNote.Insert(true);
                        IDYSPublisher.OnAfterCreateTransportOrderDelNoteForPurchaseLine(TransportOrderDelNote, PurchaseLine);
                    end;
                    if TransportOrderLine."Amount" = 0 then
                        TransportOrderLine.Validate(Amount, RoundAmountToCurrency(TransportOrderLine."Item No.", PurchaseLine."Currency Code", PurchaseLine."Unit Cost (LCY)", TransportOrderLine."Qty. (Base)"));
                end;
            Database::"Service Header":
                if ServiceLine.Get(TransportOrderLine."Source Document Type", TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    CurrencyCode := ServiceLine."Currency Code";
                    TransportOrderLine.Validate("Currency Code", CurrencyCode);
                    if (ServiceLine."Quantity (Base)" = TransportOrderLine."Qty. (Base)") or (ServiceLine."Quantity (Base)" = 0) then
                        TransportOrderLine.Validate(Amount, ServiceLine."Line Amount")
                    else
                        TransportOrderLine.Validate(Amount, RoundAmountToCurrency('', ServiceLine."Currency Code", (ServiceLine."Line Amount" / ServiceLine."Quantity (Base)") * TransportOrderLine."Qty. (Base)", 1));
                    if IDYSSetup."Add Delivery Notes" then begin
                        PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, ServiceLine."Currency Code", ServiceLine."Quantity (Base)", ServiceLine."Gross Weight" / ServiceLine."Qty. per Unit of Measure", ServiceLine."Net Weight" / ServiceLine."Qty. per Unit of Measure", ServiceLine.Type = ServiceLine.Type::Item);
                        IDYSPublisher.OnBeforeCreateTransportOrderDelNoteForServiceLine(TransportOrderDelNote, ServiceLine);
                        TransportOrderDelNote.Insert(true);
                        IDYSPublisher.OnAfterCreateTransportOrderDelNoteForServiceLine(TransportOrderDelNote, ServiceLine);
                    end;
                    if ServiceLine."Amount Including VAT" = 0 then
                        TransportOrderLine.Validate(Amount, RoundAmountToCurrency(TransportOrderLine."Item No.", ServiceLine."Currency Code", ServiceLine."Unit Cost (LCY)", TransportOrderLine."Qty. (Base)"));
                end;
            Database::"Transfer Header":
                if TransferLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    CurrencyCode := '';
                    TransportOrderLine.Validate(Amount, RoundAmountToCurrency(TransportOrderLine."Item No.", '', 0, TransportOrderLine."Qty. (Base)"));
                    if IDYSSetup."Add Delivery Notes" then begin
                        PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, '', TransferLine."Quantity (Base)", TransferLine."Gross Weight" / TransferLine."Qty. per Unit of Measure", TransferLine."Net Weight" / TransferLine."Qty. per Unit of Measure", true);
                        IDYSPublisher.OnBeforeCreateTransportOrderDelNoteForTransferLine(TransportOrderDelNote, TransferLine);
                        TransportOrderDelNote.Insert(true);
                        IDYSPublisher.OnAfterCreateTransportOrderDelNoteForTransferLine(TransportOrderDelNote, TransferLine);
                    end;
                end;
            Database::"Sales Shipment Header":
                if SalesShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    SalesShipmentLine.CalcFields("Currency Code");
                    CurrencyCode := SalesShipmentLine."Currency Code";
                    TransportOrderLine.Validate("Currency Code", CurrencyCode);
                    if (SalesShipmentLine."Quantity (Base)" = TransportOrderLine."Qty. (Base)") or (SalesShipmentLine."Quantity (Base)" = 0) then
                        TransportOrderLine.Validate(Amount, SalesShipmentLine."IDYS Transport Value")
                    else
                        TransportOrderLine.Validate(Amount, RoundAmountToCurrency('', SalesShipmentLine."Currency Code", (SalesShipmentLine."IDYS Transport Value" / SalesShipmentLine."Quantity (Base)") * TransportOrderLine."Qty. (Base)", 1));
                    if IDYSSetup."Add Delivery Notes" then begin
                        PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, SalesShipmentLine."Currency Code", SalesShipmentLine."Quantity (Base)", SalesShipmentLine."Gross Weight" / SalesShipmentLine."Qty. per Unit of Measure", SalesShipmentLine."Net Weight" / SalesShipmentLine."Qty. per Unit of Measure", SalesShipmentLine.Type = SalesShipmentLine.Type::Item);
                        IDYSPublisher.OnBeforeCreateTransportOrderDelNoteForSalesShipmentLine(TransportOrderDelNote, SalesShipmentLine);
                        TransportOrderDelNote.Insert(true);
                        IDYSPublisher.OnAfterCreateTransportOrderDelNoteForSalesShipmentLine(TransportOrderDelNote, SalesShipmentLine);
                    end;
                    if SalesShipmentLine."IDYS Transport Value" = 0 then
                        TransportOrderLine.Validate(Amount, RoundAmountToCurrency(TransportOrderLine."Item No.", SalesShipmentLine."Currency Code", SalesShipmentLine."Unit Cost (LCY)", TransportOrderLine."Qty. (Base)"));
                end;
            Database::"Return Shipment Header":
                if ReturnShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    ReturnShipmentLine.CalcFields("Currency Code");
                    CurrencyCode := ReturnShipmentLine."Currency Code";
                    TransportOrderLine.Validate("Currency Code", CurrencyCode);
                    if (ReturnShipmentLine."Quantity (Base)" = TransportOrderLine."Qty. (Base)") or (ReturnShipmentLine."Quantity (Base)" = 0) then
                        TransportOrderLine.Validate(Amount, ReturnShipmentLine."IDYS Transport Value")
                    else
                        TransportOrderLine.Validate(Amount, RoundAmountToCurrency('', ReturnShipmentLine."Currency Code", (ReturnShipmentLine."IDYS Transport Value" / ReturnShipmentLine."Quantity (Base)") * TransportOrderLine."Qty. (Base)", 1));
                    if IDYSSetup."Add Delivery Notes" then begin
                        PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, ReturnShipmentLine."Currency Code", ReturnShipmentLine."Quantity (Base)", ReturnShipmentLine."Gross Weight" / ReturnShipmentLine."Qty. per Unit of Measure", ReturnShipmentLine."Net Weight" / ReturnShipmentLine."Qty. per Unit of Measure", ReturnShipmentLine.Type = ReturnShipmentLine.Type::Item);
                        IDYSPublisher.OnBeforeCreateTransportOrderDelNoteForReturnShipmentLine(TransportOrderDelNote, ReturnShipmentLine);
                        TransportOrderDelNote.Insert(true);
                        IDYSPublisher.OnAfterCreateTransportOrderDelNoteForReturnShipmentLine(TransportOrderDelNote, ReturnShipmentLine);
                    end;
                    if ReturnShipmentLine."IDYS Transport Value" = 0 then
                        TransportOrderLine.Validate(Amount, RoundAmountToCurrency('', ReturnShipmentLine."Currency Code", ReturnShipmentLine."Unit Cost (LCY)", TransportOrderLine."Qty. (Base)"));
                end;
            Database::"Service Shipment Header":
                if ServiceShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    CurrencyCode := ServiceShipmentLine."Currency Code";
                    TransportOrderLine.Validate("Currency Code", CurrencyCode);
                    if (ServiceShipmentLine."Quantity (Base)" = TransportOrderLine."Qty. (Base)") or (ServiceShipmentLine."Quantity (Base)" = 0) then
                        TransportOrderLine.Validate(Amount, ServiceShipmentLine."IDYS Transport Value")
                    else
                        TransportOrderLine.Validate(Amount, RoundAmountToCurrency('', ServiceShipmentLine."Currency Code", (ServiceShipmentLine."IDYS Transport Value" / ServiceShipmentLine."Quantity (Base)") * TransportOrderLine."Qty. (Base)", 1));
                    if IDYSSetup."Add Delivery Notes" then begin
                        PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, ServiceShipmentLine."Currency Code", ServiceShipmentLine."Quantity (Base)", ServiceShipmentLine."Gross Weight" / ServiceShipmentLine."Qty. per Unit of Measure", ServiceShipmentLine."Net Weight" / ServiceShipmentLine."Qty. per Unit of Measure", ServiceShipmentLine.Type = ServiceShipmentLine.Type::Item);
                        IDYSPublisher.OnBeforeCreateTransportOrderDelNoteForServiceShipmentLine(TransportOrderDelNote, ServiceShipmentLine);
                        TransportOrderDelNote.Insert(true);
                        IDYSPublisher.OnAfterCreateTransportOrderDelNoteForServiceShipmentLine(TransportOrderDelNote, ServiceShipmentLine);
                    end;
                    if ServiceShipmentLine."IDYS Transport Value" = 0 then
                        TransportOrderLine.Validate(Amount, RoundAmountToCurrency(TransportOrderLine."Item No.", ServiceShipmentLine."Currency Code", ServiceShipmentLine."Unit Cost (LCY)", TransportOrderLine."Qty. (Base)"));
                end;
            Database::"Transfer Shipment Header":
                if TransferShipmentLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    CurrencyCode := '';
                    TransportOrderLine.Validate(Amount, RoundAmountToCurrency(TransportOrderLine."Item No.", '', 0, TransportOrderLine."Qty. (Base)"));
                    if IDYSSetup."Add Delivery Notes" then begin
                        PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, '', TransferShipmentLine."Quantity (Base)", TransferShipmentLine."Gross Weight" / TransferShipmentLine."Qty. per Unit of Measure", TransferShipmentLine."Net Weight" / TransferShipmentLine."Qty. per Unit of Measure", true);
                        IDYSPublisher.OnBeforeCreateTransportOrderDelNoteForTransferShipmentLine(TransportOrderDelNote, TransferShipmentLine);
                        TransportOrderDelNote.Insert(true);
                        IDYSPublisher.OnAfterCreateTransportOrderDelNoteForTransferShipmentLine(TransportOrderDelNote, TransferShipmentLine);
                    end;
                end;
            Database::"Transfer Receipt Header":
                if TransferReceiptLine.Get(TransportOrderLine."Source Document No.", TransportOrderLine."Source Document Line No.") then begin
                    CurrencyCode := '';
                    TransportOrderLine.Validate(Amount, RoundAmountToCurrency(TransportOrderLine."Item No.", '', 0, TransportOrderLine."Qty. (Base)"));
                    if IDYSSetup."Add Delivery Notes" then begin
                        PopulateDeliveryNote(TransportOrderDelNote, TransportOrderLine, '', TransferReceiptLine."Quantity (Base)", TransferReceiptLine."Gross Weight" / TransferReceiptLine."Qty. per Unit of Measure", TransferReceiptLine."Net Weight" / TransferReceiptLine."Qty. per Unit of Measure", true);
                        IDYSPublisher.OnBeforeCreateTransportOrderDelNoteForTransferReceiptLine(TransportOrderDelNote, TransferReceiptLine);
                        TransportOrderDelNote.Insert(true);
                        IDYSPublisher.OnAfterCreateTransportOrderDelNoteForTransferReceiptLine(TransportOrderDelNote, TransferReceiptLine);
                    end;
                end;
        end;
    end;

    local procedure RoundAmountToCurrency(ItemNo: Code[20]; CurrencyCode: Code[10]; CostPrice: Decimal; Quantity: Decimal): Decimal
    var
        Item: Record Item;
        Currency: Record Currency;
    begin
        if CurrencyCode <> '' then begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end else
            Currency.InitRoundingPrecision();
        if (ItemNo <> '') and (CostPrice = 0) then begin
            Item.Get(ItemNo);
            CostPrice := Item."Unit Cost";
        end;
        exit(Round(CostPrice * Quantity, Currency."Amount Rounding Precision"));
    end;

    local procedure StoreCreatedAndUpdatedLists(PostedTableNo: Integer; PostedDocNo: Code[20])
    var
        TransportOrderRegister: Record "IDYS Transport Order Register";
        TransportOrderNo: Text[20];
        IsHandled: Boolean;
    begin
        OnBeforeStoreCreatedAndUpdatedLists(PostedTableNo, PostedDocNo, CreatedOrders, UpdatedOrders, IsHandled);
        if IsHandled then
            exit;

        foreach TransportOrderNo in CreatedOrders do
            if not TransportOrderRegister.Get(PostedTableNo, PostedDocNo, TransportOrderNo) then begin
                TransportOrderRegister.Init();
                TransportOrderRegister."Table No." := PostedTableNo;
                TransportOrderRegister."Document No." := PostedDocNo;
                TransportOrderRegister."Transport Order No." := TransportOrderNo;
                TransportOrderRegister."Warehouse Shipment No." := WhseShipmemtNo;
                TransportOrderRegister.Created := true;
                TransportOrderRegister.Insert(true);
            end;
        foreach TransportOrderNo in UpdatedOrders do
            if not TransportOrderRegister.Get(PostedTableNo, PostedDocNo, TransportOrderNo) then begin
                TransportOrderRegister.Init();
                TransportOrderRegister."Table No." := PostedTableNo;
                TransportOrderRegister."Document No." := PostedDocNo;
                TransportOrderRegister."Transport Order No." := TransportOrderNo;
                TransportOrderRegister."Warehouse Shipment No." := WhseShipmemtNo;
                TransportOrderRegister.Created := false;
                TransportOrderRegister.Insert(true);
            end;

        OnAfterStoreCreatedAndUpdatedLists(PostedTableNo, PostedDocNo, CreatedOrders, UpdatedOrders);
    end;

    local procedure LoadSetup()
    begin
        if not SetupLoaded then begin
            SetupLoaded := true;
            if not IDYSSetup.Get() then
                IDYSSetup.Init();
        end;
    end;

    procedure GetTransportOrderLists(var CreatedTOOrders: List of [Code[20]]; var UpdatedTOOrders: List of [Code[20]])
    begin
        CreatedTOOrders := CreatedOrders;
        UpdatedTOOrders := UpdatedOrders;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateTotalShipmentValue(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TotalShipmentValue: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteRegisterAndShowTransportOrder(var TransportOrderRegister: Record "IDYS Transport Order Register"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConvertRegisterIntoListAndShowTransportOrder(var TransportOrderRegister: Record "IDYS Transport Order Register"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var IDYSTransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnRun(var IDYSTransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var SkipOpenTransportOrder: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateTempTransportOrderHeader(TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var TempTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTempTransportOrderHeader(TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var TempTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteRec(TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var SkipOpenTransportOrder: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateBatchIDOnRegister(PostedTableNo: Integer; PostedDocNo: Code[20]; SourceDocRecordID: RecordId; BatchID: Guid; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBatchIDOnRegister(PostedTableNo: Integer; PostedDocNo: Code[20]; SourceDocRecordID: RecordId; BatchID: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddLinesToExistingOrder(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddLinesToExistingTransportOrder(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddLinesToNewTransportOrder(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddLinesToNewOrder(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssignPackageContent(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignPackageContent(IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateTransportOrderLines(var TransportOrderHeader: Record "IDYS Transport Order Header"; NextLineNo: Integer; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddPackageLinesFromSalesOrder(TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; TransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddPackageLinesFromSalesOrder(TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePopulateDeliveryNote(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; TransportOrderLine: Record "IDYS Transport Order Line"; CurrencyCode: Code[10]; OrderQuantity: Decimal; GrossWeight: Decimal; NetWeight: Decimal; IsItem: Boolean; OverrideQuantity: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPopulateDeliveryNote(var TransportOrderDelNote: Record "IDYS Transport Order Del. Note"; TransportOrderLine: Record "IDYS Transport Order Line"; CurrencyCode: Code[10]; OrderQuantity: Decimal; GrossWeight: Decimal; NetWeight: Decimal; IsItem: Boolean; OverrideQuantity: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStoreCreatedAndUpdatedLists(PostedTableNo: Integer; PostedDocNo: Code[20]; var CreatedOrders: List of [Code[20]]; var UpdatedOrders: List of [Code[20]]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterStoreCreatedAndUpdatedLists(PostedTableNo: Integer; PostedDocNo: Code[20]; var CreatedOrders: List of [Code[20]]; var UpdatedOrders: List of [Code[20]])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeAddPackagesFromSourceDocument(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; IDYSSetup: Record "IDYS Setup"; var IsHandled: Boolean)
    begin
    end;


    [IntegrationEvent(true, false)]
    local procedure OnBeforeCalculateTransportValueAndPopulateDelNote(var TransportOrderLine: Record "IDYS Transport Order Line"; var CurrencyCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    #region [Obsolete]

    [Obsolete('Replaced with CreateTempTransOrderHeader()', '24.0')]
    procedure CreateTempTransportOrderHeader(TempTransportWorksheetLine: Record "IDYS Transport Worksheet Line" temporary; var TempTransportOrderHeader: Record "IDYS Transport Order Header" temporary)
    begin
    end;

    [Obsolete('Replaced with OnAfterAddLinesToExistingTransportOrder()', '24.0')]

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddLinesToExistingOrder(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var ReturnValue: Boolean)
    begin
    end;

    [Obsolete('Replaced with OnAfterAddLinesToNewTransportOrder()', '24.0')]

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddLinesToNewOrder(var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    begin
    end;
    #endregion

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSProviderSetup: Record "IDYS Setup";
        IDYSPublisher: Codeunit "IDYS Publisher";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        IDYSIProvider: Interface "IDYS IProvider";
        SkipOpenTransportOrder: Boolean;
        SetupLoaded: Boolean;
        OverrideQuantity: Decimal;
        WhseShipmemtNo: Code[20];
        CreatedOrders: List of [Code[20]];
        UpdatedOrders: List of [Code[20]];
        BookedOrders: List of [Code[20]];
        BookedWithErrorsOrders: List of [Code[20]];
}