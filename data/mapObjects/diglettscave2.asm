DiglettsCave2Object:
	db $19 ; border block

	db $2 ; warps
	db 4, 18, 3, DIGLETTS_CAVE_EXIT
	db 50, 6, 5, CINNABAR_ISLAND

	db $0 ; signs

	db $0 ; objects

	; warp-to
	EVENT_DISP 12, 4, 18 ; Pewter Side Entrance
	EVENT_DISP 12, 50, 6 ; Cinnbar Side Entrance
