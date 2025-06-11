page 11147669 "IDYS Transport Order Card"
{
#if BC17
#pragma warning disable AL0604
#endif
    Caption = 'Transport Order Card';
    PageType = Document;
#if BC17 or BC18 or BC19 or BC20
    PromotedActionCategories = 'New,Process,Report,Transport Order';
#endif
    SourceTable = "IDYS Transport Order Header";
    UsageCategory = None;
    ContextSensitiveHelpPage = '22937633';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no..';

                    trigger OnAssistEdit();
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }

                field(Description; Rec.Description)
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ToolTip = 'Describes the transport order.';
                }

                field(Status; Rec.Status)
                {
                    Importance = Promoted;
                    ApplicationArea = All;
                    StyleExpr = StatusStyleExpr;
                    ToolTip = 'Specifies the status of the transport order.';
                }
                group(StatusExternal)
                {
                    ShowCaption = false;
                    Visible = IsCargoson;
                    field("Status (External)"; Rec."Status (External)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the status details from the carrier.';
                    }
                }
                group(SubStatusExternal)
                {
                    ShowCaption = false;
                    Visible = IsTranssmart or IsnShiftShip;
                    field("Sub Status (External)"; Rec."Sub Status (External)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the status details from the carrier.';
                    }
                }

                field(Provider; Rec.Provider)
                {
                    Editable = ProviderEditable;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipment method code.';
                }

                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent code.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                        CurrPage.Update();
                    end;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service code.';

                    trigger OnValidate()
                    var
                        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
                    begin
                        IsnShiftShip := IDYSProviderMgt.IsProvider("IDYS Provider"::"Delivery Hub", Rec);
                        SetOpenService();
                        CurrPage.Update();
                    end;
                }

                #region [nShift Ship]
                group(DeliveryHub)
                {
                    ShowCaption = false;
                    Visible = IsnShiftShip;

                    field(OpenServices; OpenService)
                    {
                        Editable = false;
                        ApplicationArea = All;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        var
                            SelectServiceLvlOther: Page "IDYS Select Service Lvl Other";
                        begin
                            SelectServiceLvlOther.SetParameters(Database::"IDYS Transport Order Header", "IDYS Source Document Type"::"0", Rec."No.", Rec."Cntry/Rgn. Code (Pick-up) (TS)", Rec."Cntry/Rgn. Code (Ship-to) (TS)", Rec.SystemId);
                            SelectServiceLvlOther.InitializePage(Rec."Carrier Entry No.", Rec."Booking Profile Entry No.");
                            SelectServiceLvlOther.RunModal();
                            SetOpenService();
                            CurrPage.Update();
                        end;
                    }
                }
                #endregion
                field("Accepted By"; Rec."Accepted By")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies who it was accepted by.';
                }

                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies tracking no..';
                }

                field("Tracking Url"; Rec."Tracking Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tracking url.';
                }

                group(Transsmart)
                {
                    ShowCaption = false;
                    Visible = IsTranssmart;

                    field("Shipment Error"; Rec."Shipment Error")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the booking error.';
                    }

                    field("Service Type"; Rec."Service Type Enum")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the service type.';
                    }

                    field("E-Mail Type"; Rec."E-Mail Type")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the e-mail type.';
                    }

                    field("Cost Center"; Rec."Cost Center")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the cost center.';
                    }
                    field("Actual Delivery Date"; Rec."Actual Delivery Date")
                    {
                        Visible = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the actual delivery date.';
                    }
                    group(Insurance)
                    {
                        ShowCaption = false;
                        Visible = IDYSInsuranceEnabled;
                        field(Insure; Rec.Insure)
                        {
                            Editable = FieldsEditable;
                            ApplicationArea = All;
                            ToolTip = 'Specifies if insurance is applied';
                        }
                    }
                }

                field("Is Return"; Rec."Is Return")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Is Return';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }

                group(Cargoson)
                {
                    ShowCaption = false;
                    Visible = IsCargoson;
                    field("Label Format"; Rec."Label Format")
                    {
                        Editable = LabelFormatEditable or FieldsEditable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the label format. If the order was already booked before changing the label format, delete the previously created label file from Attachments.';
                    }
                    field("Include Invoice Address"; Rec."Include Invoice Address")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether the invoice information should be included. Including this information overwrites the freight payer details and may result in different pricing.';

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                }

                group("Pick-up & Delivery")
                {
                    Caption = 'Pick-up & Delivery';
                    Visible = not (IsSendcloud or IsEasyPost);
                    group(Preferred)
                    {
                        Caption = 'Preferred';

                        field("Preferred Pick-up Date"; Rec."Preferred Pick-up Date")
                        {
                            Caption = 'Pick-up Date';
                            Editable = FieldsEditable;
                            ApplicationArea = All;
                            ToolTip = 'Specifies the preferred pick up date.';
                        }
                        field("Preferred Delivery Date"; Rec."Preferred Delivery Date")
                        {
                            Caption = 'Delivery Date';
                            Editable = FieldsEditable;
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the preferred delivery date.';
                        }
                    }
                    group("Pick-up")
                    {
                        Caption = 'Pick-up';
                        field("Preferred Pick-up Date From"; Rec."Preferred Pick-up Date From")
                        {
                            Caption = 'Between';
                            Editable = FieldsEditable;
                            ApplicationArea = All;
                            ToolTip = 'Specifies the pick up from date.';
                        }

                        field("Preferred Pick-up Date To"; Rec."Preferred Pick-up Date To")
                        {
                            Caption = 'And';
                            Editable = FieldsEditable;
                            ApplicationArea = All;
                            ToolTip = 'Specifies the pick up to date.';
                        }
                    }

                    group(Delivery)
                    {
                        Caption = 'Delivery';
                        field("Preferred Delivery Date From"; Rec."Preferred Delivery Date From")
                        {
                            Caption = 'Between';
                            Editable = FieldsEditable;
                            ApplicationArea = All;
                            ToolTip = 'Specifies the delivery from date.';
                        }

                        field("Preferred Delivery Date To"; Rec."Preferred Delivery Date To")
                        {
                            Caption = 'And';
                            Editable = FieldsEditable;
                            ApplicationArea = All;
                            ToolTip = 'Specifies the delivery till date.';
                        }
                    }
                }

                group("Background Booking")
                {
                    Caption = 'Background Booking';
                    Visible = BackgroundBookingVisible;

                    field("Booking Scheduled By"; Rec."Booking Scheduled By")
                    {
                        ToolTip = 'Specifies the user who scheduled background booking for this transport order.';
                        ApplicationArea = All;
                    }
                    field("Booking Scheduled On"; Rec."Booking Scheduled On")
                    {
                        ToolTip = 'Specifies the user who scheduled background booking for this transport order.';
                        ApplicationArea = All;
                    }
                    field("Shipment Error2"; Rec."Shipment Error")
                    {
                        ApplicationArea = All;
                        Caption = 'Background Booking Error';
                        ToolTip = 'Specifies the booking error.';
                    }
                }
            }

            part("Source Lines"; "IDYS Transport Order Line Sub.")
            {
                Caption = 'Source Lines';
                Editable = FieldsEditable;
                SubPageLink = "Transport Order No." = field("No.");
                SubPageView = sorting("Transport Order No.", "Line No.");
                ApplicationArea = All;
                UpdatePropagation = Both;
            }


            part("Packages"; "IDYS Transport Order Pck. Sub.")
            {
                Caption = 'Packages';
                Editable = FieldsEditable;
                SubPageLink = "Transport Order No." = field("No.");
                SubPageView = sorting("Transport Order No.", "Line No.");
                ApplicationArea = All;
                UpdatePropagation = Both;
            }

            part("IDYS Transport Order Del. Sub."; "IDYS Transport Order Del. Sub.")
            {
                Caption = 'Delivery Notes';
                Editable = FieldsEditable;
                SubPageLink = "Transport Order No." = field("No.");
                SubPageView = sorting("Transport Order No.", "Line No.");
                ApplicationArea = All;
                UpdatePropagation = Both;
            }

            #region [Obsolete]
            group("SC Pick-up Address")
            {
                Caption = 'Pick-up Address';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Sender Address removed';
                ObsoleteTag = '21.0';

                group(NotReturn)
                {
                    ShowCaption = false;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Sender Address removed';
                    ObsoleteTag = '21.0';

                    field("SC Type (Pick-up)"; Rec."Source Type (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        Importance = Promoted;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the type.';
                        ValuesAllowed = 0, 3;

                        trigger OnValidate()
                        begin
                            SetNoAndCodeEnabled("IDYS Address Type"::"Pick-up");
                        end;
                    }

                    field("SC No. (Pick-up)"; Rec."No. (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        Importance = Promoted;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the no..';
                        Enabled = NoPickUpEnabled;

                        trigger OnValidate()
                        begin
                            SetNoAndCodeEnabled("IDYS Address Type"::"Pick-up");
                        end;
                    }

                    field("Address Id. (Pick-up)"; Rec."Address Id. (Pick-up)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Address Id. (Pick-up).';
                        ShowMandatory = true;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Sender Address removed';
                        ObsoleteTag = '21.0';
                        Visible = false;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }

                    field("SC Country/Region Code (Pick-up)"; Rec."Country/Region Code (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the country/region code.';
                    }
                }
                group(Return)
                {
                    ShowCaption = false;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Sender Address removed';
                    ObsoleteTag = '21.0';

                    field("SCR Type (Pick-up)"; Rec."Source Type (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        Importance = Promoted;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the type.';

                        trigger OnValidate()
                        begin
                            SetNoAndCodeEnabled("IDYS Address Type"::"Pick-up");
                        end;
                    }

                    field("SCR No. (Pick-up)"; Rec."No. (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        Importance = Promoted;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the no..';
                        Enabled = NoPickUpEnabled;

                        trigger OnValidate()
                        begin
                            SetNoAndCodeEnabled("IDYS Address Type"::"Pick-up");
                        end;
                    }

                    field("SCR Code (Pick-up)"; Rec."Code (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the code.';
                        Enabled = CodePickUpEnabled;
                    }

                    field("SCR Name (Pick-up)"; Rec."Name (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the name.';
                    }

                    field("SCR Address (Pick-up)"; Rec."Address (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the address.';
                    }

                    field("SCR Street (Pick-up)"; Rec."Street (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the address 2.';
                    }

                    field("SCR House No. (Pick-up)"; Rec."House No. (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the house no..';
                    }

                    field("SCR Address 2 (Pick-up)"; Rec."Address 2 (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the ';
                    }

                    field("SCR Post Code (Pick-up)"; Rec."Post Code (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the post code.';
                    }

                    field("SCR City (Pick-up)"; Rec."City (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the city.';
                    }

                    field("SCR County (Pick-up)"; Rec."County (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the county.';
                    }

                    field("SCR Country/Region Code (Pick-up)"; Rec."Country/Region Code (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the country/region code.';
                    }

                    field("SCR Contact (Pick-up)"; Rec."Contact (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the contact.';
                    }

                    field("SCR Phone No. (Pick-up)"; Rec."Phone No. (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the phone no.';
                    }

                    field("SCR Fax No. (Pick-up)"; Rec."Fax No. (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the fax no..';
                    }

                    field("SCR E-Mail (Pick-up)"; Rec."E-Mail (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the e-mail.';
                    }

                    field("SCR VAT Registration No. (Pick-up)"; Rec."VAT Registration No. (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the VAT registration no.';
                    }

                    field("SCR EORI Number (Pick-up)"; Rec."EORI Number (Pick-up)")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the EORI Number.';
                    }


                }
            }
            #endregion

            group("Pick-up Address")
            {
                Caption = 'Pick-up Address';
                field("Type (Pick-up)"; Rec."Source Type (Pick-up)")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type.';

                    trigger OnValidate()
                    begin
                        SetNoAndCodeEnabled("IDYS Address Type"::"Pick-up");
                    end;
                }

                field("No. (Pick-up)"; Rec."No. (Pick-up)")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no..';
                    Enabled = NoPickUpEnabled;

                    trigger OnValidate()
                    begin
                        SetNoAndCodeEnabled("IDYS Address Type"::"Pick-up");
                    end;
                }

                field("Code (Pick-up)"; Rec."Code (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code.';
                    Enabled = CodePickUpEnabled;
                }
                field("Account No. (Pick-up)"; Rec."Account No. (Pick-up)")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Account No. (Pick-up).';
                }
                field("Name (Pick-up)"; Rec."Name (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = NamePickUpStyleExpr;
                    ToolTip = 'Specifies the name.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Address (Pick-up)"; Rec."Address (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = AddressPickUpStyleExpr;
                    ToolTip = 'Specifies the address.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Street (Pick-up)"; Rec."Street (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = StreetPickUpStyleExpr;
                    ToolTip = 'Specifies the address 2.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("House No. (Pick-up)"; Rec."House No. (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = HouseNoPickUpStyleExpr;
                    ToolTip = 'Specifies the house no..';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Address 2 (Pick-up)"; Rec."Address 2 (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = Address2PickUpStyleExpr;
                    ToolTip = 'Specifies the ';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Post Code (Pick-up)"; Rec."Post Code (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = PostCodePickUpStyleExpr;
                    ToolTip = 'Specifies the post code.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("City (Pick-up)"; Rec."City (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = CityPickUpStyleExpr;
                    ToolTip = 'Specifies the city.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("County (Pick-up)"; Rec."County (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = CountyPickUpStyleExpr;
                    ShowMandatory = CountyPickUpMandatory;
                    ToolTip = 'Specifies the county.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Country/Region Code (Pick-up)"; Rec."Country/Region Code (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = CountryRegionCodePickUpStyleExpr;
                    ShowMandatory = CountryRegionCodePickUpMandatory;
                    ToolTip = 'Specifies the country/region code.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                        CurrPage.Update();
                    end;
                }

                field("Contact (Pick-up)"; Rec."Contact (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = ContactPickUpStyleExpr;
                    ShowMandatory = ContactPickUpMandatory;
                    ToolTip = 'Specifies the contact.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Phone No. (Pick-up)"; Rec."Phone No. (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = PhoneNoPickUpStyleExpr;
                    ToolTip = 'Specifies the phone no.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }
                field("Mobile Phone No. (Pick-up)"; Rec."Mobile Phone No. (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = MobPhoneNoPickUpStyleExpr;
                    ShowMandatory = MobPhoneNoPickUpMandatory;
                    ToolTip = 'Specifies the mobile phone no.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Fax No. (Pick-up)"; Rec."Fax No. (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = FaxNoPickUpStyleExpr;
                    ShowMandatory = FaxNoPickUpMandatory;
                    ToolTip = 'Specifies the fax no..';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("E-Mail (Pick-up)"; Rec."E-Mail (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = EmailPickUpStyleExpr;
                    ShowMandatory = EmailPickUpMandatory;
                    ToolTip = 'Specifies the e-mail.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("VAT Registration No. (Pick-up)"; Rec."VAT Registration No. (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = VATRegNoPickUpStyleExpr;
                    ShowMandatory = VATRegNoPickUpMandatory;
                    ToolTip = 'Specifies the VAT registration no.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("EORI Number (Pick-up)"; Rec."EORI Number (Pick-up)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = EORINumberPickUpStyleExpr;
                    ShowMandatory = EORINumberPickUpMandatory;
                    ToolTip = 'Specifies the EORI Number.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }
            }
            group("Ship-to Address")
            {
                Caption = 'Ship-to Address';
                field("Type (Ship-to)"; Rec."Source Type (Ship-to)")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type.';

                    trigger OnValidate()
                    begin
                        SetNoAndCodeEnabled("IDYS Address Type"::"Ship-to");
                    end;
                }

                field("No. (Ship-to)"; Rec."No. (Ship-to)")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no..';
                    Enabled = NoShipToEnabled;

                    trigger OnValidate()
                    begin
                        SetNoAndCodeEnabled("IDYS Address Type"::"Ship-to");
                    end;
                }

                field("Code (Ship-to)"; Rec."Code (Ship-to)")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code.';
                    Enabled = CodeShipToEnabled;
                }
                field("Account No."; Rec."Account No.")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Account No. (Ship-to).';
                }
                field("Name (Ship-to)"; Rec."Name (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = NameShipToStyleExpr;
                    ToolTip = 'Specifies the name.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Address (Ship-to)"; Rec."Address (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = AddressShipToStyleExpr;
                    ToolTip = 'Specifies the address.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Street (Ship-to)"; Rec."Street (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = StreetShipToStyleExpr;
                    ToolTip = 'Specifies the address 2.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("House No. (Ship-to)"; Rec."House No. (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = HouseNoShipToStyleExpr;
                    ToolTip = 'Specifies the house no..';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Address 2 (Ship-to)"; Rec."Address 2 (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = Address2ShipToStyleExpr;
                    ToolTip = 'Specifies the address 2.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Post Code (Ship-to)"; Rec."Post Code (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = PostCodeShipToStyleExpr;
                    ToolTip = 'Specifies the post code.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("City (Ship-to)"; Rec."City (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = CityShipToStyleExpr;
                    ToolTip = 'Specifies the city.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("County (Ship-to)"; Rec."County (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = CountyShipToStyleExpr;
                    ShowMandatory = CountyShipToMandatory;
                    ToolTip = 'Specifies the county.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Country/Region Code (Ship-to)"; Rec."Country/Region Code (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = CountryRegionCodeShipToStyleExpr;
                    ShowMandatory = CountryRegionCodeShipToMandatory;
                    ToolTip = 'Specifies the country/region code.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                        CurrPage.Update();
                    end;
                }

                field("Contact (Ship-to)"; Rec."Contact (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = ContactShipToStyleExpr;
                    ShowMandatory = ContactShipToMandatory;
                    ToolTip = 'Specifies the contact.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Phone No. (Ship-to)"; Rec."Phone No. (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = PhoneNoShipToStyleExpr;
                    ToolTip = 'Specifies the phone no.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }
                field("Mobile Phone No. (Ship-to)"; Rec."Mobile Phone No. (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = MobPhoneNoShipToStyleExpr;
                    ShowMandatory = MobPhoneNoShipToMandatory;
                    ToolTip = 'Specifies the mobile phone no.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Fax No. (Ship-to)"; Rec."Fax No. (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = FaxNoShipToStyleExpr;
                    ShowMandatory = FaxNoShipToMandatory;
                    ToolTip = 'Specifies the fax no.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("E-Mail (Ship-to)"; Rec."E-Mail (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = EmailShipToStyleExpr;
                    ShowMandatory = EmailShipToMandatory;
                    ToolTip = 'Specifies the e-mail.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("VAT Registration No. (Ship-to)"; Rec."VAT Registration No. (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = VATRegNoShipToStyleExpr;
                    ShowMandatory = VATRegNoShipToMandatory;
                    ToolTip = 'Specifies the VAT registration no..';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("EORI Number (Ship-to)"; Rec."EORI Number (Ship-to)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = EORINumberShipToStyleExpr;
                    ShowMandatory = EORINumberShipToMandatory;
                    ToolTip = 'Specifies the EORI Number.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }
                #region [Sendcloud]
                field("Recipient PO Box No."; Rec."Recipient PO Box No.")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the PO Box No. the parcel will be send to.';
                    Importance = Additional;
                }
                #endregion
            }
            group("Invoice Address")
            {
                Caption = 'Invoice Address';
                Visible = not (IsSendcloud or IsEasyPost) and IncludeInvoiceAddress;
                field("Type (Invoice)"; Rec."Source Type (Invoice)")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type.';

                    trigger OnValidate()
                    begin
                        SetNoAndCodeEnabled("IDYS Address Type"::"Invoice");
                    end;
                }

                field("No. (Invoice)"; Rec."No. (Invoice)")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no..';
                    Enabled = NoInvoiceEnabled;
                }
                field("Account No. (Invoice)"; Rec."Account No. (Invoice)")
                {
                    Editable = FieldsEditable;
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Account No. (Invoice).';
                }
                field("Name (Invoice)"; Rec."Name (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = NameInvoiceStyleExpr;
                    ToolTip = 'Specifies the name.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Address (Invoice)"; Rec."Address (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = AddressInvoiceStyleExpr;
                    ToolTip = 'Specifies the address.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Street (Invoice)"; Rec."Street (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = StreetInvoiceStyleExpr;
                    ToolTip = 'Specifies the street name.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("House No. (Invoice)"; Rec."House No. (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = HouseNoInvoiceStyleExpr;
                    ToolTip = 'Specifies the house no.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Address 2 (Invoice)"; Rec."Address 2 (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = Address2InvoiceStyleExpr;
                    ToolTip = 'Specifies the address 2.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Post Code (Invoice)"; Rec."Post Code (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = PostCodeInvoiceStyleExpr;
                    ToolTip = 'Specifies the post code.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("City (Invoice)"; Rec."City (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    ShowMandatory = true;
                    StyleExpr = CityInvoiceStyleExpr;
                    ToolTip = 'Specifies the city.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("County (Invoice)"; Rec."County (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = CountyInvoiceStyleExpr;
                    ShowMandatory = CountyInvoiceMandatory;
                    ToolTip = 'Specifies the county.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Country/Region Code (Invoice)"; Rec."Country/Region Code (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = CountryRegionCodeInvoiceStyleExpr;
                    ShowMandatory = CountryRegionCodeInvoiceMandatory;
                    ToolTip = 'Specifies the country/region code.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Contact (Invoice)"; Rec."Contact (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = ContactInvoiceStyleExpr;
                    ShowMandatory = ContactInvoiceMandatory;
                    ToolTip = 'Specifies the contact.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Phone No. (Invoice)"; Rec."Phone No. (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = PhoneNoInvoiceStyleExpr;
                    ShowMandatory = PhoneNoInvoiceMandatory;
                    ToolTip = 'Specifies the phone no.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }
                field("Mobile Phone No. (Invoice)"; Rec."Mobile Phone No. (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = MobPhoneNoInvoiceStyleExpr;
                    ShowMandatory = MobPhoneNoInvoiceMandatory;
                    ToolTip = 'Specifies the mobile phone no.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }
                field("Fax No. (Invoice)"; Rec."Fax No. (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = FaxNoInvoiceStyleExpr;
                    ShowMandatory = FaxNoInvoiceMandatory;
                    ToolTip = 'Specifies the fax no.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("E-Mail (Invoice)"; Rec."E-Mail (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = EmailInvoiceStyleExpr;
                    ShowMandatory = EmailInvoiceMandatory;
                    ToolTip = 'Specifies the e-mail.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("VAT Registration No. (Invoice)"; Rec."VAT Registration No. (Invoice)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = VATRegNoInvoiceStyleExpr;
                    ShowMandatory = VATRegNoInvoiceMandatory;
                    ToolTip = 'Specifies the VAT registration no..';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }
            }
            group("Additional References")
            {
                Caption = 'Additional References';
                Visible = not (IsSendcloud or IsEasyPost or IsCargoson);

                field("Invoice (Ref)"; Rec."Invoice (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = InvoiceRefStyleExpr;
                    ShowMandatory = InvoiceRefMandatory;
                    ToolTip = 'Specifies the invoice (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Customer Order (Ref)"; Rec."Customer Order (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = CustOrderReftyleExpr;
                    ToolTip = 'Specifies the customer order (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Order No. (Ref)"; Rec."Order No. (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = OrderNoRefStyleExpr;
                    ShowMandatory = OrderNoRefMandatory;
                    ToolTip = 'Specifies the order no. (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Delivery Note (Ref)"; Rec."Delivery Note (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = DeliveryNoteRefStyleExpr;
                    ShowMandatory = DeliveryNoteRefMandatory;
                    ToolTip = 'Specifies the delivery note (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Delivery Id (Ref)"; Rec."Delivery Id (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = DeliveryIdRefStyleExpr;
                    ShowMandatory = DeliveryIdRefMandatory;
                    ToolTip = 'Specifies the delivery Id (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Other (Ref)"; Rec."Other (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = OtherRefStyleExpr;
                    ShowMandatory = OtherRefMandatory;
                    ToolTip = 'Specifies the other (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Service Point (Ref)"; Rec."Service Point (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = ServicePointRefStyleExpr;
                    ShowMandatory = ServicePointRefMandatory;
                    ToolTip = 'Specifies the service point (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Project (Ref)"; Rec."Project (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = ProjectRefStyleExpr;
                    ShowMandatory = ProjectRefMandatory;
                    ToolTip = 'Specifies the project (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Your Reference (Ref)"; Rec."Your Reference (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = YourReferenceRefStyleExpr;
                    ShowMandatory = YourReferenceRefMandatory;
                    ToolTip = 'Specifies the your reference (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Engineer (Ref)"; Rec."Engineer (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = EngineerRefStyleExpr;
                    ShowMandatory = EngineerRefMandatory;
                    ToolTip = 'Specifies the engineer (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Customer (Ref)"; Rec."Customer (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = CustomerRefStyleExpr;
                    ShowMandatory = CustomerRefMandatory;
                    ToolTip = 'Specifies the customer (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Agent (Ref)"; Rec."Agent (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = AgentRefStyleExpr;
                    ShowMandatory = AgentRefMandatory;
                    ToolTip = 'Specifies the agent (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Driver ID (Ref)"; Rec."Driver ID (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = DriverIdRefStyleExpr;
                    ShowMandatory = DriverIdRefMandatory;
                    ToolTip = 'Specifies the driver Id (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field("Route ID (Ref)"; Rec."Route ID (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Importance = Additional;
                    StyleExpr = RouteIdRefStyleExpr;
                    ShowMandatory = RouteIdRefMandatory;
                    ToolTip = 'Specifies the route Id (ref).';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }

                field(Instruction; Rec.Instruction)
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    StyleExpr = InstructionStyleExpr;
                    ShowMandatory = InstructionMandatory;
                    ToolTip = 'Specifies the instruction.';

                    trigger OnValidate()
                    begin
                        SetStyle();
                        SetMandatoryFields();
                    end;
                }
                group("Reason of Export Group")
                {
                    ShowCaption = false;
                    Visible = IsnShiftShip;

                    field("Reason of Export"; Rec."Reason of Export")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the reason of export.';
                    }
                }
            }
            group("EasyPost Additional References")
            {
                Caption = 'Additional References';
                Visible = IsEasyPost;

                field("EP Invoice (Ref)"; Rec."Invoice (Ref)")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Caption = 'Invoice Number';
                    ToolTip = 'Specifies the invoice number.';
                }

                field("EP Instruction"; Rec.Instruction)
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Caption = 'Handling Instruction';
                    ToolTip = 'Specifies the handling instruction.';
                }
            }
            #region [Sendcloud]
            group(Customs)
            {
                Caption = 'Customs';
#if BC17
                Visible = "Ship Outside EU" and IsSendcloud;
#else
                Visible = Rec."Ship Outside EU" and IsSendcloud;
#endif
                Editable = FieldsEditable;
                field("Customs Invoice No."; Rec."Customs Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the invoice number that are required for customs clearance.';
                    ShowMandatory = true;
                }
                field("Customs Shipment Type"; Rec."Customs Shipment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipment type, which is required for customs clearance.';
                    ShowMandatory = true;
                }
            }
            #endregion

            #region [EasyPost]
            group(Customs_EasyPost)
            {
                Caption = 'Customs';
                Visible = IsEasyPost;
                Editable = FieldsEditable;

                field("Contents Type"; Rec."Contents Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of item being shipped.';
                }
                field("Contents Explanation"; Rec."Contents Explanation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipment type, which is required for customs clearance.';
#if BC17
                    Editable = "Contents Type" = "Contents Type"::other;
#else
                    Editable = Rec."Contents Type" = Rec."Contents Type"::other;
#endif
                }
                field("Restriction Type"; Rec."Restriction Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if special treatment or quarantine is required upon entering the country.';
                }

                field("Restriction Comments"; Rec."Restriction Comments")
                {
                    ApplicationArea = All;
                    ToolTip = 'If Restriction Type is not none, provide a brief description of the required treatment.';
#if BC17
                    Editable = "Restriction Type" <> "Restriction Type"::none;
#else
                    Editable = Rec."Restriction Type" <> Rec."Restriction Type"::none;
#endif                    
                }
                field("Customs Certify"; Rec."Customs Certify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Confirms the accuracy of the information provided on the customs form.';
                }

                field("Customs Signer"; Rec."Customs Signer")
                {
                    ApplicationArea = All;
                    ToolTip = 'The name of the person certifying the accuracy of the information on the customs form.';
                }

                field("Non Delivery Options"; Rec."Non Delivery Options")
                {
                    ApplicationArea = All;
                    ToolTip = 'In case the package cannot be delivered, choose what should happen to it.';
                }
                field("EEL/PFC"; Rec."EEL / PFC")
                {
                    ApplicationArea = All;
                    ToolTip = 'When shipping outside of the US, provide either an Exemption and Exclusion Legend (EEL) code or a Proof of Filing Citation (PFC) based on the value of the goods being shipped.';
                }
            }
            #endregion            
            group(Totals)
            {
                Caption = 'Totals';
                Visible = not (IsSendcloud or IsEasyPost);

                group(LoadMeter)
                {
                    Visible = not IsCargoson;
                    ShowCaption = false;
                    field("Load Meter"; Rec."Load Meter")
                    {
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the load meter.';
                    }
                }
                field("Total No. of Packages"; Rec."Total No. of Packages")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total no. of packages.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Quantity replaced with multiplication action on a subpage';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }
                field("Total Count of Packages"; Rec."Total Count of Packages")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total no. of packages.';
                }
                field("Total Volume"; Rec."Total Volume")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total volume.';
                }
                field(CalculatedWeight; Rec.GetCalculatedWeight())
                {
                    ApplicationArea = All;
                    Caption = 'Total Weight';
                    ToolTip = 'Specifies the total weight.';
                    Editable = false;
                }
                group(CarrierWeight)
                {
                    Visible = not IsCargoson;
                    ShowCaption = false;
                    field("Carrier Weight"; Rec."Carrier Weight")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the total weight determined by the Carrier.';
                        Editable = false;
                    }
                }
                field("Total Weight"; Rec."Total Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total weight.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with calculated field';
                    ObsoleteTag = '21.0';
                    Visible = false;
                }
                group("IDYS Shipment Value")
                {
                    Caption = 'Shipment Value';
                    field("Shipment Value Currency Code"; Rec."Shipment Value Curr Code")
                    {
                        Caption = 'Currency Code';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the shipment value currency code.';
                    }

                    field("Calculated Shipment Value"; Rec."Calculated Shipment Value")
                    {
                        Caption = 'Calculated Value';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the calculated shipment value, which is the sum of the transport values of the source lines. A transport value is mandatory in the communication with most providers. If the calculated transport value is zero or incorrect, then the actual shipment value can be used to register the correct amount. When the commercial value is empty then the unit costs will be used to determine the transport values.';
                    }

                    field("Shipment Value"; Rec."Shipmt. Value")
                    {
                        Caption = 'Actual Value';
                        Editable = FieldsEditable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the actual shipment value. When the calculated shipment value doesn''t represent the real transport value, the actual transport value can be entered in this field.';
                    }
                }
                group("IDYS Shipment Cost")
                {
                    Caption = 'Shipment Cost';
                    Visible = not IsCargoson;
                    field("Shipment Cost Currency Code"; Rec."Shipment Cost Curr Code")
                    {
                        Caption = 'Currency Code';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the currency code.';
                    }

                    field("Shipment Cost"; Rec."Shipmt. Cost")
                    {
                        Caption = 'Cost';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the shipment cost.';
                    }
                }
                group("IDYS Spot Price")
                {
                    Caption = 'Spot Price';
                    Visible = not IsCargoson;
                    field("Spot Price Currency Code"; Rec."Spot Price Curr Code")
                    {
                        Caption = 'Currency Code';
                        Editable = false;
                        Importance = Promoted;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the currency code.';
                    }

                    field("Spot Price"; Rec."Spot Pr.")
                    {
                        Caption = 'Price';
                        Editable = false;
                        Importance = Promoted;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the spot price.';
                    }
                }
                group("IDYS Insurance")
                {
                    Caption = 'Insurance';
#if BC17
                    Visible = Insure or IDYSInsuranceEnabled;
#else
                    Visible = Rec.Insure or IDYSInsuranceEnabled;
#endif                      
                    field("Insurance Status Description"; Rec."Insurance Status Description")
                    {
                        Caption = 'Insurance Status Description';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the insurance status description.';
                    }
                    field("Insurance Company"; Rec."Insurance Company")
                    {
                        Caption = 'Insurance Company';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the insurance company.';
                    }
                    field("Insurance Amount"; Rec."Insurance Amount")
                    {
                        Caption = 'Insurance Amount';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the insurance amount.';
                    }
                    field("Insured Value"; Rec."Insured Value")
                    {
                        Caption = 'Insured Value';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the insured value.';
                    }
                    field("Claim Url"; Rec."Claim Url")
                    {
                        Caption = 'Claim Url';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the claim link.';
                    }
                    field("Policy Url"; Rec."Policy Url")
                    {
                        Caption = 'Policy Url';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the policy link.';
                    }
                }
            }
        }

        area(factboxes)
        {
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24
            part("IDYS Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(11147669), "No." = field("No.");
            }
#else
            part("IDYS Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(11147669), "No." = field("No.");
                ObsoleteReason = 'The "Document Attachment FactBox" has been replaced by "Doc. Attachment List Factbox", which supports multiple files upload.';
                ObsoleteState = Pending;
                ObsoleteTag = '25.0';
            }
            part("IDYS Attached Documents List"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                UpdatePropagation = Both;
                SubPageLink = "Table ID" = const(11147669), "No." = field("No.");
            }
#endif
            part("IDYS Map Part"; "IDYS Map Part")
            {
                Caption = 'Delivery Route';
                SubPageLink = "No." = field("No.");
                ApplicationArea = All;
                Visible = MapVisible;
            }

            part("IDYS Transport Order Part"; "IDYS Transport Order Part")
            {
                Caption = 'External Details';
                SubPageLink = "No." = field("No.");
                ApplicationArea = All;
            }
            #region [Sendcloud]
            part("IDYSC Parcel Errors"; "IDYS SC Parcel Errors")
            {
                ApplicationArea = All;
                Provider = Packages;
                Visible = IsSendcloud;
                SubPageLink = "Transport Order No." = field("Transport Order No."), "Parcel Identifier" = field("Parcel Identifier");
            }
            #endregion

            part("IDYS Transport Order Pck. FB"; "IDYS Transport Order Pck. FB")
            {
                Caption = 'Package Details';
                SubPageLink = "Transport Order No." = field("No.");
                ApplicationArea = All;
            }
            part("IDYSC Parcel Documents"; "IDYS SC Parcel Documents")
            {
                ApplicationArea = All;
                Provider = Packages;
                Visible = IsSendcloud or IsnShiftShip or IsEasyPost or IsTranssmart;
                SubPageLink = "Transport Order No." = field("Transport Order No."), "Parcel Identifier" = field("Parcel Identifier");
            }
            part(Log; "IDYS Transport Order Log Part")
            {
                Caption = 'Log';
                SubPageLink = "Transport Order No." = field("No.");
                SubPageView = sorting("Transport Order No.", "Entry No.")
                              order(Descending);
                ApplicationArea = All;
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Reports)
            {
                Caption = 'Reports';
                RunObject = Page "IDYS Transport Order Reports";
                ToolTip = 'Link this transport order to one or more reports.';
                Image = Link;
                ApplicationArea = All;
            }

            action("Open in Dashboard")
            {
                Caption = 'Open in Dashboard';
                Image = DocInBrowser;
                ToolTip = 'Open this transport order in the provider''s portal.';
                ApplicationArea = All;
                Visible = not IsSendcloud;

                trigger OnAction();
                begin
                    Rec.TestField(Provider);
                    IDYSIProvider := Rec.Provider;
                    IDYSIProvider.OpenInDashboard(Rec);
                end;
            }

            action(Trace)
            {
                Caption = 'Trace';
                Image = Track;
                ToolTip = 'Trace this shipment on the shipping agent''s website.';
                ApplicationArea = All;

                trigger OnAction();
                begin
                    IDYSTransportOrderMgt.Trace(Rec);
                end;
            }
            action(ServiceLevelOther)
            {
                Caption = 'Service Levels (Other)';
                Image = SelectEntries;
                ToolTip = 'Select the Service Levels for the Transport Order';
                ApplicationArea = All;
                Visible = IsnShiftShip;

                trigger OnAction()
                var
                    TransportOrderServices: Page "IDYS Select Service Lvl Other";
                begin
                    TransportOrderServices.SetParameters(Database::"IDYS Transport Order Header", "IDYS Source Document Type"::"0", Rec."No.", Rec."Cntry/Rgn. Code (Pick-up) (TS)", Rec."Cntry/Rgn. Code (Ship-to) (TS)", Rec.SystemId);
                    TransportOrderServices.InitializePage(Rec."Carrier Entry No.", Rec."Booking Profile Entry No.");
                    TransportOrderServices.RunModal();
                end;
            }
        }

        area(Processing)
        {
            action("Carrier Selection")
            {
                Caption = 'Carrier Selection';
                ToolTip = 'Shows a list of all possible carriers and service level combinations, including delivery times and costs.';
                Image = RegisterPick;
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Visible = CarrierSelectionVisible;

                trigger OnAction();
                begin
                    CurrPage.SaveRecord();
                    IDYSTransportOrderMgt.CarrierSelect(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(Book)
            {
                Caption = 'Book';
                Image = RegisterPick;
                ToolTip = 'Book this transport order into the provider''s systems.';
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Visible = BookVisible;
                ShortCutKey = 'F9';

                trigger OnAction();
                begin
                    CurrPage.SaveRecord();
                    IDYSTransportOrderMgt.BookAction(Rec);
                    CurrPage.Update(false);
                end;
            }

            action("Book and Print")
            {
                Caption = 'Book and Print';
                Image = RegisterPick;
                ToolTip = 'Book this transport order into the provider''s systems and print labels and/or documents for it.';
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Visible = BookVisible and PrintingEnabled;

                trigger OnAction();
                begin
                    CurrPage.SaveRecord();
                    IDYSTransportOrderMgt.BookAndPrintAction(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(Synchronize)
            {
                Caption = 'Synchronize';
                Image = Refresh;
                ToolTip = 'Send updates to and receive updates from the provider.';
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Visible = SynchronizeVisible;

                trigger OnAction();
                begin
                    CurrPage.SaveRecord();
                    IDYSTransportOrderMgt.Synchronize(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(Recall)
            {
                Caption = 'Recall';
                Image = ReceiveLoaner;
                ToolTip = 'Request the provider to cancel this transport order.';
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Visible = RecallVisible;

                trigger OnAction();
                begin
                    CurrPage.SaveRecord();
                    IDYSTransportOrderMgt.Recall(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(Reset)
            {
                Caption = 'Reset';
                Image = ResetStatus;
                ToolTip = 'Reset transport order, so that it can be resent.';
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Visible = ResetVisible;

                trigger OnAction()
                var
                    ResetParcelQst: Label 'Are you sure you want to reset the order? All tracking information and packages will be reset.';
                begin
                    if Confirm(ResetParcelQst, false) then begin
                        CurrPage.SaveRecord();
                        IDYSTransportOrderMgt.Reset(Rec);
                        CurrPage.Update(false);
                    end;
                end;
            }

            action(Print)
            {
                Caption = 'Print';
                Image = Print;
                ToolTip = 'Print labels and/or documents for this transport order.';
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Visible = PrintVisible and PrintingEnabled;

                trigger OnAction();
                begin
                    CurrPage.SaveRecord();
                    IDYSTransportOrderMgt.Print(Rec);
                    CurrPage.Update(false);
                end;
            }

            action("Download Label")
            {
                Caption = 'Download Label';
                Image = SendAsPDF;
                ToolTip = 'Download labels and/or documents for this transport order.';
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ObsoleteState = Pending;
                ObsoleteReason = 'All header-level files are now stored in attachments';
                ObsoleteTag = '23.0';
                Visible = false;
                trigger OnAction();
                begin
                    ;
                end;
            }

            action(Archive)
            {
                Caption = 'Archive';
                Image = RegisteredDocs;
                ToolTip = 'Archive this transport order.';
                ApplicationArea = All;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                Visible = ArchiveVisible;

                trigger OnAction();
                begin
                    CurrPage.SaveRecord();
                    IDYSTransportOrderMgt.Archive(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(Unarchive)
            {
                Caption = 'Unarchive';
                Image = RegisteredDocs;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif
                ToolTip = 'Move this order back to the transport order list.';
                ApplicationArea = All;
                Visible = UnarchiveVisible;

                trigger OnAction();
                begin
                    CurrPage.SaveRecord();
                    IDYSTransportOrderMgt.Unarchive(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("Carrier Selection_Promoted"; "Carrier Selection")
                {
                }
                actionref(Book_Promoted; Book)
                {
                }
                actionref("Book and Print_Promoted"; "Book and Print")
                {
                }
                actionref(Synchronize_Promoted; Synchronize)
                {
                }
                actionref(Recall_Promoted; Recall)
                {
                }
                actionref(Reset_Promoted; Reset)
                {
                }
                actionref(Print_Promoted; Print)
                {
                }
#pragma warning disable AL0432
                actionref("Download Label_Promoted"; "Download Label")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'All header-level files are now stored in attachments';
                    ObsoleteTag = '23.0';
                    Visible = false;
                }
#pragma warning restore AL0432
                actionref(Archive_Promoted; Archive)
                {
                }
                actionref(Unarchive_Promoted; Unarchive)
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
            }
            group(Category_Category4)
            {
                Caption = 'Transport Order', Comment = 'Generated from the PromotedActionCategories property index 3.';
            }
        }
#endif
    }

    trigger OnOpenPage()
    begin
        LoadSetup();
        MapVisible := IDYSSetup."Bing API Key" <> '';
    end;

    trigger OnAfterGetRecord();
    begin
        Rec.CalcFields("Actor Id", "Carrier Name", "Booking Profile Description");

        CurrPage.Editable := Rec.AllowEditing();
        FieldsEditable := Rec.AllowEditing();
        SetNoAndCodeEnabled("IDYS Address Type"::"Pick-up");
        SetNoAndCodeEnabled("IDYS Address Type"::"Ship-to");
        SetNoAndCodeEnabled("IDYS Address Type"::Invoice);
        IncludeInvoiceAddress := true;
        PrintVisible := Rec.Status in [Rec.Status::Booked, Rec.Status::"Label Printed"];
        BookVisible := Rec.Status in [Rec.Status::New];
        RecallVisible := not (Rec.Status in [Rec.Status::Done, Rec.Status::New]);
        ResetVisible := (not (Rec.Status in [Rec.Status::New]));
        UnarchiveVisible := Rec.Status = Rec.Status::Archived;
        ArchiveVisible := Rec.Status <> Rec.Status::Archived;
        CarrierSelectionVisible := Rec.Status in [Rec.Status::New];
        BackgroundBookingVisible := Rec."Booking Method" = Rec."Booking Method"::Background;
        SynchronizeVisible := Rec.Status in [Rec.Status::Booked, Rec.Status::"Label Printed", Rec.Status::"On Hold", Rec.Status::Uploaded];
        ProviderEditable := Rec.Status in [Rec.Status::New];
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        LabelFormatEditable := SynchronizeVisible;
#else
        LabelFormatEditable := (Rec.Status in [Rec.Status::New, Rec.Status::Recalled]);
#endif

        IsSendcloud := IDYSProviderMgt.IsProvider(Enum::"IDYS Provider"::Sendcloud, Rec);
        IsnShiftShip := IDYSProviderMgt.IsProvider(Enum::"IDYS Provider"::"Delivery Hub", Rec);
        IsTranssmart := IDYSProviderMgt.IsProvider(Enum::"IDYS Provider"::Transsmart, Rec);
        IsEasyPost := IDYSProviderMgt.IsProvider(Enum::"IDYS Provider"::EasyPost, Rec);
        IsCargoson := IDYSProviderMgt.IsProvider(Enum::"IDYS Provider"::Cargoson, Rec);
        IDYSInsuranceEnabled := IDYSProviderMgt.IsInsuranceEnabled(Rec.Provider);

        IDYSProviderSetup.GetProviderSetup(Rec.Provider);
        if Rec.Provider in [Rec.Provider::EasyPost, Rec.Provider::Sendcloud] then
            PrintingEnabled := IDYSProviderSetup."Enable PrintIT Printing"
        else
            PrintingEnabled := true;

        SetOpenService();
        CurrPage.Packages.Page.SetProvider(Rec.Provider);
        CurrPage."IDYS Transport Order Del. Sub.".Page.SetProvider(Rec.Provider);
        CurrPage."IDYS Transport Order Pck. FB".Page.SetProviderForSourceDocPckFactbox(Rec.Provider);
        CurrPage."IDYS Transport Order Pck. FB".Page.Refresh(Rec."No.");

        OverwriteVisibilities();
        SetStyle();
        SetMandatoryFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        CurrPage.Editable := Rec.AllowEditing();
        FieldsEditable := Rec.AllowEditing();
        ProviderEditable := Rec.AllowEditing();
        SetNoAndCodeEnabled("IDYS Address Type"::"Pick-up");
        SetNoAndCodeEnabled("IDYS Address Type"::"Ship-to");
        SetNoAndCodeEnabled("IDYS Address Type"::Invoice);
    end;

    local procedure SetOpenService()
    begin
        Rec.CalcFields("No. of Selected Services");
        if Rec."No. of Selected Services" > 0 then
            OpenService := StrSubstNo(ChangeServicesLbl, Rec."No. of Selected Services")
        else
            OpenService := OpenServicesLbl;
    end;

    local procedure SetNoAndCodeEnabled(IDYSAddressType: Enum "IDYS Address Type")
    begin
        case IDYSAddressType of
            IDYSAddressType::"Pick-up":
                begin
                    NoPickUpEnabled := Rec."Source Type (Pick-up)" in [Rec."Source Type (Pick-up)"::Customer, Rec."Source Type (Pick-up)"::Vendor, Rec."Source Type (Pick-up)"::Location];
                    if Rec."Source Type (Pick-up)" in [Rec."Source Type (Pick-up)"::Location, Rec."Source Type (Pick-up)"::Company] then
                        CodePickUpEnabled := false
                    else
                        CodePickUpEnabled := Rec."No. (Pick-up)" <> '';
                end;
            IDYSAddressType::"Ship-to":
                begin
                    NoShipToEnabled := Rec."Source Type (Ship-to)" in [Rec."Source Type (Ship-to)"::Customer, Rec."Source Type (Ship-to)"::Vendor, Rec."Source Type (Ship-to)"::Location];
                    if Rec."Source Type (Ship-to)" in [Rec."Source Type (Ship-to)"::Location, Rec."Source Type (Ship-to)"::Company] then
                        CodeShipToEnabled := false
                    else
                        CodeShipToEnabled := Rec."No. (Ship-to)" <> '';
                end;
            IDYSAddressType::Invoice:
                NoInvoiceEnabled := Rec."Source Type (Invoice)" = Rec."Source Type (Invoice)"::Customer;
        end;
    end;

    local procedure SetStyle()
    var
        IDYSFieldSetup: Record "IDYS Field Setup";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        IDYSSetup.Get();
        if IDYSShipAgentMapping.Get(Rec."Shipping Agent Code") then begin
            // Ship-to
            NameShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Name (Ship-to)"), Strlen(Rec."Name (Ship-to)"));
            AddressShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Address (Ship-to)"), Strlen(Rec."Address (Ship-to)"));
            StreetShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Street (Ship-to)"), Strlen(Rec."Street (Ship-to)"));
            HouseNoShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("House No. (Ship-to)"), Strlen(Rec."House No. (Ship-to)"));
            Address2ShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Address 2 (Ship-to)"), Strlen(Rec."Address 2 (Ship-to)"));
            PostCodeShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Post Code (Ship-to)"), Strlen(Rec."Post Code (Ship-to)"));
            CityShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("City (Ship-to)"), Strlen(Rec."City (Ship-to)"));
            CountyShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("County (Ship-to)"), Strlen(Rec."County (Ship-to)"));
            CountryRegionCodeShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Country/Region Code (Ship-to)"), Strlen(Rec."Country/Region Code (Ship-to)"));
            ContactShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Contact (Ship-to)"), Strlen(Rec."Contact (Ship-to)"));
            PhoneNoShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Phone No. (Ship-to)"), Strlen(Rec."Phone No. (Ship-to)"));
            MobPhoneNoShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Mobile Phone No. (Ship-to)"), Strlen(Rec."Mobile Phone No. (Ship-to)"));
            FaxNoShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Fax No. (Ship-to)"), Strlen(Rec."Fax No. (Ship-to)"));
            EmailShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("E-mail (Ship-to)"), Strlen(Rec."E-mail (Ship-to)"));
            VATRegNoShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("VAT Registration No. (Ship-to)"), Strlen(Rec."VAT Registration No. (Ship-to)"));
            EORINumberShipToStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("EORI Number (Ship-to)"), Strlen(Rec."EORI Number (Ship-to)"));

            // Invoice
            NameInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Name (Invoice)"), Strlen(Rec."Name (Invoice)"));
            AddressInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Address (Invoice)"), Strlen(Rec."Address (Invoice)"));
            StreetInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Street (Invoice)"), Strlen(Rec."Street (Invoice)"));
            HouseNoInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("House No. (Invoice)"), Strlen(Rec."House No. (Invoice)"));
            Address2InvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Address 2 (Invoice)"), Strlen(Rec."Address 2 (Invoice)"));
            PostCodeInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Post Code (Invoice)"), Strlen(Rec."Post Code (Invoice)"));
            CityInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("City (Invoice)"), Strlen(Rec."City (Invoice)"));
            CountyInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("County (Invoice)"), Strlen(Rec."County (Invoice)"));
            CountryRegionCodeInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Country/Region Code (Invoice)"), Strlen(Rec."Country/Region Code (Invoice)"));
            ContactInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Contact (Invoice)"), Strlen(Rec."Contact (Invoice)"));
            PhoneNoInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Phone No. (Invoice)"), Strlen(Rec."Phone No. (Invoice)"));
            MobPhoneNoInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Mobile Phone No. (Invoice)"), Strlen(Rec."Mobile Phone No. (Invoice)"));
            FaxNoInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Fax No. (Invoice)"), Strlen(Rec."Fax No. (Invoice)"));
            EmailInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("E-mail (Invoice)"), Strlen(Rec."E-mail (Invoice)"));
            VATRegNoInvoiceStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("VAT Registration No. (Invoice)"), Strlen(Rec."VAT Registration No. (Invoice)"));

            // Pick-up
            NamePickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Name (Pick-up)"), Strlen(Rec."Name (Pick-up)"));
            AddressPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Address (Pick-up)"), Strlen(Rec."Address (Pick-up)"));
            StreetPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Street (Pick-up)"), Strlen(Rec."Street (Pick-up)"));
            HouseNoPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("House No. (Pick-up)"), Strlen(Rec."House No. (Pick-up)"));
            Address2PickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Address 2 (Pick-up)"), Strlen(Rec."Address 2 (Pick-up)"));
            PostCodePickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Post Code (Pick-up)"), Strlen(Rec."Post Code (Pick-up)"));
            CityPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("City (Pick-up)"), Strlen(Rec."City (Pick-up)"));
            CountyPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("County (Pick-up)"), Strlen(Rec."County (Pick-up)"));
            CountryRegionCodePickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Country/Region Code (Pick-up)"), Strlen(Rec."Country/Region Code (Pick-up)"));
            ContactPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Contact (Pick-up)"), Strlen(Rec."Contact (Pick-up)"));
            PhoneNoPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Phone No. (Pick-up)"), Strlen(Rec."Phone No. (Pick-up)"));
            MobPhoneNoPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Mobile Phone No. (Pick-up)"), Strlen(Rec."Mobile Phone No. (Pick-up)"));
            FaxNoPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Fax No. (Pick-up)"), Strlen(Rec."Fax No. (Pick-up)"));
            EmailPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("E-mail (Pick-up)"), Strlen(Rec."E-mail (Pick-up)"));
            VATRegNoPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("VAT Registration No. (Pick-up)"), Strlen(Rec."VAT Registration No. (Pick-up)"));
            EORINumberPickUpStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("EORI Number (Pick-up)"), Strlen(Rec."EORI Number (Pick-up)"));

            // Additional references
            InvoiceRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Invoice (Ref)"), Strlen(Rec."Invoice (Ref)"));
            CustOrderReftyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Customer Order (Ref)"), Strlen(Rec."Customer Order (Ref)"));
            OrderNoRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Order No. (Ref)"), Strlen(Rec."Order No. (Ref)"));
            DeliveryNoteRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Delivery Note (Ref)"), Strlen(Rec."Delivery Note (Ref)"));
            DeliveryIdRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Delivery Id (Ref)"), Strlen(Rec."Delivery Id (Ref)"));
            OtherRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Other (Ref)"), Strlen(Rec."Other (Ref)"));
            ServicePointRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Service Point (Ref)"), Strlen(Rec."Service Point (Ref)"));
            ProjectRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Project (Ref)"), Strlen(Rec."Project (Ref)"));
            YourReferenceRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Your Reference (Ref)"), Strlen(Rec."Your Reference (Ref)"));
            EngineerRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Engineer (Ref)"), Strlen(Rec."Engineer (Ref)"));
            CustomerRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Customer (Ref)"), Strlen(Rec."Customer (Ref)"));
            AgentRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Agent (Ref)"), Strlen(Rec."Agent (Ref)"));
            DriverIdRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Driver ID (Ref)"), Strlen(Rec."Driver ID (Ref)"));
            RouteIdRefStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Route ID (Ref)"), Strlen(Rec."Route ID (Ref)"));
            InstructionStyleExpr := IDYSFieldSetup.GetStyleExpr(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", Rec.FieldNo("Instruction"), Strlen(Rec."Instruction"));
        end;
    end;

    local procedure SetMandatoryFields()
    var
        IDYSFieldSetup: Record "IDYS Field Setup";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        IDYSSetup.Get();
        if IDYSShipAgentMapping.Get(Rec."Shipping Agent Code") then begin
            // Ship-to
            CountyShipToMandatory := IsMandatory(Rec.FieldNo("County (Ship-to)"));
            CountryRegionCodeShipToMandatory := IsMandatory(Rec.FieldNo("Country/Region Code (Ship-to)"));
            ContactShipToMandatory := IsMandatory(Rec.FieldNo("Contact (Ship-to)"));
            MobPhoneNoShipToMandatory := IsMandatory(Rec.FieldNo("Mobile Phone No. (Ship-to)"));
            FaxNoShipToMandatory := IsMandatory(Rec.FieldNo("Fax No. (Ship-to)"));
            EmailShipToMandatory := IsMandatory(Rec.FieldNo("E-mail (Ship-to)"));
            VATRegNoShipToMandatory := IsMandatory(Rec.FieldNo("VAT Registration No. (Ship-to)"));
            EORINumberShipToMandatory := IsMandatory(Rec.FieldNo("EORI Number (Ship-to)"));

            // Invoice
            CountyInvoiceMandatory := IsMandatory(Rec.FieldNo("County (Invoice)"));
            CountryRegionCodeInvoiceMandatory := IsMandatory(Rec.FieldNo("Country/Region Code (Invoice)"));
            ContactInvoiceMandatory := IsMandatory(Rec.FieldNo("Contact (Invoice)"));
            PhoneNoInvoiceMandatory := IsMandatory(Rec.FieldNo("Phone No. (Invoice)"));
            MobPhoneNoInvoiceMandatory := IsMandatory(Rec.FieldNo("Mobile Phone No. (Invoice)"));
            FaxNoInvoiceMandatory := IsMandatory(Rec.FieldNo("Fax No. (Invoice)"));
            EmailInvoiceMandatory := IsMandatory(Rec.FieldNo("E-mail (Invoice)"));
            VATRegNoInvoiceMandatory := IsMandatory(Rec.FieldNo("VAT Registration No. (Invoice)"));

            // Pick-up
            CountyPickUpMandatory := IsMandatory(Rec.FieldNo("County (Pick-up)"));
            CountryRegionCodePickUpMandatory := IsMandatory(Rec.FieldNo("Country/Region Code (Pick-up)"));
            ContactPickUpMandatory := IsMandatory(Rec.FieldNo("Contact (Pick-up)"));
            MobPhoneNoPickUpMandatory := IsMandatory(Rec.FieldNo("Mobile Phone No. (Pick-up)"));
            FaxNoPickUpMandatory := IsMandatory(Rec.FieldNo("Fax No. (Pick-up)"));
            EmailPickUpMandatory := IsMandatory(Rec.FieldNo("E-mail (Pick-up)"));
            VATRegNoPickUpMandatory := IsMandatory(Rec.FieldNo("VAT Registration No. (Pick-up)"));
            EORINumberPickUpMandatory := IsMandatory(Rec.FieldNo("EORI Number (Pick-up)"));

            // Additional references
            InvoiceRefMandatory := IsMandatory(Rec.FieldNo("Invoice (Ref)"));
            OrderNoRefMandatory := IsMandatory(Rec.FieldNo("Order No. (Ref)"));
            DeliveryNoteRefMandatory := IsMandatory(Rec.FieldNo("Delivery Note (Ref)"));
            DeliveryIdRefMandatory := IsMandatory(Rec.FieldNo("Delivery Id (Ref)"));
            OtherRefMandatory := IsMandatory(Rec.FieldNo("Other (Ref)"));
            ServicePointRefMandatory := IsMandatory(Rec.FieldNo("Service Point (Ref)"));
            ProjectRefMandatory := IsMandatory(Rec.FieldNo("Project (Ref)"));
            YourReferenceRefMandatory := IsMandatory(Rec.FieldNo("Your Reference (Ref)"));
            EngineerRefMandatory := IsMandatory(Rec.FieldNo("Engineer (Ref)"));
            CustomerRefMandatory := IsMandatory(Rec.FieldNo("Customer (Ref)"));
            AgentRefMandatory := IsMandatory(Rec.FieldNo("Agent (Ref)"));
            DriverIdRefMandatory := IsMandatory(Rec.FieldNo("Driver ID (Ref)"));
            RouteIdRefMandatory := IsMandatory(Rec.FieldNo("Route ID (Ref)"));
            InstructionMandatory := IsMandatory(Rec.FieldNo("Instruction"));
        end;
    end;

    local procedure IsMandatory(FieldNo: Integer): Boolean
    var
        IDYSFieldSetup: Record "IDYS Field Setup";
        IDYSShipAgentMapping: Record "IDYS Ship. Agent Mapping";
    begin
        IDYSSetup.Get();
        if IDYSShipAgentMapping.Get(Rec."Shipping Agent Code") then
            if IDYSFieldSetup.FindFieldSetup(IDYSShipAgentMapping.RecordId, Database::"IDYS Transport Order Header", FieldNo) then
                exit(IDYSFieldSetup.Mandatory);
        exit(false);
    end;

    local procedure OverwriteVisibilities()
    begin
        // Overwrite default behaviour
        Clear(StatusStyleExpr);

        case true of
            IsSendcloud:
                begin
                    if Rec.Status = Rec.Status::Recalled then begin
                        CurrPage.Editable := false;
                        FieldsEditable := false;
                        BookVisible := false;
                        CarrierSelectionVisible := false;
                        RecallVisible := false;
                    end;
                    if Rec.Status = Rec.Status::Booked then
                        if Rec."Booked with Error" then
                            StatusStyleExpr := "IDYS Style Expression".Names().Get("IDYS Style Expression".Ordinals().IndexOf("IDYS Style Expression"::Attention.AsInteger()));
                end;
            IsCargoson:
                begin
                    if Rec."Booked with Error" then begin
                        StatusStyleExpr := "IDYS Style Expression".Names().Get("IDYS Style Expression".Ordinals().IndexOf("IDYS Style Expression"::Attention.AsInteger()));
                        BookVisible := true;
                        CarrierSelectionVisible := false;
                    end;
                    IncludeInvoiceAddress := Rec."Include Invoice Address";
                end;
            IsEasyPost:
                RecallVisible := false;
        end;
    end;

    local procedure LoadSetup()
    begin
        if not SetupLoaded then begin
            SetupLoaded := true;
            if not IDYSSetup.Get() then
                IDYSSetup.Init();
        end;
    end;

    var
        IDYSSetup: Record "IDYS Setup";
        IDYSProviderSetup: Record "IDYS Setup";
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IDYSIProvider: Interface "IDYS IProvider";
        OpenService: Text;
        StatusStyleExpr: Text;
        FieldsEditable: Boolean;
        ProviderEditable: Boolean;
        LabelFormatEditable: Boolean;
        ResetVisible: Boolean;
        PrintVisible: Boolean;
        BookVisible: Boolean;
        RecallVisible: Boolean;
        SynchronizeVisible: Boolean;
        UnarchiveVisible: Boolean;
        ArchiveVisible: Boolean;
        MapVisible: Boolean;
        CarrierSelectionVisible: Boolean;
        BackgroundBookingVisible: Boolean;
        SetupLoaded: Boolean;
        IsSendcloud: Boolean;
        IsnShiftShip: Boolean;
        IsTranssmart: Boolean;
        IsCargoson: Boolean;
        IsEasyPost: Boolean;
        IDYSInsuranceEnabled: Boolean;
        PrintingEnabled: Boolean;
        IncludeInvoiceAddress: Boolean;
        OpenServicesLbl: Label 'Click here to select the service levels for this transport order.';
        ChangeServicesLbl: Label '%1 service(s) selected. Click here to view or change the services.', Comment = '%1 = No. of services activated';

    protected var
        NoPickUpEnabled: Boolean;
        CodePickUpEnabled: Boolean;
        NoShipToEnabled: Boolean;
        CodeShipToEnabled: Boolean;
        NoInvoiceEnabled: Boolean;
        // Ship-to
        NameShipToStyleExpr: Text;
        AddressShipToStyleExpr: Text;
        StreetShipToStyleExpr: Text;
        HouseNoShipToStyleExpr: Text;
        Address2ShipToStyleExpr: Text;
        PostCodeShipToStyleExpr: Text;
        CityShipToStyleExpr: Text;
        CountyShipToStyleExpr: Text;
        CountryRegionCodeShipToStyleExpr: Text;
        ContactShipToStyleExpr: Text;
        PhoneNoShipToStyleExpr: Text;
        MobPhoneNoShipToStyleExpr: Text;
        FaxNoShipToStyleExpr: Text;
        EmailShipToStyleExpr: Text;
        VATRegNoShipToStyleExpr: Text;
        EORINumberShipToStyleExpr: Text;
        // Invoice
        NameInvoiceStyleExpr: Text;
        AddressInvoiceStyleExpr: Text;
        StreetInvoiceStyleExpr: Text;
        HouseNoInvoiceStyleExpr: Text;
        Address2InvoiceStyleExpr: Text;
        PostCodeInvoiceStyleExpr: Text;
        CityInvoiceStyleExpr: Text;
        CountyInvoiceStyleExpr: Text;
        CountryRegionCodeInvoiceStyleExpr: Text;
        ContactInvoiceStyleExpr: Text;
        PhoneNoInvoiceStyleExpr: Text;
        MobPhoneNoInvoiceStyleExpr: Text;
        FaxNoInvoiceStyleExpr: Text;
        EmailInvoiceStyleExpr: Text;
        VATRegNoInvoiceStyleExpr: Text;
        // Pick-up
        NamePickUpStyleExpr: Text;
        AddressPickUpStyleExpr: Text;
        StreetPickUpStyleExpr: Text;
        HouseNoPickUpStyleExpr: Text;
        Address2PickUpStyleExpr: Text;
        PostCodePickUpStyleExpr: Text;
        CityPickUpStyleExpr: Text;
        CountyPickUpStyleExpr: Text;
        CountryRegionCodePickUpStyleExpr: Text;
        ContactPickUpStyleExpr: Text;
        PhoneNoPickUpStyleExpr: Text;
        MobPhoneNoPickUpStyleExpr: Text;
        FaxNoPickUpStyleExpr: Text;
        EmailPickUpStyleExpr: Text;
        VATRegNoPickUpStyleExpr: Text;
        EORINumberPickUpStyleExpr: Text;
        //Additional References
        InvoiceRefStyleExpr: Text;
        CustOrderReftyleExpr: Text;
        OrderNoRefStyleExpr: Text;
        DeliveryNoteRefStyleExpr: Text;
        DeliveryIdRefStyleExpr: Text;
        OtherRefStyleExpr: Text;
        ServicePointRefStyleExpr: Text;
        ProjectRefStyleExpr: Text;
        YourReferenceRefStyleExpr: Text;
        EngineerRefStyleExpr: Text;
        CustomerRefStyleExpr: Text;
        AgentRefStyleExpr: Text;
        DriverIdRefStyleExpr: Text;
        RouteIdRefStyleExpr: Text;
        InstructionStyleExpr: Text;

        // Ship-to
        CountyShipToMandatory: Boolean;
        CountryRegionCodeShipToMandatory: Boolean;
        ContactShipToMandatory: Boolean;
        MobPhoneNoShipToMandatory: Boolean;
        FaxNoShipToMandatory: Boolean;
        EmailShipToMandatory: Boolean;
        VATRegNoShipToMandatory: Boolean;
        EORINumberShipToMandatory: Boolean;
        // Invoice
        CountyInvoiceMandatory: Boolean;
        CountryRegionCodeInvoiceMandatory: Boolean;
        ContactInvoiceMandatory: Boolean;
        PhoneNoInvoiceMandatory: Boolean;
        MobPhoneNoInvoiceMandatory: Boolean;
        FaxNoInvoiceMandatory: Boolean;
        EmailInvoiceMandatory: Boolean;
        VATRegNoInvoiceMandatory: Boolean;
        // Pick-up
        CountyPickUpMandatory: Boolean;
        CountryRegionCodePickUpMandatory: Boolean;
        ContactPickUpMandatory: Boolean;
        MobPhoneNoPickUpMandatory: Boolean;
        FaxNoPickUpMandatory: Boolean;
        EmailPickUpMandatory: Boolean;
        VATRegNoPickUpMandatory: Boolean;
        EORINumberPickUpMandatory: Boolean;
        //Additional References
        InvoiceRefMandatory: Boolean;
        OrderNoRefMandatory: Boolean;
        DeliveryNoteRefMandatory: Boolean;
        DeliveryIdRefMandatory: Boolean;
        OtherRefMandatory: Boolean;
        ServicePointRefMandatory: Boolean;
        ProjectRefMandatory: Boolean;
        YourReferenceRefMandatory: Boolean;
        EngineerRefMandatory: Boolean;
        CustomerRefMandatory: Boolean;
        AgentRefMandatory: Boolean;
        DriverIdRefMandatory: Boolean;
        RouteIdRefMandatory: Boolean;
        InstructionMandatory: Boolean;
#if BC17
#pragma warning restore AL0604
#endif
}