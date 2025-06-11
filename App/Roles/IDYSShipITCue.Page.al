page 11147687 "IDYS ShipIT Cue"
{
    Caption = 'ShipIT';
    PageType = CardPart;
    SourceTable = "IDYS ShipIT Cue";

    layout
    {
        area(Content)
        {
            cuegroup("Transport Orders")
            {
                Caption = 'Transport Orders';
                field("Transport Orders - New"; Rec."Transport Orders - New")
                {
                    Caption = 'New';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the new transport order count';
                }
                field("Transport Orders - Uploaded"; Rec."Transport Orders - Uploaded")
                {
                    Caption = 'Uploaded';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the uploaded transport order count';
                    Visible = false;
                }
                field("Transport Orders - Booked"; Rec."Transport Orders - Booked")
                {
                    Caption = 'Booked';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the booked transport order count';
                }
                field("Tpt. Orders - Label Printed"; Rec."Tpt. Orders - Label Printed")
                {
                    Caption = 'Label Printed';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transport order that have their label printed count';
                }
                field("Transport Orders - Done"; Rec."Transport Orders - Done")
                {
                    Caption = 'Done';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the done transport order count';
                }
                field("Transport Orders - Recalled"; Rec."Transport Orders - Recalled")
                {
                    Caption = 'Recalled';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the recalled transport order count';
                }
                field("Transport Orders - Error"; Rec."Transport Orders - Error")
                {
                    Caption = 'Error';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error transport order count';
                }
                field("Transport Orders - On Hold"; Rec."Transport Orders - On Hold")
                {
                    Caption = 'On Hold';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the on hold transport order count';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Set Up Cues")
            {
                Image = Setup;
                ApplicationArea = All;
                ToolTip = 'Opens the setup page for cue settings.';

                trigger OnAction()
                var
                    CuesAndKPIs: Codeunit "Cues And KPIs";
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKPIs.OpenCustomizePageForCurrentUser(CueRecordRef.Number());
                end;
            }
        }
    }

    trigger OnOpenPage();
    var
        IDYSSetup: Record "IDYS Setup";
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        TempShipITCue: Record "IDYS ShipIT Cue" temporary;
        CuesAndKpis: Codeunit "Cues And KPIs";
#endif
        IDYSNotificationManagement: Codeunit "IDYS Notification Management";
        SetupMsg: Label 'The ShipIT setup has not been completed. Please contact your IT manager.';
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        if not IDYSSetup.Get() then
            IDYSNotificationManagement.SendNotification(SetupMsg);

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        // Unfavorable
        if not CuesAndKpis.PersonalizedCueSetupExistsForCurrentUser(Database::"IDYS ShipIT Cue", TempShipITCue.FieldNo("Transport Orders - Recalled")) then
            CuesAndKpis.InsertData(Database::"IDYS ShipIT Cue", TempShipITCue.FieldNo("Transport Orders - Recalled"), Enum::"Cues And KPIs Style"::None, 0, Enum::"Cues And KPIs Style"::None, 0.01, Enum::"Cues And KPIs Style"::Unfavorable);
        if not CuesAndKpis.PersonalizedCueSetupExistsForCurrentUser(Database::"IDYS ShipIT Cue", TempShipITCue.FieldNo("Transport Orders - On Hold")) then
            CuesAndKpis.InsertData(Database::"IDYS ShipIT Cue", TempShipITCue.FieldNo("Transport Orders - On Hold"), Enum::"Cues And KPIs Style"::None, 0, Enum::"Cues And KPIs Style"::None, 0.01, Enum::"Cues And KPIs Style"::Unfavorable);
        if not CuesAndKpis.PersonalizedCueSetupExistsForCurrentUser(Database::"IDYS ShipIT Cue", TempShipITCue.FieldNo("Transport Orders - Error")) then
            CuesAndKpis.InsertData(Database::"IDYS ShipIT Cue", TempShipITCue.FieldNo("Transport Orders - Error"), Enum::"Cues And KPIs Style"::None, 0, Enum::"Cues And KPIs Style"::None, 0.01, Enum::"Cues And KPIs Style"::Unfavorable);
#endif
    end;
}

