page 11147718 "IDYS Select Service Lvl Other"
{
    PageType = List;
    Caption = 'Source Document Services (Other)';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "IDYS DelHub API Services";
    SourceTableView = sorting("Carrier Entry No.", "Booking Profile Entry No.", IsGroup);
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    DataCaptionExpression = ThisPageCaption;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(GroupId; Rec."Selected GroupID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies if the Service levels are grouped. Only one service level can be selected per group.';
                }
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                }
                field("Booking Profile Description"; Rec."Booking Profile Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the booking profile description.';
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country code.';
                }
                field(IsGroup; Rec.IsGroup)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates that the service level code can be selected from a group of option values. Use the lookup to select the correct value.';
                }
                field("Service Level Code (Other)"; Rec."Service Level Code (Other)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Service level (Other).';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with variable';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }
                field(ServiceLevelCode; ServiceLevelCode)
                {
                    ApplicationArea = All;
                    Caption = 'Service Level Code';
                    ToolTip = 'Specifies the Service Level Code.';

                    trigger OnValidate()
                    var
                        IDYSDelHubAPIServices: Record "IDYS DelHub API Services";
                    begin
                        if not Rec.IsGroup then
                            Error(NotAllowedEntryTypeErr);

                        if ServiceLevelCode = '' then begin
                            ValidateRecSelected(false, true, Rec);
                            Rec."Service Level Code (Other)" := '';
                            Rec.Selected := false;
                        end else begin
                            IDYSDelHubAPIServices.SetRange("Carrier Entry No.", Rec."Carrier Entry No.");
                            IDYSDelHubAPIServices.SetRange("Booking Profile Entry No.", Rec."Booking Profile Entry No.");
                            if PageMode = PageMode::SelectServices then
                                IDYSDelHubAPIServices.SetFilter("Country Code", '%1|%2', '', ShipFromCountryCode);
                            IDYSDelHubAPIServices.SetRange(GroupId, Rec."Selected GroupId");
                            IDYSDelHubAPIServices.SetRange("Service Level Code", ServiceLevelCode);
                            if not IDYSDelHubAPIServices.FindLast() then
                                Error(NotAllowedEntryErr);

                            ClearGroupSelection();
                            Rec."Service Level Code (Other)" := IDYSDelHubAPIServices."Service Level Code (Other)";
                            Rec.Selected := true;
                            ValidateRecSelected(true, false, IDYSDelHubAPIServices);
                        end;

                        CurrPage.Update();
                    end;

                    trigger OnDrillDown()
                    var
                        IDYSDelHubAPIServices: Record "IDYS DelHub API Services";
                        IDYSDelHubAPIServicesList: Page "IDYS DelHub API Services";
                    begin
                        if Rec."Selected GroupId" <> 0 then begin
                            IDYSDelHubAPIServices.FilterGroup(10);
                            IDYSDelHubAPIServices.SetRange("Carrier Entry No.", Rec."Carrier Entry No.");
                            IDYSDelHubAPIServices.SetRange("Booking Profile Entry No.", Rec."Booking Profile Entry No.");
                            if PageMode = PageMode::SelectServices then
                                IDYSDelHubAPIServices.SetFilter("Country Code", '%1|%2', '', ShipFromCountryCode);
                            IDYSDelHubAPIServices.SetRange(GroupId, Rec."Selected GroupId");
                            IDYSDelHubAPIServices.SetAutoCalcFields("Carrier Name");
                            IDYSDelHubAPIServices.FilterGroup(0);

                            IDYSDelHubAPIServicesList.SetTableView(IDYSDelHubAPIServices);
                            IDYSDelHubAPIServicesList.LookupMode := true;
                            IDYSDelHubAPIServicesList.Editable := false;
                            if IDYSDelHubAPIServicesList.RunModal() = Action::LookupOK then begin
                                ClearGroupSelection();
                                IDYSDelHubAPIServicesList.GetRecord(IDYSDelHubAPIServices);

                                Rec."Service Level Code (Other)" := IDYSDelHubAPIServices."Service Level Code (Other)";
                                Rec.Selected := true;

                                ValidateRecSelected(true, false, IDYSDelHubAPIServices);
                                CurrPage.Update();
                            end;
                        end;
                    end;
                }
                field(Selected; Rec.Selected)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if the Service level (Other) is applicable for this transport order.';
                    Caption = 'Include';
#if BC17
#pragma warning disable AL0604
                    Enabled = ("Service Level Code (Other)" <> '') and not "Selected Read Only";
#pragma warning restore AL0604
#else
                    Enabled = (Rec."Service Level Code (Other)" <> '') and not Rec."Selected Read Only";
#endif
                    trigger OnValidate()
                    begin
                        ValidateRecSelected(Rec.Selected, false, Rec);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DisableAll)
            {
                ApplicationArea = All;
                Caption = 'Disable All';
                Image = CancelAllLines;
                ToolTip = 'Remove all services from the document';
                Visible = (PageMode = PageMode::SelectServices);

                trigger OnAction()
                var
                    SourceDocumentService: Record "IDYS Source Document Service";
                begin
                    SourceDocumentService.SetRange("Table No.", SourceTable);
                    SourceDocumentService.SetRange("Document Type", DocumentType);
                    SourceDocumentService.SetRange("Document No.", DocumentNo);
                    if not SourceDocumentService.IsEmpty() then
                        SourceDocumentService.DeleteAll();
                    Rec.ModifyAll(Selected, false);
                end;
            }
        }
    }


    trigger OnOpenPage()
    var
        NoServicesMsg: Label 'There are no services available in this country.';
    begin
        if Rec.IsEmpty() then
            IDYSNotificationManagement.SendNotification(NoServicesMsg);
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Service Level Code", "Is Default");
        ServiceLevelCode := Rec."Service Level Code";
    end;

    procedure InitializePage(CarrierEntryNo: Integer; BookingProfileEntryNo: Integer)
    var
        DelHubAPIServices: Record "IDYS DelHub API Services";
        DelHubAPIDocsMgt: Codeunit "IDYS DelHub API Docs. Mgt.";
    begin
        DelHubAPIServices.SetRange("Carrier Entry No.", CarrierEntryNo);
        DelHubAPIServices.SetRange("Booking Profile Entry No.", BookingProfileEntryNo);
        DelHubAPIServices.SetCurrentKey("Carrier Entry No.", "Booking Profile Entry No.", GroupId);
        DelHubAPIServices.SetAutoCalcFields("Is Default", "Read Only", GroupId);
        if PageMode = PageMode::SelectServices then
            DelHubAPIServices.SetFilter("Country Code", '%1|%2', '', ShipFromCountryCode);
        if DelHubAPIServices.FindSet() then
            repeat
                if (PageMode = PageMode::SetDefaultServices) or (DelHubAPIDocsMgt.IsAllowedToShip(DelHubAPIServices."Entry No.", ShipToCountryCode)) then begin
                    Rec.Init();
                    Rec := DelHubAPIServices;
                    Rec."Selected GroupID" := DelHubAPIServices.GroupId;
                    Rec."Selected Read Only" := DelHubAPIServices."Read Only";
                    Rec.IsGroup := Rec."Selected GroupID" <> 0;
                    if DelHubAPIServices.GroupId = 0 then begin
                        Rec.Selected := IsSelected(DelHubAPIServices);
                        if not Rec.Selected then
                            Rec.Selected := DelHubAPIServices."Is Default";
                    end else begin
                        Rec."Service Level Code (Other)" := '';
                        DelHubAPIServices.SetRange(GroupId, DelHubAPIServices.GroupId);
                        if DelHubAPIServices.FindSet() then
                            repeat
                                if not Rec.Selected then begin
                                    Rec.Selected := IsSelected(DelHubAPIServices);
                                    if Rec.Selected or DelHubAPIServices."Is Default" then
                                        Rec."Service Level Code (Other)" := DelHubAPIServices."Service Level Code (Other)";
                                end;
                            until DelHubAPIServices.Next() = 0;
                        DelHubAPIServices.SetRange(GroupId);
                    end;
                    Rec.Insert();
                end;
            until DelHubAPIServices.Next() = 0;

        // Reset the pointer
        if Rec.FindFirst() then;
    end;

#pragma warning disable AA0244
    [Obsolete('Removed Parameters', '19.9')]
    procedure InitializePage(NewSourceTable: Integer; NewDocumentType: Enum "IDYS Source Document Type"; NewDocumentNo: Code[20]; CarrierEntryNo: Integer; BookingProfileEntryNo: Integer; CountryCode: Code[10])
    begin
    end;
#pragma warning restore AA0244

    local procedure ValidateRecSelected(Select: Boolean; UsePrevRec: Boolean; var DelHubAPIServices: Record "IDYS DelHub API Services")
    var
        SourceDocumentService: Record "IDYS Source Document Service";
        DelHubAPIDefService: Record "IDYS DelHub API Def. Service";
    begin
        case PageMode of
            PageMode::SetDefaultServices:
                begin
                    // Clear Group Selection
                    if not Select and DelHubAPIServices.IsGroup then
                        ClearGroupSelection();

                    if DelHubAPIDefService.Get(IDYSShipAgentSvcMapping."Shipping Agent Code", IDYSShipAgentSvcMapping."Shipping Agent Service Code", DelHubAPIServices."Entry No.") then begin
                        DelHubAPIDefService."User Default" := Select;
                        DelHubAPIDefService.Modify();
                    end;
                end;
            PageMode::SelectServices:
                if not Select then begin
                    if UsePrevRec then
                        SourceDocumentService.Get(SourceTable, DocumentType, DocumentNo, xRec."Service Level Code (Other)")
                    else
                        SourceDocumentService.Get(SourceTable, DocumentType, DocumentNo, Rec."Service Level Code (Other)");
                    SourceDocumentService.Delete(true);
                end else begin
                    SourceDocumentService.Init();
                    SourceDocumentService.Validate("Table No.", SourceTable);
                    SourceDocumentService.Validate("Document Type", DocumentType);
                    SourceDocumentService.Validate("Document No.", DocumentNo);
                    SourceDocumentService.Validate("Service Level Code (Other)", Rec."Service Level Code (Other)");
                    SourceDocumentService.Insert(true);
                end;
        end;
    end;

    local procedure ClearGroupSelection()
    var
        DelHubAPIServices: Record "IDYS DelHub API Services";
        DelHubAPIDefService: Record "IDYS DelHub API Def. Service";
        SourceDocumentService: Record "IDYS Source Document Service";
    begin
        case PageMode of
            PageMode::SetDefaultServices:
                begin
                    DelHubAPIServices.SetRange("Carrier Entry No.", Rec."Carrier Entry No.");
                    DelHubAPIServices.SetRange("Booking Profile Entry No.", Rec."Booking Profile Entry No.");
                    DelHubAPIServices.SetRange(GroupId, Rec."Selected GroupID");
                    DelHubAPIServices.SetAutoCalcFields("Is Default");
                    if DelHubAPIServices.FindSet() then
                        repeat
                            if DelHubAPIDefService.Get(IDYSShipAgentSvcMapping."Shipping Agent Code", IDYSShipAgentSvcMapping."Shipping Agent Service Code", DelHubAPIServices."Entry No.") then begin
                                DelHubAPIDefService."User Default" := false;
                                DelHubAPIDefService.Modify();
                            end;
                        until DelHubAPIServices.Next() = 0;
                end;
            PageMode::SelectServices:
                begin
                    DelHubAPIServices.SetRange("Carrier Entry No.", Rec."Carrier Entry No.");
                    DelHubAPIServices.SetRange("Booking Profile Entry No.", Rec."Booking Profile Entry No.");
                    DelHubAPIServices.SetRange(GroupId, Rec."Selected GroupID");
                    if DelHubAPIServices.FindSet() then
                        repeat
                            if SourceDocumentService.Get(SourceTable, DocumentType, DocumentNo, DelHubAPIServices."Service Level Code (Other)") then
                                SourceDocumentService.Delete(true);
                        until DelHubAPIServices.Next() = 0;
                end;
        end;
    end;

    local procedure IsSelected(var DelHubAPIServices: Record "IDYS DelHub API Services"): Boolean
    var
        SourceDocumentService: Record "IDYS Source Document Service";
        IDYSDelHubAPIDefService: Record "IDYS DelHub API Def. Service";
    begin
        case PageMode of
            PageMode::SetDefaultServices:
                // Default service (set by user)
                if IDYSDelHubAPIDefService.Get(IDYSShipAgentSvcMapping."Shipping Agent Code", IDYSShipAgentSvcMapping."Shipping Agent Service Code", DelHubAPIServices."Entry No.") then
                    exit(IDYSDelHubAPIDefService."User Default");
            PageMode::SelectServices:
                // Selected service on document
                if SourceDocumentService.Get(SourceTable, DocumentType, DocumentNo, DelHubAPIServices."Service Level Code (Other)") then
                    exit(true);
        end;
    end;

    [Obsolete('Added additional paramaters', '21.9')]
    procedure SetParameters(NewSourceTable: Integer; NewDocumentType: Enum "IDYS Source Document Type"; NewDocumentNo: Code[20]; NewCountryCode: Code[10])
    begin
    end;

    [Obsolete('Added additional paramaters', '22.0')]
    procedure SetParameters(NewSourceTable: Integer; NewDocumentType: Enum "IDYS Source Document Type"; NewDocumentNo: Code[20]; NewShipToCountry: Code[10]; SourceSystemId: Guid)
    begin
    end;

    procedure SetParameters(NewSourceTable: Integer; NewDocumentType: Enum "IDYS Source Document Type"; NewDocumentNo: Code[20]; NewShipFromCountry: Code[10]; NewShipToCountry: Code[10]; SourceSystemId: Guid)
    var
        SalesOrder: Page "Sales Order";
        SalesReturnOrder: Page "Sales Return Order";
        PurchaseReturnOrder: Page "Purchase Return Order";
        PurchaseOrder: Page "Purchase Order";
        TransferOrder: Page "Transfer Order";
        ServiceOrder: Page "Service Order";
        SourceType: Text;
        TransportOrderLbl: Label 'Transport Order';
    begin
        PageMode := PageMode::SelectServices;

        SourceTable := NewSourceTable;
        DocumentType := NewDocumentType;
        DocumentNo := NewDocumentNo;
        ShipToCountryCode := NewShipToCountry;
        ShipFromCountryCode := NewShipFromCountry;

        case SourceTable of
            Database::"Sales Header":
                case DocumentType of
                    DocumentType::"1":
                        SourceType := SalesOrder.Caption();
                    DocumentType::"5":
                        SourceType := SalesReturnOrder.Caption();
                end;
            Database::"Purchase Header":
                case DocumentType of
                    DocumentType::"1":
                        SourceType := PurchaseOrder.Caption();
                    DocumentType::"5":
                        SourceType := PurchaseReturnOrder.Caption();
                end;
            Database::"Transfer Header":
                SourceType := TransferOrder.Caption();
            Database::"Service Header":
                case DocumentType of
                    DocumentType::"1":
                        SourceType := ServiceOrder.Caption();
                end;
            Database::"IDYS Transport Order Header":
                SourceType := TransportOrderLbl;
        end;

        ThisPageCaption := SourceType + ' ' + DocumentNo;
    end;

    procedure SetParameters(NewPageCaption: Text; var NewIDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping")
    begin
        PageMode := PageMode::SetDefaultServices;

        ThisPageCaption := NewPageCaption;
        IDYSShipAgentSvcMapping := NewIDYSShipAgentSvcMapping;
    end;

    var
        IDYSShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        SourceTable: Integer;
        DocumentType: Enum "IDYS Source Document Type";
        DocumentNo: Code[20];
        ThisPageCaption: Text;
        ServiceLevelCode: Code[50];
        ShipFromCountryCode: Code[10];
        ShipToCountryCode: Code[10];
        PageMode: Option SelectServices,SetDefaultServices;
        NotAllowedEntryErr: Label 'Your provided value could not be found. Please use the drilldown to select the value.';
        NotAllowedEntryTypeErr: Label 'You cannot change a predefined value.';
}