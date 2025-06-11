pageextension 11147639 "IDYS Order Proc. Role Center" extends "Order Processor Role Center"
{
    layout
    {
        addafter(Control1901851508)
        {
            part("IDYS ShipIT Cue"; "IDYS ShipIT Cue")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addfirst(Sections)
        {
            group("IDYS ShipIT Order Processing")
            {
                Caption = 'ShipIT';

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

            group("IDYS ShipIT Archive")
            {
                Caption = 'ShipIT Archive';

                action("IDYS Archived Transport Orders")
                {
                    RunObject = page "IDYS Arch Transport Order List";
                    ApplicationArea = All;
                    Caption = 'Archived Transport Orders';
                    Image = Setup;
                    ToolTip = 'Opens the archived transport orders list page.';
                }
            }
        }

        addlast(Creation)
        {
            action("IDYS Transport Order")
            {
                RunObject = page "IDYS Transport Order Card";
                RunPageMode = Create;
                ApplicationArea = All;
                Caption = 'Transport Order';
                ToolTip = 'Create a new Transport Order.';
                Image = NewShipment;
            }
        }
    }
}