pageextension 11147822 "IDYST Package Type List" extends "MOB Package Type List"
{
    layout
    {
        addafter("Shipping Provider Id")
        {

            field("IDYST IDYS Provider"; Rec."IDYST IDYS Provider")
            {
                ToolTip = 'Specifies the value of the Provider field (ShipIT 365)';
                ApplicationArea = All;
                Editable = false;
            }
            field("IDYST Carrier Entry No."; Rec."IDYST Carrier Entry No.")
            {
                ToolTip = 'Specifies the value of the Carrier Entry No. field (ShipIT 365)';
                ApplicationArea = All;
                Editable = false;
            }
            field("IDYST Carrier Name"; Rec."IDYST Carrier Name")
            {
                ToolTip = 'Specifies the value of the Carrier Name field (ShipIT 365)';
                ApplicationArea = All;
                Editable = false;
            }
            field("IDYST Book Prof Entry No."; Rec."IDYST Book Prof Entry No.")
            {
                ToolTip = 'Specifies the value of the Book Prof Entry No. field (ShipIT 365)';
                ApplicationArea = All;
                Editable = false;
            }
            field("IDYST Book Prof Descr"; Rec."IDYST Book Prof Descr")
            {
                ToolTip = 'Specifies the value of the Book Prof Description field (ShipIT 365)';
                ApplicationArea = All;
                Editable = false;
            }
        }

        modify("Shipping Provider Id")
        {
            Editable = false;
        }
    }
}
