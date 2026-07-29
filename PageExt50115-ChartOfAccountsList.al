pageextension 50115 "Chart Of Accounts Add Blocked" extends Microsoft.Finance.GeneralLedger.Account."Chart of Accounts"
{
    layout
    {
        addafter("Account Type")
        {
            field(Blocked82256; Rec.Blocked)
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}
