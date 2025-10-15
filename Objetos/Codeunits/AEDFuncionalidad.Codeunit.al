codeunit 70101 "AED Funcionalidad"
{
    Permissions = tabledata "Sales Shipment Header" = rmid, tabledata "AED Cab. Expedicion" = rmid;

    procedure enviarExpedicionDHL(var expedicon: Record "AED Cab. Expedicion"): Boolean
    var
        rAEDSetup: Record "AED Setup";
        httpRequestHandler: Codeunit "AED HTTP Request Handler";
        JSONExpedicion: JsonObject;
        responseText: Text;
        requestText: Text;
        JSONResponse: JsonObject;
        JToken: JsonToken;
        rSalesShipmentHeader: Record "Sales Shipment Header";
    begin
        rAEDSetup.Get();
        if expedicon."No. bultos" = 0 then
            Error('Nº de bultos debe ser mayor de 0');

        getJsonFromExpedicion(JSONExpedicion, expedicon);
        JSONExpedicion.WriteTo(requestText);
        if httpRequestHandler.HttpPost(rAEDSetup.getToken(), rAEDSetup."API DHL Base URL" + '/shipment', requestText, responseText) then begin
            JSONResponse.ReadFrom(responseText);
            if JSONResponse.Get('Tracking', JToken) then
                expedicon."Tracking No. DHL" := getJsonTextFromToken(JToken);
            if JSONResponse.Get('Label', JToken) then
                expedicon.asignaEtiquetas(getJsonTextFromToken(JToken));
            expedicon.Estado := "AED Estados Expedicion"::Enviado;
            expedicon.Modify();
            //pasamos la info del tracking al albarán asociado
            if rSalesShipmentHeader.Get(expedicon."Cod. albaran") then begin
                rSalesShipmentHeader."Package Tracking No." := expedicon."Tracking No. DHL";
                rSalesShipmentHeader.Modify();
            end;
            exit(true);
        end else begin
            expedicon.setError(responseText);
            expedicon.Modify();
        end;
    end;

    procedure getJsonTextFromToken(Jtoken: JsonToken): Text
    begin
        if not JToken.AsValue().IsNull then
            exit(JToken.AsValue().AsText())
        else
            exit('');
    end;

    local procedure getJsonFromExpedicion(JSonExpedicion: JsonObject; var rExpedicion: Record "AED Cab. Expedicion")
    var
        rAEDSetup: Record "AED Setup";
        JSonReceiver: JsonObject;
    begin
        rAEDSetup.Get();

        JSonReceiver.Add('Name', rExpedicion."Ship-to Name" + ' ' + rExpedicion."Ship-to Name 2");
        JSonReceiver.Add('Address', rExpedicion."Ship-to Address" + ' ' + rExpedicion."Ship-to Address 2");
        JSonReceiver.Add('City', rExpedicion."Ship-to City");
        JSonReceiver.Add('PostalCode', rExpedicion."Ship-to Post. Code");
        JSonReceiver.Add('Country', rExpedicion."Ship-to Country");
        JSonReceiver.Add('Phone', rExpedicion."Ship-to Phone No.");
        JSonReceiver.Add('Email', rExpedicion."Ship-to E-mail");

        JSonExpedicion.Add('Customer', rAEDSetup."API DHL Customer Code");
        JSonExpedicion.Add('Receiver', JSonReceiver);
        JSonExpedicion.Add('Reference', rExpedicion."Cod. Expedicion");
        JSonExpedicion.Add('Quantity', Format(rExpedicion."No. bultos"));
        if rExpedicion.Peso < 1 then
            rExpedicion.Peso := 1;
        JSonExpedicion.Add('Weight', Format(Round(rExpedicion.Peso, 1)));
        JSonExpedicion.Add('Incoterms', 'CPT'); //portes pagados
        JSonExpedicion.Add('Format', 'PDF');
    end;

    procedure OpenExpedicionFromNotif(Notification: Notification)
    var
        rExpedicion: Record "AED Cab. Expedicion";
        ExpedicionCode: Code[20];
    begin
        ExpedicionCode := Notification.GetData('ExpedicionNo');
        if rExpedicion.Get(ExpedicionCode) then
            Page.Run(Page::"AED Expedicion Card", rExpedicion);
    end;

    procedure generarExpedicionDHL(var PostedWarehouseShipmentHeader: Record "Posted Whse. Shipment Header")
    var
        PostedWarehouseShipmentLine: Record "Posted Whse. Shipment Line";
        rExpedicion: Record "AED Cab. Expedicion";
        AEDFuncionalidad: Codeunit "AED Funcionalidad";
        rSalesShipmentHeader: Record "Sales Shipment Header";
        rAEDSetup: Record "AED Setup";
        rItem: Record Item;
        Notif: Notification;
    begin
        rAEDSetup.Get();

        if PostedWarehouseShipmentHeader."Shipping Agent Code" <> rAEDSetup."Transportista DHL" then
            exit;

        rExpedicion.Reset();
        rExpedicion.SetRange("Cod. envio reg.", PostedWarehouseShipmentHeader."No.");
        if rExpedicion.FindSet() then begin
            Notif.Message(StrSubstNo('La expedición para el envío ya se ha registrado. El código de expedición generado es %1', rExpedicion."Cod. Expedicion"));
            Notif.Scope := NotificationScope::LocalScope;

            // Pasar datos a la acción (clave/valor)
            Notif.SetData('ExpedicionNo', rExpedicion."Cod. Expedicion");

            // Agregar acción: texto visible, codeunit que contiene el handler y nombre del procedimiento
            Notif.AddAction('Abrir expedición', Codeunit::"AED Funcionalidad", 'OpenExpedicionFromNotif');

            Notif.Send();

            exit;
        end;

        PostedWarehouseShipmentLine.Reset();
        PostedWarehouseShipmentLine.SetRange("No.", PostedWarehouseShipmentHeader."No.");
        if PostedWarehouseShipmentLine.FindSet() then begin
            //creamos la expedicion con los datos del albarán asociado
            if PostedWarehouseShipmentLine."Posted Source Document" = PostedWarehouseShipmentLine."Posted Source Document"::"Posted Shipment" then
                rSalesShipmentHeader.Get(PostedWarehouseShipmentLine."Posted Source No.");

            Clear(rExpedicion);
            rExpedicion.Init();
            if rAEDSetup."Tipo numeracion expedicion" = rAEDSetup."Tipo numeracion expedicion"::"Envio registrado" then
                rExpedicion."Cod. Expedicion" := PostedWarehouseShipmentLine."No.";

            rExpedicion."Cod. albaran" := rSalesShipmentHeader."No.";
            rExpedicion."Cod. envio reg." := PostedWarehouseShipmentLine."No.";
            rExpedicion."Cod. envio" := PostedWarehouseShipmentLine."Whse. Shipment No.";
            rExpedicion."Ship-to Name" := rSalesShipmentHeader."Ship-to Name";
            rExpedicion."Ship-to Name 2" := rSalesShipmentHeader."Ship-to Name 2";
            rExpedicion."Ship-to Address" := rSalesShipmentHeader."Ship-to Address";
            rExpedicion."Ship-to Address 2" := rSalesShipmentHeader."Ship-to Address 2";
            rExpedicion."Ship-to Post. Code" := rSalesShipmentHeader."Ship-to Post Code";
            rExpedicion."Ship-to City" := rSalesShipmentHeader."Ship-to City";
            rExpedicion."Ship-to County" := rSalesShipmentHeader."Ship-to County";
            rExpedicion."Ship-to Country" := rSalesShipmentHeader."Ship-to Country/Region Code";
            rExpedicion."Ship-to Phone No." := rSalesShipmentHeader."Ship-to Phone No.";
            rExpedicion."Ship-to E-Mail" := rSalesShipmentHeader."Sell-to E-Mail";
            rExpedicion."Ship-to Contact" := rSalesShipmentHeader."Ship-to Contact";
            rExpedicion."No. bultos" := PostedWarehouseShipmentHeader.NoBultos;
            rExpedicion."Cust. No" := rSalesShipmentHeader."Bill-to Customer No.";

            repeat
                if rItem.Get(PostedWarehouseShipmentLine."Item No.") then
                    rExpedicion.Peso += rItem."Net Weight";
            until PostedWarehouseShipmentLine.Next() = 0;

            rExpedicion.Insert(true);

            if AEDFuncionalidad.enviarExpedicionDHL(rExpedicion) then begin
                rExpedicion.descargarEtiquetas();

                Notif.Message(StrSubstNo('Se ha generado la expeción %1', rExpedicion."Cod. Expedicion"));
                Notif.Scope := NotificationScope::LocalScope;

                // Pasar datos a la acción (clave/valor)
                Notif.SetData('ExpedicionNo', rExpedicion."Cod. Expedicion");

                // Agregar acción: texto visible, codeunit que contiene el handler y nombre del procedimiento
                Notif.AddAction('Abrir expedición', Codeunit::"AED Funcionalidad", 'OpenExpedicionFromNotif');

                Notif.Send();
            end else begin
                Notif.Message(StrSubstNo('Se ha producido un error al enviar la expedición %1. Revise los datos de la misma e intente su envío manualmente', rExpedicion."Cod. Expedicion"));
                Notif.Scope := NotificationScope::LocalScope;

                // Pasar datos a la acción (clave/valor)
                Notif.SetData('ExpedicionNo', rExpedicion."Cod. Expedicion");

                // Agregar acción: texto visible, codeunit que contiene el handler y nombre del procedimiento
                Notif.AddAction('Abrir expedición', Codeunit::"AED Funcionalidad", 'OpenExpedicionFromNotif');

                Notif.Send();
            end;
        end;
    end;

    procedure compruebaUltimaExpedicion(var warehouseShipmentLine: Record "Warehouse Shipment Line"): Boolean
    var
        rExpedicion: Record "AED Cab. Expedicion";
    begin
        rExpedicion.SetRange("Cod. envio", warehouseShipmentLine."No.");
        if rExpedicion.FindLast() then
            if rExpedicion.Estado = rExpedicion.Estado::"Error envio" then
                exit(false);

        exit(true);
    end;

}