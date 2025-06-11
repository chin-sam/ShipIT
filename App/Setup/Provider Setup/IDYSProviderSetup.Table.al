table 11147665 "IDYS Provider Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Provider Setup';

    fields
    {
        field(1; Provider; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IDYSCreateMappings: Codeunit "IDYS Create Mappings";
                IDYSIProvider: Interface "IDYS IProvider";
                SyncMasterDataQst: Label 'Do you want to retrieve the master data?';
            begin
                if Enabled then
                    if Confirm(SyncMasterDataQst) then begin
                        IDYSCreateMappings.CreateMappings();
                        IDYSIProvider := Rec.Provider;
                        IDYSIProvider.GetMasterData(true);
                    end;
            end;
        }
        field(10; Hidden; Boolean)
        {
            Caption = 'Hidden';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Provider)
        {
            Clustered = true;
        }
        key(Key1; Enabled) { }
    }

    [Obsolete('Multi-selection enabled', '21.0')]
    procedure SetOneDefaultProvider()
    begin
    end;

    procedure IsEnabled(IDYSProvider: Enum "IDYS Provider"): Boolean
    begin
        if not Rec.Get(IDYSProvider) then
            exit(false);
        exit(Rec.Enabled);
    end;
}