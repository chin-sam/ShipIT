pageextension 11147660 "IDYS Purchase Return Order" extends "Purchase Return Order"
{
    layout
    {
        modify("Location Code")
        {
            Importance = Promoted;

            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
        modify("Ship-to Country/Region Code")
        {
            Importance = Promoted;

            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
        addafter("Pay-to Contact")
        {
            group("IDYS ShipIT Fields")
            {
                Caption = 'ShipIT';

                field("IDYS Provider"; Rec."IDYS Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

                group(IDYSTranssmart)
                {
                    ShowCaption = false;
                    Visible = IDYSIsTranssmartEnabled;

                    field("IDYS E-Mail Type"; Rec."IDYS E-Mail Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the e-mail type.';
                    }
                    field("IDYS Cost Center"; Rec."IDYS Cost Center")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the cost center.';
                    }
                    field("IDYS Account No."; Rec."IDYS Account No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Account No. (Ship-to).';
                        Importance = Additional;
                    }
                    field("IDYS Account No. (Bill-to)"; Rec."IDYS Acc. No. (Bill-to)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Acccount No. (Bill-to).';
                        Importance = Additional;
                    }

                    group("IDYS Insurance")
                    {
                        ShowCaption = false;
                        Visible = IDYSInsuranceEnabled;

                        field("IDYS Do Not Insure"; Rec."IDYS Do Not Insure")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies if the source document should not be insured.';
                        }
                    }
                    field("IDYS Shipment Method Code"; Rec."Shipment Method Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies how items on the purchase document are shipped to the customer.';
                        Importance = Additional;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                }

                field("IDYS Shipping Agent Code"; Rec."IDYS Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Speciefies the shipping agent code.';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("IDYS Shipping Agent Srv Code"; Rec."IDYS Shipping Agent Srv Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service code.';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        IDYSIsnShiftShip := IDYSProviderMgt.IsProviderEnabled(Rec."IDYS Provider", Enum::"IDYS Provider"::"Delivery Hub");
                        SetOpenService();
                        CurrPage.Update();
                    end;
                }
                #region [nShift Ship]
                group(IDYSDeliveryHub)
                {
                    ShowCaption = false;
                    Visible = IDYSIsnShiftShip;

                    field(IDYSOpenServices; IDYSOpenService)
                    {
                        Editable = false;
                        ApplicationArea = All;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        var
                            SelectServiceLvlOther: Page "IDYS Select Service Lvl Other";
                        begin
                            SelectServiceLvlOther.SetParameters(Database::"Purchase Header", "IDYS Source Document Type"::"5", Rec."No.", Rec.IDYSGetShipFromCountryCode(), Rec."Ship-to Country/Region Code", Rec.SystemId);
                            SelectServiceLvlOther.InitializePage(Rec."IDYS Carrier Entry No.", Rec."IDYS Booking Profile Entry No.");
                            SelectServiceLvlOther.RunModal();
                            SetOpenService();
                            CurrPage.Update();
                        end;
                    }
                }
                #endregion
            }
        }

        addafter("Order Date")
        {
            field("IDYS Requested Receipt Date"; Rec."Requested Receipt Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the requested receipt date.';
            }
        }

        addfirst(FactBoxes)
        {
            part("IDYS Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Source Document Table No." = const(38), "Source Document No." = field("No."), "Source Document Type" = field("Document Type");
            }
        }
    }

    actions
    {
        addbefore("F&unctions")
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
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
#endif
                    ToolTip = 'Creates a transport order.';
                    Visible = ShowUnpostedTO;

                    trigger OnAction()
                    var
                        IDYSDocumentManagement: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentManagement.PurchaseReturnHeader_CreateTransportOrder(Rec);
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
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
#endif
                    ToolTip = 'View a list of the available Transport Orders for this document.';

                    trigger OnAction()
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentMgt.FindAndOpenTransportOrdersFromSource(Database::"Purchase Header", Rec."Document Type".AsInteger(), Rec."No.");
                    end;
                }
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        addlast(Category_Process)
        {
            actionref("IDYS Create Transport Order_Promoted"; "IDYS Create Transport Order")
            {
            }
            actionref("IDYS Transport Orders_Promoted"; "IDYS Transport Orders")
            {
            }
        }
#endif
    }
    trigger OnAfterGetRecord()
    begin
        IDYSIsnShiftShip := IDYSProviderMgt.IsProviderEnabled(Rec."IDYS Provider", Enum::"IDYS Provider"::"Delivery Hub");
        IDYSIsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled(Rec."IDYS Provider"::Transsmart, false);

        SetOpenService();
    end;

    trigger OnOpenPage()
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        ShowUnpostedTO := IDYSSetup.Get() and (IDYSSetup."Base Transport Orders on" = IDYSSetup."Base Transport Orders on"::"Unposted documents");
        IDYSInsuranceEnabled := IDYSProviderMgt.IsInsuranceEnabled(Enum::"IDYS Provider"::Transsmart);
    end;


    local procedure SetOpenService()
    begin
        Rec.CalcFields("IDYS No. of Selected Services");
        if Rec."IDYS No. of Selected Services" > 0 then
            IDYSOpenService := StrSubstNo(IDYSChangeServicesLbl, Rec."IDYS No. of Selected Services")
        else
            IDYSOpenService := IDYSOpenServicesLbl;
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSInsuranceEnabled: Boolean;
        IDYSOpenService: Text;
        IDYSIsnShiftShip: Boolean;
        IDYSIsTranssmartEnabled: Boolean;
        ShowUnpostedTO: Boolean;
        IDYSOpenServicesLbl: Label 'Click here to select the service levels for this document.';
        IDYSChangeServicesLbl: Label '%1 service(s) selected. Click here to view or change the services.', Comment = '%1 = No. of services activated';
}