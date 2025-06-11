pageextension 11147820 "IDYST MOB Setup" extends "MOB Setup"

{
    layout
    {
        addafter(General)
        {
            group(IDYST)
            {
                Caption = 'Pack & Ship - ShipIT 365 Connector';

                field("IDYST TranspOrder Booking"; Rec."IDYST TranspOrder Booking")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if ShipIT 365 Transport Order should either ''Book and print'' only ''Book'' or ''None'' when Shipment is posted from the mobile device.';
                }
                field("IDYST Continue After TO Fails"; Rec."IDYST Continue After TO Fails")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enabling this field allows the system to work in continuous mode, which means having an error within the book or print action will not break the process.';
                }
            }
        }
    }
}

