page 70104 "AED PrintNode Error Log List"
{
    Caption = 'Listado log de errores de PrintNode - Impresión directa';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "AED PrintNode Error Log";
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }
                field("Date Time"; Rec."Date Time")
                {
                    ApplicationArea = All;
                }
                field("Error Code"; Rec."Error Code")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }
}