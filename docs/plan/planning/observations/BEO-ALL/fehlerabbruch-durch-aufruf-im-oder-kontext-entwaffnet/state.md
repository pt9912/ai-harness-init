**Stand:** offen

Unterhalb der Schwelle; `offen` ist hier der Normalzustand und kein Ausgang. Ein Wächter für die Aufrufform als
Klasse besteht nicht: `make shell-lint` lief über die Form grün, und ein `bats`-Fall bindet den Abbruch erst, seit
der Vorgang ihn mit einem PATH-Wrapper und einer unlesbaren Datei hergestellt hat. Träger ist der Review, der die
Aufrufform gegen die Fehlersemantik der aufgerufenen Funktion hält; die Gegenprobe ist die Datei, deren Lesen
scheitert — der Abbruch muss wiederkommen.
