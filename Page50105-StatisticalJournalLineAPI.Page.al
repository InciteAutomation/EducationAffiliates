page 50105 "Statistical Journal Line API"
{
    PageType = API;

    APIVersion = 'v1.0';
    APIPublisher = 'InciteAutomation';
    APIGroup = 'statAccountJournal';
    EntityName = 'statisticalAccountJournalLine';
    EntitySetName = 'statisticalAccountJournalLines';
    Caption = 'Statistical Journal Line API';
    SourceTable = "Statistical Acc. Journal Line";
    ODataKeyFields = SystemId;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            group(Group)
            {
                field(SystemId; Rec.SystemId)
                {
                    Caption = 'System ID';
                }

                field(journalBatchName; batchName)
                {
                    Caption = 'Journal Batch Name';
                }

                field("lineNo"; Rec."Line No.")
                {
                    Caption = 'Line Number';
                }
                field(dimensionsJson; dimensionsJsonTxt)
                {
                    Caption = 'Dimension Values';
                }

                field("PostingDate"; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field("DocumentNo"; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field("statisticalAccountNo"; Rec."Statistical Account No.")
                {
                    Caption = 'Account No.';
                }
                field("description"; Rec.Description)
                {
                    Caption = 'Description';
                }
                field("amount"; Rec.Amount)
                {
                    Caption = 'Amount';
                }
                field("dimensionSetId"; Rec."Dimension Set ID")
                {
                    Caption = 'Dimension Set ID';
                }

            }
        }
    }

    var
        batchName: Code[10];
        dimensionsJsonTxt: Text;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        statLine: Record "Statistical Acc. Journal Line";
        journalBatch: Record "Statistical Acc. Journal Batch";
        DimMgt: Codeunit DimensionManagement;
        DimSetEntry: Record "Dimension Set Entry" temporary;
        DimSetID: Integer;

        JsonArr: JsonArray;
        JsonObj: JsonObject;
        JsonToken: JsonToken;
        DimCode: Code[20];
        DimValue: Code[20];
        ctoken: JsonToken;
        vtoken: JsonToken;
        i: Integer;
    begin
        if Rec."Journal Batch Name" = '' then begin
            journalBatch.SetRange(Name, batchName);
            if journalBatch.FindFirst() then begin
                Rec."Journal Batch Name" := journalBatch.Name;
                Rec."Journal Template Name" := journalBatch."Journal Template Name"
            end;
        end;

        if Rec."Line No." = 0 then begin
            statLine.Reset();
            statLine.SetRange("Journal Template Name", Rec."Journal Template Name");
            statLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");

            if statLine.FindLast() then
                Rec."Line No." := statLine."Line No." + 10000
            else
                Rec."Line No." := 10000;
        end;

        if dimensionsJsonTxt <> '' then begin
            JsonArr.ReadFrom(dimensionsJsonTxt);
            for i := 0 to JsonArr.Count() - 1 do begin
                JsonArr.Get(i, JsonToken);
                JsonObj := JsonToken.AsObject();

                Clear(DimCode);
                Clear(DimValue);

                if JsonObj.Get('code', ctoken) then
                    DimCode := CopyStr(ctoken.AsValue().AsCode(), 1, MaxStrLen(DimCode));

                if JsonObj.Get('value', vtoken) then
                    DimValue := CopyStr(vtoken.AsValue().AsCode(), 1, MaxStrLen(DimValue));

                DimSetEntry.Init();
                DimSetEntry.Validate("Dimension Code", DimCode);
                DimSetEntry.Validate("Dimension Value Code", DimValue);
                DimSetEntry.Insert();
            end;

            DimSetID := DimMgt.GetDimensionSetID(DimSetEntry);
            if DimSetID = 0 then
                exit(true);

            Rec.Validate("Dimension Set ID", DimSetID);
        end;
        exit(true);
    end;


}
