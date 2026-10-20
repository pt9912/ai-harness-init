#!/usr/bin/env bash
# traeger-pins-check.sh — haelt die sechs TRAEGER_SHA256_*-Pins des Makefile gegen die
# SHA256SUMS des veroeffentlichten Releases (LH-QA-02, ADR-0058, ADR-0059).
# EIN KOMMANDO, KEIN GATE: es braucht Netz an genau diesem Aufruf und eine Release-Lage,
# die ein frischer Klon nicht garantiert; es steht in keiner gates-Kette. Bindepunkt ist
# die Prozedur in docs/user/releasing.md (nach Schritt 5).
#
# WAS ES HAELT: Pin gegen Publikation. Je Plattform der Matrix wird der Eintrag der
# SHA256SUMS mit dem Dateinamen des Assets gesucht (Paarung nach Name, nie nach Position)
# und sein Digest gegen den Pin dieser Plattform gehalten. Alle sechs werden verglichen,
# bevor das Ergebnis feststeht; die Meldung nennt jede abweichende Plattform.
# WAS ES NICHT HAELT: den Bau selbst (kein Bau gegen Bau) und die Assets (ihre Menge gegen
# die Pruefsummen haelt release-sums.sh verify in Schritt 3 der Prozedur). Die Pins kommen
# aus der Umgebung, die make aus dem Makefile exportiert; der Wert des Makefile reist
# damit unveraendert, und test/traeger-pins-check.bats haelt allein die Paarungs-Logik
# ueber einer nachgebauten SHA256SUMS, nicht den realen Pin.
#
# EXIT DES SKRIPTS: 0 gleich, 1 mindestens ein Pin weicht vom Eintrag ab, 2 nicht
# ausfuehrbar (Tag fehlt oder falsche Form, ein Pin fehlt, Bild nicht digest-gepinnt,
# SHA256SUMS nicht abrufbar oder leer, ein Eintrag fehlt, docker ohne Ergebnis). Bei Exit
# 1 und 2 ist die letzte stderr-Zeile des Skripts `traeger-pins-check: Exit <N>`; bei
# Exit 0 fehlt sie. Ueber `make traeger-pins-check` endet jeder Fehlschlag mit Exit 2 und
# GNU Make schreibt danach seine eigene Meldung (`Fehler <n>`); die Klasse des Skripts
# traegt allein diese Zeile. Nicht zugesagt ist sie bei einem Signal und bei nicht
# beschreibbarer stderr.
#
# TAG: Umgebungsvariable TAG (make exportiert Kommandozeilen-Variablen), sonst
# TRAEGER_TAG. Er wird nur gegen die Tag-Form geprueft und als -e-Wert durchgereicht.
#
# TRANSPORT IM GEPINNTEN BILD (AGENTS.md 3.9): dasselbe Bild wie harness/tools/traeger-fetch.sh;
# sein Pin wird dort gelesen, nicht hier ein zweites Mal gefuehrt. Findet der Lauf die
# Zeile nicht, endet er mit Exit 2. TRAEGER_IMAGE ueberschreibt den gelesenen Wert.
set -euo pipefail
export LC_ALL=C

hier="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fetch_skript="$hier/traeger-fetch.sh"

# melde <text> schreibt eine Zeile auf stderr; ein Schreibfehler aendert den Exit nicht.
melde() {
	printf '%s\n' "$1" >&2 || :
}

# beende <rc> schreibt die Exit-Zeile (nicht bei 0) und beendet mit der Klasse. Ein
# unerwarteter Status (set -e) wird Klasse 2.
beende() {
	local rc="$1"
	trap - EXIT
	case "$rc" in
	0 | 1 | 2) ;;
	*)
		melde "traeger-pins-check: interner Fehler des Skripts (Exit $rc) — es wurde nichts verglichen"
		rc=2
		;;
	esac
	if [ "$rc" -ne 0 ]; then
		melde "traeger-pins-check: Exit $rc"
	fi
	exit "$rc"
}
trap 'beende "$?"' EXIT

fehler() {
	melde "traeger-pins-check: $1"
	beende 2
}

bild="${TRAEGER_IMAGE:-}"
if [ -z "$bild" ]; then
	zeile="$(grep -m1 '^TRAEGER_IMAGE="' "$fetch_skript" 2>/dev/null || true)"
	bild="${zeile#*:-}"
	bild="${bild%\}\"}"
fi
case "$bild" in
*@sha256:*) ;;
*) fehler "kein digest-gepinntes Transport-Bild (gelesen aus $fetch_skript: '${bild}') — der Transport laeuft im gepinnten Bild." ;;
esac

tag="${TAG:-${TRAEGER_TAG:-}}"
if [ -z "$tag" ]; then
	fehler "weder TAG noch TRAEGER_TAG ist gesetzt — Aufruf: make traeger-pins-check [TAG=<tag>]"
fi
tag_form='^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'
if ! [[ "$tag" =~ $tag_form ]]; then
	fehler "Tag-Form falsch: $(printf '%q' "$tag") — erwartet v<K>.<K>.<K>, optional -<Vorab> und +<Build> aus [0-9A-Za-z.-]"
fi

plattformen=(LINUX_AMD64 LINUX_ARM64 DARWIN_AMD64 DARWIN_ARM64 WINDOWS_AMD64 WINDOWS_ARM64)

# Jeder Pin muss gesetzt sein: ein fehlender Pin hielte nichts und liesse die Plattform
# unbeobachtet.
for p in "${plattformen[@]}"; do
	name="TRAEGER_SHA256_$p"
	if [ -z "${!name:-}" ]; then
		fehler "$name ist nicht gesetzt — der Pin der Plattform fehlt (make exportiert ihn aus dem Makefile); es wurde nichts verglichen"
	fi
done

sums_url="https://github.com/pt9912/ai-harness-init/releases/download/${tag}/SHA256SUMS"

# Der Transport holt nur die Bytes der SHA256SUMS auf stdout; Paaren und Vergleichen
# laufen auf dem Host. Jeder Status ausser 0 ist ein nicht ausfuehrbarer Lauf, nie ein
# Unterschied.
rc=0
sums="$(docker run --rm \
	-e PINS_SUMS_URL="$sums_url" \
	"$bild" sh -c 'curl -fsSL "$PINS_SUMS_URL"')" || rc=$?
if [ "$rc" -ne 0 ]; then
	fehler "SHA256SUMS von $sums_url nicht abrufbar (docker Exit $rc) — es wurde nichts verglichen"
fi
if [ -z "$sums" ]; then
	fehler "SHA256SUMS von $sums_url ist leer — es wurde nichts verglichen"
fi

abweichend=0
for p in "${plattformen[@]}"; do
	os="$(printf '%s' "${p%_*}" | tr '[:upper:]' '[:lower:]')"
	arch="$(printf '%s' "${p#*_}" | tr '[:upper:]' '[:lower:]')"
	asset="ai-harness-init-${os}-${arch}"
	if [ "$os" = windows ]; then asset="${asset}.exe"; fi
	# Paarung nach Name: genau eine Zeile `<digest>  <asset>`; kein Treffer oder mehrere
	# Treffer sind ein nicht ausfuehrbarer Lauf.
	treffer="$(printf '%s\n' "$sums" | awk -v a="$asset" '$2 == a { print $1 }')"
	anzahl="$(printf '%s' "$treffer" | grep -c . || true)"
	if [ "$anzahl" -eq 0 ]; then
		fehler "$asset fehlt in den SHA256SUMS von $tag — der Eintrag der Plattform $p fehlt; es wurde nichts verglichen"
	fi
	if [ "$anzahl" -gt 1 ]; then
		fehler "$asset steht mehrfach in den SHA256SUMS von $tag — die Paarung ist nicht eindeutig; es wurde nichts verglichen"
	fi
	name="TRAEGER_SHA256_$p"
	pin="${!name}"
	if [ "$treffer" != "$pin" ]; then
		melde "traeger-pins-check: $name weicht ab — Pin $pin, SHA256SUMS von $tag fuehrt $treffer fuer $asset"
		abweichend=$((abweichend + 1))
	fi
done

if [ "$abweichend" -gt 0 ]; then
	melde "traeger-pins-check: Unterschied bei $abweichend von ${#plattformen[@]} Plattformen"
	beende 1
fi
printf 'traeger-pins-check: gleich — alle %s Pins halten gegen die SHA256SUMS von %s.\n' "${#plattformen[@]}" "$tag"
