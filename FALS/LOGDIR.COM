$ ! ---------------------------------------
$ ! Logdir command file for disk$user:[fals.v(SVersion)]
$ ! Author:    Noah Falstein
$ ! Last mod:  10/31/82
$ ! ---------------------------------------
$ !
$ set default disk$user:[fals.v'SVersion']
$ write sys$output "Directory: "
$ show default
