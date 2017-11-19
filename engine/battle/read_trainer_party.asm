ModifyLevel:
	push af
	push bc
	push de
	push hl
	ld b, 0
	ld d, 0
	ld a, [wPartyCount]
	ld c, a
	ld hl, $D18C
.searchLevel
	ld a, [hl]	
	cp d
	jp c, .noHigherLevel
	ld d, a	
.noHigherLevel	
	push bc
	ld bc, 44
	add hl, bc
	pop bc
	inc b
	ld a, b
	cp c
	jp nz, .searchLevel
.levelFound
	call Random
	and %0011
	ld b, a
	call Random
	and %0001
	cp 0
	jp z, .subtract	
	ld a, d	
	add b		
	jp .doneApplyingVariance	
.subtract
	ld a, d		
	sub b	
	jp nc, .doneApplyingVariance
	ld a, 1	
.doneApplyingVariance	
	cp 0
	jp nz, .notZero
	add 1
.notZero	
	ld b, a 
	ld a, [wEngagedTrainerClass]
	cp $E5 ; Giovanni
	jp z, .applyPlusFive
	cp $E6 ; ROCKET
	jp z, .applyPlusThree
	cp $E7; Cooltrainer male
	jp z, .applyPlusThree
	cp $E8 ; Cooltrainer female
	jp z, .applyPlusThree
	cp $E9 ; Bruno
	jp z, .applyPlusFive
	cp $EA ; Brock
	jp z, .applyPlusFive
	cp $EB ; Misty
	jp z, .applyPlusFive
	cp $EC ; Lt. Surge
	jp z, .applyPlusFive
	cp $ED ; Erika
	jp z, .applyPlusFive
	cp $EE ; Koga
	jp z, .applyPlusFive
	cp $EF ; Blaine
	jp z, .applyPlusFive
	cp $F0 ; Sabrina
	jp z, .applyPlusFive
	cp $F3 ; Rival Final
	jp z, .applyPlusFive
	cp $F4 ; Lorelei
	jp z, .applyPlusFive
	cp $F6 ; Agatha
	jp z, .applyPlusFive
	cp $F7 ; Lance
	jp z, .applyPlusFive
	ld a, b
	jp .doneApplyingBoost
.applyPlusThree
	ld a, b
	add 3
	jp .doneApplyingBoost
.applyPlusFive	
	ld a, b
	add 5
.doneApplyingBoost	
	cp 100
	jp c, .notAbove100
	jp z, .notAbove100
	ld a, 100
.notAbove100	
	ld [wCurEnemyLVL],a
	pop hl
	pop de
	pop bc
	pop af	
	ret
	
ModifyEvoStage:
	push af
	push bc
	push de
	push hl
	ld a, [wcf91]
	ld b, 0
	ld c, a
	ld a, [wCurEnemyLVL]
	cp 20
	jr nc, .higherThan20
	ld hl, Stage3ToStage2
	call ApplyStageChange
	ld hl, Stage2ToStage1
	call ApplyStageChange
	jr .evoScalingDone
.higherThan20
	ld a, [wCurEnemyLVL]
	cp 35
	jr nc, .higherThan35
	ld hl, Stage3ToStage2
	call ApplyStageChange
	ld hl, Stage1ToStage2
	call ApplyStageChange
	jr .evoScalingDone
.higherThan35		
	ld hl, Stage1ToStage2
	call ApplyStageChange
	ld hl, Stage2ToStage3
	call ApplyStageChange
.evoScalingDone	
	ld a, c 
	ld [wcf91], a
	pop hl
	pop de
	pop bc
	pop af
	ret

ApplyStageChange:
	add hl, bc
	ld a, [hl]
	cp 0
	jr z, .done
	ld c, a
.done		
	ret	
	
ReadTrainer:

; don't change any moves in a link battle
	ld a,[wLinkState]
	and a
	ret nz

; set [wEnemyPartyCount] to 0, [wEnemyPartyMons] to FF
; XXX first is total enemy pokemon?
; XXX second is species of first pokemon?
	ld hl,wEnemyPartyCount
	xor a
	ld [hli],a
	dec a
	ld [hl],a

; get the pointer to trainer data for this class
	ld a,[wCurOpponent]
	sub $C9 ; convert value from pokemon to trainer
	add a,a
	ld hl,TrainerDataPointers
	ld c,a
	ld b,0
	add hl,bc ; hl points to trainer class
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld a,[wTrainerNo]
	ld b,a
; At this point b contains the trainer number,
; and hl points to the trainer class.
; Our next task is to iterate through the trainers,
; decrementing b each time, until we get to the right one.
.outer
	dec b
	jr z,.IterateTrainer
.inner
	ld a,[hli]
	and a
	jr nz,.inner
	jr .outer

; if the first byte of trainer data is FF,
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - if [wLoneAttackNo] != 0, one pokemon on the team has a special move
; else the first byte is the level of every pokemon on the team
.IterateTrainer
	ld a,[hli]
	cp $FF ; is the trainer special?
	jr z,.SpecialTrainer ; if so, check for special moves
	
.LoopTrainerData
	call ModifyLevel	
	ld a,[hli]
	and a ; have we reached the end of the trainer data?
	jp z,.FinishUp
	ld [wcf91],a ; write species somewhere (XXX why?)	
	call ModifyEvoStage
	ld a,ENEMY_PARTY_DATA
	ld [wMonDataLocation],a	
	push hl
	call AddPartyMon
	pop hl
	jr .LoopTrainerData
.SpecialTrainer
; if this code is being run:
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - if [wLoneAttackNo] != 0, one pokemon on the team has a special move
	ld a,[hli]
	and a ; have we reached the end of the trainer data?
	jr z,.AddLoneMove
	call ModifyLevel
	ld a,[hli]
	ld [wcf91],a
	call ModifyEvoStage
	ld a,ENEMY_PARTY_DATA
	ld [wMonDataLocation],a
	push hl
	call AddPartyMon
	pop hl
	jr .SpecialTrainer
.AddLoneMove
; does the trainer have a single monster with a different move
	ld a,[wLoneAttackNo] ; Brock is 01, Misty is 02, Erika is 04, etc
	and a
	jr z,.AddTeamMove
	dec a
	add a,a
	ld c,a
	ld b,0
	ld hl,LoneMoves
	add hl,bc
	ld a,[hli]
	ld d,[hl]
	ld hl,wEnemyMon1Moves + 2
	ld bc,wEnemyMon2 - wEnemyMon1
	call AddNTimes
	ld [hl],d
	jr .FinishUp
.AddTeamMove
; check if our trainer's team has special moves

; get trainer class number
	ld a,[wCurOpponent]
	sub 200
	ld b,a
	ld hl,TeamMoves

; iterate through entries in TeamMoves, checking each for our trainer class
.IterateTeamMoves
	ld a,[hli]
	cp b
	jr z,.GiveTeamMoves ; is there a match?
	inc hl ; if not, go to the next entry
	inc a
	jr nz,.IterateTeamMoves

; no matches found. is this trainer champion rival?
	ld a,b
	cp SONY3
	jr z,.ChampionRival
	jr .FinishUp ; nope
.GiveTeamMoves
	ld a,[hl]
	ld [wEnemyMon5Moves + 2],a
	jr .FinishUp
.ChampionRival ; give moves to his team

; pidgeot
	ld a,SKY_ATTACK
	ld [wEnemyMon1Moves + 2],a

; starter
	ld a,[wRivalStarter]
	cp STARTER3
	ld b,MEGA_DRAIN
	jr z,.GiveStarterMove
	cp STARTER1
	ld b,FIRE_BLAST
	jr z,.GiveStarterMove
	ld b,BLIZZARD ; must be squirtle
.GiveStarterMove
	ld a,b
	ld [wEnemyMon6Moves + 2],a
.FinishUp
; clear wAmountMoneyWon addresses
	xor a
	ld de,wAmountMoneyWon
	ld [de],a
	inc de
	ld [de],a
	inc de
	ld [de],a
	ld a,[wCurEnemyLVL]
	ld b,a
.LastLoop
; update wAmountMoneyWon addresses (money to win) based on enemy's level
	ld hl,wTrainerBaseMoney + 1
	ld c,2 ; wAmountMoneyWon is a 3-byte number
	push bc
	predef AddBCDPredef
	pop bc
	inc de
	inc de
	dec b
	jr nz,.LastLoop ; repeat wCurEnemyLVL times
	ret

Stage1ToStage2:
	db 0
	db 0
	db 0
	db 167
	db 142
	db 35
	db 141
	db 0
	db 0
	db 0
	db 0
	db 0
	db 10
	db 136
	db 0
	db 168
	db 0
	db 145
	db 1
	db 0
	db 0
	db 0
	db 0
	db 139
	db 155
	db 147
	db 0
	db 152
	db 0
	db 0
	db 0
	db 0
	db 0
	db 20
	db 0
	db 0
	db 150
	db 7
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 128
	db 129
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 143
	db 0
	db 117
	db 120
	db 118
	db 0
	db 0
	db 0
	db 0
	db 0
	db 119
	db 0
	db 0
	db 0
	db 0
	db 116
	db 110
	db 0
	db 0
	db 0
	db 0
	db 0
	db 144
	db 138
	db 0
	db 0
	db 0
	db 83
	db 0
	db 85
	db 0
	db 0
	db 0
	db 89
	db 0
	db 91
	db 0
	db 93
	db 0
	db 0
	db 0
	db 97
	db 0
	db 99
	db 0
	db 101
	db 0
	db 105
	db 0
	db 0
	db 0
	db 41
	db 130
	db 45
	db 46
	db 0
	db 0
	db 113
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 124
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 22
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 38
	db 0
	db 0
	db 0
	db 0
	db 9
	db 0
	db 0
	db 0
	db 158
	db 0
	db 0
	db 0
	db 0
	db 0
	db 164
	db 0
	db 166
	db 0
	db 0
	db 0
	db 39
	db 0
	db 0
	db 0
	db 54
	db 0
	db 0
	db 178
	db 179
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 186
	db 0
	db 0
	db 189
	db 0
	db 0
Stage2ToStage3:
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 154
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 149
	db 49
	db 0
	db 126
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 66
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 111
	db 0
	db 0
	db 114
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 125
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 14
	db 0
	db 0
	db 151
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 7
	db 16
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 180
	db 28
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 187
	db 0
	db 0
	db 190
	db 0

Stage2ToStage1:
	db 0
	db 18
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 37
	db 153
	db 12
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 33
	db 0
	db 133
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 5
	db 0
	db 0
	db 148
	db 169
	db 0
	db 106
	db 0
	db 0
	db 0
	db 108
	db 109
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 173
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 82
	db 0
	db 0
	db 0
	db 0
	db 0
	db 88
	db 0
	db 90
	db 0
	db 92
	db 0
	db 0
	db 0
	db 96
	db 0
	db 98
	db 0
	db 100
	db 0
	db 0
	db 0
	db 102
	db 0
	db 0
	db 0
	db 0
	db 71
	db 0
	db 0
	db 112
	db 0
	db 0
	db 70
	db 57
	db 59
	db 65
	db 58
	db 0
	db 0
	db 0
	db 123
	db 0
	db 0
	db 0
	db 47
	db 48
	db 107
	db 0
	db 0
	db 0
	db 0
	db 0
	db 13
	db 0
	db 78
	db 23
	db 0
	db 6
	db 4
	db 55
	db 77
	db 17
	db 0
	db 25
	db 0
	db 0
	db 36
	db 0
	db 27
	db 0
	db 0
	db 24
	db 0
	db 0
	db 157
	db 0
	db 0
	db 0
	db 0
	db 0
	db 163
	db 0
	db 165
	db 3
	db 15
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 176
	db 177
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 185
	db 0
	db 0
	db 188
	db 0

Stage3ToStage2:
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 167
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 147
	db 0
	db 168
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 179
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 39
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 89
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 110
	db 0
	db 0
	db 113
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 124
	db 41
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 38
	db 0
	db 150
	db 0
	db 0
	db 9
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 178
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 186
	db 0
	db 0
	db 189
	
	