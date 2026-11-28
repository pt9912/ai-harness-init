#!/usr/bin/env bash
# full-smoke-skip — die hermetische Klassifikation des E2E-Skip-Griffs (ADR-0111
# Festlegung 4): liest den committeten E2E-Stempel und beurteilt dessen
# `baum-hash`-Feld gegen den frisch gerechneten Baum-Hash. SKIP nur bei Deckung;
# fehlender Stempel, unformaler Wert, fremder Hash oder Parser-Zweifel faellt auf
# den vollen Lauf zurueck (fail-closed, MR-017).
#
# ADR-0111 Festlegung 4: der Stempel traegt zwei Zeilen — `baum-hash <64-hex>`
# (der Wert von harness/tools/working-tree-hash.sh am Lauf-Start; die tmp-Repos
# der E2E liegen ausserhalb des Baums) und `varianten <n>` (die Matrix lebt im
# Skript-Inhalt von full-smoke.sh und ist transitiv im Baum-Hash); kein
# Commit-SHA-Feld (Festlegung 3: zirkulaer), kein Datumsfeld (die Chronik traegt
# git). Der Konsum liest allein das baum-hash-Feld; ein E2E-Skip konserviert das
# Runner-Verdikt des Stempel-Laufs.
#
# DER LAUFPFAD DES GRIFFS liegt in harness/tools/full-smoke.sh (Umgebung
# FULL_SMOKE_SKIP_KONSULT=1, gesetzt nur vom push-auf-main-Job der CI,
# ADR-0111 Festlegung 2; am Host bleibt sie ungesetzt und der Lauf faehrt voll —
# der Host-Lauf ist der Schreiber des Stempels). Dieses Skript traegt die reine
# Entscheidung, derselbe Massstab wie der Lauf: ein zweiter Massstab entsteht
# hier nicht (ADR-0111 Festlegung 2, Form ADR-0035).
#
# FORM: `--entscheide <stempel-pfad> <frischer-baum-hash>`
#   Exit 0 (mit SKIP-Meldung): der Stempel deckt den Baum — SKIP erlaubt.
#   Exit 1: voller Lauf (Stempel fehlt, baum-hash fehlt/unformal/fremd, oder die
#           Frisch-Rechnung unformal).
#   Exit 2: Aufruf-Form.
# Hermetisch getestet ueber test/ci-stempel-committed.bats (dieselbe
# --entscheide-Form wie harness/tools/gates-fast.sh).
set -euo pipefail

# die Form eines baum-hash-Werts: 64 Hex — die Form der Satzerzeuger-Ausgabe
# (working-tree-hash.sh); alles andere ist Parser-Zweifel (MR-017).
ist_hashform() {
  [[ "$1" =~ ^[0-9a-f]{64}$ ]]
}

skip_meldung() {
  printf 'full-smoke-skip: SKIP — der committete E2E-Stempel deckt diesen Baum (ADR-0111 Festlegung 4).\n'
  printf 'full-smoke-skip: Rest, den kein baum-abgeleiteter Schluessel deckt (Festlegung 4): die Verfuegbarkeit des Traeger-Releases (SHA256SUMS, Asset des gepinnten Tags), die Registry- und Netz-Zustaende und die Runner-Fassung des CI-Laeufers — der E2E-Skip konserviert das Runner-Verdikt des Stempel-Laufs.\n'
}

# entscheide — liest den Stempel, waehlt die baum-hash-Zeile, beurteilt die
# Frisch-Rechnung dagegen. Ein anderes Feld traegt die Entscheidung nicht; die
# varianten-Zeile wird als Rest gelesen, nicht beurteilt.
entscheide() {
  local stempel="$1" frisch="$2" zeile feld wert baum=""
  if ! ist_hashform "$frisch"; then return 1; fi
  if [ ! -f "$stempel" ]; then return 1; fi
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    [ -n "$zeile" ] || continue
    feld="${zeile%% *}"
    wert="${zeile#* }"
    if [ "$feld" = "baum-hash" ]; then baum="$wert"; fi
  done <"$stempel"
  ist_hashform "$baum" || return 1
  [ "$baum" = "$frisch" ] || return 1
  return 0
}

if [ "${1:-}" = "--entscheide" ]; then
  if [ "$#" -ne 3 ]; then
    echo "full-smoke-skip: --entscheide braucht den Stempel-Pfad und den frischen Baum-Hash" >&2
    exit 2
  fi
  if entscheide "$2" "$3"; then
    skip_meldung
    exit 0
  fi
  exit 1
fi
echo "full-smoke-skip: Aufruf-Form — --entscheide <stempel-pfad> <frischer-baum-hash>" >&2
exit 2
