#!/usr/bin/env bats
# gates-keys.bats — Waechter am Satzerzeuger der je-Check-Pruefgegenstands-Schluessel
# (harness/tools/gates-keys.sh, Tier 2 je ADR-0108).
#
# HERMETISCH: das gepinnte bats-Image fuehrt weder `git` noch `make` — der
# Satzerzeuger loest seine Wurzel deshalb ueber `--wurzel` auf; `find` und
# `sha256sum` trägt das Image (derselbe Alpine-Bauch, auf dem
# harness/tools/comment-claims.sh laeuft). Kopplungstests lesen Skripttext ueber den
# gelebten Bestand. Das reale Rot-vor/Gruen-nach am vollen Pfad traegt `make gates`
# selbst (erster Lauf voll, zweiter SKIPpt — der zweite-Runde-Beleg).
#
# ZUSAEGEN:
#   1. Der Satzerzeuger deckt EXAKT die Kante: `liste` liest die Zeile
#      `record-gates: <checks>` des Makefile (EINE Quelle) und fuer JEKEN Namen
#      dort liefert `key <check>` einen 64-Hex-Hash. Ein Check, der in die Kante
#      eintraete, ohne eine Tafel-Menge im Satzerzeuger zu tragen, faellt rot —
#      und im Lauf fail-closed voll (MR-017).
#   2. KEINE Menge deckt die Record-Ablage (.harness/stamp/**) oder den
#      Laufzustand (.harness/state/**): die Record-Dateien sind Ausgaben jedes
#      Konsum-Laufs und Prüfgegenstand keines Gates (ADR-0103 Festlegung 2) — ein
#      Record-only-Commit rotiert keinen Key. Verwaltet wird das an EINER Stelle
#      (MENGE_AUSSCHLUESS); das Verhalten misst der Record-Zug-Test unten am
#      Fixture, nicht der Text.
#   3. Fail-closed: unbekannter Check oder leere Menge → Exit != 0 (MR-017).
#   4. Der Schreiber bleibt `record-gates`: der volle Lauf schreibt die Keys nach
#      den Checks (gates-keys.sh alle); der Wrapper schreibt nur die Stempel der
#      von ihm gefahrenen Checks (test/gates-fastpfad.bats).
#
# WAS HIER NICHT GEMESSEN WIRD (Grenze): dass die Tafel-Begründungen je Check
# TRAGEN — ob die Menge den Gelesen-Bestand deckt, ist die Einweihungs-Messung des
# Plans (§3), bewacht über die Kanten-Wächter und die Re-Evaluierungs-Trigger 1 und
# 4 der ADR-0108, nicht über einen Text-Vergleich hier.

setup() {
	REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	KEYS="$REPO/harness/tools/gates-keys.sh"
	[ -f "$KEYS" ]
}

@test "keys: liste traegt genau die Kante des Makefile" {
	# EINE Quelle: die Kante selbst. Ist sie leer oder weicht sie von der
	# Makefile-Zeile ab, deckt der Satzerzeuger nicht, was `make record-gates`
	# faehrt.
	kante="$(sed -n 's/^record-gates:[[:space:]]*//p' "$REPO/Makefile" | sed 's/##.*//' | tr -s '[:blank:]' '\n' | sed '/^$/d')"
	run bash "$KEYS" --wurzel "$REPO" liste
	[ "$status" -eq 0 ]
	[ "$output" = "$kante" ]
	[ -n "$kante" ]
}

@test "keys: je Check der Kante gibt es eine Menge" {
	while IFS= read -r check; do
		[ -n "$check" ] || continue
		run bash "$KEYS" --wurzel "$REPO" key "$check"
		echo "Check [$check] exit=$status key=[$output] (Zusage: exit 0, 64 Hex)"
		[ "$status" -eq 0 ]
		[[ "$output" =~ ^[0-9a-f]{64}$ ]]

	done < <(bash "$KEYS" --wurzel "$REPO" liste)
}

@test "keys: key ist deterministisch (zwei Laeufe, derselbe Wert)" {
	k1="$(bash "$KEYS" --wurzel "$REPO" key docs-check-host)"
	k2="$(bash "$KEYS" --wurzel "$REPO" key docs-check-host)"
	[ -n "$k1" ] && [ "$k1" = "$k2" ]
}

@test "keys: unbekannter Check faellt fail-closed" {
	run bash "$KEYS" --wurzel "$REPO" key unbekannter-check
	[ "$status" -ne 0 ]
	[[ "$output" == *"unbekannter Check"* ]]
}

@test "keys: keine Menge deckt die Record- oder Laufzustands-Ablage" {
	while IFS= read -r check; do
		[ -n "$check" ] || continue
		run bash "$KEYS" --wurzel "$REPO" menge "$check"
		leak="$(printf '%s\n' "$output" | grep -E '^\.harness/(stamp|state)' || true)"
		echo "Check [$check]; Ablage-Treffer: [${leak}] (Zusage: leer, ADR-0103 Festlegung 2)"
		[ -z "$leak" ]

	done < <(bash "$KEYS" --wurzel "$REPO" liste)
}

# Zusaegen 2 und 4 (Record-Zug + deklarierte Rest-Klassen) am selben Fixture: der
# Record-only-Vertrag (die engere ADR-0103-Menge .harness/stamp/mutate) misst beide
# Richtungen — `menge` und `rest` tragen die Record-Ablage nicht — und der deklarierte
# Zuordnungs-Rest (ADR-0108 Abwaegung E, Deklarations-Form) bleibt aus der
# rest-Beurteilung heraus, ein undeklarierter Neuzugang faellt als List-Zeile auf
# (fail-closed, MR-017).
@test "keys: ein Record-Zug unter .harness/stamp bewegt keinen je-Check-Key" {
	FIX=$(mktemp -d)
	(
		mkdir -p "$FIX/docs" "$FIX/.harness/stamp/mutate"
		printf 'record-gates: docs-check-host ## Checks + Gate-Nachweis\n\ndocs-check-host: ## x\n\t@echo x\n' > "$FIX/Makefile"
		printf 'scan:\n  roots: ["."]\n' > "$FIX/.d-check.yml"
		printf 'DCHECK_IMAGE ?= f\n' > "$FIX/d-check.mk"
		printf 'inhalt\n' > "$FIX/docs/a.md"
		k1="$(bash "$KEYS" --wurzel "$FIX" key docs-check-host)"
		# Record-only-Vertrag (ADR-0103 Festlegung 2, enge Menge): die Record-Datei
		# taucht in keiner menge- und keiner rest-Ausgabe auf.
		printf 'record-only\n' > "$FIX/.harness/stamp/mutate/beleg.md"
		menge_leak="$(bash "$KEYS" --wurzel "$FIX" menge docs-check-host | grep -E '^\.harness/stamp' || true)"
		rest_leak="$(bash "$KEYS" --wurzel "$FIX" rest 2>/dev/null | grep -E '^\.harness/stamp' || true)"
		printf 'menge-Leak=[%s] rest-Leak=[%s] (Zusage: beides leer)\n' "$menge_leak" "$rest_leak"
		[ -z "$menge_leak" ]
		[ -z "$rest_leak" ]
		k2="$(bash "$KEYS" --wurzel "$FIX" key docs-check-host)"
		printf 'real\n' > "$FIX/docs/b.md"
		k3="$(bash "$KEYS" --wurzel "$FIX" key docs-check-host)"
		printf 'vor=%s nach-record=%s nach-real=%s\n' "$k1" "$k2" "$k3"
		[ -n "$k1" ]
		[ "$k1" = "$k2" ]
		[ "$k1" != "$k3" ]
	)
	rm -rf "$FIX"
}

@test "keys: der Walk liegt ganz in der Tafel-Vereinigung oder einer deklarierten Rest-Klasse; ein undeklarierter Neuzugang faellt auf" {
	# Zusaetze der Aufrufer-Reihenfolge: erst die deklarierte Form (rest leer, Exit 0),
	# dann der Gap-Detektor am Fixture (eine Datei ausserhalb jeder Menge und Klasse →
	# List-Zeile und Exit 1).
	run bash "$KEYS" --wurzel "$REPO" rest
	rest_leer="$(printf '%s' "$output" | grep -cvE '^$' || true)"
	echo "rest-Zeilen: $rest_leer (Zusage: 0 — die Bauch-Flache liegt ganz in Menge oder Deklaration)"
	[ "$status" -eq 0 ]
	[ "$rest_leer" -eq 0 ]
	FIX=$(mktemp -d)
	(
		mkdir -p "$FIX"
		printf 'record-gates: docs-check-host ## Checks + Gate-Nachweis\n\ndocs-check-host: ## x\n\t@echo x\n' > "$FIX/Makefile"
		printf 'scan:\n  roots: ["."]\n' > "$FIX/.d-check.yml"
		printf 'DCHECK_IMAGE ?= f\n' > "$FIX/d-check.mk"
		printf 'inhalt\n' > "$FIX/README.md"
		printf 'lizenz\n' > "$FIX/LICENSE"
		: > "$FIX/platzhalter.gitkeep"
		mkdir -p "$FIX/docs/user/images"
		printf 'x' > "$FIX/docs/user/images/bild.png"
		run bash "$KEYS" --wurzel "$FIX" rest
		[ "$status" -eq 0 ]
		[ -z "$output" ]
		printf 'undeckbar\n' > "$FIX/neu-beliebig.txt"
		run bash "$KEYS" --wurzel "$FIX" rest
		[ "$status" -eq 1 ]
		grep -qxF 'neu-beliebig.txt' <<<"$output"
	)
	rm -rf "$FIX"
}

@test "keys: die test-Menge deckt die geembedeten Vorlagen-Baume und die emit-Testdata (Zuschlag, Plan-Fortschreibung §3)" {
	run bash "$KEYS" --wurzel "$REPO" menge test
	[ "$status" -eq 0 ]
	for form in 'internal/emit/templates/enforce/repo.mk' 'internal/emit/templates/d-check.yml' 'internal/emit/testdata/raw-print-mk.txt'; do
		[ -f "$REPO/$form" ] || continue
		echo "test-Menge-Deckung fuer [$form] (Zusage: eine Zeile der Menge)"
		grep -qxF "$form" <<<"$output"
	done
	# Die Zaehne am Fixture: ein Vorlagen-Edit dreht den test-Key.
	FIX=$(mktemp -d)
	(
		mkdir -p "$FIX/internal/emit/templates/enforce" "$FIX/test" "$FIX/internal"
		printf 'record-gates: test ## x\n\ntest: ## x\n\t@echo x\n' > "$FIX/Makefile"
		printf 'module x\n' > "$FIX/go.mod"
		printf 'main\n' > "$FIX/main.go"
		printf 'inhalt\n' > "$FIX/internal/emit/templates/enforce/vorlage.mk"
		printf 'inhalt\n' > "$FIX/test/ein-bats.txt"
		k1="$(bash "$KEYS" --wurzel "$FIX" key test)"
		printf 'geaendert\n' > "$FIX/internal/emit/templates/enforce/vorlage.mk"
		k2="$(bash "$KEYS" --wurzel "$FIX" key test)"
		printf 'vor=%s nach-vorlage-edit=%s\n' "$k1" "$k2"
		[ -n "$k1" ] && [ -n "$k2" ]
		[ "$k1" != "$k2" ]
	)
	rm -rf "$FIX"
}

@test "keys: je Check mit Werkzeug-Skript deckt die Menge ihr eigenes Skript" {
	# JEDES Check-Rezept der Kante, das `bash harness/tools/<check>.sh` faehrt,
	# liest sein Skript ein — die Menge deckt es (Plan §3, Messrezept: die
	# Deckung ist gezeigt, nicht angenommen). Deckt sie nicht, SKIPpt der
	# Fast-Pfad am Skript-Drift des Checks.
	while IFS= read -r check; do
		[ -n "$check" ] || continue
		skript="harness/tools/${check}.sh"
		[ -f "$REPO/$skript" ] || continue
		run bash "$KEYS" --wurzel "$REPO" menge "$check"
		[ "$status" -eq 0 ]
		echo "Check [$check]: Skript-Deckung fuer [$skript] (Zusage: eine Zeile der Menge)"
		grep -qxF "$skript" <<<"$output"
	done < <(bash "$KEYS" --wurzel "$REPO" liste)
}

@test "keys: die kompilierte Menge des host-bin deckt die Baubasis (Makefile, go.mod, go.sum, cmd- und internal-Quellen)" {
	# Der Rezept-Form nach kompiliert `go build` die cmd-Quellen samt ihrer
	# internal-Abhaengigkeiten und liest die Modul-Daten. Deckt die Menge einen
	# Bestandteil nicht, SKIPpt der Fast-Pfad am Bau-Drift, ohne den Bau zu
	# fahren. go.sum liegt im Bestand NICHT vor (der Modul-Kontext traegt keine
	# Abhaengigkeit) — die Menge traegt den Eintrag nicht (Review F-3); der
	# Form-Schritt unten schraenkt auf bestehende Dateien, ein kuenftiger
	# go.sum-Beitrag ist ein Menge-Zuschlag mit eigener Begruendung am Eintrag.
	run bash "$KEYS" --wurzel "$REPO" menge host-bin
	[ "$status" -eq 0 ]
	for form in 'Makefile' 'go.mod' 'go.sum'; do
		[ -f "$REPO/$form" ] || continue
		echo "Baubasis [$form] (Zusage: eine Zeile der Menge)"
		grep -qxF "$form" <<<"$output"
	done
	echo "cmd-Quelle (Zusage: mindestens eine Zeile unter cmd/, internal-Quelle dito unter internal/)"
	[ -n "$(grep '^cmd/' <<<"$output" | head -1)" ]
	[ -n "$(grep '^internal/' <<<"$output" | head -1)" ]
}

@test "keys: die Rezeptzeilen der Kante liegen in den Mengen (Makefile je Check)" {
	# JEDES Check-Rezept der Kante lebt im Makefile — deckt die Menge es nicht,
	# entzaubert der Rezept-Edit den je-Check-Key (golangci-lint run driftet
	# keinen Key, der Fast-Pfad SKIPpt über alter Urteils-Basis; Review F-1).
	while IFS= read -r check; do
		[ -n "$check" ] || continue
		run bash "$KEYS" --wurzel "$REPO" menge "$check"
		[ "$status" -eq 0 ]
		echo "Check [$check]: Rezept-Kopplung fuer [Makefile] (Zusage: eine Zeile der Menge)"
		grep -qxF 'Makefile' <<<"$output"
	done < <(bash "$KEYS" --wurzel "$REPO" liste)
}

@test "keys: der Rezept-Edit der Kante dreht den je-Check-Key" {
	# DIE ZAEHNE des Rezept-Koppels am Minibestand: Rezept-Zeile im Makefile der
	# Fixture-Wurzel ändern, und der lint-Key driftet — dieselbe Form wie der
	# Rezept-Edit am gelebten Makefile. Der .golangci.yml-Füller hält die Menge
	# vor dem Fix nicht leer (leere Menge wäre fail-closed-Rot am falschen Grund).
	FIX=$(mktemp -d)
	(
		mkdir -p "$FIX"
		printf '%s\n' 'record-gates: lint ## Checks + Nachweis' '' 'lint: ## x' '	golangci-lint run ./...' > "$FIX/Makefile"
		printf 'inhalt\n' > "$FIX/.golangci.yml"
		k1="$(bash "$KEYS" --wurzel "$FIX" key lint)"
		sed -i 's/^\t\(golangci-lint run \)\.\/\.\.\./\t\1.\/... -einstellung/' "$FIX/Makefile"
		k2="$(bash "$KEYS" --wurzel "$FIX" key lint)"
		printf 'vor=%s nach-rezept=%s\n' "$k1" "$k2"
		[ -n "$k1" ] && [ -n "$k2" ]
		[ "$k1" != "$k2" ]
	)
	rm -rf "$FIX"
}

@test "keys: der Schreiber bleibt record-gates (voller Lauf schreibt je Check)" {
	schreibt="$(grep -vE '^[[:blank:]]*#' "$REPO/harness/tools/record-gates.sh" | grep -c 'gates-keys\.sh alle' || true)"
	stempelt="$(grep -vE '^[[:blank:]]*#' "$REPO/harness/tools/gates-fast.sh" | grep -cE 'gates-keys\.sh stamp' || true)"
	echo "record-gates schreibt: $schreibt (Zusage >= 1); fast-Pfad stuempelt je gefahrenem Check: $stempelt (Zusage >= 1, nie die zwei Gesamt-Dateien — test/gates-fastpfad.bats)"
	[ "$schreibt" -ge 1 ]
	[ "$stempelt" -ge 1 ]
}
