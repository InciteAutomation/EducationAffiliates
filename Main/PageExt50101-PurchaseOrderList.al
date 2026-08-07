pageextension 50101 "PO List Extension" extends "Purchase Order List"
{
    layout
    {
        modify("Vendor Order No.")
        {
            Caption = 'Jaggaer PO Number';
        }

        addafter("Amount Including VAT")
        {
            field("Created At"; Rec.SystemCreatedAt)
            {
                ApplicationArea = All;
                Caption = 'Created Date';
            }
        }
    }
}