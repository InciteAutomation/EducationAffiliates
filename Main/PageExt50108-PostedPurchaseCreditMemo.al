pageextension 50108 "Posted PCM Card Extension" extends "Posted Purchase Credit Memo"
{
    layout
    {
        addafter("Vendor Cr. Memo No.")
        {
            field("Jaggaer IN NBR"; Rec."Your Reference")
            {
                ApplicationArea = All;
                Caption = 'Jaggaer IN NBR';
            }
        }
    }
}