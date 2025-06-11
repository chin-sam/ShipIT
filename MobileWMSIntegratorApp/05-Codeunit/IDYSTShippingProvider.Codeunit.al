codeunit 11147822 "IDYST ShippingProvider"
{
    Permissions = tabledata "IDYS Transport Order Register" = rd;

    var
        IDYSProviderSetup: Record "IDYS Setup";
        MobToolBox: Codeunit "MOB Toolbox";
        IDYSTransportOrderAPI: Codeunit "IDYS Transport Order API";

    /// <summary>
    /// Interface implementation: Register shipping provider in base Pack and Ship app
    /// </summary>   
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Pack API", 'OnDiscoverShippingProvider', '', true, true)]
    local procedure OnDiscoverShippingProvider()
    var
        MosPackAPI: Codeunit "MOB Pack API";
    begin
        MosPackAPI.SetupShippingProvider(GetShippingProviderId(), 'ShipIT 365 Connector');
    end;

    /// <summary>
    /// Interface implementation: Unique Shipping Provider Id for this class (implementation)
    /// </summary>
    internal procedure GetShippingProviderId(): Code[20]
    begin
        exit('SHIPIT365');
    end;

    /// <summary>
    /// Interface implementation: Is the package type handled by the current Shipping Provider Id
    /// </summary>   
    local procedure IsShippingProvider(PackageType: Code[100]): Boolean
    var
        MOBPackageType: Record "MOB Package Type";
    begin
        exit(MOBPackageType.Get(PackageType) and (MOBPackageType."Shipping Provider Id" = GetShippingProviderId()));
    end;

    /// <summary>
    /// Interface implementation: Synchronize package types from external solution to our own internal table
    /// </summary>   
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Pack API", 'OnSynchronizePackageTypes', '', true, true)]
    local procedure OnSynchronizePackageTypes(var _PackageType: Record "MOB Package Type")
    begin
        SynchronizePackageTypes(_PackageType);
    end;

    /// procedure can be used to transfer license plates for a given warehouse shipment to transport order packages 
    procedure TransferLicensePlatesToTransportOrderPackages(TransportOrderNo: Code[20]; WhseShipmentNo: Code[20]; OverrideShippingAgent: Code[10])
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSSetup: Record "IDYS Setup";
        TempIDYSTransportOrderPackage: Record "IDYS Transport Order Package" temporary;
        TempIDYSPackageContentBuffer: Record "IDYS Package Content Buffer" temporary;
    begin
        if OverrideShippingAgent = '' then begin
            WarehouseShipmentHeader.Get(WhseShipmentNo);
            OverrideShippingAgent := WarehouseShipmentHeader."Shipping Agent Code";
        end;

        if not IDYSTransportOrderAPI.CheckIfTransportOrderBelongsToWhseShipment(TransportOrderNo, WhseShipmentNo) then
            exit;
        IDYSTransportOrderAPI.SetPostponeTotals(true);
        CreateIDYSTransportOrderPackagesForWarehouseShipment(TransportOrderNo, WhseShipmentNo, OverrideShippingAgent, TempIDYSTransportOrderPackage);        
        IDYSTransportOrderAPI.AddTransportOrderPackages(TempIDYSTransportOrderPackage);
        IDYSSetup.Get();
        if IDYSSetup."Link Del. Lines with Packages" then begin
            CreateIDYSPackageContentForPackages(TempIDYSPackageContentBuffer, TransportOrderNo);
            IDYSTransportOrderAPI.ReassignDelNoteLinesPerPackage(TempIDYSPackageContentBuffer);
        end;
        IDYSTransportOrderAPI.SetShippingMethod(TransportOrderNo);
        if IDYSTransportOrderHeader.Get(TransportOrderNo) then
            IDYSTransportOrderHeader.UpdateTotals();
    end;

    internal procedure SynchronizePackageTypes(var MOBPackageType: Record "MOB Package Type")
    var
        MOBSetup: Record "MOB Setup";
        TempIDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type" temporary;
        PackageTypeFilterLbl: Label '%1-%2-%3', Locked = true;
        ExtPackageTypeFilterLbl: Label '%1-%2-%3-%4-%5', Locked = true;
        PackageTypePrefixLbl: Label 'SHPIT', Locked = true;
    begin
        MOBPackageType.SetRange("Shipping Provider Id", GetShippingProviderId());
        MOBPackageType.DeleteAll();
        MOBPackageType.SetRange("Shipping Provider Id");
        IDYSTransportOrderAPI.GetPackageTypes(TempIDYSBookingProfPackageType);
        TempIDYSBookingProfPackageType.SetAutoCalcFields("Carrier Name", "Booking Profile Description");
        if TempIDYSBookingProfPackageType.FindSet() then
            repeat
                MOBPackageType.Init();
                MOBPackageType.Validate("Shipping Provider Id", GetShippingProviderId());
                MOBPackageType.Validate("Shipping Provider Package Type", TempIDYSBookingProfPackageType."Package Type Code");  // Example: BOX
                if TempIDYSBookingProfPackageType."Carrier Entry No." > 0 then
                    MOBPackageType.Validate(Code, StrSubstNo(ExtPackageTypeFilterLbl, // Example: SHIPIT365-2-4-1-3
                        PackageTypePrefixLbl,
                        MobToolBox.AsInteger(TempIDYSBookingProfPackageType."API Provider"),
                        TempIDYSBookingProfPackageType."Carrier Entry No.",  // Shipping Agent
                        TempIDYSBookingProfPackageType."Booking Profile Entry No.",  // Shipping Agent Service
                        TempIDYSBookingProfPackageType."Package Type Code"))
                else
                    MOBPackageType.Validate(Code, StrSubstNo(PackageTypeFilterLbl, // Example: SHIPIT365-1-BOX
                        PackageTypePrefixLbl,
                        MobToolBox.AsInteger(TempIDYSBookingProfPackageType."API Provider"),
                        MOBPackageType."Shipping Provider Package Type"));
                MOBPackageType.Validate("IDYST IDYS Provider", TempIDYSBookingProfPackageType."API Provider");
                if TempIDYSBookingProfPackageType."Carrier Entry No." > 0 then
                    MOBPackageType.Validate("IDYST Carrier Entry No.", TempIDYSBookingProfPackageType."Carrier Entry No.");
                MOBPackageType.Validate("IDYST Carrier Name", TempIDYSBookingProfPackageType."Carrier Name");
                MOBPackageType.Validate("IDYST Book Prof Entry No.", TempIDYSBookingProfPackageType."Booking Profile Entry No.");
                MOBPackageType.Validate("IDYST Book Prof Descr", TempIDYSBookingProfPackageType."Booking Profile Description");
                MOBPackageType.Validate(Description, CopyStr(TempIDYSBookingProfPackageType.Description, 1, MaxStrLen(MOBPackageType.Description)));

                // Units are converted to the Tasklet units
                if MOBSetup.Get() then
                    MOBPackageType.Validate(Unit, MOBSetup."Dimensions Unit");

                TempIDYSBookingProfPackageType.CalcFields(Provider);
                MOBPackageType.Validate(Height, GetConvertedUnit(TempIDYSBookingProfPackageType.Height, TempIDYSBookingProfPackageType."API Provider", "IDYS Conversion Type"::Linear, true));
                MOBPackageType.Validate(Width, GetConvertedUnit(TempIDYSBookingProfPackageType.Width, TempIDYSBookingProfPackageType."API Provider", "IDYS Conversion Type"::Linear, true));
                MOBPackageType.Validate(Length, GetConvertedUnit(TempIDYSBookingProfPackageType.Length, TempIDYSBookingProfPackageType."API Provider", "IDYS Conversion Type"::Linear, true));
                MOBPackageType.Validate(Weight, GetConvertedUnit(TempIDYSBookingProfPackageType.Weight, TempIDYSBookingProfPackageType."API Provider", "IDYS Conversion Type"::Mass, true));
                MOBPackageType.Insert(true);
            until TempIDYSBookingProfPackageType.Next() = 0;
    end;

    /// <summary>
    /// Interface implementation: Synchronize ShipIt365 External User Setup to Packing Stations from external solution to our own internal table
    /// </summary>   
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Pack API", 'OnSynchronizePackingStations', '', true, true)]
    local procedure OnSynchronizePackingStations(var _PackingStation: Record "MOB Packing Station")
    var
        IDYSUserSetup: Record "IDYS User Setup";
    begin
        IDYSUserSetup.Reset();
        if IDYSUserSetup.FindSet() then
            repeat
                _PackingStation.SetRange("IDYST User Name (External)", IDYSUserSetup."User Name (External)");
                if _PackingStation.IsEmpty() then begin
                    _PackingStation.Init();
                    _PackingStation.Code := '';  // OnInsert Code will auto-assign value
                    _PackingStation.Description := IDYSUserSetup."User Name (External)";
                    _PackingStation."IDYST User Name (External)" := IDYSUserSetup."User Name (External)";
                    _PackingStation."IDYST Password (External)" := IDYSUserSetup."Password (External)";
                    _PackingStation.Insert(true);
                end;
            until IDYSUserSetup.Next() = 0;

        _PackingStation.Reset();  // Remove any filters
    end;

    /// <summary>
    /// Interface implementaion: "Update values on User Setup to force use of selected Packing Station (Printer)"
    /// </summary>    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Pack API", 'OnBeforePostPacking', '', true, true)]
    local procedure OnBeforePostPacking_UpdatePackingStation(_RegistrationType: Text; _PackingStation: Record "MOB Packing Station"; var _RequestValues: Record "MOB NS Request Element")
    var
        IDYSUserSetup: Record "IDYS User Setup";
        MobSessionData: Codeunit "MOB SessionData";
    begin
        if _RegistrationType <> 'PostPacking' then
            exit;

        if _PackingStation.Code = '' then
            exit;

        // Get the current user as IDYSUser
        // Fallback: Use "Default" IDYSUser
        if not IDYSUserSetup.Get(MobSessionData.GetMobileUserID()) then begin
            IDYSUserSetup.SetRange(Default, true);
            if IDYSUserSetup.FindFirst() then;
        end;

        if IDYSUserSetup."User ID" = '' then
            exit;

        UpdateTransSmartPrintFromPackingStation(IDYSUserSetup, _PackingStation);
        UpdateDeliveryHubPrintFromPackingStation(IDYSUserSetup, _PackingStation);
        IDYSUserSetup.Modify();
    end;

    /// <summary>
    /// Handle specific Setup fields related to "TransSmart" Printing by updating the IDYSUser record
    /// </summary>
    /// <param name="IDYSUserSetup"></param>
    /// <param name="MOBPackingStation"></param>
    local procedure UpdateTransSmartPrintFromPackingStation(var IDYSUserSetup: Record "IDYS User Setup"; MOBPackingStation: Record "MOB Packing Station")

    begin
        if (MOBPackingStation."IDYST User Name (External)" = '') or (MOBPackingStation."IDYST Password (External)" = '') then
            exit;

        IDYSUserSetup.Validate("User Name (External)", MOBPackingStation."IDYST User Name (External)");
        IDYSUserSetup.Validate("Password (External)", MOBPackingStation."IDYST Password (External)");
    end;

    /// <summary>
    /// Handle specific Setup fields related to "Delivery Hub" Printing by updating the IDYSUser record
    /// </summary>
    /// <param name="IDYSUserSetup"></param>
    /// <param name="MOBPackingStation"></param>
    local procedure UpdateDeliveryHubPrintFromPackingStation(var IDYSUserSetup: Record "IDYS User Setup"; MOBPackingStation: Record "MOB Packing Station")
    begin
        if MOBPackingStation."IDYST Ticket Username" <> '' then
            IDYSUserSetup.Validate("Ticket Username", MOBPackingStation."IDYST Ticket Username");

        if MOBPackingStation."IDYST DZ Label Printer Key" <> '' then
            IDYSUserSetup.Validate("Drop Zone Label Printer Key", MOBPackingStation."IDYST DZ Label Printer Key");

        if MOBPackingStation."IDYST Workstation ID" <> '' then
            IDYSUserSetup.Validate("Workstation ID", MOBPackingStation."IDYST Workstation ID");
    end;

    /// <summary>
    /// Interface implementation: "Early" validation before posting to be executeed if we are the shipping provider for a license plate
    /// </summary>   
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Pack API", 'OnPostPackingOnCheckUntransferredLicensePlate', '', true, true)]
    local procedure OnPostPackingOnCheckUntransferredLicensePlate(_LicensePlate: Record "MOB License Plate")
    var
        IDYSSetup: Record "IDYS Setup";
        IDYSProviderPackageType: Record "IDYS Provider Package Type";
        PackageType: Record "MOB Package Type";
        WarehouseShipment: Record "Warehouse Shipment Header";
        IDYSShippingAgentMapping: Record "IDYS Ship. Agent Mapping";
        IDYSShippingAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSBookingProfPackageType: Record "IDYS BookingProf. Package Type";
        IsHandled: Boolean;
    begin
        if not IsShippingProvider(_LicensePlate."Package Type") then
            exit;

        OnBeforeCheckUntransferredLicensePlate(_LicensePlate, IsHandled);
        if IsHandled then
            exit;
        IDYSSetup.Get();
        IDYSSetup.TestField("Always New Trns. Order", true);

        // Check PackageType and ensure IDYS Shipping Agent Mapping exist and will not error out during validation
        WarehouseShipment.Get(_LicensePlate."Whse. Document No.");
        PackageType.Get(_LicensePlate."Package Type");
        _LicensePlate.TestField("Whse. Document Type", _LicensePlate."Whse. Document Type"::Shipment);

        // Pre-check on specific provider Package Type Codes
        IDYSShippingAgentMapping.Get(WarehouseShipment."Shipping Agent Code");

        if IDYSShippingAgentMapping.Provider in [IDYSShippingAgentMapping.Provider::Default, IDYSShippingAgentMapping.Provider::Transsmart, IDYSShippingAgentMapping.Provider::Sendcloud] then
            IDYSProviderPackageType.Get(IDYSShippingAgentMapping.Provider, PackageType."Shipping Provider Package Type");

        if WarehouseShipment."Shipping Agent Service Code" <> '' then
            IDYSShippingAgentSvcMapping.Get(WarehouseShipment."Shipping Agent Code", WarehouseShipment."Shipping Agent Service Code");

        if IDYSShippingAgentMapping.Provider in [IDYSShippingAgentMapping.Provider::"Delivery Hub", IDYSShippingAgentMapping.Provider::EasyPost] then
            IDYSBookingProfPackageType.Get(IDYSShippingAgentSvcMapping."Carrier Entry No.", IDYSShippingAgentSvcMapping."Booking Profile Entry No.", PackageType."Shipping Provider Package Type");
    end;

    /// <summary>
    /// Interface implementation: Create new tranport order prior to posting if needed (prior to initial commit)
    /// </summary>
    /// <remarks>
    /// Redirected from standard event OnAfterCheckWhseShptLine to new local event for more accessible "interface" (all neccessary events in MOB Pack Register CU)
    /// </remarks>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Pack API", 'OnPostPackingOnBeforePostWarehouseShipment', '', false, false)]
    local procedure OnPostPackingOnBeforePostWarehouseShipment(var WhseShptHeader: Record "Warehouse Shipment Header"; var WhseShptLine: Record "Warehouse Shipment Line")
    var
        IDYSSetup: Record "IDYS Setup";
        MosPackRegister: Codeunit "MOB WMS Pack Adhoc Reg-PostPck";
        SessionData: Codeunit "IDYST SessionData";
        IsHandled: Boolean;
    begin
        OnBeforePostPackingOnBeforePostWarehouseShipment(WhseShptHeader, WhseShptLine, IsHandled);
        if IsHandled then
            exit;
        SessionData.SetErrorMessage('');  // Clear error message
        UpdateQuantityToTransport(WhseShptLine);
        if HasQuantityToTransport(WhseShptLine) and MosPackRegister.HasUntransferredLicensePlatesForWarehouseShipment(WhseShptHeader."No.") then begin
            IDYSSetup.Get();
            if IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents" then // Checks if we are indeed supposed to create unposted Transport Order from our code
                CreateTransportOrder(WhseShptHeader, IDYSSetup."Link Del. Lines with Packages") // May append to existing transport order
            else
                SessionData.SetWhseShipmentNo(WhseShptHeader."No.", WhseShptHeader."Shipping Agent Code"); //scenario for posted documents license plates are injected via a event.
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Pack API", 'OnPostPackingOnAfterPostWarehouseShipment', '', false, false)]
    local procedure OnPostPackingOnAfterPostWarehouseShipment(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        SessionData: Codeunit "IDYST SessionData";
    begin
        OnBeforePostPackingOnAfterPostWarehouseShipment(WarehouseShipmentHeader);
        if SessionData.GetErrorMessage() <> '' then begin
            Commit();
            Error(SessionData.GetErrorMessage());
        end;
    end;

    /// <summary>
    /// inject Untransferred License Plates in a Transport Order based on Posted Documents scenario
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IDYS Create Tpt. Ord. (Wrksh.)", 'OnBeforeAssignPackageContent', '', false, false)]
    local procedure IDYSCreateTptOrdWrksh_OnBeforeAssignPackageContent(IDYSTransportOrderHeader: Record "IDYS Transport Order Header"; var IsHandled: Boolean)
    var
        SessionData: Codeunit "IDYST SessionData";
        WhseShipmentNo: Code[20];
    begin
        WhseShipmentNo := SessionData.GetWhseShipmentNo();
        if WhseShipmentNo = '' then
            exit;
        TransferLicensePlatesToTransportOrderPackages(IDYSTransportOrderHeader."No.", WhseShipmentNo, SessionData.GetShippingAgentCode());
        IsHandled := true;
    end;

    /// <summary>
    /// Update quantity to transport based on package type quantity to ship
    /// </summary>
    local procedure UpdateQuantityToTransport(var WarehouseShipmentLine: Record "Warehouse Shipment Line"): Boolean
    var
        UpdatedWarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        // Simple implementation: Assuming everything is for ShipIt (currently not checking package + package type exists and is asociated to IDYS)
        // We currently assume we can just populate the IDYS field even if it is not needed.
        UpdatedWarehouseShipmentLine.Copy(WarehouseShipmentLine);
        if UpdatedWarehouseShipmentLine.FindSet() then
            repeat
                if UpdatedWarehouseShipmentLine."IDYS Quantity To Send" <> UpdatedWarehouseShipmentLine."Qty. to Ship (Base)" then begin
                    UpdatedWarehouseShipmentLine.Validate("IDYS Quantity To Send", UpdatedWarehouseShipmentLine."Qty. to Ship (Base)");
                    UpdatedWarehouseShipmentLine.Modify(true);
                end;
            until UpdatedWarehouseShipmentLine.Next() = 0;
    end;

    /// <summary>
    /// Update "IDYS Quantity To Send" where it wasn't cleared due to "WhseShipmentLine.ModifyAll("Qty. to Ship", 0, true);"
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Pack Adhoc Reg-PostPck", 'OnPostAdhocRegistrationOnPostPacking_OnBeforeRunWhsePostShipment', '', false, false)]
    local procedure MOBWMSPackAdhocRegPostPck_OnPostAdhocRegistrationOnPostPacking_OnBeforeRunWhsePostShipment(var _IsHandled: Boolean; var _WhsePostShipment: Codeunit "Whse.-Post Shipment"; var _WhseShipmentLine: Record "Warehouse Shipment Line")
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WarehouseShipmentLine.CopyFilters(_WhseShipmentLine);
        WarehouseShipmentLine.SetRange("Qty. to Ship", 0);
        WarehouseShipmentLine.SetFilter("IDYS Quantity To Send", '<>0');
        WarehouseShipmentLine.ModifyAll("IDYS Quantity To Send", 0);
    end;

    /// <summary>
    /// Is a new transport order to be created for the filtered warehouse shipment lines
    /// </summary>
    local procedure HasQuantityToTransport(var WarehouseShipmentLine: Record "Warehouse Shipment Line"): Boolean
    var
        CheckWarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        CheckWarehouseShipmentLine.Copy(WarehouseShipmentLine);
        CheckWarehouseShipmentLine.SetFilter("IDYS Quantity To Send", '>0');
        exit(not CheckWarehouseShipmentLine.IsEmpty());
    end;

    /// <summary>
    /// Create a new transport order for the warehouse shipment
    /// </summary>
    procedure CreateTransportOrder(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; PackageContentEnabled: Boolean)
    var
        TempIDYSTransportOrderPackage: Record "IDYS Transport Order Package" temporary;
        TempIDYSPackageContentBuffer: Record "IDYS Package Content Buffer" temporary;
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        LastTransportOrderNo: Code[20];
    begin
        CreateIDYSTransportOrderPackagesForWarehouseShipment('', WarehouseShipmentHeader."No.", WarehouseShipmentHeader."Shipping Agent Code", TempIDYSTransportOrderPackage);
        LastTransportOrderNo := IDYSTransportOrderAPI.CreateTransportOrder(WarehouseShipmentHeader.RecordId, TempIDYSTransportOrderPackage, PackageContentEnabled);
        if LastTransportOrderNo = '' then
            exit;
        if PackageContentEnabled then begin
            CreateIDYSPackageContentForPackages(TempIDYSPackageContentBuffer, LastTransportOrderNo);
            IDYSTransportOrderAPI.SetPostponeTotals(true);
            IDYSTransportOrderAPI.ReassignDelNoteLinesPerPackage(TempIDYSPackageContentBuffer);
        end;
        if IDYSTransportOrderHeader.Get(LastTransportOrderNo) then
            IDYSTransportOrderHeader.UpdateTotals();
        BookAndPrintShipItTransportOrders(WarehouseShipmentHeader."No.");
    end;

    /// <summary>
    /// Insert all untransferred packages from a warehouse shipment
    /// </summary>
    internal procedure CreateIDYSTransportOrderPackagesForWarehouseShipment(TransportOrderNo: Code[20]; WhseShipmentNo: Code[20]; ShippingAgentCode: Code[10]; var TempIDYSTransportOrderPackage: Record "IDYS Transport Order Package" temporary) PackagesInserted: Integer
    var
        UntransferredMOBLicensePlate: Record "MOB License Plate";
        UntransferredUpdMOBLicensePlate: Record "MOB License Plate";
        MOBPackageType: Record "MOB Package Type";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        MOBWMSPackAdhocRegPostPck: Codeunit "MOB WMS Pack Adhoc Reg-PostPck";
        PackageTypeCode: Code[50];
    begin
        IDYSShipAgentMapping.Get(ShippingAgentCode);
        MOBWMSPackAdhocRegPostPck.FilterUntransferredLicensePlatesForWarehouseShipment(WhseShipmentNo, UntransferredMOBLicensePlate);
        if UntransferredMOBLicensePlate.FindSet() then
            repeat
                if IsShippingProvider(UntransferredMOBLicensePlate."Package Type") then begin

                    Evaluate(PackageTypeCode, UntransferredMOBLicensePlate."Package Type");
                    MOBPackageType.Get(PackageTypeCode);

                    PackagesInserted += 1;
                    TempIDYSTransportOrderPackage.Init();
                    TempIDYSTransportOrderPackage."Line No." := PackagesInserted;
                    TempIDYSTransportOrderPackage."Transport Order No." := TransportOrderNo;
                    TempIDYSTransportOrderPackage."Provider Package Type Code" := MOBPackageType."Shipping Provider Package Type";
                    TempIDYSTransportOrderPackage."API Carrier Entry No." := MOBPackageType."IDYST Carrier Entry No.";
                    TempIDYSTransportOrderPackage."API Booking Profile Entry No." := MOBPackageType."IDYST Book Prof Entry No.";
                    TempIDYSTransportOrderPackage.Validate(Weight, GetConvertedUnit(UntransferredMOBLicensePlate.Weight, MOBPackageType."IDYST IDYS Provider", "IDYS Conversion Type"::Mass, false));
                    TempIDYSTransportOrderPackage.Validate(Height, GetConvertedUnit(UntransferredMOBLicensePlate.Height, MOBPackageType."IDYST IDYS Provider", "IDYS Conversion Type"::Linear, false));
                    TempIDYSTransportOrderPackage.Validate(Width, GetConvertedUnit(UntransferredMOBLicensePlate.Width, MOBPackageType."IDYST IDYS Provider", "IDYS Conversion Type"::Linear, false));
                    TempIDYSTransportOrderPackage.Validate(Length, GetConvertedUnit(UntransferredMOBLicensePlate.Length, MOBPackageType."IDYST IDYS Provider", "IDYS Conversion Type"::Linear, false));
                    TempIDYSTransportOrderPackage.Validate("License Plate No.", UntransferredMOBLicensePlate."No.");
                    TempIDYSTransportOrderPackage.Validate("Load Meter", UntransferredMOBLicensePlate."Loading Meter");
                    TempIDYSTransportOrderPackage.Insert(true);
                end;
                UntransferredUpdMOBLicensePlate := UntransferredMOBLicensePlate;
                UntransferredUpdMOBLicensePlate.Validate("Transferred to Shipping", true);   // Will mark all child license plates as transferred as well
                UntransferredUpdMOBLicensePlate.Modify();    // Do no modify record used for iteration due to next cursorplacement 
            until UntransferredMOBLicensePlate.Next() = 0;
    end;

    [Obsolete('Replaced with CreateIDYSTransportOrderPackagesForWarehouseShipment', '22.10')]
    internal procedure InsertPackagesForWarehouseShipment(FromWhseShipmentNo: Code[20]; ToTransportOrderNo: Code[20]) PackagesInserted: Integer
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        UntransferredMOBLicensePlate: Record "MOB License Plate";
        UntransferredUpdMOBLicensePlate: Record "MOB License Plate";
        MOBPackageType: Record "MOB Package Type";
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        MOBWMSPackAdhocRegPostPck: Codeunit "MOB WMS Pack Adhoc Reg-PostPck";
        PackageTypeCode: Code[50];
        TotalLoadingMeters: Decimal;
        IDYSProvider: Enum "IDYS Provider";
    begin
        Clear(PackagesInserted);

        // Identify Provider based on Shipping Agent
        WarehouseShipmentHeader.Get(FromWhseShipmentNo);
        IDYSShipAgentMapping.Get(WarehouseShipmentHeader."Shipping Agent Code");

        IDYSTransportOrderPackage.LockTable();
        IDYSTransportOrderPackage.SetRange("Transport Order No.", ToTransportOrderNo);
        IDYSTransportOrderPackage.SetRange("System Created Entry", true);
        if not IDYSTransportOrderPackage.IsEmpty() then
            IDYSTransportOrderPackage.DeleteAll(true);
        IDYSTransportOrderPackage.SetRange("Transport Order No.");
        IDYSTransportOrderPackage.SetRange("System Created Entry");

        MOBWMSPackAdhocRegPostPck.FilterUntransferredLicensePlatesForWarehouseShipment(FromWhseShipmentNo, UntransferredMOBLicensePlate);
        if UntransferredMOBLicensePlate.FindSet() then
            repeat
                if IsShippingProvider(UntransferredMOBLicensePlate."Package Type") then begin

                    Evaluate(PackageTypeCode, UntransferredMOBLicensePlate."Package Type");
                    MOBPackageType.Get(PackageTypeCode);

                    IDYSTransportOrderPackage.LockTable();

                    // Create new package
                    IDYSTransportOrderPackage.Init();
                    IDYSTransportOrderPackage.Validate("Transport Order No.", ToTransportOrderNo);
                    IDYSTransportOrderPackage."Line No." := 0;
                    IDYSTransportOrderAPI.PutTransportOrderPackage(IDYSTransportOrderPackage);

                    // Update package fields based on Provider
                    case IDYSShipAgentMapping.Provider of
                        IDYSProvider::Default, IDYSProvider::Transsmart, IDYSProvider::Sendcloud:
                            IDYSTransportOrderPackage.Validate("Provider Package Type Code", MOBPackageType."Shipping Provider Package Type");
                        IDYSProvider::"Delivery Hub", IDYSProvider::Easypost:
                            IDYSTransportOrderPackage.Validate("Book. Prof. Package Type Code", MOBPackageType."Shipping Provider Package Type");
                    end;
                    if GetConvertedUnit(UntransferredMOBLicensePlate.Weight, IDYSShipAgentMapping.Provider, "IDYS Conversion Type"::Mass, false) <> IDYSTransportOrderPackage.Weight then
                        IDYSTransportOrderPackage.Validate("Actual Weight", GetConvertedUnit(UntransferredMOBLicensePlate.Weight, IDYSShipAgentMapping.Provider, "IDYS Conversion Type"::Mass, false));
                    if GetConvertedUnit(UntransferredMOBLicensePlate.Height, IDYSShipAgentMapping.Provider, "IDYS Conversion Type"::Linear, false) <> 0 then
                        IDYSTransportOrderPackage.Validate(Height, GetConvertedUnit(UntransferredMOBLicensePlate.Height, IDYSShipAgentMapping.Provider, "IDYS Conversion Type"::Linear, false));
                    if GetConvertedUnit(UntransferredMOBLicensePlate.Width, IDYSShipAgentMapping.Provider, "IDYS Conversion Type"::Linear, false) <> 0 then
                        IDYSTransportOrderPackage.Validate(Width, GetConvertedUnit(UntransferredMOBLicensePlate.Width, IDYSShipAgentMapping.Provider, "IDYS Conversion Type"::Linear, false));
                    if GetConvertedUnit(UntransferredMOBLicensePlate.Length, IDYSShipAgentMapping.Provider, "IDYS Conversion Type"::Linear, false) <> 0 then
                        IDYSTransportOrderPackage.Validate(Length, GetConvertedUnit(UntransferredMOBLicensePlate.Length, IDYSShipAgentMapping.Provider, "IDYS Conversion Type"::Linear, false));

                    IDYSTransportOrderPackage.UpdateTotalVolume();
                    IDYSTransportOrderPackage.UpdateTotalWeight();

                    IDYSTransportOrderPackage.Validate("License Plate No.", UntransferredMOBLicensePlate."No.");
                    IDYSTransportOrderPackage.Modify(true);

                    // Calculate Total "Load Meters"
                    if UntransferredMOBLicensePlate."Loading Meter" <> 0 then
                        TotalLoadingMeters += UntransferredMOBLicensePlate."Loading Meter";

                    PackagesInserted += 1;

                    UntransferredUpdMOBLicensePlate := UntransferredMOBLicensePlate;
                    UntransferredUpdMOBLicensePlate.Validate("Transferred to Shipping", true);   // Will mark all child license plates as transferred as well
                    UntransferredUpdMOBLicensePlate.Modify();    // Do no modify record used for iteration due to next cursorplacement 
                end;
            until UntransferredMOBLicensePlate.Next() = 0;

        // Update Loading Meters from transfered License Plates
        if TotalLoadingMeters <> 0 then begin
            IDYSTransportOrderHeader.Get(ToTransportOrderNo);
            IDYSTransportOrderHeader.Validate("Load Meter", TotalLoadingMeters);
            IDYSTransportOrderHeader.Modify();
        end;

        exit(PackagesInserted);
    end;

    local procedure GetConvertedUnit(SourceDimension: Decimal; IDYSProvider: Enum "IDYS Provider"; IDYSConversionType: Enum "IDYS Conversion Type"; Multiply: Boolean): Decimal
    begin
        if SourceDimension = 0 then
            exit(SourceDimension);

        IDYSProviderSetup.GetProviderSetup(IDYSProvider);
        if Multiply then
            exit(Round(GetConversionFactor(IDYSConversionType) * SourceDimension, GetRoundingPrecision(IDYSConversionType)))
        else
            exit(Round(1 / GetConversionFactor(IDYSConversionType) * SourceDimension, GetRoundingPrecision(IDYSConversionType)));
    end;

    local procedure GetConversionFactor(IDYSConversionType: Enum "IDYS Conversion Type"): Decimal
    begin
        case IDYSConversionType of
            IDYSConversionType::Mass:
                exit(IDYSProviderSetup."IDYST Conversion Factor (Mass)");
            IDYSConversionType::Linear:
                exit(IDYSProviderSetup."IDYST Conv. Factor (Linear)");
        end;
    end;

    local procedure GetRoundingPrecision(IDYSConversionType: Enum "IDYS Conversion Type"): Decimal
    begin
        case IDYSConversionType of
            IDYSConversionType::Mass:
                exit(IDYSProviderSetup."IDYST Rounding Prec. (Mass)");
            IDYSConversionType::Linear:
                exit(IDYSProviderSetup."IDYST Rounding Prec. (Linear)");
        end;
    end;

    /// <summary>
    /// Create Package Item Lines in 1 level based on License Plate structure in multiple levels
    /// </summary>
    local procedure CreateIDYSPackageContentForPackages(var TempIDYSPackageContentBuffer: Record "IDYS Package Content Buffer" temporary; TransportOrderNo: Code[20])
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
        LastLineNo: Integer;
    begin
        LastLineNo := GetLastLineNo(TempIDYSPackageContentBuffer, TransportOrderNo);
        IDYSTransportOrderPackage.SetRange("Transport Order No.", TransportOrderNo);
        IDYSTransportOrderPackage.SetFilter("License Plate No.", '<>%1', '');
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                AddTransportOrderPackageContentFromLicensePlate(IDYSTransportOrderPackage."License Plate No.", IDYSTransportOrderPackage, TempIDYSPackageContentBuffer, LastLineNo);
            until IDYSTransportOrderPackage.Next() = 0;
    end;

    local procedure GetLastLineNo(var TempIDYSPackageContentBuffer: Record "IDYS Package Content Buffer" temporary; TransportOrderNo: Code[20]): Integer
    begin
        TempIDYSPackageContentBuffer.SetRange("Transport Order No.", TransportOrderNo);
        if TempIDYSPackageContentBuffer.FindLast() then
            exit(TempIDYSPackageContentBuffer."Line No.");
    end;

    local procedure AddTransportOrderPackageContentFromLicensePlate(LicensePlateNo: Code[20]; IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var TempIDYSPackageContentBuffer: Record "IDYS Package Content Buffer" temporary; var LineNo: Integer)
    var
        MOBLicensePlate: Record "MOB License Plate";
        MOBLicensePlateContent: Record "MOB License Plate Content";
        SourceRecordId: RecordId;
        TOLineNo: Integer;
        IsHandled: Boolean;
    begin
        OnBeforeAddTransportOrderPackageContentFromLicensePlate(LicensePlateNo, IDYSTransportOrderPackage, TempIDYSPackageContentBuffer, LineNo, IsHandled);
        if IsHandled then
            exit;
        MOBLicensePlate.Get(LicensePlateNo);
        MOBLicensePlateContent.SetRange("License Plate No.", LicensePlateNo);
        if MOBLicensePlateContent.FindSet() then
            repeat
                if MOBLicensePlateContent.Type = MOBLicensePlateContent.Type::Item then begin // Type = Item                                                                                  
                    LineNo += 1;
                    TempIDYSPackageContentBuffer.Init();
                    TempIDYSPackageContentBuffer."Transport Order No." := IDYSTransportOrderPackage."Transport Order No.";
                    TempIDYSPackageContentBuffer."Package Line No." := IDYSTransportOrderPackage."Line No.";
                    TempIDYSPackageContentBuffer."Line No." := LineNo;
                    TempIDYSPackageContentBuffer."Qty. (Base)" := MOBLicensePlateContent."Quantity (Base)";
                    TOLineNo := IDYSTransportOrderAPI.FindTransportOrderLineBySource(IDYSTransportOrderPackage."Transport Order No.", MOBLicensePlateContent."Source Type", MOBLicensePlateContent."Source No.", MOBLicensePlateContent."Source Line No.", SourceRecordId);
                    if TOLineNo <> 0 then begin  //ERROR?                        
                        TempIDYSPackageContentBuffer."Source RecordId" := SourceRecordId;
                        TempIDYSPackageContentBuffer."Transport Order Line No." := TOLineNo;
                        TempIDYSPackageContentBuffer.Insert();
                    end;
                end else // Type = "License Plate" 
                    AddTransportOrderPackageContentFromLicensePlate(MOBLicensePlateContent."No.", IDYSTransportOrderPackage, TempIDYSPackageContentBuffer, LineNo); //recursion
            until MOBLicensePlateContent.Next() = 0;
    end;

    /// <summary>
    /// Book and Print (all transport orders associated to a warehouse shipment)
    /// </summary>
    procedure BookAndPrintShipItTransportOrders(WhseShipmentNo: Code[20])
    var
        IDYSTransportOrderHeader: Record "IDYS Transport Order Header";
        IDYSTransportOrderRegister: Record "IDYS Transport Order Register";
    begin
        IDYSTransportOrderRegister.SetRange("Warehouse Shipment No.", WhseShipmentNo);
        if IDYSTransportOrderRegister.FindSet() then
            repeat
                IDYSTransportOrderHeader.Get(IDYSTransportOrderRegister."Transport Order No.");
                if IDYSTransportOrderHeader.Status = IDYSTransportOrderHeader.Status::New then
                    BookAndPrintShipItTransportOrder(IDYSTransportOrderHeader);
                IDYSTransportOrderRegister.Delete();
            until IDYSTransportOrderRegister.Next() = 0;
    end;

    local procedure BookAndPrintShipItTransportOrder(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header")
    var
        MobSetup: Record "MOB Setup";
        MobSessionData: Codeunit "MOB SessionData";
        SessionData: Codeunit "IDYST SessionData";
        TotalNoOfPackages: Integer;
        PackagesLbl: Label 'Packages: %1', Comment = '%1 = Total No. of Packages';
    begin
        TotalNoOfPackages := CalcTotalNoOfPackages(IDYSTransportOrderHeader);

        MobSessionData.SetRegistrationTypeTracking(
            MobSessionData.GetRegistrationTypeTracking() + ' / ' +
            Format(IDYSTransportOrderHeader.RecordId) + ' / ' +
            StrSubstNo(PackagesLbl, TotalNoOfPackages));  // Packages to book (may include packages previously at the Transport Order)

        if TotalNoOfPackages = 0 then
            exit;   // No packages was inserted from OnAfterCreateTransportOrderLine events

        MobSetup.Get();
        if MobSetup."IDYST TranspOrder Booking" = MobSetup."IDYST TranspOrder Booking"::None then
            exit;

        // We need to make sure all data is commited before we engage with the Idyn API
        Commit();

        // Determine if API action "Book" or "BookAndPrint" should be executed on the Transport Order        
        if MobSetup."IDYST TranspOrder Booking" = MobSetup."IDYST TranspOrder Booking"::BookAndPrint then
            IDYSTransportOrderAPI.BookAndPrint(IDYSTransportOrderHeader, MobSetup."IDYST Continue After TO Fails")
        else
            IDYSTransportOrderAPI.Book(IDYSTransportOrderHeader, MobSetup."IDYST Continue After TO Fails");
        SessionData.SetErrorMessage(IDYSTransportOrderAPI.GetErrorMessage());
    end;

    local procedure CalcTotalNoOfPackages(var IDYSTransportOrderHeader: Record "IDYS Transport Order Header"): Integer
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        IDYSTransportOrderPackage.SetRange("Transport Order No.", IDYSTransportOrderHeader."No.");
        exit(IDYSTransportOrderPackage.Count());
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckUntransferredLicensePlate(_LicensePlate: Record "MOB License Plate"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforePostPackingOnBeforePostWarehouseShipment(var WhseShptHeader: Record "Warehouse Shipment Header"; var WhseShptLine: Record "Warehouse Shipment Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforePostPackingOnAfterPostWarehouseShipment(var WarehouseShipmentHeader: Record "Warehouse Shipment Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddTransportOrderPackageContentFromLicensePlate(LicensePlateNo: Code[20]; IDYSTransportOrderPackage: Record "IDYS Transport Order Package"; var TempIDYSPackageContentBuffer: Record "IDYS Package Content Buffer" temporary; var LineNo: Integer; var IsHandled: Boolean)
    begin
    end;
}