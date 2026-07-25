#!/usr/bin/env bash
# start-smoke.sh — Plattform-Start-Smoke fuer ein Release-Binary (slice-048, LH-QA-04).
#
# Belegt: das Binary LAEUFT auf DIESER Plattform und meldet seine Usage. Mehr nicht —
# und genau das ist der Punkt. Ein Voll-Smoke (Bootstrap + `make gates` im Ziel) ist
# auf macOS/Windows nicht erreichbar: die macOS-Runner tragen kein Container-Runtime,
# die Windows-Runner nur Windows-Container. Die Messmethode im Lastenheft benennt
# diese Grenze; dieses Skript loest genau sie ein, nicht mehr.
#
# WARUM EIN SKRIPT UND KEIN make-TARGET: MR-014 Setzung 1 verlangt, dass ein Check nie
# in der Workflow-YAML definiert wird, sondern versioniert im Repo lebt — `make <target>`
# ist die Regelform dafuer, nicht der Zweck. `make` ist auf den Windows- und macOS-Runnern
# nicht installiert (an den Runner-Images-Readmes geprueft), ein `make start-smoke` waere
# dort nicht ausfuehrbar. Also ein Skript, und zwar auf ALLEN sechs Runnern dasselbe: ein
# Split „make auf Linux, Skript sonst" erzeugte genau die zwei Definitionen, die die
# Setzung verhindert. shell-lint deckt diese Datei.
#
# Aufruf: start-smoke.sh <pfad-zum-binary>
set -euo pipefail

bin="${1:?start-smoke: Pfad zum Binary ist Pflicht}"

# PFAD-FORM ERZWINGEN, bevor irgendetwas geprueft oder ausgefuehrt wird: `[ -f "$bin" ]`
# prueft eine DATEI, ein Aufruf ohne Slash macht aber einen PATH-Lookup. Bei einem
# gleichnamigen Kommando im PATH liefe das FREMDE Binary, und das Skript meldete OK,
# waehrend die uebergebene Datei nie gestartet wurde — ein stiller Nachweis ueber dem
# falschen Gegenstand (Review-Runde 3, F-3; hermetisch nachgestellt).
case "$bin" in
	*/*) ;;
	*) bin="./$bin" ;;
esac

[ -f "$bin" ] || { echo "start-smoke: FEHLER — $bin existiert nicht." >&2; exit 1; }
chmod +x "$bin" 2>/dev/null || true

# Die Ausgabe wird EINGEFANGEN, nicht durchgereicht: ein Exit != 0 faellt so sofort
# auf (set -e), und der Marker-Grep bekommt den vollstaendigen Text.
out="$("$bin" --help)"
printf '%s\n' "$out"

# Marker statt blossem Exit 0: ein Binary, das irgendetwas ausgibt und mit 0 endet,
# waere sonst „gruen" — das waere ein Nachweis ueber leerem Bereich (LH-QA-01).
# Geprueft werden der Werkzeugname und ein Kommando aus der Usage; beide stehen
# nur dort, wo die Usage wirklich gedruckt wurde. Here-String statt Pipe: unter
# pipefail schliesst `grep -q` die Pipe frueh, der Producer bekommt EPIPE und der
# Lauf faellt aus dem falschen Grund (die Klasse aus full-smoke.sh).
fehlt=""
for marker in 'ai-harness-init' 'add-lang'; do
	grep -qF -- "$marker" <<<"$out" || fehlt="$fehlt [$marker]"
done
if [ -n "$fehlt" ]; then
	echo "start-smoke: FEHLER — Usage ohne Beleg fuer:$fehlt (lief wirklich --help?)" >&2
	exit 1
fi

echo "start-smoke: OK — $bin laeuft auf dieser Plattform und meldet seine Usage."
