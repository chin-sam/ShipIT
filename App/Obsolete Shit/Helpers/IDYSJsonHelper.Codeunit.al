codeunit 11147681 "IDYS Json Helper"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by App Management app';
    //ObsoleteTag = '19.7';

    procedure AddValue(var Object: JsonObject; KeyName: Text; Value: Text)
    var
        ValueToAdd: JsonValue;
    begin
        ValueToAdd.SetValue(value);
        Object.Add(KeyName, ValueToAdd);
    end;

    procedure AddValue(var Object: JsonObject; KeyName: Text; Value: Integer)
    var
        ValueToAdd: JsonValue;
    begin
        ValueToAdd.SetValue(value);
        Object.Add(KeyName, ValueToAdd);
    end;

    procedure AddValue(var Object: JsonObject; KeyName: Text; Value: Boolean)
    var
        ValueToAdd: JsonValue;
    begin
        ValueToAdd.SetValue(value);
        Object.Add(KeyName, ValueToAdd);
    end;

    procedure AddValue(var Object: JsonObject; KeyName: Text; Value: Decimal)
    var
        ValueToAdd: JsonValue;
    begin
        ValueToAdd.SetValue(value);
        Object.Add(KeyName, ValueToAdd);
    end;

    procedure AddValue(var Object: JsonObject; KeyName: Text; Value: DateTime)
    var
        ValueToAdd: JsonValue;
    begin
        ValueToAdd.SetValue(value);
        Object.Add(KeyName, ValueToAdd);
    end;

    procedure AddValue(var Object: JsonObject; KeyName: Text; Value: Date)
    var
        ValueToAdd: JsonValue;
    begin
        ValueToAdd.SetValue(value);
        Object.Add(KeyName, ValueToAdd);
    end;

    procedure Add(var Object: JsonObject; KeyName: Text; ObjectToAdd: JsonObject)
    begin
        Object.Add(KeyName, ObjectToAdd);
    end;

    procedure Add(var Object: JsonObject; KeyName: Text; ArrayToAdd: JsonArray)
    begin
        Object.Add(KeyName, ArrayToAdd);
    end;

    procedure Add(var Objects: JsonArray; ObjectToAdd: JsonObject)
    begin
        Objects.Add(ObjectToAdd);
    end;

    procedure GetCodeValue(Object: JsonObject; KeyName: Text): Code[250]
    begin
        exit(GetCodeValue(Object, KeyName, ''));
    end;

    procedure GetCodeValue(Token: JsonToken; KeyName: Text): Code[250]
    begin
        exit(GetCodeValue(Token.AsObject(), KeyName, ''));
    end;

    procedure GetCodeValue(Object: JsonObject; KeyName: Text; DefaultValue: Code[250]): Code[250]
    var
        JsonVal: JsonValue;
    begin
        if GetValue(Object, KeyName, JsonVal) then
            exit(CopyStr(JsonVal.AsCode(), 1, 250))
        else
            exit(DefaultValue);
    end;

    procedure GetTextValue(Object: JsonObject; KeyName: Text): Text
    begin
        exit(GetTextValue(Object, KeyName, ''));
    end;

    procedure GetTextValue(Token: JsonToken; KeyName: Text): Text
    begin
        exit(GetTextValue(Token.AsObject(), KeyName, ''));
    end;

    procedure GetTextValue(Object: JsonObject; KeyName: Text; DefaultValue: Text): Text
    var
        JsonVal: JsonValue;
    begin
        if GetValue(Object, KeyName, JsonVal) then
            exit(JsonVal.AsText())
        else
            exit(DefaultValue);
    end;

    procedure GetIntegerValue(Token: JsonToken; KeyName: Text): Integer
    begin
        exit(GetIntegerValue(Token.AsObject(), KeyName, 0));
    end;


    procedure GetIntegerValue(Object: JsonObject; KeyName: Text): Integer
    begin
        exit(GetIntegerValue(Object, KeyName, 0));
    end;

    procedure GetIntegerValue(Object: JsonObject; KeyName: Text; DefaultValue: Integer) ReturnInt: Integer
    var
        JsonVal: JsonValue;
        IntAsVariant: Variant;
    begin
        if GetValue(Object, KeyName, JsonVal) then begin
            IntAsVariant := ReturnInt;
            if not TypeHelper.Evaluate(IntAsVariant, JsonVal.AsText(), '', '') then
                Error(CouldNotCastErr, JsonVal.AsText(), 'integer');
            if IntAsVariant.IsInteger then
                ReturnInt := IntAsVariant;
        end else
            exit(DefaultValue);
    end;

    procedure GetDecimalValue(Object: JsonObject; KeyName: Text): Decimal
    begin
        exit(GetDecimalValue(Object, KeyName, 0));
    end;

    procedure GetDecimalValue(Token: JsonToken; KeyName: Text): Decimal
    begin
        exit(GetDecimalValue(Token.AsObject(), KeyName, 0));
    end;

    procedure GetDecimalValue(Object: JsonObject; KeyName: Text; DefaultValue: Decimal) ReturnDecimal: Decimal
    var
        JsonVal: JsonValue;
        DecimalAsVariant: Variant;
    begin
        if GetValue(Object, KeyName, JsonVal) then begin
            DecimalAsVariant := ReturnDecimal;
            if not TypeHelper.Evaluate(DecimalAsVariant, JsonVal.AsText(), '', '') then
                Error(CouldNotCastErr, JsonVal.AsText(), 'decimal');
            if DecimalAsVariant.IsDecimal then
                ReturnDecimal := DecimalAsVariant;
        end else
            exit(DefaultValue);
    end;

    procedure GetBooleanValue(Object: JsonObject; KeyName: Text): Boolean
    begin
        exit(GetBooleanValue(Object, KeyName, false));
    end;

    procedure GetBooleanValue(Token: JsonToken; KeyName: Text): Boolean
    begin
        exit(GetBooleanValue(Token.AsObject(), KeyName, false));
    end;

    procedure GetBooleanValue(Object: JsonObject; KeyName: Text; DefaultValue: Boolean): Boolean
    var
        JsonVal: JsonValue;
        Val: Boolean;
    begin
        if GetValue(Object, KeyName, JsonVal) then begin
            if not Evaluate(Val, JsonVal.AsText()) then
                Error(CouldNotCastErr, JsonVal.AsText(), 'boolean');

            exit(JsonVal.AsBoolean())
        end else
            exit(DefaultValue);
    end;


    procedure Get(Object: JsonObject; KeyName: Text): JsonToken
    var
        Token: JsonToken;
    begin
        Object.get(KeyName, Token);
        exit(Token);
    end;

    procedure GetDateValue(Object: JsonObject; KeyName: Text): Date
    begin
        exit(GetDateValue(Object, KeyName, 0D));
    end;

    procedure GetDateValue(Object: JsonObject; KeyName: Text; DefaultValue: Date): Date
    var
        JsonVal: JsonValue;
    begin

        if GetValue(Object, KeyName, JsonVal) then
            exit(JsonVal.AsDate())
        else
            exit(DefaultValue);
    end;

    procedure GetTitleCasedTextValue(Object: JsonObject; KeyName: Text): Text
    begin
        exit(GetTitleCasedTextValue(Object, KeyName, ''));
    end;

    procedure GetTitleCasedTextValue(Object: JsonObject; KeyName: Text; DefaultValue: Text): Text
    var
        TextVal: Text;
    begin
        TextVal := GetTextValue(Object, KeyName, DefaultValue);
        exit(UpperCase(CopyStr(TextVal, 1, 1)) + CopyStr(TextVal, 2, StrLen(TextVal)));
    end;

    procedure GetObject(Token: JsonToken; KeyName: Text): JsonObject
    var
        ValueToken: JsonToken;
    begin
        Token.AsObject().Get(KeyName, ValueToken);
        exit(ValueToken.AsObject());
    end;

    procedure GetArray(Token: JsonToken; KeyName: Text): JsonArray
    var
        ValueToken: JsonToken;
    begin
        Token.AsObject().Get(KeyName, ValueToken);
        exit(ValueToken.AsArray());
    end;

    procedure GetArray(Object: JsonObject; KeyName: Text): JsonArray
    var
        Token: JsonToken;
    begin
        Object.get(KeyName, Token);
        exit(Token.AsArray());
    end;

    procedure GetTextValue(JArray: JsonArray; KeyName: Text): Text
    var
        Token: JsonToken;
        Object: JsonObject;
        JsonVal: JsonValue;
    begin
        foreach Token in JArray do begin
            Object := Token.AsObject();
            if GetValue(Object, 'name', JsonVal) then
                if JsonVal.AsText() = KeyName then
                    exit(GetTextValue(Object, 'value'));
        end;
    end;

    local procedure GetValue(Object: JsonObject; KeyName: Text; var JsonVal: JsonValue): Boolean
    var
        Token: JsonToken;
    begin
        if not Object.Contains(KeyName) then
            exit(false);

        Object.Get(KeyName, Token);
        if not Token.IsValue() then
            exit(false);

        JsonVal := Token.AsValue();
        if JsonVal.IsNull() or JsonVal.IsUndefined() then
            exit(false);

        exit(true);
    end;

    procedure FormatTime(input: DateTime): Text;
    begin
        exit(Format(input, 0, '<Hours24,2>:<Minutes,2>'));
    end;

    var
        TypeHelper: Codeunit "Type Helper";
        CouldNotCastErr: Label 'Could not cast value %1 to %2.', Comment = '%1 = Value to cast, %2 = Type to cast value to.';
}