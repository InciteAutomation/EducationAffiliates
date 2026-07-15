pageextension 50103 "PCM Card Extension" extends "Purchase Credit Memo"
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
            field("Jaggaer PO Number"; Rec."Vendor Order No.")
            {
                ApplicationArea = All;
                Caption = 'Jaggaer PO Number';
            }
        }

    }
}