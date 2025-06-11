page 11147743 "IDYS Transport Order Pck. FB"
{
    PageType = ListPart;
    SourceTable = "IDYS Transport Order Package";
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
                    CaptionClass = IDYSProviderMgt.GetMeasurementCaption(Rec.FieldCaption(Volume), VolumeCaption);
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        TotalWeight := 0;
        TotalVolume := 0;

        IDYSTransportOrderPackage.SetRange("Transport Order No.", Rec."Transport Order No.");
        if UseBookingProfilePackageTypeCode then
            IDYSTransportOrderPackage.SetRange("Book. Prof. Package Type Code", Rec."Book. Prof. Package Type Code")
        else
            IDYSTransportOrderPackage.SetRange("Provider Package Type Code", Rec."Provider Package Type Code");

        PackageQuantity := IDYSTransportOrderPackage.Count();
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                TotalWeight += IDYSTransportOrderPackage.GetCalculatedWeight();
                TotalVolume += IDYSTransportOrderPackage.Volume;
            until IDYSTransportOrderPackage.Next() = 0;
    end;

    procedure Refresh(SourceDocNo: Code[20])
    var
        IDYSTransportOrderPackage: Record "IDYS Transport Order Package";
    begin
        ClearBuffer();

        if UseBookingProfilePackageTypeCode then
            IDYSTransportOrderPackage.SetCurrentKey("Book. Prof. Package Type Code")
        else
            IDYSTransportOrderPackage.SetCurrentKey("Provider Package Type Code");

        IDYSTransportOrderPackage.SetRange("Transport Order No.", SourceDocNo);
        if IDYSTransportOrderPackage.FindSet() then
            repeat
                if UseBookingProfilePackageTypeCode then
                    IDYSTransportOrderPackage.SetRange("Book. Prof. Package Type Code", IDYSTransportOrderPackage."Book. Prof. Package Type Code")
                else
                    IDYSTransportOrderPackage.SetRange("Provider Package Type Code", IDYSTransportOrderPackage."Provider Package Type Code");

                Rec.Init();
                Rec := IDYSTransportOrderPackage;
                Rec.Insert();

                IDYSTransportOrderPackage.Findlast();
                if UseBookingProfilePackageTypeCode then
                    IDYSTransportOrderPackage.SetRange("Book. Prof. Package Type Code")
                else
                    IDYSTransportOrderPackage.SetRange("Provider Package Type Code");
            until IDYSTransportOrderPackage.Next() = 0;
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
        TempTransportOrderPackage: Record "IDYS Transport Order Package" temporary;
    begin
        Rec.FilterGroup(4);

        TempTransportOrderPackage.Copy(Rec, true);
        TempTransportOrderPackage.Reset();
        TempTransportOrderPackage.DeleteAll();

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