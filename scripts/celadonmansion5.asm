CeladonMansion5Script:
	jp EnableAutoTextBoxDrawing

CeladonMansion5TextPointers:
	dw CeladonMansion5Text1
	dw CeladonMansion5Text2

CeladonMansion5Text1:
	TX_FAR _CeladonMansion5Text1
	db "@"

CeladonMansion5Text2:
	TX_ASM
	ld a, EEVEE
	ld [wcf91], a
	ld [wUnusedCD3D], a
	call RandomizeMon
	ld a, [wcf91]
	ld b, a
	Call DetermineReferenceLevel
	ld a, [wReferenceLevel]
	ld c, a
	call GivePokemon
	jr nc, .asm_24365
	ld a, HS_CELADON_MANSION_5_GIFT
	ld [wMissableObjectIndex], a
	predef HideObject
.asm_24365
	jp TextScriptEnd
