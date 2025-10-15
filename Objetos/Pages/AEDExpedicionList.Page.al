page 70101 "AED Expedicion List"
{
    Caption = 'Mantenimiento de expediciones';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "AED Cab. Expedicion";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;    
    CardPageId = "AED Expedicion Card";
    Editable = false;
    
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Cod. Expedicion"; Rec."Cod. Expedicion")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    Caption = 'Consignatario';
                    ApplicationArea = All;
                }
                field("Cust. No"; Rec."Cust. No")
                {
                    Caption = 'Cód. consignatario';
                    ApplicationArea = All;
                }
                field("Cod. albaran"; Rec."Cod. albaran")
                {
                    ApplicationArea = All;
                }
                field("Cod. envio"; Rec."Cod. envio")
                {
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
                field(Estado; Rec.Estado)
                {
                    ApplicationArea = All;
                }                
                field("Ultimo estado"; Rec."Ultimo estado")
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
            action(ActionName)
            {
                ApplicationArea = All;
                
                trigger OnAction();
                begin
                    
                end;
            }
        }
    }
}