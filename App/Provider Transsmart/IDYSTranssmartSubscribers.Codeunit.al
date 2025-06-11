codeunit 11147697 "IDYS Transsmart Subscribers"
{
    #region [Insurance]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYS Create Tpt. Ord. (Wrksh.)", 'OnAfterAddLinesToNewTransportOrder', '', true, false)]
    local procedure IDYSCreateTptOrdWrksh_OnAfterAddLinesToNewTransportOrder(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    var
        TransOrderHeader: Record "IDYS Transport Order Header";
    begin
        if not IDYSProviderMgt.IsProvider("IDYS Provider"::Transsmart, TransportOrderHeader) then
            exit;
        if not IDYSProviderMgt.IsInsuranceEnabled("IDYS Provider"::Transsmart) then
            exit;
        if TransportWorksheetLine."Do Not Insure" then
            exit;
        if not TransOrderHeader.Get(TransportOrderHeader.RecordId) then
            exit;
        if TransOrderHeader.Status <> TransOrderHeader.Status::New then
            exit;

        if IDYSTranssmartAPIDocsMgt.IsInsuranceApplicable(TransOrderHeader) then begin
            TransOrderHeader.Insure := true;
            TransOrderHeader.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYS Create Tpt. Ord. (Wrksh.)", 'OnAfterAddLinesToExistingTransportOrder', '', true, false)]
    local procedure IDYSCreateTptOrdWrksh_OnAfterAddLinesToExistingTransportOrder(var TransportOrderHeader: Record "IDYS Transport Order Header"; var TransportWorksheetLine: Record "IDYS Transport Worksheet Line")
    var
        TransOrderHeader: Record "IDYS Transport Order Header";
        Insure: Boolean;
    begin
        if not IDYSProviderMgt.IsProvider("IDYS Provider"::Transsmart, TransportOrderHeader) then
            exit;
        if not IDYSProviderMgt.IsInsuranceEnabled("IDYS Provider"::Transsmart) then
            exit;
        if TransportWorksheetLine."Do Not Insure" then
            exit;
        if not TransOrderHeader.Get(TransportOrderHeader.RecordId) then
            exit;
        if TransOrderHeader.Status <> TransOrderHeader.Status::New then
            exit;

        Insure := IDYSTranssmartAPIDocsMgt.IsInsuranceApplicable(TransOrderHeader);
        if TransOrderHeader.Insure <> Insure then begin
            TransOrderHeader.Insure := Insure;
            TransOrderHeader.Modify();
        end;
    end;
    #endregion

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSTranssmartAPIDocsMgt: Codeunit "IDYS Transsmart API Docs. Mgt.";
}