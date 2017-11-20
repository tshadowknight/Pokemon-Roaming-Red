DiglettsCaveEntranceCinnabarObject:
	db $7d ; border block

	db $3 ; warps
	db $7, $2, $5, CINNABAR_ISLAND
	db $7, $3, $5, CINNABAR_ISLAND
	db $4, $4, $1, 75

	db $0 ; signs

	db $0 ; objects

	; warp-to
	EVENT_DISP DIGLETTS_CAVE_ENTRANCE_WIDTH, $7, $2
	EVENT_DISP DIGLETTS_CAVE_ENTRANCE_WIDTH, $7, $3
	EVENT_DISP DIGLETTS_CAVE_ENTRANCE_WIDTH, $4, $4 ; DIGLETTS_CAVE
