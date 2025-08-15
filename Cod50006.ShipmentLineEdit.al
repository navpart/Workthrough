namespace AL_TNL.AL_TNL;

using Microsoft.Sales.History;

codeunit 50006 "Shipment Line - Edit"
{
    Permissions = TableData "Sales Shipment Line" = rm;
    TableNo = "Sales Shipment Line";

    trigger OnRun()
    begin
        SalesShiptLine := Rec;
        SalesShiptLine.LockTable();
        SalesShiptLine.Find();
        SalesShiptLine.TestField("No.", Rec."No.");
        SalesShiptLine.TestField("Line No.", Rec."Line No.");
        SalesShiptLine."Security Confirmation" := Rec."Security Confirmation";
        SalesShiptLine."Security Confirmation by" := Rec."Security Confirmation by";
        SalesShiptLine.Modify();
        Rec := SalesShiptLine;

    end;

    var
        SalesShiptLine: Record "Sales Shipment Line";

}
