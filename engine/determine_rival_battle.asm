DetermineRivalClassAndRoster::
	ld b, 0
	CheckEvent EVENT_BEAT_CERULEAN_RIVAL	
	jr z, .ceruleanRivalNotBeaten
	inc b
.ceruleanRivalNotBeaten
	CheckEvent EVENT_BEAT_POKEMON_TOWER_RIVAL	
	jr z, .towerRivalNotBeaten
	inc b
.towerRivalNotBeaten
	CheckEvent EVENT_BEAT_ROUTE22_RIVAL_2ND_BATTLE	
	jr z, .route22Rival2NotBeaten
	inc b
.route22Rival2NotBeaten
	CheckEvent EVENT_BEAT_SILPH_CO_RIVAL	
	jr z, .silphRivalNotBeaten
	inc b
.silphRivalNotBeaten
	CheckEvent EVENT_BEAT_SSANNE_RIVAL	
	jr z, .SSAnneRivalNotBeaten
	inc b
.SSAnneRivalNotBeaten
	ld a, b
	inc a
	ld [wTrainerNo], a
	cp 1
	jr z, .firstEncounter
	ld a, OPP_SONY2
	ld [wCurOpponent], a
	jr .rivalDone
.firstEncounter
	ld a, OPP_SONY1
	ld [wCurOpponent], a
.rivalDone		
	ret	