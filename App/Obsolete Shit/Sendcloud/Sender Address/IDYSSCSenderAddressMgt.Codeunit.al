codeunit 11147699 "IDYS SC Sender Address Mgt."
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Sender Address removed';
    ObsoleteTag = '21.0';

    trigger OnRun()
    var
        Handled: Boolean;
    begin
        OnBeforeSyncSenderAddresses(Handled);

        if not Handled then
            SyncSenderAddresses();

        OnAfterSyncSenderAddresses();
    end;

    procedure SyncSenderAddresses();
    var
        TempIDYMRESTParameters: Record "IDYM REST Parameters" temporary;
        IDYMHTTPHelper: Codeunit "IDYM Http Helper";
        FinishedNotification: Notification;
        Statuscode: Integer;
        Response: JsonObject;
        ErrorMessage: Text;
        FinishedImportMsg: Label 'Finished synchronizing sender addresses.';
        CurrentSenderAddresses: List of [Guid];
    begin
        if GuiAllowed() then
            ProgressWindowDialog.Open('#1#######');

        TempIDYMRESTParameters.Init();
        TempIDYMRESTParameters.Accept := 'application/json';
        TempIDYMRESTParameters.RestMethod := TempIDYMRESTParameters.RestMethod::GET;
        TempIDYMRESTParameters.Path := '/user/addresses/sender';

        Statuscode := IDYMHTTPHelper.Execute(TempIDYMRESTParameters, "IDYM Endpoint Service"::Sendcloud, "IDYM Endpoint Usage"::Default);
        if Statuscode <> 200 then
            IDYMHTTPHelper.ParseError(TempIDYMRESTParameters, Statuscode, ErrorMessage, true)
        else begin
            Response := TempIDYMRESTParameters.GetResponseBodyAsJSON().AsObject();
            GetCurrentAddressesList(CurrentSenderAddresses);
            ProcessResponse(Response, CurrentSenderAddresses);
            CleanSenderAddresses(CurrentSenderAddresses);
        end;

        if GuiAllowed() then begin
            ProgressWindowDialog.Close();
            FinishedNotification.Message(FinishedImportMsg);
            FinishedNotification.Scope := NotificationScope::LocalScope;
            FinishedNotification.Send();
        end;
    end;

    local procedure GetCurrentAddressesList(var CurrentSenderAddresses: List of [Guid])
    var
        IDYSSCSenderAddress: Record "IDYS SC Sender Address";
    begin
        if IDYSSCSenderAddress.FindSet() then
            repeat
                CurrentSenderAddresses.Add(IDYSSCSenderAddress.SystemId);
            until IDYSSCSenderAddress.Next() = 0;
    end;

    local procedure CleanSenderAddresses(var CurrentSenderAddresses: List of [Guid])
    var
        IDYSSCSenderAddress: Record "IDYS SC Sender Address";
        AddrId: Guid;
    begin
        foreach AddrId in CurrentSenderAddresses do
            if IDYSSCSenderAddress.GetBySystemId(AddrId) then
                IDYSSCSenderAddress.Delete(true);
    end;

    local procedure ProcessResponse(Response: JsonObject; var CurrentSenderAddresses: List of [Guid])
    var
        SenderAddresses: JsonArray;
        IDYSSCSenderAddress: JsonToken;
        SyncingMsg: Label 'Syncing %1 of %2 Sender Addresses.', Comment = '%1 = is current record, %2 = total records.';
        i: Integer;
        x: Integer;
    begin
        if not Response.Contains('sender_addresses') then
            exit;

        SenderAddresses := IDYMJSONHelper.GetArray(Response, 'sender_addresses');

        Clear(i);
        x := SenderAddresses.Count();

        foreach IDYSSCSenderAddress in SenderAddresses do begin
            if GuiAllowed() then begin
                i += 1;
                ProgressWindowDialog.Update(1, StrSubstNo(SyncingMsg, i, x));
            end;
            ProcessSenderAddress(IDYSSCSenderAddress.AsObject(), CurrentSenderAddresses);
        end;
    end;

    local procedure ProcessSenderAddress(SenderAddr: JsonObject; var CurrentSenderAddresses: List of [Guid])
    var
        IDYSSCSenderAddress: Record "IDYS SC Sender Address";
    begin
        if not IDYSSCSenderAddress.Get(IDYMJSONHelper.GetIntegerValue(SenderAddr, 'id')) then begin
            IDYSSCSenderAddress.Init();
            IDYSSCSenderAddress.Id := IDYMJSONHelper.GetIntegerValue(SenderAddr, 'id');
            IDYSSCSenderAddress.Insert(true);
        end else
            CurrentSenderAddresses.Remove(IDYSSCSenderAddress.SystemId);

        IDYSSCSenderAddress.City := CopyStr(IDYMJSONHelper.GetTextValue(SenderAddr, 'city'), 1, MaxStrLen(IDYSSCSenderAddress.City));
        IDYSSCSenderAddress."Company Name" := CopyStr(IDYMJSONHelper.GetTextValue(SenderAddr, 'company_name'), 1, MaxStrLen(IDYSSCSenderAddress."Company Name"));
        IDYSSCSenderAddress."Contact Name" := CopyStr(IDYMJSONHelper.GetTextValue(SenderAddr, 'contact_name'), 1, MaxStrLen(IDYSSCSenderAddress."Contact Name"));
        IDYSSCSenderAddress.Country := CopyStr(IDYMJSONHelper.GetTextValue(SenderAddr, 'country'), 1, MaxStrLen(IDYSSCSenderAddress.Country));
        IDYSSCSenderAddress.Email := CopyStr(IDYMJSONHelper.GetTextValue(SenderAddr, 'email'), 1, MaxStrLen(IDYSSCSenderAddress.Email));
        IDYSSCSenderAddress."EORI Number" := CopyStr(IDYMJSONHelper.GetTextValue(SenderAddr, 'eori_number'), 1, MaxStrLen(IDYSSCSenderAddress."EORI Number"));
        IDYSSCSenderAddress."House Number" := CopyStr(IDYMJSONHelper.GetTextValue(SenderAddr, 'house_number'), 1, MaxStrLen(IDYSSCSenderAddress."House Number"));
        IDYSSCSenderAddress."Postal Box" := CopyStr(IDYMJSONHelper.GetTextValue(SenderAddr, 'postal_box'), 1, MaxStrLen(IDYSSCSenderAddress."Postal Box"));
        IDYSSCSenderAddress."Postal Code" := CopyStr(IDYMJSONHelper.GetCodeValue(SenderAddr, 'postal_code'), 1, MaxStrLen(IDYSSCSenderAddress."Postal Code"));
        IDYSSCSenderAddress.Street := CopyStr(IDYMJSONHelper.GetTextValue(SenderAddr, 'street'), 1, MaxStrLen(IDYSSCSenderAddress.Street));

        IDYSSCSenderAddress.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSyncSenderAddresses(var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSyncSenderAddresses();
    begin
    end;

    var
        IDYMJSONHelper: Codeunit "IDYM JSON Helper";
        ProgressWindowDialog: Dialog;
}