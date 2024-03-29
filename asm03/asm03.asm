; ====================================================================================================
; asm03.asm
; ・COLOR 15,1,1に該当する処理を実行
; ・SCREEN 1,2,0に該当する処理を実行（スクリーンモード1、スプライトキャラクター16x16、ファンクションキー表示off）
; ・WIDTH32に該当する処理を実行
; ・16x16ドットのスプライトパターンを複数定義
; ・CTRL+STOPによる停止
; ・垂直帰線同期処理
; ・アニメーションするスプライトパターンをテーブル定義して切替表示
; ====================================================================================================
SECTION code_user
PUBLIC _main

; ====================================================================================================
; メイン
; ====================================================================================================
_main:

    CALL    INIT                 ; 初期設定

MAINLOOP:
	; ■ちょっとだけ待つ
    							; ウェイトカウンタの値を減算
	LD A,(WAIT_CNT)				; - AレジスタにWAIT_CNTの値をロード
	DEC A						; - Aレジスタから1引く
	LD (WAIT_CNT),A				; - WAIT_CNTにAレジスタの値を保存

								; ウェイトカウンタの値を判定
	JR NZ,VSYNC					; - Aレジスタの値がゼロじゃなかったらVSYNCにジャンプ

								; ウェイトカウンタの値をリセット
	LD A,10						; - Aレジスタに10をロード
	LD (WAIT_CNT),A					; - WAIT_CNTにAレジスタの値を保存

	; ■キャラクターのアニメーション
    							; 参照先のアニメーションパターンテーブルのアドレスを求める
    LD HL,(PTN_ADDR)			; - HLレジスタにアニメーションパターンテーブルの参照アドレスの値をロード
    INC HL						; - HL=HL+1(ひとつ次のデータのアドレスへ)

								; 参照先のアニメーションパターンテーブルの値をロードする
	LD A,(HL)					; - AレジスタにHLレジスタが示すアドレスの値をロード
    OR 0						; - 0かどうか
    JR NZ,LOOP1					; - 0でなければL1にジャンプ

								; ロードした値が0の時はアニメーションパターンテーブルの先頭を参照先にする
    LD HL,PTN_TBL				; - HLレジスタにアニメーションパターンテーブルの先頭アドレスの値をロード
	LD A,(HL)					; - AレジスタにHLレジスタが示すアドレス(＝アニメーションパターンテーブルの最初のアドレス)の値をロードしなおす
LOOP1:
    LD (PTN_ADDR),HL			; アニメーションパターンテーブルの参照アドレスにHLレジスタの値を設定

	; ■スプライトパターン番号を求める
	LD A,(HL)					; AレジスタにHLレジスタが示すアドレス（＝アニメーションパターンテーブルの参照先アドレス）の値をロード
	DEC A						; A=A-1（パターンテーブルの値はスプライトパターン番号+1が設定されているため）
    							; Aレジスタの値を4倍する
	SLA A						; - A=A*2
	SLA A						; - A=A*2
	LD (SPR_ATR_DATA+2),A		; Aレジスタの値をスプライトアトリビュートエリアのスプライトパターン番号に設定

	; ■スプライトアトリビュートエリアをVRAMにブロック転送
	LD HL,SPR_ATR_DATA			; HLレジスタにスプライトアトリビュートデータの先頭アドレスを設定
    LD DE,SPR_ATR_ADDR			; DEレジスタにスプライトアトリビュートエリアの先頭アドレスを設定
    LD BC,4*1					; BCレジスタにアトリビュートデータのサイズを指定
    CALL LDIRVM					; BIOS VRAMブロック転送

VSYNC:
	; ■垂直帰線待ち
	HALT

	JR MAINLOOP


; ====================================================================================================
; 初期設定
; ====================================================================================================
INIT:
    ; ------------------------------------------------------------------------------------------------
    ; 画面設定
    ; ------------------------------------------------------------------------------------------------
    ; COLOR 15,1,1
    LD A,15                     ; Aレジスタに文字色をロード 
    LD (FORCLR),A               ; Aレジスタの値をワークエリアに格納
    LD A,1                      ; Aレジスタに全景色をロード
    LD (BAKCLR),A               ; Aレジスタの値をワークエリアに格納
;    LD A,1                      ; Aレジスタに背景色をロード
    LD (BDRCLR),A               ; Aレジスタの値をワークエリアに格納

    ; SCREEN 1,2,0
    LD A,(REG1SAV)              ; AレジスタにVDPコントロールレジスタ1の値をロード
    OR 2                        ; ビット2を立てる(=スプライトモードを16x16に設定)
    LD (REG1SAV),A              ; Aレジスタの値をVDPコントロールレジスタ1のワークエリアに格納
    LD A,1                      ; Aレジスタにスクリーンモードの値を設定
    CALL CHGMOD                 ; BIOS スクリーンモード変更
    LD A,0                      ; Aレジスタにキークリックスイッチの値(0=OFF)をロード
    LD (CLIKSW),A               ; Aレジスタの値をワークエリアに格納

    ; WIDTH 32
    LD A,32                     ; AレジスタにWIDTHの値を設定
    LD (LINL32),A               ; Aレジスタの値をワークエリアに格納

    ; KEY OFF
    CALL ERAFNC                 ; BIOS ファンクションキー非表示

    ; ------------------------------------------------------------------------------------------------
    ; ワークエリア初期化
    ; ------------------------------------------------------------------------------------------------
	LD HL,PTN_TBL				; アニメーションパターンテーブル参照先アドレス初期化
    LD (PTN_ADDR),HL

    LD A,10
    LD IX,WAIT_CNT
    LD (IX),A

    LD IX, SPR_ATR_INIT_DATA
    LD HL, SPR_ATR_DATA

    LD A,(IX)
    LD (HL),A
    INC HL
    LD A,(IX+1)
    LD (HL),A
    INC HL
    LD A,(IX+2)
    LD (HL),A
    INC HL
    LD A,(IX+3)
    LD (HL),A

    ; ------------------------------------------------------------------------------------------------
    ; スプライト定義
    ; ------------------------------------------------------------------------------------------------
	CALL SET_SPRPTN				; スプライトパターン定義
	CALL SET_SPRATR				; スプライトアトリビュート初期化

	RET


; ====================================================================================================
; スプライトパターン定義
; ====================================================================================================
SET_SPRPTN:
	LD HL,SPR_PTN_DATA			; HLレジスタにスプライトデータの先頭アドレスを設定
    LD DE,SPR_PTN_ADDR			; DEレジスタにスプライトパターンジェネレータの先頭アドレスを設定
	LD BC,8*4*3					; BCレジスタにスプライトデータのサイズを指定
    CALL LDIRVM					; BIOS VRAMブロック転送

	RET


; ====================================================================================================
; スプライトアトリビュート定義
; ====================================================================================================
SET_SPRATR:
	LD HL,SPR_ATR_DATA			; HLレジスタにスプライトアトリビュートデータの先頭アドレスを設定
    LD DE,SPR_ATR_ADDR			; DEレジスタにスプライトアトリビュートエリアの先頭アドレスを設定
    LD BC,4*1					; BCレジスタにアトリビュートデータのサイズを指定
    CALL LDIRVM					; BIOS VRAMブロック転送

    RET


; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================
SECTION rodata_user

; BIOSアドレス定義
LDIRVM:			    EQU	$005C	; BIOS:VRAMブロック転送
CHGMOD:             EQU $005F   ; BIOS:スクリーンモード変更
ERAFNC:             EQU $00CC   ; BIOS:ファンクションキー非表示

; システムワークエリアアドレス定義
REG0SAV:            EQU $F3DF   ; VDPコントロールレジスタ0
REG1SAV:            EQU $F3E0   ; VDPコントロールレジスタ1
FORCLR:             EQU $F3E9   ; 前景色
BAKCLR:             EQU $F3EA   ; 背景色
BDRCLR:             EQU $F3EB   ; 周辺色
LINL32:             EQU $F3AF   ; WIDTH値
CLIKSW:             EQU $F3DB   ; キークリックスイッチ(0:OFF,0以外:ON)

; VRAMワークエリアアドレス定義
SPR_PTN_ADDR:	    EQU $3800	; VRAM:スプライトパターンジェネレータの先頭アドレス
SPR_ATR_ADDR:	    EQU	$1B00	; VRAM:スプライトアトリビュートエリアの先頭アドレス

; アニメーションパターンテーブル
PTN_TBL:
	DB 1,2,3,2,0

; スプライトパターンデータ
SPR_PTN_DATA:
	; 00：プレイヤーパターン1
	DB $0F,$1F,$1D,$1D,$1D,$FF,$E7,$E8
	DB $1F,$7F,$3F,$1F,$0F,$0F,$3E,$3E
	DB $F0,$F8,$B8,$B8,$B8,$F8,$E0,$10
	DB $F0,$FC,$FF,$C3,$B8,$B8,$38,$00
	; 01：プレイヤーパターン2
	DB $0F,$1F,$1D,$1D,$1D,$1F,$07,$08
	DB $1F,$3F,$FF,$DF,$0F,$0F,$3E,$3E
	DB $F0,$F8,$B8,$B8,$B8,$F8,$E0,$10
	DB $F0,$FC,$FF,$FB,$F0,$F0,$7C,$7C
	; 02：プレイヤーパターン3
	DB $0F,$1F,$1D,$1D,$1D,$1F,$07,$08
	DB $0F,$3F,$FF,$C3,$1D,$1D,$1C,$00
	DB $F0,$F8,$B8,$B8,$B8,$FF,$E7,$17
	DB $F8,$FE,$FC,$F8,$F0,$F0,$7C,$7C

; スプライトアトリビュートデータ初期値
; 1キャラクター4バイト(Y座標,X座標,パターンNo,カラーコード)
SPR_ATR_INIT_DATA:
	DB  90,120,  2, 15				; 00:プレイヤー


; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================
SECTION bss_user

; ウェイトカウンター
WAIT_CNT:
	defs 1

; アニメーションパターン参照アドレス
PTN_ADDR:
	defs 2

; スプライトアトリビュートワークエリア
; 1キャラクター4バイト(Y座標,X座標,パターンNo,カラーコード)
SPR_ATR_DATA:
	defs 4


; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでramに値が設定される 
; ====================================================================================================
SECTION data_user
