codeunit 11147665 "IDYS Sales Post Events"
{
    Permissions = tabledata "IDYS Source Document Service" = RIMD;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, false)]
    local procedure SalesPost_OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        Setup: Record "IDYS Setup";
    begin
        if not SalesHeader.Ship and not SalesHeader.Receive then
            exit;

        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order]) then
            exit;

        if not Setup.Get() then
            exit;

        if Setup."Base Transport Orders on" = Setup."Base Transport Orders on"::"Posted documents" then
            if ((SalesHeader."Document Type" = SalesHeader."Document Type"::Order) and (Setup."After Posting Sales Orders" <> Setup."After Posting Sales Orders"::"Do Nothing")) then begin
                SalesHeader.TestField("Shipping Agent Code");
                SalesHeader.TestField("Shipping Agent Service Code");
                if IDYSProviderMgt.CheckShipmentMethodCode(SalesHeader."IDYS Provider") then
                    SalesHeader.TestField("Shipment Method Code");
                ShippingAgentServices.Get(SalesHeader."Shipping Agent Code", SalesHeader."Shipping Agent Service Code");
                ShippingAgentServices.TestField(ShippingAgentServices."Shipping Time");
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptHeaderInsert', '', true, false)]
    local procedure SalesPost_OnBeforeSalesShptHeaderInsert(var SalesShptHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        SalesShptHeader."IDYS E-Mail Type" := SalesHeader."IDYS E-Mail Type";
        SalesShptHeader."IDYS Cost Center" := SalesHeader."IDYS Cost Center";
        SalesShptHeader."IDYS Account No." := SalesHeader."IDYS Account No.";
        SalesShptHeader."IDYS Account No. (Bill-to)" := SalesHeader."IDYS Account No. (Bill-to)";
        SalesShptHeader."IDYS Do Not Insure" := SalesHeader."IDYS Do Not Insure";
        SalesShptHeader."IDYS Tracking No." := SalesHeader."IDYS Tracking No.";
        SalesShptHeader."IDYS Tracking URL" := SalesHeader."IDYS Tracking URL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesShptHeaderInsert', '', true, false)]
    local procedure SalesPost_OnAfterSalesShptHeaderInsert(var SalesShipmentHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header")
    var
        IDYSSourceDocumentService: Record "IDYS Source Document Service";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;
        IDYSSourceDocumentService.CopyServiceLevels(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", Database::"Sales Shipment Header", "IDYS Source Document Type"::"0", SalesShipmentHeader."No.")
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptLineInsert', '', true, false)]
    local procedure SalesPost_OnBeforeSalesShptLineInsert(var SalesShptLine: Record "Sales Shipment Line"; SalesLine: Record "Sales Line")
    begin
        SalesShptLine."IDYS Quantity To Send" := SalesShptLine."Quantity (Base)";
        SalesShptLine."IDYS Tracking No." := SalesLine."IDYS Tracking No.";
        SalesShptLine."IDYS Tracking Url" := SalesLine."IDYS Tracking No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterDivideAmount', '', true, false)]
    local procedure SalesPost_OnAfterDivideAmount(var SalesLine: Record "Sales Line")
    var
        SalesLine2: Record "Sales Line";
    begin
        if SalesLine2.Get(SalesLine.RecordId) then
            SalesLine."IDYS Transport Value" := SalesLine2.GetLineAmountToHandle(SalesLine."Qty. to Ship");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', true, false)]
    local procedure SalesPost_OnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var ReturnReceiptHeader: Record "Return Receipt Header")
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order]) then
            exit;

        if (SalesShipmentHeader."No." = '') then
            exit;

        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        IDYSSetup.Get();
        if (SalesShipmentHeader."No." <> '') and (IDYSSetup."After Posting Sales Orders" = IDYSSetup."After Posting Sales Orders"::"Do nothing") then
            exit;
        if SalesShipmentHeader."No." <> '' then
            IDYSDocumentManagement.SalesShipment_CreateTransportOrder(SalesShipmentHeader, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, false)]
    local procedure SalesPost_OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20])
    var
        IDYSSetup: Record "IDYS Setup";
        BatchProcessingSessionMap: Record "Batch Processing Session Map";
        IDYSCreateTptOrdWrksh: Codeunit "IDYS Create Tpt. Ord. (Wrksh.)";
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order]) then
            exit;

        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if (SalesShptHdrNo = '') then
            exit;

        IDYSSetup.Get();
        if (SalesShptHdrNo <> '') and (IDYSSetup."After Posting Sales Orders" = IDYSSetup."After Posting Sales Orders"::"Do nothing") then
            exit;

        if not IsNullGuid(SalesHeader."IDYS Whse Post Batch ID") then begin
            if SalesShptHdrNo <> '' then
                IDYSCreateTptOrdWrksh.UpdateBatchIDOnRegister(Database::"Sales Shipment Header", SalesShptHdrNo, SalesHeader.RecordId, SalesHeader."IDYS Whse Post Batch ID");
            exit;
        end;

        BatchProcessingSessionMap.SetRange("Record ID", SalesHeader.RecordId);
        BatchProcessingSessionMap.SetRange("User ID", UserSecurityId());
        BatchProcessingSessionMap.SetRange("Session ID", SessionId());
        if BatchProcessingSessionMap.FindFirst() then begin
            if SalesShptHdrNo <> '' then
                IDYSCreateTptOrdWrksh.UpdateBatchIDOnRegister(Database::"Sales Shipment Header", SalesShptHdrNo, SalesHeader.RecordId, BatchProcessingSessionMap."Batch ID");
        end else
            if SalesShptHdrNo <> '' then
                IDYSCreateTptOrdWrksh.ConvertRegisterIntoListAndShowTransportOrder(Database::"Sales Shipment Header", SalesShptHdrNo);
    end;

    var
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
}