WildOptionText:
	db "Wild:@"
TrainerOptionText:
	db "Trainer:@"	
MovesOptionText:
	db "Lvl. up:@"	
TMsOptionText:
	db "TM:@"
ItemsOptionText:
	db "Items:@"
RandOKText:
	db "GO!@"	
PokeCategoryText:
	db "#MON@"	
MovesCategoryText:
	db "Moves@"		
SeedText:
	db "Seed:@"		
RandOnText:
	db "ON@"	
RandOffText:
	db "OFF@"	
RandTitleText:
	db "Randomizer Settings@"		
UnfilledCursor:	
	db $ec
	db "@"
RandoEmpty:	
	db " @"	
ShowRandomizerMenu:
	push af
	push bc
	push de
	push hl
	; init random seed
	call Random
	ld [wSeedHigh], a
	call Random
	ld [wSeedLow], a
	ld a, 0
	ld [wRandomizerOptions], a
	call ClearScreen
.drawMenu
	; borders
	coord hl, 0, 1
	ld b, 1
	ld c, 18
	call TextBoxBorder
	coord hl, 0, 4
	ld b, 3
	ld c, 18
	call TextBoxBorder
	coord hl, 0, 9
	ld b, 3
	ld c, 18
	call TextBoxBorder
	coord hl, 0, 14
	ld b, 1
	ld c, 18
	call TextBoxBorder
	
	; text	
	
	ld de, RandTitleText
	ld b, $0
	coord hl, 0, 0	
	call PlaceString

	ld de, SeedText
	ld b, $0
	coord hl, 1, 2
	call PlaceString
	
	ld de, PokeCategoryText
	ld b, $0
	coord hl, 1, 5
	call PlaceString
	ld de, WildOptionText
	ld b, $0
	coord hl, 2, 6
	call PlaceString	
	ld de, TrainerOptionText
	ld b, $0
	coord hl, 2, 7
	call PlaceString
	
	ld de, MovesCategoryText
	ld b, $0
	coord hl, 1, 10
	call PlaceString	
	ld de, MovesOptionText
	ld b, $0
	coord hl, 2, 11
	call PlaceString
	ld de, TMsOptionText
	ld b, $0
	coord hl, 2, 12
	call PlaceString
	
	ld de, ItemsOptionText
	ld b, $0
	coord hl, 1, 15
	call PlaceString
	ld de, RandOKText
	ld b, $0
	coord hl, 1, 17
	call PlaceString	
	
	; ON and OFF texts
	
	ld de, RandOnText
	ld b, $0
	coord hl, 12, 6
	call PlaceString
	ld de, RandOffText
	ld b, $0
	coord hl, 16, 6
	call PlaceString
	
	ld de, RandOnText
	ld b, $0
	coord hl, 12, 7
	call PlaceString
	ld de, RandOffText
	ld b, $0
	coord hl, 16, 7
	call PlaceString
	
	ld de, RandOnText
	ld b, $0
	coord hl, 12, 11
	call PlaceString
	ld de, RandOffText
	ld b, $0
	coord hl, 16, 11
	call PlaceString
	
	ld de, RandOnText
	ld b, $0
	coord hl, 12, 12
	call PlaceString
	ld de, RandOffText
	ld b, $0
	coord hl, 16, 12
	call PlaceString
	
	ld de, RandOnText
	ld b, $0
	coord hl, 12, 15
	call PlaceString
	ld de, RandOffText
	ld b, $0
	coord hl, 16, 15
	call PlaceString
.drawCursors	
	
	ld a, [wRandomizerOptions]
	and %00000001
	ld b, 6
	call .drawCursorsForRow
	
	ld a, [wRandomizerOptions]
	and %00000010
	ld b, 7
	call .drawCursorsForRow
	
	ld a, [wRandomizerOptions]
	and %00000100
	ld b, 11
	call .drawCursorsForRow
	
	ld a, [wRandomizerOptions]
	and %00001000
	ld b, 12
	call .drawCursorsForRow
	
	ld a, [wRandomizerOptions]
	and %00010000
	ld b, 15
	call .drawCursorsForRow
.inputLoop
	; process inputs
	push de
	call JoypadLowSensitivity
	pop de
	ld a, [hJoy5]
	ld b, a
	and A_BUTTON | B_BUTTON | D_LEFT | D_RIGHT | D_UP | D_DOWN
	jr z, .inputLoop
.done	
	pop hl
	pop de 
	pop bc
	pop af
	jp BankSwitchCall
	
.drawCursorsForRow
	push af	
	cp 1
	ld c, 11
	jr z, .ON	
	ld de, RandoEmpty
	jr .firstCursorTypeDone
.ON
	ld de, UnfilledCursor	
.firstCursorTypeDone
	push de
	call .calculateTilePtr	
	pop de
	ld b, $0		
	call PlaceString	
	ld c, 4
	ld b, 0
	add hl, bc
	pop af
	cp 1
	jr nz, .OFF	
	ld de, RandoEmpty
	jr .secondCursorTypeDone
.OFF
	ld de, UnfilledCursor	
.secondCursorTypeDone
	call PlaceString
	ret	
	
.calculateTilePtr
	; c = x
	; b = y	
	ld hl, wTileMap 
	ld d, SCREEN_WIDTH
	ld a, 0
.YCoLoop
	push af
	ld a, 0
.ScreenWidthLoop
	inc hl
	inc a
	cp d 
	jr nz, .ScreenWidthLoop
	pop af
	inc a	
	cp b
	jr nz, .YCoLoop
	ld b, 0
	add hl, bc
	ret