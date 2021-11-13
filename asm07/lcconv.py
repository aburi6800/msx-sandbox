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
#       value*0.25 (端数切捨)
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
    def __init__(self, jsonFileName:str):
        # 出力データクラスを初期化
        dc = self.dataClass(jsonFileName)

        # 変換処理実行
        dc.convert()

        # 出力データクラスからファイルに出力
        dc.export()

        # 終了
        pass

    class dataClass:
        '''
        クラス変数
        '''
        # jsonデータのリスト
        data_header = []
        data_body = []

        # ダンプデータ
        dumpData = [0, 0, 0]

        # ベースとなるspeed値
        speed = 0

        '''
        出力データクラス
        '''
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

            # sl要素の全てに対して繰り返す(0～15)
            for vl in sl:

                # データバッファ初期化
                buffer = []

                # vl要素の全てに対して繰り返す(0～32)
                for v in vl["vl"]:

                    # トーン値
                    tone = v["n"]
                    # ボリューム値
                    volume = v["x"]
                    # 音色
                    voice = v["id"]

                    # トーン=None and ボリューム値=0の場合は、noneCountをインクリメント、以外はリセット
                    if (tone is None):
                        noneCount += 1
                    else:
                        noneCount = 0

                    # テスト用
                    if v["id"] != 4:
                        s = "tone note:" + str(v["n"])
                    else:
                        s = "noise tone:" + str(v["n"])
                    s += " volume:" + str(v["x"])
                    buffer = buffer + [tone, self.speed]

                    # NoneCout=32ならループ終了
                    if noneCount == 32:
                        isTerminate = True
                        break

                # ここまでのバッファをデータに追加
                if isTerminate == False:
                    data = data + buffer

            # データを返却
            return data

        def export(self):
            '''
            ファイルエクスポート処理
            '''
            pass

if __name__ == "__main__":
    '''
    アプリケーション実行
    '''
    lcconv("./sample.json")
