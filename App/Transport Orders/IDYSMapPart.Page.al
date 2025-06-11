page 11147662 "IDYS Map Part"
{
    PageType = CardPart;
    SourceTable = "IDYS Transport Order Header";
    Caption = 'Delivery Route';

    layout
    {
        area(Content)
        {
            usercontrol(IDYSMap; "IDYS Map Addin")
            {
                Visible = BingMapsVisible;
                ApplicationArea = All;

                trigger AddinLoaded()
                begin
                    MapIsReady := true;
                    CurrPage.IDYSMap.InitializeMap(GetOrigin(), GetDestination(), IDYSSetup."Bing API Key");
                end;
            }
            usercontrol(IDYSAzureMap; "IDYS Azure Map Addin")
            {
                Visible = AzureMapsVisible;
                ApplicationArea = All;

                trigger AddinLoaded()
                begin
                    MapIsReady := true;
                    CurrPage.IDYSAzureMap.InitializeMap(GetOrigin(), GetDestination(), IDYSSetup."Bing API Key");
                end;
            }
        }
    }

    local procedure ShowRoute();
    begin
        if not MapIsReady then
            exit;

        case IDYSSetup."Map Service Provider" of
            IDYSSetup."Map Service Provider"::"Bing Maps":
                CurrPage.IDYSMap.InitializeMap(GetOrigin(), GetDestination(), IDYSSetup."Bing API Key");
            IDYSSetup."Map Service Provider"::"Azure Maps":
                CurrPage.IDYSAzureMap.InitializeMap(GetOrigin(), GetDestination(), IDYSSetup."Bing API Key");
        end;
    end;

    trigger OnOpenPage()
    begin
        IDYSSetup.Get();

        BingMapsVisible := (IDYSSetup."Map Service Provider" = IDYSSetup."Map Service Provider"::"Bing Maps");
        AzureMapsVisible := (IDYSSetup."Map Service Provider" = IDYSSetup."Map Service Provider"::"Azure Maps");
    end;

    trigger OnAfterGetRecord();
    begin
        ShowRoute();
    end;

    local procedure GetOrigin(): Text
    begin
        exit(DelChr(Rec."Address (Pick-up)" + ' ' + Rec."City (Pick-up)" + ' ' + Rec."Post Code (Pick-up)" + ' ' + Rec."Country/Region Code (Pick-up)", '<>'));
    end;

    local procedure GetDestination(): Text
    begin
        exit(DelChr(Rec."Address (Ship-to)" + ' ' + Rec."City (Ship-to)" + ' ' + Rec."Post Code (Ship-to)" + ' ' + Rec."Country/Region Code (Pick-up)", '<>'));
    end;

    var
        IDYSSetup: Record "IDYS Setup";
        MapIsReady: Boolean;
        BingMapsVisible: Boolean;
        AzureMapsVisible: Boolean;
}