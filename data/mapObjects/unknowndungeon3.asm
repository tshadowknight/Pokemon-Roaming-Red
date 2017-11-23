UnknownDungeon3Object:
	db $7d ; border block
	db 6
	db $6, $3, $8, UNKNOWN_DUNGEON_1
	db 4, 10, $0, 105
	db 6, 6, $0, 105
	db 11, 1, $0, 105
	db 16, 4, $0, 105
	db 15, 7, $0, 105

	
	db $0 ; signs

	db $3 ; objects
	object SPRITE_SLOWBRO, $1b, $d, STAY, DOWN, $1, MEWTWO, 70
	object SPRITE_BALL, $10, $9, STAY, NONE, $2, ULTRA_BALL
	object SPRITE_BALL, $12, $1, STAY, NONE, $3, MAX_REVIVE

	; warp-to
	EVENT_DISP UNKNOWN_DUNGEON_3_WIDTH, $6, $3 ; UNKNOWN_DUNGEON_1
