100 SCREEN 1,2,0:WIDTH 32:KEY OFF:COLOR 15,4,7
110 CLEAR 200,&HBFFF:DEFUSR=&HC000
120 BLOAD "ASM01.BIN"
130 FORI=0TO24:LOCATE25,I:PRINT"|";:NEXT
140 LOCATE26,1:PRINT"SCROLL";:LOCATE26,2:PRINT" DEMO";  
150 FORI=0TO30:LOCATEINT(RND(1)*25),INT(RND(1)*25):PRINT"*";:NEXT
160 A=USR(0):LOCATEINT(RND(1)*25),0:PRINT"*";:GOTO160
