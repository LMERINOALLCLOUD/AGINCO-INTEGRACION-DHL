table 70100 "AED Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Key"; Code[10])
        {
            Caption = 'Key';
            DataClassification = ToBeClassified;
        }
        field(2; "Token API DHL"; Blob)
        {
            Caption = 'API Token DHL';
            DataClassification = ToBeClassified;
        }
        field(3; "Token API DHL Timestamp"; DateTime)
        {
            Caption = 'Timestamp API Token DHL';
            DataClassification = ToBeClassified;
        }
        field(4; "Token API DHL Expiration"; Integer)
        {
            Caption = 'Expiración API Token DHL (minutos)';
            DataClassification = ToBeClassified;
        }
        field(5; "API DHL Username"; Text[50])
        {
            Caption = 'API DHL Username';
            DataClassification = ToBeClassified;
        }

        field(6; "API DHL Password"; Text[50])
        {
            Caption = 'API DHL Password';
            DataClassification = SystemMetadata;
        }
        field(7; "API DHL Base URL"; Text[50])
        {
            Caption = 'API DHL Base URL';
            DataClassification = ToBeClassified;
        }
        field(8; "Tipo numeracion expedicion"; Enum "AED Opciones Numeracion")
        {
            Caption = 'Opción numeración expediciones';
            DataClassification = ToBeClassified;
        }
        field(9; "Series Num. Expedicion"; Code[20])
        {
            Caption = 'Num. Serie Expedición';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(14; "Series Num. End Day"; Code[20])
        {
            Caption = 'Num. Serie EndDay Report';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(10; "API DHL Customer Code"; Text[20])
        {
            Caption = 'API DHL Customer Code';
            DataClassification = ToBeClassified;
        }
        field(11; "Transportista DHL"; Code[20])
        {
            Caption = 'Transportista DHL';
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent";
        }




    }



    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
    }

    procedure checkTokenStatus(): Boolean
    begin
        if Rec."Token API DHL Timestamp" = 0DT then
            exit(false);

        if ((CurrentDateTime - Rec."Token API DHL Timestamp") > Rec."Token API DHL Expiration" * 60 * 1000) then
            exit(false);

        exit(true);
    end;

    procedure renewToken(newToken: Text)
    var
        OStream: OutStream;
    begin
        Rec."Token API DHL".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(newToken);
        Rec."Token API DHL Timestamp" := CurrentDateTime;
        Modify();
    end;

    procedure getToken(): Text
    var
        iStream: InStream;
        token: Text;
        httprequesthandler: Codeunit "AED HTTP Request Handler";
    begin
        Rec.CalcFields("Token API DHL");
        if not Rec."Token API DHL".HasValue then
            exit(httprequesthandler.GetAccessToken());

        rec."Token API DHL".CreateInStream(iStream, TextEncoding::UTF8);
        iStream.ReadText(token);
        exit(token);
    end;

}