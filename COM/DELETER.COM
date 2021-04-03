$ ON ERROR THEN GOTO NO_FILE
$ ON CONTROL_Y THEN GOTO _ABORT
$!
$ open/error=NO_FILE test 'P1'
$ close test
$ delete 'P1';*
$	EXIT		! OK
$NO_FILE:
$	EXIT		! OK
$_ABORT:
$	STOP		! ABORT
