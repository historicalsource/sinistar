$! EBurn= "@DISK$USER:[witt.dark]burnit BOX:=YES DEBUG:=BURN"
$ EBurn= "@DISK$USER:[common.com]dirdownu"
$!
$ ON ERROR THEN GOTO _EXIT
$ ON CONTROL_Y THEN GOTO _EXIT
$ SET VERIFY
$!!!!!
$!
$! SINISTAR MEMORY MAP ...
$! 0000 - 8BFF	Reserved for Sinistar images, executive, tactics, intelligences
$! 8C00 - 8FFF	Second part of message utility.
$!		9000 - 97FF	Screen mapped scratch RAM
$!		9800 - 98FF	Direct Page RAM
$!		9900 - BEFF	Extended RAM
$!		BF00 - BF7F	Message/Bookkeeping RAM
$!		BF80 - BFFE	DCON scratch pad RAM
$!		BFFF		DCON mirror $C800
$!		C000 - CFFF	I/O ports
$!		D000 - DEFF	Static RAM
$! E000 - E1FF	Sinistar IRQ routine.
$! E200 - EFEF	First part of message utility.
$! EFF0 - EFFF	ROM Vectors
$!
$!!!!!
$ SET NOVERIFY
$! EBurn		[LIBRARY.SINISTAR.sam]DIAG.MOT	!$F000
$ IF .NOT. $STATUS THEN $ GOTO _EXIT
$ EBurn			[LIBRARY.SINISTAR.sam]IMAGE.MOT
$ IF .NOT. $STATUS THEN $ GOTO _EXIT
$ EBurn			[LIBRARY.SINISTAR.sam]MESSAGE.MOT
$ IF .NOT. $STATUS THEN $ GOTO _EXIT
$ EBurn			[LIBRARY.SINISTAR.sam]SAMS.MOT
$ IF .NOT. $STATUS THEN $ GOTO _EXIT
$! EBurn		[LIBRARY.SINISTAR.witt]RICHS.MOT
$ IF .NOT. $STATUS THEN $ GOTO _EXIT
$! EBurn		[LIBRARY.SINISTAR.witt]RICHS2.MOT
$ IF .NOT. $STATUS THEN $ GOTO _EXIT
$! EBurn		[LIBRARY.SINISTAR.fals]NOAHS.MOT
$ IF .NOT. $STATUS THEN $ GOTO _EXIT
$! EBurn		[LIBRARY.SINISTAR.mica]BOBS.MOT
$ IF .NOT. $STATUS THEN $ GOTO _EXIT
$! EBurn		[LIBRARY.SINISTAR.witt]AOE.mot
$!
$_EXIT:
$	SET NOVERIFY
$	EXIT
