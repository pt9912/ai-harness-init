#!/usr/bin/env bash
# history-range-guard.sh — Vorlauf-Waechter fuer history-lesende d-check-Module
# (`vcs`/`commits`, Targets `doc-immutable`/`doc-commits` in d-check.mk).
# Prueft VOR einem Modul-Lauf, dass eine angeforderte Range git-seitig
# AUFLOESBAR und NICHT LEER ist.
#
# ANLASS (gemessen): ein Klon der Tiefe 1 liefert fuer eine AUFLOESBARE, aber
# im flachen Klon LEERE Range (z. B. `HEAD..HEAD`) "0 Befund(e)", Exit 0 —
# d-check selbst unterscheidet das nicht von "wirklich nichts zu melden". Das
# ist die Klasse "blind und gruen" (harness/conventions.md MR-007 Setzung 3).
# Eine UNAUFLOESBARE Basis (z. B. `HEAD~1` im Tiefe-1-Klon) bricht dagegen
# schon OHNE diesen Waechter mit d-check Exit 2 ab ("object not found") —
# DAS deckt dieser Waechter nicht zusaetzlich; er meldet dieselbe Klasse nur
# VOR dem (teureren) docker run.
#
# WOFUER: ein eigenstaendiger Baustein (`make history-range-guard RANGE=...`),
# den ein history-lesender CI-Job VOR `make doc-immutable`/`make doc-commits`
# ruft. `--staged` vergleicht gegen den Index und braucht keine Tiefe > 1 —
# wird durchgereicht, ohne den Range-Check auszuloesen.
#
# ZWEI SCHICHTEN, aus demselben Grund wie harness/tools/component-freshness.sh
# getrennt: `decide()` ist REIN (nimmt eine bereits ermittelte Commit-Zahl
# entgegen, ruft selbst kein `git`) und damit hermetisch bats-testbar; der
# volle Lauf ruft `git rev-list --count` und reicht das Ergebnis an `decide()`
# durch. Das gepinnte bats-Image fuehrt kein `git`
# (s. harness/tools/slice-mv.sh Kopf, Abschnitt ZUSAGE) — ohne die Trennung
# waere die Entscheidungslogik nicht hermetisch pruefbar.
#
# BELEG (echter flacher Klon, DoD (1) im Slice-Plan slice-123 — "es lief"
# reicht der DoD nicht), reproduziert mit
# `git clone --depth 1 file://<repo> <klon> && cd <klon>`:
#   $ bash harness/tools/history-range-guard.sh HEAD..HEAD
#   history-range-guard: Range 'HEAD..HEAD' ist aufloesbar, aber LEER (0 Commits).
#     Klon-Tiefe: 1
#     Angeforderte Range: HEAD..HEAD
#     -> Checkout braucht 'fetch-depth: 0' (oder ausreichende Tiefe) fuer diesen Job.
#   $ echo $?
#   1
#   OHNE den Waechter meldet derselbe Klon fuer dieselbe Range (d-check direkt,
#   `--enable vcs --range HEAD..HEAD`, alle anderen Module disabled) "834
#   Datei(en) geprueft, 0 Befund(e)", Exit 0 — genau der blinde Gruen-Fall, den
#   DoD (1) verlangt, einmal rot zu sehen (die Datei-Zahl wandert mit dem
#   Bestand und ist kein Erwartungswert, MR-025 Setzung 2). Zum Vergleich die
#   UNAUFLOESBARE Basis, die dieser Waechter NICHT zusaetzlich deckt (d-check
#   selbst bricht hier schon ab):
#   $ bash harness/tools/history-range-guard.sh HEAD~1..HEAD
#   history-range-guard: Range 'HEAD~1..HEAD' ist NICHT aufloesbar (Basis fehlt im Klon?).
#     Klon-Tiefe: 1
#   $ echo $?
#   2
#
# GRENZE: ohne einen echten history-lesenden CI-Job ist dieser Beleg ein
# KONSTRUIERTER flacher Klon, kein echter CI-Lauf — schwaechere, aber
# zulaessige Deckung.
set -euo pipefail

# depth_info liefert die Klon-Tiefe fuer die Meldung: die Zeilenzahl in
# .git/shallow (eine Zeile je Shallow-Grenze), oder "voll", wenn die Datei
# fehlt. Nur fuer die Meldung — die Entscheidung selbst haengt an der
# Commit-Zahl der Range, nicht an dieser Zahl (Slice-Plan §1: "Der Waechter
# prueft die Range, nicht die Klon-Tiefe").
depth_info() {
  if [ -f .git/shallow ]; then
    wc -l <.git/shallow | tr -d ' '
  else
    echo "voll (kein Shallow-Klon)"
  fi
}

# decide <range> <count> — REIN: kein git-Aufruf, nur die schon ermittelte
# Commit-Zahl wird bewertet. Exit 0: nicht leer, OK. Exit 1: leer (0 Commits)
# — der Fall, den dieser Waechter faengt.
decide() {
  local range="$1" count="$2"
  if [ "$count" -eq 0 ]; then
    echo "history-range-guard: Range '$range' ist aufloesbar, aber LEER (0 Commits)." >&2
    echo "  Klon-Tiefe: $(depth_info)" >&2
    echo "  Angeforderte Range: $range" >&2
    echo "  -> Checkout braucht 'fetch-depth: 0' (oder ausreichende Tiefe) fuer diesen Job." >&2
    return 1
  fi
  echo "history-range-guard: Range '$range' aufgeloest, $count Commit(s) — OK."
}

# --decide <range> <count>: nur die reine Bewertung (Fixture, fuer den
# bats-Test test/history-range-guard.bats — ohne git, ohne Repo).
if [ "${1:-}" = "--decide" ]; then
  rc=0
  decide "${2:-}" "${3:-}" || rc=$?
  exit "$rc"
fi

range="${1:?Usage: history-range-guard.sh <base>..<head> | --staged | --decide <range> <count>}"

# --staged vergleicht den Index gegen HEAD und braucht keine Tiefe > 1 —
# durchreichen, ohne den Range-Check auszuloesen.
if [ "$range" = "--staged" ]; then
  exit 0
fi

cd "$(git rev-parse --show-toplevel)"

count="$(git rev-list --count "$range" 2>/dev/null)" || {
  echo "history-range-guard: Range '$range' ist NICHT aufloesbar (Basis fehlt im Klon?)." >&2
  echo "  Klon-Tiefe: $(depth_info)" >&2
  exit 2
}

rc=0
decide "$range" "$count" || rc=$?
exit "$rc"
