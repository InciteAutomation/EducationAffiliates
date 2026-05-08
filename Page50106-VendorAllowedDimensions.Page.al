page 50125 "Vendor Allowed Dim Values API"
{
    PageType = API;
    APIPublisher = 'InciteAutomation';
    APIGroup = 'allowedvalues';
    APIVersion = 'v1.0';
    EntityName = 'vendorAllowedDimensionValue';
    EntitySetName = 'vendorAllowedDimensionValues';
    Caption = 'Vendor Allowed Dimension Values API';
    SourceTable = "Dim. Value per Account";
    DelayedInsert = true;
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(tableId; Rec."Table ID")
                {
                    Caption = 'Table ID';
                }
                field(accountNo; Rec."No.")
                {
                    Caption = 'Account No.';
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code';
                }
                field(dimensionValueCode; Rec."Dimension Value Code")
                {
                    Caption = 'Dimension Value Code';
                }
                field(allowedValue; Rec.Allowed)
                {
                    Caption = 'Allowed';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Table ID", Database::Vendor);
    end;
}