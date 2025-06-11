page 11147694 "IDYS ShipIT Explained Act."
{
    PageType = CardPart;
    UsageCategory = None;
    Caption = 'Getting Started';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            cuegroup(GettingStarted)
            {
                Caption = 'ShipIT 365';
                actions
                {
                    action(ShipITIntroduction)
                    {
                        ApplicationArea = All;
                        Caption = 'ShipIT 365 Introduction';
                        ToolTip = 'Click this tile to watch the introduction for ShipIT 365.';
                        //Visible = not ShipIT365IntroWatched;
                        Image = TileVideo;
                        trigger OnAction()
                        begin
                            VideoManagement.PlayVideo(EmbeddedVideo::Introduction);
                        end;
                    }
                    action(ShipITServicesAndPrices)
                    {
                        ApplicationArea = All;
                        Caption = 'Demo';
                        ToolTip = 'Click this tile to watch a video that explains the offered services in ShipIT 365.';
                        //Visible = not ShipIT365ServicesAndPricesWatched;
                        Image = TileVideo;
                        trigger OnAction()
                        begin
                            VideoManagement.PlayVideo(EmbeddedVideo::ServicesAndPrices);
                        end;
                    }
                    action(ShipITHelp)
                    {
                        ApplicationArea = All;
                        Caption = 'ShipIT 365 Help';
                        ToolTip = 'Click this tile to open the ShipIT 365 help documentation.';
                        Image = TileHelp;

                        trigger OnAction()
                        begin
                            System.Hyperlink('https://idyn.atlassian.net/wiki/spaces/S365M/pages/22151185/Introduction');
                        end;
                    }
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action(ReEnableAllVideos)
    //         {
    //             ApplicationArea = All;
    //             Caption = 'Reset all video''s to unwatched';
    //             ToolTip = 'Makes all the previously watched videos available again on the role center.';
    //             Image = Restore;
    //             trigger OnAction()
    //             var
    //                 VideoProgressbyUser: Record "IDYS Video Progress by User";
    //             begin
    //                 VideoProgressbyUser.SetRange("User ID", UserId());
    //                 VideoProgressbyUser.ModifyAll(Watched, false, true);
    //                 DetermineVideoVisibility();
    //                 CurrPage.Update();
    //             end;
    //         }
    //     }
    // }

    var
        VideoManagement: Codeunit "IDYS Video Management";
        EmbeddedVideo: Enum "IDYS Embedded Video";

    trigger OnOpenPage()
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        DetermineVideoVisibility();
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
    end;

    local procedure DetermineVideoVisibility()
    // var
    //     IDYSVideoProgressbyUser: Record "IDYS Video Progress by User";
    begin
        // ShipIT365IntroWatched := false;
        // ShipIT365ServicesAndPricesWatched := false;

        // if IDYSVideoProgressbyUser.Get(UserId(), EmbeddedVideo::Introduction) then
        //     ShipIT365IntroWatched := IDYSVideoProgressbyUser.Watched;

        // if IDYSVideoProgressbyUser.Get(UserId(), EmbeddedVideo::ServicesAndPrices) then
        //     ShipIT365ServicesAndPricesWatched := IDYSVideoProgressbyUser.Watched;        
    end;
}