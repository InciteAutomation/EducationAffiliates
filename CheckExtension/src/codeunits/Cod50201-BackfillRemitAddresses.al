codeunit 50201 "EA Backfill Remit Addresses"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        CreatedCount: Integer;
        SkippedExistingCount: Integer;
        SkippedIncompleteCount: Integer;
        VendorCount: Integer;
    begin
        LogInfo(
            'EA-REMIT-BACKFILL-START',
            'Starting REMIT1 vendor backfill.');

        BackfillMissingRemitAddresses(
            VendorCount,
            CreatedCount,
            SkippedExistingCount,
            SkippedIncompleteCount);

        LogInfo(
            'EA-REMIT-BACKFILL-COMPLETE',
            StrSubstNo(
                'REMIT1 backfill completed. Vendors checked: %1. REMIT1 created: %2. Vendors already containing REMIT1: %3. Vendors skipped because required fields were incomplete: %4.',
                VendorCount,
                CreatedCount,
                SkippedExistingCount,
                SkippedIncompleteCount));
    end;


    local procedure BackfillMissingRemitAddresses(
        var VendorCount: Integer;
        var CreatedCount: Integer;
        var SkippedExistingCount: Integer;
        var SkippedIncompleteCount: Integer)
    var
        Vendor: Record Vendor;
    begin
        if not Vendor.FindSet() then begin
            LogInfo(
                'EA-REMIT-BACKFILL-NOVENDORS',
                'No vendor records were found.');

            exit;
        end;

        repeat
            VendorCount += 1;

            ProcessVendor(
                Vendor,
                CreatedCount,
                SkippedExistingCount,
                SkippedIncompleteCount);

        until Vendor.Next() = 0;
    end;


    local procedure ProcessVendor(
        Vendor: Record Vendor;
        var CreatedCount: Integer;
        var SkippedExistingCount: Integer;
        var SkippedIncompleteCount: Integer)
    var
        RemitAddress: Record "Remit Address";
    begin
        // Required Vendor Card fields:
        // Name
        // Address
        // City
        // State
        // ZIP Code

        if not HasRequiredVendorFields(Vendor) then begin
            SkippedIncompleteCount += 1;

            LogVendor(
                'EA-REMIT-VENDOR-INCOMPLETE',
                'Vendor skipped because Name, Address, City, State, or ZIP Code is incomplete.',
                Vendor);

            exit;
        end;

        // Only check specifically for REMIT1.
        //
        // A vendor may already have other Remit Address records,
        // such as:
        //
        // 081
        // REMIT
        // REMI1
        // CHECK
        //
        // Those do NOT prevent creation of REMIT1.

        RemitAddress.Reset();

        RemitAddress.SetRange(
            "Vendor No.",
            Vendor."No.");

        RemitAddress.SetRange(
            Code,
            'REMIT1');

        if not RemitAddress.IsEmpty() then begin
            SkippedExistingCount += 1;

            LogVendor(
                'EA-REMIT-VENDOR-EXISTS',
                'Vendor skipped because REMIT1 already exists.',
                Vendor);

            exit;
        end;

        CreateRemitAddress(Vendor);

        CreatedCount += 1;

        LogVendor(
            'EA-REMIT-VENDOR-CREATED',
            'REMIT1 address successfully created.',
            Vendor);
    end;


    local procedure CreateRemitAddress(
        Vendor: Record Vendor)
    var
        RemitAddress: Record "Remit Address";
    begin
        RemitAddress.Init();

        RemitAddress.Validate(
            "Vendor No.",
            Vendor."No.");

        RemitAddress.Validate(
            Code,
            'REMIT1');

        RemitAddress.Validate(
            Name,
            Vendor.Name);

        RemitAddress.Validate(
            "Name 2",
            Vendor."Name 2");

        RemitAddress.Validate(
            Address,
            Vendor.Address);

        RemitAddress.Validate(
            "Address 2",
            Vendor."Address 2");

        RemitAddress.Validate(
            City,
            Vendor.City);

        // State on the Vendor Card = County in AL.
        RemitAddress.Validate(
            County,
            Vendor.County);

        // ZIP Code on the Vendor Card = Post Code in AL.
        RemitAddress.Validate(
            "Post Code",
            Vendor."Post Code");

        RemitAddress.Validate(
            "Country/Region Code",
            Vendor."Country/Region Code");

        RemitAddress.Validate(
            Contact,
            Vendor.Contact);

        RemitAddress.Validate(
            "Phone No.",
            Vendor."Phone No.");

        RemitAddress.Validate(
            "Fax No.",
            Vendor."Fax No.");

        RemitAddress.Validate(
            "E-Mail",
            Vendor."E-Mail");

        RemitAddress.Validate(
            "Home Page",
            Vendor."Home Page");

        RemitAddress.Default := false;

        RemitAddress.Insert(true);
    end;


    local procedure HasRequiredVendorFields(
        Vendor: Record Vendor): Boolean
    begin
        exit(
            (Vendor.Name <> '') and
            (Vendor.Address <> '') and
            (Vendor.City <> '') and
            (Vendor.County <> '') and
            (Vendor."Post Code" <> '')
        );
    end;


    local procedure LogInfo(
        EventId: Text;
        MessageText: Text)
    begin
        Session.LogMessage(
            EventId,
            MessageText,
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            'Feature',
            'REMIT1 Backfill');
    end;


    local procedure LogVendor(
        EventId: Text;
        MessageText: Text;
        Vendor: Record Vendor)
    begin
        Session.LogMessage(
            EventId,
            MessageText,
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            'VendorNo',
            Vendor."No.",
            'Feature',
            'REMIT1 Backfill');
    end;
}