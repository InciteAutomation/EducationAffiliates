pageextension 50203 "EA Vendor Card Remit Sync"
    extends "Vendor Card"
{
    actions
    {
        addlast(Processing)
        {
            action(SyncREMIT1)
            {
                ApplicationArea = All;
                Caption = 'Sync REMIT1';
                ToolTip = 'Creates the REMIT1 remit address if it does not exist, or updates the existing REMIT1 address using the current Vendor Card information.';
                Image = Refresh;

                trigger OnAction()
                var
                    AutoRemitAddress: Codeunit "EA Auto Remit Address";
                begin
                    CurrPage.SaveRecord();

                    AutoRemitAddress.SyncRemit1(Rec);
                end;
            }
        }

        addlast(Category_Process)
        {
            actionref(SyncREMIT1Promoted; SyncREMIT1)
            {
            }
        }
    }
}