DiglettsCave2_h:
	db CAVERN ; tileset
	db 27, 12 ; dimensions (y, x)
	dw DiglettsCave2Blocks, DiglettsCaveTextPointers, DiglettsCaveScript ; blocks, texts, scripts
	db $00 ; connections
	dw DiglettsCave2Object ; objects
