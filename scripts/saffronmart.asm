SaffronMartScript:
	jp EnableAutoTextBoxDrawing

SaffronMartTextPointers:
	dw SharedMartText
	dw SaffronMartText2
	dw SaffronMartText3

SaffronMartText2:
	TX_FAR _SaffronMartText2
	db "@"

SaffronMartText3:
	TX_FAR _SaffronMartText3
	db "@"
