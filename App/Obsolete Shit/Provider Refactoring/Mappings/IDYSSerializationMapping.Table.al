table 11147689 "IDYS Serialization Mapping"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';
    ObsoleteTag = '18.5';
    Caption = 'Serialization Mapping';

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = SystemMetadata;
        }

        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
        }

        field(3; "Element Name"; Text[30])
        {
            Caption = 'Element Name';
            DataClassification = SystemMetadata;
        }

        field(4; "Include in Serialization"; Boolean)
        {
            Caption = 'Include in Serialization';
            DataClassification = SystemMetadata;
        }

        field(5; "Include in Deserialization"; Boolean)
        {
            Caption = 'Include in Deserialization';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Table ID", "Field No.")
        {
        }
        key(Key2; "Table ID", "Element Name")
        {
        }
    }

    procedure GetFieldNoFromElementName(TableID: Integer; ElementName: Text[30]): Integer;
    begin
        InitializeMappings();

        SetCurrentKey("Table ID", "Element Name");
        SetRange("Table ID", TableID);
        SetRange("Element Name", ElementName);
        SetRange("Include in Deserialization", true);

        if FindFirst() then
            exit("Field No.");
    end;

    procedure GetElementNameFromFieldNo(TableID: Integer; FieldNo: Integer): Text[30];
    begin
        InitializeMappings();

        if Get(TableID, FieldNo) then
            if "Include in Serialization" then
                exit("Element Name");
    end;

    local procedure InitializeMappings();
    begin
        Reset();

        if not IsEmpty() then
            exit;

        InsertMapping(Database::"IDYS Carrier", 1, 'Id', true, true);
        InsertMapping(Database::"IDYS Carrier", 10, 'Code', true, true);
        InsertMapping(Database::"IDYS Carrier", 20, 'Name', true, true);

        InsertMapping(Database::"IDYS Booking Profile", 1, 'CarrierId', true, true);
        InsertMapping(Database::"IDYS Booking Profile", 2, 'Id', true, true);
        InsertMapping(Database::"IDYS Booking Profile", 100, 'ServiceLevelTimeId', true, true);
        InsertMapping(Database::"IDYS Booking Profile", 110, 'ServiceLevelOtherId', true, true);

        InsertMapping(Database::"IDYS Service Level (Time)", 2, 'Id', true, true);
        InsertMapping(Database::"IDYS Service Level (Time)", 10, 'Code', true, true);
        InsertMapping(Database::"IDYS Service Level (Time)", 20, 'Name', true, true);

        InsertMapping(Database::"IDYS Service Level (Other)", 2, 'Id', true, true);
        InsertMapping(Database::"IDYS Service Level (Other)", 10, 'Code', true, true);
        InsertMapping(Database::"IDYS Service Level (Other)", 20, 'Name', true, true);

        InsertMapping(Database::"IDYS Package Type", 1, 'Id', true, true);
        InsertMapping(Database::"IDYS Package Type", 10, 'Name', true, true);
        InsertMapping(Database::"IDYS Package Type", 20, 'Type', true, true);
        InsertMapping(Database::"IDYS Package Type", 30, 'Length', true, true);
        InsertMapping(Database::"IDYS Package Type", 40, 'Width', true, true);
        InsertMapping(Database::"IDYS Package Type", 50, 'Height', true, true);
        InsertMapping(Database::"IDYS Package Type", 60, 'Weight', true, true);

        InsertMapping(Database::"IDYS Incoterm", 1, 'Id', true, true);
        InsertMapping(Database::"IDYS Incoterm", 10, 'Code', true, true);
        InsertMapping(Database::"IDYS Incoterm", 20, 'Name', true, true);

        InsertMapping(Database::"IDYS Cost Center", 1, 'Id', true, true);
        InsertMapping(Database::"IDYS Cost Center", 10, 'Code', true, true);
        InsertMapping(Database::"IDYS Cost Center", 20, 'Name', true, true);

        InsertMapping(Database::"IDYS E-Mail Type", 1, 'Id', true, true);
        InsertMapping(Database::"IDYS E-Mail Type", 10, 'Code', true, true);
        InsertMapping(Database::"IDYS E-Mail Type", 20, 'Name', true, true);

        InsertMapping(Database::"IDYS Transport Order Header", 1, 'Reference', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 10, 'Id', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 20, 'Description', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 31, 'Status', false, true);
        InsertMapping(Database::"IDYS Transport Order Header", 50, 'ShipmentError', false, true);
        InsertMapping(Database::"IDYS Transport Order Header", 101, 'CarrierId', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 114, 'ServiceLevelTimeId', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 117, 'ServiceLevelOtherId', true, true);

        InsertMapping(Database::"IDYS Transport Order Header", 141, 'IncotermId', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 150, 'ServiceType', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 160, 'MailTypeId', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 170, 'CostCenterId', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 175, 'accountNumber', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 200, 'AcceptedBy', false, true);

        InsertMapping(Database::"IDYS Transport Order Header", 300, 'PreferredPickupDateFrom', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 310, 'PreferredPickupDateTo', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 320, 'PreferredDeliveryDateFrom', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 330, 'PreferredDeliveryDateTo', true, true);

        InsertMapping(Database::"IDYS Transport Order Header", 1020, 'AddressNamePickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1041, 'AddressStreetPickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1042, 'AddressStreetNoPickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1050, 'AddressStreet2Pickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1060, 'AddressZipcodePickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1070, 'AddressCityPickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1080, 'AddressStatePickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1091, 'AddressCountryPickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1100, 'AddressContactPickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1110, 'AddressPhonePickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1120, 'AddressFaxPickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1130, 'AddressE-MailPickup', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 1190, 'AddressVatNumberPickup', true, true);

        InsertMapping(Database::"IDYS Transport Order Header", 2030, 'AddressName', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2051, 'AddressStreet', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2052, 'AddressStreetNo', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2060, 'AddressStreet2', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2070, 'AddressZipcode', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2080, 'AddressCity', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2090, 'AddressState', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2101, 'AddressCountry', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2110, 'AddressContact', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2120, 'AddressPhone', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2130, 'AddressFax', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2140, 'AddressE-Mail', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 2190, 'AddressVatNumber', true, true);

        InsertMapping(Database::"IDYS Transport Order Header", 4030, 'AddressNameInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4041, 'AddressStreetInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4042, 'AddressStreetNoInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4050, 'AddressStreet2Invoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4060, 'AddressZipcodeInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4070, 'AddressCityInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4080, 'AddressStateInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4090, 'AddressCountryInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4100, 'AddressContactInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4110, 'AddressPhoneInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4120, 'AddressFaxInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4130, 'AddressE-MailInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 4140, 'AddressVatNumberInvoice', true, true);

        InsertMapping(Database::"IDYS Transport Order Header", 6000, 'TrackingNumber', false, true);
        InsertMapping(Database::"IDYS Transport Order Header", 6010, 'TrackingUrl', false, true);

        InsertMapping(Database::"IDYS Transport Order Header", 7000, 'RefInvoice', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7001, 'RefCustomerOrder', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7002, 'RefOrder', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7003, 'RefDeliveryNote', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7004, 'RefDeliveryId', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7005, 'RefOther', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7006, 'RefServicePoint', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7007, 'RefProject', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7008, 'RefYourReference', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7009, 'RefEngineer', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7010, 'RefCustomer', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 7011, 'RefAgentReference', true, true);

        InsertMapping(Database::"IDYS Transport Order Header", 8000, 'LoadMeter', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 8001, 'Instruction', true, true);

        InsertMapping(Database::"IDYS Transport Order Header", 50101, 'ShipmentValueCurrency', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 50110, 'ShipmentValue', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 50121, 'CostCurrency', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 50130, 'ShipmentCost', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 50141, 'SpotPriceCurrency', true, true);
        InsertMapping(Database::"IDYS Transport Order Header", 50150, 'SpotPrice', true, true);

        InsertMapping(Database::"IDYS Carrier Select", 10, 'CarrierId', false, true);
        InsertMapping(Database::"IDYS Carrier Select", 11, 'Carrier', false, true);
        InsertMapping(Database::"IDYS Carrier Select", 12, 'PickupDate', false, true);
        InsertMapping(Database::"IDYS Carrier Select", 13, 'DeliveryDate', false, true);
        InsertMapping(Database::"IDYS Carrier Select", 14, 'DeliveryTime', false, true);
        InsertMapping(Database::"IDYS Carrier Select", 15, 'Price', false, true);
        InsertMapping(Database::"IDYS Carrier Select", 16, 'ServiceLevelTime', false, true);
        InsertMapping(Database::"IDYS Carrier Select", 17, 'ServiceLevelOther', false, true);
        InsertMapping(Database::"IDYS Carrier Select", 18, 'ServiceLevelTimeId', false, true);
        InsertMapping(Database::"IDYS Carrier Select", 19, 'ServiceLevelOtherId', false, true);

        InsertMapping(Database::"IDYS Transport Order Package", 10, 'Id', true, true);
        InsertMapping(Database::"IDYS Transport Order Package", 21, 'PackagingType', true, true);
        InsertMapping(Database::"IDYS Transport Order Package", 30, 'Description', true, true);
        InsertMapping(Database::"IDYS Transport Order Package", 40, 'Quantity', true, true);
        InsertMapping(Database::"IDYS Transport Order Package", 50, 'Length', true, true);
        InsertMapping(Database::"IDYS Transport Order Package", 60, 'Width', true, true);
        InsertMapping(Database::"IDYS Transport Order Package", 70, 'Height', true, true);
        InsertMapping(Database::"IDYS Transport Order Package", 80, 'Weight', true, true);
    end;

    local procedure InsertMapping(TableID: Integer; FieldNo: Integer; ElementName: Text[30]; IncludeInSerialization: Boolean; IncludeInDeserialization: Boolean);
    begin
        "Table ID" := TableID;
        "Field No." := FieldNo;
        "Element Name" := ElementName;
        "Include in Serialization" := IncludeInSerialization;
        "Include in Deserialization" := IncludeInDeserialization;
        Insert();
    end;
}