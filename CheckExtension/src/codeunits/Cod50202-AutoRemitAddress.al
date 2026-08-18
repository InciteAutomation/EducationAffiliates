codeunit 50202 "EA Auto Remit Address"
{
    [EventSubscriber(
        ObjectType::Table,
        Database::Vendor,
        'OnAfterInsertEvent',
        '',
        false,
        false)]
    local procedure VendorOnAfterInsert(
        var Rec: Record Vendor;
        RunTrigger: Boolean)
    begin
        LogVendor(
            'EA-REMIT-AUTO-INSERT',
            'Vendor OnAfterInsertEvent fired.',
            Rec);

        EnsureRemit1Exists(Rec);
    end;


    [EventSubscriber(
        ObjectType::Table,
        Database::Vendor,
        'OnAfterModifyEvent',
        '',
        false,
        false)]
    local procedure VendorOnAfterModify(
        var Rec: Record Vendor;
        var xRec: Record Vendor;
        RunTrigger: Boolean)
    begin
        // OnAfterModifyEvent fires whenever the Vendor record is modified.
        // Only continue if one of our required fields changed.
        if not RequiredVendorFieldsChanged(Rec, xRec) then
            exit;

        LogVendor(
            'EA-REMIT-AUTO-MODIFY',
            'Required vendor fields changed. Checking whether REMIT1 should be created.',
            Rec);

        EnsureRemit1Exists(Rec);
    end;


    procedure SyncRemit1(Vendor: Record Vendor)
    var
        RemitAddress: Record "Remit Address";
        WasCreated: Boolean;
    begin
        LogVendor(
            'EA-REMIT-SYNC-START',
            'Manual Sync REMIT1 started.',
            Vendor);

        // Manual sync requires all required Vendor Card fields.
        if not HasRequiredVendorFields(Vendor) then begin
            LogVendor(
                'EA-REMIT-SYNC-INCOMPLETE',
                'Manual REMIT1 sync stopped because Name, Address, City, State, or ZIP Code is incomplete.',
                Vendor);

            Error(
                'REMIT1 cannot be synced until Name, Address, City, State, and ZIP Code are filled in for vendor %1.',
                Vendor."No.");
        end;

        // Look specifically for this vendor's REMIT1 record.
        RemitAddress.Reset();
        RemitAddress.SetRange(
            "Vendor No.",
            Vendor."No.");

        RemitAddress.SetRange(
            Code,
            'REMIT1');

        WasCreated := RemitAddress.IsEmpty();

        if WasCreated then begin
            LogVendor(
                'EA-REMIT-SYNC-CREATE',
                'REMIT1 does not exist. Creating it from the Vendor Card.',
                Vendor);

            CreateRemitAddress(Vendor);
        end else begin
            RemitAddress.FindFirst();

            LogVendor(
                'EA-REMIT-SYNC-UPDATE',
                'Existing REMIT1 found. Updating it from the Vendor Card.',
                Vendor);

            UpdateRemitAddress(
                RemitAddress,
                Vendor);
        end;

        ShowSyncNotification(
            Vendor,
            WasCreated);

        if WasCreated then
            LogVendor(
                'EA-REMIT-SYNC-COMPLETE',
                'Manual REMIT1 sync completed. REMIT1 was created.',
                Vendor)
        else
            LogVendor(
                'EA-REMIT-SYNC-COMPLETE',
                'Manual REMIT1 sync completed. Existing REMIT1 was updated.',
                Vendor);
    end;


    local procedure EnsureRemit1Exists(
        Vendor: Record Vendor)
    var
        RemitAddress: Record "Remit Address";
    begin
        // Wait until all required Vendor Card fields exist.
        if not HasRequiredVendorFields(Vendor) then begin
            LogVendor(
                'EA-REMIT-AUTO-INCOMPLETE',
                'Automatic REMIT1 creation skipped because Name, Address, City, State, or ZIP Code is incomplete.',
                Vendor);

            exit;
        end;

        // Only check for REMIT1.
        //
        // Other codes such as:
        // 081
        // REMIT
        // CHECK
        //
        // do not prevent REMIT1 creation.
        RemitAddress.Reset();
        RemitAddress.SetRange(
            "Vendor No.",
            Vendor."No.");

        RemitAddress.SetRange(
            Code,
            'REMIT1');

        if not RemitAddress.IsEmpty() then begin
            LogVendor(
                'EA-REMIT-AUTO-EXISTS',
                'Automatic REMIT1 creation skipped because REMIT1 already exists.',
                Vendor);

            exit;
        end;

        LogVendor(
            'EA-REMIT-AUTO-CREATE',
            'All required fields are populated and REMIT1 does not exist. Creating REMIT1.',
            Vendor);

        CreateRemitAddress(Vendor);

        ShowCreatedNotification(Vendor);

        LogVendor(
            'EA-REMIT-AUTO-COMPLETE',
            'REMIT1 was created automatically.',
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

        CopyVendorFieldsToRemitAddress(
            RemitAddress,
            Vendor);

        // Do not automatically make REMIT1
        // the default remit address.
        RemitAddress.Default := false;

        RemitAddress.Insert(true);
    end;


    local procedure UpdateRemitAddress(
        var RemitAddress: Record "Remit Address";
        Vendor: Record Vendor)
    begin
        CopyVendorFieldsToRemitAddress(
            RemitAddress,
            Vendor);

        // Intentionally preserve the existing Default value.
        //
        // Manual Sync REMIT1 only synchronizes Vendor Card
        // address/contact information.
        RemitAddress.Modify(true);
    end;


    local procedure CopyVendorFieldsToRemitAddress(
        var RemitAddress: Record "Remit Address";
        Vendor: Record Vendor)
    begin
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

        // "State" on the Vendor Card maps to County in AL.
        RemitAddress.Validate(
            County,
            Vendor.County);

        // "ZIP Code" on the Vendor Card maps to Post Code in AL.
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
    end;


    local procedure HasRequiredVendorFields(
        Vendor: Record Vendor): Boolean
    begin
        // Required fields:
        //
        // Name
        // Address
        // City
        // State
        // ZIP Code

        exit(
            (Vendor.Name <> '') and
            (Vendor.Address <> '') and
            (Vendor.City <> '') and
            (Vendor.County <> '') and
            (Vendor."Post Code" <> '')
        );
    end;


    local procedure RequiredVendorFieldsChanged(
        Vendor: Record Vendor;
        PreviousVendor: Record Vendor): Boolean
    begin
        exit(
            (Vendor.Name <> PreviousVendor.Name) or
            (Vendor.Address <> PreviousVendor.Address) or
            (Vendor.City <> PreviousVendor.City) or
            (Vendor.County <> PreviousVendor.County) or
            (
                Vendor."Post Code" <>
                PreviousVendor."Post Code"
            )
        );
    end;


    local procedure ShowCreatedNotification(
        Vendor: Record Vendor)
    var
        RemitNotification: Notification;
    begin
        RemitNotification.Message :=
            StrSubstNo(
                'REMIT1 remit address was created automatically for vendor %1 - %2.',
                Vendor."No.",
                Vendor.Name);

        RemitNotification.Scope :=
            NotificationScope::LocalScope;

        RemitNotification.Send();
    end;


    local procedure ShowSyncNotification(
        Vendor: Record Vendor;
        WasCreated: Boolean)
    var
        RemitNotification: Notification;
    begin
        if WasCreated then
            RemitNotification.Message :=
                StrSubstNo(
                    'REMIT1 was created and synced for vendor %1 - %2.',
                    Vendor."No.",
                    Vendor.Name)
        else
            RemitNotification.Message :=
                StrSubstNo(
                    'REMIT1 was updated from the Vendor Card for vendor %1 - %2.',
                    Vendor."No.",
                    Vendor.Name);

        RemitNotification.Scope :=
            NotificationScope::LocalScope;

        RemitNotification.Send();
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
            'REMIT1 Automation');
    end;
}