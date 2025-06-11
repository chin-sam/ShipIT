table 11147698 "IDYS Source Document Service"
{
    DataClassification = CustomerContent;
    LookupPageId = "IDYS Source Document Services";
    Caption = 'Source Document Service Level (Other)';

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(2; "Document Type"; Enum "IDYS Source Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = if ("Table No." = Const(11147669)) "IDYS Transport Order Header"."No."
            else
            if ("Table No." = Const(36)) "Sales Header"."No." where("Document Type" = field("Document Type"))
            else
            if ("Table No." = Const(38)) "Purchase Header"."No." where("Document Type" = field("Document Type"))
            else
            if ("Table No." = Const(110)) "Sales Shipment Header"."No."
            else
            if ("Table No." = Const(6650)) "Return Shipment Header"."No."
            else
            if ("Table No." = Const(6660)) "Return Receipt Header"."No."
            else
            if ("Table No." = Const(5740)) "Transfer Header"."No."
            else
            if ("Table No." = Const(5744)) "Transfer Shipment Header"."No."
            else
            if ("Table No." = Const(5900)) "Service Header"."No." where("Document Type" = field("Document Type"))
            else
            if ("Table No." = Const(5990)) "Service Shipment Header"."No.";
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Service Level Code (Other)"; Code[50])
        {
            Caption = 'Service Level Code (Other)';
            TableRelation = "IDYS Service Level (Other)";
            DataClassification = CustomerContent;
        }
        field(5; "Service Level Code"; Code[50])
        {
            Caption = 'Service Level Code';
            FieldClass = FlowField;
            CalcFormula = lookup("IDYS Service Level (Other)"."Service Code" where(Code = field("Service Level Code (Other)")));
            Editable = false;
        }
        field(500; "System Created Entry"; Boolean)
        {
            Caption = 'System Created Entry';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Table No.", "Document Type", "Document No.", "Service Level Code (Other)")
        {
            Clustered = true;
        }
    }

    procedure CopyServiceLevels(FromSourceTable: Integer; FromDocumentType: Enum "IDYS Source Document Type"; FromDocumentNo: Code[20]; ToSourceTable: Integer; ToDocumentType: Enum "IDYS Source Document Type"; ToDocumentNo: Code[20])
    var
        SourceDocumentService: Record "IDYS Source Document Service";
    begin
        SourceDocumentService.SetRange("Table No.", FromSourceTable);
        SourceDocumentService.SetRange("Document Type", FromDocumentType);
        SourceDocumentService.SetRange("Document No.", FromDocumentNo);
        if SourceDocumentService.FindSet() then
            repeat
                if not Rec.Get(ToSourceTable, ToDocumentType, ToDocumentNo, SourceDocumentService."Service Level Code (Other)") then begin
                    Rec.Init();
                    Rec.Validate("Table No.", ToSourceTable);
                    Rec.Validate("Document Type", ToDocumentType);
                    Rec.Validate("Document No.", ToDocumentNo);
                    Rec.Validate("Service Level Code (Other)", SourceDocumentService."Service Level Code (Other)");
                    Rec.Insert(true);
                end;
            until SourceDocumentService.Next() = 0;
    end;

    procedure CheckMatchingServiceLevels(FromSourceTable: Integer; FromDocumentType: Enum "IDYS Source Document Type"; FromDocumentNo: Code[20]; ToSourceTable: Integer; ToDocumentType: Enum "IDYS Source Document Type"; ToDocumentNo: Code[20]) IsMatch: Boolean
    var
        FromSourceDocumentService: Record "IDYS Source Document Service";
        ToSourceDocumentService: Record "IDYS Source Document Service";
    begin
        // Used for the transport order combinability when services are included
        // Commit: d864ad86f7e07f86be486c3368ed631b4a73d7e5
        FromSourceDocumentService.SetRange("Table No.", FromSourceTable);
        FromSourceDocumentService.SetRange("Document Type", FromDocumentType);
        FromSourceDocumentService.SetRange("Document No.", FromDocumentNo);
        ToSourceDocumentService.SetRange("Table No.", ToSourceTable);
        ToSourceDocumentService.SetRange("Document Type", ToDocumentType);
        ToSourceDocumentService.SetRange("Document No.", ToDocumentNo);
        IsMatch := FromSourceDocumentService.Count() <> ToSourceDocumentService.Count();
        if not IsMatch then
            exit;
        if FromSourceDocumentService.FindSet() then
            repeat
                IsMatch := ToSourceDocumentService.Get(ToSourceTable, ToDocumentType, ToDocumentNo, FromSourceDocumentService."Service Level Code (Other)");
                if not IsMatch then
                    exit;
            until FromSourceDocumentService.Next() = 0;
    end;

    [Obsolete('Added new parameter', '21.9')]
    procedure SetDefaultServices(SourceTable: Integer; DocumentType: Enum "IDYS Source Document Type"; DocumentNo: Code[20]; CarrierEntryNo: Integer; BookingProfileEntryNo: Integer; CountryCode: Code[10])
    begin
    end;

    [Obsolete('Added new parameter', '22.0')]
    procedure SetDefaultServices(SourceTable: Integer; DocumentType: Enum "IDYS Source Document Type"; DocumentNo: Code[20]; var ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping"; ShipToCountryCode: Code[10]; SourceSystemId: Guid)
    begin
    end;

    procedure SetDefaultServices(SourceTable: Integer; DocumentType: Enum "IDYS Source Document Type"; DocumentNo: Code[20]; var ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping"; ShipFromCountryCode: Code[10]; ShipToCountryCode: Code[10]; SourceSystemId: Guid)
    var
        DelHubAPIDefService: Record "IDYS DelHub API Def. Service";
        SourceDocumentService: Record "IDYS Source Document Service";
        DelHubAPIDocsMgt: Codeunit "IDYS DelHub API Docs. Mgt.";
    begin
        SourceDocumentService.SetRange("Table No.", SourceTable);
        SourceDocumentService.SetRange("Document Type", DocumentType);
        SourceDocumentService.SetRange("Document No.", DocumentNo);
        SourceDocumentService.DeleteAll();

        DelHubAPIDefService.SetRange("Shipping Agent Code", ShipAgentSvcMapping."Shipping Agent Code");
        DelHubAPIDefService.SetRange("Shipping Agent Service Code", ShipAgentSvcMapping."Shipping Agent Service Code");
        DelHubAPIDefService.SetFilter("Country Code", '%1|%2', '', ShipFromCountryCode);
        DelHubAPIDefService.SetRange("User Default", true);
        DelHubAPIDefService.SetAutoCalcFields("Service Level Code (Other)");
        if DelHubAPIDefService.FindSet() then
            repeat
                if DelHubAPIDocsMgt.IsAllowedToShip(DelHubAPIDefService."DelHub API Service Entry No.", ShipToCountryCode) then begin
                    SourceDocumentService.Init();
                    SourceDocumentService.Validate("Table No.", SourceTable);
                    SourceDocumentService.Validate("Document Type", DocumentType);
                    SourceDocumentService.Validate("Document No.", DocumentNo);
                    SourceDocumentService.Validate("Service Level Code (Other)", DelHubAPIDefService."Service Level Code (Other)");
                    SourceDocumentService.Validate("System Created Entry", true);
                    SourceDocumentService.Insert(true);
                end
            until DelHubAPIDefService.Next() = 0;
    end;
}