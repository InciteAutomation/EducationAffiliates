page 50116 "Purchase Document Remit API"
{
    PageType = API;

    APIVersion = 'v1.1';
    APIPublisher = 'InciteAutomation';
    APIGroup = 'purchaseremit';
    EntityName = 'purchaseInvoice';
    EntitySetName = 'purchaseInvoices';
    Caption = 'Purchase Invoice Remit API';
    SourceTable = "Purchase Header";
    SourceTableView = where("Document Type" = const(Invoice));
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
                field("Num"; Rec."No.")
                {
                    Caption = 'No.';
                }
                field("VendorNo"; Rec."Buy-from Vendor No.")
                {
                    Caption = 'Vendor No.';
                }
                field("remitToCode"; Rec."Remit-to Code")
                {
                    Caption = 'Remit-To Code';
                    trigger OnValidate()
                    begin
                        Rec.Validate("Remit-to Code");
                    end;
                }
            }
        }
    }
}
