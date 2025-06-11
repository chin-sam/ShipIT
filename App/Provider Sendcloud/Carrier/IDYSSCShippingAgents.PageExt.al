pageextension 11147681 "IDYS SC Shipping Agents" extends "Shipping Agents"
{
    layout
    {
        addafter("Internet Address")
        {
            field("IDYS SC Change Label Settings"; Rec."IDYS SC Change Label Settings")
            {
                ApplicationArea = All;
                ToolTip = 'Indicates that the default setting for printing labels from the setup is overruled by carrier specific settings.';
                Visible = IsSendcloud;

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
            field("IDYS SC Request Label"; Rec."IDYS SC Request Label")
            {
                ApplicationArea = All;
                ToolTip = 'Indicates if a label should be created for the parcel directly when sending it to the Sendcloud portal. This setting overrules the default setting from the setup when Change Label Settings is activated.';
                Editable = ChangeLabelSettings;
                Visible = IsSendcloud;
            }
            field("IDYS SC Label Type"; Rec."IDYS SC Label Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies which label type should be saved to the database as .pdf file. This setting overrules the default setting from the setup when Change Label Settings is activated.';
                Editable = ChangeLabelSettings;
                Visible = IsSendcloud;
            }
        }
    }

    trigger OnOpenPage()
    var
        IDYSProviderMgt: Codeunit "IDYS Provider Mgt.";
    begin
        IsSendcloud := IDYSProviderMgt.IsProviderEnabled("IDYS Provider"::Sendcloud, false);
    end;

    trigger OnAfterGetRecord()
    begin
        ChangeLabelSettings := Rec."IDYS SC Change Label Settings";
    end;

    var
        IsSendcloud: Boolean;
        ChangeLabelSettings: Boolean;
}