$ IF VERSION .EQ. 16 THEN GOTO _VOK
$	show symbol VERSION
$	write SYS$OUTPUT "The symbol VERSION must be 15 in your login."
$	write SYS$OUTPUT "PROCEEDURE ABORTING."
$	write SYS$OUTPUT "Restart when condition has been corrected."
$	EXIT
$_VOK:
$ ESC[0,8] = %X1B
$ write SYS$OUTPUT ESC,"[24;1H "	! Clear bottom two lines of the screen
$ write SYS$OUTPUT " "			!   for informational use.
$ write SYS$OUTPUT ESC,"[1;22r"		! Set scrolling region
$ write SYS$OUTPUT ESC,"[24;1H",ESC,"#6",ESC,"[7mVERSION ''VERSION'",ESC,"[0m"
$ ON ERROR THEN GOTO _EXIT
$ ON CONTROL_Y THEN GOTO _EXIT
$_NAME:
$ write SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: [MESSAGE,SAM,RICH,NOAH,BOB,LIBCHK,Control-Y]"
$ write SYS$OUTPUT ESC,"[21;1H"			! Position cursor
$ INQUIRE PGMR_NAME "What is your name?"	!   for inquiry.
$ IF PGMR_NAME .EQS. "MESSAGE" THEN GOTO _'PGMR_NAME'
$ IF PGMR_NAME .EQS. "NOAH" THEN GOTO _NOAH
$ IF PGMR_NAME .EQS. "RICH" THEN GOTO _'PGMR_NAME'
$ IF PGMR_NAME .EQS. "BOB" THEN GOTO _BOB
$ IF PGMR_NAME .EQS. "LIBCHK" THEN GOTO _LIBCHK
$ GOTO _NAME
$_MESSAGE
$!
$!  M   M  EEEEE   SSSS   SSSS   AAA    GGGG  EEEEE
$!  MM MM  E      S      S      A   A  G      E
$!  M M M  EEEE    SSS    SSS   AAAAA  G GGG  EEEE
$!  M   M  E          S      S  A   A  G   G  E
$!  M   M  EEEEE  SSSS   SSSS   A   A   GGG   EEEEE
$!
$ set default [witt.v'VERSION']
$!
$! Reset MESSAGE.SYM
$!
$ ab message slow
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the first assembly to finish."
$ synchronize MESSSAGESLOW/queue=SYS$SLOW
$ @[witt.v'VERSION']capture SLOW @[witt.v'VERSION']symver message.lis message y
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the symbol capturing to finish."
$ synchronize CAPTURE/queue=SYS$SLOW
$ ab richs slow
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "Please examine MESSAGE.LOG to determine if there are any errors."
$ write SYS$OUTPUT "Then login as SAM and begin his portion of the release."
$	GOTO _EXIT
$!
$!  N   N   OOO    AAA   H   H
$!  NN  N  O   O  A   A  H   H
$!  N N N  O   O  AAAAA  HHHHH
$!  N  NN  O   O  A   A  H   H
$!  N   N   OOO   A   A  H   H
$!
$_NOAH:
$ set DEFAULT [fals]
$ @login
$ set DEFAULT [fals.v'VERSION']
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now search RICHS.EQU for the symbol _1"
$ write SYS$OUTPUT "If it is not found, then the $Symbols were not edited to _Symbols."
$ search [witt.v'VERSION']richs.equ "_1"
$N_SYMBOLS:
$ write SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ write SYS$OUTPUT ESC,"[21;1H"
$ INQUIRE YES_NO "Was the _1 symbol found?"
$ IF YES_NO .EQS. "YES" THEN GOTO N_SET
$ IF YES_NO .EQS. "Y" THEN GOTO N_SET
$ IF YES_NO .EQS. "NO" THEN GOTO N_NO_SET
$ IF YES_NO .EQS. "N" THEN GOTO N_NO_SET
$ GOTO N_SYMBOLS
$N_NO_SET:
$ WRITE SYS$OUTPUT "Please go back and edit RICHS.EQU and change"
$ WRITE SYS$OUTPUT "all the $Symbols to _Symbols now."
$ GOTO _EXIT
$!
$! Reset NOAHS.SET and NOAHS.SYM
$!
$N_SET:
$ search/output=noahs.set [witt.v'VERSION']richs.equ "	SET	"
$ copy [witt]null.src [fals.v'VERSION']noahs.sym
$ copy [witt]null.src [fals.v'VERSION']noah.sym	! For the work files.
$ a9s [fals.v'VERSION']noahs
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the first assembly to finish."
$ synchronize ASM09/queue=SYS$SLOW
$ @[witt.v'VERSION']capture SLOW @[fals.v'VERSION']symver noahs.lis noahs y
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the symbol capturing to finish."
$ synchronize CAPTURE/queue=SYS$SLOW
$ delete noahs.lis;*		! To free up disk space
$ a9s [fals.v'VERSION']noahs
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the second assembly to finish."
$ synchronize ASM09/queue=SYS$SLOW
$ write SYS$OUTPUT " "
$ search [fals.v'VERSION']noahs.log "errors detected"
$N_DETECT:
$ write SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ write SYS$OUTPUT ESC,"[21;1H"
$ INQUIRE YES_NO "Were there any errors detected?"
$ IF YES_NO .EQS. "YES" THEN GOTO N_ERROR
$ IF YES_NO .EQS. "Y" THEN GOTO N_ERROR
$ IF YES_NO .EQS. "NO" THEN GOTO N_NO_ERROR
$ IF YES_NO .EQS. "N" THEN GOTO N_NO_ERROR
$ GOTO N_DETECT
$N_ERROR:
$ write SYS$OUTPUT "Please examine NOAHS.LOG and correct the errors."
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "Once the assembly works, don't forget to run:"
$ write SYS$OUTPUT "@[WITT.V''VERSION']EQUATES NOAHS"
$ purge [fals.v'VERSION']noahs.*
$	GOTO _EXIT
$N_NO_ERROR:
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now generate the equate file."
$ write SYS$OUTPUT "Follow the instructions which follow ..."
$ write SYS$OUTPUT " "
$ @[WITT.V'VERSION']EQUATES NOAHS
$	GOTO _EXIT
$!
$!  RRRR   IIIII   CCCC  H   H
$!  R   R    I    C      H   H
$!  RRRR     I    C      HHHHH
$!  R  R     I    C      H   H
$!  R   R  IIIII   CCCC  H   H
$!
$_RICH:
$ set DEFAULT [witt.v'VERSION']
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now search SAMS.EQU for the symbols _1 and VERSION."
$ write SYS$OUTPUT "If VERSION is the wrong value, then [SAM]TSTART.SRC is wrong."
$ write SYS$OUTPUT "   SAMS.EQU will have to be edited also."
$ write SYS$OUTPUT "If _1 is not found, then the $Symbols were not edited to _Symbols."
$ write SYS$OUTPUT "   SAMS.EQU will have to be edited."
$ search [sam.v'VERSION']sams.equ VERSIO,_1
$R_SYMBOLS:
$ write SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ write SYS$OUTPUT ESC,"[21;1H"
$ INQUIRE YES_NO "Was the _1 symbol found and VERSIO the right value?"
$ IF YES_NO .EQS. "YES" THEN GOTO R_SET
$ IF YES_NO .EQS. "Y" THEN GOTO R_SET
$ IF YES_NO .EQS. "NO" THEN GOTO R_NO_SET
$ IF YES_NO .EQS. "N" THEN GOTO R_NO_SET
$ GOTO R_SYMBOLS
$R_NO_SET:
$ write SYS$OUTPUT "Please go back and edit SAMS.EQU and change"
$ write SYS$OUTPUT "all the $Symbols to _Symbols now."
$	GOTO _EXIT
$!
$! Reset RICHS.SET and RICHS.SYM
$!
$R_SET:
$ search/output=richs.set [sam.v'VERSION']sams.equ "	SET	"
$ copy [witt]null.src [witt.v'VERSION']richs.sym
$ copy [witt]null.src [witt.v'VERSION']rich.sym	! For the work files.
$ ab richs slow
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the first assembly to finish."
$ synchronize RICHSSLOW/queue=SYS$SLOW
$ @[witt.v'VERSION']capture SLOW @[witt.v'VERSION']symver richs.lis richs y
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the symbol capturing to finish."
$ synchronize CAPTURE/queue=SYS$SLOW
$ delete richs.lis;*		! to free up disk space
$ ab richs slow
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the second assembly to finish."
$ synchronize RICHSSLOW/queue=SYS$SLOW
$ write SYS$OUTPUT " "
$ search [witt.v'VERSION']richs.log "errors detected"
$R_DETECT:
$ write SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ write SYS$OUTPUT ESC,"[21;1H"
$ INQUIRE YES_NO "Were there any errors detected?"
$ IF YES_NO .EQS. "YES" THEN GOTO R_ERROR
$ IF YES_NO .EQS. "Y" THEN GOTO R_ERROR
$ IF YES_NO .EQS. "NO" THEN GOTO R_NO_ERROR
$ IF YES_NO .EQS. "N" THEN GOTO R_NO_ERROR
$ GOTO R_DETECT
$R_ERROR:
$ write SYS$OUTPUT "Please examine RICHS.LOG and correct the errors."
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "Once the assembly works, don't forget to run:"
$ write SYS$OUTPUT "@[WITT.V''VERSION']EQUATES RICHS"
$ purge [witt.v'VERSION']richs.*
$	GOTO _EXIT
$R_NO_ERROR:
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now generate the equate file."
$ write SYS$OUTPUT "Follow the instructions which follow ..."
$ write SYS$OUTPUT " "
$ @[WITT.V'VERSION']EQUATES RICHS
$	GOTO _EXIT
$!
$!   SSSS   AAA   M   M
$!  S      A   A  MM MM
$!   SSS   AAAAA  M M M
$!      S  A   A  M   M
$!  SSSS   A   A  M   M
$!
$_SAM:
$	GOTO _EXIT
$!
$!  BBBB    OOO   BBBB
$!  B   B  O   O  B   B
$!  BBBB   O   O  BBBB
$!  B   B  O   O  B   B
$!  BBBB    OOO   BBBB
$!
$_BOB:
$ set DEFAULT [mica]
$ @login
$ set DEFAULT [mica.v'VERSION']
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now search NOAHS.EQU for the symbol _1"
$ write SYS$OUTPUT "If it is not found, then the $Symbols were not edited to _Symbols."
$ search [fals.v'VERSION']noahs.equ "_1"
$B_SYMBOLS:
$ write SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ write SYS$OUTPUT ESC,"[21;1H"
$ INQUIRE YES_NO "Was the _1 symbol found?"
$ IF YES_NO .EQS. "YES" THEN GOTO B_SET
$ IF YES_NO .EQS. "Y" THEN GOTO B_SET
$ IF YES_NO .EQS. "NO" THEN GOTO B_NO_SET
$ IF YES_NO .EQS. "N" THEN GOTO B_NO_SET
$ GOTO B_SYMBOLS
$B_NO_SET:
$ WRITE SYS$OUTPUT "Please go back and edit NOAHS.EQU and change"
$ WRITE SYS$OUTPUT "all the $Symbols to _Symbols now."
$ GOTO _EXIT
$!
$! Reset BOBS.SET and BOBS.SYM
$!
$B_SET:
$ search/output=bobs.set [fals.v'VERSION']noahs.equ "	SET	"
$ copy [witt]null.src [mica.v'VERSION']bobs.sym
$ copy [witt]null.src [mica.v'VERSION']bob.sym	! For the work files.
$ asms [mica.v'VERSION']bobs
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the first assembly to finish."
$ synchronize BOBS/queue=SYS$SLOW
$ @[witt.v'VERSION']capture SLOW @[mica.v'VERSION']symver bobs.lis bobs y
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the symbol capturing to finish."
$ synchronize CAPTURE/queue=SYS$SLOW
$ delete bobs.lis;*		! To free up disk space
$ asms [mica.v'VERSION']bobs
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the second assembly to finish."
$ synchronize BOBS/queue=SYS$SLOW
$ write SYS$OUTPUT " "
$ search [mica.v'VERSION']bobs.log "errors detected"
$B_DETECT:
$ write SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ write SYS$OUTPUT ESC,"[21;1H"
$ INQUIRE YES_NO "Were there any errors detected?"
$ IF YES_NO .EQS. "YES" THEN GOTO B_ERROR
$ IF YES_NO .EQS. "Y" THEN GOTO B_ERROR
$ IF YES_NO .EQS. "NO" THEN GOTO B_NO_ERROR
$ IF YES_NO .EQS. "N" THEN GOTO B_NO_ERROR
$ GOTO B_DETECT
$B_ERROR:
$ write SYS$OUTPUT "Please examine BOBS.LOG and correct the errors."
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "Once the assembly works, don't forget to run:"
$ write SYS$OUTPUT "@[WITT.V''VERSION']EQUATES BOBS"
$ purge [mica.v'VERSION']bobs.*
$	GOTO _EXIT
$B_NO_ERROR:
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now generate the equate file."
$ write SYS$OUTPUT "Follow the instructions which follow ..."
$ write SYS$OUTPUT " "
$ @[WITT.V'VERSION']EQUATES BOBS
$	GOTO _EXIT
$!
$!  L      IIIII  BBBB    CCCC  H   H  K   K
$!  L        I    B   B  C      H   H  K  K
$!  L        I    BBBB   C      HHHHH  KKK
$!  L        I    B   B  C      H   H  K  K
$!  LLLLL  IIIII  BBBB    CCCC  H   H  K   K
$!
$_LIBCHK:
$	ERR_COUNT = 0
$	ON ERROR THEN GOTO _LIBABORT1
$	ON CONTROL_Y THEN GOTO _LIBABORT1
$	SORT/KEY=(pos:1,size:6) [SAM.V'VERSION']library.equ temp.tmp
$	OPEN/READ TMP: temp.tmp
$	ON ERROR THEN GOTO _LIBABORT2
$	ON CONTROL_Y THEN GOTO _LIBABORT2
$	NEXT_LABEL = ""
$	NEXT_LINE = ""
$_LIBLOOP:
$	LAST_LABEL = "''NEXT_LABEL'"
$	LAST_LINE = "''NEXT_LINE'"
$	READ TMP: NEXT_LINE
$	NEXT_LABEL = "''F$EXTRACT(0,6,NEXT_LINE)'"
$	IF NEXT_LABEL .NES. LAST_LABEL THEN GOTO _LIBLOOP
$	WRITE SYS$OUTPUT "Duplicate: ""''LAST_LINE'"""
$	WRITE SYS$OUTPUT "           ""''NEXT_LINE'"""
$	ERR_COUNT = ERR_COUNT+1
$	GOTO _LIBLOOP
$_LIBABORT2:	
$	CLOSE TMP:
$_LIBABORT1:
$	DELETE temp.tmp;*
$	IF ERR_COUNT .NE. 0 THEN WRITE SYS$OUTPUT "[SAM.V''VERSION']Library.equ is BAD."
$ GOTO _EXIT
$!
$_EXIT:
$ write SYS$OUTPUT ESC,"[1;24r",ESC,"[24;79H "	! Reset screen scroll region.
$	EXIT
