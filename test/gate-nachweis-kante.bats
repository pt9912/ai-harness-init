#!/usr/bin/env bats
# gate-nachweis-kante.bats — Waechter ueber der Ordnungskante des Gate-Nachweises:
# `make gates` hinterlaesst keinen Nachweis, wenn eines seiner Ziele rot war.
#
# WARUM STRUKTUR UND NICHT LAUF: der bats-Container traegt weder Docker noch make
# (dieselbe Linie wie test/release-matrix.bats), und ein `make -k gates` als Test
# kostete jeden Gate ein zweites Mal. Gelesen wird der GELEBTE Makefile dieses Repos —
# keine Nachbildung, die sich selbst misst.
#
# DIE DREI ZUSAGEN, DIE HIER HAENGEN:
#   1. Die Kante existiert: record-gates hat Voraussetzungen. Ohne sie steht der
#      Stempel NEBEN den Checks, und `make -k gates` schreibt ihn ueber rotem Stand; der
#      Stop-Hook vergleicht genau diesen Hash und gaebe einen Abschluss frei, den er
#      nicht decken darf.
#   2. Kein Check steht neben record-gates: jede Voraussetzung von `gates` ausser
#      record-gates selbst ist auch Voraussetzung von record-gates. Ein daneben
#      gehaengter Check oeffnet das Loch fuer genau diesen Check wieder — dass er
#      ZUSAETZLICH an der Kante haengt, schadet nicht, denn make baut ein Ziel mit
#      gefallener Voraussetzung auch dann nicht.
#   3. `gates` zieht den Nachweis ueberhaupt. Ohne diese Zusage waeren 1 und 2 auch
#      dadurch erfuellt, dass gar kein Nachweis mehr entsteht.
#
# WAS ER NICHT PRUEFT (Grenze): das VERHALTEN von make. `make -i`, `make -j` und ein
# Aufruf des Skripts an make vorbei sind an der Struktur nicht sichtbar; sie stehen als
# Grenze im Makefile neben der Kante und im Kopf von harness/tools/record-gates.sh.
# Ebenfalls draussen: Doppelpunkt-Regeln (`ziel::`) — dieses Repo fuehrt keine
# (`grep -cE '^[A-Za-z_.-]+::' Makefile d-check.mk` -> je 0), und ein Waechter ueber
# einer Form, die es nicht gibt, hat einen leeren Pruefbereich.
# Und: gelesen wird der Makefile in der WURZEL. Ein eingebundenes Fragment, das `gates`
# oder `record-gates` um Voraussetzungen erweitert, saehe dieser Waechter nicht — heute
# tut es keines, es gibt genau ein `include` und es ruehrt beide Ziele nicht an
# (`grep -cE '^(gates|record-gates):' d-check.mk` -> 0).

setup() {
	REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	MK="$REPO/Makefile"
	[ -f "$MK" ]
}

# Fortsetzungszeilen (`\` am Zeilenende) zusammenziehen, BEVOR gelesen wird: eine ueber
# zwei Zeilen gesetzte Voraussetzungs-Liste saehe sonst halb aus, und der Waechter waere
# rot ohne Befund.
mk_joined() {
	sed -e :a -e '/\\$/N; s/\\\n//; ta' "$MK"
}

# Voraussetzungen eines Ziels, aus ALLEN Regel-Zeilen dieses Ziels: make fuehrt mehrere
# Regeln desselben Ziels zusammen, ein Blick auf nur eine Zeile saehe die halbe Kante.
# Weg fallen der Hilfe-Kommentar (`## …`) und ziel-spezifische Zuweisungen
# (`ziel: VAR := wert`), die keine Voraussetzung sind.
prereqs() {
	local ziel="$1"
	mk_joined \
		| grep -E "^${ziel}:([^=]|$)" \
		| grep -v ':=' \
		| sed -e 's/##.*//' -e "s/^${ziel}://" \
		| tr ' \t' '\n\n' \
		| grep -v '=' \
		| sed '/^$/d' || true
}

# Die Diagnose-Zeilen setzen die Listen EINZEILIG: bats stellt jeder Ausgabezeile ein
# `# ` voran, und eine zehnzeilige Liste versteckt den Befund in zehn Kommentarzeilen.
@test "gate-nachweis: record-gates haengt an den Checks (Ordnungskante steht)" {
	kante="$(prereqs record-gates | tr '\n' ' ')"
	echo "Voraussetzungen von record-gates: [${kante}]"
	echo "Ohne sie baut make den Stempel auch unter -k, wenn ein Check gefallen ist."
	[ -n "$kante" ]
}

@test "gate-nachweis: kein Check steht neben record-gates" {
	kante="$(prereqs record-gates)"
	daneben=""
	for ziel in $(prereqs gates); do
		if [ "$ziel" = "record-gates" ]; then
			continue
		fi
		if ! printf '%s\n' "$kante" | grep -qx -- "$ziel"; then
			daneben="${daneben} ${ziel}"
		fi
	done
	echo "Voraussetzungen von gates:        [$(prereqs gates | tr '\n' ' ')]"
	echo "Voraussetzungen von record-gates: [$(printf '%s\n' "$kante" | tr '\n' ' ')]"
	echo "steht daneben statt an der Kante: [${daneben}]"
	[ -z "$daneben" ]
}

@test "gate-nachweis: gates zieht den Gate-Nachweis ueber record-gates" {
	echo "Voraussetzungen von gates: [$(prereqs gates | tr '\n' ' ')]"
	prereqs gates | grep -qx 'record-gates'
}
