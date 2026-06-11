table 50100 "Vendor Remit Result Buffer"
{
    TableType = Temporary;

    fields
    {
        field(1; "Vendor No."; Code[20]) { }
        field(2; "Company Dim Value"; Code[20]) { }
        field(3; "Remit Code"; Code[10]) { }
        field(4; Name; Text[100]) { }
        field(5; Address; Text[100]) { }
        field(6; "Address 2"; Text[50]) { }
        field(7; City; Text[30]) { }
        field(8; State; Text[30]) { }
        field(9; "Post Code"; Code[20]) { }
        field(10; "Country Code"; Code[10]) { }
        field(11; "Debug Message"; Text[250]) { }
        field(12; "EntryId"; Text[50]) { }
    }

    keys
    {
        key(PK; "EntryId") { Clustered = true; }
    }
}