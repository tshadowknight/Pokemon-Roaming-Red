ModifyLevelWild:
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
	ld a, d	
	sub b	
	jp nc, .noUnderflow
	ld a, 1
.noUnderflow
	cp 0
	jp nz, .notZero
	add 1
.notZero	
	ld [wCurEnemyLVL],a
	pop hl
	pop de
	pop bc
	pop af	
	ret

ModifyEvoStageWild:
	push af
	push bc
	push de
	push hl
	call Random
	and 1
	cp 0
	jp z, .evoScalingEnd
	ld a, [wcf91]
	ld b, 0
	ld c, a
	ld a, [wCurEnemyLVL]
	cp 20
	jr nc, .higherThan20
	ld hl, Stage3ToStage2Wild
	call ApplyStageChangeWild
	ld hl, Stage2ToStage1Wild
	call ApplyStageChangeWild
	jr .evoScalingDone
.higherThan20
	ld a, [wCurEnemyLVL]
	cp 35
	jr nc, .higherThan35
	ld hl, Stage3ToStage2Wild
	call ApplyStageChangeWild
	ld hl, Stage1ToStage2Wild
	call ApplyStageChangeWild
	jr .evoScalingDone
.higherThan35		
	ld hl, Stage1ToStage2Wild
	call ApplyStageChangeWild
	ld hl, Stage2ToStage3Wild
	call ApplyStageChangeWild
.evoScalingDone	
	ld a, c 
	ld [wcf91], a
	ld [wEnemyMonSpecies2], a
.evoScalingEnd	
	pop hl
	pop de
	pop bc
	pop af
	ret

ApplyStageChangeWild:
	add hl, bc
	ld a, [hl]
	cp 0
	jr z, .done
	ld c, a
.done		
	ret	
	
; try to initiate a wild pokemon encounter
; returns success in Z
TryDoWildEncounter:
	ld a, [wNPCMovementScriptPointerTableNum]
	and a
	ret nz
	ld a, [wd736]
	and a
	ret nz
	callab IsPlayerStandingOnDoorTileOrWarpTile
	jr nc, .notStandingOnDoorOrWarpTile
.CantEncounter
	ld a, $1
	and a
	ret
.notStandingOnDoorOrWarpTile
	callab IsPlayerJustOutsideMap
	jr z, .CantEncounter
	ld a, [wRepelRemainingSteps]
	and a
	jr z, .next
	dec a
	jr z, .lastRepelStep
	ld [wRepelRemainingSteps], a
.next
; determine if wild pokemon can appear in the half-block we're standing in
; is the bottom right tile (9,9) of the half-block we're standing in a grass/water tile?
	coord hl, 9, 9
	ld c, [hl]
	ld a, [wGrassTile]
	cp c
	ld a, [wGrassRate]
	jr z, .CanEncounter
	ld a, $14 ; in all tilesets with a water tile, this is its id
	cp c
	ld a, [wWaterRate]
	jr z, .CanEncounter
; even if not in grass/water, standing anywhere we can encounter pokemon
; so long as the map is "indoor" and has wild pokemon defined.
; ...as long as it's not Viridian Forest or Safari Zone.
	ld a, [wCurMap]
	cp REDS_HOUSE_1F ; is this an indoor map?
	jr c, .CantEncounter2
	ld a, [wCurMapTileset]
	cp FOREST ; Viridian Forest/Safari Zone
	jr z, .CantEncounter2
	ld a, [wGrassRate]
.CanEncounter
; compare encounter chance with a random number to determine if there will be an encounter
	ld b, a
	ld a, [hRandomAdd]
	cp b
	jr nc, .CantEncounter2
	ld a, [hRandomSub]
	ld b, a
	ld hl, WildMonEncounterSlotChances
.determineEncounterSlot
	ld a, [hli]
	cp b
	jr nc, .gotEncounterSlot
	inc hl
	jr .determineEncounterSlot
.gotEncounterSlot
; determine which wild pokemon (grass or water) can appear in the half-block we're standing in
	ld c, [hl]
	ld hl, wGrassMons
	aCoord 8, 9
	cp $14 ; is the bottom left tile (8,9) of the half-block we're standing in a water tile?
	jr nz, .gotWildEncounterType ; else, it's treated as a grass tile by default
	ld hl, wWaterMons
; since the bottom right tile of a "left shore" half-block is $14 but the bottom left tile is not,
; "left shore" half-blocks (such as the one in the east coast of Cinnabar) load grass encounters.
.gotWildEncounterType
	ld b, 0
	add hl, bc
	ld a, [hli]
	ld [wCurEnemyLVL], a
	call ModifyLevelWild
	ld a, [hl]
	ld [wcf91], a
	ld [wEnemyMonSpecies2], a
	call ModifyEvoStageWild
	
	ld a, [wRepelRemainingSteps]
	and a
	jr z, .willEncounter
	ld a, [wPartyMon1Level]
	ld b, a
	ld a, [wCurEnemyLVL]
	cp b
	jr c, .CantEncounter2 ; repel prevents encounters if the leading party mon's level is higher than the wild mon
	jr .willEncounter
.lastRepelStep
	ld [wRepelRemainingSteps], a
	ld a, TEXT_REPEL_WORE_OFF
	ld [hSpriteIndexOrTextID], a
	call EnableAutoTextBoxDrawing
	call DisplayTextID
.CantEncounter2
	ld a, $1
	and a
	ret
.willEncounter
	xor a
	ret

WildMonEncounterSlotChances:
; There are 10 slots for wild pokemon, and this is the table that defines how common each of
; those 10 slots is. A random number is generated and then the first byte of each pair in this
; table is compared against that random number. If the random number is less than or equal
; to the first byte, then that slot is chosen.  The second byte is double the slot number.
	db $32, $00 ; 51/256 = 19.9% chance of slot 0
	db $65, $02 ; 51/256 = 19.9% chance of slot 1
	db $8C, $04 ; 39/256 = 15.2% chance of slot 2
	db $A5, $06 ; 25/256 =  9.8% chance of slot 3
	db $BE, $08 ; 25/256 =  9.8% chance of slot 4
	db $D7, $0A ; 25/256 =  9.8% chance of slot 5
	db $E4, $0C ; 13/256 =  5.1% chance of slot 6
	db $F1, $0E ; 13/256 =  5.1% chance of slot 7
	db $FC, $10 ; 11/256 =  4.3% chance of slot 8
	db $FF, $12 ;  3/256 =  1.2% chance of slot 9

	
Stage1ToStage2Wild:
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
Stage2ToStage3Wild:
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

Stage2ToStage1Wild:
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

Stage3ToStage2Wild:
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
	
	