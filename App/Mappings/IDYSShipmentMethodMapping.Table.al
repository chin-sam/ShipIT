table 11147650 "IDYS Shipment Method Mapping"
{
    Caption = 'Shipment Method Mapping';
    LookupPageId = "IDYS Shipment Method Mappings";

    fields
    {
        field(1; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            NotBlank = true;
            TableRelation = "Shipment Method";
            DataClassification = CustomerContent;
        }

        field(2; "Incoterms Code"; Code[50])
        {
            Caption = 'Incoterms Code';
            TableRelation = "IDYS Incoterm";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Shipment Method Code")
        {
        }

        key(Key2; "Incoterms Code")
        {
        }
    }
}