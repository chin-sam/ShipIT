page 11147684 "IDYS Decimal Dialog"
{
    Extensible = false;
    PageType = StandardDialog;
    Caption = 'Enter value';

    layout
    {
        area(content)
        {
            field(DecimalValue; DecimalValue)
            {
                ApplicationArea = All;
                CaptionClass = DecimalCaption;
                ToolTip = 'Specifies the decimal value.';
            }
        }
    }

    procedure SetValues(_DecimalCaption: Text[100]; _DecimalValue: Decimal)
    begin
        DecimalValue := _DecimalValue;
        DecimalCaption := _DecimalCaption;
    end;


    procedure GetValues(var _DecimalValue: Decimal)
    begin
        _DecimalValue := DecimalValue;
    end;

    var
        DecimalValue: Decimal;
        DecimalCaption: Text;

}