enum 11147651 "IDYS Cargoson Service Type"
{
    // NOTE:
    // https://app.swaggerhub.com/apis-docs/cargoson/cargoson-api/v1#/ServicesResponseBody

    Extensible = true;

    value(0; none)
    {
        Caption = 'None';
    }
    value(1; road)
    {
        Caption = 'Road';
    }
    value(2; air)
    {
        Caption = 'Air';
    }
    value(3; sea)
    {
        Caption = 'Sea';
    }
    value(4; rail)
    {
        Caption = 'Rail';
    }
    value(5; courier)
    {
        Caption = 'Courier';
    }
    value(6; parcel_machine)
    {
        Caption = 'Parcel machine';
    }
}