#!/usr/bin/env bash
# release-sums.sh — erzeugt und haelt die SHA256SUMS eines Release-Schnitts
# (ADR-0059 Folgepflicht 1). Zwei Modi, ein Mechanik-Ort:
#
#   generate <dir>  schreibt <dir>/SHA256SUMS neben die Binaries — eine Zeile je
#                   Asset, Format <sha256>␣␣<name> (sha256sum). Das Rezept
#                   `make release-artifacts` ruft sie nach dem Bau; die SUMS reist
#                   damit im selben DEST wie die Assets, die sie beschreibt.
#   verify <dir>    haelt die Dateien in <dir> gegen das reisende Manifest,
#                   fail-closed: fehlt die SUMS, fehlt ein Eintrag, oder weicht
#                   eine Datei ab, bricht der Lauf — dieselbe Disziplin wie die
#                   Verifizierung vor der Ablage im Fetch (ADR-0059 Festlegung 1),
#                   hier auf der Publikations-Seite.
#
# KEIN GATE: das Skript prueft nichts am Baum, haengt an keiner gates-Kette und
# steht in keiner Prerequisite-Kette. Es braucht nichts ausser coreutils; der
# Aufruf im publish-Job ist der eine, der die reisende SUMS gegen die
# heruntergeladenen Artefakte haelt, BEVOR etwas hochgeladen wird.
#
# AUFRUFE: das Rezept release-artifacts (generate) und der publish-Job der
# Release-Workflow (verify) — test/release-matrix.bats haelt beide Stellen.
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
	# Jede gelistete Datei muss da sein — sha256sum -c bricht an fehlenden und an
	# abweichenden; die Liste selbst wird vorher gegen Leereintraege gehalten.
	if ! grep -qE '^[0-9a-f]{64}  [^ ].*$' "$sums"; then
		echo "release-sums: $sums traegt keine gueltige Zeile (<sha256>  <name>) — ein leeres oder fremdes Manifest wird nicht publiziert." >&2
		exit 1
	fi
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