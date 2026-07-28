codeunit 50108 "Post Payment Jnl. No Dims"
{
    procedure PostJournalBatch(
        var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        PostingError: Text;
    begin
        if not TryPostJournalBatch(GenJournalLine, PostingError) then
            Error(
                'The payment journal could not be posted.\%1',
                PostingError);

        exit(true);
    end;

    procedure TryPostJournalBatch(
        var GenJournalLine: Record "Gen. Journal Line";
        var PostingError: Text): Boolean
    var
        BypassContext: Codeunit "Purch. Dim. Bypass Context";
        PostingRunner: Codeunit "Payment Jnl. Bypass Runner";
        PostingSucceeded: Boolean;
    begin
        Clear(PostingError);

        if GenJournalLine."Journal Template Name" = '' then begin
            PostingError := 'The journal template name is blank.';
            exit(false);
        end;

        if GenJournalLine."Journal Batch Name" = '' then begin
            PostingError := 'The journal batch name is blank.';
            exit(false);
        end;

        Commit();

        // Bypass the selected dimensions for every vendor in this batch.
        BypassContext.EnableForJournal();

        ClearLastError();
        PostingSucceeded := PostingRunner.Run(GenJournalLine);

        if not PostingSucceeded then
            PostingError := GetLastErrorText();

        // Disable the bypass after posting
        BypassContext.Disable();

        exit(PostingSucceeded);
    end;
}