enum 11147646 "IDYS Provider" implements "IDYS IProvider"
{
    Extensible = true;

    value(0; Default)
    {
        Caption = 'Default';
        Implementation = "IDYS IProvider" = "IDYS Default Provider";
    }
    value(1; Transsmart)
    {
        Caption = 'nShift Transsmart';
        Implementation = "IDYS IProvider" = "IDYS Transsmart Provider";
    }
    value(2; Sendcloud)
    {
        Caption = 'Sendcloud';
        Implementation = "IDYS IProvider" = "IDYS Sendcloud Provider";
    }
    value(3; "Delivery Hub")
    {
        Caption = 'nShift Ship';
        Implementation = "IDYS IProvider" = "IDYS DelHub Provider";
    }
    value(4; EasyPost)
    {
        Caption = 'EasyPost';
        Implementation = "IDYS IProvider" = "IDYS EasyPost Provider";
    }
    value(5; Cargoson)
    {
        Caption = 'Cargoson';
        Implementation = "IDYS IProvider" = "IDYS Cargoson Provider";
    }
}