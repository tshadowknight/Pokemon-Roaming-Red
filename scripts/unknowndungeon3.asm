UnknownDungeon3Script:
	call EnableAutoTextBoxDrawing
	call PitFallCheck
	ld hl, MewtwoTrainerHeader
	ld de, .ScriptPointers
	ld a, [wUnknownDungeon3CurScript]
	call ExecuteCurMapScriptInTable
	ld [wUnknownDungeon3CurScript], a
	ret

.ScriptPointers
	dw CheckFightingMapTrainers
	dw DisplayEnemyTrainerTextAndStartBattle
	dw EndTrainerBattle
	

UnknownDungeon3TextPointers:
	dw MewtwoText
	dw PickUpItemText
	dw PickUpItemText
	

MewtwoTrainerHeader:
	dbEventFlagBit EVENT_BEAT_MEWTWO
	db ($0 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_MEWTWO
	dw MewtwoBattleText ; TextBeforeBattle
	dw MewtwoBattleText ; TextAfterBattle
	dw MewtwoBattleText ; TextEndBattle
	dw MewtwoBattleText ; TextEndBattle

	db $ff

MewtwoText:
	TX_ASM
	Call DetermineReferenceLevel
	ld hl, wMapSpriteExtraData+$1
	ld a, [wReferenceLevel]
	ld [hl], a
	ld hl, MewtwoTrainerHeader
	call TalkToTrainer
	jp TextScriptEnd

MewtwoBattleText:
	TX_FAR _MewtwoBattleText
	TX_ASM
	ld a, MEWTWO
	call PlayCry
	call WaitForSoundToFinish
	jp TextScriptEnd

PitFallCheck:	
	xor a
	ld [wWhichDungeonWarp], a
	ld a, 105	
	ld [wDungeonWarpDestinationMap], a
	ld hl, holeCoordinates3
	call IsPlayerOnDungeonWarp	
	ret
	
holeCoordinates3:	
	db 4, 10
	db 6, 6
	db 11, 1
	db 16, 4
	db 15, 7
	db $FF
