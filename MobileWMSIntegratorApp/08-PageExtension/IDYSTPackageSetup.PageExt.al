pageextension 11147821 "IDYST Package Setup" extends "MOB Mobile WMS Package Setup"
{
    layout
    {
        addafter("Package Type")
        {

            field("IDYST Package Descr"; Rec."IDYST Package Descr")
            {
                ToolTip = 'Specifies the value of the Package Description field (ShipIT 365)';
                ApplicationArea = All;
                Editable = false;
            }
            field("IDYST IDYS Provider"; Rec."IDYST IDYS Provider")
            {
                ToolTip = 'Specifies the value of the Provider field (ShipIT 365)';
                ApplicationArea = All;
                Editable = false;
            }

            field("IDYST Carrier Name"; Rec."IDYST Carrier Name")
            {
                ToolTip = 'Specifies the value of the Carrier Name field (ShipIT 365)';
                ApplicationArea = All;
                Editable = false;
            }

            field("IDYST Book Prof Descr"; Rec."IDYST Book Prof Descr")
            {
                ToolTip = 'Specifies the value of the Booking Profile Description field (ShipIT 365)';
                ApplicationArea = All;
                Editable = false;
            }
        }

        modify("Package Type")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                PackageType: Record "MOB Package Type";
                IDYSShippingAgentMapping: Record "IDYS Ship. Agent Mapping";
            begin
                PackageType.SetCurrentKey("IDYST Carrier Entry No.", "IDYST Book Prof Entry No.");

                if IDYSShippingAgentMapping.Get(Rec."Shipping Agent") then begin
                    PackageType.FilterGroup(2);
                    PackageType.SetRange("IDYST IDYS Provider", IDYSShippingAgentMapping.Provider);
                    PackageType.FilterGroup(0);
                end;

                IF Page.RunModal(Page::"MOB Package Type List", PackageType) = Action::LookupOK THEN
                    Rec.Validate("Package Type", PackageType.Code);
            end;
        }
    }
}
