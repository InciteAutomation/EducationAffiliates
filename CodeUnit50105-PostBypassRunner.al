codeunit 50105 "Purch. Post Bypass Runner"
{
    TableNo = "Purchase Header";

    trigger OnRun()
    begin
        if (Rec."Document Type" <> Rec."Document Type"::Invoice) and (Rec."Document Type" <> Rec."Document Type"::"Credit Memo") then
            Error(
                'Document %1 must be a purchase invoice or credit memo.',
                Rec."No.");

        Codeunit.Run(Codeunit::"Purch.-Post (Yes/No)", Rec);
    end;
}