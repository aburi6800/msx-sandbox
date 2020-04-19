;
;  sprite.as
;
        .area   CODE (ABS)
        .org    #0xD000                 ; 開始アドレス

VDP_R0  =       0xF3DF                  ; VDPレジスタR#0の値の格納先アドレス
V_SPATR =       0x1B00                  ; VRAMスプライトアトリビュートエリアのアドレス
V_SPPTN =       0x3800                  ; VRAMスプライトパターンエリアのアドレス

;
; BIOS FUNCTION CALL
;
RDVRM   =       0x004A                  ; BIOS(READ VRAM)
WRTVRM  =       0x004D                  ; BIOS(WRITE VRAM)
LDIVRM  =       0x005C
CHGMOD  =       0x005F                  ; BIOS(CHANGE SCREEN MODE)
ERAFNK  =       0x00CC                  ; BIOS(ERASE FUNCTION)
CHPUT   =       0x00A2                  ; BIOS(CHARACTER OUTPUT)

MAIN:
        CALL    PG_INIT                 ; 初期化ルーチン
        CALL    SP_MOV                  ; スプライト移動処理CALL

        RET

;
; 初期化ルーチン
;
PG_INIT:
        LD      A, (VDP_R0 + #1)        ; スプライトモードを16X16にする
        OR      #2
        LD      (VDP_R0 + #1), A
 
        LD      A, #1                   ; SCREEN1にする
        CALL    CHGMOD                  ; BIOSコール(CHANGE SCREEN MODE)

        CALL    ERAFNK                  ; BIOSコール(ERASE FUNCTION)

        CALL    SP_DEF                  ; スプライト定義処理CALL

        RET

;
; スプライト定義処理
;
SP_DEF:
        LD      HL, #SP_PTN             ; スプライトパターンデータの先頭アドレス
        LD      BC, (0x0020)            ; スプライトパターンデータ長
        LD      DE, #V_SPPTN            ; VRAMスプライトパターンエリアのアドレス
        CALL    LDIVRM                  ; VRAMブロック転送

        LD      HL, #SP_ATR             ; スプライトアトリビュートデータの先頭アドレス
        LD      BC, (0x0004)            ; スプライトアトリビュートデータ長
        LD      DE, #V_SPATR            ; VRAMスプライトアトリビュートエリアのアドレス
        CALL    LDIVRM

        RET

;
; スプライト移動処理
;
SP_MOV:
        CALL    GET_SPY
        RET

;
; スプライトY座標取得
; 
GET_SPY:
        LD      HL, #V_SPATR
        CALL    #RDVRM

        RET

;
; キャラクタプロパティ定義
; 0:下方向、1:上方向
;
CHRROP:
        .DB     0x00

;
; スプライトパターン定義
;
SP_PTN:
; #0
        .DB     0x00, 0x00, 0xA7, 0xAF, 0xBF, 0x9F, 0x9D, 0x9D
        .DB     0x9F, 0x8F, 0x87, 0x80, 0xE7, 0xE1, 0x86, 0x00
        .DB     0x00, 0x00, 0xF2, 0xFA, 0xFE, 0xFC, 0xDC, 0xDC
        .DB     0xFC, 0xFF, 0xFB, 0x11, 0x7B, 0xCE, 0x30, 0x30

;
; スプライトアトリビュートエリア定義
; Ｙ座標、X座標、パターン、カラーコード
;
SP_ATR:
        .DB     0x40, 0x80, 0x00, 0x0F






