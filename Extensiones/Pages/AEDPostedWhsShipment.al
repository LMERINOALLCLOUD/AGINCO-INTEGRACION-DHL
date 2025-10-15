pageextension 70100 "AED Posted Whse. Shipment" extends "Posted Whse. Shipment"
{

    actions
    {
        addlast(processing)
        {
            action(GenerarExp)
            {
                ApplicationArea = All;
                Caption = 'Generar expedición DHL';
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Process;

                
                
                trigger OnAction()
                var
                    cuFuncionalidad: Codeunit "AED Funcionalidad";
                begin
                    cuFuncionalidad.generarExpedicionDHL(Rec);
                end;
            }

        }
    }
}
