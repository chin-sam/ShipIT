codeunit 11147647 "IDYS Combinability Mgt."
{
    procedure GetHashForTransportWorkshtLine(TransportWorksheetLine: Record "IDYS Transport Worksheet Line"): Code[40];
    var
        Input: Text;
        Hash: Code[40];
        Handled: Boolean;
    begin
        OnBeforeGetHashForTransportWorkshtLine(TransportWorksheetLine, Input, Handled);
        if Handled then
            exit(GetMD5Hash(Input));

        Input :=
            TransportWorksheetLine."Shipping Agent Code" + '$' +
            TransportWorksheetLine."Shipping Agent Service Code" + '$' +
            TransportWorksheetLine."Shipment Method Code" + '$' +
            Format(TransportWorksheetLine.Book, 0, 9) + '$' +
            Format(TransportWorksheetLine."E-Mail Type") + '$' +
            Format(TransportWorksheetLine."Cost Center") + '$' +
            Format(TransportWorksheetLine."Preferred Shipment Date", 0, 9) + '$' +
            Format(TransportWorksheetLine."Preferred Delivery Date", 0, 9) + '$' +
            TransportWorksheetLine."Address (Pick-up)" + '$' +
            TransportWorksheetLine."Address 2 (Pick-up)" + '$' +
            TransportWorksheetLine."Post Code (Pick-up)" + '$' +
            TransportWorksheetLine."City (Pick-up)" + '$' +
            TransportWorksheetLine."County (Pick-up)" + '$' +
            TransportWorksheetLine."Country/Region Code (Pick-up)" + '$' +
            TransportWorksheetLine."VAT Registration No. (Pick-up)" + '$' +
            TransportWorksheetLine."Address (Ship-to)" + '$' +
            TransportWorksheetLine."Address 2 (Ship-to)" + '$' +
            TransportWorksheetLine."Post Code (Ship-to)" + '$' +
            TransportWorksheetLine."City (Ship-to)" + '$' +
            TransportWorksheetLine."County (Ship-to)" + '$' +
            TransportWorksheetLine."Country/Region Code (Ship-to)" + '$' +
            TransportWorksheetLine."VAT Registration No. (Ship-to)" + '$' +
            TransportWorksheetLine."Address (Invoice)" + '$' +
            TransportWorksheetLine."Address 2 (Invoice)" + '$' +
            TransportWorksheetLine."Post Code (Invoice)" + '$' +
            TransportWorksheetLine."City (Invoice)" + '$' +
            TransportWorksheetLine."County (Invoice)" + '$' +
            TransportWorksheetLine."Country/Region Code (Invoice)" + '$' +
            TransportWorksheetLine."VAT Registration No. (Invoice)";

        Hash := GetMD5Hash(Input);

        OnAfterGetHashForTransportWorkshtLine(TransportWorksheetLine, Input, Hash);

        exit(Hash);
    end;

    procedure GetHashForTransportOrderHeader(TransportOrderHeader: Record "IDYS Transport Order Header"): Code[40];
    var
        Input: Text;
        Hash: Code[40];
        Handled: Boolean;
    begin
        OnBeforeGetHashForTransportOrderHeader(TransportOrderHeader, Input, Handled);
        if Handled then
            exit(GetMD5Hash(Input));

        Input :=
            TransportOrderHeader."Shipping Agent Code" + '$' +
            TransportOrderHeader."Shipping Agent Service Code" + '$' +
            TransportOrderHeader."Shipment Method Code" + '$' +
            Format(TransportOrderHeader.Book, 0, 9) + '$' +
            Format(TransportOrderHeader."E-Mail Type") + '$' +
            Format(TransportOrderHeader."Cost Center") + '$' +
            Format(DT2Date(TransportOrderHeader."Preferred Pick-up Date From"), 0, 9) + '$' +
            Format(DT2Date(TransportOrderHeader."Preferred Delivery Date From"), 0, 9) + '$' +
            TransportOrderHeader."Address (Pick-up)" + '$' +
            TransportOrderHeader."Address 2 (Pick-up)" + '$' +
            TransportOrderHeader."Post Code (Pick-up)" + '$' +
            TransportOrderHeader."City (Pick-up)" + '$' +
            TransportOrderHeader."County (Pick-up)" + '$' +
            TransportOrderHeader."Country/Region Code (Pick-up)" + '$' +
            TransportOrderHeader."VAT Registration No. (Pick-up)" + '$' +
            TransportOrderHeader."Address (Ship-to)" + '$' +
            TransportOrderHeader."Address 2 (Ship-to)" + '$' +
            TransportOrderHeader."Post Code (Ship-to)" + '$' +
            TransportOrderHeader."City (Ship-to)" + '$' +
            TransportOrderHeader."County (Ship-to)" + '$' +
            TransportOrderHeader."Country/Region Code (Ship-to)" + '$' +
            TransportOrderHeader."VAT Registration No. (Ship-to)" + '$' +
            TransportOrderHeader."Address (Invoice)" + '$' +
            TransportOrderHeader."Address 2 (Invoice)" + '$' +
            TransportOrderHeader."Post Code (Invoice)" + '$' +
            TransportOrderHeader."City (Invoice)" + '$' +
            TransportOrderHeader."County (Invoice)" + '$' +
            TransportOrderHeader."Country/Region Code (Invoice)" + '$' +
            TransportOrderHeader."VAT Registration No. (Invoice)";

        Hash := GetMD5Hash(Input);

        OnAfterGetHashForTransportOrderHeader(TransportOrderHeader, Input, Hash);

        exit(Hash);
    end;

    procedure GetMD5Hash(Input: Text) HashKey: Code[40]
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        exit(CopyStr(CryptographyManagement.GenerateHash(Input, HashAlgorithmType::MD5), 1, MaxStrLen(HashKey)))
    end;

    procedure UpdateCombinabilityID()
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
        TransportOrderHeader2: Record "IDYS Transport Order Header";
        TransportWorksheetLine: Record "IDYS Transport Worksheet Line";
        TransportWorksheetLine2: Record "IDYS Transport Worksheet Line";
    begin
        if TransportOrderHeader.FindSet() then
            repeat
                TransportOrderHeader2 := TransportOrderHeader;
                TransportOrderHeader2.Modify(true);
            until TransportOrderHeader.Next() = 0;

        if TransportWorksheetLine.FindSet() then
            repeat
                TransportWorksheetLine2 := TransportWorksheetLine;
                TransportWorksheetLine2.Modify(true);
            until TransportWorksheetLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetHashForTransportWorkshtLine(TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; var Input: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetHashForTransportWorkshtLine(TransportWorksheetLine: Record "IDYS Transport Worksheet Line"; Input: Text; Hash: Code[40])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetHashForTransportOrderHeader(TransportOrderHeader: Record "IDYS Transport Order Header"; var Input: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetHashForTransportOrderHeader(TransportOrderHeader: Record "IDYS Transport Order Header"; Input: Text; Hash: Code[40])
    begin
    end;
}

