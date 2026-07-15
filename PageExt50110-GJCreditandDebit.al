pageextension 50110 PageExtension50110 extends Microsoft.Finance.GeneralLedger.Journal."General Journal"
{
    layout
    {
        addafter(Description)
        {
            field("Your Reference"; Rec."Your Reference")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        addafter("Posting Group")
        {
            field("Credit Amount73531"; Rec."Credit Amount")
            {
                ApplicationArea = All;
                Visible = true;
                Caption = 'Credit Amount';
            }
            field("Debit Amount73531"; Rec."Debit Amount")
            {
                ApplicationArea = All;
                Visible = true;
                Caption = 'Debit Amount';
            }
        }

        moveafter(Description; "Deferral Code")
    }
}