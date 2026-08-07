codeunit 50103 "Purch. Dim. Bypass Context"
{
    SingleInstance = true;

    var
        BypassEnabled: Boolean;
        BypassAllVendors: Boolean;
        CurrentVendorNo: Code[20];

    procedure Enable(VendorNo: Code[20])
    begin
        BypassEnabled := true;
        BypassAllVendors := false;
        CurrentVendorNo := VendorNo;
    end;

    procedure EnableForJournal()
    begin
        BypassEnabled := true;
        BypassAllVendors := true;
        Clear(CurrentVendorNo);
    end;

    procedure Disable()
    begin
        BypassEnabled := false;
        BypassAllVendors := false;
        Clear(CurrentVendorNo);
    end;

    procedure IsEnabled(): Boolean
    begin
        exit(BypassEnabled);
    end;

    procedure IsEnabledForAllVendors(): Boolean
    begin
        exit(BypassEnabled and BypassAllVendors);
    end;

    procedure GetVendorNo(): Code[20]
    begin
        exit(CurrentVendorNo);
    end;
}