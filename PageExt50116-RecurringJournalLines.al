pageextension 50116 "Recurring General Journal" extends Microsoft.Finance.GeneralLedger.Journal."Recurring General Journal"
{
    layout
    {
        moveafter("Posting Date"; "Account No.")
        moveafter("Account No."; "Shortcut Dimension 1 Code")
        moveafter("Shortcut Dimension 1 Code"; "Shortcut Dimension 2 Code")
        moveafter("Document Date"; ShortcutDimCode3)
        moveafter(ShortcutDimCode3; ShortcutDimCode4)
        moveafter(ShortcutDimCode4; ShortcutDimCode5)
        addafter(ShortcutDimCode5)
        {
            field("Your Reference52519"; Rec."Your Reference")
            {
                ApplicationArea = All;
            }
            field("Debit Amount15588"; Rec."Debit Amount")
            {
                ApplicationArea = All;
            }
            field("Credit Amount71470"; Rec."Credit Amount")
            {
                ApplicationArea = All;
            }
        }
        moveafter("Credit Amount71470"; Description)
        moveafter("Document No."; "Document Type")
        moveafter(Description; "Amount (LCY)")
    }
}
