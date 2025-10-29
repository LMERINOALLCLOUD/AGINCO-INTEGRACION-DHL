pageextension 70102 "AED User Setup" extends "User Setup"
{
    layout
    {
        addafter("Allow VAT To")
        {
            field("AED PrintLabel Mode"; Rec."AED PrintLabel Mode")
            {
                ApplicationArea = All;
            }
            field("ID Printer PrintNode"; Rec."ID Printer PrintNode")
            {
                ApplicationArea = All;
            }
        }
    }
}