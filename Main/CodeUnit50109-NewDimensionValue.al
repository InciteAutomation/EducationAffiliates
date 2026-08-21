codeunit 50109 "New Dimension Value Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", 'OnAfterInsertEvent', '', false, false)]
    local procedure DimensionValueOnAfterInsert(var Rec: Record "Dimension Value"; RunTrigger: Boolean)
    begin
        if (Rec."Dimension Code" <> 'COMPANY') and (Rec."Dimension Code" <> 'DEGREE') and (Rec."Dimension Code" <> 'DEPARTMENT') and (Rec."Dimension Code" <> 'SHIFT') and (Rec."Dimension Code" <> 'PROGRAM') then
            exit;

        TriggerDimensionFlow(Rec);
    end;

    local procedure TriggerDimensionFlow(DimensionValue: Record "Dimension Value")
    var
        Http: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        Resp: HttpResponseMessage;
        JsonBody: JsonObject;
        ResponseText: Text;
        FlowUrl: Text;
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if (EnvironmentInformation.IsSandbox()) and (EnvironmentInformation.GetEnvironmentName() = 'Sandbox') then
            FlowUrl := 'https://default40a96b834e8b4d89969e20067e90f4.ac.environment.api.powerplatform.com:443/powerautomate/automations/direct/cu/30/workflows/047714e5d63041bbafce17a15c5970ba/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=aezesA5C4mAfpshtrpUqBhCkuqiN6himniWz0rHRn6E'
        else
            FlowUrl := '';

        if FlowUrl = '' then
            exit;

        JsonBody.Add('dimensionCode', DimensionValue."Dimension Code");
        JsonBody.Add('code', DimensionValue.Code);
        JsonBody.Add('name', DimensionValue.Name);

        Content.WriteFrom(Format(JsonBody));

        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        if Http.Post(FlowUrl, Content, Resp) then begin
            if Resp.IsSuccessStatusCode() then
                //Message('Sent new %1 dimension to Jaggaer with value: %2 - %3', DimensionValue."Dimension Code", DimensionValue.Code, DimensionValue.Name)
                exit
            else
                Error(
                    'Flow call failed. Status %1. Response: %2',
                    Resp.HttpStatusCode(),
                    GetResponseText(Resp));
        end else
            Error('Could not reach flow endpoint.');
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