pageextension 50105 "PCM List Extension" extends "Purchase Credit Memos"
{
    layout
    {
        addafter("Vendor Cr. Memo No.")
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