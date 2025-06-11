page 11147666 "IDYS Transport Worksheet"
{
    Caption = 'Transport Worksheet';
    UsageCategory = Lists;
    ApplicationArea = All;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "IDYS Transport Worksheet Line";
    ContextSensitiveHelpPage = '22872090';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Include; Rec.Include)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the record is included.';
                }

                field("Source Document Type"; Rec."Source Document Type")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the source document type.';
                }

                field("Source Table Caption"; Rec."Source Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source table caption.';
                }

                field("Source Document No."; Rec."Source Document No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document no..';
                }

                field("Source Document Line No."; Rec."Source Document Line No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document line no..';
                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item no..';
                }

                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant code..';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }

                field("Description 2"; Rec."Description 2")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description 2.';
                }

                field(Quantity; Rec.Quantity)
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Unit of Measure Code';
                }

                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the base quantity.';
                }

                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent code.';
                }

                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service code.';
                }

                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipment method code.';
                    Visible = IDYSIsTranssmartEnabled;
                }

                field("Preferred Shipment Date"; Rec."Preferred Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the preferred shipment date.';
                }

                field("Preferred Delivery Date"; Rec."Preferred Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the preferred delivery date.';
                }

                field("E-Mail Type"; Rec."E-Mail Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the e-mail type.';
                    Visible = IDYSIsTranssmartEnabled;
                }

                field("Cost Center"; Rec."Cost Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost center.';
                    Visible = IDYSIsTranssmartEnabled;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Specifies the Account No. (Ship-to).';
                    Visible = IDYSIsTranssmartEnabled;
                }
                field("Account No. (Pick-up)"; Rec."Account No. (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Account No. (Pick-up).';
                    Visible = IDYSIsTranssmartEnabled;
                }
                field("Account No. (Invoice)"; Rec."Account No. (Invoice)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Account No. (Invoice).';
                    Visible = IDYSIsTranssmartEnabled;
                }
                field("Do Not Insure"; Rec."Do Not Insure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the transport order should not insured.';
                    Visible = IDYSIsTranssmartEnabled and IDYSInsuranceEnabled;
                }

                field("Combinability ID"; Rec."Combinability ID")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the combinability id.';
                }

                field("Invoice (Ref)"; Rec."Invoice (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the invoice (ref).';
                }

                field("Customer Order (Ref)"; Rec."Customer Order (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer order (ref).';
                }

                field("Order No. (Ref)"; Rec."Order No. (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order no. (ref).';
                }

                field("Delivery Note (Ref)"; Rec."Delivery Note (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delivery note (ref).';
                }

                field("Delivery Id (Ref)"; Rec."Delivery Id (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delivery id (ref).';
                }

                field("Other (Ref)"; Rec."Other (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the other (ref).';
                }

                field("Service Point (Ref)"; Rec."Service Point (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service point (ref).';
                }

                field("Project (Ref)"; Rec."Project (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the project (ref).';
                }

                field("Your Reference (Ref)"; Rec."Your Reference (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the your reference (ref).';
                }

                field("Engineer (Ref)"; Rec."Engineer (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the engineer (ref).';
                }

                field("Customer (Ref)"; Rec."Customer (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer (ref).';
                }

                field("Agent (Ref)"; Rec."Agent (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the agent (ref).';
                }

                field("Driver ID (Ref)"; Rec."Driver ID (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the drive id (ref).';
                }

                field("Route ID (Ref)"; Rec."Route ID (Ref)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the route id (ref).';
                }
            }
        }

        area(factboxes)
        {
            part("IDYS Tpt. Wksht. Pick-up Part"; "IDYS Tpt. Wksht. Pick-up Part")
            {
                SubPageLink = "Source Document Type" = field("Source Document Type"),
                              "Source Document No." = field("Source Document No."),
                              "Source Document Line No." = field("Source Document Line No.");
                SubPageView = sorting("Source Document Type", "Source Document No.", "Source Document Line No.");
                ApplicationArea = All;
            }

            part("IDYS Tpt. Wksht. Ship-to Part"; "IDYS Tpt. Wksht. Ship-to Part")
            {
                SubPageLink = "Source Document Type" = field("Source Document Type"),
                              "Source Document No." = field("Source Document No."),
                              "Source Document Line No." = field("Source Document Line No.");
                SubPageView = sorting("Source Document Type", "Source Document No.", "Source Document Line No.");
                ApplicationArea = All;
            }

            part("IDYS Tpt. Wksht. Invoice Part"; "IDYS Tpt. Wksht. Invoice Part")
            {
                SubPageLink = "Source Document Type" = field("Source Document Type"),
                              "Source Document No." = field("Source Document No."),
                              "Source Document Line No." = field("Source Document Line No.");
                SubPageView = sorting("Source Document Type", "Source Document No.", "Source Document Line No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Prepare)
            {
                Caption = 'Prepare';
                action("Filter Templates")
                {
                    Caption = 'Filter Templates';
                    Ellipsis = true;
                    Image = UseFilters;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    ApplicationArea = All;
                    RunObject = Page "IDYS Filters to Get Src. Docs.";
                    ToolTip = 'Opens the filter page.';
                }

                action("Source Document Line")
                {
                    Caption = 'Source Document Line';
                    Image = SourceDocLine;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    ApplicationArea = All;
                    ToolTip = 'Source document line.';

                    trigger OnAction();
                    var
                        IDYSDocumentMgt: Codeunit "IDYS Document Mgt.";
                    begin
                        IDYSDocumentMgt.ShowSourceDocument(Rec);
                    end;
                }

                action("Create Transport Orders")
                {
                    Caption = 'Create Transport Orders';
                    Image = NewShipment;
#if BC17 or BC18 or BC19 or BC20
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
#endif
                    ApplicationArea = All;
                    ToolTip = 'Creates transport orders.';

                    trigger OnAction();
                    var
                        TransportWorksheetLine: Record "IDYS Transport Worksheet Line";
                    begin
                        TransportWorksheetLine.Copy(Rec);
                        TransportWorksheetLine.SetRange("Do Not Insure", false);
                        if not TransportWorksheetLine.IsEmpty() then
                            Codeunit.Run(Codeunit::"IDYS Create Tpt. Ord. (Wrksh.)", TransportWorksheetLine);

                        TransportWorksheetLine.SetRange("Do Not Insure", true);
                        if not TransportWorksheetLine.IsEmpty() then
                            Codeunit.Run(Codeunit::"IDYS Create Tpt. Ord. (Wrksh.)", TransportWorksheetLine);
                    end;
                }
            }
            #region [nShift Ship]
            action("Select Service(s)")
            {
                Visible = IDYSIsnShiftShip;
                Caption = 'Select Service(s).';
                Ellipsis = true;
                Image = UseFilters;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ApplicationArea = All;
                ToolTip = 'Allows to select service(s).';

                trigger OnAction()
                var
                    SelectServiceLvlOther: Page "IDYS Select Service Lvl Other";
                begin
                    SelectServiceLvlOther.SetParameters(Database::"IDYS Transport Worksheet Line", Rec."Source Document Type", Rec."Source Document No.", Rec."Country/Region Code (Pick-up)", Rec."Country/Region Code (Ship-to)", Rec.SystemId);
                    SelectServiceLvlOther.InitializePage(Rec."Carrier Entry No.", Rec."Booking Profile Entry No.");
                    SelectServiceLvlOther.RunModal();
                    CurrPage.Update();
                end;
            }
            #endregion
        }
#if not (BC17 or BC18 or BC19 or BC20)        
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Filter Templates_Promoted"; "Filter Templates")
                {
                }
                actionref("Source Document Line_Promoted"; "Source Document Line")
                {
                }
                actionref("Create Transport Orders_Promoted"; "Create Transport Orders")
                {
                }
            }
            actionref("Select Service(s)_Promoted"; "Select Service(s)")
            {
            }
        }
#endif
    }

    trigger OnOpenPage()
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        IDYSIsTranssmartEnabled := IDYSProviderMgt.IsProviderEnabled(Enum::"IDYS Provider"::Transsmart, false);
        IDYSInsuranceEnabled := IDYSProviderMgt.IsInsuranceEnabled(Enum::"IDYS Provider"::Transsmart);
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(Provider);
        IDYSIsnShiftShip := Rec.Provider = Rec.Provider::"Delivery Hub";
    end;

    var
        IDYSIsTranssmartEnabled: Boolean;
        IDYSInsuranceEnabled: Boolean;
        IDYSIsnShiftShip: Boolean;
}