pageextension 50110 PageExtension50110 extends Microsoft.Finance.GeneralLedger.Journal."General Journal"
{
    layout
    {
        addafter(ShortcutDimCode5)
        {
            field("Your Reference"; Rec."Your Reference")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        addafter("Your Reference")
        {
            field("Debit Amount73531"; Rec."Debit Amount")
            {
                ApplicationArea = All;
                Visible = true;
                Caption = 'Debit Amount';
            }
            field("Credit Amount73531"; Rec."Credit Amount")
            {
                ApplicationArea = All;
                Visible = true;
                Caption = 'Credit Amount';
            }
        }


    }
}