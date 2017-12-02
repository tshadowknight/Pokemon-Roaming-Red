AdvanceRNG:	
	ld a,[wRNGAdd]
	ld b,a	
	rra
	ld a,[wRNGSub]
	rra
	xor b
	ld [wRNGAdd],a
	ld a,[wRNGSub]
	ld c,a
	rra
	ld a,[wRNGAdd]
	ld b,a
	rra
	xor c
	ld [wRNGSub],a
	xor b
	ld [wRNGAdd],a
	ret
	
RandomizeTrainerMon:
	ld a, [wSeedLow]
	ld [wRNGSub], a
	ld a, [wSeedHigh]
	ld [wRNGAdd], a	
	ld a, [wCurOpponent]
.countClass
	push af
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countClass
	ld a, [wTrainerNo]
.countRoster	
	push af
	ld a, [wRNGAdd]
	rra
	ld [wRNGAdd], a
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countRoster
	ld a, [wUnusedC000]
.countPartyMon	
	push af
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countPartyMon
	jr IterateUntilValid
	
RandomizeWildMon:
	ld a, [wSeedLow]
	ld [wRNGSub], a
	ld a, [wSeedHigh]
	ld [wRNGAdd], a	
	ld a, [wCurMap]
.countMap
	push af
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countMap
	ld a, [wUnusedC000]
.countSlot	
	push af
	ld a, [wRNGAdd]
	rra
	ld [wRNGAdd], a
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countSlot
	ld a, [wUnusedC000]
	jr IterateUntilValid
	
	
Done:	
	ld a, [wRNGAdd]
	ld [wcf91], a
	jp BankSwitchCall

IterateUntilValid:
	ld a, [wRNGAdd]
	ld hl, ValidMonIdxs
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	cp 0
	jr nz, Done
	ld a, [wRNGAdd]
	rra
	ld [wRNGAdd], a
	call AdvanceRNG	
	jr IterateUntilValid
	jp BankSwitchCall	

RandomizeMove:
	ld a, [wSeedLow]
	ld [wRNGSub], a
	ld a, [wSeedHigh]
	ld [wRNGAdd], a	
	ld a, [wcf91]
.countMon
	push af
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countMon
	ld a, [wUnusedC000]
.countLevel	
	push af
	ld a, [wRNGAdd]
	rra
	ld [wRNGAdd], a
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countLevel
	ld a, [wUnusedC000]
	jr IterateUntilValidMove		

MoveDone:	
	ld a, [wRNGAdd]
	ld [wUnusedC000], a
	jp BankSwitchCall

IterateUntilValidMove:
	ld a, [wRNGAdd]
	cp 0
	jr z, .invalid
	cp 166
	jr nc, .invalid
	jr nz, MoveDone
.invalid	
	ld a, [wRNGAdd]
	rra
	ld [wRNGAdd], a
	call AdvanceRNG	
	jr IterateUntilValidMove
	jp BankSwitchCall	
	
ValidMonIdxs:		
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 1
	db 0
	db 1
	db 1
	db 1
	db 0
	db 1
	db 1
	db 1
	db 1
	db 0
	db 0
	db 0
	db 1
	db 1
	db 1
	db 0
	db 0
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 0
	db 0
	db 1
	db 1
	db 1
	db 1
	db 0
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 0
	db 1
	db 1
	db 1
	db 1
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 0
	db 1
	db 0
	db 1
	db 1
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 1
	db 1
	db 0
	db 0
	db 0
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 1
	db 0
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 0
	db 0
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0

