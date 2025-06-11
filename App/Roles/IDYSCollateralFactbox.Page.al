page 11147695 "IDYS Collateral Factbox"
{
    PageType = CardPart;
    Caption = 'Getting Started';
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(VideoGroup)
            {
                ShowCaption = false;
                cuegroup(Video)
                {
                    Caption = 'Video tutorials';
                    actions
                    {
                        action(ShipITIntroduction)
                        {
                            ApplicationArea = All;
                            Caption = 'Introduction to ShipIT 365';
                            ToolTip = 'Click this tile to watch the introduction for ShipIT 365.';
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
                            ToolTip = 'Click here to watch a video that explains the ShipIT365 functionality.';
                            Image = TileVideo;
                            trigger OnAction()
                            begin
                                VideoManagement.PlayVideo(EmbeddedVideo::ServicesAndPrices);
                            end;
                        }
                    }
                }
            }
            group(HelpGroup)
            {
                ShowCaption = false;
                cuegroup(Help)
                {
                    Caption = 'Documentation';
                    actions
                    {
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
    }

    var
        VideoManagement: Codeunit "IDYS Video Management";
        EmbeddedVideo: Enum "IDYS Embedded Video";
}