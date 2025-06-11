codeunit 11147708 "IDYS Cargoson Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::"IDYS Transport Order Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure IDYSTransportOrderHeader_OnBeforeInsert(var Rec: Record "IDYS Transport Order Header")
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        if not IDYSProviderMgt.IsProvider("IDYS Provider"::Cargoson, Rec) then
            exit;

        IDYSSetup.Get();
        Rec."Label Format" := IDYSSetup."Label Format";
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
}