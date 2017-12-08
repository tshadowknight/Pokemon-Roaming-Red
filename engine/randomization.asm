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
	
RandomizeTrainerMonVariance:
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
	ld a, [wUnusedCD3D]
.countPartyMon	
	push af
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countPartyMon
	ld a, [wRNGAdd]
	ld [wReferenceLevel], a
	jp BankSwitchCall	
	
RandomizeTrainerMon:
	ld a, [wRandomizerOptions]
	bit 1, a	
	jr nz, .apply
	ld a, [wcf91]
	ld [wRNGAdd], a
	jp Done
.apply
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
	ld a, [wUnusedCD3D]
.countPartyMon	
	push af
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countPartyMon
	jr IterateUntilValid
	
RandomizeWildMon:
	ld a, [wRandomizerOptions]
	bit 0, a	
	jr nz, .apply
	ld a, [wcf91]
	ld [wRNGAdd], a
	jp Done
.apply	
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
	ld a, [wUnusedCD3D]
.countSlot	
	push af
	ld a, [wRNGAdd]
	rra
	ld [wRNGAdd], a
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countSlot
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
	ld a, [wRandomizerOptions]
	bit 2, a	
	jr nz, .apply
	ld a, [wUnusedCD40]
	ld [wRNGAdd], a
	jp MoveDone
.apply
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
	ld a, [wUnusedCD37]
.countAdditional
	push af
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countAdditional	
	jr IterateUntilValidMove		

MoveDone:	
	ld a, [wRNGAdd]
	ld [wUnusedC000], a
	jp BankSwitchCall

IterateUntilValidMove:
	ld a, [wRNGAdd]
	cp 0
	jr z, .invalid
	cp 165
	jr nc, .invalid
	jr nz, MoveDone
.invalid	
	ld a, [wRNGAdd]
	rra
	ld [wRNGAdd], a
	call AdvanceRNG	
	jr IterateUntilValidMove
	jp BankSwitchCall	

RandomizeItem:
	ld a, [wRandomizerOptions]
	bit 4, a	
	jr nz, .apply
	ld a, [wUnusedC000]
	ld c, a
	jr .done
.apply
	ld a, [wUnusedC000]
	ld b, 0
	ld c, a	
	ld hl, ValidItemIdxs
	add hl, bc
	ld a, [hl] 
	cp 2 ; do not randomize key items, tms and hms
	jr z, .done
.rollItem	
	call Random 	
	ld c, a	
	ld hl, ValidItemIdxs
	add hl, bc
	ld a, [hl]
	cp 1
	jr nz, .rollItem
.done
	ld a, c
	ld [wUnusedC000], a	
	jp BankSwitchCall	
	
RandomizeTM:
	ld a, [wRandomizerOptions]
	bit 3, a	
	jr nz, .apply
	ld a, [wUnusedC000]
	ld [wRNGAdd], a
	jp MoveDone
.apply
	ld a, [wSeedLow]
	ld [wRNGSub], a
	ld a, [wSeedHigh]
	ld [wRNGAdd], a	
	ld a, [wUnusedC000]
.countTMIdx	
	push af
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countTMIdx
	jr IterateUntilValidMove
	
RandomizeCanLearnTM:
	ld a, [wRandomizerOptions]
	bit 3, a	
	jr nz, .apply
	ld a, 1
	ld [wRNGAdd], a
	jp MoveDone
.apply
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
	ld a, [wMoveNum]
.countTM	
	push af
	ld a, [wRNGAdd]
	rra
	ld [wRNGAdd], a
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countTM	
	ld a, [wRNGAdd]
	and 1
	ld [wRNGAdd], a
	jp MoveDone
		
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

ValidItemIdxs:	
	db 0
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
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
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
	db 2
	db 0
	db 2
	db 1
	db 1
	db 2
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
	db 2
	db 1
	db 1
	db 1
	db 2
	db 2
	db 1
	db 1
	db 1
	db 1
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 1
	db 2
	db 2
	db 2
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
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 2
	db 0
	db 0
	db 0
	db 0
	db 0