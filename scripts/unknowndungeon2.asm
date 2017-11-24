UnknownDungeon2Script:
	call EnableAutoTextBoxDrawing
	xor a
	ld [wWhichDungeonWarp], a
	ld a, 105	
	ld [wDungeonWarpDestinationMap], a
	ld hl, holeCoordinates2	
	call IsPlayerOnDungeonWarp
	ret

UnknownDungeon2TextPointers:
	dw PickUpItemText
	dw PickUpItemText
	dw PickUpItemText

holeCoordinates2:
	db 4, 1
	db 8, 0
	db 13, 0
	db 6, 7
	db 7, 8
	db 8, 9	
	db 4, 11
	db 4, 12
	db 9, 14
	db 16, 6	
	db 3, 21
	db 7, 28
	db 13, 28
	db $FF	