tableextension 70101 "AED User Setup" extends "User Setup"
{
    fields
    {
        field(70100; "AED PrintLabel Mode"; Enum "AED Print Label Mode")
        {
            Caption = 'Modo etiquetas DHL';
            DataClassification = ToBeClassified;
        }
        field(70101; "ID Printer PrintNode"; Integer)
        {
            Caption = 'ID Impresora PrintNode DHL';
            DataClassification = ToBeClassified;
        }
    }
}