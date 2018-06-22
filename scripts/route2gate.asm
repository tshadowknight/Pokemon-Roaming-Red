Route2GateScript:
	jp EnableAutoTextBoxDrawing

Route2GateTextPointers:
	dw Route2GateText1
	dw Route2GateText2

Route2GateText1:
	TX_ASM
	CheckEvent EVENT_GOT_HM05
	jr nz, .HM05Owned
	ld hl, Route2GateAideText1
	call PrintText
	ld a, 6 ; badges needed
	ld b, a 
	ld a, [wObtainedBadges]
	ld c, a
	ld a, 0
	ld e, a	
	ld d, 0

.countBadges
	rr c
	jp nc, .noBadge
	ld a, d	
	inc a 
	ld d, a
.noBadge
	ld a, e
	inc a
	cp 8
	ld e, a 
	jr nz, .countBadges
	ld a, d 
	cp b
	jr c, .notEnoughBadges
	lb bc, HM_05, 1
	call GiveItem
	jr nc, .BagFull
	ld hl, Route2AideGiveHMText
	call PrintText
	ld hl, Route2GateAideText4
	call PrintText
	SetEvent EVENT_GOT_HM05
	jr .end
.BagFull
	ld hl, Route2GateAideText5
	call PrintText
	jr .end
.notEnoughBadges	
	ld hl, Route2GateAideText3
	call PrintText
	jr .end
.HM05Owned
	ld hl, Route2GateText_5d616
	call PrintText
.end
	jp TextScriptEnd
	
Route2GateAideText1:
	TX_FAR _Route2GateAideText1
	db "@"
	

Route2GateAideText3:
	TX_FAR _Route2GateAideText3
	db "@"

Route2GateAideText4:
	TX_FAR _Route2GateAideText4
	db "@"		
	
Route2GateAideText5:
	TX_FAR _Route2GateAideText5
	db "@"		
	
	
Route2GateText_5d616:
	TX_FAR _Route2GateText_5d616
	db "@"

Route2GateText2:
	TX_FAR _Route2GateText2
	db "@"

Route2AideGiveHMText:
	TX_FAR _Route2AideGiveHMText1
	TX_SFX_KEY_ITEM
	db "@"	
