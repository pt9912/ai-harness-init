#!/usr/bin/env bash
# gates-fast — Einsprung des Targets `make gates` (Tier 2 je ADR-0108, nach der
# Fastpfad-Form ADR-0099): SKIP greift nur ueber dem VOLLSTAENDIG gedeckten
# je-Check-Satz — jeder Key unter .harness/state/gates-passed-<check>.key vorhanden,
# formal (64 Hex) und gleich dem, den der Satzerzeuger aus seiner Tafel-Menge
# (harness/tools/gates-keys.sh) berechnet. Bei Teildrift faehrt der Lauf GENAU die
# gedrifteten Checks und stuempelt nur deren Keys; jedes andere Zeichen (Key fehlt,
# fremder oder unformaler Stempel, Satzerzeuger-Fehler) faehrt den vollen Lauf ueber
# `make record-gates` — fail-closed (MR-017).
#
# SCHREIBER: die je-Check-Keys der gefahrenen Checks entstehen hier nach deren
# gruennem Exit ueber `gates-keys.sh stamp`. Der Stempel-Aufruf folgt dem make-Lauf;
# endet dieser rot, entsteht kein neuer Stempel, und ein stehender entwertet nicht —
# sein Wert bleibt, und die Leser sehen die Drift (ADR-0108 Festlegung 3, ADR-0035
# Festlegung 5-Form). DIE ZWEI GESAMT-DATEIEN (.harness/state/gates-passed.diffsha,
# .harness/state/gates-passed.head) entstehen wie bisher ALLEIN im Rezept
# `record-gates` (ADR-0083 Festlegung 3, weitere Leser) — dieser Wrapper schreibt sie
# nie (ADR-0108 Festlegung 2).
#
# DER BENANNTE REST (ADR-0108 Festlegung 4, je Tier-1): der lokale Docker-Cache-
# Zustand und die Host-Werkzeuge (bash, tar, git, docker) liegen ausserhalb jedes
# baum-abgeleiteten Schluessels; jede SKIP-Meldung nennt ihn. `GATES_FORCE=1`
# erzwingt den vollen Lauf — jeder andere Wert und das Fehlen sagen nichts.
#
# HERMETISCH TESTBAR ist die reine Klassifikation ueber den Modus
# `--entscheide <bericht> [force]`: eine Bericht-Datei, je Zeile `check stamp ist`
# (derselbe Aufbau wie im Lauf aus Stempel-Datei und Satzerzeuger). Ausgabe die
# gedrifteten Checks, zeilenweise; Exit 0 ohne Ausgabe = SKIP, Exit 0 mit Ausgabe =
# Teildrift, Exit 1 = voller Lauf, Exit 2 = Aufruf-Form. Das gepinnte bats-Image
# fuehrt weder `git` noch `make`. Die Verdrahtung misst test/gates-fastpfad.bats
# strukturell; das reale Rot-vor/Gruen-nach am vollen Pfad traegt `make gates`
# selbst: der erste Lauf nach Aenderung faehrt voll, jeder weitere ueber
# unveraendertem Baum SKIPpt (der zweite-Runde-Beleg der Einweihung, ADR-0108
# Fitness-Tabelle).
#
# GEKOPPELT: der Satzerzeuger ist die EINE Definition je Menge (ADR-0108 Festlegung
# 1); der Fast-Pfad und der Stop-Hook rufen ihn an, keine zweite Form. `head_wert`
# fuehrt hier NICHT mehr — die SKIP-Bedingung ist vom Stempel-Paar (Tier 1, ADR-0099)
# auf den je-Check-Satz (Tier 2) getreten; die zwei Gesamt-Werte beurteilt allein der
# Stop-Hook an seiner HEAD-Kante und seiner je-Check-Deckung (ADR-0108 Festlegung 5).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

key_file() { printf '%s\n' ".harness/state/gates-passed-${1}.key"; }

# die Form eines Schluessel-Werts: 64 Hex — die Form der Satzerzeuger-Ausgabe und
# jedes Stempels (die Form von harness/tools/working-tree-hash.sh); alles andere ist
# Parser-Zweifel (die fail-closed-Klasse, MR-017).
ist_keyform() {
  [[ "$1" =~ ^[0-9a-f]{64}$ ]]
}

# deck_oder_drift — die reine Klassifikation einer Berichts-Zeile:
#   <1> Stempel-Wert, <2> Satzerzeuger-Wert, <3> Check-Name.
#   Exit 0 ohne Ausgabe: gedeckt. Exit 0 mit Ausgabe: der Name driftet (beide formal,
#   ungleich). Exit 1: Satzerzeuger unformal, Stempel fehlt (leer) oder unformal —
#   die Klasse "voller Lauf", nicht eine je-Check-Drift.
deck_oder_drift() {
  if ! ist_keyform "$2"; then return 1; fi        # Satzerzeuger unformal -> voll
  if [ "$1" = "$2" ]; then return 0; fi            # gedeckt
  if ! ist_keyform "$1"; then return 1; fi         # Stempel fehlt/unformal -> voll
  printf '%s\n' "$3"
}

# entscheide — die reine SKIP-Bedingung ueber dem je-Check-Bericht:
# `entscheide <datei|-> [force]`, je Zeile `check stamp ist`. Druckt die gedrifteten
# Checks zeilenweise auf stdout; Exit 0 ohne Ausgabe = SKIP, Exit 0 mit Ausgabe =
# Teildrift, Exit 1 = voller Lauf. Der FORCE-Schalter gilt VOR jeder Klassifikation.
entscheide() {
  local bericht="$1" force="${2:-}" line="" name="" rest="" stamp="" ist="" out=""
  if [ "$force" = "1" ]; then return 1; fi
  if [ "$bericht" = "-" ]; then bericht="/dev/stdin"; fi
  while IFS= read -r line || [ -n "$line" ]; do
    [ -n "$line" ] || continue
    name="${line%% *}"
    rest="${line#* }"
    stamp="${rest%% *}"
    ist="${rest#* }"
    if ! out="$(deck_oder_drift "$stamp" "$ist" "$name")"; then return 1; fi
    if [ -n "$out" ]; then printf '%s\n' "$out"; fi
  done <"$bericht"
}

skip_meldung() {
  printf 'gates: SKIP — der je-Check-Stempel deckt den vollstaendigen Satz: %s (ADR-0108 Festlegung 3).\n' "$1"
  printf 'gates: Rest, den kein baum-abgeleiteter Schluessel deckt (ADR-0108 Festlegung 4): der lokale Docker-Cache-Zustand und die Host-Werkzeuge (bash, tar, git, docker). GATES_FORCE=1 erzwingt den vollen Lauf.\n'
}

rest_meldung() {
  printf 'gates: Rest, den kein baum-abgeleiteter Schluessel deckt (ADR-0108 Festlegung 4): der lokale Docker-Cache-Zustand und die Host-Werkzeuge (bash, tar, git, docker). GATES_FORCE=1 erzwingt den vollen Lauf.\n'
}

voll_meldung() {
  printf 'gates: voller Lauf — %s (fail-closed, ADR-0108 Festlegung 1, MR-017).\n' "$1" >&2
}

if [ "${1:-}" = "--entscheide" ]; then
  if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "gates-fast: --entscheide braucht einen Bericht-Pfad und optional den FORCE-Wert" >&2
    exit 2
  fi
  if out="$(entscheide "$2" "${3:-}")"; then
    if [ -n "$out" ]; then
      printf 'gates: TEILDRIFT — fahre genau die gedrifteten Checks: %s; die uebrigen Checks sind gedeckt und fahren keinen Lauf (ADR-0108 Festlegung 3).\n' "$(printf '%s\n' "$out" | tr '\n' ' ' | sed 's/ $//')"
		else
      printf 'gates: SKIP — der je-Check-Stempel deckt den vollstaendigen Satz: %s (ADR-0108 Festlegung 3).\n' "$(cut -d' ' -f1 "$2" | tr '\n' ' ' | sed 's/ $//')"
    fi
    rest_meldung
    exit 0
  fi
  exit 1
fi

# Lauf-Pfad: Bericht aus Stempel-Dateien und Satzerzeuger bauen, klassifizieren,
# dann SKIP, Teildrift oder voller Lauf (fail-closed). Der Bericht-Pfad liegt unter
# $TMPDIR, nie im Baum — ein ungetrackter Brief dort verschoebe den MR-003-Nachweis.
force="${GATES_FORCE:-}"
if [ "$force" = "1" ]; then
  voll_meldung "GATES_FORCE=1"
  exec make record-gates
fi

if ! checks="$(bash harness/tools/gates-keys.sh liste)"; then
  voll_meldung "der Satzerzeuger bietet die Kanten-Checks nicht"
  exec make record-gates
fi

bericht="$(mktemp -p "${TMPDIR:-/tmp}" gates-fast.XXXXXX)"

while IFS= read -r check; do
  [ -n "$check" ] || continue
  stamp="$(cat "$(key_file "$check")" 2>/dev/null || true)"
  if ! ist="$(bash harness/tools/gates-keys.sh key "$check" 2>/dev/null)"; then
    rm -f "$bericht"
    voll_meldung "Satzerzeuger-Fehler bei $check"
    exec make record-gates
  fi
  printf '%s %s %s\n' "$check" "$stamp" "$ist" >>"$bericht"
done <<<"$checks"

if ! drifts="$(entscheide "$bericht")"; then
  rm -f "$bericht"
  voll_meldung "ein je-Check-Key fehlt, traegt einen fremden oder unformalen Wert, oder der Satzerzeuger war unformal"
  exec make record-gates
fi
rm -f "$bericht"

if [ -z "$drifts" ]; then
  skip_meldung "$(printf '%s\n' "$checks" | tr '\n' ' ' | sed 's/ $//')"
  exit 0
fi

printf 'gates: TEILDRIFT — fahre genau die gedrifteten Checks: %s; die uebrigen Checks sind gedeckt und fahren keinen Lauf (ADR-0108 Festlegung 3).\n' "$(printf '%s\n' "$drifts" | tr '\n' ' ' | sed 's/ $//')"
rest_meldung

drifted=()
while IFS= read -r d; do
  [ -n "$d" ] || continue
  drifted+=("$d")
done <<<"$drifts"

make "${drifted[@]}" || exit $?
bash harness/tools/gates-keys.sh stamp "${drifted[@]}"
