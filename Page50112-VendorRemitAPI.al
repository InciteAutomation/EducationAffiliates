page 50112 "Vendor Remit Address API"
{
    PageType = API;
    APIPublisher = 'InciteAutomation';
    APIGroup = 'vendorRemit';
    APIVersion = 'v1.0';
    EntityName = 'vendorRemitAddress';
    EntitySetName = 'vendorRemitAddresses';
    SourceTable = "Vendor Remit Result Buffer";
    DelayedInsert = true;
    InsertAllowed = true;
    ODataKeyFields = EntryId;

    layout
    {
        area(Content)
        {
            field(entryId; Rec.EntryId) { }
            field(vendorNo; Rec."Vendor No.") { }
            field(companyDimValue; Rec."Company Dim Value") { }
            field(remitCode; Rec."Remit Code") { }
            field(name; Rec.Name) { }
            field(address; Rec.Address) { }
            field(address2; Rec."Address 2") { }
            field(city; Rec.City) { }
            field(state; Rec.State) { }
            field(postCode; Rec."Post Code") { }
            field(countryCode; Rec."Country Code") { }
            field("debugMessage"; Rec."Debug Message") { }
        }
    }





    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        RemitLookup: Codeunit "Vendor Remit Lookup";
        Parts: List of [Text];
        VendorNo: Code[20];
        CompanyDimValue: Code[20];
    begin
        //Rec.EntryId := Rec."Vendor No." + '_' + Rec."Company Dim Value";

        // Split EntryId to get the values since Rec fields may not populate in time
        //Parts := Rec.EntryId.Split('_');
        //VendorNo := CopyStr(Parts.Get(1), 1, 20);
        //CompanyDimValue := CopyStr(Parts.Get(2), 1, 20);
        Rec.EntryId := Format(CreateGuid());
        RemitLookup.PopulateBuffer(
            Rec,
            Rec."Vendor No.",
            Rec."Company Dim Value"
        );
        exit(true);
    end;

}