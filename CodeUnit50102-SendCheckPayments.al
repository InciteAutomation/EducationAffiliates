codeunit 50102 "SendCheckPayments"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterProcessLines', '', false, false)]
    local procedure OnAfterProcessLines(
        var TempGenJournalLine: Record "Gen. Journal Line" temporary;
        var GenJournalLine: Record "Gen. Journal Line";
        SuppressCommit: Boolean;
        PreviewMode: Boolean)
    var
        LinesArray: JsonArray;
        LineObject: JsonObject;
        PurchInvHeader: Record "Purch. Inv. Header";
        EnvironmentInformation: Codeunit "Environment Information";
        Http: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        Resp: HttpResponseMessage;
        Url: Text;
        PayloadObject: JsonObject;
        PayloadString: Text;
    begin


        if PreviewMode then
            exit;

        // Only the GENERAL / PAYMENT journal.
        if not ((GenJournalLine."Journal Template Name" = 'PAYMENT'))
        then
            exit;

        if EnvironmentInformation.IsSandbox() then
            Url := 'https://default40a96b834e8b4d89969e20067e90f4.ac.environment.api.powerplatform.com:443/powerautomate/automations/direct/cu/20/workflows/cafae806c1dc46fa90c518661a05cd02/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=Mof_n27eBYfFmmoGe9pTVxtqVHs3A6kfQvmL-joeSkM'
        else
            Url := 'https://default40a96b834e8b4d89969e20067e90f4.ac.environment.api.powerplatform.com:443/powerautomate/automations/direct/cu/14/workflows/e0f385e47b6d401ba2674414f89ccaca/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=-YopJUSBA6YEBdZLbfl4_WxarsgfamVgoJTG1s2T3Tk';

        if Url = '' then
            exit;

        TempGenJournalLine.Reset();

        if TempGenJournalLine.FindSet() then
            repeat
                // Only vendor check payment lines.
                if IsEligiblePaymentLine(TempGenJournalLine) then begin
                    Clear(LineObject);
                    Clear(PurchInvHeader);

                    if PurchInvHeader.Get(
                        TempGenJournalLine."Applies-to Doc. No.")
                    then begin
                        LineObject.Add(
                            'Ref Num',
                            PurchInvHeader."No.");

                        LineObject.Add(
                            'Invoice Number',
                            PurchInvHeader."Your Reference");

                        LineObject.Add(
                            'Supplier Invoice Number',
                            PurchInvHeader."Vendor Invoice No.");
                    end else begin
                        LineObject.Add(
                            'Ref Num',
                            TempGenJournalLine."Applies-to Doc. No.");

                        LineObject.Add(
                            'Invoice Number',
                            '');

                        LineObject.Add(
                            'Supplier Invoice Number',
                            '');
                    end;
                    LineObject.Add(
                        'Record Date',
                        TempGenJournalLine."Posting Date");

                    LineObject.Add(
                        'Record Number',
                        TempGenJournalLine."Document No.");

                    LineObject.Add(
                        'Payment Method',
                        TempGenJournalLine."Payment Method Code");

                    LinesArray.Add(LineObject);
                end;
            until TempGenJournalLine.Next() = 0;

        if LinesArray.Count() = 0 then
            exit;

        PayloadObject.Add('Posted Lines', LinesArray);
        PayloadObject.WriteTo(PayloadString);

        Content.WriteFrom(PayloadString);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        if Http.Post(Url, Content, Resp) then begin
            if Resp.IsSuccessStatusCode() then
                Message('Sent journal lines for Jaggaer processing')
            else
                Error(
                    'Flow call failed. Status %1. Response: %2',
                    Resp.HttpStatusCode(),
                    GetResponseText(Resp));
        end else
            Error('Could not reach flow endpoint.');
    end;

    local procedure IsEligiblePaymentLine(
        GenJournalLine: Record "Gen. Journal Line"): Boolean
    begin

        if GenJournalLine."Account Type" <>
           GenJournalLine."Account Type"::Vendor
        then
            exit(false);

        if GenJournalLine."Document Type" <>
           GenJournalLine."Document Type"::Payment
        then
            exit(false);

        if (GenJournalLine."Payment Method Code" = 'CHECK') or (GenJournalLine."Payment Method Code" = 'WIRE') or (GenJournalLine."Payment Method Code" = 'ACH') then begin
        end else
            exit(false);

        if GenJournalLine."Applies-to Doc. Type" <>
           GenJournalLine."Applies-to Doc. Type"::Invoice
        then
            exit(false);

        if GenJournalLine."Applies-to Doc. No." = '' then
            exit(false);

        exit(true);
    end;

    local procedure GetResponseText(
        var Resp: HttpResponseMessage): Text
    var
        Body: Text;
    begin
        if Resp.Content().ReadAs(Body) then
            exit(Body);

        exit('');
    end;


    /*

    // Code for testing on preview
        [EventSubscriber(
            ObjectType::Codeunit,
            Codeunit::"Gen. Jnl.-Post Batch",
            'OnBeforeThrowPreviewError',
            '',
            false,
            false)]
        local procedure OnBeforeThrowPreviewError(
            var GenJournalLine: Record "Gen. Journal Line";
            GLRegNo: Integer)
        var
            JournalLine: Record "Gen. Journal Line";
            LinesArray: JsonArray;
            LineObject: JsonObject;
            PurchInvHeader: Record "Purch. Inv. Header";
            EnvironmentInformation: Codeunit "Environment Information";
            Http: HttpClient;
            Content: HttpContent;
            Headers: HttpHeaders;
            Resp: HttpResponseMessage;
            Url: Text;
            PayloadObject: JsonObject;
            PayloadString: Text;
        begin
            // This event is only raised during preview posting,
            // immediately before BC finishes the preview process.

            if not (
                (GenJournalLine."Journal Template Name" = 'PAYMENT') and
                (GenJournalLine."Journal Batch Name" = 'GENERAL'))
            then
                exit;

            if EnvironmentInformation.IsSandbox() then
                Url :=
                    'https://default40a96b834e8b4d89969e20067e90f4.ac.environment.api.powerplatform.com:443/powerautomate/automations/direct/cu/20/workflows/cafae806c1dc46fa90c518661a05cd02/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=Mof_n27eBYfFmmoGe9pTVxtqVHs3A6kfQvmL-joeSkM'
            else
                Url := '';

            if Url = '' then
                exit;

            JournalLine.Reset();
            JournalLine.SetRange(
                "Journal Template Name",
                GenJournalLine."Journal Template Name");

            JournalLine.SetRange(
                "Journal Batch Name",
                GenJournalLine."Journal Batch Name");

            if JournalLine.FindSet() then
                repeat
                    if IsEligiblePaymentLine(JournalLine) then begin
                        Clear(LineObject);
                        Clear(PurchInvHeader);

                        if PurchInvHeader.Get(
                            JournalLine."Applies-to Doc. No.")
                        then begin
                            LineObject.Add(
                                'Ref Num',
                                PurchInvHeader."No.");

                            LineObject.Add(
                                'Invoice Number',
                                PurchInvHeader."Your Reference");

                            LineObject.Add(
                                'Supplier Invoice Number',
                                PurchInvHeader."Vendor Invoice No.");
                        end else begin
                            LineObject.Add(
                                'Ref Num',
                                JournalLine."Applies-to Doc. No.");

                            LineObject.Add(
                                'Invoice Number',
                                '');

                            LineObject.Add(
                                'Supplier Invoice Number',
                                '');
                        end;

                        LineObject.Add(
                            'Record Date',
                            JournalLine."Posting Date");

                        LineObject.Add(
                            'Record Number',
                            JournalLine."Document No.");

                        LineObject.Add(
                            'Payment Method',
                            JournalLine."Payment Method Code");

                        LinesArray.Add(LineObject);
                    end;
                until JournalLine.Next() = 0;

            if LinesArray.Count() = 0 then
                exit;

            PayloadObject.Add('Posted Lines', LinesArray);
            PayloadObject.WriteTo(PayloadString);

            Content.WriteFrom(PayloadString);
            Content.GetHeaders(Headers);
            Headers.Clear();
            Headers.Add('Content-Type', 'application/json');

            if not Http.Post(Url, Content, Resp) then
                Error('Could not reach flow endpoint.');

            if not Resp.IsSuccessStatusCode() then
                Error(
                    'Flow call failed. Status %1. Response: %2',
                    Resp.HttpStatusCode(),
                    GetResponseText(Resp));
        end;
        */
}
