tableextension 11147670 "IDYS Company Information" extends "Company Information"
{
    fields
    {
        #region [Sendcloud]
        field(11147639; "IDYS Address Id."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Address Id';
            TableRelation = "IDYS SC Sender Address".Id;
            ObsoleteState = Pending;
            ObsoleteReason = 'Sender Address removed';
            ObsoleteTag = '21.0';
        }
        #endregion
        field(11147640; "IDYS Account No."; Code[32])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
    }
}
