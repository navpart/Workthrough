codeunit 50004 "General Purpose Codeunit-1"
{

    trigger OnRun()
    begin
    end;

    var
        LDay: Date;
        LCatRec: Record 50074;
        Dy: Integer;
        Mth: Integer;
        Yr: Integer;
        DateRec2: Record 2000000007;
        HolidayRec: Record 50070;
        WkDay: Text[10];
        Cnt: Integer;
        TmpDate: Date;
        TempDate: Date;
        EDRec: Record 50001;
        MVOLines: Record 50027;
        OK: Boolean;
        Text000: Label 'The update has been interrupted to respect the warning.';
        value1: Integer;
        value2: Integer;
        value3: Decimal;
        value4: Integer;
        value5: Integer;
        valueword1: Text[10];
        valueword2: Text[10];
        valueword3: Text[10];
        valueword4: Text[20];
        valueword5: Text[200];
        word1: Text[60];
        word2: Text[100];
        word3: Text[60];
        word5: Text[30];
        wordarray: array[20] of Text[10];
        arrayval: array[20] of Text[10];
        a: Integer;
        VALLENT: Integer;
        valent: Integer;
        i: Integer;
        deci: Text[3];
        "------------------------------": Integer;
        GenJnlLine: Record 81;
        GenJnlBatch: Record 232;
        GenJnlTemplate: Record 80;
        GenJnlLine2: Record 81;
        AmtFactor: Decimal;
        GenJnlPost: Codeunit 231;
        LineNo: Integer;
        Customer: Record 18;
        ItemLedgEntry: Record 32;
        ItemLedgEntryNo: Integer;
        ValueEntry: Record 5802;
        ReservEntry: Record 337;
        SerialNo: Code[20];
        SalesLine: Record 37;
        ItemNo: Code[20];
        UnitPrice: Decimal;
        UserSetup: Record 91;
        Margin: Decimal;


    procedure ExplodeLeavePlan(LPlanRec: Record 50075)
    var
        LeaveRosterRec: Record 50077;
        LNO: Integer;
        DDate: Record 2000000007;
    begin
        // Added by SGG to explode Leave Plans into Leave Roster Table

        IF (LPlanRec."Serial No" = '') OR
           (LPlanRec."Employee No." = '') OR
           (LPlanRec."Actual End Date" = 0D) OR
           (LPlanRec."Actual Start Date" = 0D) OR
           (LPlanRec.Registered)
           THEN
            EXIT;


        IF LeaveRosterRec.FIND('+') THEN
            LNO := LeaveRosterRec."Entry no" + 1
        ELSE
            LNO := 1;

        /////////////////

        FOR LDay := LPlanRec."Actual Start Date" TO LPlanRec."Actual End Date" DO BEGIN
            IF NOT (IsHoliday(LDay)) THEN BEGIN
                LeaveRosterRec.INIT;
                LeaveRosterRec."Employee No" := LPlanRec."Employee No.";
                LeaveRosterRec."Entry no" := LNO;
                LeaveRosterRec."Entry Type" := LPlanRec."Entry Type";
                LeaveRosterRec."Leave Category" := LPlanRec."Leave Category";
                IF LCatRec.GET(LeaveRosterRec."Leave Category") THEN
                    LeaveRosterRec.Consuming := LCatRec.Consuming;
                LeaveRosterRec.LeaveDate := LDay;
                LeaveRosterRec.LeavePlanNo := LPlanRec."Serial No";
                LeaveRosterRec."Business Unit Code" := LPlanRec."Business Unit";
                LeaveRosterRec."Global Dimension 1 Code" := LPlanRec."Global Dimension 1 Code";
                LeaveRosterRec."Global Dimension 2 Code" := LPlanRec."Global Dimension 2 Code";
                LeaveRosterRec.Duration := 1;

                LeaveRosterRec.INSERT;
                LNO := LNO + 1;
            END;
        END;


        LPlanRec.VALIDATE(Registered, TRUE);
        LPlanRec.MODIFY;

        //MESSAGE(FORMAT(LPlanRec.Exploded));
    end;


    procedure ExplodeActualLeave(LPlanRec: Record 50075)
    var
        LeaveRosterRec: Record 50077;
        LNO: Integer;
        DDate: Record 2000000007;
    begin
        // Added by SGG to explode Actual Leaves into Leave Roster Table

        //IF (LPlanRec."Serial No" = '') OR

        IF (LPlanRec."Employee No." = '') OR
           (LPlanRec."Actual End Date" = 0D) OR
           (LPlanRec."Actual Start Date" = 0D) OR
           (LPlanRec.Registered)
           THEN
            EXIT;


        IF LeaveRosterRec.FIND('+') THEN
            LNO := LeaveRosterRec."Entry no" + 1
        ELSE
            LNO := 1;

        /////////////////

        FOR LDay := LPlanRec."Actual Start Date" TO LPlanRec."Actual End Date" DO BEGIN
            IF NOT (IsHoliday(LDay)) THEN BEGIN
                LeaveRosterRec.INIT;
                LeaveRosterRec."Employee No" := LPlanRec."Employee No.";
                LeaveRosterRec."Entry no" := LNO;
                LeaveRosterRec."Entry Type" := LPlanRec."Entry Type";
                LeaveRosterRec."Leave Category" := LPlanRec."Leave Category";
                IF LCatRec.GET(LeaveRosterRec."Leave Category") THEN
                    LeaveRosterRec.Consuming := LCatRec.Consuming;
                LeaveRosterRec.LeaveDate := LDay;
                LeaveRosterRec."Leave Period" := LPlanRec."Leave Period";
                LeaveRosterRec.LeavePlanNo := LPlanRec."Serial No";
                LeaveRosterRec."Business Unit Code" := LPlanRec."Business Unit";
                LeaveRosterRec."Global Dimension 1 Code" := LPlanRec."Global Dimension 1 Code";
                LeaveRosterRec."Global Dimension 2 Code" := LPlanRec."Global Dimension 2 Code";
                LeaveRosterRec.Duration := 1;

                LeaveRosterRec.INSERT;
                LNO := LNO + 1;
            END;
        END;


        LPlanRec.VALIDATE(Registered, TRUE);
        LPlanRec.MODIFY;
    end;


    procedure IsHoliday(CheckDate: Date): Boolean
    begin
        Dy := DATE2DMY(CheckDate, 1);
        Mth := DATE2DMY(CheckDate, 2);
        Yr := DATE2DMY(CheckDate, 3);

        DateRec2.RESET;
        HolidayRec.RESET;
        HolidayRec.SETRANGE(Day, Dy);
        HolidayRec.SETRANGE(Month, Mth);

        IF HolidayRec.COUNT <> 0 THEN
            EXIT(TRUE)
        ELSE BEGIN
            DateRec2.SETRANGE("Period Type", DateRec2."Period Type"::Date);
            DateRec2.SETRANGE("Period Start", CheckDate);
            IF DateRec2.FindLast() THEN BEGIN
                WkDay := DateRec2."Period Name";
                HolidayRec.RESET;
                HolidayRec.SETRANGE(HolidayRec."Day Of Week", WkDay);
                IF HolidayRec.COUNT <> 0 THEN
                    EXIT(TRUE)
                ELSE
                    EXIT(FALSE);
            END
            ELSE
                EXIT(FALSE);
        END;
    end;


    procedure GetEndDate(StartD: Date; NoOfDays: Integer): Date
    begin
        TmpDate := StartD - 1;
        Cnt := 0;
        REPEAT
            TmpDate := TmpDate + 1;
            IF NOT (IsHoliday(TmpDate)) THEN Cnt := Cnt + 1;
        UNTIL (Cnt = NoOfDays);
        EXIT(TmpDate);
    end;


    procedure GetStartDate(EndD: Date; NoOfDays: Integer): Date
    begin
        TmpDate := EndD + 1;
        Cnt := 0;
        REPEAT
            TmpDate := TmpDate - 1;
            IF NOT (IsHoliday(TmpDate)) THEN Cnt := Cnt + 1;
        UNTIL (Cnt = NoOfDays);
        EXIT(TmpDate);
    end;


    procedure GetNoOfDays(StartD: Date; EndD: Date): Integer
    begin
        TmpDate := StartD - 1;
        Cnt := 0;
        REPEAT
            TmpDate := TmpDate + 1;
            IF NOT (IsHoliday(TmpDate)) THEN Cnt := Cnt + 1;
        UNTIL (TmpDate = EndD);
        EXIT(Cnt);
    end;


    procedure GetGrossED(SearchED: Option " ","NSITF Employee","NSITF Employer","Gross Salary","Pension Employee","Pension Employer"): Code[20]
    begin
        EDRec.SETCURRENTKEY(EDRec."ED Type");
        EDRec.SETRANGE(EDRec."ED Type", SearchED);

        IF EDRec.FIND('-') THEN EXIT(EDRec."E/D Code");
    end;


    procedure PayrollMonthofDate(InputDate: Date; locPeriodRec: Record 50004): Integer
    begin
        locPeriodRec.SETRANGE(locPeriodRec."Start Date", 0D, InputDate);
        EXIT(DATE2DMY(locPeriodRec."Start Date", 2));
    end;


    procedure BCLookup(RegionCode: Code[10]; costcenter: Code[10]): Code[10]
    var
        RegionRec: Record 220;
        g: Integer;
        BUFilter: Code[250];
    begin
        /*
        Bcrec.RESET;
        Bcrec.FILTERGROUP(0);
        
        
        IF costcenter<>'' THEN BEGIN
        ValidCenter.SETRANGE(ValidCenter."Global Dimension 2 Code",costcenter);
        IF NOT ValidCenter.FIND('-') THEN
          ERROR('Invalid Cost Center!');
        BUFilter := '';
        g:=2;
        REPEAT
        IF BUFilter='' THEN
         BUFilter := ValidCenter."Global Dimension 1 Code"
        ELSE
        BUFilter := BUFilter+'|'+ValidCenter."Global Dimension 1 Code";
        UNTIL ValidCenter.NEXT=0;
        Bcrec.SETFILTER(Bcrec.Code,BUFilter);
        END;
        IF RegionCode<>'' THEN
        Bcrec.SETRANGE(Bcrec."Business Unit Code",RegionCode);
        
        Bcrec.FILTERGROUP(0);
        IF FORM.RUNMODAL(FORM::Departments,Bcrec)=ACTION::LookupOK THEN BEGIN
        EXIT(Bcrec.Code);
        END;
        EXIT('');
        */

    end;


    procedure LocalBCLookup(costCenter: Code[10]): Code[10]
    var
        RegionRec: Record 220;
        g: Integer;
        BUFilter: Code[250];
    begin
        /*
        RegionRec.RESET;
        RegionRec.SETRANGE(RegionRec."Default Region",TRUE);
        RegionRec.FIND('-');
        Bcrec.RESET;
        Bcrec.FILTERGROUP(0);
        
        
        IF costCenter<>'' THEN BEGIN
        ValidCenter.SETRANGE(ValidCenter."Global Dimension 2 Code",costCenter);
        IF NOT ValidCenter.FIND('-') THEN
          ERROR('Invalid Cost Center!');
        BUFilter := '';
        g:=2;
        REPEAT
        IF BUFilter='' THEN
         BUFilter := ValidCenter."Global Dimension 1 Code"
        ELSE
        BUFilter := BUFilter+'|'+ValidCenter."Global Dimension 1 Code";
        UNTIL ValidCenter.NEXT=0;
        Bcrec.SETFILTER(Bcrec.Code,BUFilter);
        END;
        Bcrec.SETRANGE(Bcrec."Business Unit Code",RegionRec.Code);
        Bcrec.FILTERGROUP(0);
        //MESSAGE(BUFilter+'   '+RegionRec.Code);
        
        
        IF FORM.RUNMODAL(FORM::Departments,Bcrec)=ACTION::LookupOK THEN BEGIN
        //MESSAGE(Bcrec.Code);
        EXIT(Bcrec.Code);
        END;
        EXIT('');
        */

    end;


    procedure CCLookup(RegionCode: Code[10]; budgetcenter: Code[10]): Code[10]
    var
        RegionRec: Record 220;
        g: Integer;
        ccFilter: Code[250];
    begin
        /*
        CCrec.RESET;
        CCrec.FILTERGROUP(1);
        
        IF budgetcenter<>'' THEN BEGIN
        ValidCenter.SETRANGE(ValidCenter."Global Dimension 1 Code",budgetcenter);
        IF NOT ValidCenter.FIND('-') THEN
          ERROR('There is no Valid cost center in the selected budget Center!');
        ccFilter := '';
        g:=2;
        REPEAT
        IF ccFilter='' THEN
         ccFilter := ValidCenter."Global Dimension 2 Code"
        ELSE
        ccFilter := ccFilter+'|'+ValidCenter."Global Dimension 2 Code";
        UNTIL ValidCenter.NEXT=0;
        CCrec.SETFILTER(CCrec.Code,ccFilter);
        END;
        
        //ccrec.SETRANGE(ccrec."Region Code",RegionCode);
        
        CCrec.FILTERGROUP(0);
        IF FORM.RUNMODAL(FORM::Projects,CCrec)=ACTION::LookupOK THEN BEGIN
        EXIT(CCrec.Code);
        END;
        EXIT('');
        */

    end;


    procedure ForeignBCLookup(costCenter: Code[10]): Code[10]
    var
        RegionRec: Record 220;
        g: Integer;
        BUFilter: Code[250];
    begin
        /*
        RegionRec.RESET;
        RegionRec.SETRANGE(RegionRec."Default Region",TRUE);
        RegionRec.FIND('-');
        Bcrec.RESET;
        Bcrec.FILTERGROUP(1);
        
        
        IF costCenter<>'' THEN BEGIN
        ValidCenter.SETRANGE(ValidCenter."Global Dimension 2 Code",costCenter);
        IF NOT ValidCenter.FIND('-') THEN
          ERROR('Invalid Cost Center!');
        BUFilter := '';
        g:=2;
        REPEAT
        IF BUFilter='' THEN
         BUFilter := ValidCenter."Global Dimension 1 Code"
        ELSE
        BUFilter := BUFilter+'|'+ValidCenter."Global Dimension 1 Code";
        UNTIL ValidCenter.NEXT=0;
        Bcrec.SETFILTER(Bcrec.Code,BUFilter);
        END;
        Bcrec.SETFILTER(Bcrec."Business Unit Code",'<>'+RegionRec.Code);
        Bcrec.FILTERGROUP(0);
        IF FORM.RUNMODAL(FORM::Departments,Bcrec)=ACTION::LookupOK THEN BEGIN
        //MESSAGE(Bcrec.Code);
        EXIT(Bcrec.Code);
        END;
        EXIT('');
        */

    end;


    procedure CmdProperties(zRole: Code[250]; zFormID: Integer; zCmd: Integer): Integer
    var
        tPermission: Integer;
    begin
        //IF MemberRec.GET(USERID,'super') THEN EXIT(0);
        /*
        permit.SETCURRENTKEY("Role ID","Form ID","Control ID");
        Permit.SETFILTER(Permit."Role ID",zRole);
        Permit.SETFILTER("Form ID",FORMAT(zFormID)+'|0');
        Permit.SETFILTER("Control ID",FORMAT(zCmd)+'|0');
        tPermission := 2;
        //MESSAGE(FORMAT(Permit.COUNT) + 'count');
        IF Permit.FIND('-') THEN
        REPEAT
          IF Permit.Permission<tPermission THEN
             tPermission := Permit.Permission;
        UNTIL (Permit.NEXT=0) OR (tPermission=0)
        ELSE
        EXIT(2);
        
        
        EXIT(tPermission+1);
         */

    end;


    procedure AutoLocalBCLookup(costCenter: Code[10]): Code[10]
    var
        RegionRec: Record 220;
        g: Integer;
        BUFilter: Code[250];
    begin
        /*
        RegionRec.RESET;
        RegionRec.SETRANGE(RegionRec."Default Region",TRUE);
        RegionRec.FIND('-');
        Bcrec.RESET;
        Bcrec.FILTERGROUP(0);
        
        
        IF costCenter<>'' THEN BEGIN
        ValidCenter.SETRANGE(ValidCenter."Global Dimension 2 Code",costCenter);
        IF NOT ValidCenter.FIND('-') THEN
          ERROR('Invalid Cost Center!');
        BUFilter := '';
        g:=2;
        REPEAT
        IF BUFilter='' THEN
         BUFilter := ValidCenter."Global Dimension 1 Code"
        ELSE
        BUFilter := BUFilter+'|'+ValidCenter."Global Dimension 1 Code";
        UNTIL ValidCenter.NEXT=0;
        Bcrec.SETFILTER(Bcrec.Code,BUFilter);
        END;
        Bcrec.SETRANGE(Bcrec."Business Unit Code",RegionRec.Code);
        Bcrec.FILTERGROUP(0);
        //MESSAGE(BUFilter+'   '+RegionRec.Code);
        
        IF Bcrec.FIND('-') THEN
        IF Bcrec.COUNT=1 THEN
         EXIT(Bcrec.Code)
        ELSE
        EXIT('');
        */

    end;


    procedure GetMonthlyVedhiclePurchase(PurchHdr: Record 38; OrderMonth: Date)
    var
        SKU: Record 5700;
        OmUpdate: Dialog;
        PurchLines: Record 39;
        LineNo: Integer;
        Text000: Label 'There is No Vehicle Order for the Period Starting %1!';
    begin
        IF OrderMonth <> 0D THEN BEGIN
            SKU.SETCURRENTKEY(SKU."Order Period Staring Date");
            SKU.SETRANGE(SKU."Order Period Staring Date", OrderMonth);
            IF SKU.FIND('-') THEN BEGIN
                ;
                SKU.SETCURRENTKEY("Location Code", "Item No.", "Variant Code");
                PurchLines.SETRANGE(PurchLines."Document Type", PurchHdr."Document Type");
                PurchLines.SETRANGE(PurchLines."Document No.", PurchHdr."No.");
                IF PurchLines.FIND('+') THEN
                    LineNo := PurchLines."Line No." + 10000
                ELSE
                    LineNo := 10000;

                REPEAT
                    PurchLines.INIT;
                    PurchLines.VALIDATE(PurchLines."Document Type", PurchHdr."Document Type");
                    PurchLines.VALIDATE(PurchLines."Document No.", PurchHdr."No.");
                    PurchLines."Line No." := LineNo;
                    PurchLines.VALIDATE(PurchLines."Buy-from Vendor No.", PurchHdr."Buy-from Vendor No.");
                    PurchLines.VALIDATE(PurchLines.Type, PurchLines.Type::Item);
                    PurchLines.VALIDATE(PurchLines."No.", SKU."Item No.");
                    PurchLines.VALIDATE(PurchLines."Variant Code", SKU."Variant Code");
                    PurchLines.VALIDATE(PurchLines.Colour, SKU.Colour);
                    PurchLines.VALIDATE(PurchLines."Location Code", SKU."Location Code");
                    PurchLines.VALIDATE(PurchLines.Quantity, 1);

                    MVOLines.SETRANGE(MVOLines."PO Number", SKU."PO Number");
                    MVOLines.SETRANGE(MVOLines."Model No.", SKU."Item No.");
                    MVOLines.SETRANGE(MVOLines.Colour, SKU.Colour);
                    IF SKU.FIND('-') THEN BEGIN
                        PurchLines.VALIDATE(PurchLines."Direct Unit Cost", MVOLines."Unit Cost");
                        PurchLines.VALIDATE(PurchLines."Indirect Cost %", MVOLines."Indirect Cost%")
                    END;

                    PurchLines.INSERT(TRUE);
                    LineNo := LineNo + 10000;
                UNTIL (SKU.NEXT = 0);
            END
            ELSE
                MESSAGE(Text000, OrderMonth);
        END;
    end;


    procedure GetStoredDept(): Code[100]
    var
        UserSetup: Record 91;
    begin
        IF UserSetup.GET(USERID) THEN
            EXIT(UserSetup."Global Dimension 1 Filter")
        ELSE
            EXIT('');
    end;


    procedure GetSalesInvoiceNo(): Code[100]
    var
        UserSetup: Record 91;
    begin
        IF UserSetup.GET(USERID) THEN
            EXIT(UserSetup."Sales Invoice Nos.")
        ELSE
            EXIT('');
    end;


    procedure GetSalesOrderNo(): Code[100]
    var
        UserSetup: Record 91;
    begin
        IF UserSetup.GET(USERID) THEN
            EXIT(UserSetup."Sales Order No Series")
        ELSE
            EXIT('');
    end;


    procedure GetSalesCrMemoNo(): Code[100]
    var
        UserSetup: Record 91;
    begin
        IF UserSetup.GET(USERID) THEN
            EXIT(UserSetup."Sales Credit Memo No Series")
        ELSE
            EXIT('');
    end;


    procedure GetSalesBlkOrderNo(): Code[100]
    var
        UserSetup: Record 91;
    begin
        IF UserSetup.GET(USERID) THEN
            EXIT(UserSetup."Sales Blanket Order No Series")
        ELSE
            EXIT('');
    end;


    procedure GetSalesQuoteNo(): Code[100]
    var
        UserSetup: Record 91;
    begin
        IF UserSetup.GET(USERID) THEN
            EXIT(UserSetup."Sales Quote No Series")
        ELSE
            EXIT('');
    end;


    procedure GetStoredPostedSalesNo(): Code[100]
    var
        UserSetup: Record 91;
    begin
        IF UserSetup.GET(USERID) THEN
            EXIT(UserSetup."Posted Sales Inv. Nos.")
        ELSE
            EXIT('');
    end;


    procedure GetSalesDocumentNoSeries(DocType: Option Salesinv,SalesQuote,SalesBlkOrder,SalesOrder,SalesCrMemo,PSalesInv,PSalesShpmt,PSalesCrMemo): Code[100]
    var
        UserSetup: Record 91;
    begin
        IF NOT UserSetup.GET(USERID) THEN
            EXIT('')
        ELSE BEGIN
            CASE DocType OF
                DocType::Salesinv:
                    EXIT(UserSetup."Sales Invoice Nos.");
                DocType::SalesQuote:
                    EXIT(UserSetup."Sales Quote No Series");
                DocType::SalesOrder:
                    EXIT(UserSetup."Sales Order No Series");
                DocType::SalesCrMemo:
                    EXIT(UserSetup."Sales Credit Memo No Series");
                DocType::PSalesInv:
                    EXIT(UserSetup."Posted Sales Inv. Nos.");
                DocType::PSalesShpmt:
                    EXIT(UserSetup."Posted Sales Shipmt No Series");
                DocType::PSalesCrMemo:
                    EXIT(UserSetup."Posted Sales Cr Memo Nos.");
            END/*case*/;
        END/*Begin*/;

    end;


    procedure GetPurchaseDocumentNoSeries(DocType: Option Purchinv,PurchQuote,PurchBlkOrder,PurchOrder,PurchCrMemo,PPurchInv,PPurchRecpt,PPurchCrMemo): Code[100]
    var
        UserSetup: Record 91;
    begin
        IF NOT UserSetup.GET(USERID) THEN
            EXIT('')
        ELSE BEGIN
            CASE DocType OF
                DocType::Purchinv:
                    EXIT(UserSetup."Purch Invoice Nos.");
                DocType::PurchQuote:
                    EXIT(UserSetup."Purch Quote No Series");
                DocType::PurchOrder:
                    EXIT(UserSetup."Purch Order Nos.");
                DocType::PurchCrMemo:
                    EXIT(UserSetup."Purch Credit Memo No Series");
                DocType::PPurchInv:
                    EXIT(UserSetup."Posted Purch Invoice Nos.");
                DocType::PPurchRecpt:
                    EXIT(UserSetup."Posted Purch Receipt No Series");
                DocType::PPurchCrMemo:
                    EXIT(UserSetup."Posted Purch Cr Memo No Series");
            END/*case*/;
        END;

    end;


    procedure ItemJnlCheckLine(ItemJnlLine: Record 83)
    begin
        /*
        COMMIT;
        IF CheckItemAvail.ItemJnlLineShowWarning(ItemJnlLine) THEN BEGIN
          OK := CheckItemAvail.RUNMODAL = ACTION::Yes;
          CLEAR(CheckItemAvail);
          IF NOT OK THEN
            ERROR(Text000);
        END;
        */

    end;


    procedure SalesLineCheck(SalesLine: Record 37)
    begin
        /*IF CheckItemAvail.SalesLineShowWarning(SalesLine) THEN BEGIN
          OK := CheckItemAvail.RUNMODAL = ACTION::Yes;
          CLEAR(CheckItemAvail);
          IF NOT OK THEN
            ERROR(Text000);
        END;
        */

    end;


    procedure TransferLineCheck(TransLine: Record 5741)
    begin
        /*IF CheckItemAvail.TransferLineShowWarning(TransLine) THEN BEGIN
          OK := CheckItemAvail.RUNMODAL = ACTION::Yes;
          CLEAR(CheckItemAvail);
          IF NOT OK THEN
            ERROR(Text000);
        END;
        */

    end;


    procedure ServiceInvLineCheck(ServInvLine: Record 5902)
    begin
        /*IF CheckItemAvail.ServiceInvLineShowWarning(ServInvLine) THEN BEGIN
          OK := CheckItemAvail.RUNMODAL = ACTION::Yes;
          CLEAR(CheckItemAvail);
          IF NOT OK THEN
            ERROR(Text000);
        END;
         */

    end;


    procedure PostIOUPayment(var IOURec: Record 50105; CancelIOU: Boolean)
    begin
        IF NOT CancelIOU THEN BEGIN
            IF NOT CONFIRM('Do you want to post the IOU!') THEN EXIT;
        END ELSE BEGIN
            IF NOT CONFIRM('Do you want to cancel the IOU!') THEN EXIT;
        END;

        IF NOT GenJnlBatch.GET('GENERAL', 'IOU') THEN BEGIN
            GenJnlBatch.INIT;
            GenJnlBatch."Journal Template Name" := 'GENERAL';
            GenJnlBatch.Name := 'IOU';
            GenJnlBatch.Description := 'IOU Payment';
            //GenJnlBatch."Payer/Collector Name" := IOURec."Staff Name";
            GenJnlBatch.INSERT;
        END;

        IF CancelIOU THEN
            AmtFactor := -1
        ELSE
            AmtFactor := 1;

        IOURec.TESTFIELD(IOURec."IOU No.");
        //TESTFIELD("Manual Voucher No.");
        //TESTFIELD("Account No.");
        IOURec.TESTFIELD(IOURec."Bal. Account No.");
        //TESTFIELD(Paid);
        IOURec.TESTFIELD(IOURec.Amount);
        //delete records if any exists
        GenJnlLine2.SETRANGE("Journal Template Name", 'GENERAL');
        GenJnlLine2.SETRANGE("Journal Batch Name", 'IOU');
        IF GenJnlLine2.FINDSET THEN
            GenJnlLine2.DELETEALL;
        // create gen. jnl. line
        GenJnlLine.INIT;
        GenJnlLine."Journal Template Name" := 'GENERAL';
        GenJnlLine."Journal Batch Name" := 'IOU';
        GenJnlLine."Document No." := IOURec."IOU No.";
        GenJnlLine."Line No." := 10000;
        GenJnlLine."External Document No." := IOURec."Manual Voucher No.";
        GenJnlLine."System-Created Entry" := TRUE;
        GenJnlLine."Account Type" := IOURec."Account Type";
        GenJnlLine.VALIDATE(GenJnlLine."Account No.", IOURec."Account No.");
        GenJnlLine."Posting Date" := TODAY;
        GenJnlLine."Document Date" := IOURec."Entry Date";
        //GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine.Description := IOURec.Description;
        GenJnlLine.VALIDATE(GenJnlLine.Amount, IOURec.Amount * AmtFactor);
        IF IOURec."Bal. Account Type" <> IOURec."Bal. Account Type"::" " THEN
            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account"
        ELSE
            GenJnlLine."Bal. Account Type" := IOURec."Bal. Account Type";
        GenJnlLine.VALIDATE(GenJnlLine."Bal. Account No.", IOURec."Bal. Account No.");
        GenJnlLine.VALIDATE(GenJnlLine."Shortcut Dimension 1 Code", IOURec."Global Dimension 1 Code");
        GenJnlLine.VALIDATE(GenJnlLine."Shortcut Dimension 2 Code", IOURec."Global Dimension 2 Code");
        GenJnlLine."Payer/Collector Name" := IOURec."Staff Name";
        GenJnlLine."VAT Bus. Posting Group" := '';
        GenJnlLine."VAT Prod. Posting Group" := '';
        GenJnlLine."Bal. VAT Bus. Posting Group" := '';
        GenJnlLine."Bal. VAT Prod. Posting Group" := '';
        GenJnlLine.VALIDATE("VAT %", 0);
        GenJnlLine."Reason Code" := 'IOU';
        GenJnlLine.INSERT;
        GenJnlPost.RUN(GenJnlLine);
        // update IOURec as paid
        IF NOT CancelIOU THEN BEGIN
            //"Payment Date" := TODAY;
            IOURec.Posted := TRUE;
        END ELSE BEGIN
            IOURec.Void := TRUE;
            IOURec."Voided By" := USERID;
        END;
        IOURec.MODIFY;
    end;


    procedure PostIOURetirement(var Rec: Record 50107)
    var
        IOURec: Record 50105;
        RetLines: Record 50106;
        RetLines2: Record 50106;
        GenJnlBatch: Record 232;
        GenJnlLine: Record 81;
        PayRecpt: Record 50103;
        NoSeriesMgt: Codeunit "No. Series";
        LineNo: Integer;
        DocNo: Code[20];
        AcctType: array[3] of Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset";
        AcctNo: array[3] of Code[20];
        Descr: array[3] of Text[30];
        RemAmt: Decimal;
        Claim: Decimal;
        Refund: Decimal;
        LineCount: Integer;
        i: Integer;
        GLEntry: Record 17;
    begin

        IF NOT GenJnlBatch.GET('GENERAL', 'RETIRE') THEN BEGIN
            GenJnlBatch.INIT;
            GenJnlBatch."Journal Template Name" := 'GENERAL';
            GenJnlBatch.Name := 'RETIRE';
            GenJnlBatch.Description := 'IOU Retirement';
            GenJnlBatch.INSERT;
        END ELSE BEGIN
            GenJnlBatch.Description := 'IOU Retirement';
            GenJnlBatch.MODIFY;
        END;

        //clear journal lines
        GenJnlLine2.SETRANGE("Journal Template Name", 'GENERAL');
        GenJnlLine2.SETRANGE("Journal Batch Name", 'RETIRE');
        IF GenJnlLine2.FINDSET THEN
            GenJnlLine2.DELETEALL;

        RemAmt := 0;
        Claim := 0;
        Refund := 0;
        LineNo := 10000;


        //.....Dada: The option is removed from the form as requested by Audit.
        IOURec.GET(Rec."IOU No.");
        IOURec.CALCFIELDS(IOURec."Amount Retired");
        Rec.CALCFIELDS(Rec."Amount To Retire");
        RemAmt := IOURec.Amount - (IOURec."Amount Retired" + Rec."Amount To Retire");
        IF (RemAmt = 0) OR (RemAmt < 0) THEN
            Rec."Retirement Options" := Rec."Retirement Options"::"Full Retirement"
        ELSE
            Rec."Retirement Options" := Rec."Retirement Options"::"Partial Retirement";

        //.....Dada


        CASE Rec."Retirement Options" OF
            0:
                BEGIN  //full retirement
                    IOURec.GET(Rec."IOU No.");
                    IOURec.CALCFIELDS(IOURec."Amount Retired");
                    Rec.CALCFIELDS(Rec."Amount To Retire");
                    RemAmt := IOURec.Amount - (IOURec."Amount Retired" + Rec."Amount To Retire");
                    IF RemAmt < 0 THEN
                        Claim := ABS(RemAmt)
                    ELSE
                        IF RemAmt > 0 THEN
                            Refund := ABS(RemAmt)
                        ELSE BEGIN
                            Claim := 0;
                            Refund := 0;
                        END;
                    //create journal
                    RetLines.SETFILTER(RetLines."Retirement No.", Rec."No.");
                    RetLines.FINDSET;
                    REPEAT
                        GenJnlLine."Journal Template Name" := 'GENERAL';
                        GenJnlLine."Journal Batch Name" := 'RETIRE';
                        GenJnlLine."Line No." := LineNo;
                        GenJnlLine."Posting Date" := Rec."Entry Date";
                        GenJnlLine."Account Type" := RetLines."Account Type";
                        GenJnlLine.VALIDATE(GenJnlLine."Account No.", RetLines."Account No.");
                        GenJnlLine."Document No." := Rec."No.";
                        GenJnlLine.Description := RetLines.Description;
                        GenJnlLine.VALIDATE(GenJnlLine."Shortcut Dimension 1 Code", RetLines."Shortcut Dimension 1 Code");
                        GenJnlLine.VALIDATE(GenJnlLine."Shortcut Dimension 2 Code", RetLines."Shortcut Dimension 2 Code");
                        GenJnlLine.VALIDATE(GenJnlLine.Amount, RetLines.Amount);
                        GenJnlLine."Reason Code" := 'RETIRE';
                        GenJnlLine."System-Created Entry" := TRUE;
                        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
                        GenJnlLine."Gen. Bus. Posting Group" := '';
                        GenJnlLine."Gen. Prod. Posting Group" := '';
                        GenJnlLine."VAT Bus. Posting Group" := '';
                        GenJnlLine."VAT Prod. Posting Group" := '';
                        IF GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset" THEN BEGIN
                            GenJnlLine."Depreciation Book Code" := '';
                            GenJnlLine."FA Posting Type" := GenJnlLine."FA Posting Type"::" ";
                            GenJnlLine."Maintenance Code" := '';
                        END ELSE BEGIN
                            GenJnlLine.VALIDATE("FA Posting Type", RetLines."FA Posting Type");
                            GenJnlLine.VALIDATE("Maintenance Code", RetLines."Maintenance Code");
                        END;
                        GenJnlLine.INSERT;
                        LineNo := LineNo + 10000;
                    UNTIL RetLines.NEXT = 0;
                    //insert bal acc
                    GenJnlLine."Journal Template Name" := 'GENERAL';
                    GenJnlLine."Journal Batch Name" := 'RETIRE';
                    GenJnlLine."Line No." := LineNo;
                    GenJnlLine."Posting Date" := Rec."Entry Date";
                    GenJnlLine."Account Type" := IOURec."Account Type";
                    GenJnlLine.VALIDATE(GenJnlLine."Account No.", IOURec."Account No.");
                    GenJnlLine."Document No." := Rec."No.";
                    GenJnlLine.Description := 'IOU Retirement' + ' ' + 'of' + ' ' + Rec."IOU No.";
                    GenJnlLine.VALIDATE(GenJnlLine.Amount, (-1) * Rec."Amount To Retire");
                    GenJnlLine."Reason Code" := 'RETIRE';
                    GenJnlLine."System-Created Entry" := TRUE;
                    GenJnlLine.VALIDATE("Shortcut Dimension 1 Code", IOURec."Global Dimension 1 Code");
                    GenJnlLine.VALIDATE("Shortcut Dimension 2 Code", IOURec."Global Dimension 2 Code");
                    GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
                    GenJnlLine."Gen. Bus. Posting Group" := '';
                    GenJnlLine."Gen. Prod. Posting Group" := '';
                    GenJnlLine."VAT Bus. Posting Group" := '';
                    GenJnlLine."VAT Prod. Posting Group" := '';
                    GenJnlLine."Applies-to Doc. Type" := Rec."Applies-to Doc. Type";
                    GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. No.", Rec."Applies-to Doc. No.");
                    IF GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset" THEN BEGIN
                        GenJnlLine."Depreciation Book Code" := '';
                        GenJnlLine."FA Posting Type" := GenJnlLine."FA Posting Type"::" ";
                        GenJnlLine."Maintenance Code" := '';
                    END ELSE BEGIN
                        GenJnlLine.VALIDATE("FA Posting Type", RetLines."FA Posting Type");
                        GenJnlLine.VALIDATE("Maintenance Code", RetLines."Maintenance Code");
                    END;
                    GenJnlLine.INSERT;
                    GenJnlPost.RUN(GenJnlLine);
                END;

            1:
                BEGIN //partial retirement
                    IOURec.GET(Rec."IOU No.");
                    IOURec.CALCFIELDS(IOURec."Amount Retired");
                    Rec.CALCFIELDS(Rec."Amount To Retire");
                    RemAmt := IOURec.Amount - (IOURec."Amount Retired" + Rec."Amount To Retire");
                    IF RemAmt < 0 THEN
                        ERROR('Retirement amount cannot be greater than IOU amount for partial retirement!');

                    IF RemAmt = 0 THEN
                        ERROR('Change retirement option to full retirement!');

                    //create journal
                    RetLines.SETFILTER(RetLines."Retirement No.", Rec."No.");
                    RetLines.FINDSET;
                    REPEAT
                        GenJnlLine."Journal Template Name" := 'GENERAL';
                        GenJnlLine."Journal Batch Name" := 'RETIRE';
                        GenJnlLine."Line No." := LineNo;
                        GenJnlLine."Posting Date" := Rec."Entry Date";
                        GenJnlLine."Account Type" := RetLines."Account Type";
                        GenJnlLine.VALIDATE(GenJnlLine."Account No.", RetLines."Account No.");
                        GenJnlLine."Document No." := Rec."No.";
                        GenJnlLine.Description := RetLines.Description;
                        GenJnlLine.VALIDATE("Shortcut Dimension 1 Code", RetLines."Shortcut Dimension 1 Code");
                        GenJnlLine.VALIDATE("Shortcut Dimension 2 Code", RetLines."Shortcut Dimension 2 Code");
                        GenJnlLine.VALIDATE(GenJnlLine.Amount, RetLines.Amount);
                        GenJnlLine."Reason Code" := 'RETIRE';
                        GenJnlLine."System-Created Entry" := TRUE;
                        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
                        GenJnlLine."Gen. Bus. Posting Group" := '';
                        GenJnlLine."Gen. Prod. Posting Group" := '';
                        GenJnlLine."VAT Bus. Posting Group" := '';
                        GenJnlLine."VAT Prod. Posting Group" := '';
                        IF GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset" THEN BEGIN
                            GenJnlLine."Depreciation Book Code" := '';
                            GenJnlLine."FA Posting Type" := GenJnlLine."FA Posting Type"::" ";
                            GenJnlLine."Maintenance Code" := '';
                        END ELSE BEGIN
                            GenJnlLine.VALIDATE("FA Posting Type", RetLines."FA Posting Type");
                            GenJnlLine.VALIDATE("Maintenance Code", RetLines."Maintenance Code");
                        END;
                        GenJnlLine.INSERT;
                        LineNo := LineNo + 10000;
                    UNTIL RetLines.NEXT = 0;
                    //insert bal acc
                    GenJnlLine."Journal Template Name" := 'GENERAL';
                    GenJnlLine."Journal Batch Name" := 'RETIRE';
                    GenJnlLine."Line No." := LineNo;
                    GenJnlLine."Posting Date" := Rec."Entry Date";
                    GenJnlLine."Account Type" := IOURec."Account Type";
                    GenJnlLine.VALIDATE(GenJnlLine."Account No.", IOURec."Account No.");
                    GenJnlLine."Document No." := Rec."No.";
                    GenJnlLine.Description := 'IOU Retirement' + ' ' + 'of' + ' ' + Rec."IOU No.";
                    GenJnlLine.VALIDATE("Shortcut Dimension 1 Code", IOURec."Global Dimension 1 Code");
                    GenJnlLine.VALIDATE("Shortcut Dimension 2 Code", IOURec."Global Dimension 2 Code");
                    GenJnlLine.VALIDATE(GenJnlLine.Amount, (-1) * Rec."Amount To Retire");
                    GenJnlLine."Reason Code" := 'RETIRE';
                    GenJnlLine."System-Created Entry" := TRUE;
                    GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
                    GenJnlLine."Gen. Bus. Posting Group" := '';
                    GenJnlLine."Gen. Prod. Posting Group" := '';
                    GenJnlLine."VAT Bus. Posting Group" := '';
                    GenJnlLine."VAT Prod. Posting Group" := '';
                    GenJnlLine."Applies-to Doc. Type" := Rec."Applies-to Doc. Type";
                    GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. No.", Rec."Applies-to Doc. No.");
                    IF GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset" THEN BEGIN
                        GenJnlLine."Depreciation Book Code" := '';
                        GenJnlLine."FA Posting Type" := GenJnlLine."FA Posting Type"::" ";
                        GenJnlLine."Maintenance Code" := '';
                    END ELSE BEGIN
                        GenJnlLine.VALIDATE("FA Posting Type", RetLines."FA Posting Type");
                        GenJnlLine.VALIDATE("Maintenance Code", RetLines."Maintenance Code");
                    END;
                    GenJnlLine.INSERT;
                    GenJnlPost.RUN(GenJnlLine);
                END;
        END;

        MESSAGE('Retirement Successfully posted!');

        GLEntry.SETCURRENTKEY("Document No.", "Posting Date");
        GLEntry.SETRANGE("Document No.", Rec."No.");
        IF GLEntry.FINDFIRST THEN BEGIN
            Rec.Posted := TRUE;
            Rec.MODIFY;
            RetLines2.SETFILTER(RetLines2."Retirement No.", Rec."No.");
            RetLines2.FINDSET;
            RetLines2.MODIFYALL(RetLines2.Posted, TRUE);
            IOURec.Retired := TRUE;
            IOURec.MODIFY;
        END;

        /*
        IF NOT GenJnlBatch.GET('GENERAL','RETIRE') THEN
        BEGIN
          GenJnlBatch.INIT;
          GenJnlBatch."Journal Template Name" := 'GENERAL';
          GenJnlBatch.Name := 'RETIRE';
          GenJnlBatch.Description := 'IOU Retirement';
          GenJnlBatch.INSERT;
        END ELSE BEGIN
          GenJnlBatch.Description := 'IOU Retirement';
          GenJnlBatch.MODIFY;
        END;
        
        //clear journal lines
        GenJnlLine2.SETRANGE("Journal Template Name",'GENERAL');
        GenJnlLine2.SETRANGE("Journal Batch Name",'RETIRE');
        IF GenJnlLine2.FINDSET THEN
          GenJnlLine2.DELETEALL;
        
        RemAmt := 0;
        Claim := 0;
        Refund := 0;
        LineNo := 10000;
        
        
         //.....Dada: The option is removed from the form as requested by Audit.
            IOURec.GET(Rec."IOU No.");
            IOURec.CALCFIELDS(IOURec."Amount Retired");
            Rec.CALCFIELDS(Rec."Amount To Retire");
            RemAmt := IOURec.Amount - (IOURec."Amount Retired" + Rec."Amount To Retire");
            IF (RemAmt = 0) OR (RemAmt < 0) THEN
              Rec."Retirement Options" := Rec."Retirement Options"::"Full Retirement"
            ELSE
              Rec."Retirement Options" := Rec."Retirement Options"::"Partial Retirement";
        
          //.....Dada
        
        
        CASE Rec."Retirement Options" OF
          0: BEGIN  //full retirement
            IOURec.GET(Rec."IOU No.");
            IOURec.CALCFIELDS(IOURec."Amount Retired");
            Rec.CALCFIELDS(Rec."Amount To Retire");
            RemAmt := IOURec.Amount - (IOURec."Amount Retired" + Rec."Amount To Retire");
            IF RemAmt < 0 THEN
              Claim := ABS(RemAmt)
            ELSE IF RemAmt > 0 THEN
              Refund := ABS(RemAmt)
            ELSE BEGIN
              Claim := 0;
              Refund := 0;
            END;
            //create journal
            RetLines.SETFILTER(RetLines."Retirement No.",Rec."No.");
            RetLines.FINDSET;
            REPEAT
              GenJnlLine."Journal Template Name" := 'GENERAL';
              GenJnlLine."Journal Batch Name" := 'RETIRE';
              GenJnlLine."Line No." := LineNo;
              GenJnlLine."Posting Date" := Rec."Entry Date";
              GenJnlLine."Account Type" := RetLines."Account Type";
              GenJnlLine.VALIDATE(GenJnlLine."Account No.",RetLines."Account No.");
              GenJnlLine."Document No." := Rec."No.";
              GenJnlLine.Description := RetLines.Description;
              GenJnlLine.VALIDATE(GenJnlLine."Shortcut Dimension 1 Code",RetLines."Shortcut Dimension 1 Code");
              GenJnlLine.VALIDATE(GenJnlLine."Shortcut Dimension 2 Code",RetLines."Shortcut Dimension 2 Code");
              GenJnlLine.VALIDATE(GenJnlLine.Amount,RetLines.Amount);
              GenJnlLine."Reason Code" := 'RETIRE';
              GenJnlLine."System-Created Entry" := TRUE;
              GenJnlLine."Gen. Posting Type" := 0;
              GenJnlLine."Gen. Bus. Posting Group" := '';
              GenJnlLine."Gen. Prod. Posting Group" := '';
              GenJnlLine."VAT Bus. Posting Group" := '';
              GenJnlLine."VAT Prod. Posting Group" := '';
              IF GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset" THEN BEGIN
              GenJnlLine."Depreciation Book Code" := '';
              GenJnlLine."FA Posting Type" := 0;
              GenJnlLine."Maintenance Code" := '';
              END ELSE
              BEGIN
              GenJnlLine.VALIDATE("FA Posting Type",RetLines."FA Posting Type");
              GenJnlLine.VALIDATE("Maintenance Code",RetLines."Maintenance Code");
              END;
              GenJnlLine.INSERT;
              LineNo := LineNo + 10000;
            UNTIL RetLines.NEXT = 0;
            //insert bal acc
            GenJnlLine."Journal Template Name" := 'GENERAL';
            GenJnlLine."Journal Batch Name" := 'RETIRE';
            GenJnlLine."Line No." := LineNo;
            GenJnlLine."Posting Date" := Rec."Entry Date";
            GenJnlLine."Account Type" := IOURec."Account Type";
            GenJnlLine.VALIDATE(GenJnlLine."Account No.",IOURec."Account No.");
            GenJnlLine."Document No." := Rec."No.";
            GenJnlLine.Description := 'IOU Retirement' + ' ' + 'of' + ' ' + Rec."IOU No.";
            GenJnlLine.VALIDATE(GenJnlLine.Amount,(-1) * Rec."Amount To Retire");
            GenJnlLine."Reason Code" := 'RETIRE';
            GenJnlLine."System-Created Entry" := TRUE;
            GenJnlLine.VALIDATE("Shortcut Dimension 1 Code",IOURec."Global Dimension 1 Code");
            GenJnlLine.VALIDATE("Shortcut Dimension 2 Code",IOURec."Global Dimension 2 Code");
            GenJnlLine."Gen. Posting Type" := 0;
            GenJnlLine."Gen. Bus. Posting Group" := '';
            GenJnlLine."Gen. Prod. Posting Group" := '';
            GenJnlLine."VAT Bus. Posting Group" := '';
            GenJnlLine."VAT Prod. Posting Group" := '';
            GenJnlLine."Applies-to Doc. Type" := Rec."Applies-to Doc. Type";
            GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. No.",Rec."Applies-to Doc. No.");
            IF GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset" THEN BEGIN
            GenJnlLine."Depreciation Book Code" := '';
            GenJnlLine."FA Posting Type" := 0;
            GenJnlLine."Maintenance Code" := '';
            END ELSE
            BEGIN
              GenJnlLine.VALIDATE("FA Posting Type",RetLines."FA Posting Type");
              GenJnlLine.VALIDATE("Maintenance Code",RetLines."Maintenance Code");
            END;
            GenJnlLine.INSERT;
            GenJnlPost.RUN(GenJnlLine);
            //in case of refund create cash receipt
            {IF Refund <>  0 THEN BEGIN
              PayRecpt."Document Type" := PayRecpt."Document Type"::Receipt;
              PayRecpt."Cash/Cheque" := PayRecpt."Cash/Cheque"::Cash;
              PayRecpt."Account Type" := IOURec."Account Type";
              PayRecpt.VALIDATE(PayRecpt."Account No.",IOURec."Account No.");
              PayRecpt."Transaction Description" := 'Refund on IOU ' + IOURec."IOU No.";
              PayRecpt.VALIDATE("Global Dimension 1 Code",IOURec."Global Dimension 1 Code");
              PayRecpt.VALIDATE("Global Dimension 2 Code",IOURec."Global Dimension 2 Code");
              PayRecpt."Posting Date" := TODAY;
              PayRecpt.VALIDATE(PayRecpt."Credit Amount",Refund);
              PayRecpt.INSERT(TRUE);
            END;
            //in case of claim create cash requisition
            IF Claim <> 0 THEN BEGIN
              PayRecpt."Document Type" := PayRecpt."Document Type"::Requisition;
              PayRecpt."Cash/Cheque" := PayRecpt."Cash/Cheque"::Cash;
              PayRecpt."Account Type" := IOURec."Account Type";
              PayRecpt.VALIDATE(PayRecpt."Account No.",IOURec."Account No.");
              PayRecpt."Transaction Description" := 'Claim on IOU ' + IOURec."IOU No.";
              PayRecpt.VALIDATE("Global Dimension 1 Code",IOURec."Global Dimension 1 Code");
              PayRecpt.VALIDATE("Global Dimension 2 Code",IOURec."Global Dimension 2 Code");
              PayRecpt."Posting Date" := TODAY;
              PayRecpt.VALIDATE(PayRecpt."Debit Amount",Claim);
              PayRecpt.INSERT(TRUE);
            END;} //suspended
        
            Rec.Posted := TRUE;
            Rec.MODIFY;
            RetLines2.SETFILTER(RetLines2."Retirement No.",Rec."No.");
            RetLines2.FINDSET;
            RetLines2.MODIFYALL(RetLines2.Posted,TRUE);
            IOURec.Retired := TRUE;
            IOURec.MODIFY;
          END;
          1: BEGIN //partial retirement
            IOURec.GET(Rec."IOU No.");
            IOURec.CALCFIELDS(IOURec."Amount Retired");
            Rec.CALCFIELDS(Rec."Amount To Retire");
            RemAmt := IOURec.Amount - (IOURec."Amount Retired" + Rec."Amount To Retire");
            IF RemAmt < 0 THEN
              ERROR('Retirement amount cannot be greater than IOU amount for partial retirement!');
        
            IF RemAmt = 0 THEN
              ERROR('Change retirement option to full retirement!');
        
            //create journal
            RetLines.SETFILTER(RetLines."Retirement No.",Rec."No.");
            RetLines.FINDSET;
            REPEAT
              GenJnlLine."Journal Template Name" := 'GENERAL';
              GenJnlLine."Journal Batch Name" := 'RETIRE';
              GenJnlLine."Line No." := LineNo;
              GenJnlLine."Posting Date" := Rec."Entry Date";
              GenJnlLine."Account Type" := RetLines."Account Type";
              GenJnlLine.VALIDATE(GenJnlLine."Account No.",RetLines."Account No.");
              GenJnlLine."Document No." := Rec."No.";
              GenJnlLine.Description := RetLines.Description;
              GenJnlLine.VALIDATE("Shortcut Dimension 1 Code",RetLines."Shortcut Dimension 1 Code");
              GenJnlLine.VALIDATE("Shortcut Dimension 2 Code",RetLines."Shortcut Dimension 2 Code");
              GenJnlLine.VALIDATE(GenJnlLine.Amount,RetLines.Amount);
              GenJnlLine."Reason Code" := 'RETIRE';
              GenJnlLine."System-Created Entry" := TRUE;
              GenJnlLine."Gen. Posting Type" := 0;
              GenJnlLine."Gen. Bus. Posting Group" := '';
              GenJnlLine."Gen. Prod. Posting Group" := '';
              GenJnlLine."VAT Bus. Posting Group" := '';
              GenJnlLine."VAT Prod. Posting Group" := '';
              IF GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset" THEN BEGIN
              GenJnlLine."Depreciation Book Code" := '';
              GenJnlLine."FA Posting Type" := 0;
              GenJnlLine."Maintenance Code" := '';
              END ELSE
              BEGIN
              GenJnlLine.VALIDATE("FA Posting Type",RetLines."FA Posting Type");
              GenJnlLine.VALIDATE("Maintenance Code",RetLines."Maintenance Code");
              END;
              GenJnlLine.INSERT;
              LineNo := LineNo + 10000;
            UNTIL RetLines.NEXT = 0;
            //insert bal acc
            GenJnlLine."Journal Template Name" := 'GENERAL';
            GenJnlLine."Journal Batch Name" := 'RETIRE';
            GenJnlLine."Line No." := LineNo;
            GenJnlLine."Posting Date" := Rec."Entry Date";
            GenJnlLine."Account Type" := IOURec."Account Type";
            GenJnlLine.VALIDATE(GenJnlLine."Account No.",IOURec."Account No.");
            GenJnlLine."Document No." := Rec."No.";
            GenJnlLine.Description := 'IOU Retirement' + ' ' + 'of' + ' ' + Rec."IOU No.";
            GenJnlLine.VALIDATE("Shortcut Dimension 1 Code",IOURec."Global Dimension 1 Code");
            GenJnlLine.VALIDATE("Shortcut Dimension 2 Code",IOURec."Global Dimension 2 Code");
            GenJnlLine.VALIDATE(GenJnlLine.Amount,(-1) * Rec."Amount To Retire");
            GenJnlLine."Reason Code" := 'RETIRE';
            GenJnlLine."System-Created Entry" := TRUE;
            GenJnlLine."Gen. Posting Type" := 0;
            GenJnlLine."Gen. Bus. Posting Group" := '';
            GenJnlLine."Gen. Prod. Posting Group" := '';
            GenJnlLine."VAT Bus. Posting Group" := '';
            GenJnlLine."VAT Prod. Posting Group" := '';
            GenJnlLine."Applies-to Doc. Type" := Rec."Applies-to Doc. Type";
            GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. No.",Rec."Applies-to Doc. No.");
            IF GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset" THEN BEGIN
            GenJnlLine."Depreciation Book Code" := '';
            GenJnlLine."FA Posting Type" := 0;
            GenJnlLine."Maintenance Code" := '';
            END ELSE
            BEGIN
              GenJnlLine.VALIDATE("FA Posting Type",RetLines."FA Posting Type");
              GenJnlLine.VALIDATE("Maintenance Code",RetLines."Maintenance Code");
            END;
            GenJnlLine.INSERT;
            GenJnlPost.RUN(GenJnlLine);
        
            Rec.Posted := TRUE;
            Rec.MODIFY;
            RetLines2.SETFILTER(RetLines2."Retirement No.",Rec."No.");
            RetLines2.FINDSET;
            RetLines2.MODIFYALL(RetLines2.Posted,TRUE);
            IOURec.Retired := TRUE;
            IOURec.MODIFY;
        
          END;
        END;
        
        MESSAGE('Retirement Successfully posted');
        */

    end;


    procedure PostDeposit(var Rec: Record "Deposit Management")
    begin
        IF NOT CONFIRM('Do you want to post Deposit!') THEN EXIT;

        GenJnlLine2.SETRANGE("Journal Template Name", 'GENERAL');
        GenJnlLine2.SETRANGE("Journal Batch Name", 'DEPOSIT');
        IF GenJnlLine2.FINDSET THEN
            GenJnlLine2.DELETEALL;

        GenJnlLine."Journal Template Name" := 'GENERAL';
        GenJnlLine."Journal Batch Name" := 'DEPOSIT';
        GenJnlLine."Line No." := 10000;
        GenJnlLine."Posting Date" := Rec."Transaction Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Document No." := Rec."Deposit No.";
        GenJnlLine."External Document No." := Rec."Cheque No.";
        IF Rec.Type = Rec.Type::Customer THEN
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer
        ELSE
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
        GenJnlLine.VALIDATE("Account No.", Rec."No.");
        GenJnlLine.VALIDATE("VAT %", 0);
        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
        GenJnlLine."Gen. Bus. Posting Group" := '';
        GenJnlLine."Gen. Prod. Posting Group" := '';
        GenJnlLine."VAT Bus. Posting Group" := '';
        GenJnlLine."VAT Prod. Posting Group" := '';
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine.VALIDATE("Bal. Account No.", Rec."Bal. Account No.");
        GenJnlLine.VALIDATE(Amount, -1 * Rec."Amount Deposited");
        GenJnlLine.Description := Rec.Description;
        GenJnlLine."Shortcut Dimension 1 Code" := Rec."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := Rec."Global Dimension 2 Code";
        GenJnlLine."System-Created Entry" := TRUE;
        GenJnlLine."Bal. Gen. Posting Type" := GenJnlLine."Bal. Gen. Posting Type"::" ";
        GenJnlLine."Bal. Gen. Bus. Posting Group" := '';
        GenJnlLine."Bal. Gen. Prod. Posting Group" := '';
        GenJnlLine."Bal. VAT Bus. Posting Group" := '';
        GenJnlLine."Bal. VAT Prod. Posting Group" := '';
        GenJnlLine.INSERT;

        GenJnlPost.RUN(GenJnlLine);

        Rec.Posted := TRUE;
        Rec.MODIFY;
    end;


    procedure ConvertIOU2Loan(var IOURec: Record 50105)
    var
        Loan: Record 50013;
        LoanType: Record 50019;
        PaySetup: Record 50018;
    begin
        IF NOT CONFIRM('Do you want to convert to Loan?') THEN EXIT;

        Customer.SETRANGE(Customer."No.", IOURec."Account No.");
        Customer.SETRANGE(Customer.Type, Customer.Type::Staff);
        IF NOT Customer.FINDFIRST THEN
            ERROR('Only Staff can be granted loans!');

        PaySetup.GET;

        Loan.INIT;
        Loan.VALIDATE("Staff No.", IOURec."Account No.");
        Loan."Loan Type" := 'PERSONAL';
        Loan.Description := 'Personal Loan';
        IOURec.CALCFIELDS(IOURec."Amount Retired");
        Loan.VALIDATE("Loan Amount", IOURec.Amount - IOURec."Amount Retired");
        LoanType.GET('PERSONAL');
        Loan.VALIDATE("Number of Payments", LoanType."Default Number of Payments");
        Loan.VALIDATE("Loan ED Regular", LoanType."Loan ED");
        Loan."Start Period" := PaySetup."Open Payroll Period";
        Loan."Loan Posting Date" := WORKDATE;
        Loan."Open(Y/N)" := TRUE;
        Loan."Created from IOU" := TRUE;
        Loan."IOU No." := IOURec."IOU No.";
        Loan.INSERT(TRUE);

        IOURec."Converted to Loan" := TRUE;
        IOURec.MODIFY;

        MESSAGE('Loan successfully created!');
    end;


    procedure LookupItemLedgerList(SalesLine: Record "Sales Line")

    var
        SalesInfoMgtPanel: Codeunit "Sales Info-Pane Management";
        ItemLedgEntry: Record "Item Ledger Entry";

    Begin
        SalesLine.TESTFIELD(Type, SalesLine.Type::Item);
        SalesLine.TESTFIELD("No.");
        SalesInfoMgtPanel.GetItem(SalesLine);
        ItemLedgEntry.SETRANGE("Item No.", SalesLine."No.");
        PAGE.RUNMODAL(PAGE::"FIFO Lists", ItemLedgEntry)

    End;



    procedure AccessGranted(FieldNo: Code[10]): Boolean
    var
        HasPermission: Boolean;
    begin
        // This program is used to check whether the user has right to some restricted areas within
        // the system.

        // Error message if not allowed

        IF USERID = '' THEN EXIT;
        HasPermission := FALSE;
        /*
        UserGroup.SETRANGE(UserGroup."User ID",USERID);
        UserGroup.SETFILTER(UserGroup."Role ID",'%1','SUPER');
        IF UserGroup.FIND('-') THEN EXIT;
        
        IF (UserPerm.GET(USERID)) AND (USERID <> '') THEN
          CASE FieldNo OF
            '5' : HasPermission := UserPerm."Modify Credit Limit";
            '6' : HasPermission := UserPerm."Post IOU Retirement";
            '7' : HasPermission := UserPerm."Accept Credit Limit Msg";
            '9' : HasPermission := UserPerm."Approve Cash Requisition";
            '12' : HasPermission := UserPerm."General Ledger Setup";
            '13' : HasPermission := UserPerm."HOD Approval";
            '14' : HasPermission := UserPerm."Controller Approval";
            '17' : HasPermission := UserPerm."Post Deposit";
            '18' : HasPermission := UserPerm."Convert IOU to Loan";
            '19' : HasPermission := UserPerm."Make Loss Sales";
            '20' : HasPermission := UserPerm."Register Items";
            '21' : HasPermission := UserPerm."Approve Store Requisition";
            '22' : HasPermission := UserPerm."Cancel Sales Order";
            '23' : HasPermission := UserPerm."Purchase Approval";
            '24' : HasPermission := UserPerm."Change Purch. Unit Cost";
            '25' : HasPermission := UserPerm."View User Setup Form";
            '27' : HasPermission := UserPerm.LPO;
            '28' : HasPermission := UserPerm."Approved LPO";
            '29' : HasPermission := UserPerm.FPO;
            '30' : HasPermission := UserPerm."Approved FPO";
            '31' : HasPermission := UserPerm."Make Purchase Order";
            '32' : HasPermission := UserPerm."Change Sales Price";
            '33' : HasPermission := UserPerm."Post JV";
            '34' : HasPermission := UserPerm."Post Cash Receipt";
            '35' : HasPermission := UserPerm."Post Cheque Receipt";
            '36' : HasPermission := UserPerm."Post Store Issues";
            '37' : HasPermission := UserPerm."Post Cash Requisition";
            '38' : HasPermission := UserPerm."Post Cheque Requisition";
            '39' : HasPermission := UserPerm."Post IOU";
            '40' : HasPermission := UserPerm."Post Sales Credit Memo";
            '41' : HasPermission := UserPerm."Post Purch. Credit Memo";
            '42' : HasPermission := UserPerm."View Customer Card";
            '43' : HasPermission := UserPerm."View Vendor Card";
            '44' : HasPermission := UserPerm."View G/L Account Card";
            '45' : HasPermission := UserPerm."View Item Card";
            '46' : HasPermission := UserPerm."View Bank Account Card";
            '47' : HasPermission := UserPerm."Modify Customer Card";
            '48' : HasPermission := UserPerm."Modify Vendor Card";
            '49' : HasPermission := UserPerm."Modify Item Card";
            '50' : HasPermission := UserPerm."Modify Posting Groups";
            '51' : HasPermission := UserPerm."Modify Posting Setup";
            '52' : HasPermission := UserPerm."Sales Setup";
            '53' : HasPermission := UserPerm."Purchase Setup";
            '54' : HasPermission := UserPerm."Inventory Setup";
            '56' : HasPermission := UserPerm."Cancel IOU";
            '57' : HasPermission := UserPerm."IOU Accounts Approval";
            '58' : HasPermission := UserPerm."IOU Audit Approval";
          END;
          */
        IF HasPermission THEN
            EXIT(TRUE);

        ERROR('You do not have rights to perform this operation\\' +
              'Contact the system manager if you need to have your permissions changed!');

    end;


    procedure figure(fig: Decimal; Currency: Text[30]; CurrencyUnit: Text[30]) figureinword: Text[200]
    begin
        IF ABS(fig) > 0 THEN BEGIN
            wordarray[1] := 'ONE';
            wordarray[2] := 'TWO';
            wordarray[3] := 'THREE';
            wordarray[4] := 'FOUR';
            wordarray[5] := 'FIVE';
            wordarray[6] := 'SIX';
            wordarray[7] := 'SEVEN';
            wordarray[8] := 'EIGHT';
            wordarray[9] := 'NINE';
            wordarray[10] := 'TEN';
            wordarray[11] := 'ELEVEN';
            wordarray[12] := 'TWELVE';
            wordarray[13] := 'THIRTEEN';
            wordarray[14] := 'FOURTEEN';
            wordarray[15] := 'FIFTEEN';
            wordarray[16] := 'SIXTEEN';
            wordarray[17] := 'SEVENTEEN';
            wordarray[18] := 'EIGHTEEN';
            wordarray[19] := 'NINETEEN';
            wordarray[20] := 'TWENTY';
            arrayval[1] := 'TEN';
            arrayval[2] := 'TWENTY';
            arrayval[3] := 'THIRTY';
            arrayval[4] := 'FORTY';
            arrayval[5] := 'FIFTY';
            arrayval[6] := 'SIXTY';
            arrayval[7] := 'SEVENTY';
            arrayval[8] := 'EIGHTY';
            arrayval[9] := 'NINETY';
            arrayval[10] := 'HUNDRED';
            arrayval[11] := 'THOUSAND';
            arrayval[12] := 'MILLION';
            arrayval[13] := 'BILLION';
            arrayval[14] := 'TRILLION';
            valueword4 := FORMAT(ABS(ROUND(fig, 0.01, '>')));
            valueword4 := DELCHR(valueword4, '=', ',');
            value4 := STRPOS(valueword4, '.');
            IF value4 > 0 THEN BEGIN
                VALLENT := value4 - 1;
                deci := COPYSTR(valueword4, (STRPOS(valueword4, '.') + 1));
                IF STRLEN(deci) < 2 THEN deci := deci + '0'
            END
            ELSE
                VALLENT := STRLEN(valueword4);
            IF VALLENT > 15 THEN
                ERROR('VALUE IS TOO BIG TO CONVERT');
            value5 := VALLENT MOD 3;
            IF value5 > 0 THEN BEGIN                                             // unit and tens conversion begin
                valueword1 := COPYSTR(valueword4, 1, value5);
                EVALUATE(value3, valueword1);
                IF (value3 > 0) AND (value3 <= 20) THEN
                    word1 := wordarray[value3]
                ELSE BEGIN
                    valueword2 := COPYSTR(valueword1, 1, 1);
                    valueword3 := COPYSTR(valueword1, 2, 1);
                    EVALUATE(value3, valueword2);
                    word1 := arrayval[value3];
                    EVALUATE(value3, valueword3);
                    IF value3 > 0 THEN
                        word1 := word1 + ' ' + wordarray[value3];
                END;
                IF (VALLENT > 3) AND (VALLENT < 7) THEN
                    word1 := word1 + ' ' + arrayval[11];
                IF (VALLENT > 6) AND (VALLENT < 10) THEN
                    word1 := word1 + ' ' + arrayval[12];
                IF (VALLENT > 9) AND (VALLENT < 13) THEN
                    word1 := word1 + ' ' + arrayval[13];
                IF (VALLENT > 12) AND (VALLENT < 16) THEN
                    word1 := word1 + ' ' + arrayval[14];
            END;

            // Figure normal conversion begin by Hassan Sharafadeen
            IF VALLENT > 2 THEN BEGIN
                a := value5 + 1;
                REPEAT
                    valueword2 := COPYSTR(valueword4, a, 3);
                    EVALUATE(value4, valueword2);
                    IF value4 = 0 THEN BEGIN
                        word2 := '';
                        IF (VALLENT > 6) AND (VALLENT < 10) THEN
                            word2 := word2 + ' ' + arrayval[11];
                        IF (VALLENT > 9) AND (VALLENT < 13) THEN
                            word2 := word2 + ' ' + arrayval[12];
                        IF (VALLENT > 12) AND (VALLENT < 16) THEN
                            word2 := word2 + ' ' + arrayval[13];
                        a := a + 3;
                    END
                    ELSE BEGIN
                        valueword1 := COPYSTR(valueword2, 1, 1);
                        EVALUATE(value3, valueword1);
                        IF value3 > 0 THEN BEGIN
                            word2 := wordarray[value3];
                            word2 := word2 + ' ' + arrayval[10];
                        END
                        ELSE
                            word2 := '';
                        valueword1 := COPYSTR(valueword2, 2);
                        EVALUATE(value3, valueword1);
                        IF value3 > 0 THEN BEGIN
                            IF (value3 > 0) AND (value3 <= 20) THEN
                                IF word2 <> '' THEN
                                    word2 := word2 + ' ' + 'AND' + ' ' + wordarray[value3]
                                ELSE
                                    word2 := wordarray[value3]
                            ELSE
                                IF value3 > 20 THEN BEGIN
                                    valueword2 := COPYSTR(valueword1, 1, 1);
                                    valueword3 := COPYSTR(valueword1, 2, 1);
                                    EVALUATE(value3, valueword2);
                                    IF word2 <> '' THEN
                                        word2 := word2 + ' ' + 'AND' + ' ' + arrayval[value3]
                                    ELSE
                                        word2 := arrayval[value3];
                                    EVALUATE(value3, valueword3);
                                    IF value3 > 0 THEN
                                        word2 := word2 + ' ' + wordarray[value3];
                                END;
                        END;
                        a := a + 3;
                        IF a < VALLENT THEN BEGIN
                            IF i > 0 THEN BEGIN
                                CASE i OF
                                    3:
                                        BEGIN
                                            IF (VALLENT > 8) AND (VALLENT < 12) THEN
                                                word2 := word2 + ' ' + arrayval[11];
                                            IF (VALLENT > 11) AND (VALLENT < 15) THEN
                                                word2 := word2 + ' ' + arrayval[12];
                                            IF VALLENT = 15 THEN
                                                word2 := word2 + ' ' + arrayval[13];
                                        END;
                                    6:
                                        BEGIN
                                            IF (VALLENT > 11) AND (VALLENT < 15) THEN
                                                word2 := word2 + ' ' + arrayval[11];
                                            IF VALLENT = 15 THEN
                                                word2 := word2 + ' ' + arrayval[12];
                                        END;
                                    9:
                                        IF VALLENT = 15 THEN
                                            word2 := word2 + ' ' + arrayval[11];
                                END;
                            END
                            ELSE BEGIN
                                CASE a OF
                                    4:
                                        BEGIN
                                            IF VALLENT = 6 THEN
                                                word2 := word2 + ' ' + arrayval[11];
                                            IF VALLENT = 9 THEN
                                                word2 := word2 + ' ' + arrayval[12];
                                            IF VALLENT = 12 THEN
                                                word2 := word2 + ' ' + arrayval[13];
                                            IF VALLENT = 15 THEN
                                                word2 := word2 + ' ' + arrayval[14];
                                        END;
                                    5, 6:
                                        BEGIN
                                            IF (VALLENT > 6) AND (VALLENT < 9) THEN
                                                word2 := word2 + ' ' + arrayval[11];
                                            IF (VALLENT > 9) AND (VALLENT < 12) THEN
                                                word2 := word2 + ' ' + arrayval[12];
                                            IF (VALLENT > 12) AND (VALLENT < 15) THEN
                                                word2 := word2 + ' ' + arrayval[13];
                                        END;
                                END;
                            END;
                        END;
                        valueword5 := valueword5 + ' ' + word2;
                        i := i + 3;
                    END;
                UNTIL a > VALLENT;
            END;
            figureinword := word1 + ' ' + valueword5 + ' ' + Currency;
            IF deci <> '' THEN                 //Decimal conversion begin
            BEGIN
                EVALUATE(value3, deci);
                IF value3 <= 20 THEN
                    word3 := wordarray[value3]
                ELSE BEGIN
                    valueword2 := COPYSTR(deci, 1, 1);
                    valueword3 := COPYSTR(deci, 2, 1);
                    EVALUATE(value3, valueword2);
                    word3 := arrayval[value3];
                    EVALUATE(value3, valueword3);
                    IF value3 > 0 THEN
                        word3 := word3 + ' ' + wordarray[value3];
                END;
                word5 := word3 + ' ' + CurrencyUnit;           // Attach Decimal Unit of counting
            END
            ELSE
                word5 := ' ';
            figureinword := figureinword + ' ' + word5;
        END
        ELSE
            figureinword := '';
    end;


    procedure CheckItemCost(var ItemNo: Code[20]; var NewSalesPrice: Decimal)
    begin
        UserSetup.GET(USERID);
        if not UserSetup."Change Price Below Cost" then begin
            ItemLedgEntry.SETCURRENTKEY("Item No.", Positive, "Location Code", "Variant Code");
            ItemLedgEntry.SETRANGE("Item No.", ItemNo);
            ItemLedgEntry.SETRANGE(Positive, TRUE);
            ItemLedgEntry.SETFILTER("Location Code", '<>%1', '');
            ItemLedgEntry.SETRANGE("Remaining Quantity", 1);
            ItemLedgEntry.SETRANGE("Variant Code", '');
            IF ItemLedgEntry.FINDFIRST THEN BEGIN
                REPEAT
                    ItemLedgEntryNo := ItemLedgEntry."Entry No.";
                    ValueEntry.SETCURRENTKEY("Item Ledger Entry No.", "Item No.");
                    ValueEntry.SETRANGE("Item Ledger Entry No.", ItemLedgEntry."Entry No.");
                    ValueEntry.SETRANGE("Item No.", ItemLedgEntry."Item No.");
                    IF ValueEntry.FINDFIRST THEN BEGIN
                        ValueEntry.CALCSUMS("Cost Posted to G/L");
                        IF NewSalesPrice < Abs(ValueEntry."Cost Posted to G/L") THEN
                            ERROR('Selling Price is lower than the Cost Amount!');
                    END;
                UNTIL ItemLedgEntry.NEXT = 0;
            END;
        end;
    end;


    procedure CheckItemCostToPost(var DocNo: Code[10])
    begin

        UserSetup.GET(USERID);
        if not UserSetup."Change Price Below Cost" then begin
            ReservEntry.SETCURRENTKEY("Source ID", "Item No.");
            ReservEntry.SETRANGE("Source ID", DocNo);
            IF ReservEntry.FINDFIRST THEN BEGIN
                REPEAT
                    SerialNo := ReservEntry."Serial No.";
                    ItemNo := ReservEntry."Item No.";
                    ItemLedgEntry.SETCURRENTKEY("Serial No.");
                    ItemLedgEntry.SETRANGE("Serial No.", SerialNo);
                    IF ItemLedgEntry.FINDFIRST THEN
                        ItemLedgEntry.CALCFIELDS("Cost Amount (Actual)");

                    SalesLine.SETCURRENTKEY("Document No.", "No.");
                    SalesLine.SETRANGE("Document No.", DocNo);
                    SalesLine.SETRANGE("No.", ItemNo);
                    IF SalesLine.FINDFIRST THEN BEGIN
                        REPEAT
                            UnitPrice := SalesLine."Unit Price";
                            IF UnitPrice < Abs(ItemLedgEntry."Cost Amount (Actual)") THEN BEGIN
                                MESSAGE('%1,%2,%3', ItemLedgEntry."Item No.", ItemLedgEntry."Serial No.", Abs(ItemLedgEntry."Cost Amount (Actual)"));
                                ERROR('Selling Price is lower than the Cost Amount!')
                            END
                        UNTIL SalesLine.NEXT = 0;
                    END;
                UNTIL ReservEntry.NEXT = 0;
            END;
        end;
    end;


    procedure UseTodaysDate(var PostingDate: Date)
    begin
        UserSetup.GET(USERID);
        IF UserSetup.Today THEN
            IF PostingDate <> TODAY THEN
                ERROR('Please change the Posting Date to todays date!');
    end;


    procedure CheckMargin(var DocNo: Code[10])
    begin
        UserSetup.GET(USERID);
        if not UserSetup."Change Price Below Cost" then begin

            ReservEntry.SETCURRENTKEY("Source ID", "Item No.");
            ReservEntry.SETRANGE("Source ID", DocNo);
            IF ReservEntry.FINDFIRST THEN BEGIN
                REPEAT
                    SerialNo := ReservEntry."Serial No.";
                    ItemNo := ReservEntry."Item No.";
                    ItemLedgEntry.SETCURRENTKEY("Serial No.");
                    ItemLedgEntry.SETRANGE("Serial No.", SerialNo);
                    IF ItemLedgEntry.FINDFIRST THEN
                        ItemLedgEntry.CALCFIELDS("Cost Amount (Actual)");

                    SalesLine.SETCURRENTKEY("Document No.", "No.");
                    SalesLine.SETRANGE("Document No.", DocNo);
                    SalesLine.SETRANGE("No.", ItemNo);
                    IF SalesLine.FINDFIRST THEN BEGIN
                        REPEAT
                            UnitPrice := SalesLine."Unit Price";
                            Margin := ((UnitPrice - Abs(ItemLedgEntry."Cost Amount (Actual)")) / UnitPrice) * 100;
                            IF Margin < 5 THEN BEGIN
                                MESSAGE('%1,%2,%3', ItemLedgEntry."Item No.", ItemLedgEntry."Serial No.", ItemLedgEntry."Cost Amount (Actual)");
                                ERROR('The margin is too low for the vehicle!')
                            END
                        UNTIL SalesLine.NEXT = 0;
                    END;
                UNTIL ReservEntry.NEXT = 0;
            END;
        end;
    end;


    procedure ShowItemAvailFromSearchTracker(VAR SearchTracker: Record "Parts Enquiry"; AvailabilityType: Enum Microsoft.Inventory.Availability."Item Availability Type")
    var

        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        Item: Record item;
        NewDate: Date;
        NewVariantCode: Code[10];
        NewLocationCode: Code[10];

    begin

        SearchTracker.TESTFIELD(SearchTracker."Part No");
        Item.RESET;
        Item.GET(SearchTracker."Part No");
        ItemAvailFormsMgt.FilterItem(Item, SearchTracker."Location Code", SearchTracker.Variant, SearchTracker."Request Date");

        CASE AvailabilityType OF
            AvailabilityType::Period:
                IF ItemAvailFormsMgt.ShowItemAvailabilityByPeriod(Item, SearchTracker.FIELDCAPTION(SearchTracker."Request Date"), SearchTracker."Request Date", NewDate) THEN
                    SearchTracker.VALIDATE(SearchTracker."Request Date", NewDate);
            AvailabilityType::Variant:
                IF ItemAvailFormsMgt.ShowItemAvailabilityByVariant(Item, SearchTracker.FIELDCAPTION(SearchTracker.Variant), SearchTracker.Variant, NewVariantCode) THEN
                    SearchTracker.VALIDATE(SearchTracker.Variant, NewVariantCode);
            AvailabilityType::Location:
                IF ItemAvailFormsMgt.ShowItemAvailabilityByLocation(Item, SearchTracker.FIELDCAPTION(SearchTracker."Location Code"), SearchTracker."Location Code", NewLocationCode) THEN
                    SearchTracker.VALIDATE(SearchTracker."Location Code", NewLocationCode);
            AvailabilityType::"Event":
                IF ItemAvailFormsMgt.ShowItemAvailabilityByEvent(Item, SearchTracker.FIELDCAPTION(SearchTracker."Request Date"), SearchTracker."Request Date", NewDate, FALSE) THEN
                    SearchTracker.VALIDATE(SearchTracker."Request Date", NewDate);

        END;
    END;

    procedure ShowItemAvailFromFaultSetup(VAR FaultSetupLine: Record "Fault Setup Line"; AvailabilityType: Enum Microsoft.Inventory.Availability."Item Availability Type")

    var
        Item: Record Item;
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        NewDate: Date;
        NewVariantCode: Code[10];
        NewLocationCode: Code[10];

    Begin
        FaultSetupLine.TESTFIELD(FaultSetupLine.Type, FaultSetupLine.Type::Item);
        FaultSetupLine.TESTFIELD(FaultSetupLine."No.");
        Item.RESET;
        Item.GET(FaultSetupLine."No.");
        //ItemAvailFormsMgt.FilterItem(Item,Location,Variant,TODAY);
        CASE AvailabilityType OF
            AvailabilityType::Location:
                IF ItemAvailFormsMgt.ShowItemAvailabilityByLocation(Item, FaultSetupLine.FIELDCAPTION(FaultSetupLine.Location), FaultSetupLine.Location, NewLocationCode) THEN
                    FaultSetupLine.VALIDATE(FaultSetupLine.Location, NewLocationCode);
        END;
    End;



    procedure CalculateLeaveEndDateExcludingWeekendsAndHolidays(LeaveStartDate: Date; NumberOfLeaveDays: Integer): Date
    var
        RemainingDays: Integer;
        CurrentDate: Date;
        HolidayRecord: Record Holidays;
    begin
        RemainingDays := 0;
        RemainingDays := NumberOfLeaveDays;
        CurrentDate := LeaveStartDate - 1; // day before

        while RemainingDays > 0 do begin
            CurrentDate := CurrentDate + 1; // Move to the current day

            // Check if it's a weekend (Saturday = 6, Sunday = 7) or a public holiday
            HolidayRecord.Reset();
            HolidayRecord.SetRange(Date, CurrentDate);
            if not ((Date2DWY(CurrentDate, 1) in [6, 7]) or HolidayRecord.FindFirst()) then
                RemainingDays -= 1; // Count the working day
        end;

        exit(CurrentDate);
    end;

    procedure CalculateLeaveStartDateExcludingWeekendsAndHolidays(LeaveEndDate: Date; NumberOfLeaveDays: Integer): Date
    var
        RemainingDays: Integer;
        CurrentDate: Date;
        HolidayRecord: Record Holidays;
    begin
        RemainingDays := 0;
        RemainingDays := NumberOfLeaveDays;
        CurrentDate := LeaveEndDate + 1; // day before

        while RemainingDays > 0 do begin
            CurrentDate := CurrentDate - 1; // Move to the current day

            // Check if it's a weekend (Saturday = 6, Sunday = 7) or a public holiday
            HolidayRecord.Reset();
            HolidayRecord.SetRange(Date, CurrentDate);
            if not ((Date2DWY(CurrentDate, 1) in [6, 7]) or HolidayRecord.FindFirst()) then
                RemainingDays -= 1; // Count the working day
        end;

        exit(CurrentDate);
    end;

    procedure CalculateTotalLeaveDaysExcludingWeekends(LeaveStartDate: Date; LeaveEndDate: Date): Integer
    var
        TotalDays: Integer;
        CurrentDate: Date;
        HolidayRecord: Record Holidays;
    begin
        TotalDays := 0;
        CurrentDate := LeaveStartDate;

        while CurrentDate <= LeaveEndDate do begin

            HolidayRecord.Reset();
            HolidayRecord.SetRange(Date, CurrentDate);
            if not ((Date2DWY(CurrentDate, 1) in [6, 7]) or HolidayRecord.FindFirst()) then
                TotalDays += 1;
            CurrentDate := CurrentDate + 1;
        end;

        exit(TotalDays);
    end;



}

