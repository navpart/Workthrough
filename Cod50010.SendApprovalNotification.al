codeunit 50010 "Send Approval Notification"
{
    procedure ProcurementEmail(var Rec: Record "Procurement Header"; VendName: Text; VendAddress: Text; VendAmount: Decimal; AdvanceAmount: Decimal;
    BalanceAmount: Decimal; Justification: Text; MainEmailText: Text)

    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Recipients: Text;
        Subject: Text;
        Body: Text;
        Text001: Label 'Payment Approval Request: %1 %2';

    begin

        Subject := StrSubstNo(Text001, rec."Document Type", rec."No.");

        Body := 'Dear';
        Body += '<br><br>';
        Body += MainEmailText;
        Body += '<br><br>';
        Body += 'Vendor Name: ' + VendName;
        Body += '<br><br>';
        Body += 'Vendor Address: ' + VendAddress;
        Body += '<br><br>';
        Body += 'Vendor Amount: ' + Format(VendAmount);
        Body += '<br><br>';
        Body += 'Advance Amount: ' + Format(AdvanceAmount);
        Body += '<br><br>';
        Body += 'Balance Amount: ' + Format(BalanceAmount);
        Body += '<br><br>';
        Body += 'Purchase Justification: ' + Justification;
        Body += '<br><br>';
        Body += 'Regards,';

        EmailMessage.Create(Recipients, Subject, Body, true);
        Email.OpenInEditorModally(EmailMessage, Enum::"Email Scenario"::Default);


    end;

    procedure ProcurementEmailAttachment(var Rec: Record "Procurement Header")

    var
        ReportNo: Report "Standard Purchase - Order";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        ReportParameters: Text;

        Recipients: Text;
        Subject: Text;
        Body: Text;


    begin

        ReportParameters := ReportNo.RunRequestPage();
        TempBlob.CreateOutStream(OutStr);
        ReportNo.SaveAs(ReportParameters, ReportFormat::Pdf, OutStr);
        TempBlob.CreateInStream(InStr);

        EmailMessage.Create(Recipients, Subject, Body);
        EmailMessage.AddAttachment('Purchase Order.pdf', 'PDF', InStr);
        Email.OpenInEditor(EmailMessage, Enum::"Email Scenario"::Default);


    end;

}
