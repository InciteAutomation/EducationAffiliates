pageextension 50113 "Payment Journal Dim Bypass" extends "Payment Journal"
{
    actions
    {
        addafter(Post)
        {
            action(PostWithoutVendorDimensions)
            {
                ApplicationArea = All;
                Caption = 'Post NEW';
                ToolTip =
                    'Posts all lines in the current payment journal batch without requiring COMPANY and REMIT1 through REMIT5 vendor dimensions.';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    GenJournalLine: Record "Gen. Journal Line";
                    PaymentJournalPosting: Codeunit "Post Payment Jnl. No Dims";
                begin
                    CurrPage.SaveRecord();

                    GenJournalLine.SetRange(
                        "Journal Template Name",
                        Rec."Journal Template Name");

                    GenJournalLine.SetRange(
                        "Journal Batch Name",
                        Rec."Journal Batch Name");

                    if not GenJournalLine.FindFirst() then
                        Error(
                            'There are no lines in journal batch %1.',
                            Rec."Journal Batch Name");

                    PaymentJournalPosting.PostJournalBatch(GenJournalLine);

                    CurrPage.Update(false);

                    Message(
                        'Payment journal batch %1 was posted successfully.',
                        GenJournalLine."Journal Batch Name");
                end;
            }
        }
    }
}