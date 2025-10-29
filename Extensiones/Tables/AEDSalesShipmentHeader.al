tableextension 70100 "AED Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(70100; "Cod. expedicion"; Code[20])
        {
            Caption = 'Cod. expedición';
            DataClassification = ToBeClassified;
            TableRelation = "AED Cab. Expedicion";
        }
        
    }
    
}