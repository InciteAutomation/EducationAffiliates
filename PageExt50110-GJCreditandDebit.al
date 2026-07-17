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

        moveafter(Description; "Deferral Code")
        moveafter("Posting Date"; "Shortcut Dimension 1 Code")
        moveafter("Shortcut Dimension 1 Code"; "Account No.")
        moveafter("Account No."; "Shortcut Dimension 2 Code")
        moveafter("Shortcut Dimension 2 Code"; ShortcutDimCode3)
        moveafter(ShortcutDimCode3; ShortcutDimCode4)
        moveafter(ShortcutDimCode4; ShortcutDimCode5)
        //moveafter(ShortcutDimCode5; "Your Reference")
        //moveafter("Your Reference"; "Debit Amount73531")
        //moveafter("Debit Amount73531"; "Credit Amount73531")
        moveafter("Credit Amount73531"; Description)
        moveafter(Description; "Amount (LCY)")
        moveafter("Amount (LCY)"; "Document No.")
    }
}