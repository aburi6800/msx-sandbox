# ASM07

## 概要

H.TIMI割り込みを使用したPSGサウンドドライバです。
- 効果音の割り込み再生に対応
- 効果音の再生優先度（プライオリティ）を設定可能
- ノイズON/OFF、トーン、ノイズトーン、ボリューム、デチューンに対応
- lcsonv.pyでLovelyComposerで制作したデータから変換して使用可能（制約あり）

## 使用方法

### 事前準備

- プログラムの初期処理で、ドライバの初期化ルーチン(SOUNDDRV_INIT)をCALL
- H.TIMIのフックを書き換えて、ドライバの演奏処理(SOUNDDRV_EXEC)へJPするコードを書き込む
```
    DI                              ; 割り込み禁止
    LD A,$C3                        ; JP
    LD HL,SOUNDDRV_EXEC             ; サウンドドライバのアドレス
    LD (H_TIMI+0),A
    LD (H_TIMI+1),HL
    EI                              ; 割り込み許可
```

### ドライバのAPI

上記の事前準備を行った後は、ユーザープログラムからは以下の手順で制御できます。

- `SOUNDDRV_BGMPLAY`
    - BGMの再生を開始する。
    - HLレジスタに再生するBGMデータのアドレスを指定する。
```
    LD HL,BGMDATA
    CALL SOUNDDRV_BGMPLAY
```
- `SOUNDDRV_SFXPLAY`
    - 効果音を再生する。既にプライオリティの高い効果音が再生中の場合は再生しない。
    - HLレジスタに再生する効果音データのアドレスを指定する。
```
    LD HL,SFXDATA
    CALL SOUNDDRV_BGMPLAY
```
- `SOUNDDRV_STOP`
    - BGM、効果音の再生を停止する。
```
    CALL SOUNDDRV_STOP
```

## データ構造

このドライバで扱うデータ構造は、以下のイメージです。
BGM、効果音共に同じ構成になります。
```
[BGM/SFX Data]
  +- [Track 1 Data Address](2byte)
  +- [Track 2 Data Address](2byte)
  +- [Track 3 Data Address](2byte)
```
> すなわち、効果音として作成したデータをBGMとして鳴らすこともできますし、その逆も可能です。
> また、トラックデータは複数のBGM/効果音データで同じアドレスを指定することで使い回すこともできます。

### 曲/効果音データ

BGM/効果音データの構成を定義します。

- プライオリティ(1byte)：0～255（低～高）、効果音発声時のみ有効、BGMでは無視される。
- トラック1のデータアドレス(2byte)：ない場合は`$0000`を設定する。
- トラック2のデータアドレス(2byte)：ない場合は`$0000`を設定する。
- トラック3のデータアドレス(2byte)：ない場合は`$0000`を設定する。

### トラックデータ

トラックデータは、データ終端以外は、[ノート or コマンド],[値]の組み合わせで構成されます。

| コマンド | 概要 | 値 |
|:---|:---|:---|
| 0〜95 | ノート(トーンテーブルのindex番号) | 音長(n/60)を指定 |
| 200 | ボリューム | 0〜15を指定(PSGレジスタ#8〜#10に設定する値と同じ) |
| 201 | ミキシング | 0〜3を指定(bit0=Tone/bit1=Noise、1=off/0=on) |
| 202 | ノイズトーン | 0〜31を指定(PSGレジスタ#6に設定する値と同じ) |
| 210 | デチューン | ノートに対する補正値を指定 |
| 254 | データ終端(トラック先頭に戻る) | なし |
| 255 | データ終端(再生終了) | なし |

### 音長について

音調は以下で求められます。

- 1秒あたりの発音数：テンポ/60秒
- 4分音符の音長：60/(1秒あたりの発音数)
- 8分音符の音長：4分音符の音長/2
- 16分音符の音長：8分音符の音長/2

例)テンポ120の場合 (=1分間に4分音符を120回鳴らす速度)
- 1秒あたりの発音数：120/60秒 = 2
- 4分音符の音長：60/(1秒あたりの発音数) = 60/2 = 30
- 8分音符の音長：30 / 2 = 15
- 16分音符の音長：15 / 2 = 7.5
 
> データに設定する値は整数なので、端数が出る場合は、ノートの音長の合計で辻褄が合うように調整してください。

## 改訂履歴

2021/11/19 Ver1.0
- 効果音の割り込み再生に対応
- 効果音の再生優先度（プライオリティ）を設定可能
- ノイズON/OFF、トーン、ノイズトーン、ボリューム、デチューンに対応
- lcsonv.pyでLovelyComposerで制作したデータから変換して使用可能（制約あり）