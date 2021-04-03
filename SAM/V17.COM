$ IF VERSION .EQ. 17 THEN GOTO _VOK
$	show symbol VERSION
$	write SYS$OUTPUT "The symbol VERSION must be 17 in your login."
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
$ write SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: [MESSAGE,SAM,RICH,RICH2,NOAH,BOB,LIBCHK,Control-Y]"
$ write SYS$OUTPUT ESC,"[21;1H"			! Position cursor
$ INQUIRE PGMR_NAME "What is your name?"	!   for inquiry.
$ IF PGMR_NAME .EQS. "NOAH" THEN GOTO _NOAH
$ IF PGMR_NAME .EQS. "RICH" THEN GOTO _'PGMR_NAME'
$ IF PGMR_NAME .EQS. "RICH2" THEN GOTO _'PGMR_NAME'
$ IF PGMR_NAME .EQS. "SAM" THEN GOTO _SAM
$ IF PGMR_NAME .EQS. "BOB" THEN GOTO _BOB
$ IF PGMR_NAME .EQS. "LIBCHK" THEN GOTO _LIBCHK
$ IF PGMR_NAME .EQS. "RXX" THEN GOTO _R_XX
$ GOTO _NAME
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
$ write SYS$OUTPUT "I will now search and RICHS.EQU and RICHS2.EQU for the symbol _1"
$ write SYS$OUTPUT "If it is not found, then the $Symbols were not edited to _Symbols."
$ search [witt.v'VERSION']richs.equ,[witt.v'VERSION']richs2.equ "_1"
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
$ WRITE SYS$OUTPUT "Please go back and edit RICHS.EQU and/or RICHS2.EQU and change"
$ WRITE SYS$OUTPUT "all the $Symbols to _Symbols now."
$ GOTO _EXIT
$!
$! Reset NOAHS.SET and NOAHS.SYM
$!
$N_SET:
$ search/output=noahs.set [witt.v'VERSION']richs2.equ "	SET	"
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
$ inquire REREL_CHECK "Is this a re-release of Richs with no changes to previous assemblys?"
$ if F$EX(0,1,REREL_CHECK).EQS."Y" THEN GOTO R_RERELEASE
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
$ abl richs slow
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the first assembly to finish."
$ synchronize RICHSSLOW/queue=SYS$SLOW
$ @[witt.v'VERSION']capture SLOW @[witt.v'VERSION']symver richs.lis richs y
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the symbol capturing to finish."
$ synchronize CAPTURE/queue=SYS$SLOW
$R_RERELEASE:
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
$	GOTO _RICH2
$_RICH2:
$ set DEFAULT [witt.v'VERSION']
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now search RICHS.EQU for the symbol _1."
$ write SYS$OUTPUT "If _1 is not found, then the $Symbols were not edited to _Symbols."
$ write SYS$OUTPUT "   RICHS.EQU will have to be edited."
$ search [witt.v'VERSION']richs.equ _1
$R2_SYMBOLS:
$ write SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ write SYS$OUTPUT ESC,"[21;1H"
$ INQUIRE YES_NO "Was the _1 symbol found?"
$ IF YES_NO .EQS. "YES" THEN GOTO R2_SET
$ IF YES_NO .EQS. "Y" THEN GOTO R2_SET
$ IF YES_NO .EQS. "NO" THEN GOTO R2_NO_SET
$ IF YES_NO .EQS. "N" THEN GOTO R2_NO_SET
$ GOTO R2_SYMBOLS
$R2_NO_SET:
$ write SYS$OUTPUT "Please go back and edit RICHS.EQU and change"
$ write SYS$OUTPUT "all the $Symbols to _Symbols now."
$	GOTO _EXIT
$!
$! Reset RICHS2.SET and RICHS2.SYM
$!
$R2_SET:
$ search/output=richs2.set [witt.v'VERSION']richs.equ "	SET	"
$ copy [witt]null.src [witt.v'VERSION']richs2.sym
$ abl richs2 slow
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the first assembly to finish."
$ synchronize RICHS2SLOW/queue=SYS$SLOW
$ @[witt.v'VERSION']capture FAST @[witt.v'VERSION']symver richs2.lis richs2 y 2
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the symbol capturing to finish."
$ synchronize CAPTURE/queue=SYS$FAST
$ ab richs2 fast
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the second assembly to finish."
$ synchronize RICHS2FAST/queue=SYS$FAST
$_R_XX:
$ write SYS$OUTPUT " "
$ search [witt.v'VERSION']richs2.log "errors detected"
$R2_DETECT:
$ write SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ write SYS$OUTPUT ESC,"[21;1H"
$ INQUIRE YES_NO "Were there any errors detected?"
$ IF YES_NO .EQS. "YES" THEN GOTO R2_ERROR
$ IF YES_NO .EQS. "Y" THEN GOTO R2_ERROR
$ IF YES_NO .EQS. "NO" THEN GOTO R2_NO_ERROR
$ IF YES_NO .EQS. "N" THEN GOTO R2_NO_ERROR
$ GOTO R2_DETECT
$R2_ERROR:
$ write SYS$OUTPUT "Please examine RICHS2.LOG and correct the errors."
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "Once the assembly works, don't forget to run:"
$ write SYS$OUTPUT "@[WITT.V''VERSION']EQUATES RICHS2"
$ purge [witt.v'VERSION']richs2.*
$	GOTO _EXIT
$R2_NO_ERROR:
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now generate the equate file."
$ write SYS$OUTPUT "Follow the instructions which follow ..."
$ write SYS$OUTPUT " "
$ @[WITT.V'VERSION']EQUATES RICHS2
$	GOTO _EXIT
$!
$!   SSSS   AAA   M   M
$!  S      A   A  MM MM
$!   SSS   AAAAA  M M M
$!      S  A   A  M   M
$!  SSSS   A   A  M   M
$!
$_SAM:
$ if proc$name.eqs."SAM" then goto S_START
$ @[sam]
$S_START:
$ mo sam.v'VERSION'
$!
$ open/error=S_NO_MESLIS test MESSAGE.LIS
$ close test
$ goto S_MESEQU
$!
$! Assemble MESSAGE
$!
$S_NO_MESLIS:
$ k message.equ
$ k sams.lis
$ sb
$ ab message
$ sq
$ disp "waiting for MESSAGE assembly"
$ sync/queue=sys$asm sambuasm
$ open/read/error=S_ASMERRORS test wk:buasmok.tmp
$ close test
$ ren lis$dir:pgm.lis [sam.v'version]message
$!
$S_MESEQU:
$ open/error=S_NO_MESEQU test MESSAGE.EQU
$ close test
$ goto S_EQULIS
$!
$! Generate MESSAGE.EQU
$!
$S_NO_MESEQU:
$ k sams.sym
$ inquire null "type RETURN CTRL-A to continue"
$ equ message.lis message
$!
$S_EQULIS:
$ open/error=S_NO_EQULIS test EQUATES.LIS
$ close test
$ goto S_EQUEQU
$!
$! Assemble EQUATES
$!
$S_NO_EQULIS:
$ k equates.equ
$ k sams.lis
$ fb
$ ab equates
$ sq
$ disp "waiting for EQUATES assembly"
$ sync/queue=sys$asm sambuasm
$ open/read/error=S_ASMERRORS test wk:buasmok.tmp
$ close test
$ ren lis$dir:pgm.lis [sam.v'version]equates
$!
$S_EQUEQU:
$ open/error=S_NO_EQUEQU test EQUATES.EQU
$ close test
$ goto S_IMALIS
$!
$! Generate EQUATES.EQU
$!
$S_NO_EQUEQU:
$ k sams.sym
$ inquire null "type RETURN CTRL-A to continue"
$ equ equates.lis equates
$!
$S_IMALIS:
$ open/error=S_NO_IMALIS test IMAGE.LIS
$ close test
$ goto S_IMAEQU
$!
$! Assemble IMAGE
$!
$S_NO_IMALIS:
$ k image.equ
$ k sams.lis
$ fb
$ ab image
$ sq
$ disp "waiting for IMAGE assembly"
$ sync/queue=sys$asm sambuasm
$ open/read/error=S_ASMERRORS test wk:buasmok.tmp
$ close test
$ ren lis$dir:pgm.lis [sam.v'version]image
$!
$S_IMAEQU:
$ open/error=S_NO_IMAEQU test IMAGE.EQU
$ close test
$ goto S_SAMLIS
$!
$! Generate IMAGE.EQU
$!
$S_NO_IMAEQU:
$ k sams.lis
$ k sams.sym
$ inquire null "type RETURN CTRL-A to continue"
$ equ image.lis image
$!
$S_SAMLIS:
$ open/error=S_NO_SAMLIS test SAMS.LIS
$ close test
$ goto S_SAMEQU
$!
$! Assemble SAMS
$!
$S_NO_SAMLIS:
$ k sams.equ
$ sea/nohead/out=s.tmp message.equ,equates.equ,image.equ "	set	"
$ sort/key=(pos=1,size=16) s.tmp sams.set
$ sb
$ ab sams
$ sq
$ disp "waiting for SAMS assembly"
$ sync/queue=sys$asm sambuasm
$ open/read/error=S_SAMSERROR test wk:buasmok.tmp
$ close test
$ goto S_SAMSLISOK
$!
$S_SAMSERROR:
$ open/read/error=S_TSYMVER test wk:buasmok.tmp
$ close test
$ goto S_ASMERROR
$S_TSYMVER:
$ cap @asm$dir:tsymver lis$dir:pgm.lis sams y
$ disp "waiting for SAMS symbol capture"
$ sync/queue=sys$asm CAPTURE
$ ab sams
$ sq
$ disp "waiting for SAMS assembly"
$ sync/queue=sys$asm sambuasm
$ open/read/error=S_ASMERRORS test wk:buasmok.tmp
$ close test
$S_SAMSLISOK:
$ ren lis$dir:pgm.lis [sam.v'version]sams
$!
$S_SAMEQU:
$ open/error=S_NO_SAMEQU test SAMS.EQU
$ close test
$ goto S_SAMSEDIT
$!
$! Generate SAMS.EQU
$!
$S_NO_SAMEQU:
$ inquire null "type RETURN CTRL-A to continue"
$ equ sams.lis sams
$!
$S_SAMSEDIT:
$ sea/out=u.tmp sams.equ "$AT"
$ open/read test u.tmp
$ read/end=S_DONE test match
$ close test
$ if match.eqs."No strings matched" then goto S_DONE
$!
$! change $'s to _
$!
$ disp "change all <CR>$ to (CR>_"
$ inquire null "type RETURN to continue"
$ e sams.equ
$ goto S_SAMSEDIT
$!
$S_DONE:
$ disp "All done!!!"
$ goto _EXIT
$!
$S_ASMERRORS:
$ disp "Errors assembling ",ASM_DEFAULT,".src
$ disp "correct errors and restart this program"
$ close test
$ goto _EXIT
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
$ @[witt.v'VERSION']capture SLOW @[mica.v'VERSION']vsymver bobs.lis bobs y
$ write SYS$OUTPUT " "
$ write SYS$OUTPUT "I will now wait for the symbol capturing to finish."
$ synchronize CAPTURE/queue=SYS$SLOW
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
