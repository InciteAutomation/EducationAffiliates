page 50110 "Vendor API"
{
    PageType = API;

    APIVersion = 'v1.0';
    APIPublisher = 'InciteAutomation';
    APIGroup = 'vendorView';
    EntityName = 'vendor';
    EntitySetName = 'vendors';
    Caption = 'Vendor API';
    SourceTable = Vendor;
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
                field("Number"; Rec."No.")
                {
                    Caption = 'Vendor Number';
                }
                field("displayName"; Rec.Name)
                {
                    Caption = 'No.';
                }
                field("TaxId"; Rec."Federal ID No.")
                {
                    Caption = 'Posting Date';
                }

            }
        }
    }
}
