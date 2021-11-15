; ====================================================================================================
; asm07.asm
; sound test program
; ====================================================================================================
SECTION code_user
PUBLIC _main

_main:
; ====================================================================================================
; テスト用の処理
; ====================================================================================================
INIT:
    ; ■画面初期化
    CALL SCREEN_INIT

    ; ■フォントパターン定義
    CALL SET_FONT_PATTERN

    ; ■文字列表示
    LD DE,STRDATA1
    CALL PRTFIXSTR
    LD DE,STRDATA2
    CALL PRTFIXSTR
    LD DE,STRDATA3
    CALL PRTFIXSTR
    LD DE,STRDATA4
    CALL PRTFIXSTR
    LD DE,STRDATA5
    CALL PRTFIXSTR
    LD DE,STRDATA6
    CALL PRTFIXSTR
    LD DE,STRDATA7
    CALL PRTFIXSTR
    LD DE,STRDATA8
    CALL PRTFIXSTR
    LD DE,STRDATA9
    CALL PRTFIXSTR
    LD DE,STRDATA10
    CALL PRTFIXSTR
    LD DE,STRDATA11
    CALL PRTFIXSTR

    ; ■ドライバ初期化
    ;   利用するアプリケーションで行う処理
    CALL SOUNDDRV_INIT

MAINLOOP:
    CALL GET_KEYMATRIX              ; キーマトリクス取得
    LD B,10                         ; 0〜9のキーの入力をチェック
    LD DE,KEYBUFF                   ; キーバッファの先頭アドレス

MAINLOOP_L1:
    LD A,(DE)                       ; A <- キーバッファの値
    OR A
    JR Z,MAINLOOP_L4                ; キーバッファの値がゼロなら次の処理へ

MAINLOOP_L2:
    LD A,B                          ; A < B(ループカウンタ)
    DEC A                           ; Bは1〜10なので、-1する

    LD C,A                          ; C <- A (計算用に値をコピー)
    ADD A,A                         ; A <- A*2+C = A*3
    ADD A,C

    LD HL,MAINLOOP_L3

    PUSH DE
    LD D,0                          ; DE <- A
    LD E,A
    ADD HL,DE                       ; Noに対応するJPのアドレスを求める
    POP DE
    JP (HL)

MAINLOOP_L3:
    JP PLAY9
    JP PLAY8
    JP PLAY7
    JP PLAY6
    JP PLAY5
    JP PLAY4
    JP PLAY3
    JP PLAY2
    JP PLAY1
    JP PLAY0

MAINLOOP_L4:
    INC DE
    DJNZ MAINLOOP_L1

MAINLOOP_VSYNC:
    ; ■ここがドライバ本体
    ;   最終的には割り込み処理として入れたい
    CALL SOUNDDRV_EXEC

	; ■垂直帰線待ち
	HALT

	JR MAINLOOP


PLAY0:
;    CALL PUSHALL
;    CALL CLRCUR
;    CALL POPALL

    CALL SOUNDDRV_STOP
    JP MAINLOOP_L4

PLAY1:
;    CALL PUSHALL
;    LD HL,32*7+2
;    CALL WRTCUR
;    CALL POPALL

    LD HL,MUSIC01
    CALL SOUNDDRV_PLAY
    JP MAINLOOP_L4

PLAY2:
;    CALL PUSHALL
;    LD HL,32*8+2
;    CALL WRTCUR
;    CALL POPALL

    LD HL,_18
    CALL SOUNDDRV_PLAY
    JP MAINLOOP_L4

PLAY3:
;    CALL PUSHALL
;    LD HL,32*9+2
;    CALL WRTCUR
;    CALL POPALL

    LD HL,_19
    CALL SOUNDDRV_PLAY
    JP MAINLOOP_L4

PLAY4:
;    CALL PUSHALL
;    LD HL,32*10+2
;    CALL WRTCUR
;    CALL POPALL

    LD HL,_20
    CALL SOUNDDRV_PLAY
    JP MAINLOOP_L4

PLAY5:
;    CALL PUSHALL
;    LD HL,32*11+2
;    CALL WRTCUR
;    CALL POPALL

    LD HL,SFX04
    CALL SOUNDDRV_SFXPLAY
    JP MAINLOOP_L4

PLAY6:
;    CALL PUSHALL
;    LD HL,32*12+2
;    CALL WRTCUR
;    CALL POPALL

    LD HL,SFX02
    CALL SOUNDDRV_SFXPLAY
    JP MAINLOOP_L4

PLAY7:
;    CALL PUSHALL
;    LD HL,32*13+2
;    CALL WRTCUR
;    CALL POPALL

    LD HL,SFX05
    CALL SOUNDDRV_SFXPLAY
    JP MAINLOOP_L4

PLAY8:
;    CALL PUSHALL
;    LD HL,32*14+2
;    CALL WRTCUR
;    CALL POPALL

    LD HL,SFX03
    CALL SOUNDDRV_SFXPLAY
    JP MAINLOOP_L4

PLAY9:
;    CALL PUSHALL
;    LD HL,32*15+2
;    CALL WRTCUR
;    CALL POPALL

    LD HL,SFX01
    CALL SOUNDDRV_SFXPLAY
    JP MAINLOOP_L4

WRTCUR:
    RET
    PUSH HL
    CALL CLRCUR
    POP HL
    LD DE,CURDATA1
    CALL PRTSTR

    RET

CLRCUR:
    RET
    LD B,10
    LD HL,32*7+2

CLRCUR_L1:
    LD DE,CURDATA0
    PUSH BC
    CALL PRTSTR
    POP BC
    LD DE,32
    ADD HL,DE
    DJNZ CLRCUR_L1

    RET

PUSHALL:
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL

    RET

POPALL:
    POP HL
    POP DE
    POP BC
    POP AF

    RET


; ====================================================================================================
; キーマトリクス取得処理
; ====================================================================================================
GET_KEYMATRIX:

    LD HL,KEYBUFF                   ; HL <- キーバッファアドレス
    LD DE,KEYBUFF_SV                ; HL <- キー入力バッファSVの先頭アドレス

    LD A,0                          ; キーマトリクスの0行目をスキャン対象
    CALL SNSMAT                     ; BIOS キーマトリクススキャン
    CALL GET_KEYMATRIX_SUB          ; 入力キーの情報をバッファに設定

    LD A,1                          ; キーマトリクスの1行目をスキャン対象
    CALL SNSMAT                     ; BIOS キーマトリクススキャン
    CALL GET_KEYMATRIX_SUB          ; 入力キーの情報をバッファに設定

    RET


GET_KEYMATRIX_SUB:
    ; ■以下前提
    ;   - Aレジスタにスキャン結果のデータが入っている
    ;   - HLレジスタにキーバッファのアドレスが設定されている
    ;   - DEレジスタにキー入力バッファSVのアドレスが設定されている
    LD B,8                          ; 0〜7ビットをスキャンするためのループ回数
    LD C,A                          ; C <- A (値を退避)

GET_KEYMATRIX_SUB_L1:
    LD A,C                          ; A <- C (退避した値をAレジスタに戻す)
    AND %00000001                   ; 下位1ビットを判定
    JR NZ,GET_KEYMATRIX_SUB_L2      ; ビットが立っている=キーが押されていないならL2へ

    ; ■キーが押されているときの処理
    ;   キー入力バッファSVの値を読み、OFFの時だけキー入力バッファをONにする
    ;   キー入力バッファSVがONの時は押しっぱなしなので、キー入力バッファをOFFにする
    LD A,(DE)                       ; A <- キー入力バッファSV
    OR A
    JR Z,GET_KEYMATRIX_SUB_L12      ; キー入力バッファSVがOFFの時はL12へ

    LD (HL),KEY_OFF                 ; キー入力バッファにOFFを設定
                                    ; キー入力バッファSVはそのままで良いので何もしない
    JR GET_KEYMATRIX_SUB_L3

GET_KEYMATRIX_SUB_L12:
    LD (HL),KEY_ON                  ; キー入力バッファにONを設定
    LD A,KEY_ON
    LD (DE),A                       ; キー入力バッファSVにONを設定
    JR GET_KEYMATRIX_SUB_L3

GET_KEYMATRIX_SUB_L2:
    ; ■キーが押されていないときの処理
    LD (HL),KEY_OFF                 ; キーバッファワークにキーオフを設定
    LD A,KEY_OFF
    LD (DE),A                       ; キー入力バッファSVにOFFを設定

GET_KEYMATRIX_SUB_L3:
    INC HL                          ; キーバッファワークのアドレスを+1
    INC DE                          ; キー入力バッファSVのアドレスを+1
    SRL C                           ; Cレジスタの値を右シフト

    DJNZ GET_KEYMATRIX_SUB_L1

    RET


; ====================================================================================================
; 画面初期化
; ====================================================================================================
SCREEN_INIT:
    ; ■COLOR 15,1,1
    LD A,15                         ; Aレジスタに文字色をロード 
    LD (FORCLR),A                   ; Aレジスタの値をワークエリアに格納
    LD A,1                          ; Aレジスタに全景色をロード
    LD (BAKCLR),A                   ; Aレジスタの値をワークエリアに格納
;    LD A,1                         ; Aレジスタに背景色をロード
    LD (BDRCLR),A                   ; Aレジスタの値をワークエリアに格納

    ; ■SCREEN 1,2,0
    LD A,(REG1SAV)                  ; AレジスタにVDPコントロールレジスタ1の値をロード
    OR 2                            ; ビット2を立てる(=スプライトモードを16x16に設定)
    LD (REG1SAV),A                  ; Aレジスタの値をVDPコントロールレジスタ1のワークエリアに格納
    LD A,1                          ; Aレジスタにスクリーンモードの値を設定
    CALL CHGMOD                     ; BIOS スクリーンモード変更
    LD A,0                          ; Aレジスタにキークリックスイッチの値(0=OFF)をロード
    LD (CLIKSW),A                   ; Aレジスタの値をワークエリアに格納

    ; ■WIDTH 32
    LD A,32                         ; AレジスタにWIDTHの値を設定
    LD (LINL32),A                   ; Aレジスタの値をワークエリアに格納

    ; ■KEY OFF
    CALL ERAFNC                     ; BIOS ファンクションキー非表示

    RET


; ====================================================================================================
; フォントパターン定義
; ====================================================================================================
SET_FONT_PATTERN:
	LD HL,FONT_PTN_DATA			    ; HLレジスタに転送元データの先頭アドレスを設定
    LD DE,PTN_GEN_ADDR+32*8         ; DEレジスタに転送先アドレスを設定
	LD BC,8*64					    ; BCレジスタにデータサイズを指定
    CALL LDIRVM					    ; BIOS VRAMブロック転送

    RET


; ====================================================================================================
; 文字列固定位置表示サブルーチン
; IN  : DE = 表示文字データの開始アドレス
; HLレジスタを破壊します
; ====================================================================================================
PRTFIXSTR:
    LD A,(DE)                       ; DE <- HLアドレスの示す表示位置データ
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    INC DE                          ; DE <- 文字列データの先頭アドレス

; ====================================================================================================
; 文字列表示サブルーチン
; IN  : HL = 表示位置（y*32+x）
;       DE = 表示文字データの開始アドレス
; BCレジスタを破壊します
; ====================================================================================================
PRTSTR:
    LD BC,PTN_NAME_ADDR             ; BC <- パターンネームテーブルの先頭アドレス
    ADD HL,BC                       ; HL=HL+BC

PRTSTR_L1:
	LD A,(DE)				        ; AレジスタにDEレジスタの示すアドレスのデータを取得
	OR 0					        ; 0かどうか
    JR Z,PRTSTR_END			        ; 0の場合はPRTENDへ

	CALL WRTVRM				        ; BIOS WRTVRM呼び出し
	    					        ; - HL : 書き込み先のVRAMアドレス
    	                            ; - A  : 書き込むデータ

	INC HL					        ; HL=HL+1
    INC DE					        ; DE=DE+1
    JR PRTSTR_L1

PRTSTR_END:
	RET




; ====================================================================================================
;
; サウンドドライバ
;
; ====================================================================================================


; ====================================================================================================
; ドライバ初期化
; ====================================================================================================
SOUNDDRV_INIT:
	CALL GICINI		                ; GICINI	PSGの初期化

    ; ■音を出す設定
	LD A,7			                ; PSGレジスタ番号=7(チャンネル設定)
	LD E,%10111000	                ; 各チャンネルのON/OFF設定 0:ON 1:OFF,10+NOISE C～A+TONE C～A
	CALL WRTPSG		                ; BIOS WRTPSG  PSGレジスタへデータを書き込み

    ; ■ ドライバステータス初期化
    LD A,SOUNDDRV_STATE_STOP
    LD (SOUNDDRV_STATE),A

    ; ■ ドライバワークエリア初期化
    LD HL,SOUNDDRV_WK_MIXING_TONE
    LD (HL),%00000000

    LD HL,SOUNDDRV_WK_MIXING_NOISE
    LD (HL),%00000000

    LD HL,SOUNDDRV_WK_NOISETONE_BGM
    LD (HL),0    

    LD HL,SOUNDDRV_WK_NOISETONE_SFX
    LD (HL),0    

    LD HL,SOUNDDRV_WK_VOL
    LD (HL),0
    INC HL
    LD (HL),0
    INC HL
    LD (HL),0

    ; ■ BGM/SFXワークエリア初期化
    LD HL,SOUNDDRV_BGMWK
    LD B,SOUNDDRV_WORK_DATASIZE*6
SOUNDDRV_INIT_2:
    LD (HL),0
    INC HL
    DJNZ SOUNDDRV_INIT_2

    RET


; ====================================================================================================
; BGM演奏開始
; IN  : HL = BGMデータの先頭アドレス
;            BGMデータの構成は以下とする
;              テンポ:1byte
;              トラック1のデータアドレス:2byte
;              トラック2のデータアドレス:2byte
;              トラック3のデータアドレス:2byte
; ====================================================================================================
SOUNDDRV_PLAY:
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL

    ; ■BGMデータアドレスを設定
    PUSH HL
    POP IX
    INC IX                          ; 最初の1byteは<未使用>テンポなので飛ばす

    ; ■各チャンネルの初期設定
    LD HL,SOUNDDRV_BGMWK            ; BGMワークエリアの先頭アドレス
    LD B,3                          ; チャンネル数

SOUNDDRV_PLAY_L1:
    ;   ウェイトカウンタ
    ;   最初に必ずゼロになるように、初期値を1とする
    LD (HL),1
    INC HL

    ;   次に読むBGMデータのアドレス
    ;   BGMデータの先頭アドレスを初期値とする
    LD E,(IX)                       ; DE <- BGMデータの先頭アドレス
    LD D,(IX+1)
    LD (HL),E
    INC HL
    LD (HL),D
    INC HL

    ;   BGMデータの先頭アドレス
    LD (HL),E
    INC HL
    LD (HL),D
    INC HL

    ;   デチューン値
    LD (HL),0
    INC HL

    ;   ミキシング (bit0=Tont,bit1=Noise 0=On,1=Off)
    LD (HL),%10111111
    INC HL

    ;   未使用
    LD (HL),0
    INC HL

    INC IX                          ; 次のトラックデータのアドレスに設定
    INC IX

    DJNZ SOUNDDRV_PLAY_L1

    LD A,SOUNDDRV_STATE_PLAY        ; サウンドドライバの状態を再生中にする
    LD (SOUNDDRV_STATE),A

    POP HL
    POP DE
    POP BC
    POP AF

    RET


; ====================================================================================================
; SFX演奏開始
; IN  : HL = SFXデータの先頭アドレス
;            SFXデータの構成は以下とする
;              テンポ:1byte
;              トラック1のデータアドレス:2byte ゼロ=なし
;              トラック2のデータアドレス:2byte ゼロ=なし
;              トラック3のデータアドレス:2byte ゼロ=なし
; ====================================================================================================
SOUNDDRV_SFXPLAY:
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL

    ; ■SFXデータアドレスを設定
    PUSH HL
    POP IX
    INC IX                          ; 最初の1byteは<未使用>テンポなので飛ばす

    ; ■各チャンネルの初期設定
    LD HL,SOUNDDRV_SFXWK
    LD B,3                          ; チャンネル数

SOUNDDRV_SFXPLAY_L1:
    ;   ウェイトカウンタ
    ;   最初に必ずゼロになるように、初期値を1とする
    LD (HL),1
    INC HL

    ;   次に読むSFXデータのアドレス
    ;   SFXデータの先頭アドレスを初期値とする
    LD E,(IX)                       ; DE <- SFXデータの先頭アドレス
    LD D,(IX+1)
    LD (HL),E
    INC HL
    LD (HL),D
    INC HL

    ;   SFXデータの先頭アドレス
    LD (HL),E
    INC HL
    LD (HL),D
    INC HL

    ;   デチューン値
    LD (HL),0
    INC HL

    ;   ミキシング (bit0=Tont,bit1=Noise 0=On,1=Off)
    LD (HL),%10111111
    INC HL

    ;   未使用
    LD (HL),0
    INC HL

    INC IX                          ; 次のトラックデータのアドレスに設定
    INC IX

    DJNZ SOUNDDRV_SFXPLAY_L1

    LD A,SOUNDDRV_STATE_PLAY        ; サウンドドライバの状態を再生中にする
    LD (SOUNDDRV_STATE),A

    POP HL
    POP DE
    POP BC
    POP AF

    RET


; ====================================================================================================
; 演奏停止
; ====================================================================================================
SOUNDDRV_STOP:
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL

    LD A,SOUNDDRV_STATE_STOP
    LD (SOUNDDRV_STATE),A

    ; ■全PSGチャンネルのボリュームを0にする
    LD B,3
SOUNDDRV_STOP_L1:
    LD E,0                          ; E <- データ(ボリューム)
    LD A,B                          ; A <- トラック番号
    ADD A,7                         ; PSGレジスタ8〜10に指定するため+7
    CALL WRTPSG
    DJNZ SOUNDDRV_STOP_L1

    ; ■全トラックのワークをクリア
    LD B,7                          ; BGMワークエリア＋SFXワークエリア(ダミー含む)
SOUNDDRV_STOP_L2:
    LD A,B
    SUB 1                           ; トラック番号は0〜なので-1する
    CALL SOUNDDRV_GETWKADDR
    PUSH HL
    POP IX
    LD (IX),$00
    LD (IX+1),$00
    LD (IX+2),$00
    LD (IX+3),$00
    LD (IX+4),$00
    DJNZ SOUNDDRV_STOP_L2

    POP HL
    POP DE
    POP BC
    POP AF

    RET


; ====================================================================================================
; 演奏処理
; ====================================================================================================
SOUNDDRV_EXEC:
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL

    ; ■サウンドドライバのステータス判定
    LD A,(SOUNDDRV_STATE)           ; A <- サウンドドライバの状態
    OR A
    JP Z,SOUNDDRV_EXIT              ; ゼロ(停止)なら抜ける

    ; ■各トラックの処理
    LD A,0                          ; A <- 0(BGMトラック0=ChA)
    CALL SOUNDDRV_CHEXEC
    LD A,1                          ; A <- 1(BGMトラック1=ChB)
    CALL SOUNDDRV_CHEXEC
    LD A,2                          ; A <- 2(BGMトラック2=ChC)
    CALL SOUNDDRV_CHEXEC
    LD A,4                          ; A <- 4(SFXトラック0=ChA)
    CALL SOUNDDRV_CHEXEC
    LD A,5                          ; A <- 5(SFXトラック1=ChB)
    CALL SOUNDDRV_CHEXEC
    LD A,6                          ; A <- 6(SFXトラック2=ChC)
    CALL SOUNDDRV_CHEXEC

    ; ■チャンネル全体の処理
    CALL SOUNDDRV_SETMIXING         ; PSGレジスタ7設定処理

SOUNDDRV_EXIT:
    POP HL
    POP DE
    POP BC
    POP AF

    RET

; ----------------------------------------------------------------------------------------------------
; トラックデータ再生処理
; IN  : A  = トラック番号(0〜2,4〜6)
; ----------------------------------------------------------------------------------------------------
SOUNDDRV_CHEXEC:
    LD D,A                          ; A -> D (Dレジスタにトラック番号を退避)

    CALL SOUNDDRV_GETWKADDR         ; HLにトラックワークエリアの先頭アドレスを取得
    PUSH HL                         ; IX <- HL
    POP IX
    
    ; ■トラックデータの先頭アドレスをチェック
    LD H,(IX+3)
    LD L,(IX+4)
    LD A,H
    OR L
    RET Z                           ; トラックデータの先頭アドレス=ゼロ(未登録)なら抜ける    

    ; ■発声中の音のウェイトカウンタを減算
    DEC (IX)
    RET NZ                          ; -1した結果がゼロでない場合は発声中なので抜ける

SOUNDDRV_CHEXEC_L2:
    ; ■対象チャンネルの曲データを取得
    ;   発声が終了していたら、次のデータを取得する
    CALL SOUNDDRV_GETNEXTNATA       ; A <- シーケンスデータ
    JP Z,SOUNDDRV_CHEXEC_L3         ; ゼロフラグが立っている場合はL3へ
                                    ; 取得したデータが終端の時はゼロフラグが立っている

SOUNDDRV_CHEXEC_L21:
    ; ■コマンドによる分岐
    ; @ToDo : ここの分岐はもう少しスマートにしたい、ノート番号が多く出現するので200未満の時を優先に
    CP 200                          ; データ=200(ボリューム)か
    JP Z,SOUNDDRV_CHEXEC_CMD200     ; ボリューム設定処理へ

    CP 201                          ; データ=201(ミキシング)か
    JP Z,SOUNDDRV_CHEXEC_CMD201     ; ミキシング設定処理へ

    CP 202                          ; データ=202(ノイズトーン)か
    JP Z,SOUNDDRV_CHEXEC_CMD202     ; ノイズトーン設定処理へ

    CP 210                          ; データ=210(デチューン値)か
    JP Z,SOUNDDRV_CHEXEC_CMD210     ; デチューン値設定処理へ

    ; ■データ=0〜190のときの処理
    ;   トーンテーブルから該当するデータを取得し、PSGレジスタ0〜5に設定する
    ;   次のデータを取得して、ウェイトカウンタに設定する
    LD E,A                          ; E <- A(シーケンスデータ)
    LD A,D                          ; A <- D(トラック番号)
    AND %00000100                   ; bit2=1(=SFX)か
    JR NZ,SOUNDDRV_CHEXEC_L22       ; 1(=SFX)の場合はL22へ

    ;   BGMトラックの時の処理
    ;   SFXトラックのワークに設定されているSFXデータの先頭アドレスを調べる
    ;   $0000でない場合はSFX再生中なので、トーンデータは設定せず、ウェイトカウンタの設定のみ行う
    LD A,D                          ; A <- D(トラック番号)
    ADD A,4                         ; SFXトラックを調べるためにトラック番号にA=A+4する
    CALL SOUNDDRV_GETWKADDR         ; HLに対象トラックの先頭アドレスを取得

    INC HL                          ; @ToDo:トラックデータの先頭アドレスを求めることが多いので、ワークの持ち方を見直したい(毎回21ステートかかってる)
    INC HL
    INC HL

    LD A,(HL)
    INC HL
    OR (HL)                         ; 対象トラックの先頭アドレス=$0000か
    JR NZ,SOUNDDRV_CHEXEC_L23       ; ゼロでない場合はSFX再生中なのでBGMのトーンは設定せずL23へ

SOUNDDRV_CHEXEC_L22:
    LD B,0                          ; BC <- E(シーケンスデータ)
    LD C,E    
    LD HL,SOUNDDRV_TONETBL          ; HL <- トーンテーブルの先頭アドレス
    ADD HL,BC                       ; トーンデータは2byteなのでインデックスx2とする
    ADD HL,BC

    ; ■PSGレジスタ0〜5に周波数設定
    ;   チャンネルA:PSGレジスタ0,1
    ;   チャンネルB:PSGレジスタ2,3
    ;   チャンネルC:PSGレジスタ4,5
    LD A,(HL)                       ; A <- トーンデータ
    SUB (IX+5)                      ; デチューン値を減算
    LD E,A                          ; E <- A(計算後のトーンデータ)
    LD A,D                          ; A <- Dレジスタに退避した値(チャンネル)
    AND %00000011                   ; 下位2ビットをチャンネル番号とする
    ADD A,A                         ; PSGレジスタ番号=0/2/4(下位8ビット)
    CALL WRTPSG
    
    INC A                           ; PSGレジスタ番号=1/3/5(上位4ビット)
    INC HL
    LD E,(HL)                       ; E <- トーンデータ
    CALL WRTPSG

SOUNDDRV_CHEXEC_L23:
    ; ■該当チャンネルのウェイトカウンタ設定
    CALL SOUNDDRV_GETNEXTNATA       ; A <- シーケンスデータ
    LD (IX),A                       ; ワークにウェイトカウンタを設定

    JP SOUNDDRV_CHEXEC_EXIT

SOUNDDRV_CHEXEC_CMD200:
    ; ■ボリューム設定処理
    ;   次のシーケンスデータを取得して、PSGレジスタ8〜10(PSGChA〜C)に設定する
    ;   そして次のシーケンスデータの処理を行う
    CALL SOUNDDRV_GETNEXTNATA       ; A <- シーケンスデータ(ボリューム)
    LD E,A                          ; E <- データ(ボリューム)

    ; ■SFXトラックの場合はボリュームを退避せずPSGレジスタに設定
    LD A,D
    AND %00000100
    JR NZ,SOUNDDRV_CHEXEC_CMD200_L1

    ; ■ボリュームの値を退避
    LD B,0
    LD C,D                          ; D=トラック番号(ここに入った時点で0〜2)
    LD HL,SOUNDDRV_WK_VOL
    ADD HL,BC                       ; ボリューム退避WKのアドレス
    LD (HL),E

SOUNDDRV_CHEXEC_CMD200_L1:
    LD A,D                          ; A <- トラック番号(0〜2, 4〜6)
    AND %00000011                   ; 下位2ビットをチャンネル番号とする
    ADD A,8                         ; PSGレジスタ8〜10に指定するため+8
    CALL WRTPSG

SOUNDDRV_CHEXEC_CMD200_EXIT:
    JP SOUNDDRV_CHEXEC_L2

SOUNDDRV_CHEXEC_CMD210:
    ; ■デチューン値設定処理
    ;   次のシーケンスデータを取得して、ワークエリアに設定する
    ;   そして次のシーケンスデータの処理を行う
    CALL SOUNDDRV_GETNEXTNATA       ; A <- シーケンスデータ(デチューン値)
    LD (IX+5),A

    JP SOUNDDRV_CHEXEC_L2

SOUNDDRV_CHEXEC_CMD201:
    ; ■ミキシング設定処理
    ;   次のシーケンスデータを取得して、ワークエリアに設定すると同時にPSGレジスタ7に設定する
    ;   そして次のシーケンスデータの処理を行う
    CALL SOUNDDRV_GETNEXTNATA       ; A <- シーケンスデータ(ミキシング値)
    LD (IX+6),A

    JP SOUNDDRV_CHEXEC_L2


SOUNDDRV_SETMIXING:
    ; ■PSGレジスタ7設定処理
    ;   現在のワークの設定値からPSGレジスタ7の設定値を求め、WRTPSGを実行する
    ;   レジスタ7への設定値は以下となる(0=On,1=Off)
    ;     xx000000
    ;       |||||bit0:ChA Tone
    ;       ||||bit1:ChB Tone
    ;       |||bit2:ChC Tone
    ;       ||bit3:ChA Noise
    ;       |bit4:ChB Noise
    ;       bit5:ChC Noise
    ;   各トラックのワークには以下で設定
    ;     00
    ;     |bit0:Tone
    ;     bit1:Noise
    LD B,3                          ; ループ回数

    LD A,%00
    LD (SOUNDDRV_WK_MIXING_TONE),A  ; A -> PSGレジスタ7のWK(bit0〜2:Tone設定用)初期化
    LD (SOUNDDRV_WK_MIXING_NOISE),A ; A -> PSGレジスタ7のWK(bit3〜5:Noise設定用)初期化

SOUNDDRV_SETMIXING_L1:
    ; ■各トラックのミキシング値のアドレスを設定する
    ;   Ch2,1,0の順に処理する
    ;   SFXトラックのトラックデータ先頭アドレスを求める
    LD A,B                          ; A <- B(1〜3)
    ADD A,3                         ; Aに+3して、トラック番号4〜6(SFXトラック1〜3)とする
    CALL SOUNDDRV_GETWKADDR         ; HL <- SFXワークエリアの先頭アドレス
    INC HL                          ; @ToDo:トラックデータの先頭アドレスを求めることが多いので、ワークの持ち方を見直したい(毎回21ステートかかってる)
    INC HL
    INC HL

    ;   SFXトラックのトラックデータ先頭アドレスを判定
    LD A,(HL)                       ; トラックデータの先頭アドレスが$0000か
    INC HL
    OR (HL)
    JR NZ,SOUNDDRV_SETMIXING_L2     ; ゼロでないならSFXトラックが設定されているので、次の処理へ

    ;   BGMトラックのトラックデータ先頭アドレスを求める
    LD A,B                          ; A <- B(1〜3)
    SUB 1                           ; Aを-1して、トラック番号0〜2とする
    CALL SOUNDDRV_GETWKADDR         ; HL <- BGMワークエリアの先頭アドレス
    INC HL                          ; @ToDo:トラックデータの先頭アドレスを求めることが多いので、ワークの持ち方を見直したい(毎回21ステートかかってる)
    INC HL
    INC HL

    ;   BGMトラックのトラックデータ先頭アドレスを判定
    LD A,(HL)                       ; トラックデータの先頭アドレスが$0000か
    INC HL
    OR (HL)
    JR NZ,SOUNDDRV_SETMIXING_L2     ; ゼロでないならBGMトラックが設定されているので、次の処理をスキップ

    ; BGMもSFXも未設定の場合は、ミキシング値を%11(Noise,Tone=Off)にする
    LD D,%11
    JR SOUNDDRV_SETMIXING_L3

SOUNDDRV_SETMIXING_L2:
    ; ■各トラックのミキシング値を取得してワークに設定する
    INC HL
    INC HL
    LD D,(HL)                       ; D <- 対象トラックのミキシング値

SOUNDDRV_SETMIXING_L3:
    ;   Toneのミキシング値
    SRL D                           ; Dレジスタを1ビット右シフト 元の値のbit0→キャリーフラグ
    LD A,(SOUNDDRV_WK_MIXING_TONE)  ; A <- PSGレジスタ7のWK(bit0〜2:Tone設定用)
    RLA                             ; Aレジスタを1ビット左ローテート bit0←キャリーフラグ
    LD (SOUNDDRV_WK_MIXING_TONE),A  ; A -> PSGレジスタ7のWK(bit0〜2:Tone設定用)

    ;   Noiseのミキシング値
    SRL D                           ; Dレジスタを1ビット右シフト 元の値のbit1→キャリーフラグ
    LD A,(SOUNDDRV_WK_MIXING_NOISE) ; A <- PSGレジスタ7のWK(bit3〜5:Noise設定用)
    RLA                             ; Aレジスタを1ビット左ローテート bit0←キャリーフラグ
    LD (SOUNDDRV_WK_MIXING_NOISE),A ; A -> PSGレジスタ7のWK(bit3〜5:Noise設定用)

    DJNZ SOUNDDRV_SETMIXING_L1

    ; ■レジスタ7に設定する値を求める
    LD A,(SOUNDDRV_WK_MIXING_TONE)  ; A <- PSGレジスタ7のWK(bit0〜2:Tone設定用)
    LD E,A                          ; E <- A

    LD A,(SOUNDDRV_WK_MIXING_NOISE) ; A <- PSGレジスタ7のWK(bit0〜2:Tone設定用)
    SLA A                           ; 左3bitシフト → bit2〜0のデータをbit5〜3に移動する
    SLA A
    SLA A
    OR E                            ; Toneの値を加算
    OR %10000000                    ; bit7〜6を設定
    LD E,A
    LD A,7
    CALL WRTPSG

    RET


SOUNDDRV_CHEXEC_CMD202:
    ; ■ノイズトーン設定処理
    ;   次のシーケンスデータを取得して、ワークエリアに設定する
    ;   そして次のシーケンスデータの処理を行う
    CALL SOUNDDRV_GETNEXTNATA       ; A <- シーケンスデータ(ノイズトーン値)
    LD E,A
    LD A,6
    CALL WRTPSG

    JP SOUNDDRV_CHEXEC_L2


SOUNDDRV_CHEXEC_L3:
    ; ■終端処理    
    LD (IX+3),$00                   ; ワークエリアのトラックデータ先頭アドレスをゼロにする
    LD (IX+4),$00
    LD (IX+6),%00000011             ; ミキシングをTone,NoiseともにOffにする

    LD A,D                          ; A <- D(トラック番号)
    AND %00000100                   ; ビット2を調べる(=トラック番号が4〜6か)
    RET Z                           ; ゼロ(=BGMトラック)ならここで終了する

    ; ■SFXの再生が終了した場合は、以下の処理を行う
    ;   対象BGMトラックのボリュームを復元
    LD A,D                          ; A <- D(トラック番号)
    AND %00000011                   ; トラック番号をチャンネル番号(0〜2)に変換
    LD B,0                          ; BC <- チャンネル番号
    LD C,A
    LD HL,SOUNDDRV_WK_VOL
    ADD HL,BC                       ; ボリューム退避WKのアドレス
    LD E,(HL)                       ; E <- ボリューム
    ADD A,8                         ; PSGレジスタ8〜10に指定するため+8
    CALL WRTPSG

SOUNDDRV_CHEXEC_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; 次に読むトラックデータのアドレスからデータを取得する
; 同時に、トラックデータの取得アドレスも更新する
; データが終端(=$FF)の場合は、トラックデータの取得アドレスを先頭アドレスに戻す
; IN  : IX = トラックワークエリアの先頭アドレス
; OUT : A = トラックデータ
; ----------------------------------------------------------------------------------------------------
SOUNDDRV_GETNEXTNATA:
    ; ■トラックデータを取得
    LD C,(IX+1)                     ; BC <- トラックデータの取得アドレス
    LD B,(IX+2)
    LD A,(BC)                       ; A <- 曲データ

    ; ■終端判定
    CP $FF                          ; トラックデータ=$FFか
    RET Z                           ; 終端の場合はそのまま処理終了

    ; ■次に読む曲データのアドレスを+1
    INC BC

    ; ■ループ判定
    CP $FE                          ; トラックデータ=$FEか
    JR NZ,SOUNDDRV_GETNEXTNATA_2    ; $FEでなければスキップ

    ; ■トラックデータを先頭に戻す
    ;   @TODO:終端データに戻し先のカウントを設定できるようにしたい（BGMのイントロを飛ばす対応）
    OR A                            ; ゼロフラグをクリアする
                                    ; A=0ではないので、これでゼロフラグはOFFになる
    LD C,(IX+3)                     ; BC <- トラックデータの先頭アドレス
    LD B,(IX+4)
    LD A,(BC)                       ; Aレジスタにトラックデータを読み直す
    INC BC                          ; 読んだのでアドレスを1つ進める

SOUNDDRV_GETNEXTNATA_2:
    ; ■次に読むトラックデータのアドレスを保存
    LD (IX+1),C                     ; BC -> 次に読むトラックデータのアドレス
    LD (IX+2),B

    RET

; ----------------------------------------------------------------------------------------------------
; BGM/SFXワークエリアのアドレスを求める
; IN  : A = トラック番号(0〜2,4〜6)
; OUT : HL = 対象トラックのワークエリアのアドレス
; ----------------------------------------------------------------------------------------------------
SOUNDDRV_GETWKADDR:
    PUSH BC
    LD HL,SOUNDDRV_BGMWK            ; HL <- BGMワークエリアの先頭アドレス

    OR A                            ; ゼロか
    JR Z,SOUNDDRV_GETWKADDR_L1      ; ゼロなら計算不要なのでL2へ

    SLA A                           ; A=A*8(ワークエリアのサイズ)
    SLA A
    SLA A

SOUNDDRV_GETWKADDR_L1:
    LD B,0
    LD C,A
    ADD HL,BC                       ; HL <- 対象トラックのワークエリアのアドレス

    POP BC
    RET

; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================
SECTION rodata_user

GICINI:	                EQU $0090	; PSGの初期化アドレス
WRTPSG:	                EQU $0093   ; PSGレジスタへのデータ書込アドレス

; ■BIOSアドレス定義
RDVRM:		            EQU $004A	; BIOS RDVRM
WRTVRM:		            EQU $004D	; BIOS WRTVRM
FILVRM:			        EQU	$0056	; BIOS VRAM指定領域同一データ転送
LDIRVM:			        EQU	$005C	; BIOS VRAMブロック転送
CHGMOD:                 EQU $005F   ; BIOS スクリーンモード変更
ERAFNC:                 EQU $00CC   ; BIOS ファンクションキー非表示
SNSMAT:                 EQU $0141   ; BIOS キーマトリクススキャン
KILBUF:                 EQU $0156   ; BIOS キーバッファクリア
GTSTCK:                 EQU $00D5   ; BIOS ジョイスティックの状態取得
GTTRIG:                 EQU $00D8   ; BIOS トリガボタンの状態取得

; ■システムワークエリアアドレス定義
REG0SAV:                EQU $F3DF   ; VDPコントロールレジスタ0
REG1SAV:                EQU $F3E0   ; VDPコントロールレジスタ1
FORCLR:                 EQU $F3E9   ; 前景色
BAKCLR:                 EQU $F3EA   ; 背景色
BDRCLR:                 EQU $F3EB   ; 周辺色
LINL32:                 EQU $F3AF   ; WIDTH値
CLIKSW:                 EQU $F3DB   ; キークリックスイッチ(0:OFF,0以外:ON)
INTCNT:                 EQU $FCA2   ; システムで1/60秒でインクリメントするワークエリア

; ■VRAMワークエリアアドレス定義
PTN_GEN_ADDR:           EQU $0000   ; VRAM パターンジェネレータテーブルの先頭アドレス
PTN_NAME_ADDR:          EQU $1800   ; VRAM パターンネームテーブルの先頭アドレス
COLOR_TABLE_ADDR:       EQU $2000   ; VRAM カラーテーブルの先頭アドレス
SPR_PTN_ADDR:	        EQU $3800	; VRAM スプライトパターンジェネレータの先頭アドレス
SPR_ATR_ADDR:	        EQU	$1B00	; VRAM スプライトアトリビュートエリアの先頭アドレス

SOUNDDRV_STATE_STOP:    EQU 0       ; サウンドドライバ状態：停止
SOUNDDRV_STATE_PLAY:    EQU 1       ; サウンドドライバ状態：演奏中

SOUNDDRV_WORK_DATASIZE: EQU 8       ; サウンドドライバ1chのワークエリアサイズ


; ----------------------------------------------------------------------------------------------------
; トーンテーブル
; ----------------------------------------------------------------------------------------------------
SOUNDDRV_TONETBL:
;          C   C+    D   D+    E    F   F+    G   G+    A   A+    B
	dw  3420,3229,3047,2876,2715,2562,2419,2283,2155,2034,1920,1812 ;o1  0〜 11
	dw  1710,1614,1524,1438,1357,1281,1209,1141,1077,1017, 960, 906 ;o2 12〜 23
	dw   855, 807, 762, 719, 679, 641, 605, 571, 539, 508, 480, 453 ;o3 24〜 35
	dw   428, 404, 381, 360, 339, 320, 302, 285, 269, 254, 240, 226 ;o4 36〜 47
	dw   214, 202, 190, 180, 170, 160, 151, 143, 135, 127, 120, 113 ;o5 48〜 59
	dw   107, 101,  95,  90,  85,  80,  76,  71,  67,  64,  60,  57 ;o6 60〜 71
	dw    53,  50,  48,  45,  42,  40,  38,  36,  34,  32,  30,  28 ;o7 72〜 83
	dw    27,  25,  24,  22,  21,  20,  19,  18,  17,  16,  15,  14 ;o8 84〜 95

; ----------------------------------------------------------------------------------------------------
; 曲データ
; サウンドドライバを使用するプログラムで定義が必要
; ----------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------
; ゲーム中BGM
; ----------------------------------------------------------------------------------------------------
MUSIC01:
    DB  8                           ; <未使用>テンポ(4分音符＝n/60秒とした場合の値)
    DW  MUSIC01_TRK1                ; ChAのトラックデータ
    DW  MUSIC01_TRK2                ; ChBのトラックデータ
    DW  $0000                       ; ChCのトラックデータ(なし)

MUSIC01_TRK1:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  200, 14                     ; ボリューム
    DB   48,  6, 60, 6, 59, 6, 60, 6
    DB   64,  6, 60, 6, 59, 6, 60, 6
    DB   48,  6, 60, 6, 58, 6, 60, 6
    DB   64,  6, 60, 6, 58, 6, 60, 6
    DB   48,  6, 60, 6, 57, 6, 60, 6
    DB   64,  6, 60, 6, 57, 6, 60, 6
    DB   48,  6, 60, 6, 56, 6, 60, 6
    DB   64,  6, 60, 6, 56, 6, 60, 6
    DB  254,  0

MUSIC01_TRK2:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  200, 12                     ; ボリューム
    DB  210,  1                     ; デチューン値
    DB   48,  6, 60, 6, 59, 6, 60, 6
    DB   64,  6, 60, 6, 59, 6, 60, 6
    DB   48,  6, 60, 6, 58, 6, 60, 6
    DB   64,  6, 60, 6, 58, 6, 60, 6
    DB   48,  6, 60, 6, 57, 6, 60, 6
    DB   64,  6, 60, 6, 57, 6, 60, 6
    DB   48,  6, 60, 6, 56, 6, 60, 6
    DB   64,  6, 60, 6, 56, 6, 60, 6
    DB  254,  0

MUSIC01_TRK3:
    DB  255

; ----------------------------------------------------------------------------------------------------
; バキュラにザッパーが命中した音
; ----------------------------------------------------------------------------------------------------
SFX01:
    DB  8                           ; <未使用>テンポ(4分音符＝n/60秒とした場合の値)
    DW  SFX01_TRK1                  ; chAのトラックデータ
    DW  SFX01_TRK2                  ; chBのトラックデータ
    DW  SFX01_TRK3                  ; chCのトラックデータ

SFX01_TRK1:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  200, 15
    DB   60,  3, 200, 10, 60,  3,200,  8, 60,  3,200,  6, 60,  3, 200,  4, 60,  3
    DB  200,  0
    DB  255 

SFX01_TRK2:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  200, 13
    DB  210,  2
    DB   60,  3, 200,  8, 60,  3,200,  6, 60,  3,200,  4, 60,  3, 200,  2, 60,  3
    DB  200,  0
    DB  255

SFX01_TRK3:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  202,  1
    DB  200, 15
    DB   61,  3
    DB  200,  0
    DB  255

; ----------------------------------------------------------------------------------------------------
; ザッパー発射音
; ----------------------------------------------------------------------------------------------------
SFX02:
    DB  0                           ; <未使用>テンポ(4分音符＝n/60秒とした場合の値)
    DW  $0000                       ; chAのトラックデータ
    DW  $0000                       ; chBのトラックデータ
    DW  SFX02_TRK3                  ; chCのトラックデータ

SFX02_TRK1:
    DB  255 

SFX02_TRK2:
    DB  255 

SFX02_TRK3:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  200, 15
;    DB   18,  1,  66,  1, 19,  1, 61,  1, 20,  1, 56,  1, 21,  1, 51,  1 
    DB   18,  1,  78,  1, 21,  1, 63,  1 
    DB  200,  0
    DB  255

; ----------------------------------------------------------------------------------------------------
; 敵飛行隊破壊音
; ----------------------------------------------------------------------------------------------------
SFX03:
    DB  0                           ; <未使用>テンポ(4分音符＝n/60秒とした場合の値)
    DW  SFX03_TRK1                  ; chAのトラックデータ
    DW  SFX03_TRK2                  ; chBのトラックデータ
    DW  SFX03_TRK3                  ; chCのトラックデータ

SFX03_TRK1:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  202,  1
    DB  200, 15
    DB   93,  3,  91,  3, 95,  3, 93,  3 
    DB  200,  0
    DB  255

SFX03_TRK2:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  202,  1
    DB  200, 15
    DB   90,  3,  88,  3, 92,  3, 90,  3 
    DB  200,  0
    DB  255 

SFX03_TRK3:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  202,  1
    DB  200, 15
    DB   84,  3,  85,  3, 86,  3, 87,  3 
    DB  200,  0
    DB  255

; ----------------------------------------------------------------------------------------------------
; クレジット音
; ----------------------------------------------------------------------------------------------------
SFX04:
    DB  0                           ; <未使用>テンポ(4分音符＝n/60秒とした場合の値)
    DW  SFX04_TRK1                  ; chAのトラックデータ
    DW  SFX04_TRK2                  ; chBのトラックデータ
    DW  SFX04_TRK3                  ; chCのトラックデータ

SFX04_TRK1:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  200, 15                     ; Volume
    DB   20,  1, 19,  1, 18,  1, 17,  1, 16,  1, 15,  1, 14,  1, 13,  1 
    DB   32,  1, 31,  1, 30,  1, 29,  1, 28,  1, 27,  1, 26,  1, 25,  1
    DB   44,  1, 43,  1, 42,  1, 41,  1, 40,  1, 39,  1, 38,  1, 37,  1
    DB   56,  1, 55,  1, 54,  1, 53,  1, 52,  1, 51,  1, 50,  1, 49,  1
    DB  200,  0
    DB  255

SFX04_TRK2:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  200, 15                     ; Volume
    DB   19,  1, 18,  1, 17,  1, 16,  1, 15,  1, 16,  1, 15,  1, 14,  1
    DB   31,  1, 30,  1, 29,  1, 28,  1, 27,  1, 26,  1, 25,  1, 24,  1
    DB   43,  1, 42,  1, 41,  1, 40,  1, 39,  1, 38,  1, 37,  1, 36,  1
    DB   55,  1, 54,  1, 53,  1, 52,  1, 51,  1, 50,  1, 49,  1, 48,  1
    DB  200,  0
    DB  255 

SFX04_TRK3:
    DB  201,%00                     ; Noise/ToneSw 0:On,1:Off
    DB  202, 28                     ; NoiseTone
    DB  200, 13,  8,  1,200, 15,  8,  2,200, 13,  8,  2,200, 11,  8,  2
    DB  200,  6,  8,  2,200,  4,  8,  2,200,  2,  8,  2,200,  8,  8,  2
    DB  201,%11
    DB  255

; ----------------------------------------------------------------------------------------------------
; ブラスター発射音
; ----------------------------------------------------------------------------------------------------
SFX05:
    DB  0                           ; <未使用>テンポ(4分音符＝n/60秒とした場合の値)
    DW  $0000                       ; chAのトラックデータ
    DW  $0000                       ; chBのトラックデータ
    DW  SFX05_TRK3                  ; chCのトラックデータ

SFX05_TRK1:
    DB  255

SFX05_TRK2:
    DB  255

SFX05_TRK3:
    DB  201,%10                     ; Noise/ToneSw 0:On,1:Off
    DB  200, 15                     ; Volume
    DB   48,  1, 49,  1, 50,  1, 51,  1, 52,  1, 51,  1, 50,  1, 49,  1, 48,  1
    DB   47,  1, 46,  1, 45,  1, 44,  1, 43,  1, 42,  1, 41,  1, 40,  1, 39,  1, 38,  1, 37,  1, 36,  1
    DB   35,  1, 34,  1, 33,  1, 32,  1, 31,  1, 30,  1, 29,  1, 28,  1, 27,  1, 26,  1, 25,  1, 24,  1
    DB   23,  1, 22,  1, 21,  1, 20,  1, 19,  1, 18,  1, 17,  1, 16,  1, 15,  1, 14,  1, 13,  1, 12,  1
    DB  200,  0
    DB  255 

_18:
    DB  0
    DW  _18_TRK1
    DW  _18_TRK2
    DW  $0000
_18_TRK1:
    DB  201, %10, 200, 15, 45, 6, 200, 12, 45, 6, 200, 15, 45, 12, 42, 12
    DB  40, 12, 45, 12, 200, 0, 0, 12, 200, 15, 48, 24, 45, 6, 200, 12
    DB  45, 6, 200, 15, 45, 12, 42, 12, 40, 12, 45, 12, 200, 0, 0, 12
    DB  200, 15, 42, 24, 45, 6, 200, 12, 45, 6, 200, 15, 45, 12, 42, 12
    DB  40, 12, 45, 12, 48, 12, 50, 12, 51, 12, 52, 12, 51, 6, 52, 6
    DB  51, 6, 52, 6, 51, 6, 52, 24, 200, 12, 52, 6, 200, 15, 52, 6
    DB  51, 6, 49, 6, 47, 6, 45, 6, 200, 12, 45, 6, 200, 15, 45, 12
    DB  42, 12, 40, 12, 45, 12, 200, 0, 0, 12, 200, 15, 48, 24, 45, 6
    DB  200, 12, 45, 6, 200, 15, 45, 12, 42, 12, 40, 12, 45, 12, 200, 0
    DB  0, 12, 200, 15, 42, 24, 45, 6, 200, 12, 45, 6, 200, 15, 45, 12
    DB  42, 12, 40, 12, 45, 12, 48, 12, 50, 12, 51, 12, 57, 6, 200, 12
    DB  57, 6, 200, 15, 52, 6, 50, 6, 48, 12, 45, 12, 43, 12, 44, 12
    DB  45, 12, 200, 0, 0, 12
    DB  254
_18_TRK2:
    DB  201, %10, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 16, 6, 200, 0, 0, 6, 200, 15, 16, 6, 200, 0
    DB  0, 6, 200, 15, 28, 6, 200, 0, 0, 6, 200, 15, 28, 6, 200, 0
    DB  0, 6, 200, 15, 28, 6, 200, 0, 0, 6, 200, 15, 16, 6, 200, 0
    DB  0, 6, 200, 15, 18, 6, 200, 0, 0, 6, 200, 15, 20, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 14, 6, 200, 0, 0, 6, 200, 15, 26, 6, 200, 0
    DB  0, 6, 200, 15, 16, 6, 200, 0, 0, 6, 200, 15, 28, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 0, 0, 6, 0, 6
    DB  254

_19:
    DB  0
    DW  _19_TRK1
    DW  _19_TRK2
    DW  $0000
_19_TRK1:
    DB  201, %10, 200, 15, 51, 6, 52, 18, 49, 12, 52, 12, 54, 12, 49, 12
    DB  52, 12, 54, 12, 49, 12, 47, 12, 45, 12, 42, 12, 45, 48, 42, 12
    DB  45, 12, 47, 12, 45, 12, 49, 12, 47, 12, 45, 12, 47, 12, 49, 12
    DB  45, 24, 42, 12, 40, 48
    DB  254
_19_TRK2:
    DB  201, %10, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 14, 6, 200, 0, 0, 6, 200, 15, 14, 6, 200, 0
    DB  0, 6, 200, 15, 26, 6, 200, 0, 0, 6, 200, 15, 26, 6, 200, 0
    DB  0, 6, 200, 15, 14, 6, 200, 0, 0, 6, 200, 15, 14, 6, 200, 0
    DB  0, 6, 200, 15, 26, 6, 200, 0, 0, 6, 200, 15, 26, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6
    DB  254

_20:
    DB  0
    DW  _20_TRK1
    DW  _20_TRK2
    DW  $0000
_20_TRK1:
    DB  201, %10, 200, 15, 45, 12, 43, 12, 40, 12, 45, 12, 44, 12, 40, 12
    DB  38, 12, 40, 12, 38, 12, 36, 12, 33, 12, 38, 12, 37, 12, 33, 36
    DB  38, 12, 36, 12, 33, 12, 31, 12, 33, 12, 36, 12, 38, 12, 39, 12
    DB  40, 12, 44, 12, 40, 12, 38, 12, 37, 48
    DB  254
_20_TRK2:
    DB  201, %10, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 14, 6, 200, 0, 0, 6, 200, 15, 14, 6, 200, 0
    DB  0, 6, 200, 15, 26, 6, 200, 0, 0, 6, 200, 15, 26, 6, 200, 0
    DB  0, 6, 200, 15, 14, 6, 200, 0, 0, 6, 200, 15, 14, 6, 200, 0
    DB  0, 6, 200, 15, 26, 6, 200, 0, 0, 6, 200, 15, 26, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6, 200, 15, 21, 6, 200, 0, 0, 6, 200, 15, 21, 6, 200, 0
    DB  0, 6, 200, 15, 33, 6, 200, 0, 0, 6, 200, 15, 33, 6, 200, 0
    DB  0, 6
    DB  254

; ----------------------------------------------------------------------------------------------------
; 以降はサウンドドライバでは未使用
; ----------------------------------------------------------------------------------------------------
; ■キースキャン用定数
KEY_ON:                 EQU $01     ; キーオン
KEY_OFF:                EQU $00     ; キーオフ

; ■フォントパターンデータ
; &H0100〜
FONT_PTN_DATA:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $1C,$1C,$18,$18,$10,$00,$30,$30
    DB $36,$36,$12,$24,$00,$00,$00,$00
    DB $36,$36,$7F,$36,$7F,$36,$36,$00
    DB $08,$3E,$68,$3E,$0B,$3E,$08,$00
    DB $71,$52,$64,$08,$13,$25,$47,$00
    DB $30,$48,$58,$33,$6A,$44,$3B,$00
    DB $18,$18,$08,$10,$00,$00,$00,$00
    DB $0C,$18,$30,$30,$30,$18,$0C,$00
    DB $18,$0C,$06,$06,$06,$0C,$18,$00
    DB $18,$5A,$3C,$18,$3C,$5A,$18,$00
    DB $00,$18,$18,$7E,$18,$18,$00,$00
    DB $00,$00,$00,$00,$30,$10,$20,$00
    DB $00,$00,$00,$3E,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$18,$18,$00
    DB $03,$07,$0E,$1C,$38,$70,$60,$00
    DB $1C,$26,$63,$63,$63,$32,$1C,$00
    DB $0C,$1C,$0C,$0C,$0C,$0C,$3F,$00
    DB $3E,$63,$07,$1E,$3C,$70,$7F,$00
    DB $3F,$06,$0C,$1E,$03,$63,$3E,$00
    DB $0E,$1E,$36,$66,$7F,$06,$06,$00
    DB $7E,$60,$7E,$03,$03,$63,$3E,$00
    DB $1E,$30,$60,$7E,$63,$63,$3E,$00
    DB $7F,$63,$06,$0C,$18,$18,$18,$00
    DB $3C,$62,$72,$3C,$4F,$43,$3E,$00
    DB $3E,$63,$63,$3F,$03,$06,$3C,$00
    DB $00,$18,$18,$00,$18,$18,$00,$00
    DB $00,$18,$18,$00,$18,$08,$10,$00
    DB $06,$0C,$18,$30,$18,$0C,$06,$00
    DB $00,$00,$7F,$00,$00,$7F,$00,$00
    DB $30,$18,$0C,$06,$0C,$18,$30,$00
    DB $3E,$63,$63,$06,$0C,$00,$0C,$0C
    DB $3E,$41,$5D,$55,$5F,$4C,$3E,$00
    DB $1C,$36,$63,$63,$7F,$63,$63,$00
    DB $7E,$63,$63,$7E,$63,$63,$7E,$00
    DB $1E,$33,$60,$60,$60,$33,$1E,$00
    DB $7C,$66,$63,$63,$63,$66,$7C,$00
    DB $3F,$30,$30,$3E,$30,$30,$3F,$00
    DB $7F,$60,$60,$7E,$60,$60,$60,$00
    DB $1F,$30,$60,$67,$63,$33,$1F,$00
    DB $63,$63,$63,$7F,$63,$63,$63,$00
    DB $3F,$0C,$0C,$0C,$0C,$0C,$3F,$00
    DB $03,$03,$03,$03,$03,$63,$3E,$00
    DB $63,$66,$6C,$78,$7C,$6E,$67,$00
    DB $30,$30,$30,$30,$30,$30,$3F,$00
    DB $63,$77,$7F,$7F,$6B,$63,$63,$00
    DB $63,$73,$7B,$7F,$6F,$67,$63,$00
    DB $3E,$63,$63,$63,$63,$63,$3E,$00
    DB $7E,$63,$63,$63,$7E,$60,$60,$00
    DB $3E,$63,$63,$63,$6F,$66,$3D,$00
    DB $7E,$63,$63,$67,$7C,$6E,$67,$00
    DB $3C,$66,$60,$3E,$03,$63,$3E,$00
    DB $3F,$0C,$0C,$0C,$0C,$0C,$0C,$00
    DB $63,$63,$63,$63,$63,$63,$3E,$00
    DB $63,$63,$63,$77,$3E,$1C,$08,$00
    DB $63,$63,$6B,$7F,$7F,$77,$63,$00
    DB $63,$77,$3E,$1C,$3E,$77,$63,$00
    DB $33,$33,$33,$1E,$0C,$0C,$0C,$00
    DB $7F,$07,$0E,$1C,$38,$70,$7F,$00
    DB $3C,$30,$30,$30,$30,$30,$3C,$00
    DB $66,$3C,$18,$7E,$18,$7E,$18,$00
    DB $3C,$0C,$0C,$0C,$0C,$0C,$3C,$00
    DB $1C,$36,$63,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$7F,$00

; ■表示文字列データ
; dw : 表示先のVRAMアドレスのオフセット値(下位/上位)    
; db : 表示文字列、最後に0を設定すること
STRDATA1:
    DW 32*3+6
	DB "MSX PSG DRIVER TEST",0
STRDATA2:
    DW 32*4+6
	DB "-------------------",0
STRDATA3:
    DW 32*7+3
	DB "[1] BGM(XEVIOUS)",0
STRDATA4:
    DW 32*8+3
	DB "[2] BGM(NEW RALLY-X BGMC)",0
STRDATA5:
    DW 32*9+3
	DB "[3] BGM(NEW RALLY-X BGMA)",0
STRDATA6:
    DW 32*10+3
	DB "[4] BGM(NEW RALLY-X BGMB)",0
STRDATA7:
    DW 32*11+3
	DB "[5] SFX(XEVIOUS CREDIT)",0
STRDATA8:
    DW 32*12+3
	DB "[6] SFX(XEVIOUS ZAPPER)",0
STRDATA9:
    DW 32*13+3
	DB "[7] SFX(XEVIOUS BLASTER)",0
STRDATA10:
    DW 32*14+3
	DB "[8] SFX(XEVIOUS DESTRUCTION)",0
STRDATA11:
    DW 32*15+3
	DB "[9] SFX(XEVIOUS BACULLA)",0
STRDATA12:
    DW 32*15+3
	DB "[0] STOP",0
CURDATA0:
    DB " ",0
CURDATA1:
    DB ">",0

; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================
SECTION bss_user

; ----------------------------------------------------------------------------------------------------
; ドライバステータス
; ----------------------------------------------------------------------------------------------------
SOUNDDRV_STATE:
    DB  SOUNDDRV_STATE_STOP         ; サウンドドライバ状態初期値

; ----------------------------------------------------------------------------------------------------
; ドライバワークエリア
; ----------------------------------------------------------------------------------------------------
SOUNDDRV_WK_MIXING_TONE:
    DB  %00000000                   ; PSGレジスタ7のWK(bit7〜5:Tone設定用)計算用
SOUNDDRV_WK_MIXING_NOISE:
    DB  %00000000                   ; PSGレジスタ7のWK(bit7〜5:Noise設定用)計算用
SOUNDDRV_WK_NOISETONE_BGM:
    DB  0                           ; PSGレジスタ6のWK(BGM)
SOUNDDRV_WK_NOISETONE_SFX:
    DB  0                           ; PSGレジスタ6のWK(SFX)
SOUNDDRV_WK_VOL:
    DB  0                           ; PSGレジスタ8 (BGMトラック1)
    DB  0                           ; PSGレジスタ9 (BGMトラック2)
    DB  0                           ; PSGレジスタ10(BGMトラック3)

; ----------------------------------------------------------------------------------------------------
; BGMワークエリア
; ----------------------------------------------------------------------------------------------------
SOUNDDRV_BGMWK:
    ; BGMトラック1(=ChA)
    DB  $00                         ; ウェイトカウンタ(1音＝n/60秒)
    DW  $0000                       ; トラックデータのデチューン値取得アドレス
    DW  $0000                       ; トラックデータの先頭アドレス
    DB  $00                         ; デチューン
    DB  $00                         ; ミキシング (bit0=Tont,bit1=Noise 0=On,1=Off)
    DB  $00                         ; 予備
    ; BGMトラック2(=ChB)
    DB  $00                         ; ウェイトカウンタ(1音＝n/60秒)
    DW  $0000                       ; トラックデータの取得アドレス
    DW  $0000                       ; トラックデータの先頭アドレス
    DB  $00                         ; デチューン
    DB  $00                         ; ミキシング (bit0=Tont,bit1=Noise 0=On,1=Off)
    DB  $00                         ; 予備
    ; BGMトラック3(ChC)
    DB  $00                         ; ウェイトカウンタ(1音＝n/60秒)
    DW  $0000                       ; トラックデータの取得アドレス
    DW  $0000                       ; トラックデータの先頭アドレス
    DB  $00                         ; デチューン
    DB  $00                         ; ミキシング (bit0=Tont,bit1=Noise 0=On,1=Off)
    DB  $00                         ; 予備

SOUNDDRV_DUMMYWK:
    ; ダミー
    DB  $00
    DW  $0000
    DW  $0000
    DB  $00
    DB  $00
    DB  $00

; ----------------------------------------------------------------------------------------------------
; SFXワークエリア
; ----------------------------------------------------------------------------------------------------
SOUNDDRV_SFXWK:
    ; SFXトラック1(=ChA)
    DB  $00                         ; ウェイトカウンタ(1音＝n/60秒)
    DW  $0000                       ; トラックデータの取得アドレス
    DW  $0000                       ; トラックデータの先頭アドレス
    DB  $00                         ; デチューン
    DB  $00                         ; ミキシング (bit0=Tont,bit1=Noise 0=On,1=Off)
    DB  $00                         ; 予備
    ; SFXトラック2(=ChB)
    DB  $00                         ; ウェイトカウンタ(1音＝n/60秒)
    DW  $0000                       ; トラックデータの取得アドレス
    DW  $0000                       ; トラックデータの先頭アドレス
    DB  $00                         ; デチューン
    DB  $00                         ; ミキシング (bit0=Tont,bit1=Noise 0=On,1=Off)
    DB  $00                         ; 予備
    ; SFXトラック3(=ChC)
    DB  $00                         ; ウェイトカウンタ(1音＝n/60秒)
    DW  $0000                       ; トラックデータの取得アドレス
    DW  $0000                       ; トラックデータの先頭アドレス
    DB  $00                         ; デチューン
    DB  $00                         ; ミキシング (bit0=Tont,bit1=Noise 0=On,1=Off)
    DB  $00                         ; 予備

; ----------------------------------------------------------------------------------------------------
; その他ワークエリア（ドライバでは未使用）
; ----------------------------------------------------------------------------------------------------
; ■トリガ入力バッファ
STRIG_BUFF:
    DB 0

; ■キー入力バッファ
KEYBUFF:
    DB  $00,$00,$00,$00,$00,$00,$00,$00
    DB  $00,$00,$00,$00,$00,$00,$00,$00
KEYBUFF_SV:
    DB  $00,$00,$00,$00,$00,$00,$00,$00
    DB  $00,$00,$00,$00,$00,$00,$00,$00
