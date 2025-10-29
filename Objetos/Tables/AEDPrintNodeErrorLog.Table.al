table 70104 "AED PrintNode Error Log"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "ID"; Integer)
        {
            Caption = 'ID';
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Date Time"; DateTime)
        {
            Caption = 'Fecha/Hora';
            DataClassification = ToBeClassified;
        }
        field(3; "Error Code"; Code[5])
        {
            Caption = 'Error Code';
            DataClassification = ToBeClassified;
        }
        field(4; "Error Message"; Text[500])
        {
            Caption = 'Mensaje de error';
            DataClassification = ToBeClassified;
        }
        field(5; "Job Title"; Text[50])
        {
            Caption = 'Nombre trabajo';
            DataClassification = ToBeClassified;
        }
        

    }

    keys
    {
        key(PK; "ID")
        {
            Clustered = true;
        }
    }

}