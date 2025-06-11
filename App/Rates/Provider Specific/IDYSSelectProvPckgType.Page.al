page 11147705 "IDYS Select Prov. Pckg. Type"
{
    Caption = 'Default Package Types';
    LinksAllowed = false;
    PageType = List;
    SourceTable = "IDYS Provider Package Entry";
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider for package type.';
                    Editable = false;
                }
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the carrier name.';
                    Editable = false;
                }
                field("Default Package Type Code"; Rec."Package Type Code")
                {
                    Caption = 'Default Package Type Code';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type code.';

                    trigger OnValidate()
                    var
                        BookingProfPackageType: Record "IDYS BookingProf. Package Type";
                        PackageTypeCode: Code[50];
                        NewDefault: Boolean;
                    begin
                        if Rec."Package Type Code" = '' then begin
                            NewDefault := false;
                            PackageTypeCode := xRec."Package Type Code";
                        end else begin
                            NewDefault := true;
                            PackageTypeCode := Rec."Package Type Code";
                        end;

                        BookingProfPackageType.SetRange("Carrier Entry No.", Rec."Carrier Entry No.");
                        BookingProfPackageType.SetRange("Booking Profile Entry No.", Rec."Booking Profile Entry No.");
                        BookingProfPackageType.SetRange("Package Type Code", PackageTypeCode);
                        if not BookingProfPackageType.FindLast() then
                            Error(NotAllowedEntryErr);

                        BookingProfPackageType.Validate(Default, NewDefault);
                        BookingProfPackageType.Modify();
                        CurrPage.Update();
                    end;

                    trigger OnDrillDown()
                    var
                        BookingProfPackageType: Record "IDYS BookingProf. Package Type";
                        CombinedPackageTypes: Page "IDYS Combined Package Types";
                    begin
                        if CombineProviderPackageTypes(Rec.Provider) then
                            Commit();

                        BookingProfPackageType.SetRange(Provider, Rec.Provider);
                        BookingProfPackageType.SetRange("Carrier Entry No.", Rec."Carrier Entry No.");
                        BookingProfPackageType.SetRange("Booking Profile Entry No.", Rec."Booking Profile Entry No.");
                        CombinedPackageTypes.SetTableView(BookingProfPackageType);
                        CombinedPackageTypes.LookupMode(true);
                        if CombinedPackageTypes.Runmodal() = Action::LookupOK then begin
                            CombinedPackageTypes.GetRecord(BookingProfPackageType);
                            Rec."Package Type Code" := BookingProfPackageType."Package Type Code";
                            BookingProfPackageType.Validate(Default, true);
                            BookingProfPackageType.Modify();
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Package Types")
            {
                ApplicationArea = All;
                Caption = 'User-specified Package Types';
                Image = Inventory;
                ToolTip = 'Opens the package types list page.';
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
#endif

                trigger OnAction()
                var
                    IDYSProviderPackageType: Record "IDYS Provider Package Type";
                    IDYSProviderPackageTypes: Page "IDYS Provider Package Types";
                begin
                    IDYSProviderPackageType.SetRange(Provider, IDYSProviderPackageType.Provider::EasyPost);
                    IDYSProviderPackageTypes.SetTableView(IDYSProviderPackageType);
                    IDYSProviderPackageTypes.Run();
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Package Types_Promoted"; "Package Types") { }
            }
        }
#endif
    }


    procedure InitializePage(pProvider: Enum "IDYS Provider")
    var
        ProviderCarrier: Record "IDYS Provider Carrier";
        BookingProfPackageType: Record "IDYS BookingProf. Package Type";
        EntryNo: Integer;
    begin
        // Carrier / Service specific
        ProviderCarrier.SetRange(Provider, pProvider);
        if ProviderCarrier.FindSet() then
            repeat
                Rec.Init();
                EntryNo += 1;
                Rec."Entry No." := EntryNo;
                Rec.Provider := pProvider;
                Rec."Carrier Entry No." := ProviderCarrier."Entry No.";
                Rec."Carrier Name" := ProviderCarrier.Name;

                // Find default
                BookingProfPackageType.SetRange("Carrier Entry No.", ProviderCarrier."Entry No.");
                BookingProfPackageType.SetRange(Default, true);
                if BookingProfPackageType.FindLast() then
                    Rec."Package Type Code" := BookingProfPackageType."Package Type Code";
                Rec.Insert();

            until ProviderCarrier.Next() = 0;

        // Reset the pointer
        if Rec.FindFirst() then;
    end;

    procedure CombineProviderPackageTypes(pProvider: Enum "IDYS Provider") Inserted: Boolean
    var
        ProviderCarrier: Record "IDYS Provider Carrier";
        ProviderPackageType: Record "IDYS Provider Package Type";
        BookingProfPackageType: Record "IDYS BookingProf. Package Type";
    begin
        ProviderPackageType.SetRange(Provider, pProvider);
        if ProviderPackageType.FindSet() then
            repeat
                ProviderCarrier.SetRange(Provider, pProvider);
                if ProviderCarrier.FindSet() then
                    repeat
                        if not BookingProfPackageType.Get(ProviderCarrier."Entry No.", 0, ProviderPackageType.Code) then begin
                            BookingProfPackageType.CalcFields("Carrier Name");
                            BookingProfPackageType.Init();
                            BookingProfPackageType."Carrier Entry No." := ProviderCarrier."Entry No.";
                            BookingProfPackageType."Booking Profile Entry No." := 0;
                            BookingProfPackageType."Package Type Code" := ProviderPackageType.Code;
                            BookingProfPackageType."User Defined" := true;

                            BookingProfPackageType.Description := ProviderPackageType.Description;
                            BookingProfPackageType.Length := ProviderPackageType.Length;
                            BookingProfPackageType.Width := ProviderPackageType.Width;
                            BookingProfPackageType.Height := ProviderPackageType.Height;
                            BookingProfPackageType."Linear UOM" := ProviderPackageType."Linear UOM";
                            BookingProfPackageType."Mass UOM" := ProviderPackageType."Mass UOM";
                            BookingProfPackageType."Special Equipment Code" := ProviderPackageType."Special Equipment Code";
                            BookingProfPackageType.Weight := ProviderPackageType.Weight;
                            BookingProfPackageType.Insert();
                            Inserted := true;
                        end;
                    until ProviderCarrier.Next() = 0;
            until ProviderPackageType.Next() = 0;
    end;

    var
        NotAllowedEntryErr: Label 'Your provided value could not be found. Please use the drilldown to select the value.';
}

