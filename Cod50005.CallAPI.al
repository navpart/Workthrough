namespace AL_TNL.AL_TNL;
using Microsoft.Sales.Document;

codeunit 50005 "Call API"
{
    procedure SendPaymentRequest(var Rec: Record "Payment/Receipt.")
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        HttpRequestMessage: HttpRequestMessage;
        HttpHeaders: HttpHeaders;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonResponse: JsonObject;
        PaymentPush: Record "Payment Push";
        DeviceId: Text;
        Amt: Text;
        ToSend: Text;
        Window: Dialog;

    begin
        // Show "Please Wait" message
        Window.Open('Please Wait...');
        PaymentPush.Get();

        // Format values for JSON payload
        Amt := Format(Rec."Credit Amount");
        DeviceId := Rec."Device Id.";

        // Construct JSON object
        JsonObject.Add('deviceid', DeviceId);
        JsonObject.Add('transactionref', Rec."No.");
        JsonObject.Add('amount', Amt);
        JsonObject.Add('customername', Rec."Account Description");

        JsonObject.WriteTo(ToSend);
        HttpContent.WriteFrom(ToSend);

        HttpHeaders.Clear();
        HttpRequestMessage.Method := 'POST';
        HttpRequestMessage.SetRequestUri(PaymentPush."Webservice Url");
        HttpRequestMessage.Content := HttpContent;
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        // Check response status
        if HttpResponseMessage.IsSuccessStatusCode() then begin
            Rec."Payment Successful" := true;
            Rec."Payment Date" := CurrentDateTime();
            Rec.Modify();

            Message('Successful!');
        end else begin
            Error('Not successful!');
        end;

        Window.Close();
    end;


    procedure OnlineOrderingStatus(var OnlineOrderNo: Code[30]; StageText: Text[20]; ApproverText: Text[20])
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        HttpRequestMessage: HttpRequestMessage;
        HttpHeaders: HttpHeaders;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonResponse: JsonObject;
        PaymentPush: Record "Payment Push";
        DeviceId: Text;
        Amt: Text;
        ToSend: Text;
        Window: Dialog;

    Begin

        // Show "Please Wait" message
        Window.Open('Please Wait...');
        PaymentPush.Get();

        JsonObject.Add('OrderNumber', OnlineOrderNo);
        JsonObject.Add('Stage', StageText);
        JsonObject.Add('User', ApproverText);

        JsonObject.WriteTo(ToSend);
        HttpContent.WriteFrom(ToSend);

        HttpHeaders.Clear();
        HttpRequestMessage.Method := 'POST';
        HttpRequestMessage.SetRequestUri(PaymentPush."Online Status Url");
        HttpRequestMessage.Content := HttpContent;
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        // Check response status
        if HttpResponseMessage.IsSuccessStatusCode() then begin

            Message('Successful!');
        end else begin
            Error('Not successful!');
        end;

        Window.Close();

    End;

    
}
