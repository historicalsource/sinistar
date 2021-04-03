$ ON ERROR THEN GOTO _ABORT
$ ON CONTROL_Y THEN GOTO _ABORT
$!
$ ESC[0,8] = %X1B				! VT100 control character.
$ WRITE SYS$OUTPUT ESC,"[23;1H",ESC,"[0KResponses: ''P3'"
$ WRITE SYS$OUTPUT ESC,"[21;1H"			! Position cursor for inquiry.
$ INQUIRE/GLO 'P1' "''ESC'[1;5m''P2'''ESC'[0m"	! Inquire in bold blink.
$	EXIT 1		! OK
$_ABORT:
$	EXIT 0		! BAD
