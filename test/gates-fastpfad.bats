#!/usr/bin/env bats
# gates-fastpfad.bats — Waechter am Fast-Pfad-Einsprung des Targets `make gates`
# (harness/tools/gates-fast.sh, Tier 2 je ADR-0108, Form nach ADR-0099).
#
# HERMETISCH: getestet wird die reine Klassifikation ueber den Modus
# `--entscheide <bericht> [force]` — je Zeile `check stamp ist`, wie der Bericht im
# Lauf aus Stempel-Datei und Satzerzeuger gebaut wird (das gepinnte bats-Image fuehrt
# weder `git` noch `make`; dieselbe Grenze wie im Kopf von
# harness/tools/pre-commit-amend-guard.sh). Die kopplungs- und verdrahtungstests
# lesen Skripttext; gelesen wird der gelebte Bestand, keine Nachbildung. Das reale
# Rot-vor/Gruen-nach am vollen Pfad traegt `make gates` selbst: der erste Lauf nach
# Aenderung faehrt voll, jeder weitere ueber unveraendertem Baum SKIPpt (der
# zweite-Runde-Beleg, test/gates-keys.bats haelt den Satzerzeuger selbst).
#
# ZUSAEGEN (Tier 2, ADR-0108 Festlegungen 1/3/4):
#   1. Die SKIP-Bedingung: SKIP nur ueber dem VOLLSTAENDIG gedeckten je-Check-Satz
#      (jeder Key formal 64 Hex und gleich dem Satzerzeuger-Wert); EXIT 0, Meldung
#      nennt den gedeckten Satz.
#   2. Teildrift: die gedrifteten Checks fahren, die uebrigen meldet die Meldung
#      ausdruecklich als gedeckt; keine von beiden ist in der Ausgabe der Melden
#      getauscht (Klassifikation deck_oder_drift).
#   3. Fail-closed (Festlegung 1, MR-017): fehlender (leer), unformaler Stempel-Wert
#      und unformaler Satzerzeuger-Wert → Exit 1, voller Lauf. Die Klassifikation
#      urteilt nie ueber das hinaus, was sie sicher lesen kann.
#   4. Der Ausschalter: `GATES_FORCE=1` zwingt den vollen Lauf; jeder andere Wert und
#      das Fehlen sagen nichts.
#   5. Die Meldungen nennen den benannten Rest (Docker-Cache-Zustand, Host-Werkzeuge)
#      und den Ausschalter (Festlegung 4).
#   6. Verdrahtung: die make-Aufrufe sind der volle Lauf (`exec make record-gates` —
#      dieselbe Weiterleitung, die Mutations-Fall 212 haelt) oder genau der
#      Teildrift-Lauf (`make "${drifted[@]}"`); die je-Check-Keys entstehen nur ueber
#      den Satzerzeuger (`gates-keys.sh stamp`), die zwei Gesamt-Dateien schreibt der
#      Wrapper nie (Festlegung 2).
#   7. KOPPLUNG: die zwei Fassungen von `head_wert` (record-gates.sh, Stop-Hook) sind
#      Funktionstext-identisch; der Fast-Pfad fuehrt die Fassung NICHT mehr — seine
#      SKIP-Bedingung ist vom Stempel-Paar (Tier 1) auf den je-Check-Satz getreten.
#
# WAS HIER NICHT GEMESSEN WIRD (Grenze): der Lauf im Target — dass `make gates` den
# Wrapper startet und die Kante byte-gleich bleibt, haengt an
# test/gate-nachweis-kante.bats; der Satzerzeuger selbst an test/gates-keys.bats.

setup() {
	REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	FAST="$REPO/harness/tools/gates-fast.sh"
	[ -f "$FAST" ]
	BERICHT="$(mktemp)"
}

teardown() {
	[ -f "${BERICHT:-}" ] && rm -f "$BERICHT"
	return 0
}

# Fixture-Werte. Zwei 64-Hex-Formen je Paar; die Names sind echte Kanten-Checks,
# damit die Meldungen sie benennen, wie der Lauf sie benennt.
K1="1111111111111111111111111111111111111111111111111111111111111111"
K2="2222222222222222222222222222222222222222222222222222222222222222"
K3="3333333333333333333333333333333333333333333333333333333333333333"

@test "fastpfad: vollstaendig gedeckter Satz -> SKIP (Exit 0), Meldung nennt Satz und Rest" {
	{ printf '%s %s %s\n' lint "$K1" "$K1"
		printf '%s %s %s\n' docs-check "$K2" "$K2"
		printf '%s %s %s\n' test "$K3" "$K3"; } > "$BERICHT"
	run bash "$FAST" --entscheide "$BERICHT" ""
	[ "$status" -eq 0 ]
	[[ "$output" == *"SKIP"* ]]
	[[ "$output" == *"lint docs-check test"* ]]
	[[ "$output" == *"Docker-Cache-Zustand"* ]]
	[[ "$output" == *"Host-Werkzeuge"* ]]
	[[ "$output" == *"GATES_FORCE=1 erzwingt den vollen Lauf"* ]]
}

# Mutations-Fall 793 haelt diese Zusage: faellt die Gleichheit aus der
# Klassifikation, driftet jeder formale Stempel, und die Meldung benennt Checks,
# die keinen Lauf brauchten (hier: mutate-greift als gedeckte Zeile).
@test "fastpfad: Teildrift meldet genau die gedrifteten Checks" {
	{ printf '%s %s %s\n' lint "$K1" "$K2"
		printf '%s %s %s\n' test "$K3" "$K1"
		printf '%s %s %s\n' mutate-greift "$K3" "$K3"; } > "$BERICHT"
	run bash "$FAST" --entscheide "$BERICHT" ""
	[ "$status" -eq 0 ]
	[[ "$output" == *"TEILDRIFT"* ]]
	[[ "$output" == *"lint"* ]]
	[[ "$output" == *"test"* ]]
	[[ "$output" != *"mutate-greift"* ]]
	[[ "$output" != *"SKIP"* ]]
}

@test "fastpfad: fehlender Key (leer) -> voller Lauf (fail-closed)" {
	{ printf '%s %s %s\n' lint "" "$K1"
		printf '%s %s %s\n' test "$K2" "$K2"; } > "$BERICHT"
	run bash "$FAST" --entscheide "$BERICHT" ""
	[ "$status" -eq 1 ]
}

@test "fastpfad: unformaler Stempel-Wert -> voller Lauf (fail-closed)" {
	{ printf '%s %s %s\n' lint "${K1:0:40}" "$K1"
		printf '%s %s %s\n' test "$K2" "$K2"; } > "$BERICHT"
	run bash "$FAST" --entscheide "$BERICHT" ""
	[ "$status" -eq 1 ]
}

@test "fastpfad: Satzerzeuger unformal -> voller Lauf (fail-closed)" {
	{ printf '%s %s %s\n' lint "$K1" "fremd"
		printf '%s %s %s\n' test "$K2" "$K2"; } > "$BERICHT"
	run bash "$FAST" --entscheide "$BERICHT" ""
	[ "$status" -eq 1 ]
}

@test "fastpfad: leerer Bericht -> SKIP (leere Kante deckt leer)" {
	: > "$BERICHT"
	run bash "$FAST" --entscheide "$BERICHT" ""
	[ "$status" -eq 0 ]
}

@test "fastpfad: GATES_FORCE=1 ueber gedecktem Satz -> voller Lauf" {
	{ printf '%s %s %s\n' lint "$K1" "$K1"; } > "$BERICHT"
	run bash "$FAST" --entscheide "$BERICHT" "1"
	[ "$status" -eq 1 ]
}

@test "fastpfad: GATES_FORCE=0 sagt nichts (gedeckter Satz bleibt SKIP)" {
	{ printf '%s %s %s\n' lint "$K1" "$K1"; } > "$BERICHT"
	run bash "$FAST" --entscheide "$BERICHT" "0"
	[ "$status" -eq 0 ]
}

# Zusage 6, Halbsatz 1: die make-Aufrufe sind der volle Lauf oder der Teildrift-Lauf;
# sonst kein make-Aufruf ausserhalb der Kommentare.
@test "verdrahtung: der Wrapper faehrt den vollen Lauf oder genau den Teildrift-Lauf" {
	aufrufe="$(grep -vE '^[[:blank:]]*#' "$FAST" | grep -F 'make ' | sed 's/^[[:blank:]]*//' | sort -u)"
	echo "make-Aufrufe (ohne Kommentare):"
	echo "$aufrufe"
	voll="$(printf '%s\n' "$aufrufe" | grep -cF 'exec make record-gates' || true)"
	fremde="$(printf '%s\n' "$aufrufe" | grep -Fvx -e 'exec make record-gates' -e 'make "${drifted[@]}" || exit $?' || true)"
	echo "Voll-Lauf-Weiterleitungen: $voll; andere make-Aufrufe: [${fremde}]"
	[ "$voll" -ge 1 ]
	[ -z "$fremde" ]
}

@test "verdrahtung: der Wrapper schreibt die je-Check-Keys nur ueber den Satzerzeuger" {
	# Kein direkter Schreibzugriff in .harness/state in keiner Zeile ausserhalb der
	# Kommentare; der Stempel-Aufruf ist `gates-keys.sh stamp` (Schreiber bleibt der
	# Satzerzeuger, Festlegung 2).
	gesandt="$(grep -vE '^[[:blank:]]*#' "$FAST" | grep -cE '>+[[:space:]]*[\"'"'"']?\.harness/state' || true)"
	aufrufe="$(grep -vE '^[[:blank:]]*#' "$FAST" | grep -c 'gates-keys\.sh stamp' || true)"
	echo "Direkte Schreibzuege nach .harness/state: [$gesandt] (Zusage: 0); Satzerzeuger-Stempel-Aufrufe: $aufrufe (Zusage: >= 1)"
	[ "$gesandt" -eq 0 ]
	[ "$aufrufe" -ge 1 ]
}

@test "verdrahtung: der Wrapper schreibt keine der zwei Gesamt-Dateien" {
	treffer="$(grep -vE '^[[:blank:]]*#' "$FAST" | grep -cE 'gates-passed\.(diffsha|head)' || true)"
	echo "Gesamt-Datei-Beruehrungen: [$treffer] (Zusage: 0, ADR-0083 Festlegung 3)"
	[ "$treffer" -eq 0 ]
}

@test "verdrahtung: der Bericht baut sich aus Stempeln und Satzerzeuger" {
	liste="$(grep -vE '^[[:blank:]]*#' "$FAST" | grep -c 'gates-keys\.sh liste' || true)"
	key="$(grep -vE '^[[:blank:]]*#' "$FAST" | grep -c 'gates-keys\.sh key' || true)"
	echo "Satzerzeuger-Aufrufe: liste=$liste key=$key (Zusage: je >= 1 — EINE Definition, keine zweite)"
	[ "$liste" -ge 1 ]
	[ "$key" -ge 1 ]
}

# Zusage 7: die zwei Fassungen von head_wert sind Funktionstext-identisch — Kopplung
# zwischen record-gates.sh (Schreiber) und .claude/hooks/stop-require-gates.sh
# (Konsum). Der Fast-Pfad fuehrt die Fassung nicht mehr (Tier 2).
@test "kopplung: head_wert ist in zwei Fassungen gleich (Schreiber, Stop-Hook)" {
	sed -n '/^head_wert() {/,/^}/p' "$REPO/harness/tools/record-gates.sh" > /tmp/hw-schreiber
	sed -n '/^head_wert() {/,/^}/p' "$REPO/.claude/hooks/stop-require-gates.sh" > /tmp/hw-stop
	diff /tmp/hw-schreiber /tmp/hw-stop
}
