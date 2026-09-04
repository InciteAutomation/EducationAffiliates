codeunit 50109 "New Dimension Value Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", 'OnAfterInsertEvent', '', false, false)]
    local procedure DimensionValueOnAfterInsert(
        var Rec: Record "Dimension Value";
        RunTrigger: Boolean)
    begin
        if not IsSupportedDimension(Rec."Dimension Code") then
            exit;

        TriggerDimensionFlow(
            Rec."Dimension Code",
            Rec.Code,
            Rec.Name
        );
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", 'OnAfterModifyEvent', '', false, false)]
    local procedure DimensionValueOnAfterModify(
        var Rec: Record "Dimension Value";
        var xRec: Record "Dimension Value";
        RunTrigger: Boolean)
    begin
        if not IsSupportedDimension(Rec."Dimension Code") then
            exit;

        if not DimensionValueChanged(Rec, xRec) then
            exit;

        TriggerDimensionFlow(
            Rec."Dimension Code",
            Rec.Code,
            Rec.Name
        );
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterInsertEvent', '', false, false)]
    local procedure GLAccountOnAfterInsert(
        var Rec: Record "G/L Account";
        RunTrigger: Boolean)
    begin
        TriggerDimensionFlow(
            'Chart of Accounts',
            Rec."No.",
            Rec.Name
        );
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterModifyEvent', '', false, false)]
    local procedure GLAccountOnAfterModify(
        var Rec: Record "G/L Account";
        var xRec: Record "G/L Account";
        RunTrigger: Boolean)
    begin
        if not GLAccountChanged(Rec, xRec) then
            exit;

        TriggerDimensionFlow(
            'Chart of Accounts',
            Rec."No.",
            Rec.Name
        );
    end;

    local procedure IsSupportedDimension(DimensionCode: Code[20]): Boolean
    begin
        case DimensionCode of
            'COMPANY',
            'DEGREE',
            'DEPARTMENT',
            'SHIFT',
            'PROGRAM':
                exit(true);
        end;

        exit(false);
    end;

    local procedure DimensionValueChanged(
        DimensionValue: Record "Dimension Value";
        OldDimensionValue: Record "Dimension Value"): Boolean
    begin
        exit(
            (DimensionValue."Dimension Code" <> OldDimensionValue."Dimension Code") or
            (DimensionValue.Code <> OldDimensionValue.Code) or
            (DimensionValue.Name <> OldDimensionValue.Name)
        );
    end;

    local procedure GLAccountChanged(
        GLAccount: Record "G/L Account";
        OldGLAccount: Record "G/L Account"): Boolean
    begin
        exit(
            (GLAccount."No." <> OldGLAccount."No.") or
            (GLAccount.Name <> OldGLAccount.Name)
        );
    end;

    local procedure TriggerDimensionFlow(
        DimensionCode: Text;
        ValueCode: Text;
        ValueName: Text)
    var
        Http: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        Resp: HttpResponseMessage;
        JsonBody: JsonObject;
        FlowUrl: Text;
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSandbox() then
            FlowUrl := 'https://default40a96b834e8b4d89969e20067e90f4.ac.environment.api.powerplatform.com:443/powerautomate/automations/direct/cu/30/workflows/047714e5d63041bbafce17a15c5970ba/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=aezesA5C4mAfpshtrpUqBhCkuqiN6himniWz0rHRn6E'
        else
            FlowUrl := '';

        if FlowUrl = '' then
            exit;

        JsonBody.Add('dimensionCode', DimensionCode);
        JsonBody.Add('code', ValueCode);
        JsonBody.Add('name', ValueName);

        Content.WriteFrom(Format(JsonBody));

        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        if Http.Post(FlowUrl, Content, Resp) then begin
            if Resp.IsSuccessStatusCode() then
                Message(
                    'Sent %1 value to Power Automate: %2 - %3',
                    DimensionCode,
                    ValueCode,
                    ValueName
                )
            else
                Error(
                    'Power Automate call failed. Status %1. Response: %2',
                    Resp.HttpStatusCode(),
                    GetResponseText(Resp)
                );
        end else
            Error('Could not reach Power Automate endpoint.');
    end;

    local procedure GetResponseText(
        var Resp: HttpResponseMessage): Text
    var
        Body: Text;
    begin
        if Resp.Content().ReadAs(Body) then
            exit(Body);

        exit('');
    end;
}
