page 70100 "AED Expedicion Card"
{
    Caption = 'Caption';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "AED Cab. Expedicion";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = datosEditables;
                field("Cod. Expedicion"; Rec."Cod. Expedicion")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Tracking No. DHL"; Rec."Tracking No. DHL")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Estado; Rec.Estado)
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Ultimo estado"; Rec."Ultimo estado")
                {
                    Editable = false;
                    ApplicationArea = All;
                }


                field("No. bultos"; Rec."No. bultos")
                {
                    ApplicationArea = All;
                }
                field(Peso; Rec.Peso)
                {
                    ApplicationArea = All;
                }
            }
            group(Consignatario)
            {
                Editable = datosEditables;
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Name 2"; Rec."Ship-to Name 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Post. Code"; Rec."Ship-to Post. Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                }
                field("Ship-to County"; Rec."Ship-to County")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Country"; Rec."Ship-to Country")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Phone No."; Rec."Ship-to Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Ship-to E-Mail"; Rec."Ship-to E-Mail")
                {
                    ApplicationArea = All;
                }
            }
            group(Relations)
            {
                Editable = false;
                Caption = 'Relacionados';
                field("Cod. envio"; Rec."Cod. envio")
                {
                    ApplicationArea = All;
                }
                field("Cod. envio reg."; Rec."Cod. envio reg.")
                {
                    ApplicationArea = All;
                }
                field("Cod. albaran"; Rec."Cod. albaran")
                {
                    ApplicationArea = All;
                }
                field("Cust. No"; Rec."Cust. No")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Reenviar)
            {
                Caption = 'Reenviar a DHL';
                ApplicationArea = All;
                Image = SendMail;
                Enabled = datosEditables;

                trigger OnAction()
                var
                    funcionalidad: Codeunit "AED Funcionalidad";
                begin
                    IF Rec.Estado <> Rec.Estado::"Error envio" then
                        exit;

                    if funcionalidad.enviarExpedicionDHL(Rec) then
                        rec.descargarEtiquetas();

                    CurrPage.Update();
                end;
            }
            action(VerError)
            {
                Caption = 'Ver error';
                ApplicationArea = All;
                Image = Error;
                Enabled = datosEditables;

                trigger OnAction()
                var
                    funcionalidad: Codeunit "AED Funcionalidad";
                begin
                    IF Rec.Estado <> Rec.Estado::"Error envio" then
                        exit;

                    Message(Rec.getError());
                end;
            }
            action(DescargarEtiquetas)
            {
                Caption = 'Descargar etiquetas';
                ApplicationArea = All;
                Image = Print;
                Enabled = not datosEditables;

                trigger OnAction()
                var
                    PrintNodeInt: Codeunit "AED PrintNode Send PDF";
                    UserSetup: Record "User Setup";
                    rAEDSetup: Record "AED Setup";
                    filemngtm: Codeunit "File Management";
                begin
                    IF Rec.Estado = Rec.Estado::"Error envio" then
                        exit;

                    UserSetup.Get(UserId);
                    PrintNodeInt.checkPrintNodeData();
                    if UserSetup."AED PrintLabel Mode" = UserSetup."AED PrintLabel Mode"::DownloadFile then
                        Rec.descargarEtiquetas()
                    else begin
                        rAEDSetup.Get();                        
                        PrintNodeInt.EnviarAImpresora(rAEDSetup."AED PrintNode ApiKey", rAEDSetup."AED PrintNode Print URL", userSetup."ID Printer PrintNode",
                            filemngtm.StripNotsupportChrInFileName(Rec."Cod. albaran") + '.pdf', Rec.getB64Etiquetas());
                    end;

                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        datosEditables := false;
        if Rec.Estado = Rec.Estado::"Error envio" then
            datosEditables := true;
    end;

    trigger OnOpenPage()
    var
        Notif: Notification;
    begin
        if (Rec.Estado = rec.Estado::"Error envio") then begin
            Notif.Message(StrSubstNo('Se ha producido un error al enviar la expedición %1. Revise los datos de la misma e intente su envío manualmente', Rec."Cod. Expedicion"));
            Notif.Scope := NotificationScope::LocalScope;
            Notif.Send();
        end;
    end;

    var
        datosEditables: Boolean;
}