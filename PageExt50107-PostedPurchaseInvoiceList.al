pageextension 50107 "Posted PI List Extension" extends "Posted Purchase Invoices"
{
    layout
    {
        addafter("Shortcut Dimension 1 Code")
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
        }
    }
}