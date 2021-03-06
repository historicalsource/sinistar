100 DIM T$(100,100)
110 LINPUT "INPUT  ";FILE_INPUT$
120 OPEN FILE_INPUT$ FOR INPUT AS FILE #1,ACCESS READ
130 LINPUT "OUTPUT ";FILE_OUTPUT$
140 OPEN FILE_OUTPUT$ FOR OUTPUT AS FILE #2, ACCESS WRITE,ORGANIZATION SEQUENTIAL VARIABLE
150 INPUT #1,S0$		!SAVE THE S0 RECORD
160 REM ***** PROCESS THE X AND Y SIZE RECORDS
170 INPUT #1,A$
180 X$=MID$(A$,17,2)
200 GOSUB 10000		!CONVERT XSIZE TO DECIMAL
210 XLEN=X1
220 X$=MID$(A$,19,2)
240 GOSUB 10000		!CONVERT Y SIZE TO DECIMAL
250 YLEN=X1
300 REM ***** PROCESS THE COLOR RECORDS
310 INPUT #1,COLOR1$
320 INPUT #1,COLOR2$
330 PRINT #2,"* FILE: "+FILE_INPUT$+" "+MID$( COLOR1$, 9 , 32)+MID$( COLOR2$, 9 , 32)

600 REM ***** PROCESS THE IMAGE RECORDS
602 INPUT #1,A$
604 K=9			!POINTER TO NEXT HEX BYTE
610 FOR I=1 TO XLEN
620 FOR J=1 TO YLEN
630 IF K+1<>LEN(A$) THEN 640
632 INPUT #1,A$
634 K=9			!IGNORE FIRST 8 CHARACTERS
640 T$(I,J)=MID$(A$,K,2)
642 K=K+2
650 NEXT J
660 NEXT I
670 CLOSE #1		!THATS ALL THE RECORDS WE NEED

700 REM
701 REM		FIND TRUE PIXEL_X & PIXEL_Y SIZE
702 REM
710 PIXEL_X = 0
720 PIXEL_Y = 0
730 FOR J = 1 TO YLEN
740 FLAG = 0
750 FOR I = 1 TO XLEN
760 IF MID$(T$(I,J) , 1 , 1) <> "0" AND I*2-1 > PIXEL_X THEN PIXEL_X = I*2-1
770 IF MID$(T$(I,J) , 2 , 1) <> "0" AND I*2+0 > PIXEL_X THEN PIXEL_X = I*2+0
780 IF T$(I,J) <> "00" THEN FLAG = 1
790 NEXT I
800 IF FLAG <> 0 THEN PIXEL_Y = PIXEL_Y + 1
810 NEXT J

0900 REM
0901 REM	WRITE OUT THE SIZE RECORD & THE DATA
0902 REM
0910 PRINT #2,"*	PIXEL SIZE "+STR$(PIXEL_X)+","+STR$(PIXEL_Y)+"	BYTE SIZE "+STR$(XLEN)+","+STR$(YLEN)
0920 FOR J = 1 TO YLEN
0930 FOR I = 1 TO XLEN
0940 A$ = MID$( T$( I,J ) , 1 , 1 )
0950 IF A$ = "0" THEN A$ = "."
0970 B$ = MID$( T$( I,J ) , 2 , 1 )
0980 IF B$ = "0" THEN B$ = "."
0990 PRINT #2,A$;B$;
1000 NEXT I
1010 PRINT #2,""
1020 NEXT J
1170 CLOSE #2
1180 GOTO 30000			!**** END OF PROGRAM ****

1800 REM **************** WRITES OUT A RECORD
1802 REM IT FIRST INSERTS THE SIZE, THEN CALCULATE
1804 REM A CHEKSUM THEN WRITES RECORD
1806 X1=BYTC
1808 GOSUB 10200 !CONVERT TO HEX
1810 L$="S1"+X$+L$
1820 SUM=SUM+BYTC
1830 X1=255-(SUM-INT(SUM/256)*256)
1840 GOSUB 10200	!CONVERT TO HEX
1850 L$=L$+X$
1860 PRINT #2,L$
1870 RETURN
1900 REM **************** STARTS A NEW RECORD
1910 SUM=XSCR+YSCR
1920 BYTC=3
1940 X1=XSCR
1950 GOSUB 10200	!CONVERT TO HEX
1960 L$=X$	!X ADDRESS
1970 X1=YSCR
1980 GOSUB 10200 !	"
1990 L$=L$+X$	!Y ADDRESS
2000 RETURN  
10000 REM *********************************************
10010 REM THIS SUBROUTINE ASSUMES A VALID 2 DIGIT HEX
10020 REM VALUE TO BE IN X$.  IT RETURNS THE DECIMAL
10030 REM VALUE IN X1
10035 Y$=MID$(X$,2,1)
10040 X$=MID$(X$,1,1)
10050 IF X$>"9" THEN 10100
10060 X1=VAL(X$)*16
10070 GOTO 10150
10100 X1=(ASC(X$)-55)*16
10150 IF Y$>"9" THEN 10180
10160 X1=X1+VAL(Y$)
10170 GOTO 10190
10180 X1=X1+ASC(Y$)-55
10190 RETURN
10200 REM *********************************************
10210 REM  THIS SUBROUTINE TAKES THE VALUE IN X1
10220 REM  (ASSUMES 0-255) AND RETURNS X$ - A 2 DIGIT
10230 REM  HEX BYTE EQUIVALENT.
10240 I=INT(X1/16)
10250 IF I>9 THEN 10280
10260 X$=CHR$(48+I)
10270 GOTO 10290
10280 X$=CHR$(55+I)
10290 J=INT(X1-I*16)
10300 IF J>9 THEN 10330
10310 X$=X$+CHR$(48+J)
10320 GOTO 10340
10330 X$=X$+CHR$(55+J)
10340 RETURN
30000 END
