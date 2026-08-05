pageextension 50112 PageExtension50112 extends Microsoft.Finance.GeneralLedger.Journal."General Journal"
{
    layout
    {
        moveafter("Posting Date"; "Account No.")
        movebefore("Account No."; "Account Type")
        moveafter("Account No."; "Shortcut Dimension 1 Code")
        moveafter("Shortcut Dimension 1 Code"; "Shortcut Dimension 2 Code")
        moveafter("Shortcut Dimension 2 Code"; ShortcutDimCode3)
        moveafter(ShortcutDimCode3; ShortcutDimCode4)
        moveafter(ShortcutDimCode4; ShortcutDimCode5)
        moveafter(ShortcutDimCode5; "Your Reference")
        moveafter("Your Reference"; "Debit Amount73531")
        moveafter("Debit Amount73531"; "Credit Amount73531")
        moveafter("Credit Amount73531"; Description)
        moveafter(Description; "Amount (LCY)")
        moveafter("Amount (LCY)"; "Document No.")
    }
}
