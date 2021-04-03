$ VERSION :== 10
$ open/write output [WITT.V'VERSION']XSAMS.EQU
$ ON CONT_Y THEN GOTO _ERROR
$ A := assign/user output sys$output
$ S := SEARCH/NOHEAD [SAM.V'VERSION']IMAGE.EQU
$ A
$ DISP "	NLIST"
$ A
$ DISP "XSAMS.EQU"
$!
$ A
$ S "IPLSHO"
$ A
$ S "ISBOMB"
$ A
$ S "ITURRE"
$ A
$ S "IWARRI"
$ A
$ S "IWARRS"
$ A
$ S "IWORKE"
$!
$ S := SEARCH/NOHEAD [SAM.V'VERSION']SAMS.EQU
$ A
$ S "ADDPIE"
$ A
$ S "ADDSCO"
$ A
$ S "ALIVE "
$ A
$ S "ANIMEN"
$ A
$ S "ANIMPT"
$ A
$ S "ANIMTB"
$ A
$ S "BOMBS "
$ A
$ S "BOUNCE"
$ A
$ S "CARRY "
$ A
$ S "CCRYST"
$ A
$ S "CHGA  "
$ A
$ S "CHGOBJ"
$ A
$ S "CLTABL"
$ A
$ S "CNULL "
$ A
$ S "CPLAN1"
$ A
$ S "CPLAN2"
$ A
$ S "CPLAN3"
$ A
$ S "CPLAN4"
$ A
$ S "CPLAN5"
$ A
$ S "CPLAYE"
$ A
$ S "CPLSHO"
$ A
$ S "CSINI "
$ A
$ S "CSBOMB"
$ A
$ S "CWARRI"
$ A
$ S "CWARSH"
$ A
$ S "CWORKC"
$ A
$ S "CWORKE"
$ A
$ S "DCNS  "
$ A
$ S "DCTRL "
$ A
$ S "DDEST "
$ A
$ S "DEALLO"
$ A
$ S "DEATIM"
$ A
$ S "DHIGH "
$ A
$ S "DISP  "
$ A
$ S "DISPE "
$ A
$ S "DWBL  "
$ A
$ S "DZSP  "
$ A
$ S "D$P   "
$ A
$ S "ERASE "
$ A
$ S "FALSE "
$ A
$ S "FINISH"
$ A
$ S "FIRE  "
$ A
$ S "FSINCO"
$ A
$ S "GETOBJ"
$ A
$ S "GROUND"
$ A
$ S "HRUMPH"
$ A
$ S "IMGOBJ"
$ A
$ S "KILLOB"
$ A
$ S "KOBJEC"
$ A
$ S "LSSINI"
$ A
$ S "MEMCTL"
$ A
$ S "MESGTI"
$ A
$ S "MESLEN"
$ A
$ S "MODSIN"
$ A
$ S "NCOLLI"
$ A
$ S "NEWTUN"
$ A
$ S "OCHAR "
$ A
$ S "OCLELS"
$ A
$ S "OCOSIN"
$ A
$ S "ODRWVE"
$ A
$ S "OEFFEC"
$ A
$ S "OFIDES"
$ A
$ S "OHEIGH"
$ A
$ S "OIDESC"
$ A
$ S "OINDEX"
$ A
$ S "OINVEC"
$ A
$ S "OKIVEC"
$ A
$ S "OLCENT"
$ A
$ S "OLEFT "
$ A
$ S "OLPOS "
$ A
$ S "OLPOSF"
$ A
$ S "OLSVEC"
$ A
$ S "OLVEL "
$ A
$ S "ONIDES"
$ A
$ S "OONSCR"
$ A
$ S "OPDRWV"
$ A
$ S "OSANAN"
$ A
$ S "OSCAN "
$ A
$ S "OSCENT"
$ A
$ S "OSCHAR"
$ A
$ S "OSCLDC"
$ A
$ S "OSCSDC"
$ A
$ S "OSCSQI"
$ A
$ S "OSCWCR"
$ A
$ S "OSEED1"
$ A
$ S "OSEED2"
$ A
$ S "OSFAST"
$ A
$ S "OSFLAN"
$ A
$ S "OSINE "
$ A
$ S "OSLPOS"
$ A
$ S "OSLVEL"
$ A
$ S "OSMIS "
$ A
$ S "OSPERS"
$ A
$ S "OSPOS "
$ A
$ S "OSPOSF"
$ A
$ S "OSSCWS"
$ A
$ S "OSSPOS"
$ A
$ S "OSSQPO"
$ A
$ S "OSSQSI"
$ A
$ S "OSSVEL"
$ A
$ S "OSTATU"
$ A
$ S "OSVEL "
$ A
$ S "OTOP  "
$ A
$ S "OUTP35"
$ A
$ S "OWSCON"
$ A
$ S "PANMAS"
$ A
$ S "PASTEO"
$ A
$ S "PCRAM "
$ A
$ S "PHRLEN"
$ A
$ S "PIECEP"
$ A
$ S "PIECET"
$ A
$ S "PLAIND"
$ A
$ S "PLYRAN"
$ A
$ S "PMEMCT"
$ A
$ S "PRTASK"
$ A
$ S "PUTOBJ"
$ A
$ S "QBANG "	! Tune BANG - something exploded!
$ A
$ S "QFIRE "
$ A
$ S "QMESG "	! Tune MESG - a message hailed to the captain!
$ A
$ S "QPLAYC"
$ A
$ S "QPLDIE"
$ A
$ S "QSFIRE"
$ A
$ S "QWFIRE"
$ A
$ S "QWORKC"
$ A
$ S "QWORKS"
$ A
$ S "RAND8B"
$ A
$ S "RAND8R"
$ A
$ S "RECTAN"
$ A
$ S "RTS   "
$ A
$ S "SBOMB "
$ A
$ S "SCOREA"
$ A
$ S "SINCOS"
$ A
$ S "SINILN"
$ A
$ S "SININD"
$ A
$ S "SINISN"
$ A
$ S "SLEEP2"
$ A
$ S "SFREE "
$ A
$ S "SLVEL "
$ A
$ S "SMUL8 "
$ A
$ S "SPLAYE"
$ A
$ S "SSVEL "
$ A
$ S "START1"
$ A
$ S "START2"
$ A
$ S "SUBPIE"
$ A
$ S "TASK4 "
$ A
$ S "TASK8 "
$ A
$ S "TASK64"
$ A
$ S "TASK12"	! Task128
$ A
$ S "TDISPE"
$ A
$ S "TEMP  "
$ A
$ S "TRAP  "
$ A
$ S "TRUE  "
$ A
$ S "UPBOMB"
$ A
$ S "VSCRON"
$ A
$ S "WPLAYE"
$ A
$ S "."
$ A
$ S "_"
$ A
$ S "	SET	"
$ A
$ DISP "	LIST"
$_ERROR:
$ close output
$ deassign sys$output
$ DISP "You may now submit RICHS.SRC for assembly."
