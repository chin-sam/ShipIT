page 11147668 "IDYS Source Doc. Filter Card"
{
    Caption = 'Source Document Filter Card';
    PageType = Card;
    SourceTable = "IDYS Transport Source Filter";
    UsageCategory = None;
    ContextSensitiveHelpPage = '22904863';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Importance = Promoted;
                    ToolTip = 'Specifies the source document filter code.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Importance = Promoted;
                    ToolTip = 'Describes the source document filter.';
                }

                field("Item No. Filter"; Rec."Item No. Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item no. filter.';
                }

                field("Variant Code Filter"; Rec."Variant Code Filter")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant code filter.';
                }

                field("Unit of Measure Filter"; Rec."Unit of Measure Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure filter.';
                }

                field("Shipping Agent Code Filter"; Rec."Shipping Agent Code Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent code filter.';
                }

                field("Shipping Agent Service Filter"; Rec."Shipping Agent Service Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service filter.';
                }

                field("Shipment Method Code Filter"; Rec."Shipment Method Code Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipment method filter.';
                }

                field("E-Mail Type Filter"; Rec."E-Mail Type Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the e-mail type filter.';
                }

                field("Cost Center Filter"; Rec."Cost Center Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost center filter.';
                }

                field("Location Code Filter"; Rec."Location Code Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code filter.';
                }

                group("Source Document")
                {
                    Caption = 'Source Document';
                    field("Sales Orders"; Rec."Sales Orders")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if sales orders are in the filter.';
                        Visible = UnpostedDocsVisible;
                    }
                    field("Sales Return Orders"; Rec."Sales Return Orders")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if sales return orders are included in the filter.';
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Removed due to wrongfully implemented flow';
                        ObsoleteTag = '21.0';
                    }

                    field("Purchase Return Orders"; Rec."Purchase Return Orders")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if purchase return orders are in the filter.';
                        Visible = UnpostedDocsVisible;
                    }

                    field("Service Orders"; Rec."Service Orders")
                    {
                        ApplicationArea = Service;
                        ToolTip = 'Specifies if service orders are in the filter.';
                        Visible = UnpostedDocsVisible;
                    }

                    field("Transfer Orders"; Rec."Transfer Orders")
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies if transfer orders are in the filter.';
                        Visible = UnpostedDocsVisible;
                    }

                    field("Posted Sales Shipments"; Rec."Posted Sales Shipments")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if posted sales shipments are in the filter.';
                        Visible = PostedDocsVisible;
                    }
                    field("Posted Return Receipts"; Rec."Posted Return Receipts")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if posted sales receipts are included in the filter.';
                        Visible = PostedDocsVisible;
                    }
                    field("Posted Purch. Return Shipments"; Rec."Posted Purch. Return Shipments")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if posted purchase return shipments are in the filter.';
                        Visible = PostedDocsVisible;
                    }

                    field("Posted Service Shipments"; Rec."Posted Service Shipments")
                    {
                        ApplicationArea = Service;
                        ToolTip = 'Specifies if posted service shipments are in the filter.';
                        Visible = PostedDocsVisible;
                    }
                    field("Posted Transfer Shipments"; Rec."Posted Transfer Shipments")
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies if posted transfer shipments are in the filter.';
                        Visible = PostedDocsVisible;
                    }
                }
            }

            group(Sales)
            {
                Caption = 'Sales';
                field("Sell-to Customer No. Filter"; Rec."Sell-to Customer No. Filter")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the sell-to customer no. filter';
                }
            }

            group(Purchase)
            {
                Caption = 'Purchase';
                field("Buy-from Vendor No. Filter"; Rec."Buy-from Vendor No. Filter")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the buy-from vendor no. filter';
                }
            }

            group(Service)
            {
                Caption = 'Service';
                field("Customer No. Filter"; Rec."Customer No. Filter")
                {
                    ApplicationArea = Service;
                    Importance = Promoted;
                    ToolTip = 'Specifies customer no. filter';
                }
            }

            group("Posted Documents")
            {
                Caption = 'Posted Documents';
                field("From Posting Date Calculation"; Rec."From Posting Date Calculation")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the from posting date date formula.';
                }

                field("To Posting Date Calculation"; Rec."To Posting Date Calculation")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the to posting date date formula.';
                }
            }
        }
    }

    trigger OnInit()
    var
        Setup: Record "IDYS Setup";
    begin
        if not Setup.Get() then
            exit;

        PostedDocsVisible := Setup."Base Transport Orders on" = Setup."Base Transport Orders on"::"Posted documents";
        UnpostedDocsVisible := Setup."Base Transport Orders on" = Setup."Base Transport Orders on"::"Unposted documents";
    end;

    var
        PostedDocsVisible: Boolean;
        UnpostedDocsVisible: Boolean;
}