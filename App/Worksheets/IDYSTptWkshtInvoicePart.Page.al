page 11147680 "IDYS Tpt. Wksht. Invoice Part"
{
    Caption = 'Invoice Address';
    PageType = CardPart;
    SourceTable = "IDYS Transport Worksheet Line";

    layout
    {
        area(Content)
        {
            field("Type (Invoice)"; Rec."Source Type (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the type.';
            }

            field("No. (Invoice)"; Rec."No. (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the no.';
            }

            field("Name (Invoice)"; Rec."Name (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the name.';
            }

            field("Address (Invoice)"; Rec."Address (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifues the address.';
            }

            field("Address 2 (Invoice)"; Rec."Address 2 (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the address 2.';
            }

            field("Post Code (Invoice)"; Rec."Post Code (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the post code.';
            }

            field("City (Invoice)"; Rec."City (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the city.';
            }

            field("County (Invoice)"; Rec."County (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the county.';
            }

            field("Country/Region Code (Invoice)"; Rec."Country/Region Code (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the country/region code.';
            }

            field("Contact (Invoice)"; Rec."Contact (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the contact.';
            }

            field("Phone No. (Invoice)"; Rec."Phone No. (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the phone no.';
            }
            field("Mobile Phone No. (Invoice)"; Rec."Mobile Phone No. (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the mobile phone no.';
            }
            field("Fax No. (Invoice)"; Rec."Fax No. (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the fax no.';
            }

            field("E-Mail (Invoice)"; Rec."E-Mail (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the e-mail.';
            }

            field("VAT Registration No. (Invoice)"; Rec."VAT Registration No. (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the VAT registration no.';
            }

            field("EORI Number (Invoice)"; Rec."EORI Number (Invoice)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Economic Operators Registration and Identification number that is used when you exchange information with the customs authorities due to trade into or out of the European Union.';
            }
        }
    }
}