■コンパイル

コマンドラインより以下を実行
sdasz80 -ls -o asm01.o asm01.asm
sdld -nf asm01.rel
ihx2bin asm01.ihx asm01.bin

■実行

blueMSXで[ファイル]-[ディスクドライブA]-[ディレクトリ挿入]
このフォルダを指定
「files」で中身を確認
「RUN"asm01.bas"」で実行
