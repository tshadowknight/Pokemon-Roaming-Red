UnknownDungeon4_h:
	db CAVERN ; tileset
	db 12, 12 ; dimensions (y, x)
	dw UnknownDungeon4Blocks, UnknownDungeon4TextPointers, UnknownDungeon4Script ; blocks, texts, scripts
	db $00 ; connections
	dw UnknownDungeon4Object ; objects
