
pageextension 11147649 "IDYS Transfer Orders" extends "Transfer Orders"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("IDYS Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = Location;
                SubPageLink = "Source Document Table No." = const(5740), "Source Document No." = field("No.");
            }
        }
    }

    actions
    {
        addafter("F&unctions")
        {
            group("IDYS ShipIT Actions")
            {
                Caption = 'ShipIT';
                Image = SalesShipment;

                action("IDYS Create Transport Order")
                {
                    Caption = 'Create Transport Order';
                    Image = NewDocument;
                    ApplicationArea = Location;
                    ToolTip = 'Creates a transport order.';
                    Visible = ShowUnpostedTO;

                    trigger OnAction()
                    var
                        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentManagement.TransferHeader_CreateTransportOrder(Rec);
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
                    ApplicationArea = Location;
                    ToolTip = 'View a list of the available Transport Orders for this document.';

                    trigger OnAction()
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Transfer Header", 0, Rec."No.");
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