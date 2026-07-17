pageextension 50104 "PI List Extension" extends "Purchase Invoices"
{
    layout
    {
        addafter("Vendor Invoice No.")
        {
            field("Jaggaer PO Number"; Rec."Vendor Order No.")
            {
                ApplicationArea = All;
                Caption = 'Jaggaer PO Number';
            }
            field("Jaegger IN NBR"; Rec."Your Reference")
            {
                ApplicationArea = All;
                Caption = 'Jaggaer IN NBR';
            }
            field("Created At"; Rec.SystemCreatedAt)
            {
                ApplicationArea = All;
                Caption = 'Created Date';
            }
        }
    }
}