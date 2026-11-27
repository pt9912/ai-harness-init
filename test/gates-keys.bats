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

# Zusage 2, die eigentliche Zähne: der FIXTURE-Record-Zug. In eine Mini-Wurzel
# wird unter .harness/stamp/mutate/ eine Ablage geschrieben (beleg.md) — wenn der
# Schlüssel sie deckte, rotierte jeder Record-only-Commit den Key. Die Kontrolle
# daneben beweist, dass der Schlüssel INHALT-tragend ist: dieselbe Schreibweise
# unter docs/ bewegt ihn.
@test "keys: ein Record-Zug unter .harness/stamp bewegt keinen je-Check-Key" {
	FIX=$(mktemp -d)
	(
		mkdir -p "$FIX/docs" "$FIX/.harness/stamp/mutate"
		printf 'record-gates: docs-check-host ## Checks + Gate-Nachweis\n\ndocs-check-host: ## x\n\t@echo x\n' > "$FIX/Makefile"
		printf 'scan:\n  roots: ["."]\n' > "$FIX/.d-check.yml"
		printf 'DCHECK_IMAGE ?= f\n' > "$FIX/d-check.mk"
		printf 'inhalt\n' > "$FIX/docs/a.md"
		k1="$(bash "$KEYS" --wurzel "$FIX" key docs-check-host)"
		printf 'record-only\n' > "$FIX/.harness/stamp/mutate/beleg.md"
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

@test "keys: der Schreiber bleibt record-gates (voller Lauf schreibt je Check)" {
	schreibt="$(grep -vE '^[[:blank:]]*#' "$REPO/harness/tools/record-gates.sh" | grep -c 'gates-keys\.sh alle' || true)"
	stempelt="$(grep -vE '^[[:blank:]]*#' "$REPO/harness/tools/gates-fast.sh" | grep -cE 'gates-keys\.sh stamp' || true)"
	echo "record-gates schreibt: $schreibt (Zusage >= 1); fast-Pfad stuempelt je gefahrenem Check: $stempelt (Zusage >= 1, nie die zwei Gesamt-Dateien — test/gates-fastpfad.bats)"
	[ "$schreibt" -ge 1 ]
	[ "$stempelt" -ge 1 ]
}
