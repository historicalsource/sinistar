$ assign/user nl: SYS$OUTPUT	! Get rid of FILE NOT FOUND message.
$ ON ERROR THEN GOTO NONE
$ ON CONTROL_Y THEN GOTO ABORT
$!
$ IF "''F$SEARCH(P1)'".EQS."" THEN GOTO NONE
$ open FROM 'P1'
$ read/end=NONE FROM record
$ close FROM
$	exit 1		! IF .NOT. $STATUS THEN $ GOTO GOT_SOMETHING
$NONE:
$	close FROM
$	exit 0		! GOT_NOTHING (error)
$ABORT:
$	stop		! ABORT
