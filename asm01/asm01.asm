    .area   CODE (ABS)
	.org    #0xC000			    ; 開始アドレス

	LD HL,#0x1AF8		        ; HL=&H1AF8(処理開始VRAMアドレス)
	LD BC,#0x17			        ; BC=行数カウンタ &H17(23)回

    ; 外部ループ処理 開始
    ; 全行に対しての処理を行う
OUTLOOP:
	PUSH BC				        ; BCをスタックに退避
	LD BC,#0x19			        ; BC=桁数カウンタ &H19(25)回

    ; 内部ループ処理 開始
    ; 1行に対しての処理を行う
INLOOP:
	; ■1行上のVRAMアドレスのデータを読む
	PUSH BC	                    ; BCをスタックに退避
	PUSH HL	                    ; HLをスタックに退避

	LD BC,#0x20	                ; BC=&20(32)
	SBC HL,BC	                ; HL=HL-BC
	CALL #0x004A                ; BIOS RDVRM呼び出し
                                ; - HL : 読み取るアドレス
                                ; - A  : 読み取ったデータ

	POP HL	                    ; HLをスタックから復帰
	POP BC		                ; BCをスタックから復帰

	; ■現在のVRAMアドレスにデータを書き込む
	CALL #0x004D                ; BIOS WRTVRM呼び出し
    		                    ; - HL : 書き込み先のVRAMアドレス
                                ; - A  : 書き込むデータ

	; ■ひとつ左のアドレスに移動
	DEC HL	                    ; HL=HL-1

	; ■桁数カウンタ減算
	DEC BC				        ; BC=BC-1
    LD A,B		        		; A=B
    OR C	        			; A=A OR C
	JR NZ,INLOOP	        	; NZ(ゼロでない)なら、INLOOPラベルにジャンプ

    ; 内部ループ処理 終了

	; ■１行上の処理開始VRAMアドレスに遷移させる
    ; 画面右に7文字分の余白を設けるため、VRAMアドレスから7を減算する
	LD BC,#0x07	    	    	; BC=&H07(7)
	SBC HL,BC	        		; HL=HL-BC

	; ■行数カウンタ減算
	POP BC		        		; BCをスタックから復帰
	DEC BC	        			; BC=BC-1
    LD A,B	        			; A=B
    OR C        				; A=A OR C
	JR NZ,OUTLOOP	        	; NZ(ゼロでない)なら、OUTLOOPラベルにジャンプ

    ; 外部ループ処理 終了
	LD HL,#0x1800	    		; HL=&H1800(処理開始VRAMアドレス)
	LD BC,#0x19			        ; BC=桁数カウンタ &H19(25)回

    ; ループ処理 開始
    ; 1行目のクリア処理を行う
ENDLOOP:
	; ■現在のVRAMアドレスにデータを書き込む
	LD A,#0x20	        		; A=&20(" ")
	CALL #0x004D	        	; BIOS WRTVRM呼び出し
    		        			; - HL : 書き込み先のVRAMアドレス
                                ; - A  : 書き込むデータ

	; ■ひとつ右のアドレスに移動
	INC HL				        ; HL=HL+1

	; ■桁数カウンタ減算
	DEC BC				        ; BC=BC-1
    LD A,B			        	; A=B
    OR C		        		; A=A OR C
	JR NZ,ENDLOOP       		; NZ(ゼロでない)なら、ENDLOOPラベルにジャンプ
    
	RET					        ; BASICに戻る
