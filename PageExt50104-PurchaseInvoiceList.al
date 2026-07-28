pageextension 50104 "PI List Extension" extends "Purchase Invoices"
{
    layout
    {
        addafter("Vendor Invoice No.")
        {
            field("Jaggaer PO Number"; Rec."Vendor Order No.")
            {
                ApplicationArea = All;
                Caption = 'Jaggaer PO Number';
            }
            field("Jaegger IN NBR"; Rec."Your Reference")
            {
                ApplicationArea = All;
                Caption = 'Jaggaer IN NBR';
            }
            field("Created At"; Rec.SystemCreatedAt)
            {
                ApplicationArea = All;
                Caption = 'Created Date';
            }
        }
    }

    actions
    {
        addafter("P&osting")
        {
            action(PostSelectedWithoutVendorDimensions)
            {
                ApplicationArea = All;
                Caption = 'Post Selected Without Vendor Dimensions';
                ToolTip = 'Posts the selected purchase invoices without requiring COMPANY and REMIT dimensions.';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SelectedPurchaseHeader: Record "Purchase Header";
                    PurchaseHeader: Record "Purchase Header";
                    BypassPosting: Codeunit "Post Purch. Invoice No Dims";
                    InvoiceNumbers: List of [Code[20]];
                    InvoiceNo: Code[20];
                    PostingError: Text;
                    FailureDetails: TextBuilder;
                    PostedCount: Integer;
                    FailedCount: Integer;
                begin
                    CurrPage.SetSelectionFilter(SelectedPurchaseHeader);

                    SelectedPurchaseHeader.SetRange(
                        "Document Type",
                        SelectedPurchaseHeader."Document Type"::Invoice);

                    if SelectedPurchaseHeader.FindSet() then
                        repeat
                            InvoiceNumbers.Add(
                                SelectedPurchaseHeader."No.");
                        until SelectedPurchaseHeader.Next() = 0;

                    if InvoiceNumbers.Count() = 0 then
                        Error('Select at least one purchase invoice.');

                    if not Confirm(
                        'Post %1 selected purchase invoice(s) without the specified vendor dimensions?',
                        false,
                        InvoiceNumbers.Count())
                    then
                        exit;

                    foreach InvoiceNo in InvoiceNumbers do begin
                        Clear(PurchaseHeader);
                        Clear(PostingError);

                        if not PurchaseHeader.Get(
                            PurchaseHeader."Document Type"::Invoice,
                            InvoiceNo)
                        then begin
                            FailedCount += 1;

                            FailureDetails.AppendLine(
                                StrSubstNo(
                                    '%1: The purchase invoice could not be found.',
                                    InvoiceNo));

                            continue;
                        end;

                        if BypassPosting.TryPostInvoice(
                            PurchaseHeader,
                            PostingError)
                        then
                            PostedCount += 1
                        else begin
                            FailedCount += 1;

                            FailureDetails.AppendLine(
                                StrSubstNo(
                                    '%1: %2',
                                    InvoiceNo,
                                    PostingError));
                        end;
                    end;

                    CurrPage.Update(false);

                    if FailedCount = 0 then
                        Message(
                            '%1 purchase invoice(s) posted successfully.',
                            PostedCount)
                    else
                        Message(
                            '%1 invoice(s) posted successfully.\' +
                            '%2 invoice(s) failed.\' +
                            '%3',
                            PostedCount,
                            FailedCount,
                            FailureDetails.ToText());
                end;
            }
        }
    }
}