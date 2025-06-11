page 11147679 "IDYS Tpt. Wksht. Ship-to Part"
{
    Caption = 'Ship-to Address';
    PageType = CardPart;
    SourceTable = "IDYS Transport Worksheet Line";

    layout
    {
        area(Content)
        {
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

            field("Address (Ship-to)"; Rec."Address (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the address.';
            }

            field("Address 2 (Ship-to)"; Rec."Address 2 (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the address 2.';
            }

            field("Post Code (Ship-to)"; Rec."Post Code (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the post code.';
            }

            field("City (Ship-to)"; Rec."City (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the city.';
            }

            field("County (Ship-to)"; Rec."County (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the county.';
            }

            field("Country/Region Code (Ship-to)"; Rec."Country/Region Code (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the country/region code.';
            }

            field("Contact (Ship-to)"; Rec."Contact (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the contact.';
            }

            field("Phone No. (Ship-to)"; Rec."Phone No. (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the phone no..';
            }
            field("Mobile Phone No. (Ship-to)"; Rec."Mobile Phone No. (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the mobile phone no.';
            }
            field("Fax No. (Ship-to)"; Rec."Fax No. (Ship-to)")
            {
                Caption = 'Fax No.';
                ApplicationArea = All;
                ToolTip = 'Specifies the fax no.';
            }

            field("E-Mail (Ship-to)"; Rec."E-Mail (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the e-mail.';
            }

            field("VAT Registration No. (Ship-to)"; Rec."VAT Registration No. (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the VAT registration no.';
            }

            field("EORI Number (Ship-to)"; Rec."EORI Number (Ship-to)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Economic Operators Registration and Identification number that is used when you exchange information with the customs authorities due to trade into or out of the European Union.';
            }
        }
    }
}