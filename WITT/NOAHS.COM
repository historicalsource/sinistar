$ VERSION := V9
$ open/write output [FALS.'VERSION']XSAMRICH.EQU
$ ON CONT_Y THEN GOTO _ERROR
$ A := assign/user output sys$output
$ S := SEARCH/NOHEAD [SAM.'VERSION']SAMS.EQU,[WITT.'VERSION']RICHS.EQU
$ A
$ DISP "	NLIST"
$ A
$ DISP "XSAMRICH.EQU"
$ A
$! S "ADDPIE"
$ A
$! S "ADDSCO"
$ A
$! S "ALIVE "
$ A
$! S "ANIMEN"
$ A
$! S "ANIMPT"
$ A
$! S "ANIMTB"
$ A
$! S "BOMBS "
$ A
$! S "BOUNCE"
$ A
$! S "CARRY "
$ A
$! S "CCRYST"
$ A
$! S "CHGA  "
$ A
$! S "CHGOBJ"
$ A
$! S "CLTABL"
$ A
$! S "CNULL "
$ A
$! S "CPLAN1"
$ A
$! S "CPLAN2"
$ A
$! S "CPLAN3"
$ A
$! S "CPLAN4"
$ A
$! S "CPLAN5"
$ A
$! S "CPLAYE"
$ A
$! S "CPLSHO"
$ A
$! S "CSINI "
$ A
$! S "CSINIB"
$ A
$! S "CWARRI"
$ A
$! S "CWARSH"
$ A
$! S "CWORKC"
$ A
$! S "CWORKE"
$ A
$! S "DCNS  "
$ A
$! S "DCTRL "
$ A
$! S "DDEST "
$ A
$! S "DEATIM"
$ A
$! S "DHIGH "
$ A
$! S "DWBL  "
$ A
$! S "DZSP  "
$ A
$! S "D$P   "
$ A
$! S "FALSE "
$ A
$! S "FINISH"
$ A
$! S "FIRE  "
$ A
$! S "FSINCO"
$ A
$! S "GETOBJ"
$ A
$! S "GROUND"
$ A
$! S "IMGOBJ"
$ A
$! S "IPLSHO"
$ A
$! S "IWARRI"
$ A
$! S "IWARSH"
$ A
$! S "IWORKE"
$ A
$! S "KILLOB"
$ A
$! S "LCRYST"
$ A
$! S "LPLANE"
$ A
$! S "LPLAYE"
$ A
$! S "LPLSHO"
$ A
$! S "LSINI "
$ A
$! S "LSINIB"
$ A
$! S "LWARRI"
$ A
$! S "LWARSH"
$ A
$! S "LWORKC"
$ A
$! S "LWORKE"
$ A
$! S "MEMCTL"
$ A
$! S "MESGTI"
$ A
$! S "MODSIN"
$ A
$! S "NEWTUN"
$ A
$! S "OCHAR "
$ A
$! S "OCLELS"
$ A
$! S "OCOSIN"
$ A
$! S "ODRWVE"
$ A
$! S "OHEIGH"
$ A
$! S "OIDESC"
$ A
$! S "OINDEX"
$ A
$! S "OINVEC"
$ A
$! S "OKIVEC"
$ A
$! S "OLCENT"
$ A
$! S "OLEFT "
$ A
$! S "OLPOS "
$ A
$! S "OLPOSF"
$ A
$! S "OLSVEC"
$ A
$! S "OLVEL "
$ A
$! S "ONIDES"
$ A
$! S "OONSCR"
$ A
$! S "OSANAN"
$ A
$! S "OSCAN "
$ A
$! S "OSCENT"
$ A
$! S "OSCHAR"
$ A
$! S "OSCLDC"
$ A
$! S "OSCSDC"
$ A
$! S "OSCSQI"
$ A
$! S "OSCWCR"
$ A
$! S "OSEED1"
$ A
$! S "OSEED2"
$ A
$! S "OSFAST"
$ A
$! S "OSFLAN"
$ A
$! S "OSINE "
$ A
$! S "OSLPOS"
$ A
$! S "OSLVEL"
$ A
$! S "OSMIS "
$ A
$! S "OSPERS"
$ A
$! S "OSPOS "
$ A
$! S "OSPOSF"
$ A
$! S "OSSCWS"
$ A
$! S "OSSPOS"
$ A
$! S "OSSQPO"
$ A
$! S "OSSQSI"
$ A
$! S "OSSVEL"
$ A
$! S "OSTATU"
$ A
$! S "OSVEL "
$ A
$! S "OTOP  "
$ A
$! S "OWSCON"
$ A
$! S "PANMAS"
$ A
$! S "PAWAKE"
$ A
$! S "PCRAM "
$ A
$! S "PIECEP"
$ A
$! S "PIECET"
$ A
$! S "PLAIND"
$ A
$! S "PLYRAN"
$ A
$! S "PMEMCT"
$ A
$! S "PORBIT"
$ A
$! S "PRTASK"
$ A
$! S "PSHOOT"
$ A
$! S "PTHINK"
$ A
$! S "PUTOBJ"
$ A
$! S "PWAIT "
$ A
$! S "RAND8B"
$ A
$! S "RAND8R"
$ A
$! S "RECTAN"
$ A
$! S "RTS   "
$ A
$! S "SBOMB "
$ A
$! S "SCOREA"
$ A
$! S "SINCOS"
$ A
$! S "SINILN"
$ A
$! S "SININD"
$ A
$! S "SINISN"
$ A
$! S "SLEEP2"
$ A
$! S "SLVEL "
$ A
$! S "SMUL8 "
$ A
$! S "SPLAYE"
$ A
$! S "SSVEL "
$ A
$! S "SUBPIE"
$ A
$! S "TASK64"
$ A
$! S "TBANG "
$ A
$! S "TEMP  "
$ A
$! S "TFIRE "
$ A
$! S "TPLAYC"
$ A
$! S "TPLDIE"
$ A
$! S "TRAP  "
$ A
$! S "TRUE  "
$ A
$! S "TSFIRE"
$ A
$! S "TSINIB"
$ A
$! S "TWFIRE"
$ A
$! S "TWORKC"
$ A
$! S "TWORKS"
$ A
$! S "UPBOMB"
$ A
$! S "VSCRON"
$ A
$! S "WPLAYE"
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
