#!/bin/sh
# tap-nachzug-nutzlast.sh — die POSIX-sh-Nutzlast von harness/tools/tap-nachzug.sh.
# Sie laeuft im digest-gepinnten Transport-Bild (ADR-0064 Festlegung 5, ADR-0058
# Festlegung 4), nie auf dem Host, und ruft nur Programme des Bild-Bestands: curl,
# base64 (mit -w), cmp, sha256sum, sha1sum, sed, awk, wc, grep, cat, mktemp, sleep, rm und
# Shell-Builtins. Ein jq, bash, git oder gh gibt es dort nicht.
#
# EINGABE (Umgebung, vom Host-Skript gesetzt): TAP_MODE (check oder sync), TAP_TAG,
# TAP_ASSET_URL, TAP_URL, TAP_WAIT; TAP_TOKEN im Modus sync (im Modus check optional).
#
# ZUSAGE (ADR-0064 Festlegung 2 und 3), pro Exit-Status der Nutzlast; das Host-Skript bildet 0 auf
# seinen Exit 0, 10 auf seinen Exit 1 und jeden anderen Status auf seinen Exit 2 ab:
#   0  check: die Formel am Tap-Kopf hat dieselben Bytes wie das Asset des Tags.
#      sync: dasselbe schon beim ersten Lesen (es wird nichts geschrieben), oder die Formel
#      wurde geschrieben und die Nachkontrolle hat gleiche Bytes gelesen.
#   10 Formel-Unterschied, auch nach dem zweiten Lesen nach TAP_WAIT Sekunden (in sync: das
#      Ergebnis der Nachkontrolle nach dem Schreiben) — und nur dieser Fall: ein Kommando,
#      das scheitert (mktemp, Schreiben der Kopfdatei, cmp mit Status 2), endet als Exit 2
#      mit der Meldung des internen Fehlers. Der Status 10 ist der Unterschied und sonst
#      nichts: der Status von docker selbst (1, 125 bis 127) ist es nicht.
#   2  nicht ausfuehrbar: Asset oder Tap nicht lesbar, interner Fehler, und nur in sync: die
#      version-Zeile der Tap-Formel fehlt, steht mehrfach oder genuegt der Feldform nicht, der
#      Tag ist aelter als der Tap-Stand (Vorwaerts-Schutz), das Schreiben ist ausdruecklich
#      abgelehnt (HTTP 401, 403, 409: Meldung "Tap unveraendert") oder sein Ausgang ist
#      ungewiss (keine Antwort, jeder andere Status: Meldung "Ausgang ungewiss"), oder das Tap
#      ist nach einem erfolgten Schreiben (HTTP 200) fuer die Nachkontrolle nicht lesbar
#      (Meldung "das Schreiben ist bereits erfolgt", Ergebnis offen) — nie als Unterschied
#      gemeldet
# Der Status 10 ist ein privates Protokoll zwischen dieser Datei und dem Host-Skript, das seine
# Herkunft nicht prueft. Ein docker-Aufruf, der selbst mit 10 endet (ein Stub, ein Wrapper), wird
# dort als Formel-Unterschied gemeldet — mit Exit 1, ohne die Digests und die abweichende Zeile
# dieser Datei, allein mit der Exit-Zeile des Host-Skripts.
# Der Vergleich ist byte-genau ueber Dateien (cmp), nicht ueber Shell-Variablen: eine
# Variable verliert den Endzeilenumbruch.
#
# SYNC (ADR-0064 Festlegung 3, Schritte d bis g): Tap lesen (genau einmal, keine Wiederholung
# bis zum Schreiben), Feldform der version-Zeile und Vorwaerts-Schutz (numerisch je Feld,
# Gleichstand laeuft weiter), Vergleich (gleich: kein Schreibaufruf), Schreiben ueber die
# Contents-API mit den Bytes des Assets, optimistisch gegen den Blob-Stand der gelesenen Bytes
# (SHA-1 ueber `blob <Laenge>\0<Bytes>`), genau ein Versuch, dann die Nachkontrolle mit der
# Wiederholung des Lesens. Eine Antwort der Schnittstelle gibt sie nie aus, nur den Statuscode.
#
# TOKEN (ADR-0064 Festlegung 4): nie in einer Kommandozeile, nie in der Ausgabe. Das
# Builtin printf schreibt den Header in eine Datei mit Modus 0600, curl bekommt sie als
# `-H @<Datei>`; sie wird beim Verlassen der Nutzlast entfernt, ebenso die Antwort- und die
# Body-Datei des Schreibens. Es gibt kein `set -x`, und keine Meldung gibt eine Antwort der
# Schnittstelle aus. Belegt in test/tap-nachzug.bats.
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
geschrieben=nein
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

# nicht_lesbar <ursache> endet mit Exit 2. Vor dem Schreiben sagt die Meldung, dass nichts
# verglichen wurde; nach dem Schreiben (geschrieben=ja, die Nachkontrolle) sagt sie, dass das
# Schreiben bereits erfolgt ist und ob das Tap die Bytes des Assets traegt, unbekannt bleibt.
nicht_lesbar() {
	if [ "$geschrieben" = ja ]; then
		fehler "$1 — das Schreiben ist bereits erfolgt (HTTP 200), nur die Nachkontrolle konnte nicht lesen; ob das Tap die Bytes des Assets trägt, ist unbekannt — Ergebnis mit make tap-check TAG=$TAP_TAG prüfen"
	fi
	fehler "$1 — es wurde nichts verglichen"
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
	404) nicht_lesbar "Tap nicht lesbar: keine Formel-Datei am Kopf des Default-Branch (HTTP 404)" ;;
	401 | 403 | 429) nicht_lesbar "Tap nicht lesbar: die Schnittstelle lehnt das Lesen ab (HTTP $code: Anmeldung oder Lese-Limit)" ;;
	*) nicht_lesbar "Tap nicht lesbar (HTTP $code)" ;;
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

# melde_unterschied schreibt die Meldung des Formel-Unterschieds (Exit-Klasse 1 des Skripts).
melde_unterschied() {
	printf 'tap-%s: Formel-Unterschied%s — Tag %s, Asset sha256 %s, Tap-Kopf sha256 %s; erste abweichende Zeile (zweites Lesen) %s\n' \
		"$TAP_MODE" "$1" "$TAP_TAG" "$(digest "$work/asset")" "$(digest "$work/tap")" "$(erste_abweichung "$work/asset" "$work/tap")" >&2
}

# lies_tap_stand setzt t1 t2 t3 aus der version-Zeile der gelesenen Formel (Schritt d): genau
# eine Zeile `version "<K>.<K>.<K>"` (Einrueckung beliebig), jedes Feld 0 oder eine
# Ziffernfolge ohne fuehrende Null von hoechstens 9 Stellen. Jede andere Lage endet mit Exit 2
# und der Meldung der version-Zeile, nie mit einem stillen 0.0.0.
lies_tap_stand() {
	n="$(awk '/^[[:space:]]*version([[:space:]]|$)/ { n++ } END { print n + 0 }' "$work/tap")"
	case "$n" in
	0) fehler "die version-Zeile der Formel am Tap-Kopf fehlt — der Tap-Stand ist nicht lesbar, es wurde nichts geschrieben" ;;
	1) ;;
	*) fehler "die version-Zeile der Formel am Tap-Kopf kommt mehrfach vor ($n Zeilen) — der Tap-Stand ist nicht eindeutig, es wurde nichts geschrieben" ;;
	esac
	zeile="$(grep -E '^[[:space:]]*version([[:space:]]|$)' "$work/tap")"
	wert="$(printf '%s\n' "$zeile" | sed -n 's/^[[:space:]]*version "\([0-9.]*\)"[[:space:]]*$/\1/p')"
	feldform_fehler="die version-Zeile der Formel am Tap-Kopf genügt der Feldform nicht [$zeile] — erwartet version \"<K>.<K>.<K>\", jedes <K> ist 0 oder eine Ziffernfolge ohne führende Null von höchstens 9 Stellen; es wurde nichts geschrieben"
	if [ -z "$wert" ] || [ "$(printf '%s\n' "$wert" | awk -F. '{ print NF }')" -ne 3 ]; then
		fehler "$feldform_fehler"
	fi
	t1="$(printf '%s\n' "$wert" | awk -F. '{ print $1 }')"
	t2="$(printf '%s\n' "$wert" | awk -F. '{ print $2 }')"
	t3="$(printf '%s\n' "$wert" | awk -F. '{ print $3 }')"
	for f in "$t1" "$t2" "$t3"; do
		printf '%s\n' "$f" | grep -Eqx '0|[1-9][0-9]{0,8}' || fehler "$feldform_fehler"
	done
}

# tag_kleiner: 0, wenn der Kern des Tags (v<K>.<K>.<K>, Vorab- und Build-Feld abgeschnitten)
# numerisch je Feld kleiner ist als der Tap-Stand t1.t2.t3; Gleichstand ist nicht kleiner.
# Die Felder des Tags hat das Host-Skript auf die Feldform geprueft.
tag_kleiner() {
	kern="${TAP_TAG#v}"
	kern="${kern%%[-+]*}"
	k1="${kern%%.*}"
	rest="${kern#*.}"
	k2="${rest%%.*}"
	k3="${rest#*.}"
	[ $((k1)) -lt $((t1)) ] && return 0
	[ $((k1)) -gt $((t1)) ] && return 1
	[ $((k2)) -lt $((t2)) ] && return 0
	[ $((k2)) -gt $((t2)) ] && return 1
	[ $((k3)) -lt $((t3)) ]
}

# schreibe legt die Bytes des Assets ueber die Contents-API in das Tap: ein Versuch,
# optimistisch gegen den Blob-Stand der gelesenen Bytes (Schritt f). Ausdruecklich abgelehnt
# (401, 403, 409) endet mit Exit 2 und "Tap unveraendert"; jede andere Antwort und keine
# Antwort enden mit Exit 2 und "Ausgang ungewiss" — die Nachkontrolle des Aufrufers
# (make tap-check) entscheidet. Nur HTTP 200 kehrt zurueck.
schreibe() {
	laenge="$(wc -c <"$work/tap" | awk '{ print $1 }')"
	blob="$({
		printf 'blob %s\0' "$laenge"
		cat "$work/tap"
	} | sha1sum)"
	blob="${blob%% *}"
	{
		printf '{"message":"Formel %s aus dem Asset ai-harness-init.rb des Tags %s nachgezogen","sha":"%s","content":"' "$TAP_TAG" "$TAP_TAG" "$blob"
		base64 -w 0 "$work/asset"
		printf '"}\n'
	} >"$work/body"
	code="$(curl -sS -X PUT --max-time 60 -o "$work/antwort" -w '%{http_code}' \
		-H "@$hdr" -H 'Accept: application/vnd.github+json' -H 'Content-Type: application/json' \
		--data-binary "@$work/body" "$TAP_URL")" || code=000
	case "$code" in
	200) return 0 ;;
	401) fehler "Schreiben abgelehnt (HTTP 401: Anmeldung) — Tap unverändert" ;;
	403) fehler "Schreiben abgelehnt (HTTP 403: Anmeldung oder Schutz des Branches) — Tap unverändert" ;;
	409) fehler "Schreiben abgelehnt (HTTP 409: Konflikt, das Tap hat sich seit dem Lesen geändert) — Tap unverändert" ;;
	000) fehler "Ausgang des Schreibens ungewiss: keine Antwort der Schnittstelle — Ergebnis mit make tap-check TAG=$TAP_TAG prüfen" ;;
	*) fehler "Ausgang des Schreibens ungewiss: unerwartete Antwort der Schnittstelle (HTTP $code) — Ergebnis mit make tap-check TAG=$TAP_TAG prüfen" ;;
	esac
}

# sync_lauf: Schritte d bis g (Kopfkommentar). Der Tap-Kopf wird bis zum Schreiben einmal gelesen.
sync_lauf() {
	if [ -z "$hdr" ]; then
		fehler "TAP_TOKEN ist nicht gesetzt — der Nachzug braucht das Zugangsgeheimnis (make tap-nachzug)"
	fi
	lese_tap
	lies_tap_stand
	if tag_kleiner; then
		fehler "Vorwärts-Schutz: der Tag $TAP_TAG ist älter als der Tap-Stand $t1.$t2.$t3 — es wurde nichts geschrieben"
	fi
	if gleich; then
		printf 'tap-%s: gleich — Tag %s, Tap-Kopf Formula/ai-harness-init.rb, sha256 %s; es wurde nichts geschrieben\n' "$TAP_MODE" "$TAP_TAG" "$(digest "$work/asset")"
		exit 0
	fi
	schreibe
	geschrieben=ja
	if vergleiche; then
		printf 'tap-%s: nachgezogen — Tag %s, Formula/ai-harness-init.rb geschrieben und nachkontrolliert, sha256 %s\n' "$TAP_MODE" "$TAP_TAG" "$(digest "$work/asset")"
		exit 0
	fi
	melde_unterschied " nach dem Schreiben"
	unterschied=ja
	exit 10
}

hole_asset
if [ "$TAP_MODE" = sync ]; then
	sync_lauf
fi
if vergleiche; then
	printf 'tap-%s: gleich — Tag %s, Tap-Kopf Formula/ai-harness-init.rb, sha256 %s\n' "$TAP_MODE" "$TAP_TAG" "$(digest "$work/asset")"
	exit 0
fi
melde_unterschied ""
unterschied=ja
exit 10
