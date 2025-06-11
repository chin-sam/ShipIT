pageextension 11147647 "IDYS Transfer Order" extends "Transfer Order"
{
    layout
    {
        modify("Shipment Method Code")
        {
            Importance = Promoted;

            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
        modify("Shipping Agent Code")
        {
            Importance = Promoted;

            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
        modify("Shipping Agent Service Code")
        {
            Importance = Promoted;

            trigger OnAfterValidate()
            begin
                IDYSIsnShiftShip := IDYSProviderMgt.IsProviderEnabled(Rec."IDYS Provider", Enum::"IDYS Provider"::"Delivery Hub");
                SetOpenService();
                CurrPage.Update();
            end;
        }
        modify("Trsf.-from Country/Region Code")
        {
            Importance = Promoted;

            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
        modify("Trsf.-to Country/Region Code")
        {
            Importance = Promoted;

            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
        addafter("Shipping Agent Service Code")
        {
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
                        SelectServiceLvlOther.SetParameters(Database::"Transfer Header", "IDYS Source Document Type"::"0", Rec."No.", Rec."Trsf.-from Country/Region Code", Rec."Trsf.-to Country/Region Code", Rec.SystemId);
                        SelectServiceLvlOther.InitializePage(Rec."IDYS Carrier Entry No.", Rec."IDYS Booking Profile Entry No.");
                        SelectServiceLvlOther.RunModal();
                        SetOpenService();
                        CurrPage.Update();
                    end;
                }
            }
            #endregion
        }
        addafter("Shipment Date")
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
                group(IDYSIsTranssmart)
                {
                    ShowCaption = false;
                    Visible = IDYSIsTranssmartEnabled;

                    field("IDYS E-Mail Type"; Rec."IDYS E-Mail Type")
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies the e-mail type.';
                    }

                    field("IDYS Cost Center"; Rec."IDYS Cost Center")
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies the cost center.';
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
                }
            }
        }

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
                    ApplicationArea = Location;
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
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
#endif
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
        IDYSIsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled(Enum::"IDYS Provider"::Transsmart, false);

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
        IDYSOpenService: Text;
        IDYSIsnShiftShip: Boolean;
        IDYSIsTranssmartEnabled: Boolean;
        IDYSInsuranceEnabled: Boolean;
        ShowUnpostedTO: Boolean;
        IDYSOpenServicesLbl: Label 'Click here to select the service levels for this transport order.';
        IDYSChangeServicesLbl: Label '%1 service(s) selected. Click here to view or change the services.', Comment = '%1 = No. of services activated';
}