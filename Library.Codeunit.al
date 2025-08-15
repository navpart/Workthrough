codeunit 50003 Library
{

    trigger OnRun()
    begin
    end;

    var
        "------------------------------": Text[30];
        Words: Text[250];
        Ands: Text[10];
        ZvAL: Decimal;
        SVal: Text[30];


    procedure "A-A-A-----------------"()
    begin
    end;


    procedure C1000_Infinity(Value: Decimal) retvalue: Text[250]
    var
        t: Decimal;
        tmp: Text[250];
        t3: Integer;
    begin
        BEGIN
            tmp := FORMAT(ROUND(Value, 1, '<'));
            t := ROUND(STRLEN(FORMAT(ROUND(Value, 1, '<'), 0, 1)) / 3, 1, '>');
            retvalue := '';

            REPEAT
                IF STRPOS(tmp, ',') <> 0 THEN BEGIN
                    EVALUATE(t3, COPYSTR(tmp, 1, STRPOS(tmp, ',') - 1));
                    ZvAL := t3;
                    tmp := COPYSTR(tmp, STRPOS(tmp, ',') + 1)
                END
                ELSE BEGIN
                    EVALUATE(t3, tmp);
                    //EVALUATE(ZvAL,COPYSTR(tmp,1,3));
                    tmp := '';
                END;
                t := t - 1;
                retvalue := retvalue + C0_999(t3);
                //AAA-Sta Feb 21 2002
                IF (t = 1) AND (ZvAL = 0)
                 THEN
                    SVal := ''
                ELSE
                    SVal := SELECTSTR(28 + t, Words);
                IF (t > 0) THEN retvalue := retvalue + ' ' + SVal + ' ';
            //AAA-Sto - Feb 21 2002
            //AAA IF(t>0)THEN retvalue := retvalue+' '+SELECTSTR(28+t,Words)+' ';
            UNTIL tmp = '';
            EXIT(retvalue);
        END;
    end;


    procedure C0_9(digit: Integer): Text[20]
    begin
        BEGIN
            CASE digit OF
                0:
                    EXIT('');
                1:
                    EXIT(SELECTSTR(1, Words));
                2:
                    EXIT(SELECTSTR(2, Words));
                3:
                    EXIT(SELECTSTR(3, Words));
                4:
                    EXIT(SELECTSTR(4, Words));
                5:
                    EXIT(SELECTSTR(5, Words));
                6:
                    EXIT(SELECTSTR(6, Words));
                7:
                    EXIT(SELECTSTR(7, Words));
                8:
                    EXIT(SELECTSTR(8, Words));
                9:
                    EXIT(SELECTSTR(9, Words));
            END;
        END;
    end;


    procedure C0_999(ThreeDigit: Integer): Text[100]
    var
        text1: Text[30];
        TwoDigit: Integer;
        Hundreds: Text[30];
    begin
        BEGIN
            TwoDigit := ThreeDigit MOD 100;
            Hundreds := C0_9(ROUND(ThreeDigit / 100, 1, '<'));
            IF (Hundreds <> '') THEN Hundreds := Hundreds + ' ' + SELECTSTR(28, Words);

            IF (TwoDigit > 0) AND (Hundreds <> '') THEN
                Hundreds := Hundreds + ' ' + Ands + ' ';

            IF (TwoDigit > 19) THEN BEGIN
                text1 := C0_9(TwoDigit MOD 10);
                IF text1 <> '' THEN text1 := ' ' + text1;
            END;

            CASE ROUND(TwoDigit / 10, 1, '<') OF
                0, 1:
                    BEGIN
                        CASE TwoDigit OF
                            0, 1, 2, 3, 4, 5, 6, 7, 8, 9:
                                EXIT(Hundreds + C0_9(TwoDigit));
                            10:
                                EXIT(Hundreds + SELECTSTR(10, Words));
                            11:
                                EXIT(Hundreds + SELECTSTR(11, Words));
                            12:
                                EXIT(Hundreds + SELECTSTR(12, Words));
                            13:
                                EXIT(Hundreds + SELECTSTR(13, Words));
                            14:
                                EXIT(Hundreds + SELECTSTR(14, Words));
                            15:
                                EXIT(Hundreds + SELECTSTR(15, Words));
                            16:
                                EXIT(Hundreds + SELECTSTR(16, Words));
                            17:
                                EXIT(Hundreds + SELECTSTR(17, Words));
                            18:
                                EXIT(Hundreds + SELECTSTR(18, Words));
                            19:
                                EXIT(Hundreds + SELECTSTR(19, Words));
                        END;
                    END;
                2:
                    EXIT(Hundreds + SELECTSTR(20, Words) + text1);
                3:
                    EXIT(Hundreds + SELECTSTR(21, Words) + text1);
                4:
                    EXIT(Hundreds + SELECTSTR(22, Words) + text1);
                5:
                    EXIT(Hundreds + SELECTSTR(23, Words) + text1);
                6:
                    EXIT(Hundreds + SELECTSTR(24, Words) + text1);
                7:
                    EXIT(Hundreds + SELECTSTR(25, Words) + text1);
                8:
                    EXIT(Hundreds + SELECTSTR(26, Words) + text1);
                9:
                    EXIT(Hundreds + SELECTSTR(27, Words) + text1);
            END;
        END;
    end;


    procedure ToWords(Value: Decimal; Currency: Text[30]; CurrencyUnit: Text[30]; ConversionRate: Integer; LanguageCodes: Text[250]): Text[250]
    var
        WholeNumber: Decimal;
        DecimalPart: Decimal;
        l: Integer;
    begin
        BEGIN
            Value := ABS(Value);
            IF LanguageCodes = '' THEN BEGIN
                LanguageCodes := 'One,Two,Three,Four,Five,Six,Seven,Eight,Nine,Ten,Eleven,Twelve,Thirtheen,Fourteen,Fifteen,Sixteen,Seventeen,'
             ;
                LanguageCodes := LanguageCodes + 'Eighteen,Nineteen,Twenty,Thirty,Forty,Fifty,Sixty,Seventy,Eighty,Ninety,Hundred,Thousand,';
                LanguageCodes := LanguageCodes + 'Million,Billion,Trillion';
            END;
            Words := LanguageCodes;
            Ands := 'and';

            IF ConversionRate = 0 THEN ConversionRate := 100;

            WholeNumber := ROUND(Value, 1, '<');
            IF STRPOS(FORMAT(Value), '.') <> 0 THEN BEGIN
                l := STRLEN(FORMAT(Value)) + 1;
                REPEAT
                    l := l - 1;
                UNTIL EVALUATE(DecimalPart, '0' + COPYSTR(COPYSTR(FORMAT(Value), 1, l), STRPOS(FORMAT(Value), '.')));
                DecimalPart := DecimalPart * ConversionRate;
                DecimalPart := ROUND(DecimalPart, 1, '=');
            END
            ELSE
                DecimalPart := 0;
            IF (WholeNumber > 0) AND (DecimalPart > 0) THEN
                EXIT(C1000_Infinity(WholeNumber) + ' ' + Currency + ' ' + C1000_Infinity(DecimalPart) + ' ' + CurrencyUnit);

            IF (WholeNumber > 0) AND (DecimalPart = 0) THEN
                EXIT(C1000_Infinity(WholeNumber) + ' ' + Currency);

            IF (WholeNumber = 0) AND (DecimalPart > 0) THEN
                EXIT(C1000_Infinity(DecimalPart) + ' ' + CurrencyUnit);

            IF (WholeNumber = 0) AND (DecimalPart = 0) THEN
                EXIT('');
        END;
    end;
}

