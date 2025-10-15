page 70102 "AED Setup"
{
    Caption = 'Integración DHL - Configuración';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "AED Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Configuración';
                field("Tipo numeracion expedicion"; Rec."Tipo numeracion expedicion")
                {
                    ApplicationArea = All;
                }
                field("Series Num. Expedicion"; Rec."Series Num. Expedicion")
                {
                    ApplicationArea = All;
                }
                field("Series Num. End Day"; Rec."Series Num. End Day")
                {
                    ApplicationArea = All;
                }                
                field("Transportista DHL"; Rec."Transportista DHL")
                {
                    ApplicationArea = All;
                }

            }
            group(DatosAPI)
            {
                Caption = 'Datos API DHL';
                field("API DHL Base URL"; Rec."API DHL Base URL")
                {
                    ApplicationArea = All;
                }
                field("API DHL Username"; Rec."API DHL Username")
                {
                    ApplicationArea = All;
                }
                field("API DHL Password"; Rec."API DHL Password")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
                field("API DHL Customer Code"; Rec."API DHL Customer Code")
                {
                    ApplicationArea = All;
                }
                field("Token API DHL Expiration"; Rec."Token API DHL Expiration")
                {
                    ApplicationArea = All;
                }
                field("Token API DHL Timestamp"; Rec."Token API DHL Timestamp")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ObtenerTOKEN)
            {
                ApplicationArea = All;
                Caption = 'Obtener TOKEN API';
                Image = RefreshText;

                trigger OnAction()
                var
                    httprequesthandler: Codeunit "AED HTTP Request Handler";
                begin
                    Rec.Modify();
                    if httprequesthandler.GetAccessToken() <> '' then
                        Message('Token actualizado correctamente');
                    CurrPage.Update();
                end;
            }
            /*
            action(ShowTOKEN)
            {
                ApplicationArea = All;
                Caption = 'Ver TOKEN API';
                Image = RefreshText;

                trigger OnAction()
                var
                    httprequesthandler: Codeunit "AED HTTP Request Handler";
                begin
                    Message(rec.getToken());
                end;
            }
            */
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        
        IF NOT Rec.GET THEN BEGIN
            Rec.INIT;
            Rec.INSERT;
        END;
    end;

}