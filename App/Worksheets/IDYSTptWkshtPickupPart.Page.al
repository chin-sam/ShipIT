page 11147678 "IDYS Tpt. Wksht. Pick-up Part"
{
    Caption = 'Pick-up Address';
    PageType = CardPart;
    SourceTable = "IDYS Transport Worksheet Line";

    layout
    {
        area(Content)
        {
            field("Type (Pick-up)"; Rec."Source Type (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the type.';
            }

            field("No. (Pick-up)"; Rec."No. (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the no..';
            }

            field("Code (Pick-up)"; Rec."Code (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the code.';
            }

            field("Name (Pick-up)"; Rec."Name (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the name.';
            }

            field("Address (Pick-up)"; Rec."Address (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the address.';
            }

            field("Address 2 (Pick-up)"; Rec."Address 2 (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the address 2.';
            }

            field("Post Code (Pick-up)"; Rec."Post Code (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the post code.';
            }

            field("City (Pick-up)"; Rec."City (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the city.';
            }

            field("County (Pick-up)"; Rec."County (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the county.';
            }

            field("Country/Region Code (Pick-up)"; Rec."Country/Region Code (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the country/region code.';
            }

            field("Contact (Pick-up)"; Rec."Contact (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the contact.';
            }

            field("Phone No. (Pick-up)"; Rec."Phone No. (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the phone no.';
            }
            field("Mobile Phone No. (Pick-up)"; Rec."Mobile Phone No. (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the mobile phone no.';
            }
            field("Fax No. (Pick-up)"; Rec."Fax No. (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies fax no.';
            }

            field("E-Mail (Pick-up)"; Rec."E-Mail (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the e-mail.';
            }

            field("VAT Registration No. (Pick-up)"; Rec."VAT Registration No. (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the VAT registration no.';
            }

            field("EORI Number (Pick-up)"; Rec."EORI Number (Pick-up)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Economic Operators Registration and Identification number that is used when you exchange information with the customs authorities due to trade into or out of the European Union.';
            }
        }
    }
}