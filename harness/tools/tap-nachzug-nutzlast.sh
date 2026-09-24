#!/bin/sh
# tap-nachzug-nutzlast.sh — die POSIX-sh-Nutzlast von harness/tools/tap-nachzug.sh.
# Sie laeuft im digest-gepinnten Transport-Bild (ADR-0064 Festlegung 5, ADR-0058
# Festlegung 4), nie auf dem Host, und ruft nur Programme des Bild-Bestands: curl,
# cmp, sha256sum, awk, mktemp, sleep, rm und Shell-Builtins. Ein jq, bash, git oder gh
# gibt es dort nicht.
#
# EINGABE (Umgebung, vom Host-Skript gesetzt): TAP_MODE, TAP_TAG, TAP_ASSET_URL,
# TAP_URL, TAP_WAIT; optional TAP_TOKEN.
#
# ZUSAGE (ADR-0064 Festlegung 2), pro Exit-Status der Nutzlast; das Host-Skript bildet 0 auf
# seinen Exit 0, 10 auf seinen Exit 1 und jeden anderen Status auf seinen Exit 2 ab:
#   0  die Formel am Tap-Kopf hat dieselben Bytes wie das Asset des Tags
#   10 Formel-Unterschied, auch nach dem zweiten Lesen nach TAP_WAIT Sekunden — und nur
#      dieser Fall: ein Kommando, das scheitert (mktemp, Schreiben der Kopfdatei, cmp mit
#      Status 2), endet als Exit 2 mit der Meldung des internen Fehlers. Der Status 10 ist
#      der Unterschied und sonst nichts: der Status von docker selbst (1, 125 bis 127) ist
#      es nicht.
#   2  nicht ausfuehrbar: Asset oder Tap nicht lesbar, interner Fehler — nie als
#      Unterschied gemeldet
# Der Status 10 ist ein privates Protokoll zwischen dieser Datei und dem Host-Skript, das seine
# Herkunft nicht prueft. Ein docker-Aufruf, der selbst mit 10 endet (ein Stub, ein Wrapper), wird
# dort als Formel-Unterschied gemeldet — mit Exit 1, ohne die Digests und die abweichende Zeile
# dieser Datei, allein mit der Exit-Zeile des Host-Skripts.
# Der Vergleich ist byte-genau ueber Dateien (cmp), nicht ueber Shell-Variablen: eine
# Variable verliert den Endzeilenumbruch.
#
# TOKEN (ADR-0064 Festlegung 4): nie in einer Kommandozeile, nie in der Ausgabe. Das
# Builtin printf schreibt den Header in eine Datei mit Modus 0600, curl bekommt sie als
# `-H @<Datei>`; sie wird beim Verlassen der Nutzlast entfernt. Es gibt kein `set -x`,
# und keine Meldung gibt eine Antwort der Schnittstelle aus. Belegt in
# test/tap-nachzug.bats.
set -eu
umask 077
LC_ALL=C
export LC_ALL

# beende <rc> raeumt auf und legt die Exit-Klasse fest; fehler() und der EXIT-Trap (mit dem
# Status des Endes) rufen es. 10 gilt nur, wenn der Vergleich es gesetzt hat (unterschied=ja);
# jedes andere Ende ausserhalb von 0 und 2 — auch ein Kommando, das mit 1 scheitert — ist ein
# interner Fehler und wird Exit 2.
work=""
unterschied=nein
beende() {
	rc="$1"
	trap - EXIT
	if [ -n "$work" ]; then rm -rf "$work" || :; fi
	case "$rc" in
	0 | 2) ;;
	10)
		if [ "$unterschied" != ja ]; then
			printf 'tap-%s: interner Fehler der Nutzlast (ein Kommando endete mit 10) — es wurde nichts verglichen\n' "${TAP_MODE:-nachzug}" >&2
			rc=2
		fi
		;;
	*)
		printf 'tap-%s: interner Fehler der Nutzlast (Exit %s) — es wurde nichts verglichen\n' "${TAP_MODE:-nachzug}" "$rc" >&2
		rc=2
		;;
	esac
	exit "$rc"
}
trap 'beende "$?"' EXIT
trap 'exit 2' HUP INT TERM
work="$(mktemp -d)"

hdr=""
if [ -n "${TAP_TOKEN:-}" ]; then
	hdr="$work/kopf"
	printf 'Authorization: Bearer %s\n' "$TAP_TOKEN" >"$hdr"
fi
unset TAP_TOKEN

fehler() {
	printf 'tap-%s: %s\n' "$TAP_MODE" "$1" >&2
	beende 2
}

# hole_asset legt das Asset des Tags nach $work/asset.
hole_asset() {
	code="$(curl -sS -L --max-time 60 -o "$work/asset" -w '%{http_code}' "$TAP_ASSET_URL")" || code=000
	if [ "$code" != 200 ]; then
		fehler "Asset nicht auffindbar: ai-harness-init.rb des Tags $TAP_TAG (HTTP $code) — es wurde nichts verglichen"
	fi
}

# lese_tap legt die Formel am Kopf des Default-Branch des Tap nach $work/tap; jeder
# andere Ausgang als eine gelesene Datei endet mit Exit 2 und gibt nur den Statuscode aus.
lese_tap() {
	set -- -sS --max-time 30 -o "$work/tap" -w '%{http_code}' -H 'Accept: application/vnd.github.raw'
	if [ -n "$hdr" ]; then
		set -- "$@" -H "@$hdr"
	fi
	code="$(curl "$@" "$TAP_URL")" || code=000
	case "$code" in
	200) ;;
	404) fehler "Tap nicht lesbar: keine Formel-Datei am Kopf des Default-Branch (HTTP 404) — es wurde nichts verglichen" ;;
	401 | 403 | 429) fehler "Tap nicht lesbar: die Schnittstelle lehnt das Lesen ab (HTTP $code: Anmeldung oder Lese-Limit) — es wurde nichts verglichen" ;;
	*) fehler "Tap nicht lesbar (HTTP $code) — es wurde nichts verglichen" ;;
	esac
}

# gleich: Status 0 gleich, 1 verschieden; cmp mit einem anderen Status als 0 und 1 (es konnte
# nicht lesen) ist ein interner Fehler und endet mit Exit 2, nie als Unterschied.
gleich() {
	cmp_rc=0
	cmp -s "$work/asset" "$work/tap" || cmp_rc=$?
	case "$cmp_rc" in
	0) return 0 ;;
	1) return 1 ;;
	*) fehler "der Vergleich lief nicht (cmp Exit $cmp_rc) — es wurde nichts verglichen" ;;
	esac
}

# vergleiche: 0 gleich, 1 ungleich auch nach dem zweiten Lesen. Gleich schon im ersten
# Lesen endet ohne Wartezeit; eine Ungleichheit wird einmal nach TAP_WAIT Sekunden
# erneut gelesen (Cache-Fenster der Schnittstelle, ADR-0064 Festlegung 2). Die Einheit
# liegt hier einmal.
vergleiche() {
	lese_tap
	if gleich; then
		return 0
	fi
	sleep "$TAP_WAIT"
	lese_tap
	if gleich; then
		return 0
	fi
	return 1
}

digest() {
	d="$(sha256sum "$1")"
	printf '%s' "${d%% *}"
}

# erste_abweichung nennt die erste Zeile, in der Asset und Tap-Stand des zweiten Lesens
# verschieden sind.
erste_abweichung() {
	awk '
		FILENAME == ARGV[1] { a[FNR] = $0; na = FNR; next }
		{ b[FNR] = $0; nb = FNR }
		END {
			n = (na > nb) ? na : nb
			for (i = 1; i <= n; i++) {
				if (!(i in a) || !(i in b) || a[i] != b[i]) {
					printf "Zeile %d: Asset [%s] | Tap [%s]\n", i, (i in a) ? a[i] : "(fehlt)", (i in b) ? b[i] : "(fehlt)"
					exit
				}
			}
			print "alle Zeilen gleich, der Unterschied liegt im Ende der Datei (Endzeilenumbruch)"
		}
	' "$1" "$2"
}

hole_asset
if vergleiche; then
	printf 'tap-%s: gleich — Tag %s, Tap-Kopf Formula/ai-harness-init.rb, sha256 %s\n' "$TAP_MODE" "$TAP_TAG" "$(digest "$work/asset")"
	exit 0
fi
printf 'tap-%s: Formel-Unterschied — Tag %s, Asset sha256 %s, Tap-Kopf sha256 %s; erste abweichende Zeile (zweites Lesen) %s\n' \
	"$TAP_MODE" "$TAP_TAG" "$(digest "$work/asset")" "$(digest "$work/tap")" "$(erste_abweichung "$work/asset" "$work/tap")" >&2
unterschied=ja
exit 10
