codeunit 70104 "AED PrintNode Send PDF"
{
    procedure EnviarAImpresora(PrintNodeApiKey: Text; PrintNodeURL: Text; PrinterId: Integer; JobTitle: Text; PdfBase64: Text)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ContentJson: Text;
        Content: HttpContent;
        Headers: HttpHeaders;
        ResultText: Text;
    begin
        // Construimos el JSON que PrintNode espera
        ContentJson :=
          '{' +
            '"printerId": ' + Format(PrinterId) + ',' +
            '"title": "' + JobTitle + '",' +
            '"contentType": "pdf_base64",' +
            '"content": "' + PdfBase64 + '"' +
          '}';

        // Configurar request
        Request.Method := 'POST';
        Request.SetRequestUri(PrintNodeURL);

        Content.WriteFrom(ContentJson);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        Request.Content := Content;

        // Autenticación Basic con la API key de PrintNode
        // Nota: PrintNode usa Basic Auth con apiKey como user y password vacío.
        // Básicamente "apiKey:" codificado en Base64.
        Request.GetHeaders(Headers);
        Headers.Add('Authorization', 'Basic ' + GetPrintNodeAuthToken(PrintNodeApiKey));

        // Llamar
        Client.Send(Request, Response);

        Response.Content.ReadAs(ResultText);

        if not Response.IsSuccessStatusCode() then begin
            SetErrroLog(Format(Response.HttpStatusCode), ResultText, JobTitle);
            /*
            Error(
              'Error enviando a PrintNode. Status %1. Respuesta: %2',
              Response.HttpStatusCode(), ResultText);
            */
        end;
    end;

    procedure checkPrintNodeData()
    var
        userSEtup: Record "User Setup";
        AEDSetup: Record "AED Setup";
    begin
        userSEtup.Get(UserId);
        if userSEtup."AED PrintLabel Mode" = userSEtup."AED PrintLabel Mode"::DirectPrint then begin
            AEDSetup.Get();
            AEDSetup.TestField("AED PrintNode ApiKey");
            AEDSetup.TestField("AED PrintNode Print URL");
            userSEtup.TestField("ID Printer PrintNode");
        end;
    end;

    local procedure GetPrintNodeAuthToken(ApiKey: Text): Text
    var
        Base64Conv: Codeunit "Base64 Convert";
        AuthText: Text;
    begin
        // Formato requerido: "ApiKey:"
        AuthText := ApiKey + ':';
        exit(Base64Conv.ToBase64(AuthText));
    end;

    local procedure SetErrroLog(ErrorCode: Code[5]; ErrorText: Text; JobTitle: Text)
    var
        rLog: Record "AED PrintNode Error Log";
    begin
        rLog.Init();
        rLog.ID := 0;
        rLog."Error Code" := ErrorCode;
        rLog."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(rLog."Error Message"));
        rLog."Job Title" := CopyStr(JobTitle, 1, MaxStrLen(rLog."Job Title"));
        rLog."Date Time" := CurrentDateTime;
        rLog.Insert(true);
    end;
}