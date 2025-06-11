tableextension 11147668 "IDYS SC Shipping Agent" extends "Shipping Agent"
{
    fields
    {
        field(11147639; "IDYS SC Change Label Settings"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Change SendCloud Label Settings';
        }
        field(11147640; "IDYS SC Request Label"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Request SendCloud Label';
        }
        field(11147641; "IDYS SC Label Type"; Enum "IDYS SC Label Type")
        {
            DataClassification = CustomerContent;
            Caption = 'SendCloud Label Type';
        }
    }
}