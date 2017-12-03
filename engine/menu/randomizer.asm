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
RandGoText:
	db "GO!@"	
RandOKText:
	db "OK@"	
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
FilledCursor:	
	db $ed
	db "@"
DownCursor:	
	db $ee
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
	ld a, 1
	ld [wUnusedC000], a ; current selected row
	ld a, 4
	ld [wUnusedCD37], a ; current position in seed row
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
	
	ld de, RandOKText
	ld b, $0
	coord hl, 17, 2
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
	ld de, RandGoText
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

	ld a, "┌"
	inc a	
	coord hl, 7, 1
	ld [hl], a
	coord hl, 8, 1
	ld [hl], a
	coord hl, 9, 1
	ld [hl], a
	coord hl, 10, 1
	ld [hl], a
	
	ld a, [wRandomizerOptions]
	ld d, %00000001
	and d
	ld b, 6
	call .drawCursorsForRow
	
	ld a, [wRandomizerOptions]
	ld d, %00000010
	and d
	ld b, 7
	call .drawCursorsForRow
	
	ld a, [wRandomizerOptions]
	ld d, %00000100
	and d
	ld b, 11
	call .drawCursorsForRow
	
	ld a, [wRandomizerOptions]
	ld d, %00001000
	and d
	ld b, 12
	call .drawCursorsForRow
	
	ld a, [wRandomizerOptions]
	ld d, %00010000
	and d
	ld b, 15
	call .drawCursorsForRow
	
	coord hl, 0, 17
	ld b, 1
	ld c, 1
	call ClearScreenArea
	ld a, [wUnusedC000]
	cp %00100000
	jr nz, .notBottomRow	
	ld de, FilledCursor
	ld b, $0
	coord hl, 0, 17
	call PlaceString

.notBottomRow	
	coord hl, 16, 2
	ld b, 1
	ld c, 1
	call ClearScreenArea
	ld a, [wUnusedC000]
	cp 0
	jr nz, .doneDrawingCusors	
	ld a, [wUnusedCD37]
	cp 0
	jp z, .drawNybble0Cursor
	cp 1
	jp z, .drawNybble1Cursor
	cp 2
	jp z, .drawNybble2Cursor
	cp 3
	jp z, .drawNybble3Cursor
	cp 4
	jp z, .drawOKCursor	
	
.doneDrawingCusors	
	
.drawSeedDisplay
	ld hl, wBuffer
	push hl
	
	ld hl, NybbleToHEXDigit
	ld a, [wSeedHigh]	
	rra
	rra
	rra
	rra
	and $F
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	pop hl
	ld [hl], a 
	inc hl  
	push hl
	
	ld hl, NybbleToHEXDigit
	ld a, [wSeedHigh]
	and $F
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	pop hl
	ld [hl], a 
	inc hl  
	push hl
	
	ld hl, NybbleToHEXDigit
	ld a, [wSeedLow]
	rra
	rra
	rra
	rra
	and $F
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	pop hl
	ld [hl], a 
	inc hl  
	push hl
	
	ld hl, NybbleToHEXDigit
	ld a, [wSeedLow]
	and $F
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	pop hl
	ld [hl], a 
	inc hl  
	
	ld a, $50
	ld [hl], a
	
	ld de, wBuffer
	ld b, $0
	coord hl, 7, 2
	call PlaceString
.inputLoop
	; process inputs
	push de
	call JoypadLowSensitivity
	pop de
	ld a, [hJoy5]
	ld b, a
	and A_BUTTON | B_BUTTON | D_LEFT | D_RIGHT | D_UP | D_DOWN
	bit 5, b ; Left pressed?
	jp nz, .pressedLeft
	bit 4, b ; Right pressed?
	jp nz, .pressedRight
	bit 6, b ; Up pressed?
	jp nz, .pressedUp
	bit 7, b ; Down pressed?
	jp nz, .pressedDown
	bit 0, b ; A pressed?
	jp nz, .pressedA
	jr z, .inputLoop
.done	
	pop hl
	pop de 
	pop bc
	pop af
	jp BankSwitchCall

.drawOKCursor	
	ld de, FilledCursor
	ld b, $0
	coord hl, 16, 2
	call PlaceString
	jp .doneDrawingCusors

.drawNybble0Cursor	
	ld de, DownCursor
	ld b, $0
	coord hl, 7, 1
	call PlaceString
	jp .doneDrawingCusors

.drawNybble1Cursor	
	ld de, DownCursor
	ld b, $0
	coord hl, 8, 1
	call PlaceString
	jp .doneDrawingCusors	

.drawNybble2Cursor	
	ld de, DownCursor
	ld b, $0
	coord hl, 9, 1
	call PlaceString
	jp .doneDrawingCusors	

.drawNybble3Cursor	
	ld de, DownCursor
	ld b, $0
	coord hl, 10, 1
	call PlaceString
	jp .doneDrawingCusors		

.pressedA
	ld a, [wUnusedC000]
	cp %00100000
	jr nz, .notOnOkRow	
	jp .done
.notOnOkRow	
	jp .inputLoop	
	
.pressedUp
	ld a, [wUnusedCD37]
	cp 4
	jr nz, .pressedUpOnSeedVal
	ld a, [wUnusedC000]
	cp 0
	jr nz, .noUnderFlow
	ld a, %00100000
	jr .pressedUpDone
.noUnderFlow
	rra
	and %01111111
.pressedUpDone
	ld [wUnusedC000], a
	jp .drawCursors	

.pressedUpOnSeedVal
	ld a, 1	
	jr .handleSeedModification
	
.pressedDownOnSeedVal
	ld a, 0
	jr .handleSeedModification	
	
.handleSeedModification
	ld b, a 
	ld a, [wUnusedCD37]
	cp 0
	jr z, .getHighHigh
	cp 1
	jr z, .getHighLow
	cp 2
	jr z, .getLowHigh
	cp 3
	jr z, .getLowLow
.gotNybble
	ld c, a	
	ld a, b 
	cp 1
	ld a, c
	jr z, .addToNybble
	dec a 
	jr .updatedNybble
.addToNybble
	inc a	
.updatedNybble	
	and $F
	ld b, a
	ld a, [wUnusedCD37]
	cp 0
	jr z, .storeHighHigh
	cp 1
	jr z, .storeHighLow
	cp 2
	jr z, .storeLowHigh
	cp 3
	jr z, .storeLowLow
.storedNybble	
	jp .drawSeedDisplay	
	
.getHighHigh
	ld a, [wSeedHigh]
	rra
	rra
	rra
	rra
	and $F 
	jr .gotNybble
	
.getHighLow
	ld a, [wSeedHigh]
	and $F 
	jr .gotNybble	
	
.getLowHigh
	ld a, [wSeedLow]
	rra
	rra
	rra
	rra
	and $F 
	jr .gotNybble

.getLowLow
	ld a, [wSeedLow]
	and $F 
	jr .gotNybble	
	
.storeHighHigh
	ld a, b
	rla 
	rla
	rla
	rla
	and $F0
	ld b, a 
	ld a, [wSeedHigh]
	and $F
	or b
	ld [wSeedHigh], a
	jr .storedNybble
	
.storeHighLow
	ld a, [wSeedHigh]
	and $F0
    or b	
	ld [wSeedHigh], a
	jr .storedNybble	
	
.storeLowHigh
	ld a, b
	rla 
	rla
	rla
	rla
	and $F0
	ld b, a 
	ld a, [wSeedLow]
	and $F
	or b
	ld [wSeedLow], a
	jr .storedNybble
	
.storeLowLow
	ld a, [wSeedLow]
	and $F0
    or b	
	ld [wSeedLow], a
	jr .storedNybble		
	
.pressedDown
	ld a, [wUnusedCD37]
	cp 4
	jp nz, .pressedDownOnSeedVal
	ld a, [wUnusedC000]
	cp %00100000
	jr nz, .noOverFlow
	ld a, 0
	jr .pressedDownDone
.noOverFlow
	cp 0
	jr z, .isZero
	rla
	and %11111110
	jr .pressedDownDone
.isZero
	ld a, 1	
.pressedDownDone
	ld [wUnusedC000], a
	jp .drawCursors		
	
.pressedLeft
	ld a, [wUnusedC000]
	cp 0
	jr z, .seedRowLeftPress
	cp %00100000
	jr z, .OKRowLeftPress
	ld b, a 
	ld a, [wRandomizerOptions]
	xor b 
  	ld [wRandomizerOptions], a	
.OKRowLeftPress	
	jp .drawCursors
	
.seedRowLeftPress
	ld a, [wUnusedCD37]
	cp 0
	jr z, .leftEndOfSeedRow
	dec a
	jr .seedRowLeftPressDone
.leftEndOfSeedRow
	ld a, 4		
.seedRowLeftPressDone
	ld [wUnusedCD37], a
	jp .drawCursors
	
.pressedRight
	ld a, [wUnusedC000]
	cp 0
	jr z, .seedRowRightPress
	cp %00100000
	jr z, .OKRowRightPress
	ld b, a 
	ld a, [wRandomizerOptions]
	xor b 
  	ld [wRandomizerOptions], a
.OKRowRightPress
	jp .drawCursors
	
.seedRowRightPress	
	ld a, [wUnusedCD37]
	cp 4
	jr z, .rightEndOfSeedRow
	inc a
	jr .seedRowRightPressDone
.rightEndOfSeedRow
	ld a, 0	
.seedRowRightPressDone
	ld [wUnusedCD37], a	
	jp .drawCursors
	
.drawCursorsForRow
	push de
	push af	
	cp 0
	ld c, 11
	jr nz, .ON	
	ld de, RandoEmpty
	jr .firstCursorTypeDone
.ON	
	push af
	ld a, [wUnusedC000]
	cp d
	jr z, .ONFilled
	ld de, UnfilledCursor	
	jr .ONDone	
.ONFilled	
	ld de, FilledCursor
.ONDone	
	pop af
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
	pop de
	cp 0
	jr z, .OFF	
	ld de, RandoEmpty
	jr .secondCursorTypeDone
.OFF
	push af
	ld a, [wUnusedC000]
	cp d
	jr z, .OFFilled
	ld de, UnfilledCursor	
	jr .OFFDone	
.OFFilled	
	ld de, FilledCursor
.OFFDone	
	pop af	
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
	
NybbleToHEXDigit:
	db "0"
	db "1"
	db "2"
	db "3"
	db "4"
	db "5"
	db "6"
	db "7"
	db "8"
	db "9"
	db "A"
	db "B"
	db "C"
	db "D"
	db "E"
	db "F"		