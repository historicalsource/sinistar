$ write SYS$OUTPUT ''P1'," >>>"
$ search junk.src "RICH,''P1'"
$ write SYS$OUTPUT "	<<< ",''P1'
$ write SYS$OUTPUT " "
