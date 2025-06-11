codeunit 11147669 "IDYS Serv. Doc. Mgt. Events"
{
    Permissions = tabledata "IDYS Source Document Service" = RIMD;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforePostWithLines', '', true, false)]
    local procedure ServicePost_OnBeforePostWithLines(var PassedServHeader: Record "Service Header"; var PassedShip: Boolean)
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        Setup: Record "IDYS Setup";
    begin
        if not PassedShip then
            exit;

        if PassedServHeader."Document Type" <> PassedServHeader."Document Type"::Order then
            exit;
        if Setup.Get() then
            if (Setup."Base Transport Orders on" = Setup."Base Transport Orders on"::"Posted documents") and
               (Setup."After Posting Service Orders" <> Setup."After Posting Service Orders"::"Do nothing")
            then begin
                PassedServHeader.TestField("Shipping Agent Code");
                PassedServHeader.TestField("Shipping Agent Service Code");
                if IDYSProviderMgt.CheckShipmentMethodCode(PassedServHeader."IDYS Provider") then
                    PassedServHeader.TestField("Shipment Method Code");
                ShippingAgentServices.Get(PassedServHeader."Shipping Agent Code", PassedServHeader."Shipping Agent Service Code");
                ShippingAgentServices.TestField(ShippingAgentServices."Shipping Time");
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnBeforeServShptHeaderInsert', '', true, false)]
    local procedure ServDocumentsMgt_OnBeforeServShptHeaderInsert(var ServiceShipmentHeader: Record "Service Shipment Header"; ServiceHeader: Record "Service Header")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;
        ServiceShipmentHeader."IDYS Tracking No." := ServiceHeader."IDYS Tracking No.";
        ServiceShipmentHeader."IDYS Tracking Url" := ServiceHeader."IDYS Tracking Url";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnAfterServShptHeaderInsert', '', true, false)]
    local procedure ServDocumentsMgt_OnAfterServShptHeaderInsert(var ServiceShipmentHeader: Record "Service Shipment Header"; ServiceHeader: Record "Service Header")
    var
        IDYSSourceDocumentService: Record "IDYS Source Document Service";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;
        IDYSSourceDocumentService.CopyServiceLevels(Database::"Service Header", ServiceHeader."Document Type", ServiceHeader."No.", Database::"Service Shipment Header", "IDYS Source Document Type"::"0", ServiceShipmentHeader."No.")
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnBeforeServShptLineInsert', '', true, false)]
    local procedure ServDocumentsMgt_OnBeforeServShptLineInsert(var ServiceShipmentLine: Record "Service Shipment Line"; ServiceLine: Record "Service Line")
    begin
        ServiceShipmentLine."IDYS Quantity To Send" := ServiceShipmentLine."Quantity (Base)";
        ServiceShipmentLine."IDYS Tracking No." := ServiceLine."IDYS Tracking No.";
        ServiceShipmentLine."IDYS Tracking Url" := ServiceLine."IDYS Tracking URL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnAfterFinalizeShipmentDocument', '', true, false)]
    local procedure ServDocumentsMgt_OnAfterFinalizeShipmentDocument(var ServiceShipmentHeader: Record "Service Shipment Header")
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        IDYSSetup.Get();
        if IDYSSetup."After Posting Service Orders" = IDYSSetup."After Posting Service Orders"::"Do nothing" then
            exit;
        IDYSDocumentManagement.ServiceShipment_CreateTransportOrder(ServiceShipmentHeader, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Amounts Mgt.", 'OnAfterDivideAmount', '', true, false)]
    local procedure ServAmountsMgt_OnAfterDivideAmount(var ServiceLine: Record "Service Line")
    begin
        ServiceLine."IDYS Transport Value" := ServiceLine."Line Amount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterPostServiceDoc', '', true, false)]
    local procedure ServicePost_OnAfterPostServiceDoc(var ServiceHeader: Record "Service Header"; ServShipmentNo: Code[20])
    var
        IDYSSetup: Record "IDYS Setup";
        BatchProcessingSessionMap: Record "Batch Processing Session Map";
        IDYSCreateTptOrdWrksh: Codeunit "IDYS Create Tpt. Ord. (Wrksh.)";
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;
        if ServShipmentNo = '' then
            exit;

        if ServiceHeader."Document Type" <> ServiceHeader."Document Type"::Order then
            exit;

        IDYSSetup.Get();
        if IDYSSetup."After Posting Service Orders" = IDYSSetup."After Posting Service Orders"::"Do nothing" then
            exit;

        if not IsNullGuid(ServiceHeader."IDYS Whse Post Batch ID") then begin
            IDYSCreateTptOrdWrksh.UpdateBatchIDOnRegister(Database::"Service Shipment Header", ServShipmentNo, ServiceHeader.RecordId, ServiceHeader."IDYS Whse Post Batch ID");
            exit;
        end;

        BatchProcessingSessionMap.SetRange("Record ID", ServiceHeader.RecordId);
        BatchProcessingSessionMap.SetRange("User ID", UserSecurityId());
        BatchProcessingSessionMap.SetRange("Session ID", SessionId());
        if BatchProcessingSessionMap.FindFirst() then
            IDYSCreateTptOrdWrksh.UpdateBatchIDOnRegister(Database::"Service Shipment Header", ServShipmentNo, ServiceHeader.RecordId, BatchProcessingSessionMap."Batch ID")
        else
            IDYSCreateTptOrdWrksh.ConvertRegisterIntoListAndShowTransportOrder(Database::"Service Shipment Header", ServShipmentNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Shipping Agent Code', false, false)]
    local procedure ServiceHeader_OnAfterValidateShippingAgentCode(var Rec: Record "Service Header")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        Rec."IDYS Shipping Agent Code" := Rec."Shipping Agent Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Shipping Agent Service Code', false, false)]
    local procedure ServiceHeader_OnAfterValidateShippingAgentServiceCode(var Rec: Record "Service Header")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        Rec."IDYS Shipping Agent Srv Code" := Rec."Shipping Agent Service Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Shipment Method Code', false, false)]
    local procedure ServiceHeader_OnAfterValidateShipmentMethodCode(var Rec: Record "Service Header")
    begin
        if not IDYSSessionVariables.SetupIsCompleted() then
            exit;

        Rec."IDYS Shipment Method Code" := Rec."Shipment Method Code";
    end;

    var
        IDYSSessionVariables: Codeunit "IDYS Session Variables";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
}