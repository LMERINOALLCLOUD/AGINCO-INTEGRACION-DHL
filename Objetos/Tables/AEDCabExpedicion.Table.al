table 70101 "AED Cab. Expedicion"
{
    DataClassification = ToBeClassified;
    LookupPageId = "AED Expedicion List";
    DrillDownPageId = "AED Expedicion List";

    fields
    {
        field(1; "Cod. Expedicion"; Code[20])
        {
            Caption = 'Cód. Expedición';
            DataClassification = ToBeClassified;
        }
        field(2; "Ship-to Name"; Text[100])
        {
            Caption = 'Envío a nombre';
            DataClassification = ToBeClassified;
        }
        field(3; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Envío a nombre 2';
            DataClassification = ToBeClassified;
        }
        field(4; "Ship-to Address"; Text[100])
        {
            Caption = 'Envío a dirección';
            DataClassification = ToBeClassified;
        }
        field(5; "Ship-to Address 2"; Text[100])
        {
            Caption = 'Envío a dirección 2';
            DataClassification = ToBeClassified;
        }
        field(6; "Ship-to City"; Text[30])
        {
            Caption = 'Envío a ciudad';
            DataClassification = ToBeClassified;
        }
        field(7; "Ship-to Contact"; Text[100])
        {
            Caption = 'Envío a contacto';
            DataClassification = ToBeClassified;
        }
        field(8; "Ship-to Phone No."; Text[30])
        {
            Caption = 'Envío a teléfono';
            DataClassification = ToBeClassified;
        }
        field(9; "Ship-to E-Mail"; Text[80])
        {
            Caption = 'Envío a E-mail';
            DataClassification = ToBeClassified;
        }
        field(10; "Ship-to County"; Text[80])
        {
            Caption = 'Envío a E-mail';
            DataClassification = ToBeClassified;
        }
        field(11; "Ship-to Country"; Text[80])
        {
            Caption = 'Envío a E-mail';
            DataClassification = ToBeClassified;
        }
        field(12; "No. bultos"; Integer)
        {
            Caption = 'Nº de bultos';
            DataClassification = ToBeClassified;
        }
        field(13; "Peso"; Decimal) //pasar a entero
        {
            Caption = 'Peso total (kg)';
            DataClassification = ToBeClassified;
        }
        field(14; "Ultimo estado"; Text[50])
        {
            Caption = 'Último estado expedición';
            FieldClass = FlowField;
            CalcFormula = max("AED Seguimiento Expedicion"."Des. estado" where("Cod. Expedicion" = field("Cod. Expedicion")));
        }
        field(15; "Cod. envio reg."; Code[20])
        {
            Caption = 'Cod. envío registrado';
            DataClassification = ToBeClassified;
            TableRelation = "Posted Whse. Shipment Header";
        }
        field(23; "Cod. envio"; Code[20])
        {
            Caption = 'Cod. envío';
            DataClassification = ToBeClassified;
            TableRelation = "Warehouse Shipment Header";
        }
        field(16; "Cod. albaran"; Code[20])
        {
            Caption = 'Cod. albarán';
            DataClassification = ToBeClassified;
            TableRelation = "Sales Shipment Header";
        }
        field(17; "Etiquetas"; Blob)
        {
            Caption = 'Etiquetas expedición';
            DataClassification = ToBeClassified;
        }
        field(18; "Tracking No. DHL"; text[30])
        {
            Caption = 'Num. seguimiento DHL';
            DataClassification = ToBeClassified;
        }
        field(19; "Ship-to Post. Code"; Code[20])
        {
            Caption = 'Envío a cód. postal';
            DataClassification = ToBeClassified;
        }
        field(20; "Estado"; Enum "AED Estados Expedicion")
        {
            Caption = 'Estado envío API';
            DataClassification = ToBeClassified;
        }
        field(21; "Mensaje error"; Blob)
        {
            Caption = 'Mensaje error';
            DataClassification = ToBeClassified;
        }
        field(22; "Cust. No"; Code[20])
        {
            Caption = 'Cod. cliente';
            DataClassification = ToBeClassified;
            TableRelation = Customer;
        }
        field(24; "End day rep. code"; Code[20])
        {
            Caption = 'Cod. end day report';
            DataClassification = ToBeClassified;
            TableRelation = "AED End Day Report";
        }
    }
    keys
    {
        key(PK; "Cod. Expedicion")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        AEDSetup: Record "AED Setup";
        SeriesMngt: Codeunit "No. Series";
    begin
        AEDSetup.Get();
        if Rec."Cod. Expedicion" = '' then
            Rec."Cod. Expedicion" := SeriesMngt.GetNextNo(AEDSetup."Series Num. Expedicion", 0D, true);
    end;

    procedure asignaEtiquetas(textB64: Text)
    var
        b64Convert: Codeunit "Base64 Convert";
        ostr: OutStream;
    begin
        Rec.Etiquetas.CreateOutStream(ostr);
        b64Convert.FromBase64(textB64, ostr);
    end;

    procedure setError(textError: Text)
    var
        outstr: OutStream;
    begin
        Rec."Mensaje error".CreateOutStream(outstr, TextEncoding::UTF8);
        outstr.WriteText(textError);
        rec.Estado := "AED Estados Expedicion"::"Error envio";
    end;

    procedure getError(): Text
    var
        instr: InStream;
        retorno: Text;
    begin
        Rec.CalcFields("Mensaje error");
        Rec."Mensaje error".CreateInStream(instr, TextEncoding::UTF8);
        instr.ReadText(retorno);
        exit(retorno);
    end;

    procedure descargarEtiquetas()
    var
        InStr: InStream;
        FileName: Text;
        filemngtm: Codeunit "File Management";
    begin
        rec.CalcFields(Etiquetas);
        if (not Rec.Etiquetas.HasValue) then
            exit;
        
        rec.Etiquetas.CreateInStream(InStr);
        FileName := filemngtm.StripNotsupportChrInFileName(Rec."Cod. albaran") + '.pdf';
        DownloadFromStream(InStr, '', '', '', FileName);
    end;

    procedure checkEstadosEnvioDHL()
    var
        rEstadosExp: Record "AED Seguimiento Expedicion";
    begin
        rEstadosExp.reset;
        rEstadosExp.SetRange("Cod. Expedicion", Rec."Cod. Expedicion");
        if rEstadosExp.FindSet() then
            repeat
                if rEstadosExp."Cod estado" = 'R' then begin
                    Rec.Estado := Rec.Estado::Entregado;
                    Rec.Modify();
                end;
            until rEstadosExp.Next() = 0;
    end;

}