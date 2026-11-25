#!/usr/bin/env bats
# gates-fastpfad.bats — Waechter am Fast-Pfad-Einsprung des Targets `make gates`
# (harness/tools/gates-fast.sh, ADR-0099).
#
# HERMETISCH: getestet wird die reine Entscheidung `entscheide()` ueber den Modus
# `--entscheide` (5 Fixture-Werte) — das gepinnte bats-Image fuehrt weder `git` noch
# `make` (Abschnitt ENTSCHEIDUNG im Kopf von harness/tools/pre-commit-amend-guard.sh,
# dieselbe Grenze). Die kopplungstests lesen Skripttext; gelesen wird der gelebte
# Bestand, keine Nachbildung. Das reale Rot-vor/Gruen-nach am vollen Pfad traegt
# `make gates` selbst: der erste Lauf ueber einem geaenderten Baum faehrt voll
# (`make record-gates`), jeder weitere ueber unverändertem Baum SKIPpt — dieselbe
# Form, in der test/history-range-guard.bats ihre Grenze haelt.
#
# ZUSAEGEN:
#   1. Die SKIP-Bedingung (ADR-0099 Festlegung 1): SKIP nur, wenn BEIDE Stempel
#      decken — diffsha gegen den Baum-Hash (64 Hex, Form von working-tree-hash.sh)
#      und head gegen die aufgelöste HEAD-SHA (oder `kein-commit` im commitlos-Fall,
#      wie eine SHA verglichen).
#   2. Fail-closed (Festlegung 4, MR-017): fehlender (leer), unlesbarer gestutzt oder
#      fremd geformatter Stempel → Exit 1, voller Lauf. Der SKIP urteilt nie ueber das
#      hinaus, was er sicher lesen kann.
#   3. Der Ausschalter (Festlegung 3): `GATES_FORCE=1` zwingt den vollen Lauf ueber
#      gedecktem Paar; jeder andere Wert und das Fehlen sagen nichts.
#   4. Die SKIP-Meldung nennt den benannten Rest aus Festlegung 2 (Docker-Cache-
#      Zustand, Host-Werkzeuge) und den Ausschalter.
#   5. Der Fast-Pfad schreibt keinen Stempel und ruft genau ein `make` auf:
#      `make record-gates`, dasselbe Rezept mit derselben Kante. Schreiber bleibt
#      `record-gates` (Festlegung 1).
#   6. KOPPLUNG: die drei Fassungen von `head_wert` (record-gates.sh, Stop-Hook,
#      gates-fast.sh) sind Funktionstext-identisch.
#
# WAS HIER NICHT GEMESSEN WIRD (Grenze): der Lauf im Target — dass `make gates` den
# Wrapper startet und die Kante byte-gleich bleibt, haengt an
# test/gate-nachweis-kante.bats (dort Zusage 2 und die Kanten-Zusagen); nichts hier
# liest den Makefile oder die Hooks-Verdrahtung.

setup() {
	REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	FAST="$REPO/harness/tools/gates-fast.sh"
	[ -f "$FAST" ]
}

# Fixture-Werte. Zwei Baum-Hashes (64 Hex) und zwei HEAD-Werte (40 Hex) unterscheiden
# sich je Paar voneinander, decken aber beide Formen.
DIFF_A="1111111111111111111111111111111111111111111111111111111111111111"
DIFF_B="2222222222222222222222222222222222222222222222222222222222222222"
HEAD_A="3333333333333333333333333333333333333333"
HEAD_B="4444444444444444444444444444444444444444"

@test "fastpfad: gedecktes Paar -> SKIP (Exit 0), Meldung nennt den benannten Rest" {
	run bash "$FAST" --entscheide "$DIFF_A" "$HEAD_A" "$DIFF_A" "$HEAD_A" ""
	[ "$status" -eq 0 ]
	[[ "$output" == *"SKIP"* ]]
	[[ "$output" == *"Docker-Cache-Zustand"* ]]
	[[ "$output" == *"Host-Werkzeuge"* ]]
	[[ "$output" == *"GATES_FORCE=1 erzwingt den vollen Lauf"* ]]
}

@test "fastpfad: Stempel fehlt (leer) -> voller Lauf (fail-closed)" {
	run bash "$FAST" --entscheide "" "$HEAD_A" "$DIFF_A" "$HEAD_A" ""
	[ "$status" -eq 1 ]
}

@test "fastpfad: fremder Hash am diffsha-Stempel -> voller Lauf (fail-closed)" {
	run bash "$FAST" --entscheide "$DIFF_B" "$HEAD_A" "$DIFF_A" "$HEAD_A" ""
	[ "$status" -eq 1 ]
}

@test "fastpfad: head-Stempel weicht ab -> voller Lauf (fail-closed)" {
	run bash "$FAST" --entscheide "$DIFF_A" "$HEAD_B" "$DIFF_A" "$HEAD_A" ""
	[ "$status" -eq 1 ]
}

@test "fastpfad: diffsha-Stempel ohne Baum-Hash-Form (gestutzt) -> voller Lauf (fail-closed)" {
	run bash "$FAST" --entscheide "${DIFF_A:0:40}" "$HEAD_A" "$DIFF_A" "$HEAD_A" ""
	[ "$status" -eq 1 ]
}

@test "fastpfad: head-Stempel weder SHA noch kein-commit -> voller Lauf (fail-closed)" {
	run bash "$FAST" --entscheide "$DIFF_A" "fremd" "$DIFF_A" "$HEAD_A" ""
	[ "$status" -eq 1 ]
}

@test "fastpfad: kein-commit deckt kein-commit (gedecktes Paar am ungeborenen Zweig) -> SKIP" {
	run bash "$FAST" --entscheide "$DIFF_A" "kein-commit" "$DIFF_A" "kein-commit" ""
	[ "$status" -eq 0 ]
}

@test "fastpfad: GATES_FORCE=1 ueber gedecktem Paar -> voller Lauf" {
	run bash "$FAST" --entscheide "$DIFF_A" "$HEAD_A" "$DIFF_A" "$HEAD_A" "1"
	[ "$status" -eq 1 ]
}

@test "fastpfad: GATES_FORCE=0 sagt nichts (gedecktes Paar bleibt SKIP)" {
	run bash "$FAST" --entscheide "$DIFF_A" "$HEAD_A" "$DIFF_A" "$HEAD_A" "0"
	[ "$status" -eq 0 ]
}

# Zusage 5, Halbsatz 1: das Skript ruft genau ein `make` auf — `make record-gates`,
# ohne Deckung; sonst kein make-Aufruf ausserhalb der Kommentare (die Kommentare
# nennen die Ziehl-Namen der ADR und zählen nicht).
@test "verdrahtung: der Wrapper faehrt bei Nicht-Deckung genau make record-gates" {
	aufrufe="$(grep -vE '^[[:blank:]]*#' "$FAST" | grep -F 'make ' | sed 's/^[[:blank:]]*//' | sort -u)"
	echo "make-Aufrufe (ohne Kommentare):"
	echo "$aufrufe"
	einzeln="$(printf '%s\n' "$aufrufe" | grep -c '^exec make record-gates$' || true)"
	fremd="$(printf '%s\n' "$aufrufe" | grep -cv '^exec make record-gates$' || true)"
	echo "Weiterleitungen: $einzeln; andere make-Aufrufe: $fremd"
	[ "$einzeln" -ge 1 ]
	[ "$fremd" -eq 0 ]
}

@test "verdrahtung: der Fast-Pfad schreibt keinen Stempel" {
	# Schreiber bleibt record-gates (ADR-0099 Festlegung 1): keine Ausgabeumleitung in
	# .harness/state, in keiner Zeile ausserhalb der Kommentare.
	gesandt="$(grep -vE '^[[:blank:]]*#' "$FAST" | grep -cE '>\s*[\"'"'"']?\.harness/state' || true)"
	echo "Ausgaben in .harness/state: [$gesandt] (Zusage: 0)"
	[ "$gesandt" -eq 0 ]
}

# Zusage 6: die drei Fassungen von head_wert sind Funktionstext-identisch — Kopplung
# zwischen record-gates.sh (Schreiber), .claude/hooks/stop-require-gates.sh (Konsum)
# und gates-fast.sh (Fast-Pfad).
@test "kopplung: head_wert ist in drei Fassungen gleich (Schreiber, Stop-Hook, Fast-Pfad)" {
	sed -n '/^head_wert() {/,/^}/p' "$REPO/harness/tools/record-gates.sh" > /tmp/hw-schreiber
	sed -n '/^head_wert() {/,/^}/p' "$REPO/.claude/hooks/stop-require-gates.sh" > /tmp/hw-stop
	sed -n '/^head_wert() {/,/^}/p' "$FAST" > /tmp/hw-fast
	diff /tmp/hw-schreiber /tmp/hw-stop
	diff /tmp/hw-schreiber /tmp/hw-fast
}
