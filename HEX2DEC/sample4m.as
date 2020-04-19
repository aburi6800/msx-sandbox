	.globl	DIV10
        .area	CODE (ABS)
        .org	#0xD000                 ; 開始アドレス

MAIN::
	LD	HL, (#0xD100)
	LD	B, (HL)
	CALL	DIV10
	LD	(#0xD101), A
	RET
