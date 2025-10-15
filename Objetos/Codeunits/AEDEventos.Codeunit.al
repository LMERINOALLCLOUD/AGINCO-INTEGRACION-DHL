codeunit 70102 "AED Eventos"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnAfterPostWhseShipment', '', false, false)]
    local procedure OnAfterPostWhseShipment(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; SuppressCommit: Boolean; var IsHandled: Boolean)
    var
        PostedWarehouseShipmentLine: Record "Posted Whse. Shipment Line";
        rExpedicion: Record "AED Cab. Expedicion";
        AEDFuncionalidad: Codeunit "AED Funcionalidad";
        rSalesShipmentHeader: Record "Sales Shipment Header";
        rAEDSetup: Record "AED Setup";
        rItem: Record Item;
        Notif: Notification;
    begin
        if SuppressCommit then exit;
        rAEDSetup.Get();

        if WarehouseShipmentHeader."Shipping Agent Code" <> rAEDSetup."Transportista DHL" then
            exit;

        PostedWarehouseShipmentLine.Reset();
        //PostedWarehouseShipmentLine.SetRange("No.", WarehouseShipmentHeader."Last Shipping No.");
        PostedWarehouseShipmentLine.SetRange("No.", WarehouseShipmentHeader."Shipping No.");
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
            rExpedicion."No. bultos" := WarehouseShipmentHeader.NoBultos;
            rExpedicion."Cust. No" := rSalesShipmentHeader."Bill-to Customer No.";

            repeat
                if rItem.Get(PostedWarehouseShipmentLine."Item No.") then
                    rExpedicion.Peso += rItem."Net Weight";
            until PostedWarehouseShipmentLine.Next() = 0;

            rExpedicion.Insert(true);
            if AEDFuncionalidad.enviarExpedicionDHL(rExpedicion) then begin
                rExpedicion.descargarEtiquetas();                
            end else begin
                /* no se ve la notificación al cerrarse el envío por la eliminación del registro si hay error se abre la pantalla de expedición
                Notif.Message(StrSubstNo('Se ha producido un error al enviar la expedición %1. Revise los datos de la misma e intente su envío manualmente', rExpedicion."Cod. Expedicion"));
                Notif.Scope := NotificationScope::LocalScope;

                // Pasar datos a la acción (clave/valor)
                Notif.SetData('ExpedicionNo', rExpedicion."Cod. Expedicion");

                // Agregar acción: texto visible, codeunit que contiene el handler y nombre del procedimiento
                Notif.AddAction('Abrir expedición', Codeunit::"AED Funcionalidad", 'OpenExpedicionFromNotif');

                Notif.Send();
                */
                Page.Run(Page::"AED Expedicion Card", rExpedicion);                
            end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnBeforeCheckWhseShptLines', '', false, false)]
    local procedure OnBeforeCheckWhseShptLines(var WarehouseShipmentLine: Record "Warehouse Shipment Line";var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; Invoice: Boolean; var SuppressCommit: Boolean; var IsHandled: Boolean)
    begin
        //comrpbamos datos 
        if WarehouseShipmentHeader.Get(WarehouseShipmentLine."No.") then
            if WarehouseShipmentHeader.NoBultos = 0 then
                Error('Nº de bultos debe ser mayor de 0');

        
    end;
}