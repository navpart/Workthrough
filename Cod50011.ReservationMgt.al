codeunit 50011 "Reservation Mgt."
{

    var

    Var
        EngineNo: Code[20];
        ExtColorCode: Code[30];
        ExtColorName: Text[30];
        KeyNo: Code[20];
        ModifyRun: Boolean;

    //Update custom field values For New Insert value Updated in Reservation Entry
    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnRegisterChangeOnChangeTypeInsertOnBeforeInsertReservEntry', '', false, false)]
    local procedure OnRegisterChangeOnChangeTypeInsertOnBeforeInsertReservEntry(var OldTrackingSpecification: Record "Tracking Specification"; var NewTrackingSpecification: Record "Tracking Specification")
    Begin
        ModifyRun := false;
        EngineNo := NewTrackingSpecification."Engine No.";
        ExtColorCode := NewTrackingSpecification."Exterior Colour Code";
        ExtColorName := NewTrackingSpecification."Exterior Colour Name";
        KeyNo := NewTrackingSpecification."Key No.";
    End;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterSetDates', '', false, false)]
    local procedure OnAfterSetDates(var ReservationEntry: Record "Reservation Entry")
    Begin
        ReservationEntry."Engine No." := EngineNo;
        ReservationEntry."Exterior Colour Code" := ExtColorCode;
        ReservationEntry."Exterior Colour Name" := ExtColorName;
        ReservationEntry."Key No." := KeyNo;
    End;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnCreateReservEntryExtraFields', '', false, false)]
    local procedure OnCreateReservEntryExtraFields(var InsertReservEntry: Record "Reservation Entry"; OldTrackingSpecification: Record "Tracking Specification"; NewTrackingSpecification: Record "Tracking Specification")
    Begin
        InsertReservEntry."Engine No." := NewTrackingSpecification."Engine No.";
        InsertReservEntry."Exterior Colour Code" := NewTrackingSpecification."Exterior Colour Code";
        InsertReservEntry."Exterior Colour Name" := NewTrackingSpecification."Exterior Colour Name";
        InsertReservEntry."Key No." := NewTrackingSpecification."Key No.";
    End;

    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterCopyTrackingSpec', '', false, false)]
    local procedure OnAfterCopyTrackingSpec(var SourceTrackingSpec: Record "Tracking Specification"; var DestTrkgSpec: Record "Tracking Specification")
    Begin
        If ModifyRun = false then begin
            SourceTrackingSpec."Engine No." := DestTrkgSpec."Engine No.";
            SourceTrackingSpec."Exterior Colour Code" := DestTrkgSpec."Exterior Colour Code";
            SourceTrackingSpec."Exterior Colour Name" := DestTrkgSpec."Exterior Colour Name";
            SourceTrackingSpec."Key No." := DestTrkgSpec."Key No.";

        end else begin
            //For Modified value flow
            DestTrkgSpec."Engine No." := SourceTrackingSpec."Engine No.";
            DestTrkgSpec."Exterior Colour Code" := SourceTrackingSpec."Exterior Colour Code";
            DestTrkgSpec."Exterior Colour Name" := SourceTrackingSpec."Exterior Colour Name";
            DestTrkgSpec."Key No." := SourceTrackingSpec."Key No.";
        end;
    End;


    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnRegisterItemTrackingLinesOnBeforeInsert', '', false, false)]
    local procedure OnRegisterItemTrackingLinesOnBeforeInsert(var TrackingSpecification: Record "Tracking Specification"; var TempTrackingSpecification: Record "Tracking Specification" temporary; SourceTrackingSpecification: Record "Tracking Specification")
    Begin
        TrackingSpecification."Engine No." := TempTrackingSpecification."Engine No.";
        TrackingSpecification."Exterior Colour Code" := TempTrackingSpecification."Exterior Colour Code";
        TrackingSpecification."Exterior Colour Name" := TempTrackingSpecification."Exterior Colour Name";
        TrackingSpecification."Key No." := TempTrackingSpecification."Key No.";
    End;



    //Update modified custom field values For New Insert value Updated in Reservation Entry

    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterEntriesAreIdentical', '', false, false)]
    local procedure OnAfterEntriesAreIdentical(ReservEntry1: Record "Reservation Entry"; ReservEntry2: Record "Reservation Entry"; var IdenticalArray: array[2] of Boolean)
    Begin
        IdenticalArray[2] :=
            (ReservEntry1."Engine No." = ReservEntry2."Engine No.") and
            (ReservEntry1."Exterior Colour Code" = ReservEntry2."Exterior Colour Code") and
            (ReservEntry1."Exterior Colour Name" = ReservEntry2."Exterior Colour Name") and
            (ReservEntry1."Key No." = ReservEntry2."Key No.")
    End;

    // [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnRegisterChangeOnBeforeAddItemTrackingToTempRecSet', '', false, false)]
    // local procedure OnRegisterChangeOnBeforeAddItemTrackingToTempRecSet(var OldTrackingSpecification: Record "Tracking Specification"; var NewTrackingSpecification: Record "Tracking Specification")
    // Begin
    //     OldTrackingSpecification."Engine No." := NewTrackingSpecification."Engine No.";
    //     OldTrackingSpecification."Exterior Colour Code" := NewTrackingSpecification."Exterior Colour Code";
    // End;

    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterMoveFields', '', false, false)]
    local procedure OnAfterMoveFields(var TrkgSpec: Record "Tracking Specification"; var ReservEntry: Record "Reservation Entry")
    Begin
        ReservEntry."Engine No." := TrkgSpec."Engine No.";
        ReservEntry."Exterior Colour Code" := TrkgSpec."Exterior Colour Code";
        ReservEntry."Exterior Colour Name" := TrkgSpec."Exterior Colour Name";
        ReservEntry."Key No." := TrkgSpec."Key No.";
    End;

    //Custom Values flow to ILE
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertSetupTempSplitItemJnlLine', '', false, false)]
    local procedure OnBeforeInsertSetupTempSplitItemJnlLine(var TempItemJournalLine: Record "Item Journal Line" temporary; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    Begin
        TempItemJournalLine."Engine No." := TempTrackingSpecification."Engine No.";
        TempItemJournalLine."Exterior Colour Code" := TempTrackingSpecification."Exterior Colour Code";
        TempItemJournalLine."Exterior Colour Name" := TempTrackingSpecification."Exterior Colour Name";
        TempItemJournalLine."Key No." := TempTrackingSpecification."Key No.";
    End;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line")
    Begin
        NewItemLedgEntry."Engine No." := ItemJournalLine."Engine No.";
        NewItemLedgEntry."Exterior Colour Code" := ItemJournalLine."Exterior Colour Code";
        NewItemLedgEntry."Exterior Colour Name" := ItemJournalLine."Exterior Colour Name";
        NewItemLedgEntry."Key No." := ItemJournalLine."Key No.";
    End;

    //Assign Custom Values to Sales Shipments
    [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnAfterValidateEvent', 'Serial No.', false, false)]
    local procedure TrackingSpecificatioOnAfterValidateEventLotNo(var Rec: Record "Tracking Specification")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntry2: Record "Item Ledger Entry";
    Begin
        ItemLedgerEntry2.Reset();
        ItemLedgerEntry2.SetRange("Serial No.", Rec."Serial No.");
        If ItemLedgerEntry2.FindFirst() then begin

            Rec."Engine No." := ItemLedgerEntry2."Engine No.";
            Rec."Exterior Colour Code" := ItemLedgerEntry2."Exterior Colour Code";
            Rec."Exterior Colour Name" := ItemLedgerEntry2."Exterior Colour Name";
            Rec."Key No." := ItemLedgerEntry2."Key No.";

        end;
    End;

    [EventSubscriber(ObjectType::Table, Database::"Entry Summary", 'OnAfterInsertEvent', '', false, false)]
    local procedure EntrySummaryOnAfterInsertEvent(var Rec: Record "Entry Summary" temporary)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntry2: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry2.Reset();
        ItemLedgerEntry2.SetRange("Serial No.", Rec."Serial No.");
        If ItemLedgerEntry2.FindFirst() then begin

            Rec."Engine No." := ItemLedgerEntry2."Engine No.";
            Rec."Exterior Colour Code" := ItemLedgerEntry2."Exterior Colour Code";
            Rec."Exterior Colour Name" := ItemLedgerEntry2."Exterior Colour Name";
            Rec."Key No." := ItemLedgerEntry2."Key No.";
            Rec.Modify();

        end;
    end;

      [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnAfterInsertEvent', '', false, false)]
    local procedure TrackingSpecificationOnAfterInsertEvent(var Rec: Record "Tracking Specification")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntry2: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry2.Reset();
        ItemLedgerEntry2.SetRange("Serial No.", Rec."Serial No.");
        If ItemLedgerEntry2.FindFirst() then begin

            Rec."Engine No." := ItemLedgerEntry2."Engine No.";
            Rec."Exterior Colour Code" := ItemLedgerEntry2."Exterior Colour Code";
            Rec."Exterior Colour Name" := ItemLedgerEntry2."Exterior Colour Name";
            Rec."Key No." := ItemLedgerEntry2."Key No.";
            Rec.Modify();

        end;
    end;

}
