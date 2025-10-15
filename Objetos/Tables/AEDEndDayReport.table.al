table 70103 "AED End Day Report"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1;"End Day Report Code"; Code[20])
        {
            Caption = 'Report Code';
            DataClassification = ToBeClassified;
        }
        field(2; "Report Data"; Blob)
        {
            Caption = 'Report Data';
            DataClassification = ToBeClassified;
        }
        field(3; "No. Expediciones"; Integer)
        {
            Caption = 'Nº expediciones';
            FieldClass = FlowField;
            CalcFormula = count("AED Cab. Expedicion" where ("End day rep. code" = field("End Day Report Code")));
        }
        field(4; "Hora proceso"; DateTime)
        {
            Caption = 'Fecha/Hora proceso';
            DataClassification = ToBeClassified;
        }        
        
    }
    
    keys
    {
        key(PK; "End Day Report Code")
        {
            Clustered = true;
        }
    }

    procedure asignaReport(textB64: Text)
    var
        b64Convert: Codeunit "Base64 Convert";
        ostr: OutStream;
    begin
        Rec."Report Data".CreateOutStream(ostr);
        b64Convert.FromBase64(textB64, ostr);
    end;

    procedure descargarReport()
    var
        InStr: InStream;
        FileName: Text;
        filemngtm: Codeunit "File Management";
    begin
        rec.CalcFields("Report Data");
        if (not Rec."Report Data".HasValue) then
            exit;
        
        rec."Report Data".CreateInStream(InStr);
        FileName := filemngtm.StripNotsupportChrInFileName(Rec."End Day Report Code") + '.pdf';
        DownloadFromStream(InStr, '', '', '', FileName);
    end;

    trigger OnInsert()
    var
        AEDSetup: Record "AED Setup";
        SeriesMngt: Codeunit "No. Series";
    begin
        AEDSetup.Get();
        AEDSetup.TestField("Series Num. End Day");
        if Rec."End Day Report Code" = '' then
            Rec."End Day Report Code" := SeriesMngt.GetNextNo(AEDSetup."Series Num. End Day", 0D, true);
    end;
    
}