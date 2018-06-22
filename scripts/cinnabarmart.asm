CinnabarMartScript:
	jp EnableAutoTextBoxDrawing

CinnabarMartTextPointers:
	dw SharedMartText
	dw CinnabarMartText2
	dw CinnabarMartText3

CinnabarMartText2:
	TX_FAR _CinnabarMartText2
	db "@"

CinnabarMartText3:
	TX_FAR _CinnabarMartText3
	db "@"
