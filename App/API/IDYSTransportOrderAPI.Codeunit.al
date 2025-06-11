codeunit 11147677 "IDYS Transport Order API"
{
    Access = Public;

    procedure AddPackage(TransportOrderNo: Code[20]; PackageTypeCode: Code[50]) NewLineNo: Integer
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        if PackageTypeCode = '' then
            exit;

        TransportOrderPackage.Init();
        TransportOrderPackage.Validate("Transport Order No.", TransportOrderNo);
        TransportOrderPackage.Validate("Provider Package Type Code", PackageTypeCode);
        TransportOrderPackage.Insert(true);
        exit(TransportOrderPackage."Line No.");
    end;

    procedure AddPackage(TransportOrderNo: Code[20]) NewLineNo: Integer
    var
        TransportOrderHeader: Record "IDYS Transport Order Header";
    begin
        TransportOrderHeader.Get(TransportOrderNo);
        AddPackage(TransportOrderHeader);
    end;

    procedure AddPackage(TransportOrderHeader: Record "IDYS Transport Order Header") NewLineNo: Integer
    var
        IDYSIProvider: Interface "IDYS IProvider";
    begin
        IDYSIProvider := TransportOrderHeader.Provider;
        exit(AddPackage(TransportOrderHeader."No.", IDYSIProvider.GetDefaultPackage(TransportOrderHeader."Carrier Entry No.", TransportOrderHeader."Booking Profile Entry No.")));
    end;

    procedure AddTransportOrderPackages(var TempTransportOrderPackage: Record "IDYS Transport Order Package")
    begin
        TransportOrderAPIMgt.AddTransportOrderPackages(TempTransportOrderPackage);
    end;

    procedure AddTransportOrderPackageContent(TransportOrderNo: Code[20]; PackageLineNo: Integer; SourceLineRecordId: RecordId; QtyBase: Decimal; NetWeight: Decimal; GrossWeight: Decimal)
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        TransportOrderPackage.Get(TransportOrderNo, PackageLineNo);
        TransportOrderAPIMgt.AddTransportOrderPackageContent(TransportOrderPackage, 0, SourceLineRecordId, QtyBase, NetWeight, GrossWeight);
    end;

    procedure AddTransportOrderPackageContent(TransportOrderPackage: Record "IDYS Transport Order Package"; SourceLineRecordId: RecordId; QtyBase: Decimal; NetWeight: Decimal; GrossWeight: Decimal)
    begin
        TransportOrderAPIMgt.AddTransportOrderPackageContent(TransportOrderPackage, 0, SourceLineRecordId, QtyBase, NetWeight, GrossWeight);
    end;

    procedure Book(TransportOrderHeader: Record "IDYS Transport Order Header"; UseTryFunction: Boolean)
    begin
        if UseTryFunction then begin
            IDYSTransportOrderMgt.TryBook(TransportOrderHeader);
            ErrorMessage := IDYSTransportOrderMgt.GetErrorMessage();
        end else
            IDYSTransportOrderMgt.Book(TransportOrderHeader);
    end;

    procedure Print(TransportOrderHeader: Record "IDYS Transport Order Header"; UseTryFunction: Boolean)
    begin
        if UseTryFunction then begin
            IDYSTransportOrderMgt.TryPrint(TransportOrderHeader, false);
            ErrorMessage := IDYSTransportOrderMgt.GetErrorMessage();
        end else
            IDYSTransportOrderMgt.Print(TransportOrderHeader);
    end;

    procedure BookAndPrint(TransportOrderHeader: Record "IDYS Transport Order Header"; UseTryFunction: Boolean)
    begin
        if UseTryFunction then begin
            if IDYSTransportOrderMgt.TryBook(TransportOrderHeader) then
                IDYSTransportOrderMgt.TryPrint(TransportOrderHeader, true);
            ErrorMessage := IDYSTransportOrderMgt.GetErrorMessage();
        end else begin
            IDYSTransportOrderMgt.Book(TransportOrderHeader);
            IDYSTransportOrderMgt.Print(TransportOrderHeader);
        end;
    end;

    procedure CheckIfTransportOrderBelongsToWhseShipment(TransportOrderNumber: Code[20]; WhseShipmentNo: Code[20]): Boolean
    begin
        exit(TransportOrderAPIMgt.CheckIfTransportOrderBelongsToWhseShipment(TransportOrderNumber, WhseShipmentNo));
    end;

    procedure CreateTransportOrder(SourceDocumentRecordId: RecordId; var TempTransportOrderPackage: Record "IDYS Transport Order Package"; SkipShipmentMethodRecalculation: Boolean) LastCreatedTransportOrderNo: Code[20]
    begin
        LastCreatedTransportOrderNo := CreateTransportOrder(SourceDocumentRecordId);
        if LastCreatedTransportOrderNo = '' then
            exit('');
        TransportOrderAPIMgt.SetTransportOrderNo(LastCreatedTransportOrderNo);
        TransportOrderAPIMgt.AddTransportOrderPackages(TempTransportOrderPackage);
        if not SkipShipmentMethodRecalculation then
            IDYSTransportOrderMgt.SetShippingMethod(LastCreatedTransportOrderNo);
    end;

    procedure CreateTransportOrder(SourceDocumentRecordId: RecordId) LastCreatedTransportOrderNo: Code[20]
    begin
        LastCreatedTransportOrderNo := TransportOrderAPIMgt.CreateTransportOrder(SourceDocumentRecordId);
        IDYSTransportOrderMgt.SetShippingMethod(LastCreatedTransportOrderNo);
    end;

    procedure FindTransportOrderLineBySource(TransportOrderNo: Code[20]; SourceTable: Integer; SourceNo: Code[20]; SourceLineNo: Integer; var OutputSourceRecordId: RecordId): Integer;
    begin
        exit(TransportOrderAPIMgt.FindTransportOrderLineBySource(TransportOrderNo, SourceTable, SourceNo, SourceLineNo, OutputSourceRecordId));
    end;

    procedure GetPackageTypes(var TempIDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type")
    begin
        TransportOrderAPIMgt.GetPackageTypes(TempIDYSBookingProfPackageType);
    end;

    procedure GetTransportOrderPackage(TransportOrderNo: Code[20]; LineNo: Integer; var ResponseTransportOrderPackage: Record "IDYS Transport Order Package") ErrorMessage: Text
    var
        TransportOrderPackageNotFoundErr: Label 'Transport Order Package with %1 %2 and %3 %4 cannot be found.', Comment = '%1 = Transport Order No. fieldcaption, %2 = Transport Order No., %3 = Line No. fieldcaption, %4 = Line No.';
    begin
        Clear(ResponseTransportOrderPackage);
        if not ResponseTransportOrderPackage.Get(TransportOrderNo, LineNo) then
            exit(StrSubStNo(TransportOrderPackageNotFoundErr, ResponseTransportOrderPackage.FieldCaption("Transport Order No."), TransportOrderNo, ResponseTransportOrderPackage.FieldCaption("Line No."), LineNo));
    end;

    procedure PutTransportOrderPackage(var TransportOrderPackage: Record "IDYS Transport Order Package") NewLineNo: Integer
    begin
        exit(TransportOrderAPIMgt.PutTransportOrderPackage(TransportOrderPackage));
    end;

    procedure ReassignDelNoteLinesPerPackage(var TempPackageContentBuffer: Record "IDYS Package Content Buffer")
    begin
        TransportOrderAPIMgt.ReassignDelNoteLinesPerPackage(TempPackageContentBuffer);
    end;

    procedure Recall(TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        IDYSTransportOrderMgt.Recall(TransportOrderHeader);
    end;

    procedure RemoveTransportOrderContent(TransportOrderNo: Code[20])
    var
        TransportOrderDelNote: Record "IDYS Transport Order Del. Note";
    begin
        TransportOrderDelNote.SetRange("Transport Order No.", TransportOrderNo);
        if not TransportOrderDelNote.IsEmpty() then
            TransportOrderDelNote.DeleteAll();
    end;

    procedure Synchronize(TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        IDYSTransportOrderMgt.Synchronize(TransportOrderHeader);
    end;

    procedure GetErrorMessage(): Text
    begin
        exit(ErrorMessage);
    end;

    procedure SetPostponeTotals(NewSkipUpdateTotals: Boolean)
    begin
        TransportOrderAPIMgt.SetPostponeTotals(NewSkipUpdateTotals);
    end;

    #region Obsolete
    [Obsolete('New parameter UseTryFunction added', '24.0')]
    procedure Book(TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        Book(TransportOrderHeader, false);
    end;

    [Obsolete('New parameter UseTryFunction added', '24.0')]
    procedure Print(TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        Print(TransportOrderHeader, false);
    end;

    [Obsolete('New parameter UseTryFunction added', '24.0')]
    procedure BookAndPrint(TransportOrderHeader: Record "IDYS Transport Order Header")
    begin
        BookAndPrint(TransportOrderHeader, false);
    end;

    [Obsolete('Changed parameter TransportOrderHeader to TransportOrderNo', '22.10')]
    procedure AddPackage(TransportOrderHeader: Record "IDYS Transport Order Header"; PackageTypeCode: Code[50]) NewLineNo: Integer
    begin
        exit(AddPackage(TransportOrderHeader."No.", PackageTypeCode));
    end;

    [Obsolete('Quantity Parameter is obsolote instead call addpackage for every desired quantity', '22.10')]
    procedure AddPackage(TransportOrderHeader: Record "IDYS Transport Order Header"; PackageTypeCode: Code[50]; Quantity: Decimal) NewLineNo: Integer
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        if PackageTypeCode = '' then
            exit;

        TransportOrderPackage.Init();
        TransportOrderPackage.Validate("Transport Order No.", TransportOrderHeader."No.");
        TransportOrderPackage.Validate("Provider Package Type Code", PackageTypeCode);
        //TransportOrderPackage.Validate(Quantity, Quantity);
        TransportOrderPackage.Insert(true);
        exit(TransportOrderPackage."Line No.");
    end;

    procedure SetShippingMethod(TransportOrderNo: Code[20])
    begin
        IDYSTransportOrderMgt.SetShippingMethod(TransportOrderNo);
    end;

    [Obsolete('Replaced parameters with either record or prim key fields', '22.10')]
    procedure AddTransportOrderPackageContent(TransportOrderPackageRecordId: RecordId; SourceLineRecordId: RecordId; QtyBase: Decimal; NetWeight: Decimal; GrossWeight: Decimal)
    var
        TransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        TransportOrderPackage.Get(TransportOrderPackageRecordId);
        AddTransportOrderPackageContent(TransportOrderPackage, SourceLineRecordId, QtyBase, NetWeight, GrossWeight);
    end;
    #endregion

    var
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        TransportOrderAPIMgt: Codeunit "IDYS Transport Order API Mgt.";
        ErrorMessage: Text;
}