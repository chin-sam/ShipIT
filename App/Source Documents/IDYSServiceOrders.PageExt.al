pageextension 11147670 "IDYS Service Orders" extends "Service Orders"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("IDYS Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = Service;
                SubPageLink = "Source Document Table No." = const(5900), "Source Document No." = field("No."), "Source Document Type" = field("Document Type");
            }
        }
    }

    actions
    {
        addafter("Create Whse Shipment")
        {
            group("IDYS ShipIT Actions")
            {
                Caption = 'ShipIT';
                Image = SalesShipment;

                action("IDYS Create Transport Order")
                {
                    Caption = 'Create Transport Order';
                    Image = NewDocument;
                    ApplicationArea = Warehouse;
                    ToolTip = 'Creates a transport order.';
                    Visible = ShowUnpostedTO;

                    trigger OnAction()
                    var
                        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentManagement.ServiceHeader_CreateTransportOrder(Rec);
                    end;
                }
            }
        }
        addbefore("O&rder")
        {
            group("IDYS ShipIT Navigate")
            {
                Caption = 'ShipIT';
                Image = SalesShipment;

                action("IDYS Transport Orders")
                {
                    Caption = 'Transport Orders';
                    Image = Documents;
                    ApplicationArea = Service;
                    ToolTip = 'View a list of the available Transport Orders for this document.';

                    trigger OnAction()
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Service Header", Rec."Document Type".AsInteger(), Rec."No.");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        IDYSSetup: Record "IDYS Setup";
        LicenseCheck: Codeunit "IDYS License Check";
        ErrorMessage: Text;
        HttpStatusCode: Integer;
    begin
        if not IDYSSetup.Get() then
            exit;
        if IDYSSetup."License Entry No." = 0 then
            exit;
        LicenseCheck.SetPostponeWriteTransactions();
        LicenseCheck.SetHideErrors(true);
        LicenseCheck.CheckLicense(IDYSSetup."License Entry No.", ErrorMessage, HttpStatusCode);

        ShowUnpostedTO := (IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents");
    end;


    var
        ShowUnpostedTO: Boolean;
}