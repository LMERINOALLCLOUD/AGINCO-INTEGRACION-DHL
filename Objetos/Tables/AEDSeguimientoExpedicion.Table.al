table 70102 "AED Seguimiento Expedicion"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Cod. Expedicion"; Code[20])
        {
            Caption = 'Cód. expedición';
            DataClassification = ToBeClassified;
        }
        field(2; "No. Linea"; Integer)
        {
            Caption = 'Nº línea';
            DataClassification = ToBeClassified;
        }
        field(3; "Fecha-Hora"; DateTime)
        {
            Caption = 'Fecha/hora';
            DataClassification = ToBeClassified;
        }
        field(4; "Cod estado"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Cód. estado';
        }
        field(5; "Des. estado"; Text[50])
        {
            Caption = 'Descripción';
            DataClassification = ToBeClassified;
        }
        field(6; "Ubicacion"; Text[100])
        {
            Caption = 'Ubicación';
            DataClassification = ToBeClassified;
        }





    }

    keys
    {
        key(PK; "Cod. Expedicion", "No. Linea")
        {
            Clustered = true;
        }
    }

}