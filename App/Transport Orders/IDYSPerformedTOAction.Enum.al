enum 11147645 "IDYS Performed TO Action"
{
    Caption = 'Performed Transport Order Action';
    Extensible = true;

    value(0; Booked)
    {
        Caption = 'Booked';
    }
    value(1; Printed)
    {
        Caption = 'Printed';
    }
    value(2; "Booked & Printed")
    {
        Caption = 'Booked & Printed';
    }
    value(3; Synchronized)
    {
        Caption = 'Synchronized';
    }
    value(4; Archived)
    {
        Caption = 'Archived';
    }
    value(5; Recalled)
    {
        Caption = 'Recalled';
    }
}