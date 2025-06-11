table 11147639 "IDYS Setup"
{
    Caption = 'ShipIT Setup';
    LookupPageId = "IDYS Setup";
    DataCaptionFields = Provider;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(4; "Shipping Cost Surcharge (%)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Default Shipping Cost Surcharge (%)';
        }
        field(5; "Transsmart Account Code"; Text[30])
        {
            Caption = 'Account Code';
            DataClassification = SystemMetadata;
        }
        field(6; "Auto. Add One Default Package"; Boolean)
        {
            Caption = 'Automatically Add One Default Package';
            DataClassification = CustomerContent;
        }
        field(7; "Default Package Type"; Code[50])
        {
            Caption = 'Default Package Type';
            TableRelation = "IDYS Package Type";
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Restructured with Provider level';
        }
        field(8; "Transport Order Nos."; Code[20])
        {
            Caption = 'Transport Order Nos.';
            TableRelation = "No. Series";
            DataClassification = SystemMetadata;
        }
        field(9; "Pick-up Time From"; Time)
        {
            Caption = 'Pick-up Time From';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Pick-up From DT", CreateDateTime(WorkDate(), "Pick-up Time From"));
            end;
        }
        field(10; "Pick-up Time To"; Time)
        {
            Caption = 'Pick-up Time To';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Pick-up To DT", CreateDateTime(WorkDate(), "Pick-up Time To"));
            end;
        }
        field(11; "Delivery Time From"; Time)
        {
            Caption = 'Delivery Time From';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Delivery From DT", CreateDateTime(WorkDate(), "Delivery Time From"));
            end;
        }
        field(12; "Delivery Time To"; Time)
        {
            Caption = 'Delivery Time To';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Delivery To DT", CreateDateTime(WorkDate(), "Delivery Time To"));
            end;
        }
        field(13; "Packages Mandatory"; Boolean)
        {
            Caption = 'Packages Mandatory';
            Description = 'SI-15';
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(14; "Base Transport Orders on"; Option)
        {
            Caption = 'Base Transport Orders On';
            Description = 'SI-16';
            OptionCaption = 'Unposted documents,,,,,Posted documents';
            OptionMembers = "Unposted documents",,,,,"Posted documents";
            DataClassification = SystemMetadata;

            trigger OnValidate();
            var
                TransportSourceFilter: Record "IDYS Transport Source Filter";
            begin
                if ("Base Transport Orders on" <> xRec."Base Transport Orders on") then begin
                    "After Posting Sales Orders" := "After Posting Sales Orders"::"Do nothing";
                    "After Posting Purch. Ret. Ord." := "After Posting Purch. Ret. Ord."::"Do nothing";
                    "After Posting Service Orders" := "After Posting Service Orders"::"Do nothing";
                    "After Posting Transfer Orders" := "After Posting Transfer Orders"::"Do nothing";

                    if ("Base Transport Orders on" = "Base Transport Orders on"::"Posted documents") then begin
                        Validate("Skip Source Docs Upd after TO", true);
                        if GuiAllowed() then
                            Message(UnpostedSourceDocsExistMsg);
                    end;
                end;

                if "Base Transport Orders on" = "Base Transport Orders on"::"Posted documents" then begin
                    TransportSourceFilter.ModifyAll("Sales Orders", false);
                    TransportSourceFilter.ModifyAll("Service Orders", false);
                    TransportSourceFilter.ModifyAll("Transfer Orders", false);
                    TransportSourceFilter.ModifyAll("Purchase Return Orders", false);
                end;

                if "Base Transport Orders on" = "Base Transport Orders on"::"Unposted documents" then begin
                    TransportSourceFilter.ModifyAll("Posted Purch. Return Shipments", false);
                    TransportSourceFilter.ModifyAll("Posted Return Receipts", false);
                    TransportSourceFilter.ModifyAll("Posted Sales Shipments", false);
                    TransportSourceFilter.ModifyAll("Posted Service Shipments", false);
                    TransportSourceFilter.ModifyAll("Posted Transfer Shipments", false);
                end;
            end;
        }
        field(15; "After Posting Sales Orders"; Option)
        {
            Caption = 'After Posting Sales Orders';
            OptionCaption = 'Do nothing,Auto-Create Transport Order(s),Create and Book Transport Order(s),Create + Book and Print Transport Order(s)';
            OptionMembers = "Do nothing","Auto-Create Transport Order(s)","Create and Book Transport Order(s)","Create + Book and Print Transport Order(s)";
            DataClassification = SystemMetadata;
        }
        field(16; "After Posting Purch. Ret. Ord."; Option)
        {
            Caption = 'After Posting Purch. Return Orders';
            OptionCaption = 'Do nothing,Auto-Create Transport Order(s),Create and Book Transport Order(s),Create + Book and Print Transport Order(s)';
            OptionMembers = "Do nothing","Auto-Create Transport Order(s)","Create and Book Transport Order(s)","Create + Book and Print Transport Order(s)";
            DataClassification = SystemMetadata;
        }
        field(17; "After Posting Service Orders"; Option)
        {
            Caption = 'After Posting Service Orders';
            OptionCaption = 'Do nothing,Auto-Create Transport Order(s),Create and Book Transport Order(s),Create + Book and Print Transport Order(s)';
            OptionMembers = "Do nothing","Auto-Create Transport Order(s)","Create and Book Transport Order(s)","Create + Book and Print Transport Order(s)";
            DataClassification = SystemMetadata;
        }
        field(18; "After Posting Transfer Orders"; Option)
        {
            Caption = 'After Posting Transfer Orders';
            OptionCaption = 'Do nothing,Auto-Create Transport Order(s),Create and Book Transport Order(s),Create + Book and Print Transport Order(s)';
            OptionMembers = "Do nothing","Auto-Create Transport Order(s)","Create and Book Transport Order(s)","Create + Book and Print Transport Order(s)";
            DataClassification = SystemMetadata;
        }
        field(19; "Base Preferred Date on"; option)
        {
            Caption = 'Base Preferred Date on';
            DataClassification = SystemMetadata;
            OptionMembers = "Planned Date","Posting Date";
            OptionCaption = 'Planned Date,Posting Date';
        }
        field(20; "Always New Trns. Order"; Boolean)
        {
            Caption = 'Always New Trns. Order';
            DataClassification = SystemMetadata;
        }
        field(21; "Default E-Mail Type"; Code[127])
        {
            Caption = 'Default E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            DataClassification = SystemMetadata;
        }
        field(22; "Default Cost Center"; Code[50])
        {
            Caption = 'Default Cost Center';
            TableRelation = "IDYS Cost Center";
            DataClassification = SystemMetadata;
        }
        field(23; "Read All Package Lines"; Boolean)
        {
            Caption = 'Read All Package Lines';
            ObsoleteState = Removed;
            ObsoleteReason = 'No longer used field.';
            DataClassification = SystemMetadata;
        }
        field(24; "Enable Debug Mode"; Boolean)
        {
            Caption = 'Enable Debug Mode';
            DataClassification = SystemMetadata;
        }
        field(26; "Transsmart Environment"; Option)
        {
            Caption = 'Environment';
            OptionCaption = 'Acceptance,Production';
            OptionMembers = "Acceptance","Production";
            DataClassification = SystemMetadata;
        }
        field(27; "Address for Invoice Address"; Option)
        {
            Caption = 'Address for Invoice Address';
            OptionCaption = 'Bill-to Customer,Sell-to Customer';
            OptionMembers = "Bill-to Customer","Sell-to Customer";
            DataClassification = SystemMetadata;
        }
        field(28; "Logging Level"; Enum "IDYS Logging Level")
        {
            DataClassification = SystemMetadata;
        }
        field(30; "License Key"; Text[50])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by App Management App';
            ObsoleteTag = '19.7';
            DataClassification = CustomerContent;
        }
        field(31; "default Ship-to Country"; Code[10])
        {
            Caption = 'Default Ship-to Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(32; "License Grace Period Start"; DateTime)
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by App Management App';
            ObsoleteTag = '19.7';

            Caption = 'License Check Grace Period (Start)';
            DataClassification = SystemMetadata;
        }
        field(33; "Add Freight Line"; Boolean)
        {
            Caption = 'Add Freight Line';
            DataClassification = SystemMetadata;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Cust. Inv. Discount';
            ObsoleteTag = '21.0';
        }
        field(34; "Background Booking"; Boolean)
        {
            Caption = 'Background Booking';
            DataClassification = SystemMetadata;
        }
        field(35; "Add Delivery Notes"; Boolean)
        {
            Caption = 'Add Delivery Notes For Source Lines';
            DataClassification = CustomerContent;
        }
        field(36; "Archive Retention Period"; DateFormula)
        {
            Caption = 'Archive Retention Period';
            ObsoleteReason = 'Replaced by field 37.';
            ObsoleteState = Removed;
            DataClassification = CustomerContent;
        }
        field(37; "Retention Period (Days)"; Integer)
        {
            Caption = 'Transport Order Retention Period (Days)';
            InitValue = 31;
            DataClassification = CustomerContent;
        }
        field(38; "Allow All Item Types"; Boolean)
        {
            Caption = 'Allow All Item Types';
            DataClassification = SystemMetadata;
        }
        field(39; "Remove Attachments on Arch."; Boolean)
        {
            Caption = 'Remove Attachments on Archiving';
            DataClassification = CustomerContent;
        }
        field(40; "Pick-up From DT"; Datetime)
        {
            Caption = 'Pick-up Time From';
            DataClassification = SystemMetadata;
        }
        field(41; "Pick-up To DT"; Datetime)
        {
            Caption = 'Pick-up Time To';
            DataClassification = SystemMetadata;
        }
        field(42; "Delivery From DT"; Datetime)
        {
            Caption = 'Delivery Time From';
            DataClassification = SystemMetadata;
        }
        field(43; "Delivery To DT"; Datetime)
        {
            Caption = 'Delivery Time To';
            DataClassification = SystemMetadata;
        }
        field(44; "Skip Source Docs Upd after TO"; Boolean)
        {
            Caption = 'Skip updating Source Documents after booking TO';
            DataClassification = SystemMetadata;
        }
        field(50; "Copy Ship. Agent to Whse-Docs"; Boolean)
        {
            Caption = 'Copy Shipping Info to Warehouse Shipments';
            DataClassification = CustomerContent;
        }
        field(51; "No TO Created Notification"; Boolean)
        {
            Caption = 'Suppress Transport Order Created Notification';
            DataClassification = CustomerContent;
        }
        field(52; "After Post Sales Return Orders"; Option)
        {
            Caption = 'After Posting Sales Return Orders';
            OptionCaption = 'Do nothing,Auto-Create Transport Order(s),Create and Book Transport Order(s),Create + Book and Print Transport Order(s)';
            OptionMembers = "Do nothing","Auto-Create Transport Order(s)","Create and Book Transport Order(s)","Create + Book and Print Transport Order(s)";
            DataClassification = SystemMetadata;
            ObsoleteState = Pending;
            ObsoleteReason = 'Removed due to wrongfully implemented flow';
            ObsoleteTag = '21.0';
        }
        field(53; "Bing API Key"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Map Service API Key';
        }
        field(54; "Link Del. Lines with Packages"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Link Delivery Lines with Packages';
        }
        field(55; "Allow Link Del. Lines with Pck"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Allow Linking Delivery Lines with Packages';
            Access = Internal;

            trigger OnValidate()
            begin
                "Link Del. Lines with Packages" := "Allow Link Del. Lines with Pck";
            end;
        }
        field(56; "Default Provider Package Type"; Code[50])
        {
            Caption = 'Default Package Type';
            TableRelation = "IDYS Provider Package Type".Code Where(Provider = field(Provider));
            DataClassification = CustomerContent;
        }
        field(57; "Skip Source Doc. Packages"; Boolean)
        {
            Caption = 'Don''t copy Sales Order Packages';
            DataClassification = CustomerContent;
        }
        field(58; "Enable PrintIT Printing"; Boolean)
        {
            Caption = 'Enable PrintIT Printing';
            DataClassification = CustomerContent;
        }
        field(59; "PrintIT Enabled"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'PrintIT Enabled';
            Access = Internal;
        }
        field(60; "Enable Insurance"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Insurance';

            trigger OnValidate()
            begin
                if not "Enable Insurance" then
                    "Enable Min. Shipment Amount" := false;
            end;
        }
        field(61; "Enable Min. Shipment Amount"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Min. Shipment Amount';

            trigger OnValidate()
            var
                NotificationManagement: Codeunit "IDYS Notification Management";
                EnableMinShipmentPerItemCategoryMsg: Label 'Please configure the minimum shipment amount requirements for each item category separately. Insurance will not be applied if the minimum requirement is not met.';
                ItemCategoriesLbl: Label 'Item Categories';
            begin
                if "Enable Min. Shipment Amount" and GuiAllowed() then
                    NotificationManagement.SendEnableMinShipmentPerItemCategoryNotification(EnableMinShipmentPerItemCategoryMsg, ItemCategoriesLbl, Codeunit::"IDYS Notification Management", 'OpenItemCategories');
            end;
        }
        field(62; "Map Service Provider"; Option)
        {
            Caption = 'Map Service Provider';
            OptionMembers = "Bing Maps","Azure Maps";
            OptionCaption = 'Bing Maps,Azure Maps';
            DataClassification = CustomerContent;
        }
        field(102; "License Entry No."; Integer)
        {
            TableRelation = "IDYM App License Key"."Entry No.";
            DataClassification = SystemMetadata;
            Caption = 'License Entry No.';
        }
        field(103; "Setup Verify Codeunit Id"; Integer)
        {
            Caption = 'Setup Verify Codeunit Id';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit));
        }
        field(104; "Setup Wizard Page Id"; Integer)
        {
            Caption = 'Setup Wizard Page Id';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));
        }
        field(105; "Setup Page Id"; Integer)
        {
            Caption = 'Setup Page Id';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));
        }

        #region [Conversion]
        field(150; "Conversion Factor (Mass)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Conversion Factor (Mass)';
            InitValue = 1;
            DecimalPlaces = 0 : 15;
        }
        field(151; "Rounding Precision (Mass)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision (Mass)';
            AutoFormatType = 1;
            InitValue = 0.01;
        }
        field(152; "Conversion Factor (Linear)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Conversion Factor (Linear)';
            InitValue = 1;
            DecimalPlaces = 0 : 15;
        }
        field(153; "Rounding Precision (Linear)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision (Linear)';
            AutoFormatType = 1;
            InitValue = 0.01;
        }
        field(154; "Conversion Factor (Volume)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Conversion Factor (Volume)';
            InitValue = 1;
            DecimalPlaces = 0 : 15;
        }
        field(155; "Rounding Precision (Volume)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision (Volume)';
            AutoFormatType = 1;
            InitValue = 0.01;
        }
        #endregion

        #region [Sendcloud]
        field(200; "Label Type"; Enum "IDYS SC Label Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Label Type';
        }
        field(201; "Apply External Document No."; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Use External Document No.';
        }
        field(202; "Apply Shipping Rules"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Apply Shipping Rules';
        }
        field(203; "Weight to KG Conversion Factor"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Weight to KG Conversion Factor';
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Conversion factors';
            ObsoleteTag = '21.0';
        }
        field(204; "Request Label"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Label';
        }
        #endregion
        #region [EasyPost]
        field(225; "Default Label Type"; Enum "IDYS DelHub Label Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Default Label Type';
        }
        #endregion
        field(250; "Aut. Select Appl. Ship. Method"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Automatically Select Applicable Ship. Method';
        }
        #region [Cargoson]
        field(260; "Label Format"; Enum "IDYS Cargoson Label Format")
        {
            Caption = 'Label Format';
            DataClassification = CustomerContent;
        }
        #endregion
        field(1000; "Unit Test Mode"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Unit Test Mode';
        }
        field(1001; "Enable Beta features"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Enable Beta features';
        }
        field(1002; "Use GetDocument Method"; Boolean)
        {
            DataClassification = SystemMetadata;
            ObsoleteState = Pending;
            ObsoleteReason = 'GetDocument replaced with GetStatus';
            ObsoleteTag = '24.0';
        }
        field(1003; Provider; Enum "IDYS Provider")
        {
            DataClassification = SystemMetadata;
        }
        field(1004; "Demo Mode"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(1005; "Dataset Size"; Integer)
        {
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(1006; "Next Sync Date"; Date)
        {
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(1007; "Last Used Sequence No."; Integer)
        {
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(1008; "Insurance Enabled"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
        }
    }

    trigger OnInsert();
    var
        CompanyInformation: Record "Company Information";
    begin
        Validate("Transsmart Environment");
        if "default Ship-to Country" = '' then
            if CompanyInformation.Get() then
                Validate("default Ship-to Country", CompanyInformation."Country/Region Code");

        case Provider of
            Provider::EasyPost:
                if "Default Label Type" = "Default Label Type"::none then
                    "Default Label Type" := "Default Label Type"::PNG;
        end;
    end;

    procedure GetProviderSetup(IDYSProvider: Enum "IDYS Provider")
    var
        SetupCode: Code[10];
    begin
        SetupCode := CopyStr("IDYS Provider".Names().Get("IDYS Provider".Ordinals().IndexOf(IDYSProvider.AsInteger())), 1, MaxStrLen(Rec."Primary Key"));
        if not Rec.Get(SetupCode) then begin
            Rec.Init();
            Rec."Primary Key" := SetupCode;
            Rec.Provider := IDYSProvider;
            Rec.Insert(true);
        end;
    end;

    procedure InitSetup()
    var
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
    begin
        Rec.Init();
        Rec.Validate("Delivery Time From", 080000T);
        Rec.Validate("Delivery Time To", 170000T);
        Rec.Validate("Pick-up Time From", 080000T);
        Rec.Validate("Pick-up Time To", 170000T);
        Rec.Validate("Transport Order Nos.", IDYSTransportOrderMgt.GetDefaultTransportOrderNoSeries())
    end;

    var
        UnpostedSourceDocsExistMsg: Label 'Transport orders with unposted source documents may exist. Be careful not to create transport orders for the same lines once they are posted.';
}

