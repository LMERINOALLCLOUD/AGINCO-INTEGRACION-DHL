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
                begin
                    if not Confirm('Esta acción generará el report de cierre diario y se enviará a DHL ¿desea continuar?', false) then
                        exit;

                    rProcesosCola.runEndDay();
                end;
            }
        }
    }
}