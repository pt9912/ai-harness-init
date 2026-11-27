#!/usr/bin/env bash
# bats-lint.sh — shellcheck ueber die Rumpf-Logik aller test/*.bats (LH-QA-01).
#
# Aufruf: BATS_IMAGE=<image> SHELLCHECK_IMAGE=<image> bats-lint.sh   (aus der Repo-Wurzel;
# `make shell-lint-image` setzt beide Pins aus dem Makefile — hier steht kein zweiter Pin).
# ODER   : BATS_HOST=1 bats-lint.sh — der docker-los Pflicht-Weg (ADR-0109):
# `make shell-lint` ruft ihn; beide Werkzeuge liegen dann im PATH
# (Anwesenheit per Inventar: bats, shellcheck), kein Image, kein Netz.
#
# ZWEI TRAEGER, EINE LOGIK. Der Unterschied ist nur der Transport der zwei
# Werkzeuge — Extrahieren, Teilen, Fuss-Aufsatz und --exclude stimmen in beiden
# Fassungen zeilenweise ueberein; eine Mutations-Anlage muss darum keinen der
# beiden Wege ueberspringen (MR-071).
#
# ABLAUF (Image-Weg). (1) EIN Container im BATS_IMAGE (--network none, Baum :ro) laesst
# bats-preprocess ueber jede test/*.bats laufen und schreibt die Extrakte mit einer
# Trennzeile je Datei auf stdout. (2) Der HOST teilt den Strom in Dateien unter dem
# gitignorierten .harness/state/bats-lint/ und haengt jedem Extrakt den FUSS an; kein
# Mount ist schreibbar (MR-049). (3) shellcheck im SHELLCHECK_IMAGE liest dieses
# Verzeichnis :ro. (4) Die Meldungen nennen test/<name>.bats statt des Extrakt-Pfads;
# die Zeilennummern sind die des Originals, weil bats-preprocess die @test-Zeile an Ort
# und Stelle ersetzt und der Fuss HINTER dem Extrakt steht.
#
# ABLAUF (Host-Weg, BATS_HOST=1): dieselben vier Schritte ohne Container —
# bats-preprocess laesst sich am Host als Teil der bats-Installation auflösen
# (relativ zur geloesten Fassung des bats-Binaers, Überschreibung BATS_HOST_PREPROCESS);
# der shellcheck-Aufruf kommt aus dem PATH. Die Grenze ist der Inventar-Grund
# beider Zeilen: Anwesenheit, keine Version-Zusage.
#
# GEGENSTAND DER ZWEI AUSNAHMEN. Beide gelten nur fuer den Extrakt aller test/*.bats und
# fuer keinen anderen Baum; der Aufruf von `make shell-lint` ueber .claude/hooks,
# harness/tools, internal/emit/templates, test/mutations und .githooks traegt weder Fuss
# noch --exclude und behaelt die volle Schwelle.
#   - SC2016 (`$` oder Backtick in Einzelquotes) ist per --exclude ausgenommen: im @test-Rumpf
#     stehen Einzelquotes mit `$` oder Backtick ueberwiegend gewollt — `bash -c '...$x...'`-
#     Payloads, grep-Muster, Heredoc-Texte, Zusicherungen gegen woertliche `$msgfile` und
#     gegen Markdown-Backticks. Am Extrakt gemessen: 60 Treffer in 16 Dateien. GRENZE: ein
#     versehentlich in Einzelquotes stehendes `$var` oder ein Backtick in einem bats-Rumpf
#     wird nicht gemeldet.
#   - SC2154 (nicht zugewiesene Variable) ist ueber den FUSS erledigt: `status`, `output`
#     und `lines` bindet `run`, shellcheck kennt das DSL nicht; der Fuss deklariert genau
#     diese drei Namen in jedem der Extrakte. GRENZE: eine Verwendung dieser drei Namen
#     OHNE vorangehendes `run` wird nicht gemeldet, auch in Hilfsfunktionen ausserhalb
#     jedes @test. Der `:`-Teil verhindert SC2034 (unbenutzte Zuweisung) in Dateien ohne
#     `run`.
# Es gibt weder eine .shellcheckrc noch ein Inline-`shellcheck disable` (AGENTS.md 3.2).
#
# SENSOREN UND LUECKEN. Der Fuss und --exclude=SC2016 sind je ein Fall in test/mutations/
# (ohne Fuss faerbt SC2154, ohne `:`-Teil SC2034, ohne --exclude SC2016 `make shell-lint`).
# Dass die Begrenzung auf den bats-Aufruf `harness/tools` und `test/mutations` die volle
# Schwelle laesst, laesst sich nicht rot faerben, solange kein Rumpf dort ein `$` in
# Einzelquotes traegt; sie haelt allein die Trennung der beiden shellcheck-Aufrufe. Kein
# Waechter liest diesen Kommentar gegen die Flags (akzeptiertes Negativ, Reviewer liest ihn).
# KEIN bats-Test und kein Mutations-Fall deckt dieses Skript selbst: bats laeuft im Image
# ohne docker, und ein Fall muesste eine Mutation rot faerben, waehrend die Fehler-
# auswertung (bats-preprocess scheitert an einer Datei -> Exit 2, Datei im Text) einen
# Lauf gruen lassen soll. Von Hand gesehen: ein Symlink ins Leere test/{a,m,z}-dangling.bats
# faerbt den Lauf in jeder Reihenfolge rot; der Container beendet die Schleife erst nach
# der letzten Datei und meldet jede gescheiterte.
set -euo pipefail

# Pins nur am Image-Weg: BATS_HOST=1 setzt die Anwesenheits-Auflage statt der
# Pins (Inventar-Zeilen bats/shellcheck) — ein fehlendes Werkzeug bricht laut.
if [ "${BATS_HOST:-}" = "1" ]; then
	BATS_IMAGE=
	SHELLCHECK_IMAGE=
else
	: "${BATS_IMAGE:?bats-lint: BATS_IMAGE fehlt (make shell-lint-image setzt ihn)}"
	: "${SHELLCHECK_IMAGE:?bats-lint: SHELLCHECK_IMAGE fehlt (make shell-lint-image setzt ihn)}"
fi

root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"

zustand=".harness/state/bats-lint"
marke='#bats-lint-datei:'
FUSS="status=0; output=; lines=(); : \"\$status\" \"\$output\" \"\${lines[@]}\""

shopt -s nullglob
dateien=(test/*.bats)
[ "${#dateien[@]}" -gt 0 ] || { echo "bats-lint: FEHLER — keine test/*.bats gefunden." >&2; exit 2; }

rm -rf "$zustand"
mkdir -p "$zustand"

# Schritt 1+2: Extrakt, Teilung auf dem Host — Transport je Weg: am Image-Weg
# per ENTRYPOINT-Aufruf im BATS_IMAGE, am Host-Weg per aufgeloester
# bats-preprocess-Fassung (kein docker, kein Netz; dasselbe printf-Muster).
extrahiere() {
	if [ -n "$BATS_IMAGE" ]; then
		docker run --rm --network none -v "$root":/code:ro -w /code \
			-e BATS_ROOT=/opt/bats -e BATS_LIBDIR=lib --entrypoint bash "$BATS_IMAGE" \
			-c 'rc=0; for f in "$@"; do printf "\n%s%s\n" "$0" "$f"; /opt/bats/libexec/bats-core/bats-preprocess "$f" || { echo "bats-lint: FEHLER — bats-preprocess scheitert an $f" >&2; rc=1; }; done; exit "$rc"' \
			"$marke" "${dateien[@]}"
	else
		preprocess="${BATS_HOST_PREPROCESS:-}"
		if [ -z "$preprocess" ]; then
			batsbin="$(command -v bats)" || { echo "bats-lint: bats fehlt am Host (Inventar-Zeile bats) — BATS_HOST_PREPROCESS setzt alternativ den bats-preprocess-Pfad." >&2; return 2; }
			preprocess="$(cd "$(dirname "$(readlink -f "$batsbin")")/.." && printf '%s/libexec/bats-core/bats-preprocess' "$PWD")"
		fi
		[ -x "$preprocess" ] || { echo "bats-lint: bats-preprocess nicht gefunden ($preprocess) — BATS_HOST_PREPROCESS setzt den Pfad." >&2; return 2; }
		rc=0
		for f in "${dateien[@]}"; do
			printf '\n%s%s\n' "$marke" "$f"
			"$preprocess" "$f" || { echo "bats-lint: FEHLER — bats-preprocess scheitert an $f" >&2; rc=1; }
		done
		return "$rc"
	fi
}

if ! extrahiere |
	awk -v marke="$marke" -v dir="$zustand" -v fuss="$FUSS" '
		index($0, marke) == 1 {
			if (out != "") { print "\n" fuss > out; close(out) }
			n = split(substr($0, length(marke) + 1), teile, "/")
			out = dir "/" teile[n]
			printf "" > out
			next
		}
		out != "" { print > out }
		END { if (out != "") { print "\n" fuss > out; close(out) } }'; then
	echo "bats-lint: FEHLER — der Extrakt ist unvollstaendig (bats-preprocess oder docker gescheitert, Meldung oben)." >&2
	exit 2
fi

anzahl="$(find "$zustand" -type f | wc -l | tr -d ' ')"
if [ "$anzahl" -ne "${#dateien[@]}" ]; then
	echo "bats-lint: FEHLER — ${#dateien[@]} test/*.bats, aber $anzahl Extrakte." >&2
	exit 2
fi

# Schritt 3+4: shellcheck mit --exclude NUR hier, Meldungen auf test/<name>.bats.
rc=0
if [ -n "$SHELLCHECK_IMAGE" ]; then
	out="$(docker run --rm -v "$root":/mnt:ro -w /mnt "$SHELLCHECK_IMAGE" \
		--shell=bash --exclude=SC2016 --format=gcc "$zustand"/*.bats 2>&1)" || rc=$?
else
	command -v shellcheck >/dev/null 2>&1 || { echo "bats-lint: shellcheck fehlt am Host (Inventar-Zeile shellcheck)." >&2; exit 2; }
	out="$(shellcheck --shell=bash --exclude=SC2016 --format=gcc "$zustand"/*.bats 2>&1)" || rc=$?
fi
if [ -n "$out" ]; then
	printf '%s\n' "$out" | sed "s#^$zustand/#test/#"
fi
if [ "$rc" -ne 0 ]; then
	echo "bats-lint: FEHLER — shellcheck ueber $anzahl test/*.bats meldet Befunde (Exit $rc)." >&2
	exit "$rc"
fi
echo "bats-lint: OK — $anzahl test/*.bats"
