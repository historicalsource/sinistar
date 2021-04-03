$ ON ERROR THEN GOTO _EXIT
$ ON CONTROL_Y THEN GOTO _ABORT
$!
$ WRITE SYS$OUTPUT ESC,"[24;1H "	! Clear bottom two lines of the screen
$ WRITE SYS$OUTPUT " "			!   for informational use.
$ WRITE SYS$OUTPUT ESC,"[1;22r"		! Set scrolling region
$ WRITE SYS$OUTPUT ESC,"[24;1H",ESC,"#6",ESC,"[7mLIBRARY COPY of SINISTAR",ESC,"[0m"
$ WRITE SYS$OUTPUT ESC,"[23;1H",ESC,"[0K",ESC,"[5m",P1,ESC,"[0m: ",P2
$ WRITE SYS$OUTPUT ESC,"[21;1H"
$_EXIT:
$	EXIT
$_ABORT:
$	STOP
