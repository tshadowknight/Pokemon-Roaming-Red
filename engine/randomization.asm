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
	ret
	
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
	ret

IterateUntilValid:
	ld a, [wRNGAdd]	
	cp 151
	jr c, .foundValidMon
	sub 151
.foundValidMon:
	ld hl, ValidMonIdxs
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	ld [wRNGAdd], a
	jr Done	

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
	ret

IterateUntilValidMove:
	ld a, [wRNGAdd]
	cp 0
	jr z, .invalid
	cp 165
	jr nc, .invalid
	jr nz, MoveDone
.invalid	
	ld a, [wRNGAdd]
	sub 164
	ld [wRNGAdd], a
	jr IterateUntilValidMove
	ret

RandomizeItem:
	ld a, [wRandomizerOptions]
	bit 4, a	
	jr nz, .apply
	ld a, [wUnusedC000]
	ld c, a
	jr .done
.apply
	ld a, [wSeedLow]
	ld [wRNGSub], a
	ld a, [wSeedHigh]
	ld [wRNGAdd], a	
	ld a, [wUnusedC000]
	ld b, 0
	ld c, a	
	ld hl, ValidItemIdxs
	add hl, bc
	ld a, [hl] 
	cp 2 ; do not randomize key items, tms and hms
	jr z, .done
	ld a, [wUnusedC000]
.countItem	
	push af
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countItem	
	ld a, [wCurMap]
.countMap	
	push af
	call AdvanceRNG	
	pop af
	sub 1
	jr nc, .countMap
.rollUntilValid
	call AdvanceRNG	
	ld b, 0
	ld a, [wRNGAdd]		
	ld c, a	
	ld hl, ValidItemIdxs
	add hl, bc
	ld a, [hl]
	cp 1
	jr nz, .rollUntilValid
.done
	ld a, c
	ld [wUnusedC000], a	
	ret
	
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
	jp IterateUntilValidMove
	
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
	db 1
	db 2
	db 3
	db 4
	db 5
	db 6
	db 7
	db 8
	db 9
	db 10
	db 11
	db 12
	db 13
	db 14
	db 15
	db 16
	db 17
	db 18
	db 19
	db 20
	db 21
	db 22
	db 23
	db 24
	db 25
	db 26
	db 27
	db 28
	db 29
	db 30
	db 33
	db 34
	db 35
	db 36
	db 37
	db 38
	db 39
	db 40
	db 41
	db 42
	db 43
	db 44
	db 45
	db 46
	db 47
	db 48
	db 49
	db 51
	db 53
	db 54
	db 55
	db 57
	db 58
	db 59
	db 60
	db 64
	db 65
	db 66
	db 70
	db 71
	db 72
	db 73
	db 74
	db 75
	db 76
	db 77
	db 78
	db 82
	db 83
	db 84
	db 85
	db 88
	db 89
	db 90
	db 91
	db 92
	db 93
	db 96
	db 97
	db 98
	db 99
	db 100
	db 101
	db 102
	db 103
	db 104
	db 105
	db 106
	db 107
	db 108
	db 109
	db 110
	db 111
	db 112
	db 113
	db 114
	db 116
	db 117
	db 118
	db 119
	db 120
	db 123
	db 124
	db 125
	db 126
	db 128
	db 129
	db 130
	db 131
	db 132
	db 133
	db 136
	db 138
	db 139
	db 141
	db 142
	db 143
	db 144
	db 145
	db 147
	db 148
	db 149
	db 150
	db 151
	db 152
	db 153
	db 154
	db 155
	db 157
	db 158
	db 163
	db 164
	db 165
	db 166
	db 167
	db 168
	db 169
	db 170
	db 171
	db 173
	db 176
	db 177
	db 178
	db 179
	db 180
	db 185
	db 186
	db 187
	db 188
	db 189
	db 190

ValidItemIdxs:	
	db 0
	db 1
	db 1
	db 1
	db 1
	db 2
	db 2
	db 0
	db 1
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
	db 2
	db 2
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