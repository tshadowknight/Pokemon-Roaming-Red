SetDefaultNames:
	ld a, [wLetterPrintingDelayFlags]
	push af
	ld a, [wOptions]
	push af
	ld a, [wd732]
	push af
	ld hl, wPlayerName
	ld bc, wBoxDataEnd - wPlayerName
	xor a
	call FillMemory
	ld hl, wSpriteStateData1
	ld bc, $200
	xor a
	call FillMemory
	pop af
	ld [wd732], a
	pop af
	ld [wOptions], a
	pop af
	ld [wLetterPrintingDelayFlags], a
	ld a, [wOptionsInitialized]
	and a
	call z, InitOptions
	ld hl, NintenText
	ld de, wPlayerName
	ld bc, NAME_LENGTH
	call CopyData
	ld hl, SonyText
	ld de, wRivalName
	ld bc, NAME_LENGTH
	jp CopyData

OakSpeech:
	ld a,$FF
	call PlaySound ; stop music
	ld a, BANK(Music_Routes2)
	ld c,a
	ld a, MUSIC_ROUTES2
	call PlayMusic
	call ClearScreen
	call LoadTextBoxTilePatterns
	call SetDefaultNames
	predef InitPlayerData2
	ld hl,wNumBoxItems
	ld a,POTION
	ld [wcf91],a
	ld a,1
	ld [wItemQuantity],a
	call AddItemToInventory  ; give one potion
	
	
	
	xor a
	ld [hTilesetType],a
	ld a,[wd732]
	bit 1,a ; possibly a debug mode bit
	jp nz,.skipChoosingNames
	ld de,ProfOakPic
	lb bc, Bank(ProfOakPic), $00
	call IntroDisplayPicCenteredOrUpperRight
	call FadeInIntroPic
	ld hl,OakSpeechText1
	call PrintText
	call GBFadeOutToWhite
	call ClearScreen
	ld a,NIDORINO
	ld [wd0b5],a
	ld [wcf91],a
	call GetMonHeader
	coord hl, 6, 4
	call LoadFlippedFrontSpriteByMonIndex
	call MovePicLeft
	ld hl,OakSpeechText2
	call PrintText
	call GBFadeOutToWhite
	call ClearScreen
	ld de,RedPicFront
	lb bc, Bank(RedPicFront), $00
	call IntroDisplayPicCenteredOrUpperRight
	call MovePicLeft
	ld hl,IntroducePlayerText
	call PrintText
	call ChoosePlayerName
	call GBFadeOutToWhite
	call ClearScreen
	ld de,Rival1Pic
	lb bc, Bank(Rival1Pic), $00
	call IntroDisplayPicCenteredOrUpperRight
	call FadeInIntroPic
	ld hl,IntroduceRivalText
	call PrintText
	call ChooseRivalName
.skipChoosingNames
	call GBFadeOutToWhite
	call ClearScreen
	ld de,RedPicFront
	lb bc, Bank(RedPicFront), $00
	call IntroDisplayPicCenteredOrUpperRight
	call GBFadeInFromWhite
	ld a,[wd72d]
	and a
	jr nz,.next	
	ld hl, AskStartLocationText
	call PrintText
	call ChooseStartDestination
	call GBFadeOutToWhite
	call ClearScreen
	ld de,ProfOakPic
	lb bc, Bank(ProfOakPic), $00
	call IntroDisplayPicCenteredOrUpperRight
	call GBFadeInFromWhite
	ld hl, AskStarterText
	call PrintText
	
	call ChooseStarter
	push af
	push bc
	push hl	
	ld a, [wUnusedD08A]
	cp 0
	jp nz, .noRandom
	call Random
	rra
	and %01111111
	ld hl, RandomStarterLookupTable
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]		
.noRandom	
	ld hl, StarterPokemonIdxs
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	ld b, a
	ld a, 10
	ld c, a	
	call GivePokemon
	pop af
	pop bc
	pop hl
	
	call GBFadeOutToWhite
	call ClearScreen
	ld de,RedPicFront
	lb bc, Bank(RedPicFront), $00
	call IntroDisplayPicCenteredOrUpperRight
	call GBFadeInFromWhite
	ld hl,OakSpeechText3
	call PrintText
	
	
.next
	ld a,[H_LOADEDROMBANK]
	push af
	ld a,SFX_SHRINK
	call PlaySound
	pop af
	ld [H_LOADEDROMBANK],a
	ld [MBC1RomBank],a
	ld c,4
	call DelayFrames
	ld de,RedSprite
	ld hl,vSprites
	lb bc, BANK(RedSprite), $0C
	call CopyVideoData
	ld de,ShrinkPic1
	lb bc, BANK(ShrinkPic1), $00
	call IntroDisplayPicCenteredOrUpperRight
	ld c,4
	call DelayFrames
	ld de,ShrinkPic2
	lb bc, BANK(ShrinkPic2), $00
	call IntroDisplayPicCenteredOrUpperRight
	call ResetPlayerSpriteData
	ld a,[H_LOADEDROMBANK]
	push af
	ld a, BANK(Music_PalletTown)
	ld [wAudioROMBank],a
	ld [wAudioSavedROMBank],a
	ld a, 10
	ld [wAudioFadeOutControl],a
	ld a,$FF
	ld [wNewSoundID],a
	call PlaySound ; stop music
	pop af
	ld [H_LOADEDROMBANK],a
	ld [MBC1RomBank],a
	ld c,20
	call DelayFrames
	coord hl, 6, 5
	ld b,7
	ld c,7
	call ClearScreenArea
	call LoadTextBoxTilePatterns
	ld a,1
	ld [wUpdateSpritesEnabled],a
	
	ld a,[wWhichTownMapLocation]
	ld hl, MapIdxMapping
	ld b, 0
	ld c, a
	add hl, bc	
	ld a, [hl]
	ld [wLastBlackoutMap], a
	ld [wDestinationMap], a 
	call SpecialWarpIn
	SetEvent EVENT_GOT_POKEDEX
	ld a, HS_LYING_OLD_MAN
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_OLD_MAN
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld a, HS_GYM_GUY
	ld [wMissableObjectIndex], a
	predef HideObject
	ld c,50
	call DelayFrames
	call GBFadeOutToWhite
	jp ClearScreen
OakSpeechText1:
	TX_FAR _OakSpeechText1
	db "@"
OakSpeechText2:
	TX_FAR _OakSpeechText2A
	TX_CRY_NIDORINA
	TX_FAR _OakSpeechText2B
	db "@"
IntroducePlayerText:
	TX_FAR _IntroducePlayerText
	db "@"
IntroduceRivalText:
	TX_FAR _IntroduceRivalText
	db "@"
OakSpeechText3:
	TX_FAR _OakSpeechText3
	db "@"
AskStartLocationText:
	TX_FAR _AskStartLocationText
	db "@"	
AskStarterText:
	TX_FAR _AskStarterText
	db "@"
ConfirmStarterText:
	TX_FAR _ConfirmStarterText
	db "@"			

FadeInIntroPic:
	ld hl,IntroFadePalettes
	ld b,6
.next
	ld a,[hli]
	ld [rBGP],a
	ld c,10
	call DelayFrames
	dec b
	jr nz,.next
	ret

IntroFadePalettes:
	db %01010100
	db %10101000
	db %11111100
	db %11111000
	db %11110100
	db %11100100

MovePicLeft:
	ld a,119
	ld [rWX],a
	call DelayFrame

	ld a,%11100100
	ld [rBGP],a
.next
	call DelayFrame
	ld a,[rWX]
	sub 8
	cp $FF
	ret z
	ld [rWX],a
	jr .next

DisplayPicCenteredOrUpperRight:
	call GetPredefRegisters
IntroDisplayPicCenteredOrUpperRight:
; b = bank
; de = address of compressed pic
; c: 0 = centred, non-zero = upper-right
	push bc
	ld a,b
	call UncompressSpriteFromDE
	ld hl,sSpriteBuffer1
	ld de,sSpriteBuffer0
	ld bc,$310
	call CopyData
	ld de,vFrontPic
	call InterlaceMergeSpriteBuffers
	pop bc
	ld a,c
	and a
	coord hl, 15, 1
	jr nz,.next
	coord hl, 6, 4
.next
	xor a
	ld [hStartTileID],a
	predef_jump CopyUncompressedPicToTilemap
	
MapIdxMapping:
	db 0
	db 1
	db 2
	db 3
	db 5
	db 4
	db 6
	db 10
	db 7
	db 8

RANDOMText:
	db "RANDOM@"

SelectionInsctrutions1:
	db "Choose: Left/Right@"
SelectionInsctrutions2:
	db "Confirm: A@"	
; lets the player choose a starter pokemon from the list defined in	StarterPokemonIdxs
ChooseStarter:
	push af
	push bc
	push de
	push hl
	call ClearScreen	
	coord hl, 0, 0
	ld b, 8
	ld c, 18
	call TextBoxBorder
	ld a, 0
	ld [wUnusedD08A], a ; current starter selection
.drawSelectionScreen
	
	coord hl, 12, 1
	ld b, 7
	ld c, 7
	call ClearScreenArea
.drawSelectionScreenNoRefreshSprite		
	coord hl, 1, 1
	ld b, 6
	ld c, 11
	call ClearScreenArea
	coord hl, 0, 10
	ld b, 8
	ld c, 20
	call ClearScreenArea	
	
	push af
	push bc
	push de
	ld de, SelectionInsctrutions1
	ld b, $0
	coord hl, 1, 10
	call PlaceString	
	ld de, SelectionInsctrutions2
	ld b, $0
	coord hl, 1, 11
	call PlaceString
	pop de
	pop bc	
	pop af

	ld a, [wUnusedD08A]
	cp 0
	jp z, .showRANDOMText
	ld hl, StarterPokemonIdxs
	ld c, a
	add hl, bc
	ld a, [hl]
	ld c, a
	push af
	push bc
	call DrawSelectionPokemonStats		
	pop bc	
	pop af
	jp .drawSelectionScreenDone
.showRANDOMText
	push af
	push bc
	push de
	ld de, RANDOMText
	ld b, $0
	coord hl, 1, 1
	call PlaceString	
	pop de
	pop bc	
	pop af
.drawSelectionScreenDone	
	ld a, 0
	ld e, a 
	ld d, a
.inputLoopSelection		
;count VBLANKS	
	ld a, [H_VBLANKOCCURRED]
	and a
	jr nz, .noVBLANK
	ld a, e	
	inc a
	ld e, a
	ld a, 1
	ld [H_VBLANKOCCURRED], a 
.noVBLANK:	
	ld a, e	
	cp 30 ; delay drawing the pokemon picture x frames to allow fast scrolling through the list
	jp c, .doneDrawingPic
	ld a, d 
	cp 1 ; d set by DrawSelectionPokemonPic when a pic has been drawn, avoid drawing the pic more than once
	jp z, .doneDrawingPic
	ld a, [wUnusedD08A]
	cp 0
	jp z, .doneDrawingPic ; no pic for random selection
	ld a, c
	call DrawSelectionPokemonPic
	call PlayCry ; play pokemon cry
.doneDrawingPic:		
	; process inputs
	push de
	call JoypadLowSensitivity
	pop de
	ld a, [hJoy5]
	ld b, a
	and A_BUTTON | B_BUTTON | D_LEFT | D_RIGHT
	jr z, .inputLoopSelection
	bit 5, b ; Left pressed?
	jp nz, .pressedLeftInStarterSelect
	bit 4, b ; Right pressed?
	jp nz, .pressedRightInStarterSelect
	bit 0, b 
	jp nz, .starterSelectionMade
	jp .inputLoopSelection
.pressedRightInStarterSelect
	ld a, [wUnusedD08A]
	add 1
	cp 75
	jp nz, .noOverflow
	ld a, 0
.noOverflow	
	ld [wUnusedD08A], a	
	jp .drawSelectionScreen
.pressedLeftInStarterSelect
	ld a, [wUnusedD08A]
	sub 1
	jp nc, .noUnderflow
	ld a, 74
.noUnderflow	
	ld [wUnusedD08A], a	
	jp .drawSelectionScreen	
.starterSelectionMade	
	ld hl, ConfirmStarterText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .drawSelectionScreenNoRefreshSprite
	pop hl
	pop de 
	pop bc
	pop af
ret	

DrawSelectionPokemonPic:
	push af
	push bc	
	push hl	
	ld [wcf91], a
	ld [wd0b5], a
	ld [wBattleMonSpecies2], a
	ld [wWholeScreenPaletteMonSpecies], a
	coord hl, 12, 1
	call GetMonHeader
	call LoadFrontSpriteByMonIndex
	ld a, 1
	ld d, a
	pop hl
	pop bc
	pop af
	ret
	
DrawSelectionPokemonStats:
	push af
	push bc
	push de
	push hl
	ld [wcf91], a
	ld [wd0b5], a
	ld [wBattleMonSpecies2], a
	ld [wWholeScreenPaletteMonSpecies], a
	call GetMonHeader
	ld a, [wMonHIndex]
	ld [wd11e], a
	call GetMonName
	ld b, $0
	coord hl, 1, 1
	call PlaceString
	
	ld a, [wMonHType1]
	ld hl, TypeNamesSelector
	
	ld b, 0
	add a
	ld c, a 
	add hl, bc

	ld a, [hli]
	ld e, a
	ld d, [hl]
	
	ld b, $0
	coord hl, 1, 3
	call PlaceString
	
	ld a, [wMonHType1]
	ld b, a
	ld a, [wMonHType2]
	cp b
	jp z, .statsDone
	ld hl, TypeNamesSelector
	
	ld b, 0
	add a
	ld c, a 
	add hl, bc

	ld a, [hli]
	ld e, a
	ld d, [hl]
	
	ld b, $0
	coord hl, 1, 4
	call PlaceString
.statsDone:	
	pop hl
	pop de 
	pop bc
	pop af
	ret 
	
TypeNamesSelector:
	dw .Normal
	dw .Fighting
	dw .Flying
	dw .Poison
	dw .Ground
	dw .Rock
	dw .Bird
	dw .Bug
	dw .Ghost

	dw .Normal
	dw .Normal
	dw .Normal
	dw .Normal
	dw .Normal
	dw .Normal
	dw .Normal
	dw .Normal
	dw .Normal
	dw .Normal
	dw .Normal

	dw .Fire
	dw .Water
	dw .Grass
	dw .Electric
	dw .Psychic
	dw .Ice
	dw .Dragon

.Normal:   db "NORMAL@"
.Fighting: db "FIGHTING@"
.Flying:   db "FLYING@"
.Poison:   db "POISON@"
.Fire:     db "FIRE@"
.Water:    db "WATER@"
.Grass:    db "GRASS@"
.Electric: db "ELECTRIC@"
.Psychic:  db "PSYCHIC@"
.Ice:      db "ICE@"
.Ground:   db "GROUND@"
.Rock:     db "ROCK@"
.Bird:     db "BIRD@"
.Bug:      db "BUG@"
.Ghost:    db "GHOST@"
.Dragon:   db "DRAGON@"
	
StarterPokemonIdxs:
	db 0
	db 153
	db 176
	db 177
	db 123
	db 112
	db 36
	db 165
	db 5
	db 108
	db 84
	db 96
	db 15
	db 3
	db 4
	db 82
	db 100
	db 107
	db 185
	db 109
	db 65
	db 59
	db 77
	db 47
	db 57
	db 33
	db 71
	db 148
	db 106
	db 188
	db 24
	db 169
	db 163
	db 37
	db 173
	db 64
	db 70
	db 58
	db 13
	db 23
	db 25
	db 34
	db 48
	db 78
	db 6
	db 12
	db 17
	db 43
	db 44
	db 11
	db 55
	db 18
	db 40
	db 30
	db 2
	db 92
	db 157
	db 27
	db 42
	db 26
	db 72
	db 53
	db 51
	db 29
	db 60
	db 133
	db 19
	db 76
	db 102
	db 170
	db 98
	db 90
	db 171
	db 132
	db 88
StarterPokemonIdxs_end:		

; can't be bothered to implement a module right now
RandomStarterLookupTable:
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
	db 31
	db 32
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
	db 50
	db 51
	db 52
	db 53
	db 54
	db 55
	db 56
	db 57
	db 58
	db 59
	db 60
	db 61
	db 62
	db 63
	db 64
	db 65
	db 66
	db 67
	db 68
	db 69
	db 70
	db 71
	db 72
	db 73
	db 74
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
	db 31
	db 32
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
	db 50
	db 51
	db 52
	db 53
