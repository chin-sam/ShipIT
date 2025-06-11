pageextension 11147824 "IDYST Transport Order Card" extends "IDYS Transport Order Card"
{
    actions
    {
        addlast(Processing)
        {
            group("IDYST Packing")
            {
                Caption = 'Pack & Ship';

                action("IDYST GetAllPackages")
                {
                    Caption = 'Get all packages';
                    Tooltip = 'Get all packages from License Plates associated with to Warehouse Shipments from Transport Order Lines.';
                    ApplicationArea = Basic, Suite;
                    Image = CreateInventoryPick;

                    trigger OnAction()
                    var
                        PackagesCreated: Integer;
                        PackageCreatedMsg: Label '%1 package(s) were inserted.', Comment = '%1 = No. of Packages Created';
                        NoNewPackageCreatedMsg: Label 'There are no packages to insert.';
                    begin
                        PackagesCreated := MOSInsertPackagesForTransportOrder(Rec."No.");
                        if PackagesCreated > 0 then
                            Message(PackageCreatedMsg, PackagesCreated)
                        else
                            Message(NoNewPackageCreatedMsg);
                    end;
                }
            }
        }
    }
    local procedure MOSInsertPackagesForTransportOrder(TransportOrderNo: Code[20]) PackagesInserted: Integer
    var
        IDYSTransportOrderLine: Record "IDYS Transport Order Line";
    begin
        Clear(PackagesInserted);
        IDYSTransportOrderLine.Reset();
        IDYSTransportOrderLine.SetRange("Transport Order No.", TransportOrderNo);
        if IDYSTransportOrderLine.FindSet() then
            repeat
                PackagesInserted := PackagesInserted + MOSInsertPackagesForTransportOrderLine(IDYSTransportOrderLine);
            until IDYSTransportOrderLine.Next() = 0;

        exit(PackagesInserted);
    end;

    /// <summary>
    /// Insert all untransferred packages from all shipments related to a transport order line
    /// </summary>   
    local procedure MOSInsertPackagesForTransportOrderLine(IDYSTransportOrderLine: Record "IDYS Transport Order Line") NoOfPackagesInserted: Integer
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        TempIDYSTransportOrderPackage: Record "IDYS Transport Order Package" temporary;
        MobToolBox: Codeunit "MOB Toolbox";
        IDYSTransportOrderAPI: Codeunit "IDYS Transport Order API";
        SourceTypeUnSupErr: Label 'InsertPackagesForTransportOrderLine(): IDYSTransportOrderLine %1 not supported.', Comment = '%1 = Source Document Table No.';
    begin
        Clear(NoOfPackagesInserted);
        case IDYSTransportOrderLine."Source Document Table No." of
            Database::"Sales Header":
                begin
                    IDYSTransportOrderLine.TestField("Source Document Type", 1);   // 1 = Sales Order
                    IDYSTransportOrderLine.TestField("Source Document No.");       // Order No.
                    IDYSTransportOrderLine.TestField("Source Document Line No.");  // Order Line No.

                    // Transport order line source document table no. 36 -> whse. shipment line source type 37
                    WarehouseShipmentHeader.Get(MOSGetWhseShipmentNoBySourceLine(Database::"Sales Line", MobToolBox.AsInteger(IDYSTransportOrderLine."Source Document Type"), IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No."));
                end;
            Database::"Transfer Header":
                begin
                    //IDYSTransportOrderLine.TestField("Source Document Type", 0);   // 0 = Transfer Order ? Not sure if it´s intentional or an error with ´0'.
                    IDYSTransportOrderLine.TestField("Source Document No.");       // Order No.
                    IDYSTransportOrderLine.TestField("Source Document Line No.");  // Order Line No.

                    // Transport order line source document table no. 5740 -> whse. shipment line source type 37
                    WarehouseShipmentHeader.Get(MOSGetWhseShipmentNoBySourceLine(Database::"Transfer Line", MobToolBox.AsInteger(IDYSTransportOrderLine."Source Document Type"), IDYSTransportOrderLine."Source Document No.", IDYSTransportOrderLine."Source Document Line No."));
                end
            else
                Error(SourceTypeUnSupErr, IDYSTransportOrderLine."Source Document Table No.");
        end;
        NoOfPackagesInserted := ShippingProvider.CreateIDYSTransportOrderPackagesForWarehouseShipment(Rec."No.", WarehouseShipmentHeader."No.", WarehouseShipmentHeader."Shipping Agent Code", TempIDYSTransportOrderPackage);
        IDYSTransportOrderAPI.AddTransportOrderPackages(TempIDYSTransportOrderPackage);
        exit(NoOfPackagesInserted);
    end;

    /// <summary>
    /// Get the single Whse Shipment No. related to a source line no. (from open or posted warehouse shipment)
    /// Assuming a source line can only have a single associated whse. shipment line
    /// </summary>   
    local procedure MOSGetWhseShipmentNoBySourceLine(SourceType: Integer; SourceSubType: Integer; SourceNo: Code[20]; SourceLineNo: Integer): Code[20]
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
    begin
        WarehouseShipmentLine.Reset();
        WarehouseShipmentLine.SetCurrentKey("Source Type", "Source SubType", "Source No.", "Source Line No.", "No.");
        WarehouseShipmentLine.SetRange("Source Type", SourceType);
        WarehouseShipmentLine.SetRange("Source Subtype", SourceSubType);
        WarehouseShipmentLine.SetRange("Source No.", SourceNo);
        WarehouseShipmentLine.SetRange("Source Line No.", SourceLineNo);
        if WarehouseShipmentLine.FindFirst() then
            exit(WarehouseShipmentLine."No.");

        PostedWhseShipmentLine.Reset();
        PostedWhseShipmentLine.SetCurrentKey("Source Type", "Source SubType", "Source No.", "Source Line No.", "No.");
        PostedWhseShipmentLine.SetRange("Source Type", SourceType);
        PostedWhseShipmentLine.SetRange("Source Subtype", SourceSubType);
        PostedWhseShipmentLine.SetRange("Source No.", SourceNo);
        PostedWhseShipmentLine.SetRange("Source Line No.", SourceLineNo);
        if PostedWhseShipmentLine.FindFirst() then
            exit(PostedWhseShipmentLine."No.");

        exit('');
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if MOBLicensePlateExists() then
            if ConfirmManagement.GetResponseOrDefault(ResetMOBLicensePlatesQst, false) then
                ResetMOBLicensePlates();
        exit(true);
    end;

    local procedure MOBLicensePlateExists(): Boolean
    var
        MOBLicensePlate: Record "MOB License Plate";
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        IDYSTransportOrderPackage.SetRange("Transport Order No.", Rec."No.");
        IDYSTransportOrderPackage.SetFilter("License Plate No.", '<>%1', '');
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                MOBLicensePlate.SetRange("No.", IDYSTransportOrderPackage."License Plate No.");
                if not MOBLicensePlate.IsEmpty() then
                    exit(true);
            until IDYSTransportOrderPackage.Next() = 0;
    end;

    local procedure ResetMOBLicensePlates()
    var
        MOBLicensePlate: Record "MOB License Plate";
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        IDYSTransportOrderPackage.SetRange("Transport Order No.", Rec."No.");
        IDYSTransportOrderPackage.SetFilter("License Plate No.", '<>%1', '');
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                if MOBLicensePlate.Get(IDYSTransportOrderPackage."License Plate No.") then begin
                    MOBLicensePlate.Validate("Transferred to Shipping", false);
                    MOBLicensePlate.Modify();
                end;
            until IDYSTransportOrderPackage.Next() = 0;
    end;

    var
        ShippingProvider: codeunit "IDYST ShippingProvider";
        ResetMOBLicensePlatesQst: Label 'Mobile WMS license plates are associated with this Transport Order, do you want to make these license plates retrievable again on future transport orders?';
}
