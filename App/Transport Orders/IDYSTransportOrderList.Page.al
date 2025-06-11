page 11147670 "IDYS Transport Order List"
{
    Caption = 'Transport Orders';
    CardPageID = "IDYS Transport Order Card";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;
    PageType = List;
#if BC17 or BC18 or BC19 or BC20
    PromotedActionCategories = 'New,Process,Report,Transport Order';
#endif
    SourceTable = "IDYS Transport Order Header";
    SourceTableView = where(Status = filter(<> Archived));
    ContextSensitiveHelpPage = '22937633';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no..';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleExpr;
                    ToolTip = 'Specifies the status.';
                }

                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document date.';
                }

                field("Preferred Pick-up Date"; Rec."Preferred Pick-up Date")
                {
                    ToolTip = 'Specifies the value of the Preferred Pick-up Date field.';
                    ApplicationArea = All;
                }

                field("Preferred Delivery Date"; Rec."Preferred Delivery Date")
                {
                    ToolTip = 'Specifies the value of the Preferred Delivery Date field.';
                    ApplicationArea = All;
                }

                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent code.';
                }

                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent service code.';
                }

                field("Type (Pick-up)"; Rec."Source Type (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the pick-up address.';
                }

                field("No. (Pick-up)"; Rec."No. (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no. of the pick-up address.';
                }

                field("Code (Pick-to)"; Rec."Code (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the pick-up address.';
                }

                field("Name (Pick-up)"; Rec."Name (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the pick-up address.';
                }

                field("Post Code (Pick-up)"; Rec."Post Code (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the pick-up post code.';
                }

                field("City (Pick-up)"; Rec."City (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the pick-up city.';
                }

                field("Country/Region Code (Pick-up)"; Rec."Country/Region Code (Pick-up)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the pick-up Country/Region Code.';
                }

                field("Type (Ship-to)"; Rec."Source Type (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type.';
                }

                field("No. (Ship-to)"; Rec."No. (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no..';
                }

                field("Code (Ship-to)"; Rec."Code (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code.';
                }

                field("Name (Ship-to)"; Rec."Name (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name.';
                }

                field("Post Code (Ship-to)"; Rec."Post Code (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Post Code.';
                }

                field("City (Ship-to)"; Rec."City (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city.';
                }

                field("Country/Region Code (Ship-to)"; Rec."Country/Region Code (Ship-to)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Country/Region Code.';
                }

                field("Type (Invoice)"; Rec."Source Type (Invoice)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the invoice address.';
                    Visible = false;
                }

                field("No. (Invoice)"; Rec."No. (Invoice)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no. of the invoice address.';
                    Visible = false;
                }

                field("Name (Invoice)"; Rec."Name (Invoice)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the invoice address.';
                    Visible = false;
                }

                field("Post Code (Invoice)"; Rec."Post Code (Invoice)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the invoice post code.';
                    Visible = false;
                }

                field("City (Invoice)"; Rec."City (Invoice)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the invoice city.';
                    Visible = false;
                }

                field("Country/Region Code (Invoice)"; Rec."Country/Region Code (Invoice)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the invoice Country/Region Code.';
                    Visible = false;
                }
                field(Insure; Rec.Insure)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if insurance is applied.';
                    Visible = false;
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
                ToolTip = 'Link this transport order to one or more reports.';
                RunObject = Page "IDYS Transport Order Reports";
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
            action("Overview Dashboard")
            {
                Caption = 'Overview Dashboard';
                Image = DocInBrowser;
                ToolTip = 'Open all transport orders in the provider''s portal.';
                ApplicationArea = All;

                trigger OnAction();
                begin
                    Rec.TestField(Provider);
                    IDYSIProvider := Rec.Provider;
                    IDYSIProvider.OpenAllInDashboard();
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
        }

        area(Processing)
        {
            action(Book)
            {
                Caption = 'Book';
                Image = RegisterPick;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                ToolTip = 'Book this transport order into the provider''s systems.';
                ApplicationArea = All;
                Visible = BookVisible;

                trigger OnAction();
                var
                    TransportOrderHeader: Record "IDYS Transport Order Header";
                begin
                    CurrPage.SaveRecord();
                    CurrPage.SetSelectionFilter(TransportOrderHeader);
                    IDYSTransportOrderMgt.ProcessTransportOrders(TransportOrderHeader, "IDYS Performed TO Action"::Booked);
                    CurrPage.Update(false);
                end;
            }

            action("Book and Print")
            {
                Caption = 'Book and Print';
                Image = RegisterPick;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                ToolTip = 'Book this transport order into the provider''s systems and print labels and/or documents for it.';
                ApplicationArea = All;
                Visible = BookVisible and not (IsSendcloud or IsEasyPost);

                trigger OnAction();
                var
                    TransportOrderHeader: Record "IDYS Transport Order Header";
                begin
                    CurrPage.SaveRecord();
                    CurrPage.SetSelectionFilter(TransportOrderHeader);
                    IDYSTransportOrderMgt.ProcessTransportOrders(TransportOrderHeader, "IDYS Performed TO Action"::"Booked & Printed");
                    CurrPage.Update(false);
                end;
            }

            action(Synchronize)
            {
                Caption = 'Synchronize';
                Image = Refresh;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                ToolTip = 'Send updates to and receive updates from the provider.';
                ApplicationArea = All;
                Visible = SynchronizeVisible;

                trigger OnAction();
                var
                    TransportOrderHeader: Record "IDYS Transport Order Header";
                begin
                    CurrPage.SaveRecord();
                    CurrPage.SetSelectionFilter(TransportOrderHeader);
                    IDYSTransportOrderMgt.ProcessTransportOrders(TransportOrderHeader, "IDYS Performed TO Action"::Synchronized);
                    CurrPage.Update(false);
                end;
            }

            action(Recall)
            {
                Caption = 'Recall';
                Image = ReceiveLoaner;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                ToolTip = 'Request the provider to cancel this transport order.';
                ApplicationArea = All;
                Visible = RecallVisible;

                trigger OnAction();
                var
                    TransportOrderHeader: Record "IDYS Transport Order Header";
                begin
                    CurrPage.SaveRecord();
                    CurrPage.SetSelectionFilter(TransportOrderHeader);
                    IDYSTransportOrderMgt.ProcessTransportOrders(TransportOrderHeader, "IDYS Performed TO Action"::Recalled);
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
                PromotedOnly = true;
                PromotedCategory = Process;
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
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                ToolTip = 'Print labels and/or documents for this transport order.';
                ApplicationArea = All;
                Visible = PrintVisible and not (IsSendcloud or IsEasyPost);

                trigger OnAction();
                var
                    TransportOrderHeader: Record "IDYS Transport Order Header";
                begin
                    CurrPage.SaveRecord();
                    CurrPage.SetSelectionFilter(TransportOrderHeader);
                    IDYSTransportOrderMgt.ProcessTransportOrders(TransportOrderHeader, "IDYS Performed TO Action"::Printed);
                    CurrPage.Update(false);
                end;
            }
            action(Archive)
            {
                Caption = 'Archive';
                Image = RegisteredDocs;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                ToolTip = 'Archive this transport order.';
                ApplicationArea = All;

                trigger OnAction();
                var
                    TransportOrderHeader: Record "IDYS Transport Order Header";
                begin
                    CurrPage.SaveRecord();
                    CurrPage.SetSelectionFilter(TransportOrderHeader);
                    IDYSTransportOrderMgt.ProcessTransportOrders(TransportOrderHeader, "IDYS Performed TO Action"::Archived);
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

#pragma warning disable AL0432
                actionref("Download Label_Promoted"; "Download Label")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'All header-level files are now stored in attachments';
                    ObsoleteTag = '23.0';
                    Visible = false;
                }
#pragma warning restore
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
                actionref(Archive_Promoted; Archive)
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
    var
        IDYMAppHub: Codeunit "IDYM Apphub";
        LicenseCheck: Codeunit "IDYS License Check";
        ErrorMessage: Text;
        HttpStatusCode: Integer;
        AppInfo: ModuleInfo;
    begin
        LoadSetup();
        MapVisible := IDYSSetup."Bing API Key" <> '';

        if IDYSSetup."License Entry No." <> 0 then begin
            LicenseCheck.SetPostponeWriteTransactions();
            LicenseCheck.SetHideErrors(true);
            LicenseCheck.CheckLicense(IDYSSetup."License Entry No.", ErrorMessage, HttpStatusCode);
        end;

        NavApp.GetCurrentModuleInfo(AppInfo);
        IDYMAppHub.NewAppVersionNotification(AppInfo.Id, false);
        NotificationManagement.SendInstructionNotification();
    end;

    trigger OnAfterGetRecord();
    begin
        PrintVisible := Rec.Status in [Rec.Status::Booked, Rec.Status::"Label Printed"];
        BookVisible := Rec.Status in [Rec.Status::New];
        RecallVisible := not (Rec.Status in [Rec.Status::Done, Rec.Status::New]);
        ResetVisible := (not (Rec.Status in [Rec.Status::New]));
        SynchronizeVisible := Rec.Status in [Rec.Status::Booked, Rec.Status::"Label Printed", Rec.Status::"On Hold", Rec.Status::Uploaded];

        IsSendcloud := IDYSProviderMgt.IsProvider(Enum::"IDYS Provider"::Sendcloud, Rec);
        IsEasyPost := IDYSProviderMgt.IsProvider(Enum::"IDYS Provider"::EasyPost, Rec);
        OverwriteVisibilities();
    end;

    local procedure OverwriteVisibilities()
    begin
        // Overwrite default behaviour
        Clear(StatusStyleExpr);

        case true of
            IsSendcloud:
                begin
                    if Rec.Status = Rec.Status::Recalled then begin
                        BookVisible := false;
                        RecallVisible := false;
                    end;
                    if Rec.Status = Rec.Status::Booked then
                        if Rec."Booked with Error" then
                            StatusStyleExpr := "IDYS Style Expression".Names().Get("IDYS Style Expression".Ordinals().IndexOf("IDYS Style Expression"::Attention.AsInteger()));
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
        IDYSTransportOrderMgt: Codeunit "IDYS Transport Order Mgt.";
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
        NotificationManagement: Codeunit "IDYS Notification Management";
        IDYSIProvider: Interface "IDYS IProvider";
        SetupLoaded: Boolean;
        PrintVisible: Boolean;
        BookVisible: Boolean;
        RecallVisible: Boolean;
        ResetVisible: Boolean;
        SynchronizeVisible: Boolean;
        MapVisible: Boolean;
        IsSendcloud: Boolean;
        IsEasyPost: Boolean;
        StatusStyleExpr: Text;
}