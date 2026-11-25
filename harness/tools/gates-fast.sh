#!/usr/bin/env bash
# gates-fast — Einsprung des Targets `make gates` (ADR-0099): SKIP greift nur über
# dem vollständig gedeckten Stempel-Paar — demselben Urteil, das der Stop-Hook am
# Turn-Ende fällt (ADR-0083 Festlegung 1) — und sonst, bei jedem Zweifel, fährt der
# volle Lauf über `make record-gates` (fail-closed, ADR-0099 Festlegung 4).
#
# SCHREIBER BLEIBT record-gates: dieses Skript schreibt nichts und löscht nichts —
# `.harness/state/gates-passed.diffsha` und `.harness/state/gates-passed.head`
# entstehen allein im Rezept `record-gates` und werden vom Stop-Hook unverändert
# konsumiert (ADR-0099 Festlegung 1).
#
# DER BENANNTE REST (ADR-0099 Festlegung 2): der lokale Docker-Cache-Zustand und die
# Host-Werkzeuge (bash, tar, git, docker) liegen außerhalb jedes baum-abgeleiteten
# Schlüssels; die SKIP-Meldung nennt ihn. `GATES_FORCE=1` erzwingt den vollen Lauf
# (Festlegung 3) — jeder andere Wert und das Fehlen sagen nichts.
#
# HERMETISCH TESTBAR ist die reine Entscheidung über den Modus `--entscheide`
# (5 Fixture-Werte) — das gepinnte bats-Image führt weder `git` noch `make`
# (Abschnitt ENTSCHEIDUNG im Kopf von harness/tools/pre-commit-amend-guard.sh,
# dieselbe Grenze). Die Verdrahtung (Makefile-Rezept, Weiterleitung an
# `make record-gates`, kein Stempel-Schreiben) misst test/gates-fastpfad.bats
# strukturell; das reale Rot-vor/Gruen-nach am vollen Pfad trägt `make gates`
# selbst: der erste Lauf über einem geänderten Baum fährt voll, jeder weitere
# über unverändertem Baum SKIPpt.
#
# KOPPLUNG: head_wert ist exakt dieselbe Fassung wie in harness/tools/record-gates.sh
# und .claude/hooks/stop-require-gates.sh — drei Fassungen gleich halten; der
# Gleichheits-Wächter über den drei Funktionstexten steht in test/gates-fastpfad.bats.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

diffsha_file=".harness/state/gates-passed.diffsha"
head_file=".harness/state/gates-passed.head"

# head_wert — exakt dieselbe Fassung wie record-gates.sh und der Stop-Hook:
# die aufgelöste SHA von HEAD; `kein-commit` nur auf einem ungeborenen Zweig
# in einem Repo ohne einzigen Commit; jede andere Lage ist ein Git-Fehler (Exit 1)
# und fährt hier den vollen Lauf.
head_wert() {
  local sha alle
  if sha="$(git rev-parse --verify -q HEAD)"; then
    printf '%s\n' "$sha"
    return 0
  fi
  git symbolic-ref -q HEAD >/dev/null || return 1
  alle="$(git rev-list -n1 --all)" || return 1
  [ -z "$alle" ] || return 1
  printf '%s\n' kein-commit
}

# Baum-Hash-Form: die Ausgabe von harness/tools/working-tree-hash.sh ist ein
# 64-stelliger Hex-String; alles andere (leer, gestutzt, fremdes Format) ist
# Parser-Zweifel und fährt den vollen Lauf (ADR-0099 Festlegung 4, MR-017).
stammt_aus_baum() {
  [[ "$1" =~ ^[0-9a-f]{64}$ ]]
}

# HEAD-Wert-Form: die SHA von rev-parse (40 bis 64 Hex) oder `kein-commit`;
# alles andere ist Parser-Zweifel.
stammt_von_head() {
  [[ "$1" =~ ^(kein-commit|[0-9a-f]{40,64})$ ]]
}

# entscheide — die reine SKIP-Bedingung (ADR-0099 Festlegungen 1/3/4):
# Exit 0 = SKIP (gedecktes Paar, der FORCE-Wert sagt nichts), Exit 1 = voller Lauf.
# Jede Unform der Stempel-Werte fällt in Exit 1 — der SKIP urteilt nie über das
# hinaus, was er sicher lesen kann.
entscheide() {
  local stamp_diff="$1" stamp_head="$2" ist_diff="$3" ist_head="$4" force="$5"
  [ "$force" = "1" ] && return 1
  stammt_aus_baum "$stamp_diff" || return 1
  stammt_von_head "$stamp_head" || return 1
  [ "$stamp_diff" = "$ist_diff" ] || return 1
  [ "$stamp_head" = "$ist_head" ] || return 1
  return 0
}

skip_meldung() {
  printf 'gates: SKIP — der Gate-Stempel (gates-passed.diffsha + gates-passed.head) deckt Arbeitsbaum-Hash und HEAD (ADR-0099 Festlegung 1).\n'
  printf 'gates: Rest, den kein baum-abgeleiteter Schluessel deckt (ADR-0099 Festlegung 2): der lokale Docker-Cache-Zustand und die Host-Werkzeuge (bash, tar, git, docker). GATES_FORCE=1 erzwingt den vollen Lauf.\n'
}

if [ "${1:-}" = "--entscheide" ]; then
  if [ "$#" -ne 6 ]; then
    echo "gates-fast: --entscheide braucht 5 Fixture-Werte: Stempel-diffsha Stempel-head ist-diffsha ist-head GATES_FORCE" >&2
    exit 2
  fi
  if entscheide "$2" "$3" "$4" "$5" "$6"; then
    skip_meldung
    exit 0
  fi
  exit 1
fi

force="${GATES_FORCE:-}"
stamp_diff="$(cat "$diffsha_file" 2>/dev/null || true)"
stamp_head="$(cat "$head_file" 2>/dev/null || true)"

if ! ist_diff="$(bash harness/tools/working-tree-hash.sh)"; then
  echo "gates-fast: Arbeitsbaum-Hash nicht lesbar — voller Lauf (fail-closed, ADR-0099 Festlegung 4)." >&2
  exec make record-gates
fi
if ! ist_head="$(head_wert)"; then
  echo "gates-fast: HEAD nicht aufloesbar, das Repo auch nicht als commitlos erkannt — voller Lauf (fail-closed, ADR-0099 Festlegung 4)." >&2
  exec make record-gates
fi

if entscheide "$stamp_diff" "$stamp_head" "$ist_diff" "$ist_head" "$force"; then
  skip_meldung
  exit 0
fi

exec make record-gates
