tableextension 11147665 "IDYS Location" extends Location
{
    fields
    {
        field(11147740; "IDYS EORI Number"; Text[40])
        {
            Caption = 'EORI Number';
            DataClassification = CustomerContent;
        }
        #region [Sendcloud]
        field(11147741; "IDYS Address Id."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Address Id';
            TableRelation = "IDYS SC Sender Address".Id;
            ObsoleteState = Pending;
            ObsoleteReason = 'Sender Address removed';
            ObsoleteTag = '21.0';
        }
        #endregion
        field(11147742; "IDYS E-Mail Type"; Code[127])
        {
            Caption = 'E-Mail Type';
            TableRelation = "IDYS E-Mail Type";
            DataClassification = CustomerContent;
        }
        field(11147743; "IDYS Cost Center"; Code[127])
        {
            Caption = 'Cost Center';
            TableRelation = "IDYS Cost Center";
            DataClassification = CustomerContent;
        }
        field(11147744; "IDYS Account No."; Code[32])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
        field(11147745; "IDYS Actor Id"; Text[30])
        {
            Caption = 'Actor Id';
            DataClassification = CustomerContent;
            TableRelation = "IDYS Additional Actor";
        }
    }
}
