#if not (BC17 or BC18 or BC19 or BC20)
reportextension 11147639 "IDYS Copy Sales Document" extends "Copy Sales Document"
{
    requestpage
    {
        layout
        {
            addlast(Options)
            {
                group("IDYS ShipIT 365")
                {
                    Caption = 'ShipIT 365';
                    field(IDYSCopySourceDocPackages; IDYSCopySourceDocPackages)
                    {
                        ApplicationArea = All;
                        Caption = 'Copy Source Document Packages';
                        ToolTip = 'Specifies if you also want to copy the source document packages from the document.';
                        Enabled = IDYSCopySourceDocPackagesEnabled;

                        trigger OnValidate()
                        begin
                            IDYSUpdateParameters();
                        end;
                    }
                }
            }
        }
    }

    procedure IDYSSetCopySourceDocPackages(NewIDYSCopySourceDocPackages: Boolean)
    begin
        IDYSCopySourceDocPackages := NewIDYSCopySourceDocPackages;
        IDYSUpdateParameters();
    end;

    procedure IDYSSetCopySourceDocPackagesEnabled(NewIDYSCopySourceDocPackagesEnabled: Boolean)
    begin
        IDYSCopySourceDocPackagesEnabled := NewIDYSCopySourceDocPackagesEnabled;
    end;

    procedure IDYSGetCopySourceDocPackages(): Boolean
    begin
        exit(IDYSCopySourceDocPackages);
    end;

    local procedure IDYSUpdateParameters()
    begin
        SalesHeader."IDYS Copy Source Doc. Packages" := IDYSCopySourceDocPackages;
        SalesHeader.Modify();
    end;

    var
        IDYSCopySourceDocPackages: Boolean;
        IDYSCopySourceDocPackagesEnabled: Boolean;
}
#endif