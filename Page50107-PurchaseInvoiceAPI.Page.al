page 50107 "Purchase Invoice API"
{
    PageType = API;

    APIVersion = 'v1.0';
    APIPublisher = 'InciteAutomation';
    APIGroup = 'purchaseinvoice';
    EntityName = 'purchaseInvoice';
    EntitySetName = 'purchaseInvoices';
    Caption = 'Purchase Invoice API';
    SourceTable = "Purchase Header";
    SourceTableView = where("Document Type" = const(Invoice));

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
                field("InvoiceDate"; Rec."Order Date")
                {
                    Caption = 'Invoice Date';
                }

                field("Num"; Rec."No.")
                {
                    Caption = 'No.';
                }
                field("PostingDate"; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field("VendorNo"; Rec."Buy-from Vendor No.")
                {
                    Caption = 'Vendor No.';
                }
                field("ShipToCode"; Rec."Ship-to Code")
                {
                    Caption = 'Ship To Code';
                }
                field("LocationCode"; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field("ShiptoAddress"; Rec."Ship-to Address")
                {
                    Caption = 'Ship To Address Line 1';
                }
                field("ShiptoAddress2"; Rec."Ship-to Address 2")
                {
                    Caption = 'Ship to Address Line 2';
                }
                field("ShiptoCity"; Rec."Ship-to City")
                {
                    Caption = 'Ship To City';
                }
                field("ShiptoRegionCode"; Rec."Ship-to Country/Region Code")
                {
                    Caption = 'Ship To Country/Region';
                }
                field("ShiptoState"; Rec."Ship-to County")
                {
                    Caption = 'Ship To State';
                }
                field("ShipToZipCode"; Rec."Ship-to Post Code")
                {
                    Caption = 'Ship To Zip Code';
                }
                field("CompanyCode"; Rec."Shortcut Dimension 1 Code")
                {
                    Caption = 'Company Dimension Code';
                }
                field("PaymentTermsCode"; Rec."Payment Terms Code")
                {
                    Caption = 'Payment Terms Code';
                }
                field("VendorInvoiceNo"; Rec."Vendor Invoice No.")
                {
                    Caption = 'Vendor Invoice Number';
                }
                field("VendorOrderNo"; Rec."Vendor Order No.")
                {
                    Caption = 'Vendor Order Number';
                }
                field("DueDate"; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field("YourRef"; Rec."Your Reference")
                {
                    Caption = 'Your Reference';
                }
            }
        }
    }
}
