codeunit 11147686 "IDYS Subscribers"
{
    //Master data deletes
    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Currency_OnAfterDeleteEvent(var Rec: Record Currency)
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if Rec.IsTemporary() then
            exit;

        IDYSRefIntegrityMgt.DeleteCurrencyMappings(Rec."Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Country/Region", 'OnAfterDeleteEvent', '', true, false)]
    local procedure CountryRegion_OnAfterDeleteEvent(var Rec: Record "Country/Region")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if Rec.IsTemporary() then
            exit;

        IDYSRefIntegrityMgt.DeleteCountryRegionMappings(Rec."Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnAfterDeleteEvent', '', true, false)]
    local procedure ShipmentMethod_OnAfterDeleteEvent(var Rec: Record "Shipment Method")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if Rec.IsTemporary() then
            exit;

        IDYSRefIntegrityMgt.DeleteShipmentMethodMappings(Rec."Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Shipping Agent", 'OnAfterDeleteEvent', '', true, false)]
    local procedure ShippingAgent_OnAfterDeleteEvent(var Rec: Record "Shipping Agent")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if Rec.IsTemporary() then
            exit;

        IDYSRefIntegrityMgt.DeleteShippingAgentMappings(Rec."Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Shipping Agent Services", 'OnAfterDeleteEvent', '', true, false)]
    local procedure ShippingAgentServices_OnAfterDeleteEvent(var Rec: Record "Shipping Agent Services")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if Rec.IsTemporary() then
            exit;

        IDYSRefIntegrityMgt.DeleteShippingAgentSvcMappings(Rec."Shipping Agent Code", Rec."Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"IDYS Transport Order Header", 'OnAfterInsertEvent', '', true, false)]
    local procedure IDYSTransportOrderHeader_OnAfterInsert(var Rec: Record "IDYS Transport Order Header")
    begin
        Rec.SetDefaultProvider();
    end;

    [EventSubscriber(ObjectType::Table, Database::"IDYS Transport Order Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure IDYSTransportOrderLine_OnAfterDelete(var Rec: Record "IDYS Transport Order Line"; RunTrigger: Boolean)
    var
        UpdatePostedDocuments: Codeunit "IDYS Update Posted Documents";
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary() then
            exit;
        UpdatePostedDocuments.UpdateQtyToSendOnDocs(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"IDYS Transport Order Line", 'OnAfterInsertEvent', '', true, false)]
    local procedure IDYSTransportOrderLine_OnAfterInsert(var Rec: Record "IDYS Transport Order Line"; RunTrigger: Boolean)
    var
        UpdatePostedDocuments: Codeunit "IDYS Update Posted Documents";
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary() then
            exit;
        UpdatePostedDocuments.ResetQtyToSendOnDocs(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"IDYS Transport Order Line", 'OnAfterModifyEvent', '', true, false)]
    local procedure IDYSTransportOrderLine_OnAfterModify(var Rec: Record "IDYS Transport Order Line"; var xRec: Record "IDYS Transport Order Line"; RunTrigger: Boolean)
    var
        UpdatePostedDocuments: Codeunit "IDYS Update Posted Documents";
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary() then
            exit;
        if (Rec.Quantity <> xRec.Quantity) then
            UpdatePostedDocuments.UpdateQtyToSendOnDocs(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Batch Processing Mgt.", 'OnAfterBatchProcess', '', true, false)]
    local procedure BatchProcessingMgt_OnAfterBatchProcess(var RecRef: RecordRef)
    var
        TransportOrderRegister: Record "IDYS Transport Order Register";
        IDYSCreateTptOrdWrksh: Codeunit "IDYS Create Tpt. Ord. (Wrksh.)";
    begin
        TransportOrderRegister.SetCurrentKey("Source Document Record Id");
        TransportOrderRegister.SetRange("Source Document Record Id", RecRef.RecordId);
        if not TransportOrderRegister.FindFirst() then
            exit;
        IDYSCreateTptOrdWrksh.ConvertRegisterIntoListAndShowTransportOrder(TransportOrderRegister."Batch Posting ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeSalesLineByChangedFieldNo', '', true, false)]
    local procedure SalesHeader_OnBeforeSalesLineByChangedFieldNo(ChangedFieldNo: Integer; var SalesLine: Record "Sales Line")
    begin
        if ChangedFieldNo = SalesLine.FieldNo("Shipping Agent Code") then
            SalesLine.Validate("Recalculate Invoice Disc.", true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterGetTransferRoute', '', true, false)]
    local procedure TransferHeader_OnAfterGetTransferRoute(var TransferHeader: Record "Transfer Header"; TransferRoute: Record "Transfer Route")
    begin
        TransferHeader."Shipment Method Code" := TransferRoute."IDYS Shipment Method Code";
        TransferHeader.Validate("Shipping Agent Code");
        TransferHeader.Validate("Shipping Agent Service Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure RegisterPackageContentOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        Setup: Record "IDYS Setup";
    begin
        if not Setup.Get() then begin
            TempApplicationAreaSetup."IDYS Package Content" := false;
            exit;
        end;
        if Setup."License Entry No." = 0 then begin
            TempApplicationAreaSetup."IDYS Package Content" := false;
            exit;
        end;
        TempApplicationAreaSetup."IDYS Package Content" := Setup."Link Del. Lines with Packages";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnBeforeModifySalesOrderHeader', '', true, false)]
    local procedure SalesQuoteToOrder_OnAfterOnRun(var SalesOrderHeader: Record "Sales Header"; SalesQuoteHeader: Record "Sales Header")
    var
        QuoteDocumentPackage: Record "IDYS Source Document Package";
        OrderDocumentPackage: Record "IDYS Source Document Package";
    begin
        // Clear default packages
        OrderDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        OrderDocumentPackage.SetRange("Document Type", SalesOrderHeader."Document Type");
        OrderDocumentPackage.SetRange("Document No.", SalesOrderHeader."No.");
        if not OrderDocumentPackage.IsEmpty() then
            OrderDocumentPackage.DeleteAll();

        // Transfer packages
        QuoteDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        QuoteDocumentPackage.SetRange("Document Type", SalesQuoteHeader."Document Type");
        QuoteDocumentPackage.SetRange("Document No.", SalesQuoteHeader."No.");
        if QuoteDocumentPackage.FindSet() then
            repeat
                Clear(OrderDocumentPackage);
                OrderDocumentPackage.Init();
                OrderDocumentPackage.TransferFields(QuoteDocumentPackage, false);
                OrderDocumentPackage."Table No." := Database::"Sales Header";
                OrderDocumentPackage."Document Type" := SalesOrderHeader."Document Type";
                OrderDocumentPackage."Document No." := SalesOrderHeader."No.";
                OrderDocumentPackage.Insert(true);
            until QuoteDocumentPackage.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure SalesHeader_OnAfterDelete(RunTrigger: Boolean; var Rec: Record "Sales Header")
    var
        SourceDocumentPackage: Record "IDYS Source Document Package";
        SourceDocumentService: Record "IDYS Source Document Service";
    begin
        SourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        SourceDocumentPackage.SetRange("Document Type", Rec."Document Type");
        SourceDocumentPackage.SetRange("Document No.", Rec."No.");
        if not SourceDocumentPackage.IsEmpty() then
            SourceDocumentPackage.DeleteAll();

        SourceDocumentService.SetRange("Table No.", Database::"Sales Header");
        SourceDocumentService.SetRange("Document Type", Rec."Document Type");
        SourceDocumentService.SetRange("Document No.", Rec."No.");
        if not SourceDocumentService.IsEmpty() then
            SourceDocumentService.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure PurchaseHeader_OnAfterDelete(RunTrigger: Boolean; var Rec: Record "Purchase Header")
    var
        SourceDocumentService: Record "IDYS Source Document Service";
    begin
        SourceDocumentService.SetRange("Table No.", Database::"Purchase Header");
        SourceDocumentService.SetRange("Document Type", Rec."Document Type");
        SourceDocumentService.SetRange("Document No.", Rec."No.");
        if not SourceDocumentService.IsEmpty() then
            SourceDocumentService.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure ServiceHeader_OnAfterDelete(RunTrigger: Boolean; var Rec: Record "Service Header")
    var
        SourceDocumentService: Record "IDYS Source Document Service";
    begin
        SourceDocumentService.SetRange("Table No.", Database::"Service Header");
        SourceDocumentService.SetRange("Document Type", Rec."Document Type");
        SourceDocumentService.SetRange("Document No.", Rec."No.");
        if not SourceDocumentService.IsEmpty() then
            SourceDocumentService.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure TransferHeader_OnAfterDelete(RunTrigger: Boolean; var Rec: Record "Transfer Header")
    var
        SourceDocumentService: Record "IDYS Source Document Service";
    begin
        SourceDocumentService.SetRange("Table No.", Database::"Transfer Header");
        SourceDocumentService.SetRange("Document Type", "IDYS Source Document Type"::"0");
        SourceDocumentService.SetRange("Document No.", Rec."No.");
        if not SourceDocumentService.IsEmpty() then
            SourceDocumentService.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeSalesLineInsert', '', true, false)]
    local procedure SalesHeader_OnBeforeSalesLineInsert(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line")
    begin
        // Hotfix for C60 CalculateInvoiceDiscount() - TempServiceChargeLine entries
        SalesLine."System-Created Entry" := TempSalesLine."System-Created Entry";
    end;

#if BC17
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Calc. Discount", 'OnBeforeCalcSalesDiscount', '', true, false)]
    local procedure SalesCalcDiscount_OnBeforeCalcSalesDiscount(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; var UpdateHeader: Boolean)
    var
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        Currency: Record Currency;
        CustPostingGr: Record "Customer Posting Group";
        CustInvDisc: Record "Cust. Invoice Disc.";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesSetup: Record "Sales & Receivables Setup";
        TempServiceChargeLine: Record "Sales Line" temporary;
        CurrExchRate: Record "Currency Exchange Rate";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        DiscountNotificationMgt: Codeunit "Discount Notification Mgt.";
        InvDiscBase: Decimal;
        ChargeBase: Decimal;
        FreightAmount: Decimal;
        CurrencyFactor: Decimal;
        CurrencyDate: Date;
        ShouldGetCustInvDisc: Boolean;
        ServiceChargeLbl: Label 'Service Charge';
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Quote, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) then
            exit;

        if SalesHeader."IDYS Freight Amount" = 0 then
            exit;

        // Get main source line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if not SalesLine.FindFirst() then
            exit;

        SalesLine.LockTable();
        SalesHeader.TestField("Customer Posting Group");
        CustPostingGr.Get(SalesHeader."Customer Posting Group");

        SalesLine2.Reset();
        SalesLine2.SetRange("Document Type", SalesLine."Document Type");
        SalesLine2.SetRange("Document No.", SalesLine."Document No.");
        SalesLine2.SetRange("System-Created Entry", true);
        SalesLine2.SetRange(Type, SalesLine2.Type::"G/L Account");
        SalesLine2.SetRange("No.", CustPostingGr."Service Charge Acc.");
        if SalesLine2.FindSet(true) then
            repeat
                SalesLine2."Unit Price" := 0;
                SalesLine2.Modify();
                TempServiceChargeLine := SalesLine2;
                TempServiceChargeLine.Insert();
            until SalesLine2.Next() = 0;

        SalesLine2.Reset();
        SalesLine2.SetRange("Document Type", SalesLine."Document Type");
        SalesLine2.SetRange("Document No.", SalesLine."Document No.");
        SalesLine2.SetFilter(Type, '<>0');
        if SalesLine2.FindFirst() then;
        SalesLine2.CalcVATAmountLines(0, SalesHeader, SalesLine2, TempVATAmountLine);
        InvDiscBase :=
          TempVATAmountLine.GetTotalInvDiscBaseAmount(
            SalesHeader."Prices Including VAT", SalesHeader."Currency Code");
        ChargeBase :=
          TempVATAmountLine.GetTotalLineAmount(
            SalesHeader."Prices Including VAT", SalesHeader."Currency Code");

        if UpdateHeader then
            SalesHeader.Modify();

        if SalesHeader."Posting Date" = 0D then
            CurrencyDate := WorkDate()
        else
            CurrencyDate := SalesHeader."Posting Date";

        CustInvDisc.GetRec(
          SalesHeader."Invoice Disc. Code", SalesHeader."Currency Code", CurrencyDate, ChargeBase);

        Currency.Initialize(SalesHeader."Currency Code");
        if not CustInvDisc."IDYS Add Calc. Freight Costs" then
            exit;

        // Freight Cost
        if SalesHeader."Currency Code" <> '' then begin
            CurrencyFactor := CurrExchRate.ExchangeRate(CurrencyDate, Currency.Code);
            FreightAmount :=
                Round(CurrExchRate.ExchangeAmtLCYToFCY(
                    CurrencyDate, SalesHeader."Currency Code", SalesHeader."IDYS Freight Amount", CurrencyFactor),
                Currency."Amount Rounding Precision");
        end else
            FreightAmount := Round(SalesHeader."IDYS Freight Amount", Currency."Amount Rounding Precision");

        // Surcharge
        FreightAmount += CustInvDisc."Service Charge";
        if CustInvDisc."IDYS Surcharge %" > 0 then
            FreightAmount *= (CustInvDisc."IDYS Surcharge %" / 100 + 1);

        CustInvDisc."Service Charge" := Round(FreightAmount, Currency."Amount Rounding Precision");

        if CustInvDisc."Service Charge" <> 0 then begin
            if not UpdateHeader then
                SalesLine2.SetSalesHeader(SalesHeader);
            if not TempServiceChargeLine.IsEmpty() then begin
                TempServiceChargeLine.FindLast();
                SalesLine2.Get(SalesLine."Document Type", SalesLine."Document No.", TempServiceChargeLine."Line No.");
                SetSalesLineServiceCharge(SalesHeader, SalesLine2, CustInvDisc, Currency);
                SalesLine2.Modify();
            end else begin
                SalesLine2.Reset();
                SalesLine2.SetRange("Document Type", SalesLine."Document Type");
                SalesLine2.SetRange("Document No.", SalesLine."Document No.");
                SalesLine2.FindLast();
                SalesLine2.Init();
                if not UpdateHeader then
                    SalesLine2.SetSalesHeader(SalesHeader);
                SalesLine2."Line No." := SalesLine2."Line No." + 10000;
                SalesLine2."System-Created Entry" := true;
                SalesLine2.Type := SalesLine2.Type::"G/L Account";
                SalesLine2.Validate("No.", CustPostingGr.GetServiceChargeAccount());
                SalesLine2.Description := ServiceChargeLbl;
                SalesLine2.Validate(Quantity, 1);

                if SalesLine2."Document Type" in
                    [SalesLine2."Document Type"::"Return Order", SalesLine2."Document Type"::"Credit Memo"]
                then
                    SalesLine2.Validate("Return Qty. to Receive", SalesLine2.Quantity)
                else
                    SalesLine2.Validate("Qty. to Ship", SalesLine2.Quantity);
                SetSalesLineServiceCharge(SalesHeader, SalesLine2, CustInvDisc, Currency);
                SalesLine2.Insert();
            end;
            SalesLine2.CalcVATAmountLines(0, SalesHeader, SalesLine2, TempVATAmountLine);
        end else
            if TempServiceChargeLine.FindSet(false, false) then
                repeat
                    if (TempServiceChargeLine."Shipment No." = '') and (TempServiceChargeLine."Qty. Shipped Not Invoiced" = 0) then begin
                        SalesLine2 := TempServiceChargeLine;
                        SalesLine2.Delete(true);
                    end;
                until TempServiceChargeLine.Next() = 0;

        if CustInvDiscRecExists(SalesHeader."Invoice Disc. Code") then begin
            ShouldGetCustInvDisc := InvDiscBase <> ChargeBase;
            if ShouldGetCustInvDisc then
                CustInvDisc.GetRec(
                  SalesHeader."Invoice Disc. Code", SalesHeader."Currency Code", CurrencyDate, InvDiscBase);

            DiscountNotificationMgt.NotifyAboutMissingSetup(
              SalesSetup.RecordId, SalesHeader."Gen. Bus. Posting Group", SalesLine2."Gen. Prod. Posting Group",
              SalesSetup."Discount Posting", SalesSetup."Discount Posting"::"Line Discounts");

            UpdateSalesHeaderInvoiceDiscount(SalesHeader, TempVATAmountLine, SalesSetup."Calc. Inv. Disc. per VAT ID", CustInvDisc, UpdateHeader);

            SalesLine2.SetSalesHeader(SalesHeader);
            SalesLine2.UpdateVATOnLines(0, SalesHeader, SalesLine2, TempVATAmountLine);
            UpdatePrepmtLineAmount(SalesHeader);
        end;

        SalesCalcDiscountByType.ResetRecalculateInvoiceDisc(SalesHeader);
        IsHandled := true;
    end;

    local procedure SetSalesLineServiceCharge(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CustInvoiceDisc: record "Cust. Invoice Disc."; Currency: Record Currency)
    begin
        if SalesHeader."Prices Including VAT" then
            SalesLine.Validate(
                "Unit Price",
                Round((1 + SalesLine."VAT %" / 100) * CustInvoiceDisc."Service Charge", Currency."Unit-Amount Rounding Precision"))
        else
            SalesLine.Validate("Unit Price", CustInvoiceDisc."Service Charge");
    end;

    local procedure CustInvDiscRecExists(InvDiscCode: Code[20]): Boolean
    var
        CustInvDisc: Record "Cust. Invoice Disc.";
    begin
        CustInvDisc.SetRange(Code, InvDiscCode);
        exit(CustInvDisc.FindFirst());
    end;

    local procedure UpdateSalesHeaderInvoiceDiscount(var SalesHeader: Record "Sales Header"; var TempVATAmountLine: Record "VAT Amount Line" temporary; CalcInvDiscPerVATID: Boolean; var CustInvDisc: Record "Cust. Invoice Disc."; var UpdateHeader: Boolean)
    begin
        SalesHeader."Invoice Discount Calculation" := SalesHeader."Invoice Discount Calculation"::"%";
        SalesHeader."Invoice Discount Value" := CustInvDisc."Discount %";
        if UpdateHeader then
            SalesHeader.Modify();

        TempVATAmountLine.SetInvoiceDiscountPercent(
          CustInvDisc."Discount %", SalesHeader."Currency Code",
          SalesHeader."Prices Including VAT", CalcInvDiscPerVATID,
          SalesHeader."VAT Base Discount %");
    end;

    local procedure UpdatePrepmtLineAmount(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        if (SalesHeader."Invoice Discount Calculation" = SalesHeader."Invoice Discount Calculation"::"%") and
           (SalesHeader."Prepayment %" > 0) and (SalesHeader."Invoice Discount Value" > 0) and
           (SalesHeader."Invoice Discount Value" + SalesHeader."Prepayment %" >= 100)
        then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindSet(true) then
                repeat
                    if not SalesLine.ZeroAmountLine(0) and (SalesLine."Prepayment %" = SalesHeader."Prepayment %") then begin
                        SalesLine."Prepmt. Line Amount" := SalesLine.Amount;
                        SalesLine.Modify();
                    end;
                until SalesLine.Next() = 0;
        end;
    end;

#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Calc. Discount", 'OnCalculateInvoiceDiscountOnBeforeCheckCustInvDiscServiceCharge', '', true, false)]
#if BC18
    local procedure SalesCalcDiscount_OnBeforeSetSalesLineServiceCharge(var SalesHeader: Record "Sales Header"; var CustInvoiceDisc: Record "Cust. Invoice Disc.")
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyFactor: Decimal;
        FreightAmount: Decimal;
        CurrencyDate: Date;
    begin
        if SalesHeader."Posting Date" = 0D then
            CurrencyDate := WorkDate()
        else
            CurrencyDate := SalesHeader."Posting Date";
#else
    local procedure SalesCalcDiscount_OnBeforeSetSalesLineServiceCharge(var SalesHeader: Record "Sales Header"; var CustInvoiceDisc: Record "Cust. Invoice Disc."; CurrencyDate: Date)
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyFactor: Decimal;
        FreightAmount: Decimal;
    begin
#endif
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Quote, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) then
            exit;

        if SalesHeader."IDYS Freight Amount" = 0 then
            exit;

        if not CustInvoiceDisc."IDYS Add Calc. Freight Costs" then
            exit;

        Currency.Initialize(SalesHeader."Currency Code");

        // Freight Cost
        if SalesHeader."Currency Code" <> '' then begin
            CurrencyFactor := CurrExchRate.ExchangeRate(CurrencyDate, Currency.Code);
            FreightAmount :=
                Round(CurrExchRate.ExchangeAmtLCYToFCY(
                    CurrencyDate, SalesHeader."Currency Code", SalesHeader."IDYS Freight Amount", CurrencyFactor),
                Currency."Amount Rounding Precision");
        end else
            FreightAmount := Round(SalesHeader."IDYS Freight Amount", Currency."Amount Rounding Precision");

        // Surcharge
        FreightAmount += CustInvoiceDisc."Service Charge";
        if CustInvoiceDisc."IDYS Surcharge %" > 0 then
            FreightAmount *= (CustInvoiceDisc."IDYS Surcharge %" / 100 + 1);

        CustInvoiceDisc."Service Charge" := Round(FreightAmount, Currency."Amount Rounding Precision");
    end;
#endif

    #region [Attachments]
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', false, false)]
    local procedure OnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef);
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        case DocumentAttachment."Table ID" of
            DATABASE::"IDYS Transport Order Header":
                begin
                    RecRef.Open(DATABASE::"IDYS Transport Order Header");
                    if TransportOrderHeader.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(TransportOrderHeader);
                end;
        end;
    end;
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", 'OnAfterGetRefTable', '', false, false)]
    local procedure DocumentAttachmentMgmt_OnAfterGetRefTable(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef);
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        case DocumentAttachment."Table ID" of
            Database::"IDYS Transport Order Header":
                begin
                    RecRef.Open(DATABASE::"IDYS Transport Order Header");
                    if TransportOrderHeader.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(TransportOrderHeader);
                end;
        end;
    end;
#endif

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure OnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef);
    begin
        case RecRef.Number of
            DATABASE::"IDYS Transport Order Header":
                DocumentAttachment.SetRange("No.", RecRef.Field(1).Value);
        end;
    end;

#if not BC17
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    begin
        case RecRef.Number of
            DATABASE::"IDYS Transport Order Header":
                DocumentAttachment.Validate("No.", RecRef.Field(1).Value);
        end;
    end;
#else
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeInsertAttachment', '', false, false)]
    local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    begin
        case RecRef.Number of
            DATABASE::"IDYS Transport Order Header":
                DocumentAttachment.Validate("No.", RecRef.Field(1).Value);
        end;
    end;
#endif
    #endregion

    #region [Copy Document]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesDocOnAfterCopySalesDocLines', '', false, false)]
    local procedure CopyDocumentMgt_OnCopySalesDocOnAfterCopySalesDocLines(var ToSalesHeader: Record "Sales Header")
    var
        ToSalesLine: Record "Sales Line";
    begin
        // Clear Sales Lines fields
        ToSalesLine.SetRange("Document Type", ToSalesHeader."Document Type");
        ToSalesLine.SetRange("Document No.", ToSalesHeader."No.");
        ToSalesLine.ModifyAll("IDYS Tracking No.", '');
        ToSalesLine.ModifyAll("IDYS Tracking URL", '');
        ToSalesLine.ModifyAll("IDYS Transport Value", 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesHeader', '', false, false)]
    local procedure CopyDocumentMgt_OnAfterCopySalesHeader(FromSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; var ToSalesHeader: Record "Sales Header")
    var
        FromIDYSSourceDocumentPackage: Record "IDYS Source Document Package";
        ToIDYSSourceDocumentPackage: Record "IDYS Source Document Package";
        FromIDYSSourceDocumentService: Record "IDYS Source Document Service";
        ToIDYSSourceDocumentService: Record "IDYS Source Document Service";
        ConfirmManagement: Codeunit "Confirm Management";
        EmptyGuid: Guid;
        DeleteSoureDocumentPackageLinesQst: Label 'The existing source document package lines for %1 %2 will be deleted.\\Do you want to continue?', Comment = '%1=Document type, e.g. Invoice. %2=Document No., e.g. 001';
    begin
        // Clear Sales Header fields 
        ToSalesHeader."IDYS Tracking No." := '';
        ToSalesHeader."IDYS Tracking URL" := '';
        ToSalesHeader."IDYS Whse Post Batch ID" := EmptyGuid;

        // Delete Existing Source Document Services
        ToIDYSSourceDocumentService.SetRange("Table No.", Database::"Sales Header");
        ToIDYSSourceDocumentService.SetRange("Document Type", ToSalesHeader."Document Type");
        ToIDYSSourceDocumentService.SetRange("Document No.", ToSalesHeader."No.");
        if not ToIDYSSourceDocumentService.IsEmpty() then
            ToIDYSSourceDocumentService.DeleteAll();

        // Copy Source Document Services
        ToIDYSSourceDocumentService.Reset();
        FromIDYSSourceDocumentService.SetRange("Table No.", Database::"Sales Header");
        FromIDYSSourceDocumentService.SetRange("Document Type", FromSalesHeader."Document Type");
        FromIDYSSourceDocumentService.SetRange("Document No.", FromSalesHeader."No.");
        if FromIDYSSourceDocumentService.FindSet() then
            repeat
                ToIDYSSourceDocumentService.Init();
                ToIDYSSourceDocumentService.TransferFields(FromIDYSSourceDocumentService);
                ToIDYSSourceDocumentService."Table No." := Database::"Sales Header";
                ToIDYSSourceDocumentService."Document Type" := ToSalesHeader."Document Type";
                ToIDYSSourceDocumentService."Document No." := ToSalesHeader."No.";
                ToIDYSSourceDocumentService.Insert(true);
            until FromIDYSSourceDocumentService.Next() = 0;

#if not (BC17 or BC18 or BC19 or BC20)
        // Copy Source Document Packages
        if not OldSalesHeader."IDYS Copy Source Doc. Packages" then
            exit;
#endif

        // Delete Existing Source Document Packages 
        ToIDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        ToIDYSSourceDocumentPackage.SetRange("Document Type", ToSalesHeader."Document Type");
        ToIDYSSourceDocumentPackage.SetRange("Document No.", ToSalesHeader."No.");
        if not ToIDYSSourceDocumentPackage.IsEmpty() then
            if ConfirmManagement.GetResponseOrDefault(StrSubstNo(DeleteSoureDocumentPackageLinesQst, ToSalesHeader."Document Type", ToSalesHeader."No."), true) then
                ToIDYSSourceDocumentPackage.DeleteAll()
            else
                exit;

        ToIDYSSourceDocumentPackage.Reset();
        FromIDYSSourceDocumentPackage.SetRange("Table No.", Database::"Sales Header");
        FromIDYSSourceDocumentPackage.SetRange("Document Type", FromSalesHeader."Document Type");
        FromIDYSSourceDocumentPackage.SetRange("Document No.", FromSalesHeader."No.");
        if FromIDYSSourceDocumentPackage.FindSet() then
            repeat
                ToIDYSSourceDocumentPackage.Init();
                ToIDYSSourceDocumentPackage.TransferFields(FromIDYSSourceDocumentPackage);
                ToIDYSSourceDocumentPackage."Table No." := Database::"Sales Header";
                ToIDYSSourceDocumentPackage."Document Type" := ToSalesHeader."Document Type";
                ToIDYSSourceDocumentPackage."Document No." := ToSalesHeader."No.";
                ToIDYSSourceDocumentPackage.Insert(true);
            until FromIDYSSourceDocumentPackage.Next() = 0;
    end;

#if not (BC17 or BC18 or BC19 or BC20)
    [EventSubscriber(ObjectType::Report, Report::"Copy Sales Document", 'OnAfterValidateIncludeHeaderProcedure', '', false, false)]
    local procedure CopySalesDocument_OnAfterValidateIncludeHeaderProcedure(sender: Report "Copy Sales Document";

    var
        IncludeHeader: Boolean;

    var
        RecalculateLines: Boolean)
    begin
        if not IncludeHeader and sender.IDYSGetCopySourceDocPackages() then
            sender.IDYSSetCopySourceDocPackages(false);
        sender.IDYSSetCopySourceDocPackagesEnabled(IncludeHeader);
    end;
#endif
    #endregion
    var
        IDYSRefIntegrityMgt: Codeunit "IDYS Ref. Integrity Mgt.";
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
}

