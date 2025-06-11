codeunit 11147687 "IDYS Create Mappings"
{
    procedure CreateMappings()
    begin
        GeneralLedgerSetup.Get();
        LoadSetup();

        MapCurrencies();
        MapCountries();
        MapLanguages();
    end;

    procedure MapCurrencies()
    var
        CurrencyMapping: Record "IDYS Currency Mapping";
        Currency: Record Currency;
        IsHandled: Boolean;
    begin
        OnBeforeMapCurrencies(IsHandled);
        if IsHandled then
            exit;

        CurrencyMapping.DeleteAll();
        GeneralLedgerSetup.Get();
        if Currency.FindSet() then
            repeat
                CurrencyMapping.Init();
                CurrencyMapping."Currency Code" := Currency."Code";
                CurrencyMapping."Currency Code (External)" := Currency."ISO Code";
                CurrencyMapping."Currency Value" := GetCurrencyValue(Currency."ISO Code");
                CurrencyMapping.Insert();
                if Currency.Code = GeneralLedgerSetup."LCY Code" then
                    if not CurrencyMapping.Get('') then begin
                        CurrencyMapping.Init();
                        CurrencyMapping."Currency Code" := '';
                        CurrencyMapping."Currency Code (External)" := Currency."ISO Code";
                        CurrencyMapping."Currency Value" := GetCurrencyValue(Currency."ISO Code");
                        CurrencyMapping.Insert();
                    end;
            until Currency.Next() = 0;
        if not CurrencyMapping.Get('') then begin //LCY Code doesn't have to exist as a currency record
            CurrencyMapping.Init();
            CurrencyMapping."Currency Code" := '';
            CurrencyMapping."Currency Code (External)" := GeneralLedgerSetup."LCY Code";
            CurrencyMapping."Currency Value" := GetCurrencyValue(GeneralLedgerSetup."LCY Code");
            CurrencyMapping.Insert();
        end;

        OnAfterMapCurrencies();
    end;

    procedure MapUnitOfMeasure()
    var
        UnitOfMeasureMapping: Record "IDYS Unit of Measure Mapping";
        UnitOfMeasure: Record "Unit of Measure";
        IsHandled: Boolean;
        RecreateQst: Label 'Do you want to recreate the unit of measure mappings?';
    begin
        OnBeforeMapUnitOfMeasure(IsHandled);
        if IsHandled then
            exit;

        if not UnitOfMeasureMapping.IsEmpty() and GuiAllowed() then
            if not Confirm(RecreateQst) then
                exit;

        UnitOfMeasureMapping.DeleteAll();
        if UnitOfMeasure.FindSet() then
            repeat
                UnitOfMeasureMapping.Init();
                UnitOfMeasureMapping."Unit of Measure" := UnitOfMeasure.Code;
                UnitOfMeasureMapping."Unit of Measure (External)" := UnitOfMeasure.Code;
                UnitOfMeasureMapping.Insert();
            until UnitOfMeasure.Next() = 0;

        OnAfterMapUnitOfMeasure();
    end;

    #region [nShift Ship]
    local procedure GetCurrencyValue(CurrencyCode: Code[10]) ReturnValue: Integer
    var
        IsHandled: Boolean;
    begin
        OnBeforeGetCurrencyValue(CurrencyCode, ReturnValue, IsHandled);
        if IsHandled then
            exit(ReturnValue);

        case CurrencyCode of
            'NOK':
                exit(1);
            'DKK':
                exit(2);
            'SEK':
                exit(3);
            'GBP':
                exit(4);
            'EUR':
                exit(5);
            'USD':
                exit(6);
            'AUD':
                exit(7);
            'HKD':
                exit(8);
            'ISK':
                exit(9);
            'JPY':
                exit(10);
            'CAD':
                exit(11);
            'CYP':
                exit(12);
            'MTL':
                exit(13);
            'SGD':
                exit(14);
            'ZAR':
                exit(15);
            'CHF':
                exit(16);
            'THB':
                exit(17);
            'CZK':
                exit(18);
            'ZWL':
                exit(19);
            'BHD':
                exit(20);
            'AED':
                exit(21);
            'PHP':
                exit(22);
            'INR':
                exit(23);
            'IDR':
                exit(24);
            'ILS':
                exit(25);
            'KES':
                exit(26);
            'CNY':
                exit(27);
            'KRW':
                exit(28);
            'KWD':
                exit(29);
            'MXN':
                exit(30);
            'MAD':
                exit(31);
            'NZD':
                exit(32);
            'PKR':
                exit(33);
            'PLN':
                exit(34);
            'QAR':
                exit(35);
            'RUB':
                exit(36);
            'SAR':
                exit(37);
            'SKK':
                exit(38);
            'LKR':
                exit(39);
            'TWD':
                exit(40);
            'TZS':
                exit(41);
            'TND':
                exit(42);
            'TRY':
                exit(43);
            'HUF':
                exit(44);
            'EEK':
                exit(45);
            'RON':
                exit(46);
            'BGN':
                exit(47);
            'EGP':
                exit(48);
            'HRK':
                exit(49);
            'LTL':
                exit(50);
            'LVL':
                exit(51);
            'SIT':
                exit(52);
            'AFN':
                exit(53);
            'ALL':
                exit(54);
            'AMD':
                exit(55);
            'ANG':
                exit(56);
            'AOA':
                exit(57);
            'ARS':
                exit(58);
            'AWG':
                exit(59);
            'AZN':
                exit(60);
            'BAM':
                exit(61);
            'BBD':
                exit(62);
            'BDT':
                exit(63);
            'BIF':
                exit(64);
            'BMD':
                exit(65);
            'BND':
                exit(66);
            'BOB':
                exit(67);
            'BOV':
                exit(68);
            'BRL':
                exit(69);
            'BSD':
                exit(70);
            'BTN':
                exit(71);
            'BWP':
                exit(72);
            'BYR':
                exit(73);
            'BZD':
                exit(74);
            'CDF':
                exit(75);
            'CLP':
                exit(76);
            'CLF':
                exit(77);
            'COP':
                exit(78);
            'COU':
                exit(79);
            'CRC':
                exit(80);
            'CUP':
                exit(81);
            'CVE':
                exit(82);
            'DJF':
                exit(83);
            'DOP':
                exit(84);
            'DZD':
                exit(85);
            'ERN':
                exit(86);
            'ETB':
                exit(87);
            'FJD':
                exit(88);
            'FKP':
                exit(89);
            'GEL':
                exit(90);
            'GHS':
                exit(91);
            'GIP':
                exit(92);
            'GMD':
                exit(93);
            'GNF':
                exit(94);
            'GTQ':
                exit(95);
            'GWP':
                exit(96);
            'GYD':
                exit(97);
            'HNL':
                exit(98);
            'HTG':
                exit(99);
            'IQD':
                exit(100);
            'IRR':
                exit(101);
            'JMD':
                exit(102);
            'JOD':
                exit(103);
            'KGS':
                exit(104);
            'KHR':
                exit(105);
            'KMF':
                exit(106);
            'KPW':
                exit(107);
            'KYD':
                exit(108);
            'KZT':
                exit(109);
            'LAK':
                exit(110);
            'LBP':
                exit(111);
            'LRD':
                exit(112);
            'LSL':
                exit(113);
            'LYD':
                exit(114);
            'MDL':
                exit(115);
            'MGA':
                exit(116);
            'MKD':
                exit(117);
            'MMK':
                exit(118);
            'MNT':
                exit(119);
            'MOP':
                exit(120);
            'MRU':
                exit(121);
            'MUR':
                exit(122);
            'MVR':
                exit(123);
            'MWK':
                exit(124);
            'MYR':
                exit(125);
            'MZN':
                exit(126);
            'NAD':
                exit(127);
            'NGN':
                exit(128);
            'NIO':
                exit(129);
            'NPR':
                exit(130);
            'OMR':
                exit(131);
            'PAB':
                exit(132);
            'PEN':
                exit(133);
            'PGK':
                exit(134);
            'PYG':
                exit(135);
            'RWF':
                exit(136);
            'SBD':
                exit(137);
            'SCR':
                exit(138);
            'SDG':
                exit(139);
            'SHP':
                exit(140);
            'SLL':
                exit(141);
            'SOS':
                exit(142);
            'SRD':
                exit(143);
            'STN':
                exit(144);
            'SVC':
                exit(145);
            'SYP':
                exit(146);
            'SZL':
                exit(147);
            'TJS':
                exit(148);
            'TMT':
                exit(149);
            'TOP':
                exit(150);
            'TTD':
                exit(151);
            'UAH':
                exit(152);
            'UGX':
                exit(153);
            'UYU':
                exit(154);
            'UYI':
                exit(155);
            'UZS':
                exit(156);
            'VEF':
                exit(157);
            'VND':
                exit(158);
            'VUV':
                exit(159);
            'WST':
                exit(160);
            'YER':
                exit(161);
            'ZMW':
                exit(162);
            'RSD':
                exit(163);
            'XAF':
                exit(164);
            'XOF':
                exit(165);
            'XCD':
                exit(166);
            'XPF':
                exit(167);
        end;
    end;
    #endregion

    local procedure LoadSetup()
    var
        CompanyInformation: Record "Company Information";
    begin
        if not IDYSSetup.Get('') then begin
            IDYSSetup.InitSetup();
            if CompanyInformation.Get() then
                IDYSSetup."Default Ship-to Country" := CompanyInformation."Country/Region Code";
            IDYSSetup.Insert();
        end else
            if IDYSSetup."default Ship-to Country" = '' then
                if CompanyInformation.Get() then begin
                    IDYSSetup."Default Ship-to Country" := CompanyInformation."Country/Region Code";
                    IDYSSetup.Modify();
                end;
        IDYSSetup.TestField("Default Ship-to Country");
    end;

    procedure MapCountries()
    var
        IDYSCountryRegionMapping: Record "IDYS Country/Region Mapping";
        CountryRegion: Record "Country/Region";
        IsHandled: Boolean;
    begin
        OnBeforeMapCountries(IsHandled);
        if IsHandled then
            exit;

        IDYSCountryRegionMapping.DeleteAll();

        LoadSetup();

        if CountryRegion.FindSet() then
            repeat
                IDYSCountryRegionMapping.Init();
                IDYSCountryRegionMapping."Country/Region Code" := CountryRegion."Code";
                IDYSCountryRegionMapping."Country/Region Code (External)" := CountryRegion."ISO Code";
                IDYSCountryRegionMapping.Insert();
                if CountryRegion.Code = IDYSSetup."default Ship-to Country" then
                    if not IDYSCountryRegionMapping.Get('') then begin
                        IDYSCountryRegionMapping.Init();
                        IDYSCountryRegionMapping."Country/Region Code" := '';
                        IDYSCountryRegionMapping."Country/Region Code (External)" := CountryRegion."ISO Code";
                        IDYSCountryRegionMapping.Insert();
                    end;
            until CountryRegion.Next() = 0;

        OnAfterMapCountries();
    end;

    procedure MapLanguages()
    var
        LanguageMapping: Record "IDYS Language Mapping";
        Language: Record Language;
        IsHandled: Boolean;
    begin
        OnBeforeMapLanguages(IsHandled);
        if IsHandled then
            exit;

        LanguageMapping.DeleteAll();

        if Language.Get('NLB') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'NLB';
            LanguageMapping."Language Code (External)" := 'NL';
            LanguageMapping.Insert();
        end;
        if Language.Get('NLD') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'NLD';
            LanguageMapping."Language Code (External)" := 'NL';
            LanguageMapping.Insert();
        end;
        if Language.Get('DAN') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'DAN';
            LanguageMapping."Language Code (External)" := 'DA';
            LanguageMapping.Insert();
        end;
        if Language.Get('DEU') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'DEU';
            LanguageMapping."Language Code (External)" := 'DE';
            LanguageMapping.Insert();
        end;
        if Language.Get('ELL') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'ELL';
            LanguageMapping."Language Code (External)" := 'EL';
            LanguageMapping.Insert();
        end;
        if Language.Get('ENG') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'ENG';
            LanguageMapping."Language Code (External)" := 'GB';
            LanguageMapping.Insert();
        end;
        if Language.Get('ENU') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'ENU';
            LanguageMapping."Language Code (External)" := 'US';
            LanguageMapping.Insert();
        end;
        if Language.Get('ESP') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'ESP';
            LanguageMapping."Language Code (External)" := 'ES';
            LanguageMapping.Insert();
        end;
        if Language.Get('FRA') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'FRA';
            LanguageMapping."Language Code (External)" := 'FR';
            LanguageMapping.Insert();
        end;
        if Language.Get('FRB') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'FRB';
            LanguageMapping."Language Code (External)" := 'FR';
            LanguageMapping.Insert();
        end;
        if Language.Get('ITA') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'ITA';
            LanguageMapping."Language Code (External)" := 'IT';
            LanguageMapping.Insert();
        end;
        if Language.Get('NOR') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'NOR';
            LanguageMapping."Language Code (External)" := 'NO';
            LanguageMapping.Insert();
        end;
        if Language.Get('PLK') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'PLK';
            LanguageMapping."Language Code (External)" := 'PL';
            LanguageMapping.Insert();
        end;
        if Language.Get('PTG') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'PTG';
            LanguageMapping."Language Code (External)" := 'PT';
            LanguageMapping.Insert();
        end;
        if Language.Get('SVE') then begin
            LanguageMapping.Init();
            LanguageMapping."Language Code" := 'SVE';
            LanguageMapping."Language Code (External)" := 'SV';
            LanguageMapping.Insert();
        end;

        OnAfterMapLanguages();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMapCurrencies(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMapCurrencies()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMapUnitOfMeasure(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMapUnitOfMeasure()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCurrencyValue(CurrencyCode: Code[10]; var ReturnValue: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMapCountries(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMapCountries()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMapLanguages(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMapLanguages()
    begin
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        IDYSSetup: Record "IDYS Setup";
}