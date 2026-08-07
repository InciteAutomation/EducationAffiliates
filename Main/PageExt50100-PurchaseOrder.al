pageextension 50100 "PO Card Extension" extends "Purchase Order"
{
    layout
    {
        modify("Vendor Order No.")
        {
            Caption = 'Jaggaer PO Number';
        }
    }
}