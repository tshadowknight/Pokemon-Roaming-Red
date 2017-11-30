ModifyLevelWild:
	push af
	push bc
	push de
	push hl
	Call DetermineReferenceLevel
	ld a, [wReferenceLevel]
	ld d, a
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

RandomizeWildMonLocal:
	ld hl, .doneRandomizingMon	
	push hl
	ld a, BANK(.doneRandomizingMon)	
	push af	
	ld hl, RandomizeWildMon
	push hl
	ld a, BANK(RandomizeWildMon)
	push af
	jp BankSwitchCall
.doneRandomizingMon	
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
	jp z, .lastRepelStep
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
	jp c, .CantEncounter2
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
	xor a 
	ld c, a
.determineEncounterSlot	
	ld a, [hli]
	cp b
	jr nc, .gotEncounterSlot
	ld a, c 
	add 1
	ld c, a
	inc hl
	jr .determineEncounterSlot
.gotEncounterSlot
; determine which wild pokemon (grass or water) can appear in the half-block we're standing in
	ld a, c 
	ld [wUnusedC000], a
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
	; call RandomizeWildMonLocal
	ld a, [wcf91]
	ld [wEnemyMonSpecies2], a
	call Random
	and 1
	jr nz, .noEvoStageModification	
	ld hl, .doneModifyingEvoStage	
	push hl
	ld a, BANK(.doneModifyingEvoStage)	
	push af	
	ld hl, ModifyEvoStage
	push hl
	ld a, BANK(ModifyEvoStage)
	push af
	jp BankSwitchCall
.doneModifyingEvoStage	
	ld a, [wcf91]
	ld [wEnemyMonSpecies2], a
.noEvoStageModification	
	ld a, [wRepelRemainingSteps]
	and a
	jr nz, .CantEncounter2 ; due to level scaling repels were made ineffective, repels now do not have the level check
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

	