$ CMD_NAME = "[LIBRARY.SINISTAR.COM]ASM.COM"
$!!!
$!
$!  SYNOPSIS
$!
$!	ASM [-ABS] [-REL] [-NEW] [-OLD] [-FAST] [-MED] [-SLOW] [-BATCH] [-INT] sourcename
$!
$!  REQUIRED PARAMETERS
$!
$!	The source is read from sourcename.SRC
$!
$!  OPTIONAL PARAMETERS
$!
$!	-ABS = An absolute object is generated.
$!	-REL = A relocatable object is generated (default).
$!
$!	-NEW = Assemble using the 4/83 version of the BSO assembler (default).
$!	-OLD = Assemble using the 1982 version of the BSO assembler.
$!
$!	-FAST = Assemble in the queue SYS$FAST (default).
$!	-MED = Assemble in the queue SYS$MED
$!	-SLOW = Assemble in the queue SYS$SLOW
$!	-BATCH = Assemble in the queue SYS$BATCH
$!	-INT = Assemble interactively
$!
$!!!
$ SET NOON
$ DIR := DEFAULT
$NOP1:	IF 'F$LOCATE(":=",P1).EQ.'F$LENGTH(P1) THEN $GOTO _OKP1
$	'P1		!DEFINE OPTION
$	P1 := 'P2
$	P2 := 'P3
$	P3 := 'P4
$	P4 := 'P5
$	P5 := 'P6
$	P6 := 'P7
$	P7 := 'P8
$	P8 := 'P9
$	GOTO NOP1
$_OKP1:
$ IF "''P9'".EQS."" THEN GOTO _DEFAULTS
$	write SYS$OUTPUT "''CMD_NAME': Too many arguments."
$	EXIT
$_DEFAULTS:
$	P9 = "<EOA>"		! End of Arguments marker
$	QUEUE = "INTERACTIVE"	! Assemble interactively
$	MODE = "/R"		! Assemble in relocatable (not absolute) mode
$	BSO = "NEW"		! Use the new BSO assembler
$_ARG_CHECK:
$	IF "''P1'".EQS.""	THEN GOTO _SHIFT
$!!!
$!	The QUEUE
$!!!
$_INT:
$	IF "''P1'".NES."-INT"	THEN GOTO _FAST
$	QUEUE = "INTERACTIVE"
$	GOTO	_SHIFT
$_FAST:
$	IF "''P1'".NES."-FAST"	THEN GOTO _MED
$	QUEUE = "FAST"
$	GOTO	_SHIFT
$_MED:
$	IF "''P1'".NES."-MED"	THEN GOTO _SLOW
$	QUEUE = "MED"
$	GOTO	_SHIFT
$_SLOW:
$	IF "''P1'".NES."-SLOW"	THEN GOTO _BATCH
$	QUEUE = "SLOW"
$	GOTO	_SHIFT
$_BATCH:
$	IF "''P1'".NES."-BATCH"	THEN GOTO _ABS
$	QUEUE = "BATCH"
$	GOTO	_SHIFT
$_ABS:
$	IF "''P1'".NES."-ABS"	THEN GOTO _REL
$	MODE = "/A"
$	GOTO	_SHIFT
$_REL:
$	IF "''P1'".NES."-REL"	THEN GOTO _NEW
$	MODE = "/R"
$	GOTO	_SHIFT
$_NEW:
$	IF "''P1'".NES."-NEW"	THEN GOTO _OLD
$	BSO = "-NEW"
$	GOTO	_SHIFT
$_OLD:
$	IF "''P1'".NES."-OLD"	THEN GOTO _SOURCE
$	BSO = "-OLD"
$	GOTO	_SHIFT
$_SOURCE:
$	SOURCE = "''P1'"	! Assign the source file name
$_SHIFT:
$ P1 = "''P2'"	! Shift
$ P2 = "''P3'"	!   all
$ P3 = "''P4'"	!   the
$ P4 = "''P5'"	!   arguments
$ P5 = "''P6'"	!   down
$ P6 = "''P7'"	!   and
$ P7 = "''P8'"	!   leave
$ P8 = "''P9'"	!   the last one marked by "<EOA>".
$ IF "''P1'".NES."<EOA>" THEN GOTO _ARG_CHECK	! Examine all the arguments.
$!
$! The arguments are parsed.
$!
$ IF "''SOURCE'".NES."" THEN GOTO _ASM
$	write SYS$OUTPUT "ERROR: Source filename is missing."
$	EXIT
$_ASM:
$ IF "''QUEUE'".EQS."INTERACTIVE" THEN GOTO _ASMINT
$!	WRITE SYS$OUTPUT "ASM Q(''QUEUE') M(''MODE') B(''BSO') ''SOURCE'"
$	IF "''MODE'".EQS."/A" THEN MODE = "-ABS"
$	IF "''MODE'".EQS."/R" THEN MODE = "-REL"
$	S := SUBMIT/QUEUE=SYS$'QUEUE'/NOTIFY/LOG='F$DIR()''SOURCE'.LOG/NOPRINT
$	S/PARA=(DIR:='F$DIR()',-INT,'BSO','MODE','SOURCE')/NAME='SOURCE''QUEUE' 'CMD_NAME'
$ EXIT
$!
$_ASMINT:
$	ON ERROR THEN GOTO INTERR
$	WRITE SYS$OUTPUT "Assembling ''SOURCE'.SRC"
$	IF "''DIR'".NES."DEFAULT" THEN SET DEFAULT 'DIR'
$!
$	IF "''MODE'".EQS."/A" THEN OBJEXT = "ABS"
$	IF "''MODE'".EQS."/R" THEN OBJEXT = "ROB"
$!
$	IF "''BSO'".NES."-OLD" THEN GOTO _NEWBSO
$		BSODIR = "CROSS"
$		BSOVER = ""
$		GOTO _BSOSET
$_NEWBSO:
$	IF "''BSO'".NES."-NEW" THEN GOTO _BSOSET
$		BSODIR = "CROSS.NEW"
$		BSOVER = "V"
$_BSOSET:
$!
$!	Get rid of old LOG files.
$	IF F$SEARCH("''SOURCE'.LOG").NES."" THEN $DELETE 'SOURCE'.LOG;*
$!
$ SET VERIFY
$	MCR SY:['BSODIR']CY6809'BSOVER' 'SOURCE'.'OBJEXT','SOURCE'.LIS='SOURCE'/D/X'MODE'
$!
$	MCR SY:['BSODIR']OBJCNV 'SOURCE'.MOT/F:MOT='SOURCE'.ABS/F:BSO
$ SET NOVERIFY
$!	DELETE 'SOURCE'.ABS;*
$	PURGE	'SOURCE'.LIS,'SOURCE'.MOT,'SOURCE'.'OBJEXT'
$	EXIT
$INTERR:
$	WRITE SYS$ERROR "Assembly error(s) in ''SOURCE'.LOG"
