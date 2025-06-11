pageextension 11147658 "IDYS Sales Return Order" extends "Sales Return Order"
{
    layout
    {
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
                        SelectServiceLvlOther.SetParameters(Database::"Sales Header", "IDYS Source Document Type"::"5", Rec."No.", Rec.IDYSGetShipFromCountryCode(), Rec."Ship-to Country/Region Code", Rec.SystemId);
                        SelectServiceLvlOther.InitializePage(Rec."IDYS Carrier Entry No.", Rec."IDYS Booking Profile Entry No.");
                        SelectServiceLvlOther.RunModal();
                        SetOpenService();
                        CurrPage.Update();
                    end;
                }
            }
            #endregion
        }
        addafter("Bill-to Contact")
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
                    field("IDYS Account No. (Bill-to)"; Rec."IDYS Account No. (Bill-to)")
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
                }
            }
        }

        addafter("Order Date")
        {
            field("IDYS Promised Delivery Date"; Rec."Promised Delivery Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the promised delivery date.';
            }
        }

        addfirst("Shipment Method")
        {
            field("IDYS Shipment Method Code"; Rec."Shipment Method Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the shipment method code.';

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
        }

        addfirst(FactBoxes)
        {
            part("IDYS Tpt. Ord. Details Factbox"; "IDYS Tpt. Ord. Details Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Source Document Table No." = const(36), "Source Document No." = field("No."), "Source Document Type" = field("Document Type");
            }
        }

        addafter(SalesLines)
        {
            part("IDYS Sales Ret. Ord. Pck. Sub."; "IDYS Sales Ret. Ord. Pck. Sub.")
            {
                ApplicationArea = All;
                SubPageLink = "Table No." = const(36), "Document Type" = field("Document Type"), "Document No." = field("No.");
            }
        }

        addfirst(FactBoxes)
        {
            part("IDYS Source Doc. Pck. Factbox"; "IDYS Source Doc. Pck. Factbox")
            {
                Caption = 'Package Details';
                SubPageLink = "Table No." = const(36), "Document Type" = field("Document Type"), "Document No." = field("No.");
                SubPageView = sorting("Table No.", "Document No.", "Line No.");
                Editable = false;
                ApplicationArea = All;
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

                action("IDYS Carrier Select")
                {
                    Caption = 'Carrier Selection';
                    Image = RegisterPick;
                    ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
#endif
                    ToolTip = 'Shows a list of all possible carriers and service level combinations, including delivery times and costs.';

                    trigger OnAction();
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        IDYSDocumentMgt.SalesOrder_CarrierSelect(Rec);
                        CurrPage.Update(false);
                    end;
                }

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
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
#endif
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
#if not (BC17 or BC18 or BC19 or BC20)
        addlast(Category_Process)
        {
            actionref("IDYS Carrier Select_Promoted"; "IDYS Carrier Select")
            {
            }
            actionref("IDYS Create Transport Order_Promoted"; "IDYS Create Transport Order")
            {
            }
            actionref("IDYS Transport Orders_Promoted"; "IDYS Transport Orders")
            {
            }
        }
#endif
    }

    trigger OnOpenPage()
    begin
        IDYSInsuranceEnabled := IDYSProviderMgt.IsInsuranceEnabled(Enum::"IDYS Provider"::Transsmart);
    end;

    trigger OnAfterGetRecord()
    begin
        IDYSIsnShiftShip := IDYSProviderMgt.IsProviderEnabled(Rec."IDYS Provider", Enum::"IDYS Provider"::"Delivery Hub");
        IDYSIsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled(Enum::"IDYS Provider"::Transsmart, false);
        SetOpenService();

        CurrPage."IDYS Sales Ret. Ord. Pck. Sub.".Page.SetProvider(Rec."IDYS Provider");
        CurrPage."IDYS Source Doc. Pck. Factbox".Page.SetProviderForSourceDocPckFactbox(Rec."IDYS Provider");
        CurrPage."IDYS Source Doc. Pck. Factbox".Page.Refresh(Database::"Sales Header", Rec."Document Type".AsInteger(), Rec."No.");
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage."IDYS Source Doc. Pck. Factbox".Page.Update(false);
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
        IDYSOpenServicesLbl: Label 'Click here to select the service levels for this document.';
        IDYSChangeServicesLbl: Label '%1 service(s) selected. Click here to view or change the services.', Comment = '%1 = No. of services activated';
}