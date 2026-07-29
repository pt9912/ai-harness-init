#!/usr/bin/env bash
# artifact-copy.sh — ein gebautes Binary aus einem Image auf den Host holen
# (slice-051, LH-QA-04).
#
# WARUM EIN SKRIPT UND KEIN INLINE-RECIPE: die Logik war in `artifact` und
# `release-artifacts` zweimal inline im Makefile — und damit NICHT PRUEFBAR. Das
# gepinnte bats-Image traegt kein `make` und keine docker-CLI (gemessen), ein Test
# kann ein Recipe also nicht ausfuehren. Als Skript ist die Einheit netzlos
# testbar: ein `docker`-Stub im PATH genuegt, weil die zu pruefende Eigenschaft
# keinen Daemon braucht. Dieselbe Begruendung wie bei start-smoke.sh, und dieselbe
# Setzung dahinter (MR-014 Setzung 1: ein Check lebt versioniert im Repo, der
# Aufrufer ruft ihn nur). shell-lint deckt diese Datei.
#
# DAS ZIELVERZEICHNIS WIRD ANGELEGT. Das ist der Anlass des Slice: ein NUTZER
# meldete, dass `make artifact DEST=./bin` fehlschlaegt, wenn `bin` nicht existiert
# — `docker cp` bricht dann mit "invalid output path: directory … does not exist"
# ab. (Der Fehler selbst endet mit Exit 1; die 2 im Nutzer-Bericht war `make`s
# eigener Abbruch-Code — real nachgemessen, Review-Befund F-3.) Genau diesen Aufruf
# schreiben README und Benutzerhandbuch vor. Kein
# Sensor fand es, weil die CI den Defekt an der AUFRUFSTELLE umging
# (`mkdir -p dist` vor dem make-Aufruf) — sie war gruen, WEIL sie kompensierte.
# Die Kompensation gehoert ins Werkzeug, nicht in den Aufrufer.
#
# Aufruf: artifact-copy.sh <image> <ziel-verzeichnis> <ziel-dateiname> [<quell-pfad>]
# Der Quell-Pfad im Image ist optional und steht auf /out/ai-harness-init, solange
# niemand etwas anderes nennt (slice-059 holt so /out/span-emit aus der span-Stage).
set -euo pipefail

img="${1:-}"
destdir="${2:-}"
name="${3:-}"
src="${4:-/out/ai-harness-init}"

if [ -z "$img" ] || [ -z "$destdir" ] || [ -z "$name" ]; then
  echo "artifact-copy: Aufruf: artifact-copy.sh <image> <ziel-verzeichnis> <ziel-dateiname>" >&2
  exit 2
fi

# Das Zielverzeichnis anlegen, BEVOR kopiert wird — der Kern dieses Slice.
mkdir -p "$destdir"

cid="$(docker create "$img" true)"
trap 'docker rm -f "$cid" >/dev/null 2>&1' EXIT
docker cp "$cid:$src" "$destdir/$name"
