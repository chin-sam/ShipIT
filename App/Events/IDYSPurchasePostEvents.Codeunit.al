codeunit 11147667 "IDYS Purchase Post Events"
{
    Permissions = tabledata "IDYS Source Document Service" = RIMD;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', true, false)]
    local procedure PurchPost_OnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header")
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        Setup: Record "IDYS Setup";
    begin
        if not PurchaseHeader.Ship then
            exit;
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::"Return Order" then
            exit;
        if Setup.Get() then
            if (Setup."Base Transport Orders on" = Setup."Base Transport Orders on"::"Posted documents") and
               (Setup."After Posting Purch. Ret. Ord." <> Setup."After Posting Purch. Ret. Ord."::"Do nothing")
            then begin
                PurchaseHeader.TestField("IDYS Shipping Agent Code");
                PurchaseHeader.TestField("IDYS Shipping Agent Srv Code");
                if IDYSProviderMgt.CheckShipmentMethodCode(PurchaseHeader."IDYS Provider") then
                    PurchaseHeader.TestField("Shipment Method Code");
                ShippingAgentServices.Get(PurchaseHeader."IDYS Shipping Agent Code", PurchaseHeader."IDYS Shipping Agent Srv Code");
                ShippingAgentServices.TestField(ShippingAgentServices."Shipping Time");
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeReturnShptHeaderInsert', '', true, false)]
    local procedure PurchasePost_OnBeforeReturnShptHeaderInsert(var ReturnShptHeader: Record "Return Shipment Header"; var PurchHeader: Record "Purchase Header")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if PurchHeader."Document Type" = PurchHeader."Document Type"::"Return Order" then begin
            ReturnShptHeader."IDYS E-Mail Type" := PurchHeader."IDYS E-Mail Type";
            ReturnShptHeader."IDYS Cost Center" := PurchHeader."IDYS Cost Center";
            ReturnShptHeader."IDYS Account No." := PurchHeader."IDYS Account No.";
            ReturnShptHeader."IDYS Account No. (Bill-to)" := PurchHeader."IDYS Acc. No. (Bill-to)";
            ReturnShptHeader."IDYS Do Not Insure" := PurchHeader."IDYS Do Not Insure";
            ReturnShptHeader."IDYS Tracking No." := PurchHeader."IDYS Tracking No.";
            ReturnShptHeader."IDYS Tracking URL" := PurchHeader."IDYS Tracking URL";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterReturnShptHeaderInsert', '', true, false)]
    local procedure PurchasePost_OnAfterReturnShptHeaderInsert(var PurchHeader: Record "Purchase Header"; var ReturnShptHeader: Record "Return Shipment Header")
    var
        IDYSSourceDocumentService: Record "IDYS Source Document Service";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;
        if PurchHeader."Document Type" = PurchHeader."Document Type"::"Return Order" then
            IDYSSourceDocumentService.CopyServiceLevels(Database::"Purchase Header", PurchHeader."Document Type", PurchHeader."No.", Database::"Return Shipment Header", "IDYS Source Document Type"::"0", ReturnShptHeader."No.")
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeReturnShptLineInsert', '', true, false)]
    local procedure PurchasePost_OnBeforeReturnShptLineInsert(var ReturnShptLine: Record "Return Shipment Line"; var PurchLine: Record "Purchase Line")
    begin
        ReturnShptLine."IDYS Quantity To Send" := ReturnShptLine."Quantity (Base)";
        ReturnShptLine."IDYS Tracking No." := PurchLine."IDYS Tracking No.";
        ReturnShptLine."IDYS Tracking URL" := PurchLine."IDYS Tracking URL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterDivideAmount', '', true, false)]
    local procedure PurchasePost_OnAfterDivideAmount(var PurchLine: Record "Purchase Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseLine.Get(PurchLine.RecordId) then
            PurchLine."IDYS Transport Value" := PurchaseLine.GetLineAmountToHandle(PurchLine."Qty. to Receive");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', true, false)]
    local procedure PurchasePost_OnAfterFinalizePostingOnBeforeCommit(var PurchHeader: Record "Purchase Header"; var ReturnShptHeader: Record "Return Shipment Header")
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if ReturnShptHeader."No." = '' then
            exit;

        if PurchHeader."Document Type" <> PurchHeader."Document Type"::"Return Order" then
            exit;

        IDYSSetup.Get();
        if IDYSSetup."After Posting Purch. Ret. Ord." = IDYSSetup."After Posting Purch. Ret. Ord."::"Do nothing" then
            exit;
        IDYSDocumentManagement.ReturnShipment_CreateTransportOrder(ReturnShptHeader, true);
        //TODO: Include PostCombineSalesOrderShipment code here.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', true, false)]
    local procedure PurchPost_OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; RetShptHdrNo: Code[20])
    var
        IDYSSetup: Record "IDYS Setup";
        BatchProcessingSessionMap: Record "Batch Processing Session Map";
        IDYSCreateTptOrdWrksh: Codeunit "IDYS Create Tpt. Ord. (Wrksh.)";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        if RetShptHdrNo = '' then
            exit;

        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::"Return Order" then
            exit;

        IDYSSetup.Get();
        if (IDYSSetup."After Posting Purch. Ret. Ord." = IDYSSetup."After Posting Purch. Ret. Ord."::"Do nothing") then
            exit;

        if not IsNullGuid(PurchaseHeader."IDYS Whse Post Batch ID") then begin
            IDYSCreateTptOrdWrksh.UpdateBatchIDOnRegister(Database::"Return Shipment Header", RetShptHdrNo, PurchaseHeader.RecordId, PurchaseHeader."IDYS Whse Post Batch ID");
            exit;
        end;
        BatchProcessingSessionMap.SetRange("Record ID", PurchaseHeader.RecordId);
        BatchProcessingSessionMap.SetRange("User ID", UserSecurityId());
        BatchProcessingSessionMap.SetRange("Session ID", SessionId());
        if BatchProcessingSessionMap.FindFirst() then
            IDYSCreateTptOrdWrksh.UpdateBatchIDOnRegister(Database::"Return Shipment Header", RetShptHdrNo, PurchaseHeader.RecordId, BatchProcessingSessionMap."Batch ID")
        else
            IDYSCreateTptOrdWrksh.ConvertRegisterIntoListAndShowTransportOrder(Database::"Return Shipment Header", RetShptHdrNo);
    end;

    var
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
}