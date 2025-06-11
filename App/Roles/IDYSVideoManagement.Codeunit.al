codeunit 11147690 "IDYS Video Management"
{
    trigger OnRun()
    begin

    end;

    // [EventSubscriber(ObjectType::Page, Page::"IDYS Transport Order Card", 'OnOpenPageEvent', '', true, true)]
    // local procedure TransportOrder_OnOpenPageEvent()
    // var
    //     IDYSEmbeddedVideo: Enum "IDYS Embedded Video";
    // begin
    //     CreateAndSendVideoNotification(IDYSEmbeddedVideo::TransportOrder);
    // end;

    procedure PlayVideo(IDYSEmbeddedVideo: enum "IDYS Embedded Video")
    var
        IDYSVideoProgressbyUser: Record "IDYS Video Progress by User";
        Video: Codeunit Video;
        VideoTitle: Text[250];
        Url: Text[2048];
        MyModuleInfo: ModuleInfo;
    begin
        if not IDYSVideoProgressbyUser.Get(UserId(), IDYSEmbeddedVideo) then begin
            IDYSVideoProgressbyUser.Init();
            IDYSVideoProgressbyUser.Validate("User ID", UserId());
            IDYSVideoProgressbyUser.Validate(Video, IDYSEmbeddedVideo);
            IDYSVideoProgressbyUser.Insert(true);
            Commit();
        end;
        VideoTitle := GetVideoTitleAndUrl(IDYSEmbeddedVideo, url);
        NavApp.GetCurrentModuleInfo(MyModuleInfo);
        Video.Register(MyModuleInfo.Id(), VideoTitle, Url);
        Video.Play(Url);
        IDYSVideoProgressbyUser.Validate(IDYSVideoProgressbyUser.Watched, true);
        IDYSVideoProgressbyUser.Modify(true);
    end;

    procedure CreateAndSendVideoNotification(IDYSEmbeddedVideo: enum "IDYS Embedded Video")
    var
        VideoNotification: Notification;
        VideoName: Text;
        VideoNotificationUseTxt: Label 'We have created a short video that explain''s how to use %1 in ShipIT 365.', Comment = '%1= Video Title';
        PlayVideoTxt: Label 'Play Video';
        HideNotificationTxt: Label 'Don''t show this notification again.';
    begin
        VideoNotification.Id(GetVideoNotificationID(IDYSEmbeddedVideo));
        if not IsVideoNotificationEnabled(VideoNotification) then
            exit;

        VideoName := IDYSEmbeddedVideo.Names().Get(IDYSEmbeddedVideo.AsInteger());
        VideoNotification.SetData('Type', Format(IDYSEmbeddedVideo));
        case IDYSEmbeddedVideo of
            IDYSEmbeddedVideo::TransportOrder:
                VideoNotification.Message(StrSubstNo(VideoNotificationUseTxt, VideoName)); //plural as Label
            else
                VideoNotification.Message(StrSubstNo(VideoNotificationUseTxt, VideoName));
        end;

        VideoNotification.Scope(NotificationScope::LocalScope);
        VideoNotification.AddAction(PlayVideoTxt, Codeunit::"IDYS Video Management", 'PlayVideo');
        VideoNotification.AddAction(HideNotificationTxt, Codeunit::"IDYS Video Management", 'HideNotification');
        VideoNotification.Send();
    end;

    procedure GetVideoTitleAndUrl(IDYSEmbeddedVideo: enum "IDYS Embedded Video"; var VideoUrl: Text[2048]) VideoTitle: Text[250]
    var
        ShipIT365IntroductionLbl: Label 'ShipIT 365 introduction';
        ShipIT365ServicesLbl: Label 'ShipIT 365 Demo';
    begin
        case IDYSEmbeddedVideo of
            IDYSEmbeddedVideo::Introduction:
                begin
                    VideoUrl := 'https://www.youtube.com/embed/JAb8TGz9W1k?autoplay=1';
                    exit(ShipIT365IntroductionLbl);
                end;
            IDYSEmbeddedVideo::ServicesAndPrices:
                begin
                    // case GlobalLanguage() of
                    //     1043:
                    //         VideoUrl := 'https://www.youtube.com/embed/-q_Y3x4S6_8?autoplay=1';
                    //     else
                            VideoUrl := 'https://www.youtube.com/embed/Yz7E-J48UYs?autoplay=1';
                    // end;
                    exit(ShipIT365ServicesLbl);
                end;
            else
                OnGetVideoTitleAndUrlElseCase(IDYSEmbeddedVideo, VideoUrl, VideoTitle);
        end;
    end;

    procedure PlayVideo(VideoNotification: Notification)
    var
        IDYSEmbeddedVideo: enum "IDYS Embedded Video";
    begin
        Evaluate(IDYSEmbeddedVideo, VideoNotification.GetData('Type'));
        PlayVideo(IDYSEmbeddedVideo);
    end;

    procedure HideNotification(EnabledNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if MyNotifications.Get(UserId(), EnabledNotification.Id()) then begin
            MyNotifications.Validate(Enabled, false);
            MyNotifications.Modify();
        end else begin
            MyNotifications."User Id" := CopyStr(UserId(), 1, MaxStrLen(MyNotifications."User Id"));
            MyNotifications."Notification Id" := EnabledNotification.Id();
            MyNotifications.Validate(Enabled, false);
            MyNotifications.Insert();
        end;
    end;

    local procedure GetVideoNotificationID(IDYSEmbeddedVideo: enum "IDYS Embedded Video") NotificationGuid: Guid
    begin
        case IDYSEmbeddedVideo of
            IDYSEmbeddedVideo::"Introduction":
                exit('834bde60-ec3c-48cc-878c-5b98bb925693');
            IDYSEmbeddedVideo::ServicesAndPrices:
                exit('4483898e-9e82-4cda-b2e1-283cd9aa0223');
            IDYSEmbeddedVideo::Setup:
                exit('af053079-6a17-4355-8ea1-a1b73c8b8840');
            IDYSEmbeddedVideo::TransportOrder:
                exit('06d887b0-3cd9-44f0-bba9-fb97577c1854');
            else
                OnGetVideoNotificationIDElseCase(IDYSEmbeddedVideo, NotificationGuid);
        end;
    end;

    local procedure IsVideoNotificationEnabled(MyNotification: Notification) Enabled: Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        Enabled := MyNotifications.IsEnabled(MyNotification.Id());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetVideoTitleAndUrlElseCase(IDYSEmbeddedVideo: Enum "IDYS Embedded Video"; var url: Text[2048]; var VideoTitle: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetVideoNotificationIDElseCase(IDYSEmbeddedVideo: Enum "IDYS Embedded Video"; var NotificationGuid: Guid)
    begin
    end;
}