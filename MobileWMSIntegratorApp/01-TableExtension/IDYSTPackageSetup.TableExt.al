tableextension 11147821 "IDYST Package Setup" extends "MOB Mobile WMS Package Setup"
{
    fields
    {
        field(11147820; "IDYST IDYS Provider"; Enum "IDYS Provider")
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;
        }
        field(11147821; "IDYST Carrier Name"; Text[150])
        {
            Caption = 'Carrier Name';
            DataClassification = CustomerContent;
        }
        field(11147822; "IDYST Book Prof Descr"; Text[150])
        {
            Caption = 'Booking Profile Description';
            DataClassification = CustomerContent;
        }
        field(11147823; "IDYST Package Descr"; Text[150])
        {
            Caption = 'Package Type Description';
            DataClassification = CustomerContent;
        }

        modify("Package Type")
        {
            trigger OnAfterValidate()
            var
                PackageType: Record "MOB Package Type";
            begin
                if PackageType.Get("Package Type") then begin
                    "IDYST IDYS Provider" := PackageType."IDYST IDYS Provider";
                    "IDYST Carrier Name" := PackageType."IDYST Carrier Name";
                    "IDYST Book Prof Descr" := PackageType."IDYST Book Prof Descr";
                    "IDYST Package Descr" := PackageType.Description;
                end;
            end;
        }
    }
}
