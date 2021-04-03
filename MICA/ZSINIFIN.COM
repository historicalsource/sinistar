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
$ Down [sam.V'VERSION']DIAG.MOT		! lives at $F000
$ Down [sam.V'VERSION']IMAGE.MOT
$ Down [SAM.V'VERSION']MESSAGE.MOT
$ Down [sam.V'VERSION']SAMS.MOT
$ Down [witt.V'VERSION']RICHS.MOT
$ Down [witt.V'VERSION']RICHS2.MOT
$ Down [fals.V'VERSION']NOAHS.MOT
$ Down [mica.V'VERSION']BOBS.MOT
$ Down [witt.V'VERSION']aoe.mot
$!
$ WRITE SYS$OUTPUT BELL
$	EXIT
