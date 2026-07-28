codeunit 50106 "Post Purch. Invoice No Dims"
{
    procedure PostInvoice(
        var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PostingError: Text;
    begin
        if not TryPostInvoice(PurchaseHeader, PostingError) then
            Error(
                'Purchase document %1 could not be posted.\%2',
                PurchaseHeader."No.",
                PostingError);

        exit(true);
    end;

    procedure TryPostInvoice(
        var PurchaseHeader: Record "Purchase Header";
        var PostingError: Text): Boolean
    var
        BypassContext: Codeunit "Purch. Dim. Bypass Context";
        PostingRunner: Codeunit "Purch. Post Bypass Runner";
        PostingSucceeded: Boolean;
        InvoiceNo: Code[20];
        DocumentNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
    begin
        Clear(PostingError);

        if (PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Invoice) and (PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::"Credit Memo")
        then begin
            PostingError :=
                StrSubstNo(
                    'Document %1 is not a purchase invoice or credit memo.',
                    PurchaseHeader."No.");
            exit(false);
        end;

        if PurchaseHeader."No." = '' then begin
            PostingError := 'The purchase document number is blank.';
            exit(false);
        end;

        if PurchaseHeader."Buy-from Vendor No." = '' then begin
            PostingError :=
                StrSubstNo(
                    'Purchase document %1 does not have a Buy-from Vendor No.',
                    PurchaseHeader."No.");
            exit(false);
        end;


        DocumentNo := PurchaseHeader."No.";
        DocumentType := PurchaseHeader."Document Type";

        /*
          The page action should save the record before calling this
          procedure. Commit is required because the Boolean form of
          Codeunit.Run cannot run with an active write transaction.
        */
        Commit();

        BypassContext.Enable(PurchaseHeader."Buy-from Vendor No.");

        ClearLastError();
        PostingSucceeded := PostingRunner.Run(PurchaseHeader);

        if not PostingSucceeded then
            PostingError := GetLastErrorText();

        // Always clear the bypass before returning.
        BypassContext.Disable();

        if not PostingSucceeded then
            exit(false);

        /*
          Confirm the open purchase invoice was removed after posting.
        */
        if PurchaseHeader.Get(DocumentType, DocumentNo)
        then begin
            PostingError :=
                StrSubstNo(
                    'Purchase invoice %1 was not removed after posting.',
                    DocumentNo);
            exit(false);
        end;

        exit(true);
    end;
}