codeunit 50101 "Dim. Value per Account Sub."
{
    [EventSubscriber(ObjectType::Table, Database::"Dim. Value per Account", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnBeforeModifyDimValuePerAccount(var Rec: Record "Dim. Value per Account"; var XRec: Record "Dim. Value per Account"; RunTrigger: Boolean)
    var
        OldRec: Record "Dim. Value per Account";
    begin
        if Rec."Dimension Code" <> 'COMPANY' then
            exit;

        if not OldRec.Get(Rec."Table ID", Rec."No.", Rec."Dimension Code", Rec."Dimension Value Code") then
            exit;

        // Only stamp when Allowed actually changes
        if XRec.Allowed = Rec.Allowed then
            exit;

        Rec."Previous Allowed Val" := XRec.Allowed;


    end;
}