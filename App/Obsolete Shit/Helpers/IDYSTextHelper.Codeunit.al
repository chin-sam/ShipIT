codeunit 11147659 "IDYS Text Helper"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by App Management app';
    //ObsoleteTag = '19.7';

    procedure TextToDate(InputText: Text) ReturnDate: Date
    var
        InputVariant: Variant;
    begin
        InputVariant := ReturnDate; //Variant must be of type date
        if TryTextToDate(InputText, InputVariant) then
            exit(Variant2Date(InputVariant));
    end;

    procedure TextToTime(TimeStr: Text): Time
    var
        DummyDateTime: DateTime;
        InputVariant: Variant;
    begin
        Clear(DummyDateTime);
        InputVariant := DummyDateTime; //Variant must be of type datetime
        if TryTextToTime(TimeStr, InputVariant) then
            exit(Variant2Time(InputVariant));
    end;

    [TryFunction]
    local procedure TryTextToDate(InputText: Text; var InputVariant: Variant)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        TypeHelper.Evaluate(InputVariant, InputText, '', '');
    end;

    [TryFunction]
    local procedure TryTextToTime(TimeStr: Text; var InputVariant: Variant)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        TypeHelper.Evaluate(InputVariant, TimeStr, '', '');
    end;
}