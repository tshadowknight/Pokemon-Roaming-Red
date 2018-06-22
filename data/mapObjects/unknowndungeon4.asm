UnknownDungeon4Object:
	db $7d ; border block

	db 1 ; warps
	db 8, 10, 3, ROUTE_4

	db $0 ; signs

	db $0 ; objects	

	; warp-to
	EVENT_DISP 12, 16, 16	
	EVENT_DISP 12, 8, 10