page 50101 "APIV2 - Journal Dim Set Lines"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Journal Dimension Set Line';
    EntitySetCaption = 'Journal Dimension Set Lines';
    DelayedInsert = true;
    EntityName = 'journalDimensionSetLine';
    EntitySetName = 'journalDimensionSetLines';
    APIPublisher = 'InciteAutomation';
    APIGroup = 'journalDimensions';
    PageType = API;
    SourceTable = "Dimension Set Entry Buffer";
    SourceTableTemporary = true;
    Extensible = false;
    ODataKeyFields = "Dimension Id";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec."Dimension Id")
                {
                    Caption = 'Id';

                    trigger OnValidate()
                    begin
                        if not GlobalDimension.GetBySystemId(Rec."Dimension Id") then
                            Error(DimensionIdDoesNotMatchADimensionErr);

                        Rec."Dimension Code" := GlobalDimension.Code;
                    end;
                }

                field(code; Rec."Dimension Code")
                {
                    Caption = 'Code';

                    trigger OnValidate()
                    begin
                        if GlobalDimension.Code <> '' then begin
                            if GlobalDimension.Code <> Rec."Dimension Code" then
                                Error(DimensionFieldsDontMatchErr);
                            exit;
                        end;

                        if not GlobalDimension.Get(Rec."Dimension Code") then
                            Error(DimensionCodeDoesNotMatchADimensionErr);

                        Rec."Dimension Id" := GlobalDimension.SystemId;
                    end;
                }

                field(consolidationCode; Rec."Dimension Consolidation Code")
                {
                    Caption = 'Consolidation Code';
                    Editable = false;
                }

                field(journalLineId; Rec."Parent Id")
                {
                    Caption = 'Journal Line Id';
                }

                field(displayName; Rec."Dimension Name")
                {
                    Caption = 'Display Name';
                    Editable = false;
                }

                field(valueId; GlobalDimensionValueId)
                {
                    Caption = 'Value Id';

                    trigger OnValidate()
                    begin
                        if not GlobalDimensionValue.GetBySystemId(GlobalDimensionValueId) then
                            Error(DimensionValueIdDoesNotMatchADimensionValueErr);

                        GlobalDimensionValueCode := GlobalDimensionValue.Code;
                    end;
                }

                field(valueCode; GlobalDimensionValueCode)
                {
                    Caption = 'Value Code';

                    trigger OnValidate()
                    begin
                        if GlobalDimensionValue.Code <> '' then begin
                            if GlobalDimensionValue.Code <> GlobalDimensionValueCode then
                                Error(DimensionValueFieldsDontMatchErr);
                            exit;
                        end;

                        if not GlobalDimensionValue.Get(Rec."Dimension Code", GlobalDimensionValueCode) then
                            Error(DimensionValueCodeDoesNotMatchADimensionValueErr);

                        GlobalDimensionValueId := GlobalDimensionValue.SystemId;
                    end;
                }

                field(valueConsolidationCode; Rec."Dim. Val. Consolidation Code")
                {
                    Caption = 'Dimension Value Consolidation Code';
                    Editable = false;
                }

                field(valueDisplayName; Rec."Dimension Value Name")
                {
                    Caption = 'Value Display Name';
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.Delete(true);
        SaveJournalDimensions(Rec.GetFilter("Parent Id"));
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        JournalLineIdFilter: Text;
    begin
        JournalLineIdFilter := Rec.GetFilter("Parent Id");
        if JournalLineIdFilter = '' then begin
            Rec.FilterGroup(4);
            JournalLineIdFilter := Rec.GetFilter("Parent Id");
            Rec.FilterGroup(0);

            if JournalLineIdFilter = '' then
                Error(JournalLineNotSpecifiedErr);
        end;

        exit(LoadLinesFromFilter(JournalLineIdFilter, false));
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        DimensionId: Guid;
        JournalLineIdFilter: Text;
    begin
        JournalLineIdFilter := Rec.GetFilter("Parent Id");
        if JournalLineIdFilter = '' then
            JournalLineIdFilter := Rec."Parent Id";

        if JournalLineIdFilter = '' then
            Error(JournalLineIdRequiredErr);

        Rec."Parent Id" := JournalLineIdFilter;
        Rec."Parent Type" := Rec."Parent Type"::"Journal Line";

        CheckIfValuesAreProperlyFilled();
        AssignDimensionValueToRecord();

        DimensionId := Rec."Dimension Id";
        Rec.Insert(true);

        LoadLinesFromFilter(JournalLineIdFilter, true);
        SaveJournalDimensions(JournalLineIdFilter);

        if not NewDimensionSet then
            LoadLinesFromFilter(JournalLineIdFilter, true);

        Rec.Get(JournalLineIdFilter, DimensionId);
        SetCalculatedFields();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Dimension: Record Dimension;
        JournalLineIdFilter: Text;
    begin
        JournalLineIdFilter := Rec.GetFilter("Parent Id");
        if JournalLineIdFilter = '' then
            JournalLineIdFilter := Rec."Parent Id";

        if JournalLineIdFilter = '' then
            Error(JournalLineIdRequiredErr);

        Dimension.Get(Rec."Dimension Code");
        if (xRec."Dimension Id" <> Rec."Dimension Id") or (xRec."Dimension Id" <> Dimension.SystemId) then
            Error(IdAndCodeCannotBeModifiedErr);

        Rec."Parent Id" := JournalLineIdFilter;
        Rec."Parent Type" := Rec."Parent Type"::"Journal Line";

        AssignDimensionValueToRecord();
        Rec.Modify(true);

        SaveJournalDimensions(JournalLineIdFilter);
        LoadLinesFromFilter(JournalLineIdFilter, false);
        Rec.Get(JournalLineIdFilter, Dimension.SystemId);
        SetCalculatedFields();

        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
        Rec."Parent Type" := Rec."Parent Type"::"Journal Line";
    end;

    var
        GlobalDimension: Record "Dimension";
        GlobalDimensionValue: Record "Dimension Value";
        GlobalDimensionValueId: Guid;
        GlobalDimensionValueCode: Code[20];
        LinesLoaded: Boolean;
        NewDimensionSet: Boolean;

        JournalLineNotSpecifiedErr: Label 'You must specify a journal line id to get dimension set lines.';
        JournalLineIdRequiredErr: Label 'The journalLineId field must be filled in.';
        JournalLineDoesNotExistErr: Label 'General journal line with ID %1 does not exist.';
        IdOrCodeShouldBeFilledErr: Label 'The "id" or "code" field must be filled in.', Comment = 'id and code are field names and should not be translated.';
        ValueIdOrValueCodeShouldBeFilledErr: Label 'The "valueId" or "valueCode" field must be filled in.', Comment = 'valueId and valueCode are field names and should not be translated.';
        IdAndCodeCannotBeModifiedErr: Label 'The "id" and "code" fields cannot be modified.', Comment = 'id and code are field names and should not be translated.';
        DimensionFieldsDontMatchErr: Label 'The dimension field values do not match to a specific Dimension.';
        DimensionIdDoesNotMatchADimensionErr: Label 'The "id" does not match to a Dimension.', Comment = 'id is a field name and should not be translated.';
        DimensionCodeDoesNotMatchADimensionErr: Label 'The "code" does not match to a Dimension.', Comment = 'code is a field name and should not be translated.';
        DimensionValueFieldsDontMatchErr: Label 'The values of the "valueCode" field and the "valueId" field do not refer to the same Dimension Value.', Comment = 'valueCode and valueId are field names and should not be translated.';
        DimensionValueIdDoesNotMatchADimensionValueErr: Label 'The "valueId" does not match to a Dimension Value.', Comment = 'valueId is a field name and should not be translated.';
        DimensionValueCodeDoesNotMatchADimensionValueErr: Label 'The "valueCode" does not match to a Dimension Value.', Comment = 'valueCode is a field name and should not be translated.';
        RecordAlreadyExistErr: Label 'The dimension set line already exists on this journal line.';

    local procedure LoadLinesFromFilter(JournalLineIdFilter: Text; IsInsert: Boolean): Boolean
    var
        FilterView: Text;
    begin
        if not LinesLoaded then begin
            FilterView := Rec.GetView();
            LoadLinesFromJournalLineId(JournalLineIdFilter, IsInsert);
            Rec.SetView(FilterView);
            if not Rec.FindFirst() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    local procedure LoadLinesFromJournalLineId(JournalLineIdFilter: Text; IsInsert: Boolean)
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        Dimension: Record Dimension;
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetId: Integer;
    begin
        if not GenJournalLine.GetBySystemId(JournalLineIdFilter) then
            Error(JournalLineDoesNotExistErr, JournalLineIdFilter);

        DimensionSetId := GenJournalLine."Dimension Set ID";
        if DimensionSetId = 0 then begin
            NewDimensionSet := true;
            exit;
        end;

        TempDimensionSetEntry.SetAutoCalcFields("Dimension Name", "Dimension Value Name");
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, DimensionSetId);

        if not TempDimensionSetEntry.Find('-') then
            exit;

        repeat
            if IsInsert then begin
                Dimension.Get(TempDimensionSetEntry."Dimension Code");
                if Rec.Get(JournalLineIdFilter, Dimension.SystemId) then
                    Error(RecordAlreadyExistErr);
            end;

            Clear(Rec);
            Rec.TransferFields(TempDimensionSetEntry, true);
            Rec."Parent Id" := JournalLineIdFilter;
            Rec."Parent Type" := Rec."Parent Type"::"Journal Line";
            Rec.Insert(true);
        until TempDimensionSetEntry.Next() = 0;
    end;

    local procedure SaveJournalDimensions(JournalLineIdFilter: Text)
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        DimensionManagement: Codeunit DimensionManagement;
    begin
        if not GenJournalLine.GetBySystemId(JournalLineIdFilter) then
            Error(JournalLineDoesNotExistErr, JournalLineIdFilter);

        Rec.Reset();
        Rec.SetRange("Parent Id", JournalLineIdFilter);

        if Rec.FindFirst() then
            repeat
                TempDimensionSetEntry.TransferFields(Rec, true);
                TempDimensionSetEntry."Dimension Set ID" := 0;
                TempDimensionSetEntry.Insert(true);
            until Rec.Next() = 0;

        GenJournalLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
        DimensionManagement.UpdateGlobalDimFromDimSetID(
            GenJournalLine."Dimension Set ID",
            GenJournalLine."Shortcut Dimension 1 Code",
            GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine.Modify(true);
    end;

    local procedure CheckIfValuesAreProperlyFilled()
    begin
        if Rec."Dimension Code" = '' then
            Error(IdOrCodeShouldBeFilledErr);

        if IsNullGuid(GlobalDimensionValueId) and (GlobalDimensionValueCode = '') then
            Error(ValueIdOrValueCodeShouldBeFilledErr);
    end;

    local procedure AssignDimensionValueToRecord()
    begin
        if not IsNullGuid(GlobalDimensionValueId) then
            Rec.Validate("Value Id", GlobalDimensionValueId);

        if GlobalDimensionValueCode <> '' then
            Rec.Validate("Dimension Value Code", GlobalDimensionValueCode);
    end;

    local procedure SetCalculatedFields()
    begin
        GlobalDimensionValueId := Rec."Value Id";
        GlobalDimensionValueCode := Rec."Dimension Value Code";
    end;

    local procedure ClearCalculatedFields()
    var
        FilterView: Text;
    begin
        Clear(GlobalDimension);
        Clear(GlobalDimensionValue);
        Clear(GlobalDimensionValueId);
        Clear(GlobalDimensionValueCode);
        Clear(NewDimensionSet);
        Clear(LinesLoaded);

        FilterView := Rec.GetView();
        Rec.Reset();
        Rec.DeleteAll();
        Rec.SetView(FilterView);
    end;
}