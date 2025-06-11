pageextension 11147668 "IDYS Sales Order List" extends "Sales Order List"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("IDYS Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Source Document Table No." = const(36), "Source Document No." = field("No."), "Source Document Type" = field("Document Type");
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
                    Caption = 'Create Transport Order(s)';
                    Image = NewDocument;
                    ApplicationArea = All;
                    Visible = ShowUnpostedTO;
                    ToolTip = 'Creates transport orders for the selected sales orders.';

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(SalesHeader);
                        if SalesHeader.FindSet() then
                            repeat
                                IDYSDocumentManagement.SalesHeader_CreateTransportOrder(SalesHeader);
                            until SalesHeader.Next() = 0;

                        CurrPage.Update();
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

        ShowUnpostedTO := (IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents");
    end;

    var
        ShowUnpostedTO: Boolean;
}