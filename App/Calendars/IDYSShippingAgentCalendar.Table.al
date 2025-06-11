table 11147661 "IDYS Shipping Agent Calendar"
{
    Caption = 'Shipping Agent Calendar';
    DataClassification = CustomerContent;
    LookupPageId = "IDYS Shipping Agent Calendars";

    fields
    {
        field(1; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services"."Code" where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "Pick-up Time From"; Time)
        {
            Caption = 'Pick-up Time From';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Pick-up From DT", CreateDateTime(WorkDate(), "Pick-up Time From"));
            end;
        }
        field(4; "Pick-up Time To"; Time)
        {
            Caption = 'Pick-up Time To';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Pick-up To DT", CreateDateTime(WorkDate(), "Pick-up Time To"));
            end;
        }
        field(5; "Pick-up Base Calendar Code"; Code[10])
        {
            Caption = 'Pick-up Base Calendar Code';
            TableRelation = "Base Calendar";
            DataClassification = CustomerContent;
        }
        field(6; "Delivery Time From"; Time)
        {
            Caption = 'Delivery Time From';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Delivery From DT", CreateDateTime(WorkDate(), "Delivery Time From"));
            end;
        }
        field(7; "Delivery Time To"; Time)
        {
            Caption = 'Delivery Time To';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Delivery To DT", CreateDateTime(WorkDate(), "Delivery Time To"));
            end;
        }
        field(8; "Delivery Base Calendar Code"; Code[10])
        {
            Caption = 'Delivery Base Calendar Code';
            TableRelation = "Base Calendar";
            DataClassification = CustomerContent;
        }
        field(10; "Pick-up From DT"; Datetime)
        {
            Caption = 'Pick-up Time From';
            DataClassification = CustomerContent;
        }
        field(11; "Pick-up To DT"; Datetime)
        {
            Caption = 'Pick-up Time To';
            DataClassification = CustomerContent;
        }
        field(12; "Delivery From DT"; Datetime)
        {
            Caption = 'Delivery Time From';
            DataClassification = CustomerContent;
        }
        field(13; "Delivery To DT"; Datetime)
        {
            Caption = 'Delivery Time To';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Shipping Agent Code", "Shipping Agent Service Code")
        {
            Clustered = true;
        }
    }
}
