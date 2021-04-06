[LIBRARY.SINISTAR] is the library version of:

	 SSSS  IIIII  N   N  IIIII   SSSS  TTTTT   AAA   RRRR
	S        I    NN  N    I    S        T    A   A  R   R
	 SSS     I    N N N    I     SSS     T    AAAAA  RRRR
	    S    I    N  NN    I        S    T    A   A  R  R
	SSSS   IIIII  N   N  IIIII  SSSS     T    A   A  R   R

INTRODUCTION

The problem history with managing sources for 4 people while using
an assembler with a very limited symbol table size is not amusing.  Let it
suffice that we did what was neccessary at the time.

Our tools have progressed since Sinistar days, but the library will
have to reflect the state of those days in the way it builds a working version
of Sinistar for you.  So it is that the subdirectories for the main programmers
contain their last development version of Sinistar.

FILE ORGANIZATION

Assembly order of overlays:

[.SAM]	Contains all the V17 files from Sam Dicker	
[.WITT]	Contains all the V17 files from Rich Witt	
[.FALS]	Contains all the V17 files from Noah Falstein	 
[.MICA]	Contains all the V17 files from Bob Mical	
[.COM]	Contains a mangerie of related comand files from them all.

At the top level, [LIBRARY.SINISTAR] you will find these main files:

READ.ME		You're reading it now.  A preliminary description of things.
MAKE.COM	A command file that can rebuild Sinistar.
