#!/usr/bin/env bash
# release-sums.sh — erzeugt und haelt die SHA256SUMS eines Release-Schnitts
# (ADR-0059 Folgepflicht 1). Zwei Modi, ein Mechanik-Ort:
#
#   generate <dir>  schreibt <dir>/SHA256SUMS neben die Binaries — eine Zeile je
#                   Asset, Format <sha256>␣␣<name> (sha256sum). Das Rezept
#                   `make release-artifacts` ruft sie nach dem Bau; die SUMS reist
#                   damit im selben DEST wie die Assets, die sie beschreibt.
#   verify <dir>    haelt die Dateien in <dir> gegen das reisende Manifest,
#                   fail-closed: fehlt die SUMS, weicht eine Zeile in ihrer Form
#                   ab, ist die Menge der Eintraege nicht die Menge der Assets,
#                   oder weicht eine Datei ab, bricht der Lauf — dieselbe
#                   Disziplin wie die Verifizierung vor der Ablage im Fetch
#                   (ADR-0059 Festlegung 1), hier auf der Publikations-Seite.
#
# KEIN GATE: das Skript prueft nichts am Baum, haengt an keiner gates-Kette und
# steht in keiner Prerequisite-Kette. Es braucht nichts ausser coreutils.
#
# GRENZE, benannt statt verschwiegen: GNU sha256sum haelt eine improper Zeile ohne
# --strict als Warnung durch (Exit 0), und --strict ist in der BusyBox-Fassung des
# bats-Bilds nicht vorhanden — die Zeilen-FORM haelt darum dieser Lauf selbst (je
# Zeile), nicht der -c-Lauf. Der -c-Lauf traegt den INHALT: fehlende Dateien und
# abweichende Digests brechen in beiden coreutils-Fassungen.
#
# AUFRUFE: das Rezept release-artifacts (generate) und der manuelle Schnitt vor
# seinem gh release create (verify). Der publish-Job der Release-Workflow fuehrt
# die Haltung NICHT ueber diesen Ort — er checkt bewusst nicht aus, das Skript
# liegt ihm also nicht vor; dort laeuft dieselbe Pruefung als eine Zeile coreutils
# am Ruheort der SUMS (cd dist && sha256sum -c SHA256SUMS). Beide Stellen haelt
# test/release-matrix.bats.
set -euo pipefail

modus="${1:-}"
dir="${2:-}"
[ -n "$modus" ] && [ -n "$dir" ] || {
	echo "release-sums: Aufruf: release-sums.sh <generate|verify> <dir>" >&2
	exit 2
}
[ -d "$dir" ] || {
	echo "release-sums: $dir existiert nicht — ohne Asset-Verzeichnis gibt es nichts zu ${modus}n." >&2
	exit 2
}

case "$modus" in
generate)
	# Genau die Binaries der Matrix werden gehasht — eine bereits liegende SUMS
	# bleibt außen vor (ein Re-Lauf ist konvergent, nicht kumulativ).
	shopt -s nullglob
	binaries=("$dir"/ai-harness-init-*)
	shopt -u nullglob
	[ "${#binaries[@]}" -gt 0 ] || {
		echo "release-sums: keine Binaries (ai-harness-init-*) in $dir — die SUMS beschreibt nichts." >&2
		exit 2
	}
	for f in "${binaries[@]}"; do
		[ -f "$f" ] || {
			echo "release-sums: $f ist keine Datei — die Matrix traegt nur Dateien (LH-QA-04)." >&2
			exit 2
		}
	done
	# sha256sum sortiert ueber den Glob alphabetisch — die Zeilenfolge ist damit
	# deterministisch und ein Re-Lauf byte-identisch.
	(
		cd "$dir"
		sha256sum ai-harness-init-* >.SHA256SUMS.tmp
		mv .SHA256SUMS.tmp SHA256SUMS
	)
	echo "release-sums: SHA256SUMS geschrieben (${#binaries[@]} Assets in $dir)."
	;;
verify)
	sums="$dir/SHA256SUMS"
	[ -f "$sums" ] || {
		echo "release-sums: $sums fehlt — der Schnitt haette die SUMS neben die Binaries gelegt (ADR-0059 Folgepflicht 1); ohne sie wird nichts publiziert." >&2
		exit 1
	}
	# Zeilen-FORM, je Zeile (siehe GRENZE im Kopf): eine improper Zeile ist ein Bruch,
	# keine Warnung.
	formfehler="$(grep -cvE '^[0-9a-f]{64}  [^ ].*$' "$sums" || true)"
	if [ "$formfehler" -ne 0 ]; then
		echo "release-sums: $sums traegt $formfehler Zeile(n) ausserhalb der Form <sha256>  <name> — ein improper Manifest wird nicht publiziert." >&2
		exit 1
	fi
	# VOLLSTAENDIGKEIT in beide Richtungen: die Asset-Menge im Verzeichnis und die
	# Menge der Manifest-Eintraege muessen identisch sein — ein Asset ohne Zeile und
	# eine Zeile ohne Asset sind derselbe Defekt (ADR-0059 Festlegung 1: eine Zeile
	# je Asset).
	shopt -s nullglob
	asset_dateien=("$dir"/ai-harness-init-*)
	shopt -u nullglob
	assets="$(printf '%s\n' "${asset_dateien[@]##*/}" | sort)"
	eintraege="$(awk '{print $2}' "$sums" | sort)"
	if [ "$assets" != "$eintraege" ]; then
		echo "release-sums: die Menge der Eintraege in $sums ist nicht die Menge der Assets in $dir — ein Asset ohne Zeile oder eine Zeile ohne Asset; es wird nichts publiziert." >&2
		printf '%s\n' "  Assets: $assets" >&2
		printf '%s\n' "  Eintraege: $eintraege" >&2
		exit 1
	fi
	# Der -c-Lauf traegt den INHALT: abweichende Digests brechen in beiden
	# coreutils-Fassungen.
	(
		cd "$dir"
		sha256sum -c SHA256SUMS
	)
	echo "release-sums: OK — die Artefakte in $dir halten gegen die reisende SHA256SUMS."
	;;
*)
	echo "release-sums: unbekannter Modus $modus — generate oder verify." >&2
	exit 2
	;;
esac