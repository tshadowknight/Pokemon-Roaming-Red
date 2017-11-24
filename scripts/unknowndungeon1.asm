UnknownDungeon1Script:
	call EnableAutoTextBoxDrawing
	xor a
	ld [wWhichDungeonWarp], a
	ld a, 105	
	ld [wDungeonWarpDestinationMap], a
	ld hl, holeCoordinates	
	call IsPlayerOnDungeonWarp2
	ret

UnknownDungeon1TextPointers:
	dw PickUpItemText
	dw PickUpItemText
	dw PickUpItemText

holeCoordinates:
	db 15, 24
	db 14, 22
	db 14, 21
	db 12, 22
	db 5, 4
	db 16, 3
	db $FF	

IsPlayerOnDungeonWarp2:
	xor a
	ld [wWhichDungeonWarp], a
	ld a, [wd72d]
	bit 4, a
	ret nz
	call ArePlayerCoordsInArray
	ret nc
	ld a, [wCoordIndex]
	ld [wWhichDungeonWarp], a
	ld hl, wd72d
	set 4, [hl]
	ld hl, wd732
	set 4, [hl]
	ret	