codeunit 11147642 "IDYS Verify Setup"
{
    trigger OnRun();
    begin
        DeletePreviousResults();
        VerifyIDYSSetupTable();
        VerifyShippingAgentTable();
        VerifyShippingMethodsTable();
        VerifyCurrencyTable();
        VerifyLocalCurrencyTable();
        VerifyCountryRegionTable();
        VerifyLocalCountryRegionTable();

        OnVerifySetup(TempSetupVerificationResultBuffer);
        DisplayResults();
    end;

    var
        TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary;
        TableTxt: Label 'Table %1', Comment = '%1 = Table Caption.';
        RecordMustExistTxt: Label 'Record must exist';
        FieldValueTxt: Label 'Field "%1" must have a value', Comment = '%1 = Field Caption.';
        MustHaveAtLeastValueTxt: Label 'Field "%1" must have a value for at least one %2', Comment = '%1 = Field Caption, %2 = Table Caption.';
        HasValueTxt: Label '%1 "%2" has at least one %3 with a value in field "%4"', Comment = '%1 = Table Caption, %2 = Shipping Agent Code, %3 = Table Caption, %4 = Booking Profile Code (Ext.).';

    local procedure DeletePreviousResults();
    begin
        TempSetupVerificationResultBuffer.Reset();
        TempSetupVerificationResultBuffer.DeleteAll();
    end;

    local procedure VerifyIDYSSetupTable();
    var
        IDYSSetup: Record "IDYS Setup";
    begin
        InsertVerificationHeading(TempSetupVerificationResultBuffer, StrSubstNo(TableTxt, IDYSSetup.TableCaption()));

        if InsertVerificationLine(TempSetupVerificationResultBuffer, RecordMustExistTxt, IDYSSetup.Get()) then begin
            InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubstNo(FieldValueTxt, IDYSSetup.FieldCaption("Transport Order Nos.")), IDYSSetup."Transport Order Nos." <> '');
            InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubstNo(FieldValueTxt, IDYSSetup.FieldCaption("Pick-up Time From")), IDYSSetup."Pick-up Time From" <> 000000T);
            InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubstNo(FieldValueTxt, IDYSSetup.FieldCaption("Pick-up Time To")), IDYSSetup."Pick-up Time To" <> 000000T);
            InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubstNo(FieldValueTxt, IDYSSetup.FieldCaption("Delivery Time From")), IDYSSetup."Delivery Time From" <> 000000T);
            InsertVerificationLine(TempSetupVerificationResultBuffer, StrSubstNo(FieldValueTxt, IDYSSetup.FieldCaption("Delivery Time To")), IDYSSetup."Delivery Time To" <> 000000T);
        end;
    end;

    local procedure VerifyShippingAgentTable();
    var
        ShipAgentMapping: Record "IDYS Ship. Agent Mapping";
        ShipAgentSvcMapping: Record "IDYS Ship. Agent Svc. Mapping";
    begin
        InsertVerificationHeading(TempSetupVerificationResultBuffer, StrSubstNo(TableTxt, ShipAgentMapping.TableCaption()));

        ShipAgentMapping.SetFilter("Carrier Entry No.", '<>%1', 0);

        InsertVerificationLine(TempSetupVerificationResultBuffer,
          StrSubstNo(
            MustHaveAtLeastValueTxt,
            ShipAgentMapping.FieldCaption("Carrier Entry No."),
            LowerCase(ShipAgentMapping.TableCaption())),
          not ShipAgentMapping.IsEmpty());

        if ShipAgentMapping.FindSet() then
            repeat
                ShipAgentSvcMapping.SetRange("Shipping Agent Code", ShipAgentMapping."Shipping Agent Code");
                ShipAgentSvcMapping.SetFilter("Booking Profile Entry No.", '<>%1', 0);

                InsertVerificationLine(TempSetupVerificationResultBuffer,
                  StrSubstNo(
                    HasValueTxt,
                    ShipAgentMapping.TableCaption(),
                    ShipAgentMapping."Shipping Agent Code",
                    LowerCase(ShipAgentSvcMapping.TableCaption()),
                    ShipAgentSvcMapping.FieldCaption("Booking Profile Entry No.")),
                  not ShipAgentSvcMapping.IsEmpty());
            until ShipAgentMapping.Next() = 0;
    end;

    local procedure VerifyShippingMethodsTable();
    var
        ShipmentMethodMapping: Record "IDYS Shipment Method Mapping";
    begin
        InsertVerificationHeading(TempSetupVerificationResultBuffer, StrSubstNo(TableTxt, ShipmentMethodMapping.TableCaption()));

        ShipmentMethodMapping.SetCurrentKey("Incoterms Code");
        ShipmentMethodMapping.SetFilter("Incoterms Code", '<>%1', '');

        InsertVerificationLine(TempSetupVerificationResultBuffer,
          StrSubstNo(
            MustHaveAtLeastValueTxt,
            ShipmentMethodMapping.FieldCaption("Incoterms Code"),
            LowerCase(ShipmentMethodMapping.TableCaption())),
          not ShipmentMethodMapping.IsEmpty());
    end;

    local procedure VerifyCurrencyTable();
    var
        CurrencyMapping: Record "IDYS Currency Mapping";
    begin
        InsertVerificationHeading(TempSetupVerificationResultBuffer, StrSubstNo(TableTxt, CurrencyMapping.TableCaption()));

        CurrencyMapping.SetCurrentKey("Currency Code (External)");
        CurrencyMapping.SetFilter("Currency Code (External)", '<>%1', '');

        InsertVerificationLine(TempSetupVerificationResultBuffer,
          StrSubstNo(
            MustHaveAtLeastValueTxt,
            CurrencyMapping.FieldCaption("Currency Code (External)"),
            LowerCase(CurrencyMapping.TableCaption())),
          not CurrencyMapping.IsEmpty());
    end;

    local procedure VerifyLocalCurrencyTable();
    var
        CurrencyMapping: Record "IDYS Currency Mapping";
        LocalCountryMappingExistsMsg: Label 'A mapping record must exist for the local currency (for an empty %1)', Comment = '%1 = CurrencyMapping.Currency Code fieldcaption';
    begin
        InsertVerificationHeading(TempSetupVerificationResultBuffer, StrSubstNo(TableTxt, CurrencyMapping.TableCaption()));

        InsertVerificationLine(TempSetupVerificationResultBuffer,
          StrSubstNo(
            LocalCountryMappingExistsMsg,
            CurrencyMapping.FieldCaption("Currency Code")),
          CurrencyMapping.Get(''));
    end;

    local procedure VerifyCountryRegionTable();
    var
        CountryRegionMapping: Record "IDYS Country/Region Mapping";
    begin
        InsertVerificationHeading(TempSetupVerificationResultBuffer, StrSubstNo(TableTxt, CountryRegionMapping.TableCaption()));

        CountryRegionMapping.SetCurrentKey("Country/Region Code (External)");
        CountryRegionMapping.SetFilter("Country/Region Code (External)", '<>%1', '');

        InsertVerificationLine(TempSetupVerificationResultBuffer,
          StrSubstNo(
            MustHaveAtLeastValueTxt,
            CountryRegionMapping.FieldCaption("Country/Region Code (External)"),
            LowerCase(CountryRegionMapping.TableCaption())),
          not CountryRegionMapping.IsEmpty());
    end;

    local procedure VerifyLocalCountryRegionTable();
    var
        CountryRegionMapping: Record "IDYS Country/Region Mapping";
        LocalCountryMappingExistsMsg: Label 'A mapping record must exist for the local country (for an empty %1)', Comment = '%1 = CountryRegionMapping.Country/Region fieldcaption';
    begin
        InsertVerificationHeading(TempSetupVerificationResultBuffer, StrSubstNo(TableTxt, CountryRegionMapping.TableCaption()));

        InsertVerificationLine(TempSetupVerificationResultBuffer,
          StrSubstNo(
            LocalCountryMappingExistsMsg,
            CountryRegionMapping.FieldCaption("Country/Region Code")),
          CountryRegionMapping.Get(''));
    end;

    procedure DisplayResults();
    begin
        Page.RunModal(Page::"IDYS Setup Verification Result", TempSetupVerificationResultBuffer);
    end;

    procedure InsertVerificationHeading(var _TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary; Description: Text);
    begin
        InsertVerificationResult(_TempSetupVerificationResultBuffer, _TempSetupVerificationResultBuffer."Line Type"::Heading, Description, false);
    end;

    procedure InsertVerificationLine(var _TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary; Description: Text; OK: Boolean): Boolean;
    begin
        InsertVerificationResult(_TempSetupVerificationResultBuffer, _TempSetupVerificationResultBuffer."Line Type"::Line, Description, OK);
        exit(OK);
    end;

    procedure InsertVerificationResult(var _TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary; LineType: Integer; Description: Text; OK: Boolean);
    begin
        _TempSetupVerificationResultBuffer.Init();
        _TempSetupVerificationResultBuffer."Line No." := _TempSetupVerificationResultBuffer."Line No." + 1;
        _TempSetupVerificationResultBuffer."Line Type" := LineType;
        _TempSetupVerificationResultBuffer.Description := CopyStr(Description, 1, MaxStrLen(TempSetupVerificationResultBuffer.Description));
        _TempSetupVerificationResultBuffer.OK := OK;
        _TempSetupVerificationResultBuffer.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVerifySetup(var TempSetupVerificationResultBuffer: Record "IDYS Setup Verification Result" temporary)
    begin
    end;
}

