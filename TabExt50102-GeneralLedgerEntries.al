tableextension 50102 "General Ledger Entry" extends "G/L Entry"
{
    fields
    {
        field(50100; "Source Name"; Text[200])
        {
            FieldClass = FlowField;
            Caption = 'Source Name';
            CalcFormula = lookup(Vendor.Name WHERE("No." = field("Source No.")));
        }
        field(50101; "Purch Inv Your Reference"; Text[35])
        {
            Caption = 'Purch. Invoice Your Reference';
            FieldClass = FlowField;
            CalcFormula = lookup(
                "Purch. Inv. Header"."Your Reference"
                where("No." = field("Document No."))
            );
        }

        field(50102; "Purch Cr Memo Your Reference"; Text[35])
        {
            Caption = 'Purch. Credit Memo Your Reference';
            FieldClass = FlowField;
            CalcFormula = lookup(
                "Purch. Cr. Memo Hdr."."Your Reference"
                where("No." = field("Document No."))
            );
        }
        field(50103; "Reference Number"; Text[35])
        {
            Caption = 'Reference Number';

        }
    }
}