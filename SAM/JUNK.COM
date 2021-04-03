$ disp := WRITE SYS$OUTPUT
$ search/output=error.tmp sams.log "No errors detected"
$ open/read/error=SAMLIS test error.tmp
$ close test
$ disp "SAMS.SRC is already assembled."
$ goto SSAMEQU
$!
$! Assemble SAMS.SRC
$!
$SAMLIS:
$ close test
$ disp "SAMS.SRC should be reassembled!"
$ exit
$SSAMEQU:
$ exit
