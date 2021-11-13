# -*- coding: utf-8 -*-
# 
# lcconv.py
#
# LovelyComposerのデータをMSX用のASMソース形式に変換する。
#
# 仕様：
# - LCのjsonデータから、ChA～Cのデータを対象として処理する。ChD、コードのデータは無視する。
# - speed値を1/2として、1ノートの音長とする(1未満=1とする)
# - トーン('n')
#   - o4aはlc＝69,ドライバのデータ=45なので、以下で計算。
#       value - 24
#     ※MSXではo8まで指定可能だが、lcではo7までになる
#   - 連続して同じトーンが出てきても、別データとして生成する。
#       例) T150でCDEE → c,8,d,8,e,8,e,8 のイメージ(実際は音階はテーブルのidx値)
#   - トーンが無い(=none)場合は、音階0、ボリューム0で音長のみ設定したデータとする
#   - LCSoundの要素(32個)全てnoneのデータが出てきたら、そこでチャネルの処理を終了する(255)
#   - 音長は以下で計算する。
#       (speed / 2) (端数切捨) ※ここは結構影響が大きいので、後で要調整
# - ボリューム('x')
#   - 12を15、1を1とする。以下で計算。
#       value*1.25 (端数切捨)
#   - 直前のデータと値が変わらない場合はデータを出力しない。
# - PSGR#7 (ノイズ/トーンのミキシング)
#   - 以下の音色はノイズとし、以外をトーンとする
#       id=4
#   - 直前のトーンが同じ(ノイズ→ノイズ、トーン→トーン)場合は変更不要とする
#   - LCの音色でノイズとトーンを同時に出すものがないので（だよね？）、常にどちらかとなる。
# - PSGR#6 (ノイズトーン)
#   - ノイズの場合に対象のトーンにより決定、以下で計算する。([低]MSX32/lc24～[高]MSX0/lc107)
#       (107 - value) / 2.59 (端数切捨)
# - ハードウェアエンベロープは使わない。(複数チャンネルで波形が同じになるため、使いにくい)
# - ファイル出力はLCSoundデータ単位に行う(=LCVoiceの要素、32トーン)
import json
import os

class lcconv:
    '''
    lcconvクラス
    '''
    # 出力データクラス
    dc = None

    def __init__(self, jsonFileName:str):
        '''
        クラス初期化
        '''
        # 出力データクラスを初期化
        self.dc = self.dataClass(jsonFileName)

    def execute(self, outFileName:str):
        '''
        変換処理実行
        '''
        # 変換処理実行
        self.dc.convert()

        # 出力データクラスからファイルに出力
        self.dc.export(outFileName)

    class dataClass:
        '''
        出力データクラス
        '''
        # jsonデータのリスト
        data_header = []
        data_body = []

        # ダンプデータ
        dumpData = [0, 0, 0]

        # ベースとなるspeed値
        speed = 0

        # 出力ファイル名
        outfilePath = ""

        def __init__(self, jsonFileName:str = ""):
            '''
            初期化処理
            '''
            # 引数のjsonFileNameのjsonファイルを読み込み
            filePath = os.path.normpath(os.path.join(os.path.dirname(__file__), jsonFileName))
            with open(filePath) as f:
                df_header = f.readline()
                df_body = f.readline()

            # jsonデータをパース
            self.data_header = json.loads(df_header)
            self.data_body = json.loads(df_body)

        def convert(self):
            '''
            変換処理
            '''
            # speed値取得
            self.speed = (self.data_body["speed"]) // 2
            print("speed = " + str(self.speed))

            # 各チャネルのデータを取得
            channels = (self.data_body["channels"])["channels"]
            channelList = list(channels)

            # チャネル1～3に大してダンプデータ作成
            self.dumpData[0] = self.makeDumpData(channelList[0])
            print(self.dumpData[0])
            self.dumpData[1] = self.makeDumpData(channelList[1])
            print(self.dumpData[1])
            self.dumpData[2] = self.makeDumpData(channelList[2])
            print(self.dumpData[2])
            pass

        def makeDumpData(self, data):
            '''
            ダンプデータ作成処理
            '''
            # 'sl'要素を取り出す
            sl = data["sl"]

            # データバッファ
            buffer = []

            # 出力データ
            data = []

            # 空データカウント
            noneCount = 0

            # 終了判定フラグ
            isTerminate = False

            # 各値の退避変数を初期化
            svVoice = None
            svTone = None
            svVolume = None
            svNoiseTone = None

            # 音長
            time = 0

            # sl要素の全てに対して繰り返す(0～15)
            for vl in sl:

                # データバッファ初期化
                buffer = []

                # vl要素の全てに対して繰り返す(0～31)
                for v in vl["vl"]:

                    # voice,tone,volumeのいずれかが直前のデータと違っていたら、データをバッファに書き出す
                    # ただし一番最初の時は直前の値が全てNoneなので何もしない
                    if (svVolume != None):
                        if (svVoice != v["id"] or svTone != v["n"] or svVolume != v["x"]):
                            # バッファにこれまでのトーンと時間を書き出す
                            if svVoice != "4":
                                # トーンの時の処理
                                buffer += [str(self.getToneValue(svTone)), str(time)]
                            else:
                                # ノイズの時の処理
                                noiseTone = self.getNoiseToneValue(svTone)
                                if noiseTone != svNoiseTone:
                                    buffer += ["202", str(noiseTone)]
                                    svNoiseTone = noiseTone
                                buffer += [str(self.getToneValue(svTone)), str(time)]
                            #音長をリセット
                            time = 0

                    # voiceが直前と変わったか判定する
                    # 変わった場合はPSGR#6,#7の設定をバッファに出力する
                    # データの最初にも設定が必要であるため、無条件で処理する
                    if svVoice != v["id"] and svVoice != None and v["id"] != None:
                        buffer += ["201", self.getMixingValue(v["id"])]

                    # volumeが変わったか判定する
                    # 変わった場合はPSGR#8〜10に設定するためのデータをバッファに出力する
                    if svVolume != v["x"]:
                        buffer += ["200", str(self.getVolumeValue(v["x"]))]

                    # 音長をカウント
                    time += self.speed

                    # トーン=None and ボリューム値=0の場合は、noneCountをインクリメント、以外はリセット
                    if (svTone is None):
                        noneCount += 1
                    else:
                        noneCount = 0

                    # tone,voice,volumeの値を退避
                    svTone = v["n"] 
                    svVoice = v["id"]
                    svVolume = (v["x"] if v["x"] != None else svVolume)

                    # NoneCout=32ならループ終了
                    if noneCount == 32:
                        isTerminate = True
                        break

                if (time > 0):
                    # バッファにこれまでのトーンと時間を書き出す
                    if svVoice != "4":
                        # トーンの時の処理
                        buffer += [str(self.getToneValue(svTone)), str(time)]
                    else:
                        # ノイズの時の処理
                        noiseTone = self.getNoiseToneValue(svTone)
                        if noiseTone != svNoiseTone:
                            data += ["202", str(noiseTone)]
                            svNoiseTone = noiseTone
                        buffer += [str(self.getToneValue(svTone)), str(time)]

                # バッファをデータに追加
                if isTerminate == False:
                    data += buffer

            # データを返却
            return data

        def getToneValue(self, tone:int) -> int:
            '''
            トーン値取得処理
            '''
            return (tone - 24 if tone != None else 0)

        def getNoiseToneValue(self, tone:int) -> int:
            '''
            ノイズトーン値取得処理
            '''
            return int(107-int((tone if tone != None else 1))/2.59)

        def getMixingValue(self, voice:int) -> str:
            '''
            ミキシング値取得処理
            '''
            return ("10" if voice == 4 else "01")

        def getVolumeValue(self, volume:int) -> int:
            '''
            ボリューム値取得処理
            '''
            return int(volume*1.25)

        def export(self, outFileName:str):
            '''
            ファイルエクスポート処理
            '''
            # 出力ファイル名
            outfilePath = os.path.normpath(os.path.join(os.path.dirname(__file__), outFileName))

            with open(outfilePath, mode="w") as f:
                # ヘッダー情報
                for idx in range(3):
                    if len(self.dumpData[idx]) > 0:
                        f.write("    DW  TRK0" + str(idx+1) + "\n")
                    else:
                        f.write("    DW  $0000" + "\n")

                # 各チャンネルのデータ
                for idx, ch in enumerate(self.dumpData):
                    if len(ch) == 0:
                        break
                    else:
                        f.write("TRK0" + str(idx+1) + ":" + "\n")
                        s = ""
                        for i, v in enumerate(ch):
                            if i % 16 == 0:
                                if s != "":
                                    f.write(s + "\n")
                                s = "    DB   " + v
                            else:
                                s += ", " + v

if __name__ == "__main__":
    '''
    アプリケーション実行
    '''
    c = lcconv("./sample.json")
    c.execute("./out.asm")
