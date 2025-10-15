codeunit 70100 "AED HTTP Request Handler"
{
    trigger OnRun()
    begin

    end;

    procedure GetAccessToken(): Text
    var
        AEDSetup: Record "AED Setup";
        MessageText: Text;
        ResponseText: Text;
    begin
        AEDSetup.Get();
        //DESCOMENTAR
        if (AcquireToken(AEDSetup."API DHL Username", AEDSetup."API DHL Password", AEDSetup."API DHL Base URL", ResponseText)) then begin
            AEDSetup.renewToken(DelChr(ResponseText,'=','"'));
            Commit();
            exit(ResponseText);
        end;
        exit('');
    end;

    local procedure AcquireToken(
        UserName: Text;
        Password: Text;
        TokenEndpointURL: Text;
        var AccessToken: Text): Boolean;
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        ContentText: Text;
        JsonRequest: JsonObject;
        ResponseText: Text;
        IsSuccess: Boolean;
        DotNetUriBuilder: Codeunit Uri;
    begin

        JsonRequest.Add('username', UserName);
        JsonRequest.Add('password', Password);
        JsonRequest.WriteTo(ContentText);
        Content.WriteFrom(ContentText);

        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        Request.Method := 'POST';
        Request.SetRequestUri(TokenEndpointURL + '/authenticate');
        Request.Content(Content);

        if Client.Send(Request, Response) then
            if Response.IsSuccessStatusCode() then begin
                if Response.Content.ReadAs(ResponseText) then begin
                    IsSuccess := true;
                    AccessToken := ResponseText;
                end;
            end else
                if Response.Content.ReadAs(ResponseText) then
                    IsSuccess := false;

        exit(IsSuccess);
    end;


    procedure HttpGet(AccessToken: Text; Url: Text; var JResponse: JsonArray; var JError: Text): Boolean
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        IsSucces: Boolean;
        Contador: Integer;
        ListOfValues: array[10] of Text;
        segundos: Integer;
        AEDSetup: Record "AED Setup";

    begin
        Contador := 0;
        AEDSetup.Get();
        repeat
            Clear(Client);
            Clear(RequestMessage);
            Clear(ResponseMessage);

            Headers := Client.DefaultRequestHeaders();
            Headers.Add('Authorization', StrSubstNo('Bearer %1', AccessToken));
            RequestMessage.SetRequestUri(Url);
            RequestMessage.Method := 'GET';

            if Client.Send(RequestMessage, ResponseMessage) then begin
                if ResponseMessage.Headers.GetValues('RateLimit-Limit', ListOfValues) then
                    if ResponseMessage.Headers.GetValues('RateLimit-Reset', ListOfValues) then begin
                        Evaluate(segundos, ListOfValues[1]);
                        //esperamos 1 segundo más
                        Sleep((segundos + 1) * 1000);
                    end;
                if ResponseMessage.IsSuccessStatusCode() then begin
                    if ResponseMessage.Content.ReadAs(ResponseText) then begin
                        IsSucces := true;
                        JResponse.ReadFrom(ResponseText);
                    end;
                    //LLM CORRECCIÓN 429
                end else if (ResponseMessage.HttpStatusCode = 429) or (ResponseMessage.HttpStatusCode = 503) then begin
                    ResponseMessage.Headers.GetValues('Retry-After', ListOfValues);
                    if (ListOfValues[1] <> '0') then begin
                        Evaluate(segundos, ListOfValues[1]);
                        //esperamos 1 segundo más
                        Sleep((segundos + 1) * 1000);
                    end;
                end else if (ResponseMessage.HttpStatusCode = 401) then begin
                    //puede que el token haya caducado, forzamos obtener uno nuevo
                    //SalesForceSetup.TestField("Oauth APP Id");
                    AccessToken := GetAccessToken();
                end else begin
                    ResponseMessage.Content.ReadAs(ResponseText);
                    Contador := 5;
                end;

                Contador += 1;
            end;
        until (IsSucces) or (Contador > 5);


        if not IsSucces then
            JError := ResponseText;
        exit(IsSucces);
    end;

    procedure HttpPost(AccessToken: Text; Url: Text; RequestText: Text; var ResponseText: Text): Boolean
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        IsSucces: Boolean;
        Contador: Integer;
        ListOfValues: array[10] of Text;
        segundos: Integer;
        AEDSetup: Record "AED Setup";
        RequestContent: HttpContent;
        ContentHeaders: HttpHeaders;
    begin
        Contador := 0;
        AEDSetup.Get();
        repeat
            Clear(Client);
            Clear(RequestMessage);
            Clear(ResponseMessage);
            Clear(RequestContent);

            Headers := Client.DefaultRequestHeaders();
            Headers.Add('Authorization', StrSubstNo('Bearer %1', AccessToken));
            RequestMessage.SetRequestUri(Url);
            RequestMessage.Method := 'POST';
            RequestContent.WriteFrom(RequestText);
            RequestContent.GetHeaders(ContentHeaders);
            ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', 'application/json');
            RequestMessage.Content := RequestContent;

            if Client.Send(RequestMessage, ResponseMessage) then begin
                if ResponseMessage.Headers.GetValues('RateLimit-Limit', ListOfValues) then
                    if ResponseMessage.Headers.GetValues('RateLimit-Reset', ListOfValues) then begin
                        Evaluate(segundos, ListOfValues[1]);
                        //esperamos 1 segundo más
                        Sleep((segundos + 1) * 1000);
                    end;
                if ResponseMessage.IsSuccessStatusCode() then begin
                    if ResponseMessage.Content.ReadAs(ResponseText) then
                        IsSucces := true;
                    //LLM CORRECCIÓN 429
                end else if (ResponseMessage.HttpStatusCode = 429) or (ResponseMessage.HttpStatusCode = 503) then begin
                    ResponseMessage.Headers.GetValues('Retry-After', ListOfValues);
                    if (ListOfValues[1] <> '0') then begin
                        Evaluate(segundos, ListOfValues[1]);
                        //esperamos 1 segundo más
                        Sleep((segundos + 1) * 1000);
                    end;
                end else if (ResponseMessage.HttpStatusCode = 401) then begin
                    //puede que el token haya caducado, forzamos obtener uno nuevo
                    //SalesForceSetup.TestField("Oauth APP Id");
                    AccessToken := GetAccessToken();
                end else begin
                    ResponseMessage.Content.ReadAs(ResponseText);
                    Contador := 5;
                end;

                Contador += 1;
            end;
        until (IsSucces) or (Contador > 5);

        exit(IsSucces);
    end;

    


}