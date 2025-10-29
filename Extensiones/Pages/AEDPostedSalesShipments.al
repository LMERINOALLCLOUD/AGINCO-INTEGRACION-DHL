pageextension 70101 "AED Posted Sales Shipments" extends "Posted Sales Shipments"
{
    actions
    {
        addafter(ImpresoParaEmail)
        {
            action("SendValorado")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Enviar albarán valorado';
                Ellipsis = true;
                Image = SendEmailPDF;
                ToolTip = 'Envía el albarán valorado por mail al cliente';

                trigger OnAction()
                var
                    SalesShptHeader: Record "Sales Shipment Header";
                    cuFuncionalidad: Codeunit "AED Funcionalidad";
                    window: Dialog;
                begin
                    if not Confirm('Esta acción enviará por mail los albaranes valorados seleccionados ¿desea continuar?', false) then
                        exit;

                    //enviar albaranes por mail
                    window.Open('Enviando email albaran ############1#');

                    SalesShptHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesShptHeader);
                    if SalesShptHeader.FindSet() then
                        repeat
                            window.Update(1, SalesShptHeader.No);
                            cuFuncionalidad.sendAlbaranValorado(SalesShptHeader);
                        until SalesShptHeader.Next() = 0;

                    window.Close();
                end;
            }
        }
        addafter(ImpresoParaEmail_Prom)
        {
            actionref("SendValorado_Promoted"; "SendValorado")
            {
            }
        }
    }
}