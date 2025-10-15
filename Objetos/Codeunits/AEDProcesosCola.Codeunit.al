codeunit 70103 "AED Procesos Cola"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        case Rec."Parameter String" of
            'UPDATE-TRACKING':
                begin
                    runUpdateTracking();
                end;
            'END-DAY':
                begin
                    runEndDay();
                end;
        end;
    end;

    local procedure runUpdateTracking()
    var
        httpRequestHandler: Codeunit "AED HTTP Request Handler";
        AEDSetup: Record "AED Setup";
        rExpediciones: Record "AED Cab. Expedicion";
        rEstadoExp: Record "AED Seguimiento Expedicion";
        JSONResponse: JsonArray;
        errorTxt: Text;
        JDriveItem: JsonToken;
        JDrive: JsonObject;
        JToken: JsonToken;
        cuFuncionalidad: Codeunit "AED Funcionalidad";
        counter: Integer;
    begin
        AEDSetup.Get();
        rExpediciones.Reset();
        rExpediciones.SetFilter(Estado, '%1', rExpediciones.Estado::Registrado);
        if rExpediciones.findset then
            repeat
                Clear(JSONResponse);
                if httpRequestHandler.HttpGet(AEDSetup.getToken(), getTrackingUrl(AEDSetup."API DHL Base URL", rExpediciones."Tracking No. DHL"),
                    JSONResponse, errorTxt) then begin
                    rEstadoExp.Reset();
                    rEstadoExp.SetRange("Cod. Expedicion", rExpediciones."Cod. Expedicion");
                    if rEstadoExp.FindSet() then
                        rEstadoExp.DeleteAll();

                    counter := 10000;
                    foreach JDriveItem in JSONResponse do begin
                        rEstadoExp.Reset();
                        rEstadoExp.Init();
                        rEstadoExp."Cod. Expedicion" := rExpediciones."Cod. Expedicion";

                        JDrive := JDriveItem.AsObject();
                        if JDrive.Get('DateTime', JToken) then
                            rEstadoExp."Fecha-Hora" := getDTFromText(cuFuncionalidad.getJsonTextFromToken(JToken));
                        if JDrive.Get('Code', JToken) then
                            rEstadoExp."Cod estado" := cuFuncionalidad.getJsonTextFromToken(JToken);
                        if JDrive.Get('Status', JToken) then
                            rEstadoExp."Des. estado" := cuFuncionalidad.getJsonTextFromToken(JToken);
                        if JDrive.Get('Ubication', JToken) then
                            rEstadoExp.Ubicacion := cuFuncionalidad.getJsonTextFromToken(JToken);
                        rEstadoExp."No. Linea" := counter;
                        rEstadoExp.Insert();

                        counter += 10000;
                    end;

                    rExpediciones.checkEstadosEnvioDHL();
                    Commit();
                end;
            until rExpediciones.Next() = 0;
    end;

    procedure runEndDay()
    var
        rExpediciones: Record "AED Cab. Expedicion";
        rAEDSetup: Record "AED Setup";
        jsonEndDay: JsonObject;
        jsonResponse: JsonObject;
        responseText: Text;
        requestText: Text;
        JToken: JsonToken;
        rEndDayRep: Record "AED End Day Report";
        cuFuncionalidad: Codeunit "AED Funcionalidad";

        httpRequestHandler: Codeunit "AED HTTP Request Handler";
    begin
        rAEDSetup.Get();
        rAEDSetup.TestField("Series Num. End Day");

        rExpediciones.Reset();
        rExpediciones.SetRange(Estado, rExpediciones.Estado::Enviado);
        if rExpediciones.FindSet() then begin
            getJsonFromExpedicionesEndDay(jsonEndDay, rAEDSetup."API DHL Customer Code");
            jsonEndDay.WriteTo(requestText);
            if httpRequestHandler.HttpPost(rAEDSetup.getToken(), rAEDSetup."API DHL Base URL" + '/endday', requestText, responseText) then begin
                JSONResponse.ReadFrom(responseText);
                if JSONResponse.Get('Report', JToken) then begin
                    rEndDayRep.Reset();
                    rEndDayRep.Init();
                    rEndDayRep."End Day Report Code" := '';
                    rEndDayRep."Hora proceso" := CurrentDateTime;
                    rEndDayRep.asignaReport(cuFuncionalidad.getJsonTextFromToken(JToken));
                    rEndDayRep.Insert(true);

                    rExpediciones.ModifyAll("End day rep. code", rEndDayRep."End Day Report Code");
                    rExpediciones.ModifyAll(Estado, rExpediciones.Estado::Registrado);

                    if GuiAllowed then
                        rEndDayRep.descargarReport();
                end;

            end else begin
                if responseText <> '' then
                    //salta error y se para el proceso en cola, debemos ver el error y reiniciar el proceso
                    Error(responseText);
            end;
        end else
            if GuiAllowed then
                Error('No hay ninguna expedición pendiente de envío a DHL');
    end;

    local procedure getTrackingUrl(baseURL: Text; trackCode: Text): Text
    begin
        exit(baseURL + 'track?id=' + trackCode);
    end;

    local procedure getDTFromText(fechaHora: text): DateTime
    var
        mes: integer;
        dia: integer;
        ano: integer;
        cadenaHora: Text;
        hora: Time;
    begin
        if not Evaluate(ano, CopyStr(fechaHora, 1, 4)) then
            exit(0DT);
        if not Evaluate(mes, CopyStr(fechaHora, 6, 2)) then
            exit(0DT);
        if not Evaluate(dia, CopyStr(fechaHora, 9, 2)) then
            exit(0DT);

        cadenaHora := CopyStr(fechaHora, 12, 8);
        if not Evaluate(hora, cadenaHora) then
            exit(0DT);

        exit(CreateDateTime(DMY2Date(dia, mes, ano), hora));
    end;

    local procedure getJsonFromExpedicionesEndDay(var JSonExpedicion: JsonObject; txtUserAccount: Text)
    begin
        JSonExpedicion.Add('Accounts', txtUserAccount);
        JSonExpedicion.Add('Report', 'PDF');
        JSonExpedicion.Add('OnlyDayReport', 0);
    end;
}