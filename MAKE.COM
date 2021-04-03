$! A few equates
$ VERSION = 17				! Hopefully unnecessary
$ TOPCOM	:== COMMON
$ TOPDIR	:== LIBRARY.SINISTAR
$ SAMDIR	:== 'TOPDIR'.SAM
$ WITTDIR 	:== 'TOPDIR'.WITT
$ FALSDIR	:== 'TOPDIR'.FALS
$ MICADIR	:== 'TOPDIR'.MICA
$ ESC[0,8] = %X1B			! VT100 control character.
$!xxx turn off external messages.
$ disp :== WRITE SYS$OUTPUT
$!
$ DISP ESC,"[24;1H "		! Clear bottom two lines of the screen
$ DISP " "			!   for informational use.
$ DISP ESC,"[1;22r"		! Set scrolling region
$ DISP ESC,"[24;1H",ESC,"#6",ESC,"[7mLIBRARY COPY of SINISTAR",ESC,"[0m"
$!
$ ON ERROR THEN GOTO _ABORT
$ ON CONTROL_Y THEN GOTO _ABORT
$ SET NOON			! Setup for use of $STATUS and $SEVERITY
$!
$_NAME:
$ @['TOPDIR'.COM]INQUIRE PGMR_NAME "What do you want to do?" -
			"[ALLNEW,CHECK,CONTINUE,HELP,Control-Y]"
$ IF .NOT. $STATUS THEN $ GOTO _ABORT
$!!! IF PGMR_NAME .EQS. "NOAH" THEN GOTO _NOAH
$!!! IF PGMR_NAME .EQS. "RICH" THEN GOTO _'PGMR_NAME'
$!!! IF PGMR_NAME .EQS. "RICH2" THEN GOTO _'PGMR_NAME'
$!!! IF PGMR_NAME .EQS. "SAM" THEN GOTO _SAM
$!!! IF PGMR_NAME .EQS. "BOB" THEN GOTO _BOB
$!!! IF PGMR_NAME .EQS. "LIBCHK" THEN GOTO _LIBCHK
$!!! IF PGMR_NAME .EQS. "RXX" THEN GOTO _R_XX
$	IF PGMR_NAME .EQS. "ALLNEW" THEN GOTO _'PGMR_NAME'
$	IF PGMR_NAME .EQS. "CHECK" THEN GOTO _'PGMR_NAME'
$	IF PGMR_NAME .EQS. "CONTINUE" THEN GOTO _'PGMR_NAME'
$	IF PGMR_NAME .EQS. "HELP" THEN GOTO _HELP1
$ DISP " "
$ DISP "You may only enter one of the designated responses."
$!
$_HELP1:
$ DISP " "
$ DISP "ALLNEW	will destroy previous builds, forcing an all new library copy"
$ DISP "	to be built.  This will take several hours."
$ DISP "CONTINUE will test the current condition of the library copy and if it"
$ DISP "	is in the middle of being built, will continue doing so.  You"
$ DISP "	must correct any errors it reports and stops at.  Then, you"
$ DISP "	need to CONTINUE again."
$ DISP "	To change a source and remake the library MOT file, just edit"
$ DISP "	the SRC file, then delete the LOG and LIS files before running"
$ DISP "	this proceedure."
$ DISP "CHECK	will test the current condition of the library copy and report"
$ DISP "	as if it were building (CONTINUEing) but will not actually try"
$ DISP "	to build anything.  It stops when it finds and reports errors."
$ DISP "HELP	will print this out."
$ DISP " "
$ GOTO _NAME
$!
$!
$_ALLNEW:
$ SET DEFAULT ['SAMDIR']
$ @['TOPDIR'.COM]DELETER message.lis
$ @['TOPDIR'.COM]DELETER message.log
$ @['TOPDIR'.COM]DELETER image.lis
$ @['TOPDIR'.COM]DELETER image.log
$ GOTO _CONTINUE
$!
$!
$_CHECK:
$ DISP "Sorry.  This isn't implimented."
$ GOTO _NAME
$!
$!
$_CONTINUE:
$ RUN_STOP := RUN
$ GOTO _SAM
$!
$!
$_CHECK:
$ RUN_STOP := STOP
$ GOTO _SAM
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
$ set DEFAULT [LIBRARY.SINISTAR.fals]
$ DISP " "
$ DISP "I will now search and RICHS.EQU and RICHS2.EQU for the symbol _1"
$ DISP "If it is not found, then the $Symbols were not edited to _Symbols."
$ search ['WITTDIR']richs.equ,['WITTDIR']richs2.equ "_1"
$N_SYMBOLS:
$ DISP ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ DISP ESC,"[21;1H"
$ INQUIRE YES_NO "Was the _1 symbol found?"
$ IF YES_NO .EQS. "YES" THEN GOTO N_SET
$ IF YES_NO .EQS. "Y" THEN GOTO N_SET
$ IF YES_NO .EQS. "NO" THEN GOTO N_NO_SET
$ IF YES_NO .EQS. "N" THEN GOTO N_NO_SET
$ GOTO N_SYMBOLS
$N_NO_SET:
$ DISP "Please go back and edit RICHS.EQU and/or RICHS2.EQU and change"
$ DISP "all the $Symbols to _Symbols now."
$ GOTO _EXIT
$!
$! Reset NOAHS.SET and NOAHS.SYM
$!
$N_SET:
$ search/output=noahs.set ['WITTDIR']richs2.equ "	SET	"
$ copy [witt]null.src ['FALSDIR']noahs.sym
$ copy [witt]null.src ['FALSDIR']noah.sym	! For the work files.
$ a9s ['FALSDIR']noahs
$ DISP " "
$ DISP "I will now wait for the first assembly to finish."
$ synchronize ASM09/queue=SYS$SLOW
$ @['TOPDIR'.COM]CAPTURE SLOW @['FALSDIR']symver noahs.lis noahs y
$ DISP " "
$ DISP "I will now wait for the symbol capturing to finish."
$ synchronize CAPTURE/queue=SYS$SLOW
$ a9s ['FALSDIR']noahs
$ DISP " "
$ DISP "I will now wait for the second assembly to finish."
$ synchronize ASM09/queue=SYS$SLOW
$ DISP " "
$ search ['FALSDIR']noahs.log "errors detected"
$N_DETECT:
$ DISP ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ DISP ESC,"[21;1H"
$ INQUIRE YES_NO "Were there any errors detected?"
$ IF YES_NO .EQS. "YES" THEN GOTO N_ERROR
$ IF YES_NO .EQS. "Y" THEN GOTO N_ERROR
$ IF YES_NO .EQS. "NO" THEN GOTO N_NO_ERROR
$ IF YES_NO .EQS. "N" THEN GOTO N_NO_ERROR
$ GOTO N_DETECT
$N_ERROR:
$ DISP "Please examine NOAHS.LOG and correct the errors."
$ DISP " "
$ DISP "Once the assembly works, don't forget to run:"
$ DISP "@['TOPDIR'.COM]EQUATES NOAHS"
$ purge ['FALSDIR']noahs.*
$	GOTO _EXIT
$!
$!
$!
$N_NO_ERROR:
$ @['TOPDIR'.COM]INQUIRE null "Press both RETURN and CTRL-A to continue" -
			"[<Return><Control-A>,Control-Y if necessary]"
$ IF .NOT. $STATUS THEN $ GOTO _ABORT
$ @['TOPDIR'.COM]MESSAGE "Editing" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]EQUATES 'SOURCE'
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$	STOP
$	GOTO _BOBS
$!
$!  RRRR   IIIII   CCCC  H   H
$!  R   R    I    C      H   H
$!  RRRR     I    C      HHHHH
$!  R  R     I    C      H   H
$!  R   R  IIIII   CCCC  H   H
$!
$_RICH:
$ DISP "Beginning RICH's !!!"
$!
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$ SET DEFAULT ['WITTDIR']
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['SAMDIR']SAMS.EQU "_1"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO S_EDIT_CHK
$!
$!
$ SOURCE := RICHS
$!!!!!
$!
$! Test for assembled RICHS.SRC
$!
$!!!!!
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['WITTDIR']'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO R_RICHS
$!
$ disp "''SOURCE'.SRC is already assembled."
$ goto R_RICHS_EQU_CHK
$!
$!
$R_RICHS:
$!
$! Test for first pass completed and RICHS.SYM generated.
$!
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['WITTDIR']'SOURCE'.sym "SYMVER"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO R_RICHS_ASM1    ! If no SYMVER then ASM1.
$ disp "''SOURCE'.SYM is already generated."
$ GOTO R_RICHS_ASM2
$!
$! Assemble RICHS.SRC the first time.
$!
$R_RICHS_ASM1:
$ DISP "''SOURCE'.SRC needs assembly with a new ''SOURCE'.SET ..."
$!
$! Reset RICHS.SET and RICHS.SYM
$!
$ @['TOPDIR'.COM]DELETER rich.sym		! Work file.
$ search/output='SOURCE'.set;1 ['SAMDIR']sams.equ "	SET	"
$ search/output='SOURCE'.set;2/match=nand 'SOURCE'.set;1 "displa" ! From sam
$ CREATE 'SOURCE'.sym
$ CREATE rich.sym		! For the work files.
$!
$! Now, assemble RICHS
$!
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]ASM -ABS -OLD -SLOW 'SOURCE'
$ DISP "Waiting for ''SOURCE' 1st pass assembly ..."
$ @['TOPDIR'.COM]MESSAGE "Batch Assembling" "[Control-Y if necessary]"
$ synchronize 'SOURCE'SLOW/queue=SYS$SLOW
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$! Capture RICHS symbols
$!
$ DISP "''SOURCE' symbols are about to be captured..."
$ @['TOPDIR'.COM]CAPTURE SLOW @['WITTDIR']symver 'SOURCE'.lis 'SOURCE' y
$ disp "Waiting for ''SOURCE' symbol capture ..."
$
$ @['TOPDIR'.COM]MESSAGE "Batch Capturing" "[Control-Y if necessary]"
$ synchronize/queue=sys$SLOW CAPTURE
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$! Assemble RICHS.SRC the second time.
$!
$R_RICHS_ASM2:
$ @['TOPDIR'.COM]ASM -ABS -OLD -SLOW 'SOURCE'
$ DISP "Waiting for ''SOURCE' 2nd pass assembly ..."
$ @['TOPDIR'.COM]MESSAGE "Batch Assembling" "[Control-Y if necessary]"
$ synchronize 'SOURCE'SLOW/queue=SYS$SLOW
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp 'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO _ASMERRORS	! Any errors the 2nd time?
$!
$! Test for generated RICHS.EQU
$!
$R_RICHS_EQU_CHK:
$ @['TOPDIR.COM]ERRORCHK 'SOURCE'.EQU
$	IF .NOT. $STATUS THEN $ GOTO R_RICHS_EQU
$ disp "''SOURCE'.EQU is already generated."
$ goto R_EDIT1_CHK
$!
$! Generate RICHS.EQU
$!
$R_RICHS_EQU:
$ purge ['WITTDIR']'SOURCE'.*
$ @['TOPDIR'.COM]DELETER RICHS2.equ
$ @['TOPDIR'.COM]DELETER RICHS2.lis
$ @['TOPDIR'.COM]DELETER RICHS2.log
$ @['TOPDIR'.COM]DELETER RICHS2.set
$ @['TOPDIR'.COM]DELETER RICHS2.sym
$!
$ @['TOPDIR'.COM]INQUIRE null "Press both RETURN and CTRL-A to continue" -
			"[<Return><Control-A>,Control-Y if necessary]"
$ IF .NOT. $STATUS THEN $ GOTO _ABORT
$ @['TOPDIR'.COM]MESSAGE "Editing" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]EQUATES 'SOURCE'
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$!	Test for _1 edited from $1 in listing.
$!
$R_EDIT1_CHK:
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$ SET DEFAULT ['WITTDIR']
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp 'SOURCE'.EQU "_1"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF $STATUS THEN $ GOTO R_EDIT1_OK
$!
$!	Convert $symbols to _symbols.
$!
$ RUN ['TOPDIR'.COM]DOLLAR
RICHS.EQU
RICHS.EQU
RICHS
$!
$!	Part 2 of RICHS section of Sinistar.
$!
$R_EDIT1_OK:
$ SOURCE := RICHS2
$!
$! Test for assembled RICHS2
$!
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['WITTDIR']'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO R_RICHS2
$!
$ disp "''SOURCE'.SRC is already assembled."
$ goto R_RICHS2_EQU_CHK
$!
$!
$R_RICHS2:
$!
$! Test for first pass completed and RICHS2.SYM generated.
$!
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['WITTDIR']'SOURCE'.sym "SYMVER"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO R_RICHS2_ASM1    ! If no SYMVER then ASM1.
$ disp "''SOURCE'.SYM is already generated."
$ GOTO R_RICHS2_ASM2
$!
$! Assemble RICHS2 the first time.
$!
$R_RICHS2_ASM1:
$ DISP "''SOURCE'.SRC needs assembly with a new ''SOURCE'.SET ..."
$!
$! Reset RICHS2.SET and RICHS2.SYM
$!
$ search/output='SOURCE'.set;1 ['WITTDIR']RICHS.equ "	SET	"
$ CREATE 'SOURCE'.sym
$!
$! Now, assemble RICHS2
$!
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]ASM -ABS -OLD -SLOW 'SOURCE'
$ DISP "Waiting for ''SOURCE' 1st pass assembly ..."
$ @['TOPDIR'.COM]MESSAGE "Batch Assembling" "[Control-Y if necessary]"
$ synchronize 'SOURCE'SLOW/queue=SYS$SLOW
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$! Capture RICHS2 symbols
$!
$ DISP "''SOURCE' symbols are about to be captured..."
$ @['TOPDIR'.COM]CAPTURE SLOW @['WITTDIR']symver 'SOURCE'.lis 'SOURCE' y RICHS2
$ disp "Waiting for ''SOURCE' symbol capture ..."
$
$ @['TOPDIR'.COM]MESSAGE "Batch Capturing" "[Control-Y if necessary]"
$ synchronize/queue=sys$SLOW CAPTURE
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$! Assemble RICHS2 the second time.
$!
$R_RICHS2_ASM2:
$ @['TOPDIR'.COM]ASM -ABS -OLD -SLOW 'SOURCE'
$ DISP "Waiting for ''SOURCE' 2nd pass assembly ..."
$ @['TOPDIR'.COM]MESSAGE "Batch Assembling" "[Control-Y if necessary]"
$ synchronize 'SOURCE'SLOW/queue=SYS$SLOW
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp 'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO _ASMERRORS	! Any errors the 2nd time?
$!
$! Test for generated RICHS2.EQU
$!
$R_RICHS2_EQU_CHK:
$ @['TOPDIR.COM]ERRORCHK 'SOURCE'.EQU
$	IF .NOT. $STATUS THEN $ GOTO R_RICHS2_EQU
$ disp "''SOURCE'.EQU is already generated."
$ goto R_EDIT2_CHK
$!
$! Generate RICHS2.EQU
$!
$R_RICHS2_EQU:
$ purge ['WITTDIR']'SOURCE'.*
$ @['TOPDIR'.COM]DELETER ['FALSDIR']NOAHS.equ	! Pre-empt the
$ @['TOPDIR'.COM]DELETER ['FALSDIR']NOAHS.log	!   third phase
$ @['TOPDIR'.COM]DELETER ['FALSDIR']NOAHS.set	!   of Sinistar,
$ @['TOPDIR'.COM]DELETER ['FALSDIR']NOAHS.sym	!   which is NOAHS.
$!
$ @['TOPDIR'.COM]INQUIRE null "Press both RETURN and CTRL-A to continue" -
			"[<Return><Control-A>,Control-Y if necessary]"
$ IF .NOT. $STATUS THEN $ GOTO _ABORT
$ @['TOPDIR'.COM]MESSAGE "Editing" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]EQUATES 'SOURCE'
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$!	Test for _1 edited from $1 in listing.
$!
$R_EDIT2_CHK:
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$ SET DEFAULT ['WITTDIR']
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp 'SOURCE'.EQU "_1"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF $STATUS THEN $ GOTO R_EDIT2_OK
$!
$!	Convert $symbols to _symbols.
$!
$ RUN ['TOPDIR'.COM]DOLLAR
RICHS2.EQU
RICHS2.EQU
RICHS2
$!
$R_EDIT2_OK:
$	STOP
$	GOTO _NOAH
$!
$!   SSSS  TTTTT   AAA   RRRR   TTTTT
$!  S        T    A   A  R   R    T
$!   SSS     T    AAAAA  RRRR     T
$!      S    T    A   A  R  R     T
$!  SSSS     T    A   A  R   R    T
$!
$_START:
$ SET DEFAULT ['SAMDIR']
$ @['TOPDIR'.COM]DELETER MESSAGE.LIS
$ @['TOPDIR'.COM]DELETER MESSAGE.LOG
$ @['TOPDIR'.COM]DELETER MESSAGE.EQU
$!
$!   SSSS   AAA   M   M
$!  S      A   A  MM MM
$!   SSS   AAAAA  M M M
$!      S  A   A  M   M
$!  SSSS   A   A  M   M
$!
$_SAM:
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$ DISP "Beginning SAM's !!!"
$ SET DEFAULT ['SAMDIR']
$ SOURCE = ""
$!
$! Test for assembled MESSAGE.SRC
$!
$ SOURCE := MESSAGE
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['SAMDIR']'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO S_NO_MESLIS
$ disp "''SOURCE'.SRC is already assembled."
$ goto S_MESEQU
$!
$! Assemble MESSAGE.SRC
$!
$S_NO_MESLIS:
$ DISP "''SOURCE'.SRC is not correctly assembled."
$ IF RUN_STOP .EQS. "STOP" THEN $ GOTO _EXIT
$ @['TOPDIR'.COM]DELETER 'SOURCE'.equ
$ @['TOPDIR'.COM]DELETER SAMS.equ
$ @['TOPDIR'.COM]DELETER SAMS.lis
$ @['TOPDIR'.COM]DELETER SAMS.log
$ @['TOPDIR'.COM]DELETER SAMS.set
$ @['TOPDIR'.COM]DELETER SAMS.sym
$ @['TOPDIR'.COM]ASM -ABS -OLD -SLOW 'SOURCE'	! sb ab sq
$ disp "Waiting for ''SOURCE' assembly ..."
$ @['TOPDIR'.COM]MESSAGE "Batch Assembling" "[Control-Y if necessary]"
$ synchronize/queue=sys$SLOW 'SOURCE'SLOW	! sambuasm
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['SAMDIR']'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO _ASMERRORS
$!
$S_MESEQU:
$!
$! Test for generated MESSAGE.EQU
$!
$ @['TOPDIR.COM]ERRORCHK 'SOURCE'.EQU
$	IF .NOT. $STATUS THEN $ GOTO S_NO_MESEQU
$ disp "''SOURCE'.EQU is already generated."
$ goto S_EQULIS
$!
$! Generate MESSAGE.EQU
$!
$S_NO_MESEQU:
$ DISP "''SOURCE'.EQU is not generated."
$ IF RUN_STOP .EQS. "STOP" THEN $ GOTO _EXIT
$ @['TOPDIR'.COM]DELETER EQUATES.equ
$ @['TOPDIR'.COM]DELETER EQUATES.lis
$ @['TOPDIR'.COM]DELETER EQUATES.log
$ @['TOPDIR'.COM]DELETER SAMS.equ
$ @['TOPDIR'.COM]DELETER SAMS.lis
$ @['TOPDIR'.COM]DELETER SAMS.log
$ @['TOPDIR'.COM]DELETER SAMS.set
$ @['TOPDIR'.COM]DELETER SAMS.sym
$!
$ @['TOPDIR'.COM]INQUIRE null "Press both RETURN and CTRL-A to continue" -
			"[<Return><Control-A>,Control-Y if necessary]"
$ IF .NOT. $STATUS THEN $ GOTO _ABORT
$ @['TOPDIR'.COM]MESSAGE "Editing" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]EQUATES 'SOURCE'
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$! Test for assembled EQUATES.SRC
$!
$S_EQULIS:
$ SOURCE := EQUATES
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['SAMDIR']'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO S_NO_EQULIS
$ disp "''SOURCE'.SRC is already assembled."
$ goto S_EQUEQU
$!
$! Assemble EQUATES.SRC
$!
$S_NO_EQULIS:
$ DISP "''SOURCE'.SRC needs assembly ..."
$ IF RUN_STOP .EQS. "STOP" THEN $ GOTO _EXIT
$ @['TOPDIR'.COM]DELETER 'SOURCE'.equ
$ @['TOPDIR'.COM]DELETER IMAGE.equ
$ @['TOPDIR'.COM]DELETER IMAGE.lis
$ @['TOPDIR'.COM]DELETER IMAGE.log
$ @['TOPDIR'.COM]DELETER SAMS.equ
$ @['TOPDIR'.COM]DELETER SAMS.lis
$ @['TOPDIR'.COM]DELETER SAMS.log
$ @['TOPDIR'.COM]DELETER SAMS.set
$ @['TOPDIR'.COM]DELETER SAMS.sym
$ @['TOPDIR'.COM]ASM -ABS -OLD -MED 'SOURCE'		! fb ab sq
$ disp "Waiting for ''SOURCE' assembly ..."
$ @['TOPDIR'.COM]MESSAGE "Batch Assembling" "[Control-Y if necessary]"
$ synchronize/queue=sys$MED 'SOURCE'MED			! sambuasm
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['SAMDIR']'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO _ASMERRORS
$!
$! Test for generated EQUATES.EQU
$!
$S_EQUEQU:
$ @['TOPDIR.COM]ERRORCHK 'SOURCE'.EQU
$	IF .NOT. $STATUS THEN $ GOTO S_NO_EQUEQU
$ disp "''SOURCE'.EQU is already generated."
$ goto S_IMALIS
$!
$! Generate EQUATES.EQU
$!
$S_NO_EQUEQU:
$ DISP "''SOURCE'.EQU is not generated."
$ IF RUN_STOP .EQS. "STOP" THEN $ GOTO _EXIT
$ @['TOPDIR'.COM]DELETER SAMS.equ
$ @['TOPDIR'.COM]DELETER SAMS.lis
$ @['TOPDIR'.COM]DELETER SAMS.log
$ @['TOPDIR'.COM]DELETER SAMS.set
$ @['TOPDIR'.COM]DELETER SAMS.sym
$!
$ @['TOPDIR'.COM]INQUIRE null "Press both RETURN and CTRL-A to continue" -
			"[<Return><Control-A>,Control-Y if necessary]"
$ IF .NOT. $STATUS THEN $ GOTO _ABORT
$ @['TOPDIR'.COM]MESSAGE "Editing" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]EQUATES 'SOURCE'
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$! Test for assembled IMAGE.SRC
$!
$S_IMALIS:
$ SOURCE := IMAGE
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['SAMDIR']'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO S_NO_IMALIS
$ disp "''SOURCE'.SRC is already assembled."
$ goto S_IMAEQU
$!
$! Assemble IMAGE.SRC
$!
$S_NO_IMALIS:
$ DISP "''SOURCE'.SRC is not correctly assembled."
$ IF RUN_STOP .EQS. "STOP" THEN $ GOTO _EXIT
$ @['TOPDIR'.COM]DELETER 'SOURCE'.equ
$ @['TOPDIR'.COM]DELETER SAMS.equ
$ @['TOPDIR'.COM]DELETER SAMS.lis
$ @['TOPDIR'.COM]DELETER SAMS.log
$ @['TOPDIR'.COM]DELETER SAMS.set
$ @['TOPDIR'.COM]DELETER SAMS.sym
$ @['TOPDIR'.COM]ASM -ABS -OLD -MED 'SOURCE'		! fb ab sq
$ disp "Waiting for ''SOURCE' assembly ..."
$ @['TOPDIR'.COM]MESSAGE "Batch Assembling" "[Control-Y if necessary]"
$ synchronize/queue=sys$MED 'SOURCE'MED			! sambuasm
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['SAMDIR']'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO _ASMERRORS
$!
$! Test for generated IMAGE.EQU
$!
$S_IMAEQU:
$ @['TOPDIR.COM]ERRORCHK 'SOURCE'.EQU
$	IF .NOT. $STATUS THEN $ GOTO S_NO_IMAEQU
$ disp "''SOURCE'.EQU is already generated."
$ goto S_SAMLIS
$!
$! Generate IMAGE.EQU
$!
$S_NO_IMAEQU:
$ @['TOPDIR'.COM]INQUIRE null "Press both RETURN and CTRL-A to continue" -
			"[<Return><Control-A>,Control-Y if necessary]"
$ IF .NOT. $STATUS THEN $ GOTO _ABORT
$ @['TOPDIR'.COM]MESSAGE "Editing" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]EQUATES 'SOURCE'
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!!!!!
$!
$! Test for assembled SAMS.SRC
$!
$!!!!!
$S_SAMLIS:
$ SOURCE := SAMS
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['SAMDIR']'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO S_SAMS
$!
$ disp "''SOURCE'.SRC is already assembled."
$ goto S_SAMS_EQU_CHK
$!
$! Test for first pass completed and SAMS.SYM generated.
$!
$S_SAMS:
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['SAMDIR']'SOURCE'.sym "SYMVER"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO S_SAMS_ASM1    ! If no SYMVER then ASM1.
$ disp "''SOURCE'.SYM is already generated."
$ GOTO S_SAMS_ASM2
$!
$! Assemble SAMS.SRC
$!
$S_SAMS_ASM1:
$ DISP "''SOURCE'.SRC needs assembly with a new ''SOURCE'.SET ..."
$!
$! Reset SAMS.SET and SAMS.SYM
$!
$ CREATE library.equ
$ CREATE sinistar.equ
$!
$ @['TOPDIR'.COM]DELETER 'SOURCE'.equ
$ @['TOPDIR'.COM]DELETER 'SOURCE'.set
$!
$ @['TOPDIR'.COM]DELETER s.tmp
$ search/nohead/out=s.tmp message.equ,equates.equ,image.equ "	set	"
$ sort/key=(pos=1,size=16) s.tmp 'SOURCE'.set
$ @['TOPDIR'.COM]DELETER s.tmp
$!
$ @['TOPDIR'.COM]ASM -ABS -OLD -SLOW 'SOURCE'		! sb ab sq
$ disp "Waiting for ''SOURCE' assembly ..."
$ @['TOPDIR'.COM]MESSAGE "Batch Assembling" "[Control-Y if necessary]"
$ synchronize/queue=sys$SLOW 'SOURCE'SLOW			! sambuasm
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp ['SAMDIR']'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF $STATUS THEN $ GOTO S_SAMS_EQU_CHK
$!
$! Capture symbols.
$!
$S_TSYMVER:
$ DISP "''SOURCE' symbols are not captured."
$ IF RUN_STOP .EQS. "STOP" THEN $ GOTO _EXIT
$!
$ @['TOPDIR'.COM]DELETER capture.tmp
$ @['SAMDIR']CAPTURE @['SAMDIR']tsymver ['SAMDIR']'SOURCE'.lis 'SOURCE' y
$ disp "Waiting for ''SOURCE' symbol capture ..."
$ @['TOPDIR'.COM]MESSAGE "Batch Capturing" "[Control-Y if necessary]"
$ synchronize/queue=sys$SLOW CAPTURE
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$!
$S_SAMS_ASM2:
$ @['TOPDIR'.COM]ASM -ABS -OLD -SLOW 'SOURCE'	! 2nd pass assemble of SAMS
$ disp "Waiting for ''SOURCE' assembly ..."
$ @['TOPDIR'.COM]MESSAGE "Batch Assembling" "[Control-Y if necessary]"
$ synchronize/queue=sys$SLOW 'SOURCE'SLOW			! sambuasm
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp 'SOURCE'.log "No errors detected"
$ @['TOPDIR.COM]ERRORCHK error.tmp
$	IF .NOT. $STATUS THEN $ GOTO _ASMERRORS	! Any errors 2nd time?
$!
$ ren ['SAMDIR']'SOURCE'.lis ['SAMDIR']'SOURCE'
$ @['TOPDIR'.COM]DELETER 'SOURCE'.equ
$!
$! Test for generated SAMS.EQU
$!
$S_SAMS_EQU_CHK:
$ @['TOPDIR.COM]ERRORCHK 'SOURCE'.EQU
$	IF .NOT. $STATUS THEN $ GOTO S_SAMS_EQU
$ disp "''SOURCE'.EQU is already generated."
$ goto S_EDIT_CHK
$!
$! Generate SAMS.EQU
$!
$S_SAMS_EQU:
$ DISP "''SOURCE'.EQU is being generated ..."
$ IF RUN_STOP .EQS. "STOP" THEN $ GOTO _EXIT
$ @['TOPDIR'.COM]INQUIRE null "Press both RETURN and CTRL-A to continue" -
			"[<Return><Control-A>,Control-Y if necessary]"
$ IF .NOT. $STATUS THEN $ GOTO _ABORT
$ @['TOPDIR'.COM]MESSAGE "Editing" "[Control-Y if necessary]"
$ @['TOPDIR'.COM]MESSAGE "Working" "[Control-Y if necessary]"
$!
$S_EDIT_CHK:
$ SET DEFAULT ['SAMDIR']		! Multiple entry points to here.
$ @['TOPDIR'.COM]DELETER error.tmp
$ search/output=error.tmp 'SOURCE'.equ "$AT"
$ open/read test error.tmp
$ read/end=S_DONE test match
$ if match.eqs."No strings matched" then goto S_DONE
$!
$!	Convert $symbols to _symbols.
$!
$ @['TOPDIR'.COM]DELETER ['WITTDIR']RICHS.equ	! Pre-empt the next
$ @['TOPDIR'.COM]DELETER ['WITTDIR']RICHS.log	!   phase of Sinistar.
$ @['TOPDIR'.COM]DELETER ['WITTDIR']RICHS.set
$ @['TOPDIR'.COM]DELETER ['WITTDIR']RICHS.sym
$ RUN ['TOPDIR'.COM]DOLLAR
SAMS.EQU
SAMS.EQU
SAMS
$!
$!
$S_DONE:
$ close test
$ @['TOPDIR'.COM]DELETER error.tmp
$ goto _RICH
$!
$_ASMERRORS:
$ disp "Errors assembling ",SOURCE,".src"
$ disp "Correct the errors and restart this program."
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
$ set DEFAULT ['MICADIR']
$ DISP " "
$ DISP "I will now search NOAHS.EQU for the symbol _1"
$ DISP "If it is not found, then the $Symbols were not edited to _Symbols."
$ search ['FALSDIR']noahs.equ "_1"
$B_SYMBOLS:
$ DISP ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ DISP ESC,"[21;1H"
$ INQUIRE YES_NO "Was the _1 symbol found?"
$ IF YES_NO .EQS. "YES" THEN GOTO B_SET
$ IF YES_NO .EQS. "Y" THEN GOTO B_SET
$ IF YES_NO .EQS. "NO" THEN GOTO B_NO_SET
$ IF YES_NO .EQS. "N" THEN GOTO B_NO_SET
$ GOTO B_SYMBOLS
$B_NO_SET:
$ DISP "Please go back and edit NOAHS.EQU and change"
$ DISP "all the $Symbols to _Symbols now."
$ GOTO _EXIT
$!
$! Reset BOBS.SET and BOBS.SYM
$!
$B_SET:
$ search/output=bobs.set ['FALSDIR']noahs.equ "	SET	"
$ copy [witt]null.src ['MICADIR']bobs.sym
$ copy [witt]null.src ['MICADIR']bob.sym	! For the work files.
$ asms ['MICADIR']bobs
$ DISP " "
$ DISP "I will now wait for the first assembly to finish."
$ synchronize BOBS/queue=SYS$SLOW
$ @['TOPDIR'.COM]CAPTURE SLOW @['MICADIR']vsymver bobs.lis bobs y
$ DISP " "
$ DISP "I will now wait for the symbol capturing to finish."
$ synchronize CAPTURE/queue=SYS$SLOW
$ asms ['MICADIR']bobs
$ DISP " "
$ DISP "I will now wait for the second assembly to finish."
$ synchronize BOBS/queue=SYS$SLOW
$ DISP " "
$ search ['MICADIR']bobs.log "errors detected"
$B_DETECT:
$ DISP ESC,"[23;1H",ESC,"[0KResponses: [YES,NO,Control-Y]"
$ DISP ESC,"[21;1H"
$ INQUIRE YES_NO "Were there any errors detected?"
$ IF YES_NO .EQS. "YES" THEN GOTO B_ERROR
$ IF YES_NO .EQS. "Y" THEN GOTO B_ERROR
$ IF YES_NO .EQS. "NO" THEN GOTO B_NO_ERROR
$ IF YES_NO .EQS. "N" THEN GOTO B_NO_ERROR
$ GOTO B_DETECT
$B_ERROR:
$ DISP "Please examine BOBS.LOG and correct the errors."
$ DISP " "
$ DISP "Once the assembly works, don't forget to run:"
$ DISP "@['TOPDIR'.COM]EQUATES BOBS"
$ purge ['MICADIR']bobs.*
$	GOTO _EXIT
$B_NO_ERROR:
$ DISP " "
$ DISP "I will now generate the equate file."
$ DISP "Follow the instructions which follow ..."
$ DISP " "
$ @['TOPDIR'.COM]EQUATES BOBS
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
$	SORT/KEY=(pos:1,size:6) ['SAMDIR']library.equ temp.tmp
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
$	DISP "Duplicate: ""''LAST_LINE'"""
$	DISP "           ""''NEXT_LINE'"""
$	ERR_COUNT = ERR_COUNT+1
$	GOTO _LIBLOOP
$_LIBABORT2:	
$	CLOSE TMP:
$_LIBABORT1:
$	@['TOPDIR'.COM]DELETER temp.tmp
$	IF ERR_COUNT .NE. 0 THEN DISP SYS$OUTPUT "['SAMDIR']Library.equ is BAD."
$ GOTO _EXIT
$!
$_ABORT:
$_EXIT:
$	DISP ESC,"[23;1H",ESC,"[0K",ESC,"[5mTerminated",ESC,"[0m"
$	DISP ESC,"[1;24r",ESC,"[24;79H "	! Reset screen scroll region.
$	@['TOPDIR'.COM]DELETER *.tmp
$	set default ['TOPDIR']
$	show default
$	EXIT
