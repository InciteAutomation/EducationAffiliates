pageextension 50109 "Posted PCM List Extension" extends "Posted Purchase Credit Memos"
{
    layout
    {
        addafter("Due Date")
        {
            field("Vendor Cr. Memo No."; Rec."Vendor Cr. Memo No.")
            {
                ApplicationArea = All;
            }
            field("Jaegger IN NBR"; Rec."Your Reference")
            {
                ApplicationArea = All;
                Caption = 'Jaggaer IN NBR';
            }
        }
    }
}