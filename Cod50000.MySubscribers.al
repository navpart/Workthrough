codeunit 50000 MySubscribers
{
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Table, 17, 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]

    procedure UpdateGLEntry_OnAfterCopyGLEntryFromGenJnlLine(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")

    var

    begin

        GLEntry."Procument No." := GenJournalLine."Procurement No.";
    end;


    [EventSubscriber(ObjectType::Table, 21, 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]

    procedure UpdateCustLedEntry_OnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")

    var


    Begin
        CustLedgerEntry."Serial No" := GenJournalLine."Serial No";
        CustLedgerEntry."Loan ID" := GenJournalLine."Loan ID";
        CustLedgerEntry."Loan Type" := GenJournalLine."Loan Type";
    End;


    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Location Code', true, true)]

    procedure LocationCode_OnValidate(VAR Rec: Record "Sales Line"; VAR xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesLine: Record "Sales Line";
        Location: Record Location;
        UserSetup: Record "User Setup";

    begin
        IF Location.GET(SalesLine."Location Code") THEN
            IF Location."With Accessory" THEN
                SalesLine.Accessory := TRUE ELSE
                SalesLine.Accessory := FALSE;

        IF Location.GET(SalesLine."Location Code") THEN
            IF Location."VRI Location" = TRUE THEN
                MESSAGE('You are picking from a VRI Location!');

        UserSetup.GET(USERID);
        IF ((SalesLine.Type = SalesLine.Type::Item) AND (SalesLine."Posting Group" = 'N_CARS')) THEN BEGIN
            IF Location.GET(SalesLine."Location Code") THEN BEGIN
                IF (Location."Monitored Location" = TRUE) AND (UserSetup."Access to Monitor Location" = FALSE) THEN
                    ERROR('You are not allowed to sell from this Location. Please Contact your Superior for Authorization!')
            END
        end;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Quantity', true, true)]

    procedure Quantity_OnValidate(VAR Rec: Record "Sales Line"; VAR xRec: Record "Sales Line"; CurrFieldNo: Integer)

    var
        SalesLine: Record "Sales Line";
        PurchInvLine: Record "Purch. Inv. Line";

    begin
        IF SalesLine."Variant Code" = 'AIR' THEN BEGIN
            PurchInvLine.SETRANGE("No.", SalesLine."No.");
            IF PurchInvLine.FINDLAST THEN
                SalesLine.Validate("Unit Price", PurchInvLine."Total Retail Price Excl. VAT");
        END;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Variant Code', true, true)]

    procedure VariantCode_OnValidate(VAR Rec: Record "Sales Line"; VAR xRec: Record "Sales Line"; CurrFieldNo: Integer)

    var
        SalesLine: Record "Sales Line";
        PurchInvLine: Record "Purch. Inv. Line";

    begin
        IF SalesLine."Variant Code" = 'AIR' THEN BEGIN
            PurchInvLine.SETRANGE("No.", SalesLine."No.");
            IF PurchInvLine.FINDLAST THEN
                SalesLine.Validate("Unit Price", PurchInvLine."Total Retail Price Excl. VAT");
        END;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Direct Unit Cost', true, true)]

    procedure DirectUnitCost_OnAfterValidate(VAR Rec: Record "Purchase Line"; VAR xRec: Record "Purchase Line"; CurrFieldNo: Integer)

    var
        PurchLine: Record "Purchase Line";
        Item: Record Item;

    begin
        IF Item.GET(PurchLine."No.") THEN BEGIN
            // "Landing Cost" := Item."Factor (Air)" * "Direct Unit Cost";
            PurchLine."Landing Cost" := 1.7 * PurchLine."Direct Unit Cost";
            PurchLine."Landing Cost (LCY)" := PurchLine."Landing Cost" * 400;
            PurchLine."Profit Margin" := PurchLine."Landing Cost (LCY)" * 0.15;
            PurchLine."Total Retail Price Excl. VAT" := PurchLine."Landing Cost (LCY)" + PurchLine."Profit Margin";
            PurchLine."VAT on Retail Price" := PurchLine."Total Retail Price Excl. VAT" * 0.05;
            PurchLine."Total Retail Price Inclu. VAT" := PurchLine."Total Retail Price Excl. VAT" + PurchLine."VAT on Retail Price";
        END;

    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnCopyFromItemOnAfterCheck', '', true, true)]

    procedure Add_OnCopyFromItemOnAfterCheck(PurchaseLine: Record "Purchase Line"; Item: Record Item)

    Begin
        PurchaseLine.Colour := Item."Pre-Owned Colour";
        PurchaseLine."Year of Production" := Item."Year of Production";
        PurchaseLine."Estimated Mileage" := Item."Estimated Mileage";
    End;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterCopyItemJnlLineFromPurchHeader', '', true, true)]

    procedure Add_OnAfterCopyItemJnlLineFromPurchHeader(VAR ItemJnlLine: Record "Item Journal Line"; PurchHeader: Record "Purchase Header")

    begin
        ItemJnlLine.Description := PurchHeader."Posting Description";
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterCopyItemJnlLineFromPurchLine', '', true, true)]

    procedure Add_OnAfterCopyItemJnlLineFromPurchLine(VAR ItemJnlLine: Record "Item Journal Line"; PurchLine: Record "Purchase Line")

    var

    begin
        ItemJnlLine."Year of Production" := PurchLine."Year of Production";
    end;

    [EventSubscriber(ObjectType::Table, 383, 'OnAfterCopyFromGenJnlLine', '', true, true)]

    procedure Add_OnAfterCopyFromGenJnlLine(VAR DtldCVLedgEntryBuffer: Record 383; GenJnlLine: Record "Gen. Journal Line")

    var

    begin
        DtldCVLedgEntryBuffer."Loan ID" := GenJnlLine."Loan ID";
    end;

    [EventSubscriber(ObjectType::Table, 5740, 'OnAfterCheckBeforePost', '', true, true)]

    procedure Add_OnAfterCheckBeforePost(var TransferHeader: Record "Transfer Header")

    Begin
        TransferHeader.TransferControl();
    End;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnBeforeActionEvent', 'PreviewPosting', false, false)]

    procedure ValidatePreviewPosting(var Rec: Record "Sales Header")

    begin
        Rec.PostingControl();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnBeforeActionEvent', 'Post', false, false)]

    procedure ValidatePost(var Rec: Record "Sales Header")

    begin
        Rec.PostingControl();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnBeforeActionEvent', 'PostAndNew', false, false)]

    procedure ValidatePostAndNew(var Rec: Record "Sales Header")

    begin
        Rec.PostingControl();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnBeforeActionEvent', 'PostAndSend', false, false)]

    procedure ValidatePostAndSend(var Rec: Record "Sales Header")

    begin
        Rec.PostingControl();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Credit Memo", 'OnBeforeActionEvent', 'Post', false, false)]

    procedure ValidatePostSalesCrMemo(var Rec: Record "Sales Header")

    Begin
        Rec.PostSalesCreditMemoControl();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', true, true)]
    procedure ChangeFinancialReport(ReportId: Integer; var NewReportId: Integer)

    begin
        if ReportId = Report::"Account Schedule" then
            NewReportId := Report::"Account Schedule2";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', true, true)]
    procedure ChangeCustmerItemSalesReport(ReportId: Integer; var NewReportId: Integer)

    begin
        if ReportId = Report::"Customer/Item Sales" then
            NewReportId := Report::"Customer/Item Sales2";
    end;

    /* [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', true, true)]
    procedure ChangeCustmerDetailTrialBal(ReportId: Integer; var NewReportId: Integer)

    begin
        if ReportId = Report::"Customer - Detail Trial Bal." then
            NewReportId := Report::"Customer - Detail Trial Bal.2";
    end;
 */
    [EventSubscriber(ObjectType::Codeunit, codeunit::"TransferOrder-Post Shipment", 'OnAfterInsertTransShptHeader', '', false, false)]
    procedure AddOnAfterInsertTransShptHeader(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header")

    Begin
        TransferShipmentHeader."COF No." := TransferHeader."COF No.";
        TransferShipmentHeader.Modify();
    End;


    [EventSubscriber(ObjectType::Codeunit, codeunit::"TransferOrder-Post Receipt", 'OnAfterInsertTransRcptHeader', '', false, false)]
    procedure AddOnAfterInsertTransRcptHeader(var TransRcptHeader: Record "Transfer Receipt Header"; var TransHeader: Record "Transfer Header")

    Begin
        TransRcptHeader."COF No." := TransHeader."COF No.";
        TransRcptHeader.Modify();
    End;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterOnInsert', '', false, false)]
    procedure OnAfterInsertSalesHeader(var SalesHeader: Record "Sales Header")
    var
        UserSetup: Record "User Setup";
    begin

        IF UserSetup.GET(USERID) THEN
            SalesHeader."Shortcut Dimension 1 Code" := UserSetup.Department;

    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Shipment Header - Edit", 'OnBeforeSalesShptHeaderModify', '', false, false)]
    procedure AddOnBeforeSalesShptHeaderModify(var SalesShptHeader: Record "Sales Shipment Header"; FromSalesShptHeader: Record "Sales Shipment Header")

    begin
        SalesShptHeader."Acknowledged Doc Link" := FromSalesShptHeader."Acknowledged Doc Link";
        SalesShptHeader."Audit Summary" := FromSalesShptHeader."Audit Summary";
    end;


    [EventSubscriber(ObjectType::Page, Page::"Service Order", 'OnBeforeActionEvent', 'Post', false, false)]

    procedure ValidateServPost(var Rec: Record "Service Header")

    begin
        Rec.CheckControls();
    end;

     [EventSubscriber(ObjectType::Page, Page::"Service Order", 'OnBeforeActionEvent', 'Preview', false, false)]

    procedure ValidateServPreview(var Rec: Record "Service Header")

    begin
        Rec.CheckControls();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Service Lines", 'OnBeforeActionEvent', 'Post', false, false)]

    procedure ValidateServLinePost(var Rec: Record "Service Line")

    begin
        Rec.ServLineCheckControls();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Service Lines", 'OnBeforeActionEvent', 'Preview', false, false)]

    procedure ValidateServLinePreview(var Rec: Record "Service Line")

    begin
        Rec.ServLineCheckControls();
    end;


}

