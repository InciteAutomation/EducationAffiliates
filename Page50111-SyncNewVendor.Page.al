pageextension 50111 "CreateNewVendor-PA" extends "Vendor Card"
{
    actions
    {
        addfirst(processing)
        {
            action(SendToFlow)
            {
                ApplicationArea = All;
                Caption = 'Sync Vendor';
                Image = SocialSecurityTax;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    selectedRecords: Record Vendor;
                    Http: HttpClient;
                    Content: HttpContent;
                    Headers: HttpHeaders;
                    Resp: HttpResponseMessage;
                    payloadObject: JsonObject;
                    payloadString: Text;
                    Items: JsonArray;
                    jVal: JsonValue;
                    Url: Text;

                begin
                    /*
                    CurrPage.SetSelectionFilter(selectedRecords);
                    if selectedRecords.IsEmpty() then begin
                        Message('Select at least one PO');
                    end;

                    If selectedRecords.FindSet() then
                        repeat
                            jVal.SetValue(selectedRecords."No.");
                            Items.Add(jVal);
                        until selectedRecords.Next() = 0;
                    */

                    payloadObject.add('ID', Rec.SystemId);
                    if Rec.Synced = true then begin
                        payloadObject.add('Status', 'Old');
                    end else begin
                        payloadObject.add('Status', 'New');
                    end;


                    Url := 'https://default40a96b834e8b4d89969e20067e90f4.ac.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/56f13df5ff7d403183785a22a7954609/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=4giehh7ZKxvCSYwN0DGSqglMfBOdHKNmcUAbnaHWsaY';
                    payloadObject.WriteTo(payloadString);
                    Content.WriteFrom(payloadString);
                    Content.GetHeaders(Headers);
                    Headers.Clear();
                    Headers.Add('Content-Type', 'application/json');

                    if Http.Post(Url, Content, Resp) then begin
                        if Resp.IsSuccessStatusCode then begin
                            Message('Vendor Sync to Jaggaer Initiated');
                            Rec.Synced := true;
                            Rec.Modify(true);
                        end else
                            Error('Flow call failed. Status %1 %2', Resp.HttpStatusCode, GetResponseText(Resp));

                    end else
                        Error('Could not reach flow endpoint');
                end;
            }
        }
    }
    local procedure GetResponseText(var Resp: HttpResponseMessage): Text
    var
        Body: Text;
    begin
        if Resp.Content.ReadAs(Body) then
            exit(Body);
        exit('')
    end;
}