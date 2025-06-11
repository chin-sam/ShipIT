page 11147702 "IDYS SC Sender Address List"
{

    PageType = List;
    SourceTable = "IDYS SC Sender Address";
    Caption = 'Sendcloud Sender Addresses';
    UsageCategory = None;
    InsertAllowed = false;
    ObsoleteState = Pending;
    ObsoleteReason = 'Sender Address removed';
    ObsoleteTag = '21.0';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique Id of the sender address in the Sendcloud portal.';
                    Editable = false;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company name for the sender address.';
                    Editable = false;
                }
                field("Contact Name"; Rec."Contact Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the contact name for the sender address.';
                    Editable = false;
                }
                field(Street; Rec.Street)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the street of the sender address.';
                    Editable = false;
                }
                field("House Number"; Rec."House Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the house no. of the sender address.';
                    Editable = false;
                }
                field("Postal Code"; Rec."Postal Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the postal code of the sender address.';
                    Editable = false;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city of the sender address.';
                    Editable = false;
                }
                field(Country; Rec.Country)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country of the sender address.';
                    Editable = false;
                }

            }
        }
    }
}
