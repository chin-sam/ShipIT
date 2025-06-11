page 11147661 "IDYS ShipIT Manager"
{
    PageType = RoleCenter;
    Caption = 'ShipIT Manager Role Center';

    layout
    {
        area(RoleCenter)
        {
            group(General)
            {
                ObsoleteReason = 'Group removed for better alignment of Role Centers parts';
                ObsoleteState = Pending;
                ObsoleteTag = '25.0';
                ShowCaption = false;
                Visible = false;
            }

            part(IDYSITRole; "IDYS ShipIT Setup Card Part")
            {
                ApplicationArea = All;
            }
            part("IDYS ShipIT Explained Act."; "IDYS ShipIT Explained Act.")
            {
                ApplicationArea = All;
            }
            part("IDYS ShipIT Cue"; "IDYS ShipIT Cue")
            {
                Caption = 'Document Output';
                ApplicationArea = All;
            }
            systempart(MyNotes; MyNotes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(Customers)
            {
                ApplicationArea = All;
                RunObject = page "Customer List";
                Caption = 'Customers';
                Image = Customer;
                ToolTip = 'Opens the customer list page.';
            }
            action(Vendors)
            {
                ApplicationArea = All;
                RunObject = page "Vendor List";
                Caption = 'Vendors';
                Image = Vendor;
                ToolTip = 'Opens the vendor list page.';
            }
            action(CountriesRegions)
            {
                ApplicationArea = All;
                RunObject = page "Countries/Regions";
                Caption = 'Countries/Regions';
                Image = CountryRegion;
                ToolTip = 'Opens the country/region list page.';
            }
            action(Currencies)
            {
                ApplicationArea = All;
                RunObject = page Currencies;
                Caption = 'Currencies';
                Image = Currencies;
                ToolTip = 'Opens the currency list page.';
            }

            action(ShippingAgents)
            {
                ApplicationArea = All;
                RunObject = page "Shipping Agents";
                Caption = 'Shipping Agents';
                Image = Shipment;
                ToolTip = 'Opens the shipping agent list page.';
            }

            action(ShippingAgentServices)
            {
                ApplicationArea = All;
                RunObject = page "Shipping Agent Services";
                Caption = 'Shipping Agent Services';
                Image = Shipment;
                ToolTip = 'Opens the shipping agent services list page.';
            }

            action(ShipmentMethods)
            {
                ApplicationArea = All;
                RunObject = page "Shipment Methods";
                Caption = 'Shipment Methods';
                Image = Shipment;
                ToolTip = 'Opens the shipment method list page.';
            }
        }

        area(Sections)
        {
            group("Source Documents")
            {
                Caption = 'Source Documents';

                action("Sales Quotes")
                {
                    RunObject = page "Sales Quotes";
                    ApplicationArea = All;
                    Caption = 'Sales Quotes';
                    Image = OrderList;
                    ToolTip = 'Opens the sales quote list.';
                }
                action("Sales Orders")
                {
                    RunObject = page "Sales Order List";
                    ApplicationArea = All;
                    Caption = 'Sales Orders';
                    Image = OrderList;
                    ToolTip = 'Opens the sales order list.';
                }
                action("Transfer Orders")
                {
                    RunObject = page "Transfer Orders";
                    ApplicationArea = Location;
                    Caption = 'Transfer Orders';
                    Image = TransferOrder;
                    ToolTip = 'Opens the transfer orders.';
                }
                action("Sales Return Orders")
                {
                    RunObject = page "Sales Return Order List";
                    ApplicationArea = All;
                    Image = ReturnOrder;
                    ToolTip = 'Opens the sales return order list.';
                }
                action("Purchase Return Orders")
                {
                    RunObject = page "Purchase Return Order List";
                    ApplicationArea = All;
                    Image = ReturnOrder;
                    ToolTip = 'Opens the purchase return order list.';
                }
                action("Service Orders")
                {
                    RunObject = page "Service Orders";
                    ApplicationArea = Service;
                    Image = ViewServiceOrder;
                    ToolTip = 'Opens the service orders.';
                }
                group(PostedDocuments)
                {
                    Caption = 'Posted Documents';
                    action("Posted Sales Shipments")
                    {
                        RunObject = page "Posted Sales Shipments";
                        ApplicationArea = All;
                        Caption = 'Posted Sales Shipments';
                        Image = PostedShipment;
                        ToolTip = 'Opens the posted sales shipments.';
                    }
                    action("Transfer Shipments")
                    {
                        RunObject = page "Posted Transfer Shipments";
                        ApplicationArea = Location;
                        Caption = 'Posted Transfer Shipments';
                        Image = PostedShipment;
                        ToolTip = 'Opens the posted transfer shipments.';
                    }
                    action("Posted Return Receipts")
                    {
                        RunObject = page "Posted Return Receipts";
                        ApplicationArea = All;
                        Image = ReturnReceipt;
                        ToolTip = 'Opens the posted return receipts.';
                    }
                    action("Posted Return Shipments")
                    {
                        RunObject = page "Posted Return Shipments";
                        ApplicationArea = All;
                        Image = ReturnShipment;
                        ToolTip = 'Opens the posted return shipments.';
                    }
                    action("Service Shipments")
                    {
                        RunObject = page "Posted Service Shipments";
                        ApplicationArea = Service;
                        Image = PostedServiceOrder;
                        ToolTip = 'Opens the posted service shipments.';
                    }
                }
            }

            group("Transport Orders")
            {
                Caption = 'Transport Orders';

                action("IDYS Transport Orders")
                {
                    RunObject = page "IDYS Transport Order List";
                    ApplicationArea = All;
                    Caption = 'Transport Orders';
                    Image = Setup;
                    ToolTip = 'Opens the transport order list page.';
                }

                action("IDYS Transport Worksheet")
                {
                    RunObject = page "IDYS Transport Worksheet";
                    ApplicationArea = All;
                    Caption = 'Transport Worksheet';
                    Image = Setup;
                    ToolTip = 'Opens the transport order worksheet page.';
                }
            }

            group("Archive")
            {
                Caption = 'Archive';

                action("IDYS Archived Transport Orders")
                {
                    RunObject = page "IDYS Arch Transport Order List";
                    ApplicationArea = All;
                    Caption = 'Archived Transport Orders';
                    Image = Setup;
                    ToolTip = 'Opens the archived transport orders list page.';
                }
            }

            group(ExternalMappings)
            {
                Caption = 'External Mappings';

                action("Shipping Agent Mappings")
                {
                    RunObject = page "IDYS Ship. Agent Mappings";
                    ApplicationArea = All;
                    Caption = 'Shipping Agent Mappings';
                    Image = CalculateShipment;
                    ToolTip = 'Opens the shipping agent mappings list page.';
                }
                action("Shipment Method Mappings")
                {
                    RunObject = page "IDYS Shipment Method Mappings";
                    ApplicationArea = All;
                    Caption = 'Shipment Method Mappings';
                    Image = CalculateShipment;
                    ToolTip = 'Opens the shipping method mappings list page.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved to Transsmart Setup';
                    ObsoleteTag = '18.8';
                    Visible = false;
                }
                action("Currency Mappings")
                {
                    RunObject = page "IDYS Currency Mappings";
                    ApplicationArea = All;
                    Caption = 'Currency Mappings';
                    Image = CalculateShipment;
                    ToolTip = 'Opens the currency mappings list page.';
                }
                action("Country/Region Mappings")
                {
                    RunObject = page "IDYS Country/Region Mappings";
                    ApplicationArea = All;
                    Caption = 'Country/Region Mappings';
                    Image = CalculateShipment;
                    ToolTip = 'Opens the country/region mappings list page.';
                }
                action("Language Mappings")
                {
                    RunObject = page "IDYS Language Mappings";
                    ApplicationArea = All;
                    Caption = 'Language Mappings';
                    Image = CalculateShipment;
                    ToolTip = 'Opens the language mappings list page.';
                }
            }

            group(ExternalMasterData)
            {
                Caption = 'External Master Data';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Restructured with Provider level';
                ObsoleteTag = '19.7';

                action("Carriers")
                {
                    RunObject = page "IDYS Provider Carriers";
                    ApplicationArea = All;
                    Caption = 'Carriers';
                    Image = Inventory;
                    ToolTip = 'Opens the carriers list page.';
                }

                action("Package Types")
                {
                    RunObject = page "IDYS Package Types";
                    ApplicationArea = All;
                    Caption = 'Package Types';
                    Image = Inventory;
                    ToolTip = 'Opens the package types list page.';
                }
                action("Incoterms")
                {
                    RunObject = page "IDYS Incoterms";
                    ApplicationArea = All;
                    Caption = 'Incoterms';
                    Image = Inventory;
                    ToolTip = 'Opens the incoterms list page.';
                }
                action("Cost Centers")
                {
                    RunObject = page "IDYS Cost Centers";
                    ApplicationArea = All;
                    Caption = 'Cost Centers';
                    Image = Inventory;
                    ToolTip = 'Opens the cost center list page.';
                }

                action("E-Mail Types")
                {
                    RunObject = page "IDYS E-Mail Types";
                    ApplicationArea = All;
                    Caption = 'E-Mail Types';
                    Image = Email;
                    ToolTip = 'Opens the e-mail types list page.';
                }
            }
            group(ShipITSetup)
            {
                Caption = 'Administration';

                action(Providers)
                {
                    RunObject = page "IDYS Providers";
                    ApplicationArea = All;
                    Caption = 'Providers';
                    Image = Email;
                    ToolTip = 'Opens the provider list page.';
                }
                action(AdminShipITSetupWizard)
                {
                    RunObject = page "IDYS ShipIT Setup Wizard";
                    ApplicationArea = All;
                    Caption = 'Setup Wizard';
                    Image = Setup;
                    ToolTip = 'Starts the ShipIT setup wizard.';
                }
                action("SetupCard")
                {
                    RunObject = page "IDYS Setup";
                    ApplicationArea = All;
                    Caption = 'Setup';
                    Image = Setup;
                    ToolTip = 'Opens the setup page.';
                }
                action("User Setup")
                {
                    RunObject = page "IDYS User Setup";
                    ApplicationArea = All;
                    Caption = 'User Setup';
                    Image = CalculateShipment;
                    ToolTip = 'Opens the user setup page.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Restructured with Provider level';
                    ObsoleteTag = '19.7';
                }
                action("Shipping Agent Calendars")
                {
                    RunObject = page "IDYS Shipping Agent Calendars";
                    ApplicationArea = All;
                    Caption = 'Shipping Agent Calendars';
                    Image = CalculateShipment;
                    ToolTip = 'Opens the shipping agent calendars page.';
                }
                action("Log")
                {
                    RunObject = page "IDYS Log Entry List";
                    ApplicationArea = All;
                    Caption = 'Log';
                    Image = Log;
                    ToolTip = 'Opens the transport order log list.';
                }
            }
        }

        area(Processing)
        {
            action(ActionProviders)
            {
                RunObject = page "IDYS Providers";
                ApplicationArea = All;
                Caption = 'Providers';
                Image = TransferOrder;
                ToolTip = 'Opens the list of providers that can be used for the communication with the carriers.';
            }
            action("ShipIT Setup Wizard")
            {
                RunObject = page "IDYS ShipIT Setup Wizard";
                ApplicationArea = All;
                Caption = 'ShipIT Setup Wizard';
                Image = Setup;
                ToolTip = 'Starts the ShipIT setup wizard.';
            }
            action("Setup")
            {
                RunObject = page "IDYS Setup";
                ApplicationArea = All;
                Caption = 'ShipIT Setup';
                Image = Setup;
                ToolTip = 'Opens the ShipIT setup page.';
            }
        }
    }
}