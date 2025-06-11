page 11147707 "IDYS Contact Card"
{
    Caption = 'ShipIT 365 Contact Information';
    PageType = NavigatePage;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                ShowCaption = false;
                Visible = ShowClose;

                usercontrol(SetupWizardAddin2; "IDYS Setup Wizard 02 Addin")
                {
                    ApplicationArea = All;

                    trigger AddinLoaded()
                    begin
                        CurrPage.SetupWizardAddin2.Initialize();
                    end;
                }
                usercontrol(ContactAddin; "IDYS Contact Addin")
                {
                    ApplicationArea = All;

                    trigger AddinLoaded()
                    begin
                        CurrPage.ContactAddin.Initialize();
                        CurrPage.ContactAddin.addButton('About Idyn');
                        CurrPage.ContactAddin.addButton2('Support');
                    end;

                    trigger ButtonPressed()
                    begin
                        Hyperlink('https://www.idyn.nl/about-us');
                    end;

                    trigger ButtonPressed2()
                    begin
                        Hyperlink('https://www.idyn.nl/support');
                    end;
                }
                group(Contact)
                {
                    Caption = 'Contact our sales department';
                    InstructionalText = 'Do you have a question or need assistance? Please contact us.';
                    ShowCaption = false;
                    field(IdynSalesEmailUrlLbl; IdynSalesEmailUrlLbl)
                    {
                        Caption = 'Contact email address';
                        ApplicationArea = All;
                        ToolTip = 'Contact email address';
                        ShowCaption = false;
                        trigger OnDrillDown()
                        begin
                            Hyperlink('mailto:sales@idyn.nl');
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Close)
            {
                ApplicationArea = All;
                Caption = 'Close';
                Enabled = true;
                Image = Close;
                InFooterBar = true;
                Visible = not ShowClose;
                ToolTip = 'Close page.';

                trigger OnAction();
                begin
                    CurrPage.Close();
                end;
            }
            action("Contact Us")
            {
                Caption = 'Contact Us';
                ApplicationArea = All;
                Image = Info;
                InFooterBar = true;
                ToolTip = 'Contact Us';

                trigger OnAction();
                begin
                    page.Run(page::"IDYS Contact Card");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ShowClose := true;
    end;

    var
        ShowClose: Boolean;
        IdynSalesEmailUrlLbl: Label 'sales@idyn.nl';
}
