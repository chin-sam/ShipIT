page 11147742 "IDYS Source Doc. Pck. Factbox"
{
    PageType = ListPart;
    SourceTable = "IDYS Source Document Package";
    SourceTableTemporary = true;
    Caption = 'Package Details';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Provider Package Type Code"; Rec."Provider Package Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package type code.';
                }

                field(PackageQuantity; PackageQuantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                    Caption = 'Quantity';
                }

                field(TotalWeight; TotalWeight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total weight.';
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption("Total Weight"), MassCaption);
                }

                field(TotalVolume; TotalVolume)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total volume.';
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption("Total Volume"), VolumeCaption);
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
    begin
        IDYSSourceDocumentPackage.SetRange("Table No.", Rec."Table No.");
        IDYSSourceDocumentPackage.SetRange("Document Type", Rec."Document Type");
        IDYSSourceDocumentPackage.SetRange("Document No.", Rec."Document No.");
        if UseBookingProfilePackageTypeCode then
            IDYSSourceDocumentPackage.SetRange("Book. Prof. Package Type Code", Rec."Book. Prof. Package Type Code")
        else
            IDYSSourceDocumentPackage.SetRange("Provider Package Type Code", Rec."Provider Package Type Code");
        IDYSSourceDocumentPackage.CalcSums(Weight, Volume);

        PackageQuantity := IDYSSourceDocumentPackage.Count();
        TotalWeight := IDYSSourceDocumentPackage.Weight;
        TotalVolume := IDYSSourceDocumentPackage.Volume;
    end;

    procedure Refresh(SourceDocTableNo: Integer; SourceDocType: Integer; SourceDocNo: Code[20])
    var
        IDYSSourceDocumentPackage: Record "IDYS Source Document Package";
    begin
        ClearBuffer();

        if UseBookingProfilePackageTypeCode then
            IDYSSourceDocumentPackage.SetCurrentKey("Book. Prof. Package Type Code")
        else
            IDYSSourceDocumentPackage.SetCurrentKey("Provider Package Type Code");

        IDYSSourceDocumentPackage.SetRange("Table No.", SourceDocTableNo);
        IDYSSourceDocumentPackage.SetRange("Document Type", SourceDocType);
        IDYSSourceDocumentPackage.SetRange("Document No.", SourceDocNo);
        if IDYSSourceDocumentPackage.FindSet() then
            repeat
                if UseBookingProfilePackageTypeCode then
                    IDYSSourceDocumentPackage.SetRange("Book. Prof. Package Type Code", IDYSSourceDocumentPackage."Book. Prof. Package Type Code")
                else
                    IDYSSourceDocumentPackage.SetRange("Provider Package Type Code", IDYSSourceDocumentPackage."Provider Package Type Code");

                Rec.Init();
                Rec := IDYSSourceDocumentPackage;
                Rec.Insert();

                IDYSSourceDocumentPackage.Findlast();
                if UseBookingProfilePackageTypeCode then
                    IDYSSourceDocumentPackage.SetRange("Book. Prof. Package Type Code")
                else
                    IDYSSourceDocumentPackage.SetRange("Provider Package Type Code");
            until IDYSSourceDocumentPackage.Next() = 0;
    end;

    procedure SetProviderForSourceDocPckFactbox(IDYSProvider: Enum "IDYS Provider")
    begin
        IsnShiftShip := IDYSProvider = IDYSProvider::"Delivery Hub";
        IsEasyPost := IDYSProvider = IDYSProvider::EasyPost;

        IDYSProviderMgt.GetMeasurementCaptions(IDYSProvider, DistanceCaption, VolumeCaption, MassCaption);
        UseBookingProfilePackageTypeCode := IsnShiftShip or IsEasyPost;
    end;

    procedure ClearBuffer()
    var
        TempSourceDocumentPackage: Record "IDYS Source Document Package" temporary;
    begin
        Rec.FilterGroup(4);

        TempSourceDocumentPackage.Copy(Rec, true);
        TempSourceDocumentPackage.Reset();
        TempSourceDocumentPackage.DeleteAll();

        Rec.FilterGroup(0);
    end;

    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        IsnShiftShip: Boolean;
        IsEasyPost: Boolean;
        UseBookingProfilePackageTypeCode: Boolean;
        MassCaption: Text;
        DistanceCaption: Text;
        VolumeCaption: Text;
        PackageQuantity: Decimal;
        TotalWeight: Decimal;
        TotalVolume: Decimal;
}