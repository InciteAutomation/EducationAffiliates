tableextension 50101 "Customer Dim Allowed Extension" extends "Dim. Value per Account"
{
    fields
    {
        field(50100; "Previous Allowed Val"; Boolean)
        {
            Caption = 'Previously Allowed';
        }
    }
}