table 11147657 "IDYS Shipp. Agent Svc. Mapping"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Restructured with Provider level';
    Caption = 'Shipping Agent Service Mapping';
    DrillDownPageID = "IDYS Shipp. Agent Svc. Mapping";
    LookupPageID = "IDYS Shipp. Agent Svc. Mapping";

    fields
    {
        field(1; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            NotBlank = true;
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ShippingAgentMapping: Record "IDYS Shipping Agent Mapping";
            begin
                if not ShippingAgentMapping.Get("Shipping Agent Code") then
                    ShippingAgentMapping.Init();

                "Carrier Code (External)" := ShippingAgentMapping."Carrier Code (External)";
            end;
        }

        field(2; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            NotBlank = true;
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = CustomerContent;
        }

        field(3; "Carrier Code (External)"; Code[50])
        {
            Caption = 'Carrier Code (External)';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(4; "Booking Profile Code (Ext.)"; Code[50])
        {
            Caption = 'Booking Profile Code (Ext.)';
            TableRelation = "IDYS Booking Profile"."Code" where("Carrier Code (External)" = field("Carrier Code (External)"));
            DataClassification = CustomerContent;
        }

        field(5; "Shipping Agent Name"; Text[50])
        {
            CalcFormula = Lookup("Shipping Agent".Name where(Code = field("Shipping Agent Code")));
            Caption = 'Shipping Agent Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(6; "Shipping Agent Service Desc."; Text[100])
        {
            CalcFormula = Lookup("Shipping Agent Services".Description where("Shipping Agent Code" = field("Shipping Agent Code"),
                                                                              Code = field("Shipping Agent Service Code")));
            Caption = 'Shipping Agent Service Desc.';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Shipping Agent Code", "Shipping Agent Service Code")
        {
        }
    }
}