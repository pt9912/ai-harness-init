#!/usr/bin/env bats
# gate-nachweis-kante.bats — Waechter ueber der Ordnungskante des Gate-Nachweises:
# `make gates` hinterlaesst keinen Nachweis, wenn eines seiner Ziele rot war.
#
# WARUM STRUKTUR UND NICHT LAUF: der bats-Container traegt weder Docker noch make
# (dieselbe Linie wie test/release-matrix.bats), und ein `make -k gates` als Test
# kostete jeden Gate ein zweites Mal. Gelesen wird der GELEBTE Makefile dieses Repos —
# keine Nachbildung, die sich selbst misst.
#
# DIE FUENF ZUSAGEN, DIE HIER HAENGEN:
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
#   4. An der Kante haengen GENAU die erwarteten Checks. 1 bis 3 sind auch von einer
#      Kante mit einer einzigen Voraussetzung erfuellt: die uebrigen fielen aus `gates`
#      heraus, und der Stempel deckte einen Baum, ueber den sie nie geurteilt haben.
#      Geprueft wird der Bestand, nicht die Reihenfolge — die haengt an Zusage 5.
#   5. baseline-verify haengt als ERSTER an der Kante. Das ist die Reihenfolgen-Zusage,
#      die im Makefile neben der Kante steht: steht die vendored Baseline nicht, ist jede
#      Aussage der Folge-Gates ueber sie wertlos. Serielles make baut die Voraussetzungen
#      in Listen-Reihenfolge ab; unter `-j` faellt die Zusage (Grenze unten).
#
# ZUSAGE 4 IST STRENGER ALS ZUSAGE 1: eine leere Kante verletzt beide, 1 faellt also nie
# allein. Sie bleibt trotzdem stehen, weil sie den Mechanismus benennt und ihre Diagnose
# beim totalen Wegfall sagt, warum das Loch zurueck ist. Wer die Liste kuerzt, sieht 4
# fallen; wer die Kante ganz entfernt, sieht 1, 4 und 5 zusammen fallen.
#
# DIE ERWARTUNGSLISTE IN ZUSAGE 4 IST EINE ZWEITE BUCHFUEHRUNG, kein unabhaengiger
# Beleg: welche Checks es geben SOLLTE, liest dieser Waechter nirgends. Er faengt das
# stille Kuerzen — Makefile geaendert, Liste hier nicht — und zwingt jeden neuen Gate
# durch zwei Stellen; wer beide zugleich aendert, kommt an ihm vorbei.
#
# WAS ER NICHT PRUEFT (Grenze): das VERHALTEN von make. Ob ein Lauf den Stempel
# schreibt, entscheidet make, nicht die Struktur. Die Wege, die ihn ueber rotem Stand
# schreiben, stehen im Makefile neben der Kante; gemessen sind sie an einem
# synthetischen Makefile derselben Kantenform, und so wird die Messung wiederholt:
#   d=$(mktemp -d)
#   printf '.PHONY: gates record-gates gruen rot\ngates: record-gates\nrecord-gates: gruen rot\n\t@echo STEMPEL\ngruen:\n\t@echo g\nrot:\n\t@exit 1\n' > "$d/Makefile"
#   for f in "" -k -i "-o rot"; do make -C "$d" $f gates 2>&1 | grep -c STEMPEL; done
# -> `0 0 1 1` (2026-08-30, GNU Make 4.3). Dieselbe Datei mit `.IGNORE: rot` in der
# ersten Zeile -> 1, mit `-@exit 1` statt `@exit 1` -> 1,
# `MAKEFLAGS=i make -C "$d" gates` -> 1, `MAKEFLAGS=k make -C "$d" gates` -> 0. Ein
# Aufruf des Skripts an make vorbei kennt ohnehin keinen Check.
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

# Die Erwartungsliste steht SORTIERT und wird gegen die sortierte Ist-Liste gehalten:
# so faerbt ein Umsortieren der Kante diesen Test nicht mit — dafuer steht der naechste.
@test "gate-nachweis: an der Kante haengen genau die erwarteten Checks" {
	erwartet="baseline-verify build ci-lint comment-claims docs-check host-bin lint shell-lint span-check test"
	ist="$(prereqs record-gates | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//')"
	echo "erwartet: [${erwartet}]"
	echo "ist:      [${ist}]"
	echo "Fehlt einer, deckt der Stempel einen Baum, ueber den dieser Check nie geurteilt hat."
	[ "$ist" = "$erwartet" ]
}

@test "gate-nachweis: baseline-verify haengt als erster an der Kante" {
	erster="$(prereqs record-gates | head -1)"
	echo "erste Voraussetzung von record-gates: [${erster}]"
	echo "Steht die vendored Baseline nicht, ist jede Aussage der Folge-Gates ueber sie wertlos."
	[ "$erster" = "baseline-verify" ]
}
