page 11147688 "IDYS Setup Verification Result"
{
    Caption = 'Setup Verification Result';
    DataCaptionExpression = '';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "IDYS Setup Verification Result";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                IndentationColumn = Indentation;
                IndentationControls = Description;
                field(OK; Rec.OK)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the setup verification was successful.';
                }

                field(Description; Rec.Description)
                {
                    Style = Strong;
                    StyleExpr = Style;
                    ApplicationArea = All;
                    ToolTip = 'Describes the verification result.';
                }
            }
        }
    }

    trigger OnAfterGetRecord();
    begin
        Indentation := 0;
        Style := false;

        case Rec."Line Type" of
            Rec."Line Type"::Heading:
                Style := true;
            Rec."Line Type"::Line:
                Indentation := 1;
        end;
    end;

    var
        Indentation: Integer;
        Style: Boolean;
}

