tableextension 11147820 "IDYST MOB Setup" extends "MOB Setup"
{
    fields
    {
        field(11147820; "IDYST TranspOrder Booking"; Option)
        {
            Caption = 'Transport Order Booking Action';
            OptionCaption = 'Book & print,Book,None';
            OptionMembers = BookAndPrint,Book,None;
            DataClassification = CustomerContent;
        }
        field(11147821; "IDYST Continue After TO Fails"; Boolean)
        {
            Caption = 'Continue After Transport Order Fails';
            DataClassification = CustomerContent;
        }
    }
}
