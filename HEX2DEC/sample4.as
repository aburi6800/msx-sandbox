        .area	CODE (ABS)
; IN :B  10進化したい16進（0～99）
; OUT:A  内部10進化した値
; BRK:A,B,C
DIV10::
	LD	A, B
	AND	#0x78
	RRCA
	RRCA
	RRCA
	DAA
	ADD	A
	DAA
	ADD	A
	DAA
	ADD	A
	DAA
	LD	C, A
	LD	A, B
	AND	#0x07
	ADD	C
	DAA
	RET
