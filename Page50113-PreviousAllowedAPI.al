page 50113 "Dim. Value per Account API"
{
    PageType = API;
    APIPublisher = 'InciteAutomation';
    APIGroup = 'dimensions';
    APIVersion = 'v1.0';
    EntityName = 'dimValuePerAccount';
    EntitySetName = 'dimValuesPerAccount';
    SourceTable = "Dim. Value per Account";
    ODataKeyFields = "Table ID", "No.", "Dimension Code", "Dimension Value Code";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Dim. Value per Account API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(tableId; Rec."Table ID") { }
                field(no; Rec."No.") { }
                field(dimensionCode; Rec."Dimension Code") { }
                field(dimensionValueCode; Rec."Dimension Value Code") { }
                field(dimensionValueName; Rec."Dimension Value Name") { }
                field(allowed; Rec.Allowed) { }
                field(previouslyAllowed; Rec."Previous Allowed Val") { }
            }
        }
    }
}