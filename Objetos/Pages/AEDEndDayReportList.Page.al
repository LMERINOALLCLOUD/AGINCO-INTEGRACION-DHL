page 70103 "AED End Day Report LIst"
{
    Caption = 'Lista de reportes de Cierre diario DHL';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "AED End Day Report";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("End Day Report Code"; Rec."End Day Report Code")
                {
                    ApplicationArea = All;
                }
                field("Hora proceso"; Rec."Hora proceso")
                {
                    ApplicationArea = All;
                }
                field("No. Expediciones"; Rec."No. Expediciones")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadReport)
            {
                ApplicationArea = All;
                Caption = 'Descargar informe';
                Image = Print;
                Scope = Repeater;

                trigger OnAction();
                begin
                    Rec.descargarReport();
                end;
            }
            action(generarEndDay)
            {
                ApplicationArea = All;
                Caption = 'Generar informe';
                Image = PostPrint;
                Scope = Page;

                trigger OnAction()
                var
                    rProcesosCola: Codeunit "AED Procesos Cola";
                    repCode: Code[20];
                    endDayRep: Record "AED End Day Report";
                begin
                    if not Confirm('Esta acción generará el report de cierre diario y se enviará a DHL ¿desea continuar?', false) then
                        exit;

                    repCode := rProcesosCola.runEndDay();
                end;
            }
            action(enviarAlbaranValorado)
            {
                ApplicationArea = All;
                Caption = 'Enviar albarán valorado';
                Image = SendEmailPDF;
                Scope = Repeater;

                trigger OnAction()
                var
                    window: Dialog;
                    rExpediciones: Record "AED Cab. Expedicion";
                    rSalesShipmentHeader: Record "Sales Shipment Header";
                    cuFuncionalidad: Codeunit "AED Funcionalidad";
                begin
                    if not Confirm('Esta acción enviará por mail los albaranes valorados relacionados con el report ¿desea continuar?', false) then
                        exit;

                    //enviar albaranes por mail
                    window.Open('Enviando email albaran ############1#');

                    if rExpediciones.FindSet() then
                        repeat
                            rSalesShipmentHeader.Reset();
                            rSalesShipmentHeader.SetRange("Cod. expedicion", rExpediciones."Cod. Expedicion");
                            if rSalesShipmentHeader.FindSet() then begin
                                repeat
                                    window.Update(1, rSalesShipmentHeader.No);
                                    cuFuncionalidad.sendAlbaranValorado(rSalesShipmentHeader);
                                until rSalesShipmentHeader.Next() = 0;
                            end;
                        until rExpediciones.Next() = 0;

                    window.Close();
                end;
            }
        }
    }
}