pageextension 50117 "G/L Entry Page" extends "General Ledger Entries"
{
    layout
    {
        addafter(Description)
        {
            field("Source Name"; Rec."Source Name")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        addafter("Entry No.")
        {
            field("Reference Number"; YourReference)
            {
                ApplicationArea = All;
                Caption = 'Reference Number';
                Editable = false;
            }
            /*
            field("Purch Inv Your Reference"; Rec."Purch Inv Your Reference")
            {
                ApplicationArea = All;
                Caption = 'Reference Number';
                Editable = false;
            }
            field("Purch Cr Memo Your Reference"; Rec."Purch Cr Memo Your Reference")
            {
                ApplicationArea = All;
                Caption = 'Reference Number';
                Editable = false;
            }
            */
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(
            "Purch Inv Your Reference",
            "Purch Cr Memo Your Reference"
        );

        if Rec."Purch Inv Your Reference" <> '' then
            YourReference := Rec."Purch Inv Your Reference"
        else
            YourReference := Rec."Purch Cr Memo Your Reference";
    end;

    var
        YourReference: Text[35];
}
