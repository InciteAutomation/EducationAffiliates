codeunit 50104 "Purch. Dim. Bypass Events"
{
    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::DimensionManagement,
        'OnCheckDimValuePostingOnBeforeLogErrors',
        '',
        false,
        false)]
    local procedure BypassSelectedVendorDimensions(
        TempDefaultDim: Record "Default Dimension" temporary;
        var DimSetEntry: Record "Dimension Set Entry";
        var LastErrorMessage: Record "Error Message";
        var ErrorMessageMgt: Codeunit "Error Message Management";
        var IsHandled: Boolean)
    var
        BypassContext: Codeunit "Purch. Dim. Bypass Context";
    begin
        if not BypassContext.IsEnabled() then
            exit;

        // Only bypass default dimensions assigned to vendors.
        if TempDefaultDim."Table ID" <> Database::Vendor then
            exit;

        // Only bypass dimensions belonging to the vendor currently being posted.
        if TempDefaultDim."No." <> BypassContext.GetVendorNo() then
            exit;

        // Only bypass the specific custom dimensions.
        if not BypassContext.IsEnabledForAllVendors() then
            if TempDefaultDim."No." <> BypassContext.GetVendorNo() then
                exit;

        if not IsBypassDimension(TempDefaultDim."Dimension Code") then
            exit;

        IsHandled := true;
    end;

    [EventSubscriber(
    ObjectType::Codeunit,
    Codeunit::DimensionManagement,
    'OnBeforeCheckDimValuePosting',
    '',
    false,
    false)]
    local procedure BypassPaymentJournalDimValuePosting(
    TableID: array[10] of Integer;
    No: array[10] of Code[20];
    DimSetID: Integer;
    var IsChecked: Boolean;
    var IsHandled: Boolean;
    var DimensionSetEntry: Record "Dimension Set Entry")
    var
        BypassContext: Codeunit "Purch. Dim. Bypass Context";
    begin
        // Only active while using your custom payment-journal posting action.
        if not BypassContext.IsEnabledForAllVendors() then
            exit;

        // Only bypass checks where Vendor is one of the accounts being validated.
        if not ContainsVendor(TableID) then
            exit;

        /*
          Skip Business Central's vendor default-dimension validation
          for this journal line.
        */
        IsChecked := true;
        IsHandled := true;
    end;


    local procedure ContainsVendor(TableID: array[10] of Integer): Boolean
    var
        Index: Integer;
    begin
        for Index := 1 to ArrayLen(TableID) do
            if TableID[Index] = Database::Vendor then
                exit(true);

        exit(false);
    end;

    local procedure IsBypassDimension(DimensionCode: Code[20]): Boolean
    begin
        exit(
            DimensionCode in [
                'COMPANY',
                'REMIT1',
                'REMIT2',
                'REMIT3',
                'REMIT4',
                'REMIT5',
                'REMIT6',
                'REMIT7',
                'REMIT8',
                'REMIT9'
            ]);
    end;
}