pageextension 11147667 "IDYS Sales Return Order List" extends "Sales Return Order List"
{
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
                    ApplicationArea = All;
                    ToolTip = 'Creates a transport order.';

                    trigger OnAction()
                    var
                        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentManagement.SalesHeader_CreateTransportOrder(Rec);
                    end;
                }
            }
        }
        addbefore("&Return Order")
        {
            group("IDYS ShipIT Navigate")
            {
                Caption = 'ShipIT';
                Image = SalesShipment;

                action("IDYS Transport Orders")
                {
                    Caption = 'Transport Orders';
                    Image = Documents;
                    ApplicationArea = All;
                    ToolTip = 'View a list of the available Transport Orders for this document.';

                    trigger OnAction()
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Sales Header", Rec."Document Type".AsInteger(), Rec."No.");
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
    end;
}