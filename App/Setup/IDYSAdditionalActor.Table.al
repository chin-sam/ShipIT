table 11147679 "IDYS Additional Actor"
{
    Caption = 'Additional Actor';

    fields
    {
        field(1; "Actor Id"; Text[30])
        {
            Caption = 'Actor Id';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Actor Id")
        {
        }
    }

    trigger OnDelete()
    var
        IDYSProviderCarrier: Record "IDYS Provider Carrier";
    begin
        IDYSProviderCarrier.SetRange(Provider, IDYSProviderCarrier.Provider::"Delivery Hub");
        IDYSProviderCarrier.SetRange("Actor Id", "Actor Id");
        IDYSProviderCarrier.DeleteAll(true);
    end;
}

