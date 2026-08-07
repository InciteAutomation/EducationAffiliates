codeunit 50107 "Payment Jnl. Bypass Runner"
{
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", Rec);
    end;
}