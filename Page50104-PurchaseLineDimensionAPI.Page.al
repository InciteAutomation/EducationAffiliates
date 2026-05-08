page 50103 "Purch Inv Dim Set Lines"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Purchase Invoice Dimension Set Line';
    EntitySetCaption = 'Purchase Invoice Dimension Set Lines';
    DelayedInsert = true;
    EntityName = 'purchaseInvoiceDimensionSetLine';
    EntitySetName = 'purchaseInvoiceDimensionSetLines';
    APIPublisher = 'InciteAutomation';
    APIGroup = 'purchaseInvoiceDimensions';
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

                field(purchaseInvoiceLineId; Rec."Parent Id")
                {
                    Caption = 'Purchase Invoice Line Id';
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
        SavePurchaseInvoiceDimensions(Rec.GetFilter("Parent Id"));
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        PurchaseInvoiceLineIdFilter: Text;
    begin
        PurchaseInvoiceLineIdFilter := Rec.GetFilter("Parent Id");
        if PurchaseInvoiceLineIdFilter = '' then begin
            Rec.FilterGroup(4);
            PurchaseInvoiceLineIdFilter := Rec.GetFilter("Parent Id");
            Rec.FilterGroup(0);

            if PurchaseInvoiceLineIdFilter = '' then
                Error(PurchaseInvoiceLineNotSpecifiedErr);
        end;

        exit(LoadLinesFromFilter(PurchaseInvoiceLineIdFilter, false));
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        DimensionId: Guid;
        PurchaseInvoiceLineIdFilter: Text;
    begin
        PurchaseInvoiceLineIdFilter := Rec.GetFilter("Parent Id");
        if PurchaseInvoiceLineIdFilter = '' then
            PurchaseInvoiceLineIdFilter := Rec."Parent Id";

        if PurchaseInvoiceLineIdFilter = '' then
            Error(PurchaseInvoiceLineIdRequiredErr);

        Rec."Parent Id" := PurchaseInvoiceLineIdFilter;
        Rec."Parent Type" := Rec."Parent Type"::"Purchase Invoice Line";

        CheckIfValuesAreProperlyFilled();
        AssignDimensionValueToRecord();

        DimensionId := Rec."Dimension Id";
        Rec.Insert(true);

        LoadLinesFromFilter(PurchaseInvoiceLineIdFilter, true);
        SavePurchaseInvoiceDimensions(PurchaseInvoiceLineIdFilter);

        if not NewDimensionSet then
            LoadLinesFromFilter(PurchaseInvoiceLineIdFilter, true);

        Rec.Get(PurchaseInvoiceLineIdFilter, DimensionId);
        SetCalculatedFields();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Dimension: Record Dimension;
        PurchaseInvoiceLineIdFilter: Text;
    begin
        PurchaseInvoiceLineIdFilter := Rec.GetFilter("Parent Id");
        if PurchaseInvoiceLineIdFilter = '' then
            PurchaseInvoiceLineIdFilter := Rec."Parent Id";

        if PurchaseInvoiceLineIdFilter = '' then
            Error(PurchaseInvoiceLineIdRequiredErr);

        Dimension.Get(Rec."Dimension Code");
        if (xRec."Dimension Id" <> Rec."Dimension Id") or (xRec."Dimension Id" <> Dimension.SystemId) then
            Error(IdAndCodeCannotBeModifiedErr);

        Rec."Parent Id" := PurchaseInvoiceLineIdFilter;
        Rec."Parent Type" := Rec."Parent Type"::"Purchase Invoice Line";

        AssignDimensionValueToRecord();
        Rec.Modify(true);

        SavePurchaseInvoiceDimensions(PurchaseInvoiceLineIdFilter);
        LoadLinesFromFilter(PurchaseInvoiceLineIdFilter, false);
        Rec.Get(PurchaseInvoiceLineIdFilter, Dimension.SystemId);
        SetCalculatedFields();

        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
        Rec."Parent Type" := Rec."Parent Type"::"Purchase Invoice Line";
    end;

    var
        GlobalDimension: Record "Dimension";
        GlobalDimensionValue: Record "Dimension Value";
        GlobalDimensionValueId: Guid;
        GlobalDimensionValueCode: Code[20];
        LinesLoaded: Boolean;
        NewDimensionSet: Boolean;

        PurchaseInvoiceLineNotSpecifiedErr: Label 'You must specify a purchase invoice line id to get dimension set lines.';
        PurchaseInvoiceLineIdRequiredErr: Label 'The purchaseInvoiceLineId field must be filled in.';
        PurchaseInvoiceLineDoesNotExistErr: Label 'Purchase invoice line with ID %1 does not exist.';
        PurchaseInvoiceLineWrongTypeErr: Label 'Purchase line with ID %1 is not an invoice line.';
        IdOrCodeShouldBeFilledErr: Label 'The "id" or "code" field must be filled in.', Comment = 'id and code are field names and should not be translated.';
        ValueIdOrValueCodeShouldBeFilledErr: Label 'The "valueId" or "valueCode" field must be filled in.', Comment = 'valueId and valueCode are field names and should not be translated.';
        IdAndCodeCannotBeModifiedErr: Label 'The "id" and "code" fields cannot be modified.', Comment = 'id and code are field names and should not be translated.';
        DimensionFieldsDontMatchErr: Label 'The dimension field values do not match to a specific Dimension.';
        DimensionIdDoesNotMatchADimensionErr: Label 'The "id" does not match to a Dimension.', Comment = 'id is a field name and should not be translated.';
        DimensionCodeDoesNotMatchADimensionErr: Label 'The "code" does not match to a Dimension.', Comment = 'code is a field name and should not be translated.';
        DimensionValueFieldsDontMatchErr: Label 'The values of the "valueCode" field and the "valueId" field do not refer to the same Dimension Value.', Comment = 'valueCode and valueId are field names and should not be translated.';
        DimensionValueIdDoesNotMatchADimensionValueErr: Label 'The "valueId" does not match to a Dimension Value.', Comment = 'valueId is a field name and should not be translated.';
        DimensionValueCodeDoesNotMatchADimensionValueErr: Label 'The "valueCode" does not match to a Dimension Value.', Comment = 'valueCode is a field name and should not be translated.';
        RecordAlreadyExistErr: Label 'The dimension set line already exists on this purchase invoice line.';

    local procedure LoadLinesFromFilter(PurchaseInvoiceLineIdFilter: Text; IsInsert: Boolean): Boolean
    var
        FilterView: Text;
    begin
        if not LinesLoaded then begin
            FilterView := Rec.GetView();
            LoadLinesFromPurchaseInvoiceLineId(PurchaseInvoiceLineIdFilter, IsInsert);
            Rec.SetView(FilterView);
            if not Rec.FindFirst() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    local procedure LoadLinesFromPurchaseInvoiceLineId(PurchaseInvoiceLineIdFilter: Text; IsInsert: Boolean)
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        PurchaseLine: Record "Purchase Line";
        Dimension: Record Dimension;
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetId: Integer;
    begin
        if not PurchaseLine.GetBySystemId(PurchaseInvoiceLineIdFilter) then
            Error(PurchaseInvoiceLineDoesNotExistErr, PurchaseInvoiceLineIdFilter);

        if PurchaseLine."Document Type" <> PurchaseLine."Document Type"::Invoice then
            Error(PurchaseInvoiceLineWrongTypeErr, PurchaseInvoiceLineIdFilter);

        DimensionSetId := PurchaseLine."Dimension Set ID";
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
                if Rec.Get(PurchaseInvoiceLineIdFilter, Dimension.SystemId) then
                    Error(RecordAlreadyExistErr);
            end;

            Clear(Rec);
            Rec.TransferFields(TempDimensionSetEntry, true);
            Rec."Parent Id" := PurchaseInvoiceLineIdFilter;
            Rec."Parent Type" := Rec."Parent Type"::"Purchase Invoice Line";
            Rec.Insert(true);
        until TempDimensionSetEntry.Next() = 0;
    end;

    local procedure SavePurchaseInvoiceDimensions(PurchaseInvoiceLineIdFilter: Text)
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        PurchaseLine: Record "Purchase Line";
        DimensionManagement: Codeunit DimensionManagement;
    begin
        if not PurchaseLine.GetBySystemId(PurchaseInvoiceLineIdFilter) then
            Error(PurchaseInvoiceLineDoesNotExistErr, PurchaseInvoiceLineIdFilter);

        if PurchaseLine."Document Type" <> PurchaseLine."Document Type"::Invoice then
            Error(PurchaseInvoiceLineWrongTypeErr, PurchaseInvoiceLineIdFilter);

        Rec.Reset();
        Rec.SetRange("Parent Id", PurchaseInvoiceLineIdFilter);

        if Rec.FindFirst() then
            repeat
                TempDimensionSetEntry.TransferFields(Rec, true);
                TempDimensionSetEntry."Dimension Set ID" := 0;
                TempDimensionSetEntry.Insert(true);
            until Rec.Next() = 0;

        PurchaseLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
        DimensionManagement.UpdateGlobalDimFromDimSetID(
            PurchaseLine."Dimension Set ID",
            PurchaseLine."Shortcut Dimension 1 Code",
            PurchaseLine."Shortcut Dimension 2 Code");
        PurchaseLine.Modify(true);
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