#!/usr/bin/env bash
# pre-commit-amend-guard.sh — haelt `git commit --amend` ab, wenn der Index
# Pfade traegt, die im urspruenglich amendierten Commit (HEAD) nicht standen
# (AGENTS.md §3.10, Beobachtungs-Register
# BEO-ALL/amend-committet-fremde-index-eintraege-mit, 3 Belege — seit
# slice-amend-haelt-den-index-pfadrein).
#
# ZUSAGE. `--amend` committet den INDEX, nicht die eigenen Pfade des
# aufrufenden Vorgangs — laeuft zwischen dem letzten eigenen Commit und dem
# Amend ein paralleler Vorgang und hinterlaesst Pfade im Index, reisst der
# Amend sie mit (drei reale Faelle in der Beobachtung). Erkennt dieser
# Traeger `--amend` UND traegt der Index Pfade ausserhalb des amendierten
# Commits, bricht er ab (Exit 1) — es sei denn, `AMEND_EXPECTED_PATHS`
# (leerzeichen- oder zeilengetrennt) nennt genau diese Pfade vorab.
#
# ERKENNUNG von `--amend`. git reicht dem `pre-commit`-Hook keine Argumente,
# und der `prepare-commit-msg`-Hook unterscheidet `--amend` NICHT
# zuverlaessig von einem gewoehnlichen `-m`/`-F`-Commit (gemessen: bei
# `git commit --amend -F <datei>` ist `commit_source` ebenso `message` wie
# bei einem Nicht-Amend-Commit mit `-F`; nur unbeschriftetes `--amend` ohne
# `-m`/`-F` liefert `commit_source=commit` — genau der Aufrufstil, den diese
# Repo-Konvention nicht fuehrt, s. harness/README.md §Traceability "Commit
# via Message-Datei"). Erkannt wird `--amend` deshalb aus der Kommandozeile
# des aufrufenden `git`-Prozesses (PPID): `/proc/$PPID/cmdline`, sonst
# `ps -o args= -p $PPID`. Ist keines lesbar, ueberspringt der Traeger die
# Pruefung (fail-open), statt jeden Commit zu blockieren — benannte Grenze,
# keine Zusage.
#
# ENTSCHEIDUNG. `decide()` ist REIN: sie nimmt die bereits ermittelte Liste
# "Pfade im Index ausserhalb des amendierten Commits" und den Inhalt von
# `AMEND_EXPECTED_PATHS` entgegen und ruft selbst kein `git` — damit im
# gepinnten bats-Image ohne `git` testbar (s. harness/tools/slice-mv.sh Kopf,
# Abschnitt ZUSAGE; dieselbe Trennung wie harness/tools/history-range-guard.sh
# `decide()`). `has_amend_flag()` ist ebenso REIN: sie prueft eine bereits
# eingelesene Kommandozeile (zeilengetrennt, ein Token je Zeile) auf ein
# eigenstaendiges `--amend`-Token. Der volle Lauf liest die Kommandozeile
# ueber `/proc`/`ps`, ermittelt die Pfad-Liste ueber
# `git diff-tree --no-commit-id --name-only -r --root HEAD` (Pfade des
# amendierten Commits) gegen `git diff --cached --name-only <HEAD^ oder
# leerer Baum>` (Pfade des kuenftigen Commits) und reicht beides an die
# reinen Funktionen durch.
#
# GRENZE. Der Traeger erkennt genau EIN Muster: Pfade im Index, die der
# amendierte Commit selbst nicht enthielt. Er erkennt NICHT, ob `--amend`
# versehentlich den FALSCHEN Commit trifft, weil HEAD zwischen dem letzten
# eigenen Commit und dem Amend durch einen fremden Commit weitergewandert ist
# — dafuer muesste der aufrufende Vorgang seinen eigenen erwarteten
# HEAD-Stand mitbringen, was dieser Traeger nicht voraussetzt; in der Praxis
# unterscheiden sich dabei die Pfade des neuen Ziel-Commits meist trotzdem
# von denen des eigenen, und der Traeger faengt den Fall darum meist ueber
# dasselbe Muster — eine Garantie ist das nicht. Ohne lesbares
# `/proc/$PPID/cmdline` und ohne funktionierendes `ps -o args=` (kein
# erkennbarer Host) ueberspringt der Traeger die Pruefung; dieser Fall ist im
# gepinnten bats-Image nicht nachstellbar und darum nicht mit einem roten
# Gegenbeispiel belegt. Wirkt nur nach `make hooks-install` (lokale
# Konfiguration, reist nicht mit dem Klon) und wird von
# `git commit --no-verify` umgangen — dieselbe Grenze wie beim
# `commit-msg`-Traeger (harness/README.md §Traceability).
#
# ABGRENZUNG. Kein Gate und kein genereller Index-Waechter (§1 Ziel und
# Abgrenzung des Slice-Plans): geprueft wird ausschliesslich der
# `--amend`-Fall, nicht jeder Commit. Der Aufrufer ist der git-eigene Traeger
# .githooks/pre-commit; dessen Pruefung selbst liegt hier, damit shell-lint
# sie deckt.
#
# BELEG (echtes Repo, drei parallele Vorgaenge nachgestellt — reproduziert
# mit einem frischen `git init`):
#   $ echo eigen > eigen.txt && git add eigen.txt && git commit -q -m eigen
#   $ echo fremd > fremd.txt && git add fremd.txt   # paralleler Vorgang staged
#   $ AMEND_EXPECTED_PATHS= git commit -q --amend -m eigen-amend
#   pre-commit-amend-guard: --amend nimmt Pfade mit, die im urspruenglichen
#   Commit HEAD nicht standen:
#     fremd.txt
#   pre-commit-amend-guard: das ist das Muster aus
#   BEO-ALL/amend-committet-fremde-index-eintraege-mit — ein paralleler
#   Vorgang hat diese Pfade in den Index gelegt.
#   pre-commit-amend-guard: sind die Pfade gewollt, den Commit mit
#   AMEND_EXPECTED_PATHS="fremd.txt" wiederholen; sonst git reset <pfad> vor
#   dem Commit.
#   $ echo $?
#   1
#   Mit `AMEND_EXPECTED_PATHS="fremd.txt"` gesetzt haelt derselbe Aufruf an
#   (Exit 0) — der Pfad war vorab bestaetigt.
set -euo pipefail

empty_tree=4b825dc642cb6eb9a060e54bf8d69288fbee4904

# has_amend_flag <cmdline-zeilengetrennt> — REIN: 1, wenn ein eigenstaendiges
# `--amend`-Token vorkommt, sonst 0. Kein git-, kein /proc-Zugriff.
has_amend_flag() {
  local cmdline="$1"
  if printf '%s\n' "$cmdline" | grep -qxF -- '--amend'; then
    echo 1
  else
    echo 0
  fi
}

# decide <extra-pfade-zeilengetrennt> <erwartete-pfade> — REIN: kein
# git-Aufruf. `extra` sind die Pfade, die im Index stehen, aber nicht im
# amendierten Commit standen (bereits leere Zeilen entfernt, sortiert-eindeutig
# erwartet). Leer -> Exit 0 (nichts Fremdes). Sonst: jeder Pfad in `extra`
# muss in `erwartete` (leerzeichen-/zeilengetrennt) genannt sein, sonst Exit 1.
decide() {
  local extra="$1" expected="${2:-}"
  [ -n "$extra" ] || return 0

  if [ -n "$expected" ]; then
    local missing
    missing="$(comm -23 \
      <(printf '%s\n' "$extra" | sort -u) \
      <(printf '%s\n' "$expected" | tr ' \t' '\n' | sed '/^$/d' | sort -u))"
    if [ -z "$missing" ]; then
      echo "pre-commit-amend-guard: --amend erweitert HEAD um $(printf '%s\n' "$extra" | wc -l | tr -d ' ') Pfad(e), alle in AMEND_EXPECTED_PATHS bestaetigt."
      return 0
    fi
  fi

  echo "pre-commit-amend-guard: --amend nimmt Pfade mit, die im urspruenglichen Commit HEAD nicht standen:" >&2
  while IFS= read -r p; do
    [ -n "$p" ] && echo "  $p" >&2
  done <<<"$extra"
  echo "pre-commit-amend-guard: das ist das Muster aus BEO-ALL/amend-committet-fremde-index-eintraege-mit — ein paralleler Vorgang hat diese Pfade in den Index gelegt." >&2
  echo "pre-commit-amend-guard: sind die Pfade gewollt, den Commit mit AMEND_EXPECTED_PATHS=\"$(printf '%s' "$extra" | tr '\n' ' ')\" wiederholen; sonst git reset <pfad> vor dem Commit." >&2
  return 1
}

# --decide-amend <cmdline-zeilengetrennt>: nur has_amend_flag (Fixture, fuer
# test/pre-commit-amend-guard.bats — ohne git, ohne /proc).
if [ "${1:-}" = "--decide-amend" ]; then
  has_amend_flag "${2:-}"
  exit 0
fi

# --decide <extra> [<erwartet>]: nur decide() (Fixture, fuer
# test/pre-commit-amend-guard.bats — ohne git).
if [ "${1:-}" = "--decide" ]; then
  rc=0
  decide "${2:-}" "${3:-}" || rc=$?
  exit "$rc"
fi

# ---------- voller Lauf (git-facing) ----------

read_ppid_cmdline() {
  if [ -r "/proc/$PPID/cmdline" ]; then
    tr '\0' '\n' <"/proc/$PPID/cmdline" 2>/dev/null || true
  elif command -v ps >/dev/null 2>&1; then
    ps -o args= -p "$PPID" 2>/dev/null | tr ' ' '\n' || true
  fi
}

cmdline="$(read_ppid_cmdline)"
if [ -z "$cmdline" ]; then
  echo "pre-commit-amend-guard: --amend nicht erkennbar (kein /proc, ps liefert nichts) — Pruefung uebersprungen." >&2
  exit 0
fi

if [ "$(has_amend_flag "$cmdline")" != "1" ]; then
  exit 0
fi

cd "$(git rev-parse --show-toplevel)"

parent="$(git rev-parse -q --verify HEAD^ 2>/dev/null || echo "$empty_tree")"
orig_files="$(git diff-tree --no-commit-id --name-only -r --root HEAD 2>/dev/null || true)"
staged_files="$(git diff --cached --name-only "$parent" 2>/dev/null || true)"

extra="$(comm -23 \
  <(printf '%s\n' "$staged_files" | sed '/^$/d' | sort -u) \
  <(printf '%s\n' "$orig_files" | sed '/^$/d' | sort -u))"

rc=0
decide "$extra" "${AMEND_EXPECTED_PATHS:-}" || rc=$?
exit "$rc"
